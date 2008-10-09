From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 3/8 2.6.28] cxgb3 - allow for PHY reset status
Date: Wed, 08 Oct 2008 17:34:08 -0700
Message-ID: <20081009003407.13347.1075.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:25936 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755955AbYJIAeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 20:34:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

First step towards overall PHY layering re-organization.
Allow a status return when a PHY is reset.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/ael1002.c |   20 ++++++++++++--------
 drivers/net/cxgb3/common.h  |   24 ++++++++++++------------
 drivers/net/cxgb3/t3_hw.c   |   15 ++++++++++-----
 drivers/net/cxgb3/vsc8211.c |    5 +++--
 4 files changed, 37 insertions(+), 27 deletions(-)

diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
index ee140e6..bf22e56 100644
--- a/drivers/net/cxgb3/ael1002.c
+++ b/drivers/net/cxgb3/ael1002.c
@@ -119,11 +119,12 @@ static struct cphy_ops ael1002_ops = {
 	.power_down = ael1002_power_down,
 };
 
-void t3_ael1002_phy_prep(struct cphy *phy, struct adapter *adapter,
-			 int phy_addr, const struct mdio_ops *mdio_ops)
+int t3_ael1002_phy_prep(struct cphy *phy, struct adapter *adapter,
+			int phy_addr, const struct mdio_ops *mdio_ops)
 {
 	cphy_init(phy, adapter, phy_addr, &ael1002_ops, mdio_ops);
 	ael100x_txon(phy);
+	return 0;
 }
 
 static int ael1006_reset(struct cphy *phy, int wait)
@@ -174,11 +175,12 @@ static struct cphy_ops ael1006_ops = {
 	.power_down = ael1006_power_down,
 };
 
-void t3_ael1006_phy_prep(struct cphy *phy, struct adapter *adapter,
-			 int phy_addr, const struct mdio_ops *mdio_ops)
+int t3_ael1006_phy_prep(struct cphy *phy, struct adapter *adapter,
+			     int phy_addr, const struct mdio_ops *mdio_ops)
 {
 	cphy_init(phy, adapter, phy_addr, &ael1006_ops, mdio_ops);
 	ael100x_txon(phy);
+	return 0;
 }
 
 static struct cphy_ops qt2045_ops = {
@@ -191,8 +193,8 @@ static struct cphy_ops qt2045_ops = {
 	.power_down = ael1006_power_down,
 };
 
-void t3_qt2045_phy_prep(struct cphy *phy, struct adapter *adapter,
-			int phy_addr, const struct mdio_ops *mdio_ops)
+int t3_qt2045_phy_prep(struct cphy *phy, struct adapter *adapter,
+		       int phy_addr, const struct mdio_ops *mdio_ops)
 {
 	unsigned int stat;
 
@@ -205,6 +207,7 @@ void t3_qt2045_phy_prep(struct cphy *phy, struct adapter *adapter,
 	if (!phy_addr && !mdio_read(phy, MDIO_DEV_PMA_PMD, MII_BMSR, &stat) &&
 	    stat == 0xffff)
 		phy->addr = 1;
+	return 0;
 }
 
 static int xaui_direct_reset(struct cphy *phy, int wait)
@@ -250,8 +253,9 @@ static struct cphy_ops xaui_direct_ops = {
 	.power_down = xaui_direct_power_down,
 };
 
-void t3_xaui_direct_phy_prep(struct cphy *phy, struct adapter *adapter,
-			     int phy_addr, const struct mdio_ops *mdio_ops)
+int t3_xaui_direct_phy_prep(struct cphy *phy, struct adapter *adapter,
+			    int phy_addr, const struct mdio_ops *mdio_ops)
 {
 	cphy_init(phy, adapter, phy_addr, &xaui_direct_ops, mdio_ops);
+	return 0;
 }
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index ace6b58..78c10d3 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -203,8 +203,8 @@ struct adapter_info {
 };
 
 struct port_type_info {
-	void (*phy_prep)(struct cphy *phy, struct adapter *adapter,
-			 int phy_addr, const struct mdio_ops *ops);
+	int (*phy_prep)(struct cphy *phy, struct adapter *adapter,
+			int phy_addr, const struct mdio_ops *ops);
 	unsigned int caps;
 	const char *desc;
 };
@@ -776,14 +776,14 @@ int t3_sge_read_rspq(struct adapter *adapter, unsigned int id, u32 data[4]);
 int t3_sge_cqcntxt_op(struct adapter *adapter, unsigned int id, unsigned int op,
 		      unsigned int credits);
 
-void t3_vsc8211_phy_prep(struct cphy *phy, struct adapter *adapter,
-			 int phy_addr, const struct mdio_ops *mdio_ops);
-void t3_ael1002_phy_prep(struct cphy *phy, struct adapter *adapter,
-			 int phy_addr, const struct mdio_ops *mdio_ops);
-void t3_ael1006_phy_prep(struct cphy *phy, struct adapter *adapter,
-			 int phy_addr, const struct mdio_ops *mdio_ops);
-void t3_qt2045_phy_prep(struct cphy *phy, struct adapter *adapter, int phy_addr,
-			const struct mdio_ops *mdio_ops);
-void t3_xaui_direct_phy_prep(struct cphy *phy, struct adapter *adapter,
-			     int phy_addr, const struct mdio_ops *mdio_ops);
+int t3_vsc8211_phy_prep(struct cphy *phy, struct adapter *adapter,
+			int phy_addr, const struct mdio_ops *mdio_ops);
+int t3_ael1002_phy_prep(struct cphy *phy, struct adapter *adapter,
+			int phy_addr, const struct mdio_ops *mdio_ops);
+int t3_ael1006_phy_prep(struct cphy *phy, struct adapter *adapter,
+			int phy_addr, const struct mdio_ops *mdio_ops);
+int t3_qt2045_phy_prep(struct cphy *phy, struct adapter *adapter, int phy_addr,
+		       const struct mdio_ops *mdio_ops);
+int t3_xaui_direct_phy_prep(struct cphy *phy, struct adapter *adapter,
+			    int phy_addr, const struct mdio_ops *mdio_ops);
 #endif				/* __CHELSIO_COMMON_H */
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 33470c7..fa0a4b4 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3626,8 +3626,11 @@ int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
 			++j;
 
 		p->port_type = &port_types[adapter->params.vpd.port_type[j]];
-		p->port_type->phy_prep(&p->phy, adapter, ai->phy_base_addr + j,
-				       ai->mdio_ops);
+		ret = p->port_type->phy_prep(&p->phy, adapter,
+					     ai->phy_base_addr + j,
+					     ai->mdio_ops);
+		if (ret)
+			return ret;
 		mac_prep(&p->mac, adapter, j);
 		++j;
 
@@ -3674,9 +3677,11 @@ int t3_replay_prep_adapter(struct adapter *adapter)
 		while (!adapter->params.vpd.port_type[j])
 			++j;
 
-		p->port_type->phy_prep(&p->phy, adapter, ai->phy_base_addr + j,
-					ai->mdio_ops);
-
+		ret = p->port_type->phy_prep(&p->phy, adapter,
+					     ai->phy_base_addr + j,
+					     ai->mdio_ops);
+		if (ret)
+			return ret;
 		p->phy.ops->power_down(&p->phy, 1);
 		++j;
 	}
diff --git a/drivers/net/cxgb3/vsc8211.c b/drivers/net/cxgb3/vsc8211.c
index eee4285..8f1b0d3 100644
--- a/drivers/net/cxgb3/vsc8211.c
+++ b/drivers/net/cxgb3/vsc8211.c
@@ -221,8 +221,9 @@ static struct cphy_ops vsc8211_ops = {
 	.power_down = vsc8211_power_down,
 };
 
-void t3_vsc8211_phy_prep(struct cphy *phy, struct adapter *adapter,
-			 int phy_addr, const struct mdio_ops *mdio_ops)
+int t3_vsc8211_phy_prep(struct cphy *phy, struct adapter *adapter,
+			int phy_addr, const struct mdio_ops *mdio_ops)
 {
 	cphy_init(phy, adapter, phy_addr, &vsc8211_ops, mdio_ops);
+	return 0;
 }

