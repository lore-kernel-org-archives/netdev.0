From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH v3 net] net: ipv6: regenerate host route if moved to gc
 list
Date: Mon, 24 Apr 2017 14:08:19 -0700
Message-ID: <20170424210819.5ynqc6rdf7z2gnox@kafai-mba.dhcp.thefacebook.com>
References: <1493046549-17420-1-git-send-email-dsa@cumulusnetworks.com>
 <1493051946.6453.37.camel@edumazet-glaptop3.roam.corp.google.com>
 <0ebdefd9-3f89-1876-ba03-1a8277ff79e2@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
        <dvyukov@google.com>, <andreyknvl@google.com>,
        <mmanning@brocade.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45615 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1428387AbdDXVIa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 17:08:30 -0400
Content-Disposition: inline
In-Reply-To: <0ebdefd9-3f89-1876-ba03-1a8277ff79e2@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 01:37:00PM -0600, David Ahern wrote:
> On 4/24/17 10:39 AM, Eric Dumazet wrote:
> >
> > Very nice changelog !
>
>
> Thanks. Given my aggressive brain cell recycling program, I needed to
> write down the analysis.
>
>
>
> >> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> >> index 80ce478c4851..93f81d9cd85f 100644
> >> --- a/net/ipv6/addrconf.c
> >> +++ b/net/ipv6/addrconf.c
> >> @@ -3271,14 +3271,25 @@ static void addrconf_gre_config(struct net_device *dev)
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
> >>  		if (unlikely(IS_ERR(rt)))
> >>  			return PTR_ERR(rt);
> >>
> >> +		prev = ifp->rt;
> >
> > I would feel more comfortable if this was moved after the spin_lock() ?
>
> That's what I had in v2; it reads better to me even if it is not
> technically required (all changes to ifp->rt happen under rtnl).
>
> Martin you agree?
Agree.

My question was mainly on the added spin_lock.

>
> I'll send a v3 tomorrow -- allow more time for other comments.
