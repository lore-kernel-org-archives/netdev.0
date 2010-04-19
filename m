From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Mon, 19 Apr 2010 08:48:03 -0400
Message-ID: <1271681283.32453.39.camel@bigi>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <4BC741AE.3000108@hp.com> <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <k2h412e6f7f1004160634v88440075p6e4cb2404abdb006@mail.gmail.com>
	 <1271425753.4606.65.camel@bigi>
	 <r2q412e6f7f1004160710j6d575f36t8e39a283328cf2d7@mail.gmail.com>
	 <1271429025.4606.149.camel@bigi>
	 <s2z412e6f7f1004160758l823ea0cah61a409972d4865fe@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f182.google.com ([209.85.221.182]:39240 "EHLO
	mail-qy0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756Ab0DSMsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 08:48:08 -0400
Received: by qyk12 with SMTP id 12so5219527qyk.21
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 05:48:07 -0700 (PDT)
In-Reply-To: <s2z412e6f7f1004160758l823ea0cah61a409972d4865fe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry, didnt respond to you - busyed out setting up before trying
to think a little more about this..

On Fri, 2010-04-16 at 22:58 +0800, Changli Gao wrote:

> >
> > cpu   Total     |rps_recv |rps_ipi
> > -----+----------+---------+---------
> > cpu0 | 002dc7f1 |00000000 |000f4246
> > cpu1 | 002dc804 |000f4240 |00000000
> > -------------------------------------
> >
> > So: cpu0 receive 0x2dc7f1 pkts accummulative over time and
> > redirected to cpu1 (mostly, the extra 5 maybe to leftover since i clear
> > the data) and for the test 0xf4246 times it generated an IPI. It can be
> > seen that total running for CPU1 is 0x2dc804 but in this one run it
> > received 1M packets (0xf4240).
> 
> I remeber you redirected all the traffic from cpu0 to cpu1, and the data shows:
> 
> about 0x2dc7f1 packets are processed, and about 0xf4240 IPI are generated.

If you look at the patch, I am zeroing those stats - so 0xf4240 is only
one test (decimal 1M). I think there is something to what you are
saying; rps_ipi on cpu0 is ambigous because it counts the number of
times cpu0 softirq was scheduled as well as the number of times cpu0
scheduled other cpus. 
The extra six for cpu0 turn out to be the times an ethernet interrupt
scheduled the cpu0 softirq.

> a single packet is counted twice by CPU0 and CPU1. 

Well, the counts have different meanings; rps_ipi applies to source cpu
activity and rps_recv applies to destination. Example, if cpu0 in total
6 times found some destination cpu to be empty and 2 of those happen to
be on cpu1, cpu2, cpu3 then
cpu0: ipi_rps = 6
cpu1: rps_recv = 2
cpu2: rps_recv = 2
cpu3: rps_recv = 2


> If you change RPS setting by:
> 
> echo 1 > ..../rps_cpus
> 
> you will find the total number are doubled.

This is true. But IMO deserving and should be double counted.
It is just more fine-grained accounting.
IOW, I am not sure we need your patch because we will loose the
fine-grain accounting - and mine requires more work to be less ambigous.

cheers,
jamal 

