From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 7/7] net: ixgbe: add support for tc_u32 offload
Date: Sun, 31 Jan 2016 17:53:10 -0800
Message-ID: <20160201015310.13871.63596.stgit@john-Precision-Tower-5810>
References: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, donald.c.skidmore@intel.com, horms@verge.net.au,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: anjali.singhai@intel.com, jesse.brandeburg@intel.com,
	jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35688 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933349AbcBABx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 20:53:59 -0500
Received: by mail-pa0-f66.google.com with SMTP id gi1so6522392pac.2
        for <netdev@vger.kernel.org>; Sun, 31 Jan 2016 17:53:59 -0800 (PST)
In-Reply-To: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds initial support for offloading the u32 tc classifier. This
initial implementation only implements a few base matches and actions
to illustrate the use of the infrastructure patches.

However it is an interesting subset because it handles the u32 next
hdr logic to correctly map tcp packets from ip headers using the ihl
and protocol fields. After this is accepted we can extend the match
and action fields easily by updating the model header file.

Also only the drop action is supported initially.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    3 
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    6 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  188 ++++++++++++++++++++++
 3 files changed, 190 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index f4c9a42..532b1bd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -925,6 +925,9 @@ s32 ixgbe_fdir_erase_perfect_filter_82599(struct ixgbe_hw *hw,
 					  u16 soft_id);
 void ixgbe_atr_compute_perfect_hash_82599(union ixgbe_atr_input *input,
 					  union ixgbe_atr_input *mask);
+int ixgbe_update_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
+				    struct ixgbe_fdir_filter *input,
+				    u16 sw_idx);
 void ixgbe_set_rx_mode(struct net_device *netdev);
 #ifdef CONFIG_IXGBE_DCB
 void ixgbe_set_rx_drop_en(struct ixgbe_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 1ed4c9a..712972d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2490,9 +2490,9 @@ static int ixgbe_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 	return ret;
 }
 
-static int ixgbe_update_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
-					   struct ixgbe_fdir_filter *input,
-					   u16 sw_idx)
+int ixgbe_update_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
+				    struct ixgbe_fdir_filter *input,
+				    u16 sw_idx)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct hlist_node *node2;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 38a160b..c1aabf1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -51,6 +51,7 @@
 #include <linux/prefetch.h>
 #include <scsi/fc/fc_fcoe.h>
 #include <net/vxlan.h>
+#include <net/pkt_cls.h>
 
 #ifdef CONFIG_OF
 #include <linux/of_net.h>
@@ -8167,10 +8168,189 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	return 0;
 }
 
+#include <net/tc_act/tc_gact.h>
+#include "ixgbe_model.h"
+static int ixgbe_delete_clsu32(struct ixgbe_adapter *adapter,
+			       struct tc_cls_u32_offload *cls)
+{
+	int err;
+
+	spin_lock(&adapter->fdir_perfect_lock);
+	err = ixgbe_update_ethtool_fdir_entry(adapter, NULL, cls->knode.handle);
+	spin_unlock(&adapter->fdir_perfect_lock);
+	return err;
+}
+
+#define IXGBE_MAX_LINK_HANDLE 10
+static struct ixgbe_mat_fieldi *
+ixgbe_jump_tables[IXGBE_MAX_LINK_HANDLE] = {ixgbe_ipv4_fields,};
+
+static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
+				  __be16 protocol,
+				  struct tc_cls_u32_offload *cls)
+{
+	u32 loc = cls->knode.handle & 0xfffff;
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_mat_field *field_ptr;
+	struct ixgbe_fdir_filter *input;
+	union ixgbe_atr_input mask;
+	const struct tc_action *a;
+	int i, err = 0;
+	u8 queue;
+	u32 handle;
+
+	memset(&mask, 0, sizeof(union ixgbe_atr_input));
+	handle = cls->knode.handle;
+
+	/* At the moment cls_u32 jumps to transport layer and skips past
+	 * L2 headers. The canonical method to match L2 frames is to use
+	 * negative values. However this is error prone at best but really
+	 * just broken because there is no way to "know" what sort of hdr
+	 * is in front of the transport layer. Fix cls_u32 to support L2
+	 * headers when needed.
+	 */
+	if (protocol != htons(ETH_P_IP))
+		return -EINVAL;
+
+	if (cls->knode.link_handle ||
+	    cls->knode.link_handle >= IXGBE_MAX_LINK_HANDLE) {
+		struct ixgbe_nexthdr *nexthdr = ixgbe_ipv4_jumps;
+		u32 uhtid = TC_U32_USERHTID(cls->knode.link_handle);
+
+		for (i = 0; nexthdr[i].jump; i++) {
+			if (nexthdr->o != cls->knode.sel->offoff ||
+			    nexthdr->s != cls->knode.sel->offshift ||
+			    nexthdr->m != cls->knode.sel->offmask ||
+			    /* do not support multiple key jumps its just mad */
+			    cls->knode.sel->nkeys > 1)
+				return -EINVAL;
+
+			if (nexthdr->off != cls->knode.sel->keys[0].off ||
+			    nexthdr->val != cls->knode.sel->keys[0].val ||
+			    nexthdr->mask != cls->knode.sel->keys[0].mask)
+				return -EINVAL;
+
+			if (uhtid >= IXGBE_MAX_LINK_HANDLE)
+				return -EINVAL;
+
+			ixgbe_jump_tables[uhtid] = nexthdr->jump;
+		}
+		return 0;
+	}
+
+	if (loc >= ((1024 << adapter->fdir_pballoc) - 2)) {
+		e_err(drv, "Location out of range\n");
+		return -EINVAL;
+	}
+
+	/* cls u32 is a graph starting at root node 0x800. The driver tracks
+	 * links and also the fields used to advance the parser across each
+	 * link (e.g. nexthdr/eat parameters from 'tc'). This way we can map
+	 * the u32 graph onto the hardware parse graph denoted in ixgbe_model.h
+	 * To add support for new nodes update ixgbe_model.h parse structures
+	 * this function _should_ be generic try not to hardcode values here.
+	 */
+	if (TC_U32_USERHTID(handle) == 0x800) {
+		field_ptr = ixgbe_jump_tables[0];
+	} else {
+		if (TC_U32_USERHTID(handle) >= ARRAY_SIZE(ixgbe_jump_tables))
+			return -EINVAL;
+
+		field_ptr = ixgbe_jump_tables[TC_U32_USERHTID(handle)];
+	}
+
+	if (!field_ptr)
+		return -EINVAL;
+
+	input = kzalloc(sizeof(*input), GFP_ATOMIC);
+	if (!input)
+		return -ENOMEM;
+
+	for (i = 0; i < cls->knode.sel->nkeys; i++) {
+		int off = cls->knode.sel->keys[i].off;
+		__be32 val = cls->knode.sel->keys[i].val;
+		__be32 m = cls->knode.sel->keys[i].mask;
+		bool found_entry = false;
+
+		mask.formatted.flow_type = IXGBE_ATR_L4TYPE_IPV6_MASK |
+					   IXGBE_ATR_L4TYPE_MASK;
+
+		for (i = 0; field_ptr[i].val; i++) {
+			if (field_ptr[i].off == off &&
+			    field_ptr[i].mask == m) {
+				field_ptr[i].val(input, &mask, val, m);
+				found_entry = true;
+				break;
+			}
+		}
+
+		if (!found_entry)
+			goto err_out;
+	}
+
+	if (list_empty(&cls->knode.exts->actions))
+		goto err_out;
+
+	list_for_each_entry(a, &cls->knode.exts->actions, list) {
+		if (!is_tcf_gact_dropped(a))
+			goto err_out;
+	}
+
+	input->action = IXGBE_FDIR_DROP_QUEUE;
+	queue = IXGBE_FDIR_DROP_QUEUE;
+	input->sw_idx = loc;
+
+	spin_lock(&adapter->fdir_perfect_lock);
+
+	if (hlist_empty(&adapter->fdir_filter_list)) {
+		memcpy(&adapter->fdir_mask, &mask, sizeof(mask));
+		err = ixgbe_fdir_set_input_mask_82599(hw, &mask);
+		if (err)
+			goto err_out_w_lock;
+	} else if (memcmp(&adapter->fdir_mask, &mask, sizeof(mask))) {
+		err = -EINVAL;
+		goto err_out_w_lock;
+	}
+
+	ixgbe_atr_compute_perfect_hash_82599(&input->filter, &mask);
+	err = ixgbe_fdir_write_perfect_filter_82599(hw, &input->filter,
+						    input->sw_idx, queue);
+	if (!err)
+		ixgbe_update_ethtool_fdir_entry(adapter, input, input->sw_idx);
+	spin_unlock(&adapter->fdir_perfect_lock);
+
+	return err;
+err_out_w_lock:
+	spin_unlock(&adapter->fdir_perfect_lock);
+err_out:
+	kfree(input);
+	return -EINVAL;
+}
+
 int __ixgbe_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 		     struct tc_to_netdev *tc)
 {
-	/* Only support egress tc setup for now */
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+
+	if (TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS) &&
+	    tc->type == TC_SETUP_CLSU32) {
+		struct tc_cls_u32_offload *cls = tc->cls_u32;
+
+		if (!(dev->hw_features & NETIF_F_HW_TC))
+			return -EINVAL;
+
+		switch (tc->cls_u32->command) {
+		case TC_CLSU32_NEW_KNODE:
+		case TC_CLSU32_REPLACE_KNODE:
+			return ixgbe_configure_clsu32(adapter,
+						      proto, tc->cls_u32);
+		case TC_CLSU32_DELETE_KNODE:
+			return ixgbe_delete_clsu32(adapter, tc->cls_u32);
+		default:
+			return -EINVAL;
+		}
+	}
+
 	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
@@ -8244,6 +8424,7 @@ static int ixgbe_set_features(struct net_device *netdev,
 	 */
 	switch (features & NETIF_F_NTUPLE) {
 	case NETIF_F_NTUPLE:
+	case NETIF_F_HW_TC:
 		/* turn off ATR, enable perfect filters and reset */
 		if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
 			need_reset = true;
@@ -8634,9 +8815,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_trust	= ixgbe_ndo_set_vf_trust,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
-#ifdef CONFIG_IXGBE_DCB
 	.ndo_setup_tc		= __ixgbe_setup_tc,
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif
@@ -9007,7 +9186,8 @@ skip_sriov:
 	case ixgbe_mac_X550EM_x:
 		netdev->features |= NETIF_F_SCTP_CRC;
 		netdev->hw_features |= NETIF_F_SCTP_CRC |
-				       NETIF_F_NTUPLE;
+				       NETIF_F_NTUPLE |
+				       NETIF_F_HW_TC;
 		break;
 	default:
 		break;
