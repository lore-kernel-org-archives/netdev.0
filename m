From: Levitsky Maxim <maximlevitsky@yahoo.com>
Subject: [PATCH] [005] dmfe : Add support for wake-on-lan
Date: Wed, 7 Feb 2007 10:35:26 -0800 (PST)
Message-ID: <242352.74083.qm@web38508.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tori@unhappy.mine.nu, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web38508.mail.mud.yahoo.com ([209.191.125.54]:41320 "HELO
	web38508.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1161418AbXBGSf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 13:35:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Maxim Levitsky <maximlevitsky@yahoo.com>
Subject: [PATCH] [NETDEV] [005] dmfe : Add support for wake-on-lan

Adds support for wake on lan feature

Signed-off-by: Maxim Levitsky <maximlevitsky@yahoo.com>

---

This board supports WOL on magic packet / link change / specific packet
This adds support for WOL on magic packet / link change

Note : WOL is enabled when you suspend system ether to disk or ram, and=
 is not enabled when you
turn system off


--- linux-2.6.20-mod/drivers/net/tulip/dmfe.c=A0=A0=A02007-02-07 18:53:=
19.000000000 +0200
+++ linux-2.6.20-test/drivers/net/tulip/dmfe.c=A0=A02007-02-07 18:55:44=
=2E000000000 +0200
@@ -122,6 +122,11 @@
=A0#define DM9801_NOISE_FLOOR 8
=A0#define DM9802_NOISE_FLOOR 5
=A0
+#define DMFE_WOL_LINKCHANGE=A0=A0=A0=A00x20000000
+#define DMFE_WOL_SAMPLEPACKET=A0=A00x10000000
+#define DMFE_WOL_MAGICPACKET=A0=A0=A00x08000000
+
+
=A0#define DMFE_10MHF =A0 =A0 =A00
=A0#define DMFE_100MHF =A0 =A0 1
=A0#define DMFE_10MFD =A0 =A0 =A04
@@ -242,6 +247,7 @@ struct dmfe_board_info {
=A0=A0=A0=A0=A0=A0=A0=A0u8 wait_reset;=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0/* Hardware failed, need to reset */
=A0=A0=A0=A0=A0=A0=A0=A0u8 dm910x_chk_mode;=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0/* Operating mode check */
=A0=A0=A0=A0=A0=A0=A0=A0u8 first_in_callback;=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0/* Flag to record state */
+=A0=A0=A0=A0=A0=A0=A0u8 wol_mode;=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0/* user WOL settings */
=A0=A0=A0=A0=A0=A0=A0=A0struct timer_list timer;
=A0
=A0=A0=A0=A0=A0=A0=A0=A0/* System defined statistic counter */
@@ -423,6 +429,7 @@ static int __devinit dmfe_init_one (stru
=A0=A0=A0=A0=A0=A0=A0=A0db->chip_id =3D ent->driver_data;
=A0=A0=A0=A0=A0=A0=A0=A0db->ioaddr =3D pci_resource_start(pdev, 0);
=A0=A0=A0=A0=A0=A0=A0=A0db->chip_revision =3D dev_rev;
+=A0=A0=A0=A0=A0=A0=A0db->wol_mode =3D 0;
=A0
=A0=A0=A0=A0=A0=A0=A0=A0db->pdev =3D pdev;
=A0
@@ -1054,7 +1061,11 @@ static void dmfe_set_filter_mode(struct=20
=A0=A0=A0=A0=A0=A0=A0=A0spin_unlock_irqrestore(&db->lock, flags);
=A0}
=A0
-static void netdev_get_drvinfo(struct net_device *dev,
+/*
+ * =A0=A0=A0=A0Ethtool interace=20
+ */
+
+static void dmfe_ethtool_get_drvinfo(struct net_device *dev,
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 =A0 =A0 =A0 struct ethtool_drvinfo *info)
=A0{
=A0=A0=A0=A0=A0=A0=A0=A0struct dmfe_board_info *np =3D netdev_priv(dev)=
;
@@ -1068,9 +1079,35 @@ static void netdev_get_drvinfo(struct ne
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
dev->base_addr, dev->irq);
=A0}
=A0
+static int dmfe_ethtool_set_wol(struct net_device *dev,=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0struct ethtool_wolinfo *wolinfo)
+{
+=A0=A0=A0=A0=A0=A0=A0struct dmfe_board_info *db =3D netdev_priv(dev);
+=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0if (wolinfo->wolopts & (WAKE_UCAST | WAKE_MCAST |=
 WAKE_BCAST |=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0 =A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0WAKE_ARP | WAKE_MAGICSECURE))
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0 return -EOPNOTSUPP;
+=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0db->wol_mode =3D wolinfo->wolopts;
+=A0=A0=A0=A0=A0=A0=A0return 0;
+}
+
+static void dmfe_ethtool_get_wol(struct net_device *dev,=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 struct ethtool_wolinfo *wolinfo)
+{
+=A0=A0=A0=A0=A0=A0=A0struct dmfe_board_info *db =3D netdev_priv(dev);
+=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0wolinfo->supported =3D WAKE_PHY | WAKE_MAGIC;
+=A0=A0=A0=A0=A0=A0=A0wolinfo->wolopts =3D db->wol_mode;
+=A0=A0=A0=A0=A0=A0=A0return;
+}
+
+
=A0static const struct ethtool_ops netdev_ethtool_ops =3D {
-=A0=A0=A0=A0=A0=A0=A0.get_drvinfo=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D=
 netdev_get_drvinfo,
+=A0=A0=A0=A0=A0=A0=A0.get_drvinfo=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D=
 dmfe_ethtool_get_drvinfo,
=A0=A0=A0=A0=A0=A0=A0=A0.get_link =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D ethto=
ol_op_get_link,
+=A0=A0=A0=A0=A0=A0=A0.set_wol=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=3D dmfe_ethtool_set_wol,
+=A0=A0=A0=A0=A0=A0=A0.get_wol=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=3D dmfe_ethtool_get_wol,
=A0};
=A0
=A0/*
@@ -2046,6 +2083,20 @@ static int dmfe_suspend(struct pci_dev *
=A0 =A0 =A0/* Fre RX buffers */
=A0 =A0 =A0dmfe_free_rxbuffer(db);
=A0
+ =A0 =A0/* Enable WOL */
+ =A0 =A0pci_read_config_dword(pci_dev, 0x40, &tmp);
+ =A0 =A0tmp &=3D ~(WAKE_PHY|WAKE_MAGIC);
+ =A0 =A0
+ =A0 =A0if (db->wol_mode & WAKE_PHY)
+=A0=A0=A0=A0=A0=A0=A0 =A0 =A0tmp |=3D DMFE_WOL_LINKCHANGE;
+ =A0 =A0if (db->wol_mode & WAKE_MAGIC)
+=A0=A0=A0=A0=A0=A0=A0 =A0 =A0tmp |=3D DMFE_WOL_MAGICPACKET;
+ =A0 =A0
+ =A0 =A0pci_write_config_dword(pci_dev, 0x40, tmp);
+ =A0 =A0
+ =A0 =A0pci_enable_wake(pci_dev, PCI_D3hot, 1);
+ =A0 =A0pci_enable_wake(pci_dev, PCI_D3cold, 1);
+ =A0 =A0
=A0 =A0 =A0/* Power down device*/
=A0 =A0 =A0pci_set_power_state(pci_dev , =A0pci_choose_state(pci_dev,st=
ate));
=A0 =A0 =A0pci_save_state(pci_dev);
@@ -2064,6 +2115,15 @@ static int dmfe_resume(struct pci_dev *p
=A0 =A0 =A0/* Re-initilize DM910X board */
=A0 =A0 =A0dmfe_init_dm910x(dev);
=A0 =A0 =A0 =A0 =A0
+ =A0 =A0/* Disable WOL */
+ =A0 =A0pci_read_config_dword(pci_dev, 0x40, &tmp);
+ =A0 =A0
+ =A0 =A0tmp &=3D (DMFE_WOL_LINKCHANGE | DMFE_WOL_MAGICPACKET);
+ =A0 =A0pci_write_config_dword(pci_dev, 0x40, tmp);
+ =A0 =A0
+ =A0 =A0pci_enable_wake(pci_dev, PCI_D3hot, 0);
+ =A0 =A0pci_enable_wake(pci_dev, PCI_D3cold, 0);
+ =A0 =A0
=A0 =A0 =A0/* Restart upper layer interface */
=A0 =A0 =A0netif_device_attach(dev);


=20
_______________________________________________________________________=
_____________
=46ood fight? Enjoy some healthy debate=20
in the Yahoo! Answers Food & Drink Q&A.
http://answers.yahoo.com/dir/?link=3Dlist&sid=3D396545367
