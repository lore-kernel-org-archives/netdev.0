From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH RFC 1/3] net: ixgbe: add struct igxbe_filter
Date: Thu, 25 Feb 2016 18:37:22 +0100
Message-ID: <1456421844-5901-2-git-send-email-pablo@netfilter.org>
References: <1456421844-5901-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, jiri@resnulli.us, horms@verge.net.au,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36276 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933420AbcBYRhe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 12:37:34 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 13EA27410
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 18:37:32 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id EC1BFDA386
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 18:37:31 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2A74EDA38E
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 18:37:30 +0100 (CET)
In-Reply-To: <1456421844-5901-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a container structure, this change is required by follow up patches
that rework the u32 classifier offload on top of the generic
intermediate representation.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 51 +++++++++++++++------------
 1 file changed, 28 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cf4b729..252e9ff 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8238,6 +8238,12 @@ static int ixgbe_configure_clsu32_del_hnode(struct ixgbe_adapter *adapter,
 	return 0;
 }
 
+struct ixgbe_filter {
+	struct ixgbe_fdir_filter *input;
+	union ixgbe_atr_input mask;
+	u8 queue;
+};
+
 static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 				  __be16 protocol,
 				  struct tc_cls_u32_offload *cls)
@@ -8245,16 +8251,14 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 	u32 loc = cls->knode.handle & 0xfffff;
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbe_mat_field *field_ptr;
-	struct ixgbe_fdir_filter *input;
-	union ixgbe_atr_input mask;
+	struct ixgbe_filter f;
 #ifdef CONFIG_NET_CLS_ACT
 	const struct tc_action *a;
 #endif
 	int i, err = 0;
-	u8 queue;
 	u32 handle;
 
-	memset(&mask, 0, sizeof(union ixgbe_atr_input));
+	memset(&f.mask, 0, sizeof(union ixgbe_atr_input));
 	handle = cls->knode.handle;
 
 	/* At the moment cls_u32 jumps to transport layer and skips past
@@ -8320,8 +8324,8 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 	if (!field_ptr)
 		return -EINVAL;
 
-	input = kzalloc(sizeof(*input), GFP_KERNEL);
-	if (!input)
+	f.input = kzalloc(sizeof(struct ixgbe_fdir_filter), GFP_KERNEL);
+	if (!f.input)
 		return -ENOMEM;
 
 	for (i = 0; i < cls->knode.sel->nkeys; i++) {
@@ -8334,8 +8338,8 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 		for (j = 0; field_ptr[j].val; j++) {
 			if (field_ptr[j].off == off &&
 			    field_ptr[j].mask == m) {
-				field_ptr[j].val(input, &mask, val, m);
-				input->filter.formatted.flow_type |=
+				field_ptr[j].val(f.input, &f.mask, val, m);
+				f.input->filter.formatted.flow_type |=
 					field_ptr[j].type;
 				found_entry = true;
 				break;
@@ -8346,11 +8350,11 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 			goto err_out;
 	}
 
-	mask.formatted.flow_type = IXGBE_ATR_L4TYPE_IPV6_MASK |
-				   IXGBE_ATR_L4TYPE_MASK;
+	f.mask.formatted.flow_type = IXGBE_ATR_L4TYPE_IPV6_MASK |
+				     IXGBE_ATR_L4TYPE_MASK;
 
-	if (input->filter.formatted.flow_type == IXGBE_ATR_FLOW_TYPE_IPV4)
-		mask.formatted.flow_type &= IXGBE_ATR_L4TYPE_IPV6_MASK;
+	if (f.input->filter.formatted.flow_type == IXGBE_ATR_FLOW_TYPE_IPV4)
+		f.mask.formatted.flow_type &= IXGBE_ATR_L4TYPE_IPV6_MASK;
 
 #ifdef CONFIG_NET_CLS_ACT
 	if (list_empty(&cls->knode.exts->actions))
@@ -8362,34 +8366,35 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 	}
 #endif
 
-	input->action = IXGBE_FDIR_DROP_QUEUE;
-	queue = IXGBE_FDIR_DROP_QUEUE;
-	input->sw_idx = loc;
+	f.input->action = IXGBE_FDIR_DROP_QUEUE;
+	f.queue = IXGBE_FDIR_DROP_QUEUE;
+	f.input->sw_idx = loc;
 
 	spin_lock(&adapter->fdir_perfect_lock);
 
 	if (hlist_empty(&adapter->fdir_filter_list)) {
-		memcpy(&adapter->fdir_mask, &mask, sizeof(mask));
-		err = ixgbe_fdir_set_input_mask_82599(hw, &mask);
+		memcpy(&adapter->fdir_mask, &f.mask, sizeof(f.mask));
+		err = ixgbe_fdir_set_input_mask_82599(hw, &f.mask);
 		if (err)
 			goto err_out_w_lock;
-	} else if (memcmp(&adapter->fdir_mask, &mask, sizeof(mask))) {
+	} else if (memcmp(&adapter->fdir_mask, &f.mask, sizeof(f.mask))) {
 		err = -EINVAL;
 		goto err_out_w_lock;
 	}
 
-	ixgbe_atr_compute_perfect_hash_82599(&input->filter, &mask);
-	err = ixgbe_fdir_write_perfect_filter_82599(hw, &input->filter,
-						    input->sw_idx, queue);
+	ixgbe_atr_compute_perfect_hash_82599(&f.input->filter, &f.mask);
+	err = ixgbe_fdir_write_perfect_filter_82599(hw, &f.input->filter,
+						    f.input->sw_idx, f.queue);
 	if (!err)
-		ixgbe_update_ethtool_fdir_entry(adapter, input, input->sw_idx);
+		ixgbe_update_ethtool_fdir_entry(adapter, f.input,
+						f.input->sw_idx);
 	spin_unlock(&adapter->fdir_perfect_lock);
 
 	return err;
 err_out_w_lock:
 	spin_unlock(&adapter->fdir_perfect_lock);
 err_out:
-	kfree(input);
+	kfree(f.input);
 	return -EINVAL;
 }
 
-- 
2.1.4
