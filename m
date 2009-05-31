From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: tulip_rxtx_stop() on Cobalt Qube2
Date: Sat, 30 May 2009 19:40:36 -0600
Message-ID: <20090531014036.GA23050@lackof.org>
References: <200905011238.59345.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org, kyle@mcmartin.ca
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:58352 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079AbZEaBkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 21:40:35 -0400
Content-Disposition: inline
In-Reply-To: <200905011238.59345.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46lorian,
Summary: proposed patch below for you to test (I've not tested it yet)
and some explanation on what I think is happening.


On Fri, May 01, 2009 at 12:38:57PM +0200, Florian Fainelli wrote:
=2E..
> Linux Tulip driver version 1.1.15-NAPI (Feb 27, 2007)
=2E..
> PCI: Enabling device 0000:00:0c.0 (0005 -> 0007)
> tulip1: Old format EEPROM on 'Cobalt Microserver' board.  Using subst=
itute=20
> media control info.
> tulip1:  EEPROM default media type Autosense.
> tulip1:  Index #0 - Media MII (#11) described by a 21142 MII PHY (3) =
block.
> tulip1:  MII transceiver #1 config 1000 status 7809 advertising 01e1.
> eth1: Digital DS21142/43 Tulip rev 65 at MMIO 0x12082400, 00:10:e0:00=
:88:b9,=20
> IRQ 20.
> [snip]
> 0000:00:07.0: tulip_stop_rxtx() failed (CSR5 0xf0660000 CSR6 0xb20e22=
02)

Looking up these bits in the publicly available manual:
    ftp://download.intel.com/design/network/manuals/27807401.pdf

"Rev 65" =3D=3D 0x41 =3D=3D 21143-PD or 21143-TD (page 3-7)

Operation Mode Register (CSR6=C2=ADOffset 30H)
----
bit : Val
31  : 1 Special Capture Effect Enable
30  : 1 Receive All
13  : 1 ST - Start Transmission
9   : 1 Full Duplex
1   : 1 SR - Start Receive

Status Register (CSR5=C2=ADOffset 28H)
----
28-31 : reserved
23-25 : 0x6 TX State =3D Suspended--Transmit FIFO underflow, or an unav=
ailable transmit descriptor
20-22 : 0x3 RX State =3D Running--Waiting for receive packet
1     : 0x0 TX isn't stopped
0     : 0x0 No TX Interrupt pending

The RX/TX engines are in a wedged state to begin with. :(

The normal calling path here is tulip_init() to register the driver
callbacks and tulip_init_one() gets called immediately by pci subsystem=
=2E
tulip_up() gets called after netdev registration when someone ifconfig'=
s
the device (ifconfig up). I don't know when else tulip_up() is called.

I have two ideas on how to fix this:
1) reset the RX/TX engines in tulip_init_one() before tulip_stop_rxtx()=
=2E
2) reset the RX/TX engines in tulip_stop_rxtx() if they are "wedged".
3) remove tulip_stop_rxtx() call in tulip_init_one()


(1) seems like a reasonable thing to do at init time anyway.
(2) feels like a pretty big hammer and I don't know all the side effect=
s.
(3) tulip_up() will reset the RX/TX engine and call tulip_stop_rxtx()
   when the NIC is opene/ifconfig'd. Calling pci_set_master()
   will allow the device to scribble into Host Memory...probably
   should move that call to tulip_up() as well. But I don't see anythin=
g
   in tulip_init_one() that requires DMA (and thus pci_set_master()).

Is there any reason for NOT implementing (1) and (3)?

I still need to work out where to call pci_set_master() in
tulip_up(). If that's feasible,

hrm. WTF. tulip_stop_rxtx() is called again from tulip_up() right befor=
e
CSR6 is written. Earlier in tulip_up() we reset the chip.  Removed.

Can you test the patch below?

I have not tested or even compiled this patch...will do so on parisc/ia=
64
machines once I get some feedback on this patch.

And I just noticed pci_clear_master() is not called *anywhere*. :(
Need to add such a call after tulip_stop_rxtx() some place (many places=
?).
This patch is just RFC and not suitable for merging upstream.

many thanks,
grant


diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_c=
ore.c
index 2abb5d3..1aa058e 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -470,11 +470,12 @@ media_picked:
 		tulip_select_media(dev, 1);
=20
 	/* Start the chip's Tx to process setup frame. */
-	tulip_stop_rxtx(tp);
 	barrier();
 	udelay(5);
 	iowrite32(tp->csr6 | TxOn, ioaddr + CSR6);
=20
+	pci_set_master(pdev);	/* enabled DMA */
+
 	/* Enable interrupts by setting the interrupt mask. */
 	iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ioaddr + CSR5);
 	iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ioaddr + CSR7);
@@ -1422,11 +1423,6 @@ static int __devinit tulip_init_one (struct pci_=
dev *pdev,
 		tulip_mwi_config (pdev, dev);
 #endif
=20
-	/* Stop the chip's Tx and Rx processes. */
-	tulip_stop_rxtx(tp);
-
-	pci_set_master(pdev);
-
 #ifdef CONFIG_GSC
 	if (pdev->subsystem_vendor =3D=3D PCI_VENDOR_ID_HP) {
 		switch (pdev->subsystem_device) {
