From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bug#645589: linux-image-3.0.0-2-amd64: sky2 rx errors on 3.0,
 2.6.32 works
Date: Tue, 18 Oct 2011 11:13:08 -0700
Message-ID: <20111018111308.2c5a6580@nehalam.linuxnetplumber.net>
References: <20111017074016.6840.77265.reportbug@thor.viidakko.fi>
	<1318909386.3340.91.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: 645589@bugs.debian.org, Antti Salmela <asalmela@iki.fi>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53762 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750802Ab1JRSNM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Oct 2011 14:13:12 -0400
In-Reply-To: <1318909386.3340.91.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Oct 2011 04:43:06 +0100
Ben Hutchings <ben@decadent.org.uk> wrote:

> On Mon, 2011-10-17 at 10:40 +0300, Antti Salmela wrote:
> > Package: linux-2.6
> > Version: 3.0.0-5
> > Severity: normal
> > 
> > 
> > sky2 loses packets on 3.0 (-3 and -5) and 3.1-rc7, 2.6.32-38 and
> > setting interface to promiscuous works.
> > 
> > [   60.118244] sky2 0000:02:00.0: eth0: rx error, status 0xb92100 length 185
> > [   62.664370] sky2 0000:02:00.0: eth0: rx error, status 0x602100 length 96
> > [   63.370051] sky2 0000:02:00.0: eth0: rx error, status 0x422100 length 66
> > [   63.714672] sky2 0000:02:00.0: eth0: rx error, status 0x722100 length 114
> > [   64.513458] device eth0 entered promiscuous mode
> 
> It looks like this is a bug in accounting of VLAN tags, though I don't
> see what difference promiscuous mode should make.
> 
> The log messages show that status has the VLAN flag (bit 13) set and the
> length field (bits 16:28) equals the length passed into sky2_receive(),
> but that function expects the length field to be greater by VLAN_HLEN.
> 
> This device is:
> 
> [...]
> > 02:00.0 Ethernet controller [0200]: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit Ethernet Controller [11ab:4362] (rev 19)
> > 	Subsystem: ASUSTeK Computer Inc. Marvell 88E8053 Gigabit Ethernet controller PCIe (Asus) [1043:8142]
> > 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> > 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > 	Latency: 0, Cache Line Size: 16 bytes
> > 	Interrupt: pin A routed to IRQ 43
> > 	Region 0: Memory at cdefc000 (64-bit, non-prefetchable) [size=16K]
> > 	Region 2: I/O ports at c800 [size=256]
> > 	Expansion ROM at cdec0000 [disabled] [size=128K]
> > 	Capabilities: <access denied>
> > 	Kernel driver in use: sky2
> [...]

The accounting is supposed to be:
   MAC = total length of packet (including vlan)
   DMA = bytes dma'd to buffer (does not include vlan)
Looks like the code is incorrect for the case where hardware
VLAN stripping is disabled.  What happens is that status bit
still has the VLAN flag, but DMA engine leaves the VLAN tag
in the DMA buffer so the check fails.

Proper accounting would involve more state machine mechanics
about whether VLAN tag has already been seen in current receive
status ring.

For now probably best to do something like:

--- net-next.orig/drivers/net/ethernet/marvell/sky2.c	2011-10-18 11:09:04.108683763 -0700
+++ net-next/drivers/net/ethernet/marvell/sky2.c	2011-10-18 11:09:53.661264323 -0700
@@ -2543,7 +2543,8 @@ static struct sk_buff *sky2_receive(stru
 	struct sk_buff *skb = NULL;
 	u16 count = (status & GMR_FS_LEN) >> 16;
 
-	if (status & GMR_FS_VLAN)
+	if ((dev->features & NETIF_F_HW_VLAN_RX) &&
+	    (status & GMR_FS_VLAN))
 		count -= VLAN_HLEN;	/* Account for vlan tag */
 
 	netif_printk(sky2, rx_status, KERN_DEBUG, dev,
