From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH 1/2 net v3.16]r8169:  Not enable/disable bus mastering when is enabled on BIOS
Date: Sun, 13 Mar 2016 11:32:48 +0200
Message-ID: <1457861569-1844-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-231-86.residential.rdsnet.ro ([5.14.231.86]:44110 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932424AbcCMJwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 05:52:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 This patch not enable/disable bus mastering when is enabled on BIOS..
 pci_disable_device function also disable bus mastering for, disable bus mastering
  is dedicate function.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 29 ++++++++++++++++++++++++++---
 1 file changed, 26 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 02aec96..ec555e7 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -754,6 +754,7 @@ struct rtl8169_private {
 	struct timer_list timer;
 	u16 cp_cmd;
 	bool pcie;
+	bool bios_support;
 
 	u16 event_slow;
 
@@ -3718,13 +3719,27 @@ static void rtl8169_phy_timer(unsigned long __opaque)
 	rtl_schedule_task(tp, RTL_FLAG_TASK_PHY_PENDING);
 }
 
+static void rtl_disable_device (struct pci_dev *pdev)
+{
+	dev_WARN_ONCE(&pdev->dev, atomic_read(&pdev->enable_cnt) <= 0,
+		"disabling already-disabled device");
+
+	if (atomic_dec_return(&pdev->enable_cnt) != 0)
+		return;
+}
+
 static void rtl8169_release_board(struct pci_dev *pdev, struct net_device *dev,
 				  void __iomem *ioaddr)
 {
+	struct rtl8169_private *tp = netdev_priv(dev);
+
 	iounmap(ioaddr);
 	pci_release_regions(pdev);
 	pci_clear_mwi(pdev);
-	pci_disable_device(pdev);
+	if (!tp->bios_support)
+		pci_disable_device(pdev);
+	else
+		rtl_disable_device(pdev);
 	free_netdev(dev);
 }
 
@@ -6779,7 +6794,8 @@ static void rtl_wol_shutdown_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_11:
 	case RTL_GIGA_MAC_VER_12:
 	case RTL_GIGA_MAC_VER_17:
-		pci_clear_master(tp->pci_dev);
+		if (!tp->bios_support)
+			pci_clear_master(tp->pci_dev);
 
 		RTL_W8(ChipCmd, CmdRxEnb);
 		/* PCI commit */
@@ -6996,6 +7012,7 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	void __iomem *ioaddr;
 	int chipset, i;
 	int rc;
+	u16 cmd;
 
 	if (netif_msg_drv(&debug)) {
 		printk(KERN_INFO "%s Gigabit Ethernet driver %s loaded\n",
@@ -7103,7 +7120,13 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rtl_ack_events(tp, 0xffff);
 
-	pci_set_master(pdev);
+	pci_read_config_word(pdev, PCI_COMMAND, &cmd);
+	if (cmd & PCI_COMMAND_MASTER)
+		tp->bios_support = true;
+	else {
+		tp->bios_support = false;
+		pci_set_master(pdev);
+	}
 
 	/*
 	 * Pretend we are using VLANs; This bypasses a nasty bug where
-- 
2.1.4
