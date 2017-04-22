From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH v2 net] net: ipv6: regenerate host route if moved to gc
 list
Date: Sat, 22 Apr 2017 15:00:41 -0700
Message-ID: <20170422220041.wha72qa3zuy23hkf@kafai-mba.local>
References: <1492879237-31566-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <dvyukov@google.com>,
        <andreyknvl@google.com>, <mmanning@brocade.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59189 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1427263AbdDVWAt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 18:00:49 -0400
Content-Disposition: inline
In-Reply-To: <1492879237-31566-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 22, 2017 at 09:40:37AM -0700, David Ahern wrote:
[...]
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 08f9e8ea7a81..97e86158bbcb 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3303,14 +3303,24 @@ static void addrconf_gre_config(struct net_device *dev)
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
The rt regernation makes sense.

>  		if (unlikely(IS_ERR(rt)))
>  			return PTR_ERR(rt);
>
> +		spin_lock(&ifp->lock);
> +		prev = ifp->rt;
>  		ifp->rt = rt;
I am still missing something on the new spin_lock:
1) Is there an existing race in the existing
   ifp->rt modification ('ipf->rt = rt') which is
   not related to this bug?
2) If there is a race in ifp->rt, is the above if-checks
   on ifp->rt racy and need protection also? F.e. 'ifp->rt->rt6i_ref'
   since ifp->rt could be NULL or ifp->rt->rt6i_ref
   may not be zero later if there is concurrent
   modification on ifp->rt?

> +		spin_unlock(&ifp->lock);
> +
> +		if (prev)
> +			ip6_rt_put(prev);
Nit. ip6_rt_put() takes NULL.

>  	}
>
>  	if (!(ifp->flags & IFA_F_NOPREFIXROUTE)) {
> --
> 2.1.4
>
