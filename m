From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] e100 rx: or s and el bits
Date: Fri, 04 May 2007 17:43:34 -0400
Message-ID: <463BA906.30205@roinet.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@pobox.com>, Jeff Garzik <jeff@garzik.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>
To: Milton Miller <miltonm@bga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:59197
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031713AbXEDVmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 17:42:20 -0400
In-Reply-To: <4638F2B2.2000103@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Acker wrote:
> So far my testing has shown both the original and the new version of the 
> S-bit patch work in that no corruption seemed to occur over long term 
> runs.

I spoke too soon.  Further testing has not gone well.  If I use the 
default settings for CPU saver and drop the receive pool down to 16 
buffers I can cause problems with various forms of the patch.  With the 
original S-bit patch I can get:
e100: eth0: e100_update_stats: exec cuc_dump_reset failed

At this point sends and receives are failing and their counters are not
changing.  When a raw socket opened on the port tries to send it gets
errno 11, Resource temporarily unavailable.

When this error occurred, I added a reset call through the tx timeout
schedule_work(&nic->tx_timeout_task);

This made the port come back but obviously this is somewhat of a kludge 
and eventually, the entire system hangs or get an oops from memory 
corruption.

Apparently my earlier tests got lucky with a large receive pool size.
The only way the original patch was stable for me was by disabling CPU
saver, and setting the NAPI weight (default of 16) as large as the
default receive pool size (256) so that all buffers were claimed and
reallocated in one NAPI call.  None of this should be needed so there is 
  definitely a problem with the original patch.

The updated patch produced a different issue.  We got an RNR interrupt
indicating the receive unit got ahead of the software.  The S-bit patch
removed any handling of this issue as it assumed the hardware would spin
on the sbit.  Apparently if both the S-bit and the EL-bit are set on the 
same RFD, it follows the EL-bit handling.  Printing the stat/ack and 
status bytes on the RNR interrupts I get:
status
01001000 = 0x48 = RUS of 0010 = No Resources, CUS of 01 = Suspended

stat/ack
01010000 = 0x50 = FR, RNR
or
00010000 = 0x10 = RNR

Notice that the RUS went into No Resources and not suspended.  Thus 
clearing the S-bit does not wake it up; it needs a new start command. 
I could not find documentation that states that the S-bit need only be 
cleared to take the RU out of suspended state.  Before the S-bit patch 
the driver tried to track this need but that version of the driver 
didn't work for me either.  By the way, I am using, "Intel 8255x 10/100 
Mbps Ethernet Controller Family, Open Source Software Developer Manual, 
January 2006" as my documentation.

This got me looking at just how in the world this worked on the old
eepro100 driver.  It had another difference; it did not reap the last rx
buffer in the chain.  It set a postponed bit and then picked it up on
the next interrupt after more buffers had been allocated.  It then
noticed that the RU was in a suspended or no resources state and did a
softreset.

I don't believe this avoid the last buffer trick really fixes the race. 
  Imagine the following:
1. 4 buffers in receive pool, all freshly allocated
2. Hardware consumes 3 buffers
3. Software processes 3 buffers, begins to allocate new buffers
4. Hardware writes status bits into buffer 4 while software updates link 
and command word bits in buffer 4.  They share a cache line and corrupt 
each other.

This appears to be possible with any of the versions of this driver I 
have seen.  The problem is one of packet ownership.  Once the driver 
gives a list of buffers to hardware, hardware owns them all.  The driver 
can not safely change these buffers.  Sadly, this means that the idea of 
the driver "staying ahead" of the hardware such that the hardware never 
runs out of resources will not work here.  Once the driver gives the 
hardware a packet with S or EL bits set, it must let the hardware 
encounter the packet and return it to software.

I think the driver needs to protect the last entry in the ring by 
putting the S-bit on the entry before it.  The first time the driver 
allocates a block of packets, it writes a new S-bit out on the next to 
last packet.  As buffers complete it allocates more packets in the chain 
but does not set a new S-bit since the old one will stop hardware.  It 
can not clear the old S-bit because the driver does not own the buffer, 
hardware does.  After processing the s-bit packet the hardware will 
interrupt with a stat/ack of RNR and RUS of suspended.
When software processes a packet with an old S-bit it allocates new 
buffers and sets the s-bit on the new next to last packet.

The above case changes now:
1. 4 buffers numbered 1-4 in a receive pool, all freshly allocated. 
S-bit is on buffer 3.
2. Hardware consumes 3 buffers, hits S-bit, RNR interrupts
3. Software processes 3 buffers, begins to allocate new buffers
4. Software sends resume once buffers are allocated, S-bit is on buffer 2.
5. Hardware gets resume.  When it processed buffer 3, it saved the link 
to buffer 4 and thus resumes at buffer 4.


Here is a different flow where the software stays ahead:
1. 4 buffers numbered 1-4 in a receive pool, all freshly allocated. 
S-bit is on buffer 3.
2. Hardware consumes 2 buffers (1, 2).
3. Software processes buffers 1, 2, begins to allocate new buffers
4. Software buffers 1, 2 are allocated
5. Hardware consumes 1 buffer (#3) and hits S-bit, RNR interrupts.
6. Software consumes 1 buffer, (#3) and finds the old S-bit.  It 
allocates a new buffer 3 and sets the S-bit on buffer 2.
7. Software sends resume, hardware continues at buffer 4.

In this setup, software will send a resume command every RING_SIZE 
packets.  RNR interrupts will also occur every RING_SIZE packets.  When 
hardware is faster than software, it will process RING_SIZE packets, RNR 
interrupt and wait for software to process all of them.  When software 
is faster then hardware, hardware will still process RING_SIZE packets 
before interrupting but software will only need to allocate 1 packet or 
so before sending the resume so hardware will wait much less time.

This will probably slow things down since on a fast CPU, software will 
normally stay ahead of the hardware and the only PCI operations from the 
driver would be interrupt acks.  With this change, we have PCI 
operations every 256 packets.  I don't see how else to do this in a safe 
way on ARM (at least PXA255).

I am testing this over the weekend with a 16-buffer receive pool.  If 
all goes well, I will send a patch early next week.  It will basically 
back out the S-bit patch and then make the changes noted above.

-Ack
