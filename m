From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Tue, 1 Sep 2015 15:25:33 -0700
Message-ID: <20150901222533.GB66075@kafai-mba.local>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
 <1441133703-1570969-4-git-send-email-kafai@fb.com>
 <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150901205505.GA66075@kafai-mba.local>
 <1441142818.8932.185.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:6655 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752361AbbIAWZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 18:25:41 -0400
Content-Disposition: inline
In-Reply-To: <1441142818.8932.185.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2015 at 02:26:58PM -0700, Eric Dumazet wrote:
> On Tue, 2015-09-01 at 13:55 -0700, Martin KaFai Lau wrote:
> > On Tue, Sep 01, 2015 at 01:14:20PM -0700, Eric Dumazet wrote:
> > > It should not be a problem. refcnt is taken when/if necessary (skb
> > > queued on a qdisc for example)
> > >
> > > We have other uses of skb_dst_set_noref()
> > >
> > > Please describe the problem ?
> > The current ip6_tnl_dst_get() does not take the dst refcnt.
> >
> > If the dst is released after ip6_tnl_dst_get() and before
> > skb_dst_set_noref(), would it cause an issue?
>
> We are under rcu here, and a dst in a cache is protected by RCU by
> definition.
>
> skb_dst_set_noref() has following debugging clause, does it trigger for
> you ?
>
> WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
No. I did not see this.

I am probably missing something.  Do you mean the rcu can
protect the followings:


ip6_tnl_dst_get()
			dst_release()
						dst_free() /* refcnt is 0 */
skb_dst_set_noref()

--------

or for DST_NOCACHE

ip6_tnl_dst_get()
			dst_release() /* refcnt is 0 */
skb_dst_set_noref()
/* ip6tunnel_xmit()
 * or its callees
 * take a dst refcnt
 */

--------

or the above situation does not matter/will not happen?
