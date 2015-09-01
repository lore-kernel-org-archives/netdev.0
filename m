From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Tue, 01 Sep 2015 15:38:36 -0700
Message-ID: <1441147116.8932.188.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
	 <1441133703-1570969-4-git-send-email-kafai@fb.com>
	 <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150901205505.GA66075@kafai-mba.local>
	 <1441142818.8932.185.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150901222533.GB66075@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36072 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbbIAWii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 18:38:38 -0400
Received: by pacwi10 with SMTP id wi10so9536314pac.3
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 15:38:37 -0700 (PDT)
In-Reply-To: <20150901222533.GB66075@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-01 at 15:25 -0700, Martin KaFai Lau wrote:
> On Tue, Sep 01, 2015 at 02:26:58PM -0700, Eric Dumazet wrote:
> > On Tue, 2015-09-01 at 13:55 -0700, Martin KaFai Lau wrote:
> > > On Tue, Sep 01, 2015 at 01:14:20PM -0700, Eric Dumazet wrote:
> > > > It should not be a problem. refcnt is taken when/if necessary (skb
> > > > queued on a qdisc for example)
> > > >
> > > > We have other uses of skb_dst_set_noref()
> > > >
> > > > Please describe the problem ?
> > > The current ip6_tnl_dst_get() does not take the dst refcnt.
> > >
> > > If the dst is released after ip6_tnl_dst_get() and before
> > > skb_dst_set_noref(), would it cause an issue?
> >
> > We are under rcu here, and a dst in a cache is protected by RCU by
> > definition.
> >
> > skb_dst_set_noref() has following debugging clause, does it trigger for
> > you ?
> >
> > WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
> No. I did not see this.
> 
> I am probably missing something.  Do you mean the rcu can
> protect the followings:
> 
> 
> ip6_tnl_dst_get()
> 			dst_release()
> 						dst_free() /* refcnt is 0 */
> skb_dst_set_noref()
> 

Yes, this is protected by normal rcu rules.

dst wont be freed until all cpus exit their rcu read sections.

> --------
> 
> or for DST_NOCACHE
> 
> ip6_tnl_dst_get()
> 			dst_release() /* refcnt is 0 */
> skb_dst_set_noref()
> /* ip6tunnel_xmit()
>  * or its callees
>  * take a dst refcnt
>  */
> 



> --------
> 
> or the above situation does not matter/will not happen?
> --

You should take a look at following commits for a bit of history

10e2eb878f3ca07ac2f05fa5ca5e6c4c9174a27a
dbfc4fb7d578d4f224faa6b60deb40804dfdc1b1
f88649721268999bdff09777847080a52004f691
6c7e7610ff6888ea15a901fbcb30c5d461816b34
