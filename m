From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Tue, 17 Nov 2015 12:26:05 +1030
Message-ID: <20151117015605.GI22941@marvin.atrad.com.au>
References: <20130309064647.GC4984@marvin.atrad.com.au>
 <20130311000216.GA31808@zoreil.com>
 <20130405001526.GC19253@marvin.atrad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:37505 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077AbbKQCL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 21:11:29 -0500
Content-Disposition: inline
In-Reply-To: <20130405001526.GC19253@marvin.atrad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

Back in March/April 2013 I instigated this thread in connection with what
appeared to be a regression in the r8169 driver.  To briefly recap, we have
external hardware which transfers data at moderate rates (150-300 Mbits/sec)
to a Linux system using UDP packets.  The transfer stream lasts for around
55 seconds and restarts after a 5 second wait.  During the 5 second wait,
various systems are reconfigured, again using UDP.  The reconfiguration
involves the sending of around 5 UDP packets with payloads less than 32
bytes.

Under the fault which was noticed by us when Linux 3.8 was tried, UDP
packets associated with the reconfiguration - never the high speed streaming
- seemed to be lost, or at least delayed for many seconds.

A git bisect had suggested that the errant behaviour was introduced with:

  Commit: da78dbff2e05630921c551dbbc70a4b7981a8fff
  Author: Francois Romieu <romieu@fr.zoreil.com>
  Date:   Thu Jan 26 14:18:23 2012 +0100
  r8169: remove work from irq handler.

Through a series of circumstances this problem was not resolved at the time.

Recently I have been looking at upgrading the kernel used by the system and
installed Linux 4.3 to see whether anything had changed in the years since. 
The short answer is that the reconfiguration still fails in much the same
way as it did before, although it seems to happen a lot more frequently now.
Of course that doesn't rule out the option that the original problem has
been fixed and a new one - with very similar symptoms - has developed.

Using tcpdump on the system with the r8169 card it appears that in the fault
condition, the outgoing UDP packet is sent at the correct time and the
targetted equipment sends the reply within microseconds.  However, tcpdump
only sees the response many seconds later - after we've timed out waiting
for a response.  At least sometimes the old response is delivered at the
time another outgoing UDP packet is sent.  I have not yet determined whether
this happens all the time.

The same software on the same hardware running under 2.6.35.11 does not
suffer from any such problems.

The card in use is a Netgear GA311.  Lspic identifies it as a Realtek
Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10).  The kernel is
32-bit.

It would be advantageous if we could upgrade this Linux system to a kernel
more recent than 2.6.35.11, but that will require a resolution to this
problem.  Since 2.6.35.11 works while current kernels do not, the only other
option is to stick with 2.6.35.11.  Is there anything we can do to try to
track down the problem?  I'm willing and able to run further tests on the
system as required.

Regards
  jonathan
