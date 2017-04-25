From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH v4 net] net: ipv6: regenerate host route if moved to gc
 list
Date: Tue, 25 Apr 2017 10:18:46 -0700
Message-ID: <20170425171846.ldh3hwg2hrrqlffu@kafai-mba.local>
References: <1493137049-16465-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <dvyukov@google.com>,
        <andreyknvl@google.com>, <mmanning@brocade.com>,
        <eric.dumazet@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55973 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1951780AbdDYRSx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:18:53 -0400
Content-Disposition: inline
In-Reply-To: <1493137049-16465-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 09:17:29AM -0700, David Ahern wrote:
[...]
>
> All of those faults are fixed by regenerating the host route if the
> existing one has been moved to the gc list, something that can be
> determined by checking if the rt6i_ref counter is 0.
Acked-by: Martin KaFai Lau <kafai@fb.com>

>
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

> ---
> v4
> - move 'prev = ifp->rt;' under spinlock as requested by Eric
>
> v3
> - removed 'if (prev)' and just call ip6_rt_put; added comment about spinlock
>
> v2
> - change ifp->rt under spinlock vs cmpxchg
> - add comment about rt6i_ref == 0
>
>  net/ipv6/addrconf.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 80ce478c4851..0ea96c4d334d 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3271,14 +3271,24 @@ static void addrconf_gre_config(struct net_device *dev)
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
> +		/* ifp->rt can be accessed outside of rtnl */
> +		spin_lock(&ifp->lock);
> +		prev = ifp->rt;
>  		ifp->rt = rt;
> +		spin_unlock(&ifp->lock);
> +
> +		ip6_rt_put(prev);
>  	}
>
>  	if (!(ifp->flags & IFA_F_NOPREFIXROUTE)) {
> --
> 2.1.4
>
