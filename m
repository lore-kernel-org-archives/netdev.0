From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: Don't flush multicast MACs
Date: Wed, 24 Aug 2016 13:27:19 +0300
Message-ID: <1472034439-18810-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:60481 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751063AbcHXK10 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:27:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ndo_set_rx_mode() is called for bnx2x, as part of process of
configuring the new MAC address filters [both unicast & multicast]
driver begins by flushing the existing configuration and then iterating
over the network device's list of addresses and configures those instead.

This has the side-effect of creating a short gap where traffic wouldn't
be properly classified, as no filters are configured in HW.
While for unicasts this is rather insignificant [as unicast MACs don't
frequently change while interface is actually running],
for multicast traffic it does pose an issue as there are multicast-based
networks where new multicast groups would constantly be removed and
added.

This patch tries to remedy this [at least for the newer adapters] -
Instead of flushing & reconfiguring all existing multicast filters,
the driver would instead create the approximate hash match that would
result from the required filters. It would then compare it against the
currently configured approximate hash match, and only add and remove the
delta between those.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please consider applying this to `net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  47 +++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c    | 191 ++++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h    |  12 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |  24 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |   1 -
 5 files changed, 241 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 97e8925..de2d326 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12560,8 +12560,10 @@ static int bnx2x_init_mcast_macs_list(struct bnx2x *bp,
 		kcalloc(mc_count, sizeof(*mc_mac), GFP_ATOMIC);
 	struct netdev_hw_addr *ha;
 
-	if (!mc_mac)
+	if (!mc_mac) {
+		BNX2X_ERR("Failed to allocate mc MAC list\n");
 		return -ENOMEM;
+	}
 
 	INIT_LIST_HEAD(&p->mcast_list);
 
@@ -12632,7 +12634,7 @@ static int bnx2x_set_uc_list(struct bnx2x *bp)
 				 BNX2X_UC_LIST_MAC, &ramrod_flags);
 }
 
-static int bnx2x_set_mc_list(struct bnx2x *bp)
+static int bnx2x_set_mc_list_e1x(struct bnx2x *bp)
 {
 	struct net_device *dev = bp->dev;
 	struct bnx2x_mcast_ramrod_params rparam = {NULL};
@@ -12650,11 +12652,8 @@ static int bnx2x_set_mc_list(struct bnx2x *bp)
 	/* then, configure a new MACs list */
 	if (netdev_mc_count(dev)) {
 		rc = bnx2x_init_mcast_macs_list(bp, &rparam);
-		if (rc) {
-			BNX2X_ERR("Failed to create multicast MACs list: %d\n",
-				  rc);
+		if (rc)
 			return rc;
-		}
 
 		/* Now add the new MACs */
 		rc = bnx2x_config_mcast(bp, &rparam,
@@ -12669,6 +12668,42 @@ static int bnx2x_set_mc_list(struct bnx2x *bp)
 	return rc;
 }
 
+static int bnx2x_set_mc_list(struct bnx2x *bp)
+{
+	struct bnx2x_mcast_ramrod_params rparam = {NULL};
+	struct net_device *dev = bp->dev;
+	int rc = 0;
+
+	/* On older adapters, we need to flush and re-add filters */
+	if (CHIP_IS_E1x(bp))
+		return bnx2x_set_mc_list_e1x(bp);
+
+	rparam.mcast_obj = &bp->mcast_obj;
+
+	if (netdev_mc_count(dev)) {
+		rc = bnx2x_init_mcast_macs_list(bp, &rparam);
+		if (rc)
+			return rc;
+
+		/* Override the curently configured set of mc filters */
+		rc = bnx2x_config_mcast(bp, &rparam,
+					BNX2X_MCAST_CMD_SET);
+		if (rc < 0)
+			BNX2X_ERR("Failed to set a new multicast configuration: %d\n",
+				  rc);
+
+		bnx2x_free_mcast_macs_list(&rparam);
+	} else {
+		/* If no mc addresses are required, flush the configuration */
+		rc = bnx2x_config_mcast(bp, &rparam, BNX2X_MCAST_CMD_DEL);
+		if (rc)
+			BNX2X_ERR("Failed to clear multicast configuration %d\n",
+				  rc);
+	}
+
+	return rc;
+}
+
 /* If bp->state is OPEN, should be called with netif_addr_lock_bh() */
 static void bnx2x_set_rx_mode(struct net_device *dev)
 {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index ff702a7..d468380 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -2600,6 +2600,12 @@ struct bnx2x_mcast_mac_elem {
 	u8 pad[2]; /* For a natural alignment of the following buffer */
 };
 
+struct bnx2x_mcast_bin_elem {
+	struct list_head link;
+	int bin;
+	int type; /* BNX2X_MCAST_CMD_SET_{ADD, DEL} */
+};
+
 struct bnx2x_pending_mcast_cmd {
 	struct list_head link;
 	int type; /* BNX2X_MCAST_CMD_X */
@@ -2609,6 +2615,11 @@ struct bnx2x_pending_mcast_cmd {
 		int next_bin; /* Needed for RESTORE flow with aprox match */
 	} data;
 
+	bool set_convert; /* in case type == BNX2X_MCAST_CMD_SET, this is set
+			   * when macs_head had been converted to a list of
+			   * bnx2x_mcast_bin_elem.
+			   */
+
 	bool done; /* set to true, when the command has been handled,
 		    * practically used in 57712 handling only, where one pending
 		    * command may be handled in a few operations. As long as for
@@ -2636,15 +2647,30 @@ static int bnx2x_mcast_enqueue_cmd(struct bnx2x *bp,
 	struct bnx2x_pending_mcast_cmd *new_cmd;
 	struct bnx2x_mcast_mac_elem *cur_mac = NULL;
 	struct bnx2x_mcast_list_elem *pos;
-	int macs_list_len = ((cmd == BNX2X_MCAST_CMD_ADD) ?
-			     p->mcast_list_len : 0);
+	int macs_list_len = 0, macs_list_len_size;
+
+	/* When adding MACs we'll need to store their values */
+	if (cmd == BNX2X_MCAST_CMD_ADD || cmd == BNX2X_MCAST_CMD_SET)
+		macs_list_len = p->mcast_list_len;
 
 	/* If the command is empty ("handle pending commands only"), break */
 	if (!p->mcast_list_len)
 		return 0;
 
-	total_sz = sizeof(*new_cmd) +
-		macs_list_len * sizeof(struct bnx2x_mcast_mac_elem);
+	/* For a set command, we need to allocate sufficient memory for all
+	 * the bins, since we can't analyze at this point how much memory would
+	 * be required.
+	 */
+	macs_list_len_size = macs_list_len *
+			     sizeof(struct bnx2x_mcast_mac_elem);
+	if (cmd == BNX2X_MCAST_CMD_SET) {
+		int bin_size = BNX2X_MCAST_BINS_NUM *
+			       sizeof(struct bnx2x_mcast_bin_elem);
+
+		if (bin_size > macs_list_len_size)
+			macs_list_len_size = bin_size;
+	}
+	total_sz = sizeof(*new_cmd) + macs_list_len_size;
 
 	/* Add mcast is called under spin_lock, thus calling with GFP_ATOMIC */
 	new_cmd = kzalloc(total_sz, GFP_ATOMIC);
@@ -2662,6 +2688,7 @@ static int bnx2x_mcast_enqueue_cmd(struct bnx2x *bp,
 
 	switch (cmd) {
 	case BNX2X_MCAST_CMD_ADD:
+	case BNX2X_MCAST_CMD_SET:
 		cur_mac = (struct bnx2x_mcast_mac_elem *)
 			  ((u8 *)new_cmd + sizeof(*new_cmd));
 
@@ -2771,7 +2798,8 @@ static void bnx2x_mcast_set_one_rule_e2(struct bnx2x *bp,
 	u8 rx_tx_add_flag = bnx2x_mcast_get_rx_tx_flag(o);
 	int bin;
 
-	if ((cmd == BNX2X_MCAST_CMD_ADD) || (cmd == BNX2X_MCAST_CMD_RESTORE))
+	if ((cmd == BNX2X_MCAST_CMD_ADD) || (cmd == BNX2X_MCAST_CMD_RESTORE) ||
+	    (cmd == BNX2X_MCAST_CMD_SET_ADD))
 		rx_tx_add_flag |= ETH_MULTICAST_RULES_CMD_IS_ADD;
 
 	data->rules[idx].cmd_general_data |= rx_tx_add_flag;
@@ -2797,6 +2825,16 @@ static void bnx2x_mcast_set_one_rule_e2(struct bnx2x *bp,
 		bin = cfg_data->bin;
 		break;
 
+	case BNX2X_MCAST_CMD_SET_ADD:
+		bin = cfg_data->bin;
+		BIT_VEC64_SET_BIT(o->registry.aprox_match.vec, bin);
+		break;
+
+	case BNX2X_MCAST_CMD_SET_DEL:
+		bin = cfg_data->bin;
+		BIT_VEC64_CLEAR_BIT(o->registry.aprox_match.vec, bin);
+		break;
+
 	default:
 		BNX2X_ERR("Unknown command: %d\n", cmd);
 		return;
@@ -2932,6 +2970,102 @@ static inline void bnx2x_mcast_hdl_pending_restore_e2(struct bnx2x *bp,
 		cmd_pos->data.next_bin++;
 }
 
+static void
+bnx2x_mcast_hdl_pending_set_e2_convert(struct bnx2x *bp,
+				       struct bnx2x_mcast_obj *o,
+				       struct bnx2x_pending_mcast_cmd *cmd_pos)
+{
+	u64 cur[BNX2X_MCAST_VEC_SZ], req[BNX2X_MCAST_VEC_SZ];
+	struct bnx2x_mcast_mac_elem *pmac_pos, *pmac_pos_n;
+	struct bnx2x_mcast_bin_elem *p_item;
+	int i, cnt = 0, mac_cnt = 0;
+
+	memset(req, 0, sizeof(u64) * BNX2X_MCAST_VEC_SZ);
+	memcpy(cur, o->registry.aprox_match.vec,
+	       sizeof(u64) * BNX2X_MCAST_VEC_SZ);
+
+	/* Fill `current' with the required set of bins to configure */
+	list_for_each_entry_safe(pmac_pos, pmac_pos_n, &cmd_pos->data.macs_head,
+				 link) {
+		int bin = bnx2x_mcast_bin_from_mac(pmac_pos->mac);
+
+		DP(BNX2X_MSG_SP, "Set contains %pM mcast MAC\n",
+		   pmac_pos->mac);
+
+		BIT_VEC64_SET_BIT(req, bin);
+		list_del(&pmac_pos->link);
+		mac_cnt++;
+	}
+
+	/* We no longer have use for the MACs; Need to re-use memory for
+	 * a list that will be used to configure bins.
+	 */
+	cmd_pos->set_convert = true;
+	p_item = (struct bnx2x_mcast_bin_elem *)(cmd_pos + 1);
+	INIT_LIST_HEAD(&cmd_pos->data.macs_head);
+
+	for (i = 0; i < BNX2X_MCAST_BINS_NUM; i++) {
+		bool b_current = !!BIT_VEC64_TEST_BIT(cur, i);
+		bool b_required = !!BIT_VEC64_TEST_BIT(req, i);
+
+		if (b_current == b_required)
+			continue;
+
+		p_item->bin = i;
+		p_item->type = b_required ? BNX2X_MCAST_CMD_SET_ADD
+					  : BNX2X_MCAST_CMD_SET_DEL;
+		list_add_tail(&p_item->link , &cmd_pos->data.macs_head);
+		p_item++;
+		cnt++;
+	}
+
+	/* We now definitely know how many commands are hiding here.
+	 * Also need to correct the disruption we've added to guarantee this
+	 * would be enqueued.
+	 */
+	o->total_pending_num -= (o->max_cmd_len + mac_cnt);
+	o->total_pending_num += cnt;
+
+	DP(BNX2X_MSG_SP, "o->total_pending_num=%d\n", o->total_pending_num);
+}
+
+static void
+bnx2x_mcast_hdl_pending_set_e2(struct bnx2x *bp,
+			       struct bnx2x_mcast_obj *o,
+			       struct bnx2x_pending_mcast_cmd *cmd_pos,
+			       int *cnt)
+{
+	union bnx2x_mcast_config_data cfg_data = {NULL};
+	struct bnx2x_mcast_bin_elem *p_item, *p_item_n;
+
+	/* This is actually a 2-part scheme - it starts by converting the MACs
+	 * into a list of bins to be added/removed, and correcting the numbers
+	 * on the object. this is now allowed, as we're now sure that all
+	 * previous configured requests have already applied.
+	 * The second part is actually adding rules for the newly introduced
+	 * entries [like all the rest of the hdl_pending functions].
+	 */
+	if (!cmd_pos->set_convert)
+		bnx2x_mcast_hdl_pending_set_e2_convert(bp, o, cmd_pos);
+
+	list_for_each_entry_safe(p_item, p_item_n, &cmd_pos->data.macs_head,
+				 link) {
+		cfg_data.bin = (u8)p_item->bin;
+		o->set_one_rule(bp, o, *cnt, &cfg_data, p_item->type);
+		(*cnt)++;
+
+		list_del(&p_item->link);
+
+		/* Break if we reached the maximum number of rules. */
+		if (*cnt >= o->max_cmd_len)
+			break;
+	}
+
+	/* if no more MACs to configure - we are done */
+	if (list_empty(&cmd_pos->data.macs_head))
+		cmd_pos->done = true;
+}
+
 static inline int bnx2x_mcast_handle_pending_cmds_e2(struct bnx2x *bp,
 				struct bnx2x_mcast_ramrod_params *p)
 {
@@ -2955,6 +3089,10 @@ static inline int bnx2x_mcast_handle_pending_cmds_e2(struct bnx2x *bp,
 							   &cnt);
 			break;
 
+		case BNX2X_MCAST_CMD_SET:
+			bnx2x_mcast_hdl_pending_set_e2(bp, o, cmd_pos, &cnt);
+			break;
+
 		default:
 			BNX2X_ERR("Unknown command: %d\n", cmd_pos->type);
 			return -EINVAL;
@@ -3095,6 +3233,19 @@ static int bnx2x_mcast_validate_e2(struct bnx2x *bp,
 		o->set_registry_size(o, reg_sz + p->mcast_list_len);
 		break;
 
+	case BNX2X_MCAST_CMD_SET:
+		/* We can only learn how many commands would actually be used
+		 * when this is being configured. So for now, simply guarantee
+		 * the command will be enqueued [to refrain from adding logic
+		 * that handles this and THEN learns it needs several ramrods].
+		 * Just like for ADD/Cont, the mcast_list_len might be an over
+		 * estimation; or even more so, since we don't take into
+		 * account the possibility of removal of existing bins.
+		 */
+		o->set_registry_size(o, reg_sz + p->mcast_list_len);
+		o->total_pending_num += o->max_cmd_len;
+		break;
+
 	default:
 		BNX2X_ERR("Unknown command: %d\n", cmd);
 		return -EINVAL;
@@ -3108,12 +3259,16 @@ static int bnx2x_mcast_validate_e2(struct bnx2x *bp,
 
 static void bnx2x_mcast_revert_e2(struct bnx2x *bp,
 				      struct bnx2x_mcast_ramrod_params *p,
-				      int old_num_bins)
+				  int old_num_bins,
+				  enum bnx2x_mcast_cmd cmd)
 {
 	struct bnx2x_mcast_obj *o = p->mcast_obj;
 
 	o->set_registry_size(o, old_num_bins);
 	o->total_pending_num -= p->mcast_list_len;
+
+	if (cmd == BNX2X_MCAST_CMD_SET)
+		o->total_pending_num -= o->max_cmd_len;
 }
 
 /**
@@ -3223,9 +3378,11 @@ static int bnx2x_mcast_setup_e2(struct bnx2x *bp,
 		bnx2x_mcast_refresh_registry_e2(bp, o);
 
 	/* If CLEAR_ONLY was requested - don't send a ramrod and clear
-	 * RAMROD_PENDING status immediately.
+	 * RAMROD_PENDING status immediately. due to the SET option, it's also
+	 * possible that after evaluating the differences there's no need for
+	 * a ramrod. In that case, we can skip it as well.
 	 */
-	if (test_bit(RAMROD_DRV_CLR_ONLY, &p->ramrod_flags)) {
+	if (test_bit(RAMROD_DRV_CLR_ONLY, &p->ramrod_flags) || !cnt) {
 		raw->clear_pending(raw);
 		return 0;
 	} else {
@@ -3253,6 +3410,11 @@ static int bnx2x_mcast_validate_e1h(struct bnx2x *bp,
 				    struct bnx2x_mcast_ramrod_params *p,
 				    enum bnx2x_mcast_cmd cmd)
 {
+	if (cmd == BNX2X_MCAST_CMD_SET) {
+		BNX2X_ERR("Can't use `set' command on e1h!\n");
+		return -EINVAL;
+	}
+
 	/* Mark, that there is a work to do */
 	if ((cmd == BNX2X_MCAST_CMD_DEL) || (cmd == BNX2X_MCAST_CMD_RESTORE))
 		p->mcast_list_len = 1;
@@ -3262,7 +3424,8 @@ static int bnx2x_mcast_validate_e1h(struct bnx2x *bp,
 
 static void bnx2x_mcast_revert_e1h(struct bnx2x *bp,
 				       struct bnx2x_mcast_ramrod_params *p,
-				       int old_num_bins)
+				       int old_num_bins,
+				       enum bnx2x_mcast_cmd cmd)
 {
 	/* Do nothing */
 }
@@ -3372,6 +3535,11 @@ static int bnx2x_mcast_validate_e1(struct bnx2x *bp,
 	struct bnx2x_mcast_obj *o = p->mcast_obj;
 	int reg_sz = o->get_registry_size(o);
 
+	if (cmd == BNX2X_MCAST_CMD_SET) {
+		BNX2X_ERR("Can't use `set' command on e1!\n");
+		return -EINVAL;
+	}
+
 	switch (cmd) {
 	/* DEL command deletes all currently configured MACs */
 	case BNX2X_MCAST_CMD_DEL:
@@ -3422,7 +3590,8 @@ static int bnx2x_mcast_validate_e1(struct bnx2x *bp,
 
 static void bnx2x_mcast_revert_e1(struct bnx2x *bp,
 				      struct bnx2x_mcast_ramrod_params *p,
-				      int old_num_macs)
+				   int old_num_macs,
+				   enum bnx2x_mcast_cmd cmd)
 {
 	struct bnx2x_mcast_obj *o = p->mcast_obj;
 
@@ -3816,7 +3985,7 @@ error_exit2:
 	r->clear_pending(r);
 
 error_exit1:
-	o->revert(bp, p, old_reg_size);
+	o->revert(bp, p, old_reg_size, cmd);
 
 	return rc;
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 4048fc5..0bf2fd4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -536,6 +536,15 @@ enum bnx2x_mcast_cmd {
 	BNX2X_MCAST_CMD_CONT,
 	BNX2X_MCAST_CMD_DEL,
 	BNX2X_MCAST_CMD_RESTORE,
+
+	/* Following this, multicast configuration should equal to approx
+	 * the set of MACs provided [i.e., remove all else].
+	 * The two sub-commands are used internally to decide whether a given
+	 * bin is to be added or removed
+	 */
+	BNX2X_MCAST_CMD_SET,
+	BNX2X_MCAST_CMD_SET_ADD,
+	BNX2X_MCAST_CMD_SET_DEL,
 };
 
 struct bnx2x_mcast_obj {
@@ -635,7 +644,8 @@ struct bnx2x_mcast_obj {
 	 */
 	void (*revert)(struct bnx2x *bp,
 		       struct bnx2x_mcast_ramrod_params *p,
-		       int old_num_bins);
+		       int old_num_bins,
+		       enum bnx2x_mcast_cmd cmd);
 
 	int (*get_registry_size)(struct bnx2x_mcast_obj *o);
 	void (*set_registry_size)(struct bnx2x_mcast_obj *o, int n);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 632daff..6c586b0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -573,17 +573,6 @@ int bnx2x_vf_mcast(struct bnx2x *bp, struct bnx2x_virtf *vf,
 		}
 	}
 
-	/* clear existing mcasts */
-	mcast.mcast_list_len = vf->mcast_list_len;
-	vf->mcast_list_len = mc_num;
-	rc = bnx2x_config_mcast(bp, &mcast, BNX2X_MCAST_CMD_DEL);
-	if (rc) {
-		BNX2X_ERR("Failed to remove multicasts\n");
-		kfree(mc);
-		return rc;
-	}
-
-	/* update mcast list on the ramrod params */
 	if (mc_num) {
 		INIT_LIST_HEAD(&mcast.mcast_list);
 		for (i = 0; i < mc_num; i++) {
@@ -594,12 +583,18 @@ int bnx2x_vf_mcast(struct bnx2x *bp, struct bnx2x_virtf *vf,
 
 		/* add new mcasts */
 		mcast.mcast_list_len = mc_num;
-		rc = bnx2x_config_mcast(bp, &mcast, BNX2X_MCAST_CMD_ADD);
+		rc = bnx2x_config_mcast(bp, &mcast, BNX2X_MCAST_CMD_SET);
 		if (rc)
-			BNX2X_ERR("Faled to add multicasts\n");
-		kfree(mc);
+			BNX2X_ERR("Faled to set multicasts\n");
+	} else {
+		/* clear existing mcasts */
+		rc = bnx2x_config_mcast(bp, &mcast, BNX2X_MCAST_CMD_DEL);
+		if (rc)
+			BNX2X_ERR("Failed to remove multicasts\n");
 	}
 
+	kfree(mc);
+
 	return rc;
 }
 
@@ -1583,7 +1578,6 @@ int bnx2x_iov_nic_init(struct bnx2x *bp)
 		 *  It needs to be initialized here so that it can be safely
 		 *  handled by a subsequent FLR flow.
 		 */
-		vf->mcast_list_len = 0;
 		bnx2x_init_mcast_obj(bp, &vf->mcast_obj, 0xFF,
 				     0xFF, 0xFF, 0xFF,
 				     bnx2x_vf_sp(bp, vf, mcast_rdata),
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index 670a581..7a6d406 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -195,7 +195,6 @@ struct bnx2x_virtf {
 	int leading_rss;
 
 	/* MCAST object */
-	int mcast_list_len;
 	struct bnx2x_mcast_obj		mcast_obj;
 
 	/* RSS configuration object */
-- 
1.9.3
