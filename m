From: Andrew Morton <akpm@digeo.com>
Subject: [Fwd: Info: NAPI performance at "low" loads]
Date: Tue, 17 Sep 2002 14:35:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D87A00B.F78DE643@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred typo'ed the email address...

-------- Original Message --------
Subject: Info: NAPI performance at "low" loads
Date: Tue, 17 Sep 2002 21:53:03 +0200
From: Manfred Spraul <manfred@colorfullife.com>
To: linux-netdev@oss.sgi.com, linux-kernel@vger.kernel.org

NAPI network drivers mask the rx interrupts in their interrupt handler,
and reenable them in dev->poll(). In the worst case, that happens for
every packet. I've tried to measure the overhead of that operation.

The cpu time needed to recieve 50k packets/sec:

without NAPI:	53.7 %
with NAPI:	59.9 %

50k packets/sec is the limit for NAPI, at higher packet rates the forced 
mitigation kicks in and every interrupt recieves more than one packet.

The cpu time was measured by busy-looping in user space, the numbers 
should be accurate to less than 1 %.
Summary: with my setup, the overhead is around 11 %.

Could someone try to reproduce my results?

Sender:
  # sendpkt <target ip> 1 <10..50, go get a good packet rate>

Receiver:
  $ loadtest

Please disable any interrupt  mitigation features of your nic, otherwise 
the mitigation will dramatically change the needed cpu time.
The sender sends ICMP echo reply packets, evenly spaced by 
"memset(,,n*512)" between the syscalls.
The cpu load was measured with a user space app that calls
"memset(,,16384)" in a tight loop, and reports the number of loops per
second.

I've used a patched tulip driver, the current NAPI driver contains a
loop that severely slows down the nic under such loads.

The patch and my test apps are at

http://www.q-ag.de/~manfred/loadtest

hardware setup:
	Duron 700, VIA KT 133
		no IO APIC, i.e. slow 8259 XT PIC.
	Accton tulip clone, ADMtek comet.
	crossover cable
	Sender: Celeron 1.13 GHz, rtl8139

--
	Manfred

