From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v2 1/2] drivers: net: cpsw: Add helper functions for VLAN ALE implementation
Date: Thu, 31 Jan 2013 00:37:34 +0530
Message-ID: <1359572855-12344-2-git-send-email-mugunthanvnm@ti.com>
References: <1359572855-12344-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:56482 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756586Ab3A3THu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 14:07:50 -0500
In-Reply-To: <1359572855-12344-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add helper functions for VLAN ALE implementations for Add, Delete
Dump VLAN related ALE entries

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c     |    8 +--
 drivers/net/ethernet/ti/cpsw_ale.c |  106 ++++++++++++++++++++++++++++++++----
 drivers/net/ethernet/ti/cpsw_ale.h |   20 +++++--
 3 files changed, 112 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index b35e6a7..a40750e 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -345,7 +345,7 @@ static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 		/* program multicast address list into ALE register */
 		netdev_for_each_mc_addr(ha, ndev) {
 			cpsw_ale_add_mcast(priv->ale, (u8 *)ha->addr,
-				ALE_ALL_PORTS << priv->host_port, 0, 0);
+				ALE_ALL_PORTS << priv->host_port, 0, 0, 0);
 		}
 	}
 }
@@ -592,7 +592,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	slave_port = cpsw_get_slave_port(priv, slave->slave_num);
 
 	cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
-			   1 << slave_port, 0, ALE_MCAST_FWD_2);
+			   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
 
 	slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
 				 &cpsw_adjust_link, slave->data->phy_if);
@@ -624,9 +624,9 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 	cpsw_ale_control_set(priv->ale, priv->host_port,
 			     ALE_PORT_STATE, ALE_PORT_STATE_FORWARD);
 
-	cpsw_ale_add_ucast(priv->ale, priv->mac_addr, priv->host_port, 0);
+	cpsw_ale_add_ucast(priv->ale, priv->mac_addr, priv->host_port, 0, 0);
 	cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
-			   1 << priv->host_port, 0, ALE_MCAST_FWD_2);
+			   1 << priv->host_port, 0, 0, ALE_MCAST_FWD_2);
 }
 
 static int cpsw_ndo_open(struct net_device *ndev)
diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index 0e9ccc2..18b88ce 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -148,7 +148,7 @@ static int cpsw_ale_write(struct cpsw_ale *ale, int idx, u32 *ale_entry)
 	return idx;
 }
 
-static int cpsw_ale_match_addr(struct cpsw_ale *ale, u8 *addr)
+int cpsw_ale_match_addr(struct cpsw_ale *ale, u8 *addr, u16 vid)
 {
 	u32 ale_entry[ALE_ENTRY_WORDS];
 	int type, idx;
@@ -160,6 +160,8 @@ static int cpsw_ale_match_addr(struct cpsw_ale *ale, u8 *addr)
 		type = cpsw_ale_get_entry_type(ale_entry);
 		if (type != ALE_TYPE_ADDR && type != ALE_TYPE_VLAN_ADDR)
 			continue;
+		if (cpsw_ale_get_vlan_id(ale_entry) != vid)
+			continue;
 		cpsw_ale_get_addr(ale_entry, entry_addr);
 		if (memcmp(entry_addr, addr, 6) == 0)
 			return idx;
@@ -167,6 +169,22 @@ static int cpsw_ale_match_addr(struct cpsw_ale *ale, u8 *addr)
 	return -ENOENT;
 }
 
+int cpsw_ale_match_vlan(struct cpsw_ale *ale, u16 vid)
+{
+	u32 ale_entry[ALE_ENTRY_WORDS];
+	int type, idx;
+
+	for (idx = 0; idx < ale->params.ale_entries; idx++) {
+		cpsw_ale_read(ale, idx, ale_entry);
+		type = cpsw_ale_get_entry_type(ale_entry);
+		if (type != ALE_TYPE_VLAN)
+			continue;
+		if (cpsw_ale_get_vlan_id(ale_entry) == vid)
+			return idx;
+	}
+	return -ENOENT;
+}
+
 static int cpsw_ale_match_free(struct cpsw_ale *ale)
 {
 	u32 ale_entry[ALE_ENTRY_WORDS];
@@ -274,19 +292,26 @@ int cpsw_ale_flush(struct cpsw_ale *ale, int port_mask)
 	return 0;
 }
 
-int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port, int flags)
+int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port,
+		       int flags, u16 vid)
 {
 	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
 	int idx;
 
-	cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_ADDR);
+	if (flags & ALE_VLAN) {
+		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_VLAN_ADDR);
+		cpsw_ale_set_vlan_id(ale_entry, vid);
+	} else {
+		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_ADDR);
+	}
+
 	cpsw_ale_set_addr(ale_entry, addr);
 	cpsw_ale_set_ucast_type(ale_entry, ALE_UCAST_PERSISTANT);
 	cpsw_ale_set_secure(ale_entry, (flags & ALE_SECURE) ? 1 : 0);
 	cpsw_ale_set_blocked(ale_entry, (flags & ALE_BLOCKED) ? 1 : 0);
 	cpsw_ale_set_port_num(ale_entry, port);
 
-	idx = cpsw_ale_match_addr(ale, addr);
+	idx = cpsw_ale_match_addr(ale, addr, (flags & ALE_VLAN) ? vid : 0);
 	if (idx < 0)
 		idx = cpsw_ale_match_free(ale);
 	if (idx < 0)
@@ -298,12 +323,13 @@ int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port, int flags)
 	return 0;
 }
 
-int cpsw_ale_del_ucast(struct cpsw_ale *ale, u8 *addr, int port)
+int cpsw_ale_del_ucast(struct cpsw_ale *ale, u8 *addr, int port,
+		       int flags, u16 vid)
 {
 	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
 	int idx;
 
-	idx = cpsw_ale_match_addr(ale, addr);
+	idx = cpsw_ale_match_addr(ale, addr, (flags & ALE_VLAN) ? vid : 0);
 	if (idx < 0)
 		return -ENOENT;
 
@@ -313,18 +339,24 @@ int cpsw_ale_del_ucast(struct cpsw_ale *ale, u8 *addr, int port)
 }
 
 int cpsw_ale_add_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
-			int super, int mcast_state)
+		       int flags, u16 vid, int mcast_state)
 {
 	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
 	int idx, mask;
 
-	idx = cpsw_ale_match_addr(ale, addr);
+	idx = cpsw_ale_match_addr(ale, addr, (flags & ALE_VLAN) ? vid : 0);
 	if (idx >= 0)
 		cpsw_ale_read(ale, idx, ale_entry);
 
-	cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_ADDR);
+	if (flags & ALE_VLAN) {
+		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_VLAN_ADDR);
+		cpsw_ale_set_vlan_id(ale_entry, vid);
+	} else {
+		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_ADDR);
+	}
+
 	cpsw_ale_set_addr(ale_entry, addr);
-	cpsw_ale_set_super(ale_entry, super);
+	cpsw_ale_set_super(ale_entry, (flags & ALE_BLOCKED) ? 1 : 0);
 	cpsw_ale_set_mcast_state(ale_entry, mcast_state);
 
 	mask = cpsw_ale_get_port_mask(ale_entry);
@@ -342,12 +374,13 @@ int cpsw_ale_add_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
 	return 0;
 }
 
-int cpsw_ale_del_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask)
+int cpsw_ale_del_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
+		       int flags, u16 vid)
 {
 	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
 	int idx;
 
-	idx = cpsw_ale_match_addr(ale, addr);
+	idx = cpsw_ale_match_addr(ale, addr, (flags & ALE_VLAN) ? vid : 0);
 	if (idx < 0)
 		return -EINVAL;
 
@@ -362,6 +395,55 @@ int cpsw_ale_del_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask)
 	return 0;
 }
 
+int cpsw_ale_add_vlan(struct cpsw_ale *ale, u16 vid, int port, int untag,
+		      int reg_mcast, int unreg_mcast)
+{
+	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
+	int idx;
+
+	idx = cpsw_ale_match_vlan(ale, vid);
+	if (idx >= 0)
+		cpsw_ale_read(ale, idx, ale_entry);
+
+	cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_VLAN);
+	cpsw_ale_set_vlan_id(ale_entry, vid);
+
+	cpsw_ale_set_vlan_untag_force(ale_entry, untag);
+	cpsw_ale_set_vlan_reg_mcast(ale_entry, reg_mcast);
+	cpsw_ale_set_vlan_unreg_mcast(ale_entry, unreg_mcast);
+	cpsw_ale_set_vlan_member_list(ale_entry, port);
+
+	if (idx < 0)
+		idx = cpsw_ale_match_free(ale);
+	if (idx < 0)
+		idx = cpsw_ale_find_ageable(ale);
+	if (idx < 0)
+		return -ENOMEM;
+
+	cpsw_ale_write(ale, idx, ale_entry);
+	return 0;
+}
+
+int cpsw_ale_del_vlan(struct cpsw_ale *ale, u16 vid, int port_mask)
+{
+	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
+	int idx;
+
+	idx = cpsw_ale_match_vlan(ale, vid);
+	if (idx < 0)
+		return -ENOENT;
+
+	cpsw_ale_read(ale, idx, ale_entry);
+
+	if (port_mask)
+		cpsw_ale_set_vlan_member_list(ale_entry, port_mask);
+	else
+		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_FREE);
+
+	cpsw_ale_write(ale, idx, ale_entry);
+	return 0;
+}
+
 struct ale_control_info {
 	const char	*name;
 	int		offset, port_offset;
diff --git a/drivers/net/ethernet/ti/cpsw_ale.h b/drivers/net/ethernet/ti/cpsw_ale.h
index 2bd09cb..a002417 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.h
+++ b/drivers/net/ethernet/ti/cpsw_ale.h
@@ -64,8 +64,10 @@ enum cpsw_ale_port_state {
 };
 
 /* ALE unicast entry flags - passed into cpsw_ale_add_ucast() */
-#define ALE_SECURE			1
-#define ALE_BLOCKED			2
+#define ALE_SECURE			BIT(0)
+#define ALE_BLOCKED			BIT(1)
+#define ALE_SUPER			BIT(2)
+#define ALE_VLAN			BIT(3)
 
 #define ALE_MCAST_FWD			0
 #define ALE_MCAST_BLOCK_LEARN_FWD	1
@@ -81,11 +83,17 @@ void cpsw_ale_stop(struct cpsw_ale *ale);
 int cpsw_ale_set_ageout(struct cpsw_ale *ale, int ageout);
 int cpsw_ale_flush(struct cpsw_ale *ale, int port_mask);
 int cpsw_ale_flush_multicast(struct cpsw_ale *ale, int port_mask);
-int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port, int flags);
-int cpsw_ale_del_ucast(struct cpsw_ale *ale, u8 *addr, int port);
+int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port,
+		       int flags, u16 vid);
+int cpsw_ale_del_ucast(struct cpsw_ale *ale, u8 *addr, int port,
+		       int flags, u16 vid);
 int cpsw_ale_add_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
-			int super, int mcast_state);
-int cpsw_ale_del_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask);
+		       int flags, u16 vid, int mcast_state);
+int cpsw_ale_del_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
+		       int flags, u16 vid);
+int cpsw_ale_add_vlan(struct cpsw_ale *ale, u16 vid, int port, int untag,
+			int reg_mcast, int unreg_mcast);
+int cpsw_ale_del_vlan(struct cpsw_ale *ale, u16 vid, int port);
 
 int cpsw_ale_control_get(struct cpsw_ale *ale, int port, int control);
 int cpsw_ale_control_set(struct cpsw_ale *ale, int port,
-- 
1.7.9.5
