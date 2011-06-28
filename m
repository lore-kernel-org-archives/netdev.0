From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6] jme: Cleanup PM operations after using new PM API
Date: Tue, 28 Jun 2011 19:38:30 +0800
Message-ID: <1309261110-11883-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:49549 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757167Ab1F1Lih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 07:38:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

	1. Using enum name instead of numeric value.
	2. device_set_wakeup_enable expect bool argument
	   adding !!() to the argument to be passed.
	3. Remove non-jme-hardware related operations from
	   jme_clear_pm()
	4. Reuse jme_clear_pm() in jme_resume() and jme_powersave_phy()

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |   23 +++++++++++------------
 drivers/net/jme.h |    2 ++
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 2ce9339..6b2a5e7 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -271,9 +271,7 @@ jme_reset_mac_processor(struct jme_adapter *jme)
 static inline void
 jme_clear_pm(struct jme_adapter *jme)
 {
-	jwrite32(jme, JME_PMCS, 0xFFFF0000 | jme->reg_pmcs);
-	pci_set_power_state(jme->pdev, PCI_D0);
-	device_set_wakeup_enable(&jme->pdev->dev, false);
+	jwrite32(jme, JME_PMCS, PMCS_STMASK | jme->reg_pmcs);
 }
 
 static int
@@ -1817,11 +1815,9 @@ jme_powersave_phy(struct jme_adapter *jme)
 {
 	if (jme->reg_pmcs) {
 		jme_set_100m_half(jme);
-
 		if (jme->reg_pmcs & (PMCS_LFEN | PMCS_LREN))
 			jme_wait_link(jme);
-
-		jwrite32(jme, JME_PMCS, jme->reg_pmcs);
+		jme_clear_pm(jme);
 	} else {
 		jme_phy_off(jme);
 	}
@@ -2529,8 +2525,7 @@ jme_set_wol(struct net_device *netdev,
 		jme->reg_pmcs |= PMCS_MFEN;
 
 	jwrite32(jme, JME_PMCS, jme->reg_pmcs);
-
-	device_set_wakeup_enable(&jme->pdev->dev, jme->reg_pmcs);
+	device_set_wakeup_enable(&jme->pdev->dev, !!(jme->reg_pmcs));
 
 	return 0;
 }
@@ -3058,6 +3053,9 @@ jme_init_one(struct pci_dev *pdev,
 	jme->mii_if.mdio_write = jme_mdio_write;
 
 	jme_clear_pm(jme);
+	pci_set_power_state(jme->pdev, PCI_D0);
+	device_set_wakeup_enable(&pdev->dev, true);
+
 	jme_set_phyfifo_5level(jme);
 	jme->pcirev = pdev->revision;
 	if (!jme->fpgaver)
@@ -3136,7 +3134,8 @@ jme_shutdown(struct pci_dev *pdev)
 }
 
 #ifdef CONFIG_PM_SLEEP
-static int jme_suspend(struct device *dev)
+static int
+jme_suspend(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -3175,14 +3174,14 @@ static int jme_suspend(struct device *dev)
 	return 0;
 }
 
-static int jme_resume(struct device *dev)
+static int
+jme_resume(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct jme_adapter *jme = netdev_priv(netdev);
 
-	jwrite32(jme, JME_PMCS, 0xFFFF0000 | jme->reg_pmcs);
-
+	jme_clear_pm(jme);
 	jme_phy_on(jme);
 	if (test_bit(JME_FLAG_SSET, &jme->flags))
 		jme_set_settings(netdev, &jme->old_ecmd);
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 0d5da06..1481a62 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -852,6 +852,7 @@ enum jme_ghc_txmac_clk {
  * Power management control and status register
  */
 enum jme_pmcs_bit_masks {
+	PMCS_STMASK	= 0xFFFF0000,
 	PMCS_WF7DET	= 0x80000000,
 	PMCS_WF6DET	= 0x40000000,
 	PMCS_WF5DET	= 0x20000000,
@@ -863,6 +864,7 @@ enum jme_pmcs_bit_masks {
 	PMCS_LFDET	= 0x00040000,
 	PMCS_LRDET	= 0x00020000,
 	PMCS_MFDET	= 0x00010000,
+	PMCS_ENMASK	= 0x0000FFFF,
 	PMCS_WF7EN	= 0x00008000,
 	PMCS_WF6EN	= 0x00004000,
 	PMCS_WF5EN	= 0x00002000,
-- 
1.7.3.4

