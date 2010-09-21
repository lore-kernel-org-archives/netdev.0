From: arno@natisbad.org (Arnaud Ebalard)
Subject: [BUG,E1000E] first packets after device is reported up are silently dropped
Date: Tue, 21 Sep 2010 14:07:22 +0200
Message-ID: <87vd5z5mh1.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Brian Haley <brian.haley@hp.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Stefan Rompf <sux@loplof.de>,
	David Miller <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiew
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:56241 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752179Ab0IUMGt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Sep 2010 08:06:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When the link is reported up again (after plugging a cable) by the
driver (E1000E) the first packets sent immediately after that event
are sometimes *silently* dropped by the hardware.

Before describing the tests, here are some info on the hardware and
software. Don't hesitate to ask if you need more:
 
  Kernel: 2.6.35.4
 
  Hardware: Intel 82567LM (rev3) Gigagbit adapter on a DELL E4300
  Here is what ethtool reports for the driver:
   driver: e1000e
   version: 1.0.2-k4
   firmware-version: 1.7-7
   bus-info: 0000:00:19.0

  Switch: tested with a Cisco Catalyst 2960 (100Mbits/s), Planex
          FX08-Mini (100Mbit/s), PLanex 5 ports Gigabit
 
The setup is pretty simple: two different userland tools (umip and
netplug) monitor netlink NEWLINK events and respectively send an ICMPv6
Router Solicitation packet and an IPv4 DHCP request when they receive
the information the interface is UP and RUNNING:

00:21:70:bd:ef:fc > 33:33:00:00:00:02, ethertype IPv6 (0x86dd), length 62: :: > ff02::2: ICMP6, router solicitation, length 8
00:21:70:bd:ef:fc > ff:ff:ff:ff:ff:ff, ethertype IPv4 (0x0800), length 342: 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 

The idea is to have address autoconfiguration performed as soon as
possible. Because the reemission occurs only after a few seconds, the
net result is a long delay.

I noticed that sometimes the first few packets emitted by the tools are
not answered. I put a tcpdump on the other side. Nothing arrives. I even
checked the led on the switch. Does not blink.

I first thought adding a few ms of delay beteween the reception of the
NEWLINK and the emission of the packets. It seems the higher the better
but at *550ms* I still managed to have the initial packet dropped from
time to time.

I then spent time in the kernel (net/core/dev.c, net/sched/sch_generic.c
drivers/net/e1000e/netdev.c) following the first packet to see where it
gets dropped. I ended up in e1000_xmit_frame() in which everything seems
to be ok. AFAICT, the packet is delivered to the hardware and then
silently killed for some unknown reason.

I added various debug statements in the code (custom printk(),
calls to e1000e_dump()) to try and understand what can be different in
the driver's state when the first packet is deliver and when it is
not. Nothing interesting.

I am currently out of idea. Is this a known bug? What can be happening?
If you have patches you want me to test to get additional info, don't
hesitate!

Cheers,

a+
