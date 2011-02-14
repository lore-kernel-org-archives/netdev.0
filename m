From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 1/9] jme: Extract main and sub chip revision
Date: Mon, 14 Feb 2011 12:27:34 +0800
Message-ID: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:48716 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755068Ab1BNE2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 23:28:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Get the main and sub chip revision for later workaround use.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |    8 +++++---
 drivers/net/jme.h |    8 +++++---
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index e97ebef..d44716e 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2731,6 +2731,8 @@ jme_check_hw_ver(struct jme_adapter *jme)
 
 	jme->fpgaver = (chipmode & CM_FPGAVER_MASK) >> CM_FPGAVER_SHIFT;
 	jme->chiprev = (chipmode & CM_CHIPREV_MASK) >> CM_CHIPREV_SHIFT;
+	jme->chip_main_rev = jme->chiprev & 0xF;
+	jme->chip_sub_rev = (jme->chiprev >> 4) & 0xF;
 }
 
 static const struct net_device_ops jme_netdev_ops = {
@@ -2937,7 +2939,7 @@ jme_init_one(struct pci_dev *pdev,
 
 	jme_clear_pm(jme);
 	jme_set_phyfifoa(jme);
-	pci_read_config_byte(pdev, PCI_REVISION_ID, &jme->rev);
+	pci_read_config_byte(pdev, PCI_REVISION_ID, &jme->pcirev);
 	if (!jme->fpgaver)
 		jme_phy_init(jme);
 	jme_phy_off(jme);
@@ -2964,14 +2966,14 @@ jme_init_one(struct pci_dev *pdev,
 		goto err_out_unmap;
 	}
 
-	netif_info(jme, probe, jme->dev, "%s%s ver:%x rev:%x macaddr:%pM\n",
+	netif_info(jme, probe, jme->dev, "%s%s chiprev:%x pcirev:%x macaddr:%pM\n",
 		   (jme->pdev->device == PCI_DEVICE_ID_JMICRON_JMC250) ?
 		   "JMC250 Gigabit Ethernet" :
 		   (jme->pdev->device == PCI_DEVICE_ID_JMICRON_JMC260) ?
 		   "JMC260 Fast Ethernet" : "Unknown",
 		   (jme->fpgaver != 0) ? " (FPGA)" : "",
 		   (jme->fpgaver != 0) ? jme->fpgaver : jme->chiprev,
-		   jme->rev, netdev->dev_addr);
+		   jme->pcirev, netdev->dev_addr);
 
 	return 0;
 
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index eac0926..32b2a9d 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -411,8 +411,10 @@ struct jme_adapter {
 	u32			rx_ring_mask;
 	u8			mrrs;
 	unsigned int		fpgaver;
-	unsigned int		chiprev;
-	u8			rev;
+	u8			chiprev;
+	u8			chip_main_rev;
+	u8			chip_sub_rev;
+	u8			pcirev;
 	u32			msg_enable;
 	struct ethtool_cmd	old_ecmd;
 	unsigned int		old_mtu;
@@ -1184,7 +1186,7 @@ enum jme_phy_reg17_vals {
 /*
  * Workaround
  */
-static inline int is_buggy250(unsigned short device, unsigned int chiprev)
+static inline int is_buggy250(unsigned short device, u8 chiprev)
 {
 	return device == PCI_DEVICE_ID_JMICRON_JMC250 && chiprev == 0x11;
 }
-- 
1.7.2.2

