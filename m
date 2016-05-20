From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Fri, 20 May 2016 06:01:20 -0700
Message-ID: <1463749280.18194.281.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpUj9u4bgG+7Tc06z0_wSRhAWCVSz5KsydrhcmpoJf39tg@mail.gmail.com>
	 <1463712330.18194.261.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1463748265.18194.279.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35690 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075AbcETNBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 09:01:23 -0400
Received: by mail-pf0-f194.google.com with SMTP id b66so11272638pfb.2
        for <netdev@vger.kernel.org>; Fri, 20 May 2016 06:01:22 -0700 (PDT)
In-Reply-To: <1463748265.18194.279.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-05-20 at 05:44 -0700, Eric Dumazet wrote:
> On Thu, 2016-05-19 at 19:45 -0700, Eric Dumazet wrote:
> > On Thu, 2016-05-19 at 18:50 -0700, Cong Wang wrote:
> > > On Thu, May 19, 2016 at 5:35 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > >
> > > > These stats are using u64 or u32 fields, so reading integral values
> > > > should not prevent writers from doing concurrent updates if the kernel
> > > > arch is a 64bit one.
> > > >
> > > > Being able to atomically fetch all counters like packets and bytes sent
> > > > at the expense of interfering in fast path (queue and dequeue packets)
> > > > is simply not worth the pain, as the values are generally stale after 1
> > > > usec.
> > > 
> > > I think one purpose of this lock is to make sure we have an atomic
> > > snapshot of these counters as a whole. IOW, we may need another
> > > lock rather than the qdisc root lock to guarantee this.
> > 
> > Right, this was stated in the changelog.
> > 
> > I played a bit at changing qdisc->__state to a seqcount.
> > 
> > But this would add 2 additional smp_wmb() barriers.
> 
> Although this would allow the mechanism to be used both on 32bit an
> 64bit kernels.
> 
> This would also add LOCKDEP annotations which can be nice for debugging.
> 
> Also the seqcount value >> 1 would give us the number of __qdisc_run()
> and we could compute packets/(seqcount>>1) to get the average number of
> packets processed per round.

Tricky, since sch_direct_xmit() releases the qdisc spinlock and grabs it
again, while owning the ' running seqcount'

Needs more LOCKDEP tricks ;)
