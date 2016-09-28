From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 08/12] rocker: Support Open vSwitch (-like) flow stats in OF-DPA world
Date: Wed, 28 Sep 2016 14:42:58 +0200
Message-ID: <1475066582-1971-9-git-send-email-simon.horman@netronome.com>
References: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35450 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752839AbcI1MnT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:43:19 -0400
Received: by mail-wm0-f48.google.com with SMTP id l132so234066586wmf.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:43:19 -0700 (PDT)
In-Reply-To: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prototype an implementation of the new switchdev_port_obj_get SDO for the
SWITCHDEV_OBJ_OVS_FLOW object type. This allows retrieval of statistics for
Open vSwitch (-like) flows which have been programmed into hardware.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker_hw.h    |  4 ++
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 92 ++++++++++++++++++++++++++++--
 2 files changed, 92 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_hw.h b/drivers/net/ethernet/rocker/rocker_hw.h
index 2adfe88859f2..0a9d33bc80a0 100644
--- a/drivers/net/ethernet/rocker/rocker_hw.h
+++ b/drivers/net/ethernet/rocker/rocker_hw.h
@@ -373,6 +373,10 @@ enum {
 	ROCKER_TLV_OF_DPA_FLOW_STAT_RX_PKTS,	/* u64 */
 	ROCKER_TLV_OF_DPA_FLOW_STAT_TX_PKTS,	/* u64 */
 
+	ROCKER_TLV_OF_DPA_FLOW_STAT_RX_BYTES,	/* u64 */
+	ROCKER_TLV_OF_DPA_FLOW_STAT_TX_BYTES,	/* u64 */
+	ROCKER_TLV_OF_DPA_FLOW_STAT_IDLE,	/* u64 */
+
 	__ROCKER_TLV_OF_DPA_FLOW_STAT_MAX,
 	ROCKER_TLV_OF_DPA_FLOW_STAT_MAX = __ROCKER_TLV_OF_DPA_FLOW_STAT_MAX - 1,
 };
diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 6669f2ba2f97..3b441359a3a7 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -619,9 +619,9 @@ static int ofdpa_cmd_flow_tbl_add(const struct rocker_port *rocker_port,
 	return 0;
 }
 
-static int ofdpa_cmd_flow_tbl_del(const struct rocker_port *rocker_port,
-				  struct rocker_desc_info *desc_info,
-				  void *priv)
+static int ofdpa_cmd_flow_tbl_prep(const struct rocker_port *rocker_port,
+				   struct rocker_desc_info *desc_info,
+				   void *priv)
 {
 	const struct ofdpa_flow_tbl_entry *entry = priv;
 	struct rocker_tlv *cmd_info;
@@ -884,7 +884,7 @@ static int ofdpa_flow_tbl_del(struct ofdpa_port *ofdpa_port,
 		if (!switchdev_trans_ph_prepare(trans))
 			err = rocker_cmd_exec(ofdpa_port->rocker_port,
 					      ofdpa_flags_nowait(flags),
-					      ofdpa_cmd_flow_tbl_del,
+					      ofdpa_cmd_flow_tbl_prep,
 					      found, NULL, NULL);
 		ofdpa_kfree(trans, found);
 	}
@@ -3038,6 +3038,82 @@ static int ofdpa_port_obj_sw_flow_del(struct rocker_port *rocker_port,
 	return ofdpa_flow_tbl_del(ofdpa_port, trans, flags, entry);
 }
 
+static int
+ofdpa_cmd_flow_tbl_get_stats_proc(const struct rocker_port *rocker_port,
+				const struct rocker_desc_info *desc_info,
+				void *priv)
+{
+	const struct rocker_tlv *info_attrs[ROCKER_TLV_OF_DPA_FLOW_STAT_MAX + 1];
+	const struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
+	struct switchdev_obj_stats *stats = priv;
+
+	rocker_tlv_parse_desc(attrs, ROCKER_TLV_CMD_MAX, desc_info);
+	if (!attrs[ROCKER_TLV_CMD_INFO])
+		return -EIO;
+
+	rocker_tlv_parse_nested(info_attrs, ROCKER_TLV_OF_DPA_FLOW_STAT_MAX,
+			       attrs[ROCKER_TLV_CMD_INFO]);
+
+	if (info_attrs[ROCKER_TLV_OF_DPA_FLOW_STAT_RX_PKTS])
+		stats->rx_packets = rocker_tlv_get_u64(info_attrs[ROCKER_TLV_OF_DPA_FLOW_STAT_RX_PKTS]);
+	if (info_attrs[ROCKER_TLV_OF_DPA_FLOW_STAT_RX_BYTES])
+		stats->rx_bytes = rocker_tlv_get_u64(info_attrs[ROCKER_TLV_OF_DPA_FLOW_STAT_RX_BYTES]);
+	if (info_attrs[ROCKER_TLV_OF_DPA_FLOW_STAT_IDLE]) {
+		u64 idle_ms;
+
+		idle_ms = rocker_tlv_get_u64(info_attrs[ROCKER_TLV_OF_DPA_FLOW_STAT_IDLE]);
+		stats->last_used = jiffies - (idle_ms * HZ / 1000);
+	}
+
+	return 0;
+}
+
+static int ofdpa_flow_tbl_get_stats(struct ofdpa_port *ofdpa_port,
+				    struct ofdpa_flow_tbl_entry *match,
+				    struct switchdev_obj_stats *stats)
+{
+	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
+	struct ofdpa_flow_tbl_entry *found;
+	size_t key_len = match->key_len ? match->key_len : sizeof(found->key);
+	unsigned long lock_flags;
+	int err = 0;
+
+	match->key_crc32 = crc32(~0, &match->key, key_len);
+
+	spin_lock_irqsave(&ofdpa->flow_tbl_lock, lock_flags);
+
+	found = ofdpa_flow_tbl_find(ofdpa, match);
+
+	if (found)
+		found->cmd = ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_GET_STATS;
+
+	spin_unlock_irqrestore(&ofdpa->flow_tbl_lock, lock_flags);
+
+	ofdpa_kfree(NULL, match);
+
+	if (found) {
+		err = rocker_cmd_exec(ofdpa_port->rocker_port, 0,
+				      ofdpa_cmd_flow_tbl_prep, found,
+				      ofdpa_cmd_flow_tbl_get_stats_proc, stats);
+	}
+
+	return err;
+}
+
+static int ofdpa_port_obj_sw_flow_get_stats(struct rocker_port *rocker_port,
+				     const struct switchdev_obj_sw_flow *flow)
+{
+	struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
+	struct switchdev_trans *trans = NULL;
+	struct ofdpa_flow_tbl_entry *entry;
+
+	entry = ofdpa_port_sw_flow_entry(ofdpa_port, trans, flow);
+	if (IS_ERR(entry))
+		return PTR_ERR(entry);
+
+	return ofdpa_flow_tbl_get_stats(ofdpa_port, entry, flow->stats);
+}
+
 #else
 
 static int ofdpa_port_obj_sw_flow_add(struct rocker_port *rocker_port,
@@ -3052,6 +3128,13 @@ static int ofdpa_port_obj_sw_flow_del(struct rocker_port *rocker_port,
 	return -ENOTSUPP;
 }
 
+static int ofdpa_port_obj_ovs_flow_get_stats(struct rocker_port *rocker_port,
+				     const struct switchdev_obj_ovs_flow *flow)
+{
+{
+	return -ENOTSUPP;
+}
+
 #endif
 
 static int ofdpa_port_bridge_join(struct ofdpa_port *ofdpa_port,
@@ -3207,6 +3290,7 @@ struct rocker_world_ops rocker_ofdpa_ops = {
 	.port_obj_fdb_dump = ofdpa_port_obj_fdb_dump,
 	.port_obj_sw_flow_add = ofdpa_port_obj_sw_flow_add,
 	.port_obj_sw_flow_del = ofdpa_port_obj_sw_flow_del,
+	.port_obj_sw_flow_get_stats = ofdpa_port_obj_sw_flow_get_stats,
 	.port_master_linked = ofdpa_port_master_linked,
 	.port_master_unlinked = ofdpa_port_master_unlinked,
 	.port_neigh_update = ofdpa_port_neigh_update,
-- 
2.7.0.rc3.207.g0ac5344
