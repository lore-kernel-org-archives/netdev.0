From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Thu, 19 May 2016 22:50:32 -0700
Message-ID: <1463723432.18194.274.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpUj9u4bgG+7Tc06z0_wSRhAWCVSz5KsydrhcmpoJf39tg@mail.gmail.com>
	 <1463712330.18194.261.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpVGjibj_bU2k_27O_PmzG1tqc6wHhg03yUe2RGzR++owA@mail.gmail.com>
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
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36246 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbcETFuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 01:50:35 -0400
Received: by mail-pa0-f65.google.com with SMTP id xm6so9858729pab.3
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 22:50:35 -0700 (PDT)
In-Reply-To: <CAM_iQpVGjibj_bU2k_27O_PmzG1tqc6wHhg03yUe2RGzR++owA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-19 at 22:23 -0700, Cong Wang wrote:
> On Thu, May 19, 2016 at 7:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2016-05-19 at 18:50 -0700, Cong Wang wrote:
> >> On Thu, May 19, 2016 at 5:35 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> >
> >> > These stats are using u64 or u32 fields, so reading integral values
> >> > should not prevent writers from doing concurrent updates if the kernel
> >> > arch is a 64bit one.
> >> >
> >> > Being able to atomically fetch all counters like packets and bytes sent
> >> > at the expense of interfering in fast path (queue and dequeue packets)
> >> > is simply not worth the pain, as the values are generally stale after 1
> >> > usec.
> >>
> >> I think one purpose of this lock is to make sure we have an atomic
> >> snapshot of these counters as a whole. IOW, we may need another
> >> lock rather than the qdisc root lock to guarantee this.
> >
> > Right, this was stated in the changelog.
> >
> > I played a bit at changing qdisc->__state to a seqcount.
> >
> > But this would add 2 additional smp_wmb() barriers.
> >
> > Not sure if any application would actually care if it reads
> >
> > Sent 22954160104777 bytes 1808585171 pkt (dropped 0, overlimits 0
> > requeues 26021)
> >
> > Instead of
> >
> > Sent 22954160104777 bytes 1808585172 pkt (dropped 0, overlimits 0
> > requeues 26021)
> >
> > ?
> 
> Sometimes I use bytes/pkts to valuate the average size of the packets.
> ;) It doesn't have to be that accurate but we don't know how inaccurate
> it is without lock?

It wont be inaccurate (no drift), as the writers hold the qdisc
spinlock.

It it the same with say IP/TCP SNMP counters :

When an incoming frame is handled, it might change many SNMP counters,
but an SNMP agent might fetch the whole set of SNMP values in the middle
of the changes.

IpInReceives
IpInDelivers 
TcpInSegs
IpExtInOctets
IpExtInNoECTPkts
...

The only 'problem' can be a off-by-one (or off-by-bytes-in-the-packet)
transient error, that all SNMP agents are normally handling just fine.
