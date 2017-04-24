From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net] net: ipv6: regenerate host route if moved to gc
 list
Date: Mon, 24 Apr 2017 09:39:06 -0700
Message-ID: <1493051946.6453.37.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493046549-17420-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, andreyknvl@google.com,
        mmanning@brocade.com, kafai@fb.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35920 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S974821AbdDXQjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 12:39:10 -0400
Received: by mail-it0-f66.google.com with SMTP id x188so17517247itb.3
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 09:39:09 -0700 (PDT)
In-Reply-To: <1493046549-17420-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-24 at 08:09 -0700, David Ahern wrote:
> Taking down the loopback device wreaks havoc on IPv6 routing. By
> extension, taking down a VRF device wreaks havoc on its table.
> 
> Dmitry and Andrey both reported heap out-of-bounds reports in the IPv6
> FIB code while running syzkaller fuzzer. The root cause is a dead dst
> that is on the garbage list gets reinserted into the IPv6 FIB. While on
> the gc (or perhaps when it gets added to the gc list) the dst->next is
> set to an IPv4 dst. A subsequent walk of the ipv6 tables causes the
> out-of-bounds access.
> 
> Andrey's reproducer was the key to getting to the bottom of this.
> 
> With IPv6, host routes for an address have the dst->dev set to the
> loopback device. When the 'lo' device is taken down, rt6_ifdown initiates
> a walk of the fib evicting routes with the 'lo' device which means all
> host routes are removed. That process moves the dst which is attached to
> an inet6_ifaddr to the gc list and marks it as dead.
> 
> The recent change to keep global IPv6 addresses added a new function,
> fixup_permanent_addr, that is called on admin up. That function restarts
> dad for an inet6_ifaddr and when it completes the host route attached
> to it is inserted into the fib. Since the route was marked dead and
> moved to the gc list, re-inserting the route causes the reported
> out-of-bounds accesses. If the device with the address is taken down
> or the address is removed, the WARN_ON in fib6_del is triggered.
> 
> All of those faults are fixed by regenerating the host route if the
> existing one has been moved to the gc list, something that can be
> determined by checking if the rt6i_ref counter is 0.

Very nice changelog !

> 
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v3
> - removed 'if (prev)' and just call ip6_rt_put; added comment about spinlock
> 
> v2
> - change ifp->rt under spinlock vs cmpxchg
> - add comment about rt6i_ref == 0
> 
>  net/ipv6/addrconf.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 80ce478c4851..93f81d9cd85f 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3271,14 +3271,25 @@ static void addrconf_gre_config(struct net_device *dev)
>  static int fixup_permanent_addr(struct inet6_dev *idev,
>  				struct inet6_ifaddr *ifp)
>  {
> -	if (!ifp->rt) {
> -		struct rt6_info *rt;
> +	/* rt6i_ref == 0 means the host route was removed from the
> +	 * FIB, for example, if 'lo' device is taken down. In that
> +	 * case regenerate the host route.
> +	 */
> +	if (!ifp->rt || !atomic_read(&ifp->rt->rt6i_ref)) {
> +		struct rt6_info *rt, *prev;
>  
>  		rt = addrconf_dst_alloc(idev, &ifp->addr, false);
>  		if (unlikely(IS_ERR(rt)))
>  			return PTR_ERR(rt);
>  
> +		prev = ifp->rt;

I would feel more comfortable if this was moved after the spin_lock() ?

> +
> +		/* ifp->rt can be accessed outside of rtnl */
> +		spin_lock(&ifp->lock);
>  		ifp->rt = rt;
> +		spin_unlock(&ifp->lock);
> +
> +		ip6_rt_put(prev);
>  	}
>  
>  	if (!(ifp->flags & IFA_F_NOPREFIXROUTE)) {

Thanks !
