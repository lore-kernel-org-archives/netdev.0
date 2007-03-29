From: David Acker <dacker@roinet.com>
Subject: Re: [RFT] e100 driver on ARM
Date: Thu, 29 Mar 2007 01:17:38 -0400
Message-ID: <460B4BF2.1070803@roinet.com>
References: <44FC0261.6010807@garzik.org> <20060904123123.GB1285@xi.wantstofly.org> <460AF480.7050609@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Jeff Garzik <jeff@garzik.org>,
	Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Russell King <rmk+lkml@arm.linux.org.uk>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:46486
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184AbXC2FXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 01:23:54 -0400
In-Reply-To: <460AF480.7050609@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Lennert Buytenhek wrote:
>> On Mon, Sep 04, 2006 at 06:39:29AM -0400, Jeff Garzik wrote:
>>
>>> 1) Does e100 driver work on ARM?
>>
>> FWIW, e100 seems to work okay for me on an intel ixp2400 (xscale based)
>> board, an ixp2850 (xscale based) board and an ixp2350 (xscale3 based)
>> board.  ixp2350 works both with hardware coherency turned on (cpu
>> snoops bus) and turned off (manual dma cache clean/invalidate as usual.)
>>
>> As for the other ARM platforms that I'm interested in / have hardware
>> for / maintain, the at91/ep93xx/pxa270 don't have PCI, and the other
>> two (iop32x/iop33x) I can't test because I don't have such systems with
>> e100 NICs, but I expect those would work, since they're both xscale
>> based like the ixp2400, and the ixp2400 works.
> 
> I just got an iop342 board dropped on my lap. Once it's running, I'll 
> make sure to make this the first thing to test.
> 

I have a pxa255 based system with PCI added to it.  The e100 would have 
memory corruption in its receive buffers detected by slab debugging 
unless I put in the patch to use the S-bit.

Here is a link to the patch posting:
http://kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.20-rc3/2.6.20-rc3-mm1/broken-out/git-netdev-all.patch
Search for e100.c.

http://www-gatago.com/linux/kernel/15457063.html - This discussion seems 
to hit the issue.

There appears to be a race on the cache line where the EL bit and the 
next packet info live. In my case the hardware appeared to write to a 
free packet.  The S-bit seems to make the hardware stop and spin on the 
bit, while the EL bit seems to let the hardware try to use that packet.

This race would occur less often when the receive buffer chain is always 
refilled before the hardware can use them up.  On our 400 Mhz Xscale, we 
can use up all 256 buffers if the PCI bus has another busy device on it. 
  In our case it is an 802.11g miniPCI card and our software was routing 
all ethernet packets to the wireless interface and vice versa while TCP 
streams were running accross these connections.
-Ack
