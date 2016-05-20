From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Thu, 19 May 2016 19:45:30 -0700
Message-ID: <1463712330.18194.261.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpUj9u4bgG+7Tc06z0_wSRhAWCVSz5KsydrhcmpoJf39tg@mail.gmail.com>
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
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36103 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753693AbcETCpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 22:45:34 -0400
Received: by mail-pf0-f196.google.com with SMTP id g132so9844798pfb.3
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 19:45:33 -0700 (PDT)
In-Reply-To: <CAM_iQpUj9u4bgG+7Tc06z0_wSRhAWCVSz5KsydrhcmpoJf39tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-19 at 18:50 -0700, Cong Wang wrote:
> On Thu, May 19, 2016 at 5:35 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > These stats are using u64 or u32 fields, so reading integral values
> > should not prevent writers from doing concurrent updates if the kernel
> > arch is a 64bit one.
> >
> > Being able to atomically fetch all counters like packets and bytes sent
> > at the expense of interfering in fast path (queue and dequeue packets)
> > is simply not worth the pain, as the values are generally stale after 1
> > usec.
> 
> I think one purpose of this lock is to make sure we have an atomic
> snapshot of these counters as a whole. IOW, we may need another
> lock rather than the qdisc root lock to guarantee this.

Right, this was stated in the changelog.

I played a bit at changing qdisc->__state to a seqcount.

But this would add 2 additional smp_wmb() barriers.

Not sure if any application would actually care if it reads

Sent 22954160104777 bytes 1808585171 pkt (dropped 0, overlimits 0
requeues 26021)

Instead of 

Sent 22954160104777 bytes 1808585172 pkt (dropped 0, overlimits 0
requeues 26021)

?
