From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/2] drivers: net: cpsw: Add helper functions for VLAN ALE implementation
Date: Tue, 29 Jan 2013 01:42:24 +0530
Message-ID: <1359403945-28585-2-git-send-email-mugunthanvnm@ti.com>
References: <1359403945-28585-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1359403945-28585-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add helper functions for VLAN ALE implementations for Add, Delete
Dump VLAN related ALE entries

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw_ale.c |  172 ++++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/ti/cpsw_ale.h |   11 +++
 2 files changed, 178 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index 0e9ccc2..0d7a60a 100644
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
@@ -286,7 +304,7 @@ int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port, int flags)
 	cpsw_ale_set_blocked(ale_entry, (flags & ALE_BLOCKED) ? 1 : 0);
 	cpsw_ale_set_port_num(ale_entry, port);
 
-	idx = cpsw_ale_match_addr(ale, addr);
+	idx = cpsw_ale_match_addr(ale, addr, 0);
 	if (idx < 0)
 		idx = cpsw_ale_match_free(ale);
 	if (idx < 0)
@@ -303,7 +321,7 @@ int cpsw_ale_del_ucast(struct cpsw_ale *ale, u8 *addr, int port)
 	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
 	int idx;
 
-	idx = cpsw_ale_match_addr(ale, addr);
+	idx = cpsw_ale_match_addr(ale, addr, 0);
 	if (idx < 0)
 		return -ENOENT;
 
@@ -318,7 +336,7 @@ int cpsw_ale_add_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
 	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
 	int idx, mask;
 
-	idx = cpsw_ale_match_addr(ale, addr);
+	idx = cpsw_ale_match_addr(ale, addr, 0);
 	if (idx >= 0)
 		cpsw_ale_read(ale, idx, ale_entry);
 
@@ -347,7 +365,151 @@ int cpsw_ale_del_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask)
 	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
 	int idx;
 
-	idx = cpsw_ale_match_addr(ale, addr);
+	idx = cpsw_ale_match_addr(ale, addr, 0);
+	if (idx < 0)
+		return -EINVAL;
+
+	cpsw_ale_read(ale, idx, ale_entry);
+
+	if (port_mask)
+		cpsw_ale_set_port_mask(ale_entry, port_mask);
+	else
+		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_FREE);
+
+	cpsw_ale_write(ale, idx, ale_entry);
+	return 0;
+}
+
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
+int cpsw_ale_del_vlan(struct cpsw_ale *ale, u16 vid, int port)
+{
+	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
+	int idx, mask;
+
+	idx = cpsw_ale_match_vlan(ale, vid);
+	if (idx < 0)
+		return -ENOENT;
+
+	cpsw_ale_read(ale, idx, ale_entry);
+
+	mask  = cpsw_ale_get_vlan_member_list(ale_entry);
+	mask &= ~port;
+	if (!mask)
+		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_FREE);
+	else
+		cpsw_ale_set_vlan_member_list(ale_entry, mask);
+
+	cpsw_ale_write(ale, idx, ale_entry);
+	return 0;
+}
+
+int cpsw_ale_vlan_add_ucast(struct cpsw_ale *ale, u8 *addr, int port,
+				int flags, u16 vid)
+{
+	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
+	int idx;
+
+	cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_VLAN_ADDR);
+	cpsw_ale_set_addr(ale_entry, addr);
+	cpsw_ale_set_ucast_type(ale_entry, ALE_UCAST_PERSISTANT);
+	cpsw_ale_set_secure(ale_entry, (flags & ALE_SECURE) ? 1 : 0);
+	cpsw_ale_set_blocked(ale_entry, (flags & ALE_BLOCKED) ? 1 : 0);
+	cpsw_ale_set_port_num(ale_entry, port);
+	cpsw_ale_set_vlan_id(ale_entry, vid);
+
+	idx = cpsw_ale_match_addr(ale, addr, vid);
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
+int cpsw_ale_vlan_del_ucast(struct cpsw_ale *ale, u8 *addr, int port, u16 vid)
+{
+	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
+	int idx;
+
+	idx = cpsw_ale_match_addr(ale, addr, vid);
+	if (idx < 0)
+		return -ENOENT;
+
+	cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_FREE);
+	cpsw_ale_write(ale, idx, ale_entry);
+	return 0;
+}
+
+int cpsw_ale_vlan_add_mcast(struct cpsw_ale *ale, u8 *addr,
+		int port_mask, u16 vid, int super, int mcast_state)
+{
+	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
+	int idx, mask;
+
+	idx = cpsw_ale_match_addr(ale, addr, vid);
+	if (idx >= 0)
+		cpsw_ale_read(ale, idx, ale_entry);
+
+	cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_VLAN_ADDR);
+	cpsw_ale_set_addr(ale_entry, addr);
+	cpsw_ale_set_mcast_state(ale_entry, ALE_MCAST_FWD_2);
+	cpsw_ale_set_vlan_id(ale_entry, vid);
+	cpsw_ale_set_super(ale_entry, super);
+	cpsw_ale_set_mcast_state(ale_entry, mcast_state);
+
+	mask = cpsw_ale_get_port_mask(ale_entry);
+	port_mask |= mask;
+	cpsw_ale_set_port_mask(ale_entry, port_mask);
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
+int cpsw_ale_vlan_del_mcast(struct cpsw_ale *ale, u8 *addr,
+				int port_mask, u16 vid)
+{
+	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
+	int idx;
+
+	idx = cpsw_ale_match_addr(ale, addr, vid);
 	if (idx < 0)
 		return -EINVAL;
 
diff --git a/drivers/net/ethernet/ti/cpsw_ale.h b/drivers/net/ethernet/ti/cpsw_ale.h
index 2bd09cb..fbb0f7e 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.h
+++ b/drivers/net/ethernet/ti/cpsw_ale.h
@@ -86,6 +86,17 @@ int cpsw_ale_del_ucast(struct cpsw_ale *ale, u8 *addr, int port);
 int cpsw_ale_add_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
 			int super, int mcast_state);
 int cpsw_ale_del_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask);
+int cpsw_ale_add_vlan(struct cpsw_ale *ale, u16 vid, int port, int untag,
+			int reg_mcast, int unreg_mcast);
+int cpsw_ale_del_vlan(struct cpsw_ale *ale, u16 vid, int port);
+int cpsw_ale_vlan_add_ucast(struct cpsw_ale *ale, u8 *addr, int port,
+			int flags, u16 vid);
+int cpsw_ale_vlan_del_ucast(struct cpsw_ale *ale, u8 *addr, int port,
+			u16 vid);
+int cpsw_ale_vlan_add_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
+			u16 vid, int super, int mcast_state);
+int cpsw_ale_vlan_del_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
+			u16 vid);
 
 int cpsw_ale_control_get(struct cpsw_ale *ale, int port, int control);
 int cpsw_ale_control_set(struct cpsw_ale *ale, int port,
-- 
1.7.9.5

