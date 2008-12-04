From: Michael Brown <mbrown@fensystems.co.uk>
Subject: Re: Realtek 8169 problems with net booting
Date: Thu, 4 Dec 2008 20:45:00 +0000
Message-ID: <200812042045.00773.mbrown@fensystems.co.uk>
References: <20081124181456.66a967d2@lxorguk.ukuu.org.uk> <200812041722.26935.mbrown@fensystems.co.uk> <20081204.101503.154423248.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprocket.fensystems.co.uk ([212.13.204.53]:33181 "EHLO
	sprocket.fensystems.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851AbYLDUpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 15:45:17 -0500
In-Reply-To: <20081204.101503.154423248.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 04 December 2008 18:15:03 David Miller wrote:
> > The assumption that the chip is quiescent is invalid in the case of any
> > kind of boot from SAN (e.g. iSCSI, AoE) via the net device.  The
> > INT13-based bootloader has no way to signal to the boot firmware that it
> > is finished using the INT13 interface, so the card will always be left in
> > an active state.
>
> So there is no "close" method for the boot loader to call?
> Who designs this crud? :-(

I believe that would be IBM, circa 1980.  Pity they didn't consider the needs 
of iSCSI boot in a protected-mode OS.

For SAN boot, the network boot loader (e.g. gPXE) emulates a BIOS disk using 
INT 13, and the next-stage boot loader (e.g. lilo/grub) believes that it is 
operating a physical disk; it doesn't even know that there's a NIC involved 
that may need to be shut down.

> > In gPXE, we do what we can to ensure that the card is safe to use when
> > the OS loads; we edit the RX buffers, ISR, etc. out of the system memory
> > map prior to starting an iSCSI boot.  We don't, however, get a chance to
> > actually quiesce the chip before the OS driver loads up, so the OS driver
> > must be prepared to discover the chip in an active state.
>
> It's really unfortunate that things have been setup so poorly.
>
> So OK, we have to handle this.

Agreed.  From our point of view, we will guarantee that the card is left in a 
state that is "active but harmless"; if the OS never touches the card then 
nothing bad will happen.  The driver should, as its first action, reset 
everything except the chip's PCI core.  (Some chips have only the facility to 
reset everything including the PCI core; I've seen drivers that back up PCI 
config space prior to reset and restore it afterwards, which seems to work.)

Michael
