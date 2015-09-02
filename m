From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Tue, 1 Sep 2015 18:55:31 -0700
Message-ID: <20150902015515.GA77832@kafai-mba.local>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
 <1441133703-1570969-4-git-send-email-kafai@fb.com>
 <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36967 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750717AbbIBBzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 21:55:42 -0400
Content-Disposition: inline
In-Reply-To: <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2015 at 01:14:20PM -0700, Eric Dumazet wrote:
> On Tue, 2015-09-01 at 11:55 -0700, Martin KaFai Lau wrote:
> > Problems in the current dst_entry cache in the ip6_tunnel:
> >
> > 1. ip6_tnl_dst_set is racy.  There is no lock to protect it:
> >    - One major problem is that the dst refcnt gets messed up. F.e.
> >      the same dst_cache can be released multiple times and then
> >      triggering the infamous dst refcnt < 0 warning message.
> >    - Another issue is the inconsistency between dst_cache and
> >      dst_cookie.
> >
> >    It can be reproduced by adding and removing the ip6gre tunnel
> >    while running a super_netperf TCP_CRR test.
> >
> > 2. In ip6_tnl_xmit2() and ip6gre_xmit2(), the outgoing skb does
> >    not hold a dst_entry's refcnt.
>
> It should not be a problem. refcnt is taken when/if necessary (skb
> queued on a qdisc for example)
>
> We have other uses of skb_dst_set_noref()
>
> Please describe the problem ?
After some more thoughts, I think it could be that the commit description is
inaccurate/confusing.  skb_dst_set_noref() is not the _source_ of the
problem per se.  Instead, the ip6_tnl_dst_get() should always bump the
dst refcnt before returning the dst. Using skb_dst_set() instead
of skb_dst_set_noref() here is just a follow-through effect.
