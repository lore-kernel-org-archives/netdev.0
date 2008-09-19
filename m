From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] regression fixes for .27-rc
Date: Thu, 18 Sep 2008 21:52:09 -0400
Message-ID: <20080919015209.GA21268@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:54209 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755581AbYISBwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 21:52:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is all the net driver-related regressions AFAICS.

Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/net/e100.c           |    4 +---
 drivers/net/e1000/e1000_hw.c |   23 +++++++++++++++++++++++
 drivers/net/forcedeth.c      |   16 +++++++++++++---
 3 files changed, 37 insertions(+), 6 deletions(-)

Christopher Li (1):
      e1000: prevent corruption of EEPROM/NVM

Rafael J. Wysocki (1):
      e100: Use pci_pme_active to clear PME_Status and disable PME#

Yinghai Lu (1):
      forcedeth: call restore mac addr in nv_shutdown path

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 453115a..5cf78d6 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2738,9 +2738,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 		nic->flags |= wol_magic;
 
 	/* ack any pending wake events, disable PME */
-	err = pci_enable_wake(pdev, 0, 0);
-	if (err)
-		DPRINTK(PROBE, ERR, "Error clearing wake event\n");
+	pci_pme_active(pdev, false);
 
 	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 9d6edf3..d04eef5 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -144,6 +144,8 @@ static s32 e1000_host_if_read_cookie(struct e1000_hw *hw, u8 *buffer);
 static u8 e1000_calculate_mng_checksum(char *buffer, u32 length);
 static s32 e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex);
 static s32 e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
+static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+static s32 e1000_do_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 
 /* IGP cable length table */
 static const
@@ -168,6 +170,8 @@ u16 e1000_igp_2_cable_length_table[IGP02E1000_AGC_LENGTH_TABLE_SIZE] =
       83, 89, 95, 100, 105, 109, 113, 116, 119, 122, 124,
       104, 109, 114, 118, 121, 124};
 
+static DEFINE_SPINLOCK(e1000_eeprom_lock);
+
 /******************************************************************************
  * Set the phy type member in the hw struct.
  *
@@ -4904,6 +4908,15 @@ static s32 e1000_spi_eeprom_ready(struct e1000_hw *hw)
  *****************************************************************************/
 s32 e1000_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
+    s32 ret;
+    spin_lock(&e1000_eeprom_lock);
+    ret = e1000_do_read_eeprom(hw, offset, words, data);
+    spin_unlock(&e1000_eeprom_lock);
+    return ret;
+}
+
+static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+{
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     u32 i = 0;
 
@@ -5236,6 +5249,16 @@ s32 e1000_update_eeprom_checksum(struct e1000_hw *hw)
  *****************************************************************************/
 s32 e1000_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
+    s32 ret;
+    spin_lock(&e1000_eeprom_lock);
+    ret = e1000_do_write_eeprom(hw, offset, words, data);
+    spin_unlock(&e1000_eeprom_lock);
+    return ret;
+}
+
+
+static s32 e1000_do_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+{
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     s32 status = 0;
 
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0b6ecef..eeb55ed 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5643,6 +5643,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		dev->dev_addr[4] = (np->orig_mac[0] >>  8) & 0xff;
 		dev->dev_addr[5] = (np->orig_mac[0] >>  0) & 0xff;
 		writel(txreg|NVREG_TRANSMITPOLL_MAC_ADDR_REV, base + NvRegTransmitPoll);
+		printk(KERN_DEBUG "nv_probe: set workaround bit for reversed mac addr\n");
 	}
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
@@ -5890,14 +5891,12 @@ static void nv_restore_phy(struct net_device *dev)
 	}
 }
 
-static void __devexit nv_remove(struct pci_dev *pci_dev)
+static void nv_restore_mac_addr(struct pci_dev *pci_dev)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
-	unregister_netdev(dev);
-
 	/* special op: write back the misordered MAC address - otherwise
 	 * the next nv_probe would see a wrong address.
 	 */
@@ -5905,6 +5904,15 @@ static void __devexit nv_remove(struct pci_dev *pci_dev)
 	writel(np->orig_mac[1], base + NvRegMacAddrB);
 	writel(readl(base + NvRegTransmitPoll) & ~NVREG_TRANSMITPOLL_MAC_ADDR_REV,
 	       base + NvRegTransmitPoll);
+}
+
+static void __devexit nv_remove(struct pci_dev *pci_dev)
+{
+	struct net_device *dev = pci_get_drvdata(pci_dev);
+
+	unregister_netdev(dev);
+
+	nv_restore_mac_addr(pci_dev);
 
 	/* restore any phy related changes */
 	nv_restore_phy(dev);
@@ -5975,6 +5983,8 @@ static void nv_shutdown(struct pci_dev *pdev)
 	if (netif_running(dev))
 		nv_close(dev);
 
+	nv_restore_mac_addr(pdev);
+
 	pci_disable_device(pdev);
 	if (system_state == SYSTEM_POWER_OFF) {
 		if (pci_enable_wake(pdev, PCI_D3cold, np->wolenabled))
