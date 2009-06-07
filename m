From: Florian Fainelli <florian@openwrt.org>
Subject: Re: tulip_rxtx_stop() on Cobalt Qube2
Date: Sun, 7 Jun 2009 20:27:00 +0200
Message-ID: <200906072027.00617.florian@openwrt.org>
References: <200905011238.59345.florian@openwrt.org> <200905312302.22608.florian@openwrt.org> <20090531234342.GD3291@lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kyle@mcmartin.ca
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:56658 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289AbZFGS1B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 14:27:01 -0400
Received: by fg-out-1718.google.com with SMTP id d23so626494fga.17
        for <netdev@vger.kernel.org>; Sun, 07 Jun 2009 11:27:02 -0700 (PDT)
In-Reply-To: <20090531234342.GD3291@lackof.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Monday 01 June 2009 01:43:42 Grant Grundler, vous avez =E9crit=A0:
> On Sun, May 31, 2009 at 11:02:22PM +0200, Florian Fainelli wrote:
> > Hi Grant,
>
> ...
>
> > > The RX/TX engines are in a wedged state to begin with. :(
> >
> > I suppose this is due to the Bootloader, either CoLo or the origina=
l
> > Cobalt microservers bootloader.
>
> Yeah - either bootloader or BIOS - whatever talked to the NIC most
> recently.
>
> ...
>
> > > I have not tested or even compiled this patch...will do so on
> > > parisc/ia64 machines once I get some feedback on this patch.
> > >
> > > And I just noticed pci_clear_master() is not called *anywhere*. :=
(
> > > Need to add such a call after tulip_stop_rxtx() some place (many
> > > places?). This patch is just RFC and not suitable for merging ups=
tream.
> >
> > The patch below does not help on my Qube2, I am still having the sa=
me
> > message appearing.
>
> Are you sure?

Yes I am see below.

>
> I thought I removed all calls to tulip_stop_rxtx() in the initializat=
ion
> code path and didn't think it would get called. Did I overlook one?
> Can you add "dump_stack()" to tulip_stop_rxtx() failure case?

Will do.

>
> Can you also modify the driver version to make sure you are using
> the correct/most recenly built module?

See below the patch that was applied:

--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -15,11 +15,11 @@

 #define DRV_NAME       "tulip"
 #ifdef CONFIG_TULIP_NAPI
-#define DRV_VERSION    "1.1.15-NAPI" /* Keep at least for test */
+#define DRV_VERSION    "1.1.16-NAPI" /* Keep at least for test */
 #else
-#define DRV_VERSION    "1.1.15"
+#define DRV_VERSION    "1.1.16"
 #endif
-#define DRV_RELDATE    "Feb 27, 2007"
+#define DRV_RELDATE    "Mar 03, 2009"


 #include <linux/module.h>
@@ -470,11 +470,12 @@ media_picked:
                tulip_select_media(dev, 1);

        /* Start the chip's Tx to process setup frame. */
-       tulip_stop_rxtx(tp);
        barrier();
        udelay(5);
        iowrite32(tp->csr6 | TxOn, ioaddr + CSR6);

+       pci_set_master(tp->pdev);/* enabled DMA */
+
        /* Enable interrupts by setting the interrupt mask. */
        iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ioaddr + CSR5);
        iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ioaddr + CSR7);
@@ -1421,12 +1422,6 @@ static int __devinit tulip_init_one (struct pci_=
dev *pdev,
        if (!force_csr0 && (tp->flags & HAS_PCI_MWI))
                tulip_mwi_config (pdev, dev);
 #endif
-
-       /* Stop the chip's Tx and Rx processes. */
-       tulip_stop_rxtx(tp);
-
-       pci_set_master(pdev);
-
 #ifdef CONFIG_GSC
        if (pdev->subsystem_vendor =3D=3D PCI_VENDOR_ID_HP) {
                switch (pdev->subsystem_device) {


>
> And the please post the dmesg output from the driver again (plus 10
> lines of output  before and after).

Here comes the dmesg:

Linux Tulip driver version 1.1.16-NAPI (Mar 03, 2009)
PCI: Enabling device 0000:00:07.0 (0045 -> 0047)
tulip0: Old format EEPROM on 'Cobalt Microserver' board.  Using substit=
ute media control info.
tulip0:  EEPROM default media type Autosense.
tulip0:  Index #0 - Media MII (#11) described by a 21142 MII PHY (3) bl=
ock.
tulip0:  MII transceiver #1 config 1000 status 7809 advertising 01e1.
eth0: Digital DS21142/43 Tulip rev 65 at MMIO 0x12082000, 00:10:e0:00:7=
d:1f, IRQ 19.
PCI: Enabling device 0000:00:0c.0 (0005 -> 0007)
tulip1: Old format EEPROM on 'Cobalt Microserver' board.  Using substit=
ute media control info.
tulip1:  EEPROM default media type Autosense.
tulip1:  Index #0 - Media MII (#11) described by a 21142 MII PHY (3) bl=
ock.
tulip1:  MII transceiver #1 config 1000 status 7809 advertising 01e1.
eth1: Digital DS21142/43 Tulip rev 65 at MMIO 0x12082400, 00:10:e0:00:8=
8:b9, IRQ 20.
[snip]
0000:00:07.0: tulip_stop_rxtx() failed (CSR5 0xf0660000 CSR6 0xb20e2202=
)
eth0: Setting full-duplex based on MII#1 link partner capability of 45e=
1.
NET: Registered protocol family 10
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
