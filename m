From: Levitsky Maxim <maximlevitsky@yahoo.com>
Subject: [PATCH] [004] dmfe : Add suspend/resume support
Date: Wed, 7 Feb 2007 10:33:55 -0800 (PST)
Message-ID: <549393.8054.qm@web38506.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tori@unhappy.mine.nu, netdev@vger.kernel.org, pavel@suse.cz
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web38506.mail.mud.yahoo.com ([209.191.125.52]:20296 "HELO
	web38506.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1030651AbXBGSd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 13:33:56 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Maxim Levitsky <maximlevitsky@yahoo.com>
Subject: [PATCH] [NETDEV] [004] dmfe : Add suspend/resume support

Adds support for suspend/resume

---


--- linux-2.6.20-mod/drivers/net/tulip/dmfe.c=A0=A0=A02007-02-07 18:46:=
13.000000000 +0200
+++ linux-2.6.20-test/drivers/net/tulip/dmfe.c=A0=A02007-02-07 18:50:52=
=2E000000000 +0200
@@ -55,9 +55,6 @@
=A0
=A0 =A0 =A0TODO
=A0
- =A0 =A0Implement pci_driver::suspend() and pci_driver::resume()
- =A0 =A0power management methods.
-
=A0 =A0 =A0Check on 64 bit boxes.
=A0 =A0 =A0Check and fix on big endian boxes.
=A0
@@ -2027,11 +2024,59 @@ static struct pci_device_id dmfe_pci_tbl
=A0MODULE_DEVICE_TABLE(pci, dmfe_pci_tbl);
=A0
=A0
+
+static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
+{
+ =A0 =A0u32 tmp;
+
+ =A0 =A0struct net_device *dev =3D pci_get_drvdata(pci_dev);
+ =A0 =A0struct dmfe_board_info *db =3D netdev_priv(dev);
+ =A0 =A0
+ =A0 =A0/* Disable upper layer interface */
+ =A0 =A0netif_device_detach(dev);
+ =A0 =A0
+ =A0 =A0/* Disable Tx/Rx */
+ =A0 =A0db->cr6_data &=3D ~(CR6_RXSC | CR6_TXSC);=A0=A0=A0=A0
+ =A0 =A0update_cr6(db->cr6_data, dev->base_addr);
+ =A0 =A0
+ =A0 =A0/* Disable Interrupt */
+ =A0 =A0outl(0, dev->base_addr + DCR7);=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0
+ =A0 =A0outl(inl(dev->base_addr + DCR5), dev->base_addr + DCR5);
+ =A0 =A0
+ =A0 =A0/* Fre RX buffers */
+ =A0 =A0dmfe_free_rxbuffer(db);
+
+ =A0 =A0/* Power down device*/
+ =A0 =A0pci_set_power_state(pci_dev , =A0pci_choose_state(pci_dev,stat=
e));
+ =A0 =A0pci_save_state(pci_dev);
+
+ =A0 =A0return 0;
+}
+
+static int dmfe_resume(struct pci_dev *pci_dev)
+{
+ =A0 =A0struct net_device *dev =3D pci_get_drvdata(pci_dev);
+ =A0 =A0u32 tmp;
+
+ =A0 =A0pci_restore_state(pci_dev);
+ =A0 =A0pci_set_power_state(pci_dev ,PCI_D0);
+ =A0 =A0
+ =A0 =A0/* Re-initilize DM910X board */
+ =A0 =A0dmfe_init_dm910x(dev);
+ =A0 =A0 =A0 =A0
+ =A0 =A0/* Restart upper layer interface */
+ =A0 =A0netif_device_attach(dev);
+
+ =A0 =A0return 0;
+}
+
=A0static struct pci_driver dmfe_driver =3D {
=A0=A0=A0=A0=A0=A0=A0=A0.name=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D "dmfe=
",
=A0=A0=A0=A0=A0=A0=A0=A0.id_table=A0=A0=A0=A0=A0=A0=A0=3D dmfe_pci_tbl,
=A0=A0=A0=A0=A0=A0=A0=A0.probe=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D dmfe_in=
it_one,
=A0=A0=A0=A0=A0=A0=A0=A0.remove=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D __devexit=
_p(dmfe_remove_one),
+ =A0 =A0 =A0 =A0.suspend =A0 =A0 =A0 =A0=3D dmfe_suspend,
+ =A0 =A0 =A0 =A0.resume =A0 =A0 =A0 =A0 =3D dmfe_resume
=A0};
=A0
=A0MODULE_AUTHOR("Sten Wang, sten_wang@davicom.com.tw");



=20
_______________________________________________________________________=
_____________
Do you Yahoo!?
Everyone is raving about the all-new Yahoo! Mail beta.
http://new.mail.yahoo.com
