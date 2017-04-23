From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH v2 net] net: ipv6: regenerate host route if moved to gc
 list
Date: Sat, 22 Apr 2017 19:28:01 -0700
Message-ID: <20170423022801.t7lw3vuazo2ks6u4@kafai-mba.local>
References: <1492879237-31566-1-git-send-email-dsa@cumulusnetworks.com>
 <20170422220041.wha72qa3zuy23hkf@kafai-mba.local>
 <072e9af7-2163-ce53-ce74-a288e0934825@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <dvyukov@google.com>,
        <andreyknvl@google.com>, <mmanning@brocade.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:53584 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1427396AbdDWC2H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 22:28:07 -0400
Content-Disposition: inline
In-Reply-To: <072e9af7-2163-ce53-ce74-a288e0934825@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 22, 2017 at 07:12:34PM -0600, David Ahern wrote:
> On 4/22/17 4:00 PM, Martin KaFai Lau wrote:
> > On Sat, Apr 22, 2017 at 09:40:37AM -0700, David Ahern wrote:
> > [...]
> >> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> >> index 08f9e8ea7a81..97e86158bbcb 100644
> >> --- a/net/ipv6/addrconf.c
> >> +++ b/net/ipv6/addrconf.c
> >> @@ -3303,14 +3303,24 @@ static void addrconf_gre_config(struct net_device *dev)
> >>  static int fixup_permanent_addr(struct inet6_dev *idev,
> >>  				struct inet6_ifaddr *ifp)
> >>  {
> >> -	if (!ifp->rt) {
> >> -		struct rt6_info *rt;
> >> +	/* rt6i_ref == 0 means the host route was removed from the
> >> +	 * FIB, for example, if 'lo' device is taken down. In that
> >> +	 * case regenerate the host route.
> >> +	 */
> >> +	if (!ifp->rt || !atomic_read(&ifp->rt->rt6i_ref)) {
> >> +		struct rt6_info *rt, *prev;
> >>
> >>  		rt = addrconf_dst_alloc(idev, &ifp->addr, false);
> > The rt regernation makes sense.
> >
> >>  		if (unlikely(IS_ERR(rt)))
> >>  			return PTR_ERR(rt);
> >>
> >> +		spin_lock(&ifp->lock);
> >> +		prev = ifp->rt;
> >>  		ifp->rt = rt;
> > I am still missing something on the new spin_lock:
> > 1) Is there an existing race in the existing
> >    ifp->rt modification ('ipf->rt = rt') which is
> >    not related to this bug?
> > 2) If there is a race in ifp->rt, is the above if-checks
> >    on ifp->rt racy and need protection also? F.e. 'ifp->rt->rt6i_ref'
> >    since ifp->rt could be NULL or ifp->rt->rt6i_ref
> >    may not be zero later if there is concurrent
> >    modification on ifp->rt?
>
> As I understand it:
> - rt6i_ref is modified by the fib code (adding and removing to tree) and
> always under RTNL.
> - ifp->rt is only *set* under RTNL, but is accessed without (dad via
> workqueue and sysctl).
>
> The code path to fixup_permanent_addr is under RTNL, so the if check on
> ifp->rt and rt6i_ref is ok -- neither can be changed since RTNL is held.
>
> Since ifp->rt can be accessed outside of RTNL, the spinlock is needed to
> change its value.
Got it. It is to protect the readers which are not under RTNL.
Many thanks for pointing out what I was missing.  It all makes sense now.

> Arguably only 'ifp->rt = rt;' needs the spinlock.
It still seems like the existing 'ifp->rt = rt;' needs protection
anyway regardless of the rt regeneration change.  It would be nice to
explain it in the commit log or even better separating it out
into another patch.

>
> There are many twists and turns with the ipv6 code.
Nod Nod :)

>
> >
> >> +		spin_unlock(&ifp->lock);
> >> +
> >> +		if (prev)
> >> +			ip6_rt_put(prev);
> > Nit. ip6_rt_put() takes NULL.
>
> ok.
>
