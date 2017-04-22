From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net] net: ipv6: regenerate host route if moved to gc list
Date: Fri, 21 Apr 2017 22:57:03 -0700
Message-ID: <20170422055703.uo4ghu5jfbctxvud@kafai-mba.dhcp.thefacebook.com>
References: <1492818030-17640-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <dvyukov@google.com>,
        <andreyknvl@google.com>, <mmanning@brocade.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47193 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1040722AbdDVF6V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 01:58:21 -0400
Content-Disposition: inline
In-Reply-To: <1492818030-17640-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 04:40:30PM -0700, David Ahern wrote:
> Taking down the loopback device wreaks havoc on IPv6 routes. By
> extension, taking a VRF device wreaks havoc on its table.
>
> Dmitry and Andrey both reported heap out-of-bounds reports in the IPv6
> FIB code while running syzkaller fuzzer. The root cause is a dead dst
> that is on the garbage list gets reinserted into the IPv6 FIB. While on
> the gc (or perhaps when it gets added to the gc list) the dst->next is
> set to an IPv4 dst. A subsequent walk of the ipv6 tables causes the
> out-of-bounds access.
Thanks for the investigation and details explanation.

It sounds like the dst is already in DST_OBSOLETE_DEAD during
the second fib6_add().  Glad that the fib6_del() caught it.

>
> Andrey's reproducer was the key to getting to the bottom of this.
>
> With IPv6, host routes for an address have the dst->dev set to the
> loopback device. When the 'lo' device is taken down, rt6_ifdown initiates
> a walk of the fib evicting routes with the 'lo' device which means all
> host routes are removed. That process moves the dst which is attached to
> an inet6_ifaddr to the gc list and marks it as dead.
>
> The recent change to keep global IPv6 addresses added a new function
> fixup_permanent_addr that is called on admin up. That function restarts
> dad for an inet6_ifaddr and when it completes the host route attached
> to it is inserted into the fib. Since the route was marked dead and
> moved to the gc list, we get the reported out-of-bounds accesses. If
> the device with the address is taken down or the address is removed, the
> WARN_ON in fib6_del is triggered.
>
> All of those faults are fixed by regenerating the host route of the
> existing one has been moved to the gc list, something that can be
> determined by checking if the rt6i_ref counter is 0.
>
> The update of the route on the ifp is done using cmpxchg as suggested
> by Li RongQing in a patch a year ago.
>
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/ipv6/addrconf.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 08f9e8ea7a81..93555528a45b 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3303,14 +3303,16 @@ static void addrconf_gre_config(struct net_device *dev)
>  static int fixup_permanent_addr(struct inet6_dev *idev,
>  				struct inet6_ifaddr *ifp)
>  {
> -	if (!ifp->rt) {
> -		struct rt6_info *rt;
> +	if (!ifp->rt || !atomic_read(&ifp->rt->rt6i_ref)) {
> +		struct rt6_info *rt, *prev;
>
>  		rt = addrconf_dst_alloc(idev, &ifp->addr, false);
>  		if (unlikely(IS_ERR(rt)))
>  			return PTR_ERR(rt);
>
> -		ifp->rt = rt;
> +		prev = cmpxchg(&ifp->rt, ifp->rt, rt);
One small question.  Why cmpxchg is needed instead
of a ip6_rt_put() and then assign?
Is it fixing another bug?


> +		if (prev)
> +			ip6_rt_put(prev);
>  	}
>
>  	if (!(ifp->flags & IFA_F_NOPREFIXROUTE)) {
> --
> 2.1.4
>
