From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: question about softirqs
Date: Wed, 13 May 2009 16:54:44 +0200
Message-ID: <4A0ADF34.2040001@cosmosbay.com>
References: <18948.63755.279732.294842@cargo.ozlabs.ibm.com>	<20090508.234815.127227651.davem@davemloft.net>	<4A086DB2.8040703@nortel.com>	<20090511.162436.193717082.davem@davemloft.net>	<4A08C62F.1050105@nortel.com> <20090512081237.GA16403@elte.hu>	<4A09933B.8010606@nortel.com> <874ovpmmdq.fsf@basil.nowhere.org>	<4A0AC9EC.6070908@nortel.com>	<20090513141532.GT19296@one.firstfloor.org>	<alpine.LFD.2.00.0905131612180.3561@localhost.localdomain> <87my9hkrmw.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Chris Friesen <cfriesen@nortel.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	paulus@samba.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:37349 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760090AbZEMOzp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 10:55:45 -0400
In-Reply-To: <87my9hkrmw.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
> Thomas Gleixner <tglx@linutronix.de> writes:
>=20
>=20
>> Err, no. Chris is completely correct:
>>
>>         if (!in_interrupt())
>> 		wakeup_softirqd();
>=20
> Yes you have to wake it up just in case, but it doesn't normally
> process the data because a normal softirq comes in faster. It's
> just a safety policy.=20
>=20
> You can check this by checking the accumulated CPU time on your
> ksoftirqs.  Mine are all 0 even on long running systems.
>=20

Then its a bug Andi. Its quite easy to trigger ksoftirqd with a Gb ethe=
rnet link.

commit f5f293a4e3d0a0c52cec31de6762c95050156516 corrected something
(making mpstat and top correctly display softirq on cpu stats),
but apparently we still have a problem to report correct time on proces=
ses,
particularly on ksoftirq/x

I have one machine SMP flooded by network frames, CPU0 handling all
the work, inside ksoftirq/0 (napi processing : almost no more hard inte=
rrupts delivered)

Still, top or ps reports no more than 30% of cpu time used by
ksoftirqd, while this cpu only runs ksoftirqd/0 (100% in sirq), and has=
 no idle time.

$ps -fp 4 ; mpstat -P 0 1 10 ; ps -fp 4
UID        PID  PPID  C STIME TTY          TIME CMD
root         4     2  1 15:35 ?        00:00:46 [ksoftirqd/0]
Linux 2.6.30-rc5-tip-01595-g6f75dad-dirty (svivoipvnx001)       05/13/2=
009      _i686_

04:45:01 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %stea=
l  %guest   %idle
04:45:02 PM    0    0.00    0.00    0.00    0.00    0.00  100.00    0.0=
0    0.00    0.00
04:45:03 PM    0    0.00    0.00    0.00    0.00    0.00   99.01    0.0=
0    0.00    0.99
04:45:04 PM    0    0.00    0.00    0.00    0.00    0.00  100.00    0.0=
0    0.00    0.00
04:45:05 PM    0    0.00    0.00    0.00    0.00    0.00  100.00    0.0=
0    0.00    0.00
04:45:06 PM    0    0.00    0.00    0.00    0.00    0.00  100.00    0.0=
0    0.00    0.00
04:45:07 PM    0    0.00    0.00    0.00    0.00    0.00  100.00    0.0=
0    0.00    0.00
04:45:08 PM    0    0.00    0.00    0.00    0.00    0.00  100.00    0.0=
0    0.00    0.00
04:45:09 PM    0    0.00    0.00    0.00    0.00    0.00  100.00    0.0=
0    0.00    0.00
04:45:10 PM    0    0.00    0.00    0.00    0.00    0.00  100.00    0.0=
0    0.00    0.00
04:45:11 PM    0    0.00    0.00    0.00    0.00    0.00  100.00    0.0=
0    0.00    0.00
Average:       0    0.00    0.00    0.00    0.00    0.00   99.90    0.0=
0    0.00    0.10
UID        PID  PPID  C STIME TTY          TIME CMD
root         4     2  1 15:35 ?        00:00:49 [ksoftirqd/0]

You can see here time consumed by ksoftirqd/0 suring this 10 seconds ti=
me frame is *only* 3 seconds.

Therefore, we cannot trust ps, not with current kernel.

# cat /proc/4/stat ; sleep 10 ; cat /proc/4/stat
4 (ksoftirqd/0) R 2 0 0 0 -1 2216730688 0 0 0 0 0 15347 0 0 15 -5 1 0 6=
 0 0 4294967295 0 0 0 0 0 0 0 2147483647 0 0 0 0 17 0 0 0 0 0 0
4 (ksoftirqd/0) R 2 0 0 0 -1 2216730688 0 0 0 0 0 15670 0 0 15 -5 1 0 6=
 0 0 4294967295 0 0 0 0 0 0 0 2147483647 0 0 0 0 17 0 0 0 0 0 0


> The reason Andrea originally added the softirqds was just that
> if you have very softirq intensive workloads they would tie
> up too much CPU time or not make enough process with the default
> "don't loop too often" heuristics.=20
>=20
>> We can not rely on irqs coming in when the softirq is raised from
>=20
> You can't rely on it, but it happens in near all cases.
>=20
> -Andi


