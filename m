From: Daniel Gryniewicz <dang@fprintf.net>
Subject: Re: [PATCH, RFT] bcm43xx: Busting the 1G limit
Date: Mon, 19 Jun 2006 19:06:15 -0400
Message-ID: <1150758375.8932.6.camel@athena.fprintf.net>
References: <200606171928.08155.mb@bu3sch.de>
	 <1150730630.9048.2.camel@athena.fprintf.net>
	 <200606192243.09039.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nemesis.fprintf.net ([66.134.112.218]:19460 "EHLO
	nemesis.fprintf.net") by vger.kernel.org with ESMTP id S964973AbWFSXGS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 19:06:18 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606192243.09039.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-06-19 at 22:43 +0200, Michael Buesch wrote:
> On Monday 19 June 2006 17:23, Daniel Gryniewicz wrote:
> > On Sat, 2006-06-17 at 19:28 +0200, Michael Buesch wrote:
> > > Hi,
> > > 
> > > This patch adds full 32-bit and 64-bit DMA support
> > > to the bcm43xx driver. Well, it _should_ do this. I can
> > > not test it, as I don't have a machine to trigger the 1G
> > > limit.
> > > The 1G limit should be exploitable on an AMD64 machine
> > > with more than 1G RAM.
> > > 
> > > Please test and report, if it works or not. In the
> > > case of "works not", please provide full dmesg log.
> > > 
> > > Note that I am not sure which cards actually support
> > > full 32-bit or even 64-bit mode. Older cards might still
> > > only support 30-bit DMA.
> > 
> > Hi.
> > 
> > I tried this on both 2.6.17-rc6 and on wireless-dev, and got pretty much
> > the same panic on both (modulo locking).  My box is a turion with 2 GB
> > of ram and a BCM4318.  Here's the panic from wireless-dev:
> > 
> > Unable to handle kernel NULL pointer dereference at 0000000000000020
> > RIP:
> > <ffffffff88104f24>{:bcm43xx:bcm43xx_dma_handle_xmitstatus+436}
> 
> I am still not absolutely sure where this oops comes from.
> Could you remove at least 1G of your RAM and retry?
> 

I took out 1G of RAM (2 1G sticks), and there was no more panic.  It
still didn't work (no output from iwlist scan), but also no panic.

dmesg output was:
Jun 19 18:00:54 athena bcm43xx: Radio turned on
Jun 19 18:00:54 athena bcm43xx: ASSERTION FAILED (radio_attenuation <
10) at:
drivers/net/wireless/bcm43xx/bcm43xx_phy.c:1485:bcm43xx_find_lopair()
Jun 19 18:00:54 athena bcm43xx: ASSERTION FAILED (radio_attenuation <
10) at:
drivers/net/wireless/bcm43xx/bcm43xx_phy.c:1485:bcm43xx_find_lopair()
Jun 19 18:00:54 athena bcm43xx: Chip initialized
Jun 19 18:00:54 athena bcm43xx: 32-bit DMA initialized
Jun 19 18:00:54 athena bcm43xx: 80211 cores initialized
Jun 19 18:00:54 athena bcm43xx: Keys cleared
Jun 19 18:00:54 athena SoftMAC: Associate: Scanning for networks first.
Jun 19 18:00:54 athena SoftMAC: Associate: failed to initiate scan. Is
device up?

followed by a bunch of:
Jun 19 18:01:15 athena SoftMAC: Start scanning with channel: 1
Jun 19 18:01:15 athena SoftMAC: Scanning 14 channels
Jun 19 18:01:15 athena SoftMAC: Scanning finished

followed by:
Jun 19 18:02:03 athena SoftMAC: Associate: Scanning for networks first.
Jun 19 18:02:03 athena SoftMAC: Start scanning with channel: 1
Jun 19 18:02:03 athena SoftMAC: Scanning 14 channels
Jun 19 18:02:03 athena bcm43xx: set security called
Jun 19 18:02:03 athena bcm43xx:    .level = 0
Jun 19 18:02:03 athena bcm43xx:    .enabled = 0
Jun 19 18:02:03 athena bcm43xx:    .encrypt = 0
Jun 19 18:02:03 athena SoftMAC: Scanning finished
Jun 19 18:02:03 athena SoftMAC: Associate: Scanning for networks first.
Jun 19 18:02:03 athena SoftMAC: Start scanning with channel: 1
Jun 19 18:02:03 athena SoftMAC: Scanning 14 channels
Jun 19 18:02:03 athena SoftMAC: Scanning finished
Jun 19 18:02:03 athena SoftMAC: Associate: Scanning for networks first.
Jun 19 18:02:03 athena SoftMAC: Start scanning with channel: 1
Jun 19 18:02:03 athena SoftMAC: Scanning 14 channels
Jun 19 18:02:04 athena SoftMAC: Scanning finished
Jun 19 18:02:04 athena SoftMAC: Unable to find matching network after
scan!

and finally:

Jun 19 18:02:44 athena bcm43xx: Radio turned off
Jun 19 18:02:44 athena bcm43xx: DMA-32 0x0200 (RX) max used slots: 0/64
Jun 19 18:02:44 athena bcm43xx: DMA-32 0x02A0 (TX) max used slots: 0/512
Jun 19 18:02:44 athena bcm43xx: DMA-32 0x0280 (TX) max used slots: 0/512
Jun 19 18:02:44 athena bcm43xx: DMA-32 0x0260 (TX) max used slots: 0/512
Jun 19 18:02:44 athena bcm43xx: DMA-32 0x0240 (TX) max used slots: 0/512
Jun 19 18:02:44 athena bcm43xx: DMA-32 0x0220 (TX) max used slots: 2/512
Jun 19 18:02:44 athena bcm43xx: DMA-32 0x0200 (TX) max used slots: 0/512

At that point, I remove the bcm43xx module, and switched over to my
prism54 card in order to get net access.

This was all on wireless-dev as of yesterday with the 1G limit patch
from this thread.

Let me know if there's anything I can try, I'd love to get this working
properly.

Daniel

