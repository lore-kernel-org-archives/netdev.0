From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 2/7] cxgb4: add common api support for configuring filters
Date: Mon, 12 Sep 2016 13:42:35 +0530
Message-ID: <05ef6c530086d3df5b8f4128141e3c12d3812105.1473667613.git.rahul.lakkireddy@chelsio.com>
References: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:20518 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932447AbcILIO4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 04:14:56 -0400
In-Reply-To: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
References: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable filters for non-offload configuration and add common api support
for setting and deleting filters in LE-TCAM region of the hardware.

IPv4 filters occupy one slot.  IPv6 filters occupy 4 slots and must
be on a 4-slot boundary.  IPv4 filters can not occupy a slot belonging
to IPv6 and the vice-versa is also true.

Filters are set and deleted asynchronously.  Use completion to wait
for reply from firmware in order to allow for synchronization if needed.

Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h        |   3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c | 424 +++++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c   |  33 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h    |  23 +-
 5 files changed, 453 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 053976f..fbd593a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1055,7 +1055,10 @@ struct filter_entry {
 
 	u32 pending:1;          /* filter action is pending firmware reply */
 	u32 smtidx:8;           /* Source MAC Table index for smac */
+	struct filter_ctx *ctx; /* Caller's completion hook */
 	struct l2t_entry *l2t;  /* Layer Two Table entry for dmac */
+	struct net_device *dev; /* Associated net device */
+	u32 tid;                /* This will store the actual tid */
 
 	/* The filter itself.  Most of this is a straight copy of information
 	 * provided by the extended ioctl().  Some fields are translated to
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
index 2e86902..490bd94 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
@@ -33,10 +33,138 @@
  */
 
 #include "cxgb4.h"
+#include "t4_regs.h"
 #include "l2t.h"
 #include "t4fw_api.h"
 #include "cxgb4_filter.h"
 
+/* Validate filter spec against configuration done on the card.
+ */
+static int validate_filter(struct net_device *dev,
+			   struct ch_filter_specification *fs)
+{
+	struct adapter *adapter = netdev2adap(dev);
+	u32 fconf, iconf;
+
+	/* Check for unconfigured fields being used. */
+	fconf = adapter->params.tp.vlan_pri_map;
+	iconf = adapter->params.tp.ingress_config;
+
+	#define S(_field) \
+		(fs->val._field || fs->mask._field)
+	#define U(_mask, _field) \
+		(!(fconf & (_mask)) && S(_field))
+
+	if (U(FCOE_F, fcoe) || U(PORT_F, iport) || U(TOS_F, tos) ||
+	    U(ETHERTYPE_F, ethtype) || U(MACMATCH_F, macidx) ||
+	    U(MPSHITTYPE_F, matchtype) || U(FRAGMENTATION_F, frag) ||
+	    U(PROTOCOL_F, proto) ||
+	    U(VNIC_ID_F, pfvf_vld) ||
+	    U(VNIC_ID_F, ovlan_vld) ||
+	    U(VLAN_F, ivlan_vld))
+		return -EOPNOTSUPP;
+
+	/* T4 inconveniently uses the same FT_VNIC_ID_W bits for both the Outer
+	 * VLAN Tag and PF/VF/VFvld fields based on VNIC_F being set
+	 * in TP_INGRESS_CONFIG.  Hense the somewhat crazy checks
+	 * below.  Additionally, since the T4 firmware interface also
+	 * carries that overlap, we need to translate any PF/VF
+	 * specification into that internal format below.
+	 */
+	if (S(pfvf_vld) && S(ovlan_vld))
+		return -EOPNOTSUPP;
+	if ((S(pfvf_vld) && !(iconf & VNIC_F)) ||
+	    (S(ovlan_vld) && (iconf & VNIC_F)))
+		return -EOPNOTSUPP;
+	if (fs->val.pf > 0x7 || fs->val.vf > 0x7f)
+		return -ERANGE;
+	fs->mask.pf &= 0x7;
+	fs->mask.vf &= 0x7f;
+
+	#undef S
+	#undef U
+
+	/* If the user is requesting that the filter action loop
+	 * matching packets back out one of our ports, make sure that
+	 * the egress port is in range.
+	 */
+	if (fs->action == FILTER_SWITCH &&
+	    fs->eport >= adapter->params.nports)
+		return -ERANGE;
+
+	/* Don't allow various trivially obvious bogus out-of-range values... */
+	if (fs->val.iport >= adapter->params.nports)
+		return -ERANGE;
+
+	/* T4 doesn't support removing VLAN Tags for loop back filters. */
+	if (is_t4(adapter->params.chip) &&
+	    fs->action == FILTER_SWITCH &&
+	    (fs->newvlan == VLAN_REMOVE ||
+	     fs->newvlan == VLAN_REWRITE))
+		return -EOPNOTSUPP;
+
+	return 0;
+}
+
+static unsigned int get_filter_steerq(struct net_device *dev,
+				      struct ch_filter_specification *fs)
+{
+	struct adapter *adapter = netdev2adap(dev);
+	unsigned int iq;
+
+	/* If the user has requested steering matching Ingress Packets
+	 * to a specific Queue Set, we need to make sure it's in range
+	 * for the port and map that into the Absolute Queue ID of the
+	 * Queue Set's Response Queue.
+	 */
+	if (!fs->dirsteer) {
+		if (fs->iq)
+			return -EINVAL;
+		iq = 0;
+	} else {
+		struct port_info *pi = netdev_priv(dev);
+
+		/* If the iq id is greater than the number of qsets,
+		 * then assume it is an absolute qid.
+		 */
+		if (fs->iq < pi->nqsets)
+			iq = adapter->sge.ethrxq[pi->first_qset +
+						 fs->iq].rspq.abs_id;
+		else
+			iq = fs->iq;
+	}
+
+	return iq;
+}
+
+static int cxgb4_set_ftid(struct tid_info *t, int fidx, int family)
+{
+	spin_lock_bh(&t->ftid_lock);
+
+	if (test_bit(fidx, t->ftid_bmap)) {
+		spin_unlock_bh(&t->ftid_lock);
+		return -EBUSY;
+	}
+
+	if (family == PF_INET)
+		__set_bit(fidx, t->ftid_bmap);
+	else
+		bitmap_allocate_region(t->ftid_bmap, fidx, 2);
+
+	spin_unlock_bh(&t->ftid_lock);
+	return 0;
+}
+
+static void cxgb4_clear_ftid(struct tid_info *t, int fidx, int family)
+{
+	spin_lock_bh(&t->ftid_lock);
+	if (family == PF_INET)
+		__clear_bit(fidx, t->ftid_bmap);
+	else
+		bitmap_release_region(t->ftid_bmap, fidx, 2);
+	spin_unlock_bh(&t->ftid_lock);
+}
+
 /* Delete the filter at a specified index.
  */
 static int del_filter_wr(struct adapter *adapter, int fidx)
@@ -44,17 +172,16 @@ static int del_filter_wr(struct adapter *adapter, int fidx)
 	struct filter_entry *f = &adapter->tids.ftid_tab[fidx];
 	struct sk_buff *skb;
 	struct fw_filter_wr *fwr;
-	unsigned int len, ftid;
+	unsigned int len;
 
 	len = sizeof(*fwr);
-	ftid = adapter->tids.ftid_base + fidx;
 
 	skb = alloc_skb(len, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
 
 	fwr = (struct fw_filter_wr *)__skb_put(skb, len);
-	t4_mk_filtdelwr(ftid, fwr, adapter->sge.fw_evtq.abs_id);
+	t4_mk_filtdelwr(f->tid, fwr, adapter->sge.fw_evtq.abs_id);
 
 	/* Mark the filter as "pending" and ship off the Filter Work Request.
 	 * When we get the Work Request Reply we'll clear the pending status.
@@ -75,7 +202,6 @@ int set_filter_wr(struct adapter *adapter, int fidx)
 	struct filter_entry *f = &adapter->tids.ftid_tab[fidx];
 	struct sk_buff *skb;
 	struct fw_filter_wr *fwr;
-	unsigned int ftid;
 
 	skb = alloc_skb(sizeof(*fwr), GFP_KERNEL);
 	if (!skb)
@@ -95,8 +221,6 @@ int set_filter_wr(struct adapter *adapter, int fidx)
 		}
 	}
 
-	ftid = adapter->tids.ftid_base + fidx;
-
 	fwr = (struct fw_filter_wr *)__skb_put(skb, sizeof(*fwr));
 	memset(fwr, 0, sizeof(*fwr));
 
@@ -111,7 +235,7 @@ int set_filter_wr(struct adapter *adapter, int fidx)
 	fwr->op_pkd = htonl(FW_WR_OP_V(FW_FILTER_WR));
 	fwr->len16_pkd = htonl(FW_WR_LEN16_V(sizeof(*fwr) / 16));
 	fwr->tid_to_iq =
-		htonl(FW_FILTER_WR_TID_V(ftid) |
+		htonl(FW_FILTER_WR_TID_V(f->tid) |
 		      FW_FILTER_WR_RQTYPE_V(f->fs.type) |
 		      FW_FILTER_WR_NOREPLY_V(0) |
 		      FW_FILTER_WR_IQ_V(f->fs.iq));
@@ -237,34 +361,300 @@ void clear_filter(struct adapter *adap, struct filter_entry *f)
 	memset(f, 0, sizeof(*f));
 }
 
+void clear_all_filters(struct adapter *adapter)
+{
+	unsigned int i;
+
+	if (adapter->tids.ftid_tab) {
+		struct filter_entry *f = &adapter->tids.ftid_tab[0];
+		unsigned int max_ftid = adapter->tids.nftids +
+					adapter->tids.nsftids;
+
+		for (i = 0; i < max_ftid; i++, f++)
+			if (f->valid || f->pending)
+				clear_filter(adapter, f);
+	}
+}
+
+/* Fill up default masks for set match fields. */
+static void fill_default_mask(struct ch_filter_specification *fs)
+{
+	unsigned int i;
+	unsigned int lip = 0, lip_mask = 0;
+	unsigned int fip = 0, fip_mask = 0;
+
+	if (fs->val.iport && !fs->mask.iport)
+		fs->mask.iport |= ~0;
+	if (fs->val.fcoe && !fs->mask.fcoe)
+		fs->mask.fcoe |= ~0;
+	if (fs->val.matchtype && !fs->mask.matchtype)
+		fs->mask.matchtype |= ~0;
+	if (fs->val.macidx && !fs->mask.macidx)
+		fs->mask.macidx |= ~0;
+	if (fs->val.ethtype && !fs->mask.ethtype)
+		fs->mask.ethtype |= ~0;
+	if (fs->val.ivlan && !fs->mask.ivlan)
+		fs->mask.ivlan |= ~0;
+	if (fs->val.ovlan && !fs->mask.ovlan)
+		fs->mask.ovlan |= ~0;
+	if (fs->val.frag && !fs->mask.frag)
+		fs->mask.frag |= ~0;
+	if (fs->val.tos && !fs->mask.tos)
+		fs->mask.tos |= ~0;
+	if (fs->val.proto && !fs->mask.proto)
+		fs->mask.proto |= ~0;
+
+	for (i = 0; i < ARRAY_SIZE(fs->val.lip); i++) {
+		lip |= fs->val.lip[i];
+		lip_mask |= fs->mask.lip[i];
+		fip |= fs->val.fip[i];
+		fip_mask |= fs->mask.fip[i];
+	}
+
+	if (lip && !lip_mask)
+		memset(fs->mask.lip, ~0, sizeof(fs->mask.lip));
+
+	if (fip && !fip_mask)
+		memset(fs->mask.fip, ~0, sizeof(fs->mask.lip));
+
+	if (fs->val.lport && !fs->mask.lport)
+		fs->mask.lport = ~0;
+	if (fs->val.fport && !fs->mask.fport)
+		fs->mask.fport = ~0;
+}
+
+/* Check a Chelsio Filter Request for validity, convert it into our internal
+ * format and send it to the hardware.  Return 0 on success, an error number
+ * otherwise.  We attach any provided filter operation context to the internal
+ * filter specification in order to facilitate signaling completion of the
+ * operation.
+ */
+int cxgb4_set_filter(struct net_device *dev, int filter_id,
+		     struct ch_filter_specification *fs,
+		     struct filter_ctx *ctx)
+{
+	struct adapter *adapter = netdev2adap(dev);
+	struct filter_entry *f;
+	u32 iconf;
+	unsigned int fidx, iq;
+	unsigned int max_fidx;
+	int ret;
+
+	max_fidx = adapter->tids.nftids;
+	if ((filter_id != (max_fidx + adapter->tids.nsftids - 1)) &&
+	    (filter_id >= max_fidx))
+		return -E2BIG;
+
+	fill_default_mask(fs);
+
+	ret = validate_filter(dev, fs);
+	if (ret)
+		return ret;
+
+	iq = get_filter_steerq(dev, fs);
+	if (iq < 0)
+		return iq;
+
+	/* IPv6 filters occupy four slots and must be aligned on
+	 * four-slot boundaries.  IPv4 filters only occupy a single
+	 * slot and have no alignment requirements but writing a new
+	 * IPv4 filter into the middle of an existing IPv6 filter
+	 * requires clearing the old IPv6 filter and hence we prevent
+	 * insertion.
+	 */
+	if (fs->type == 0) { /* IPv4 */
+		/* If our IPv4 filter isn't being written to a
+		 * multiple of four filter index and there's an IPv6
+		 * filter at the multiple of 4 base slot, then we
+		 * prevent insertion.
+		 */
+		fidx = filter_id & ~0x3;
+		if (fidx != filter_id &&
+		    adapter->tids.ftid_tab[fidx].fs.type) {
+			f = &adapter->tids.ftid_tab[fidx];
+			if (f->valid) {
+				dev_err(adapter->pdev_dev,
+					"Invalid location. IPv6 requires 4 slots and is occupying slots %u to %u\n",
+					fidx, fidx + 3);
+				return -EINVAL;
+			}
+		}
+	} else { /* IPv6 */
+		/* Ensure that the IPv6 filter is aligned on a
+		 * multiple of 4 boundary.
+		 */
+		if (filter_id & 0x3) {
+			dev_err(adapter->pdev_dev,
+				"Invalid location. IPv6 must be aligned on a 4-slot boundary\n");
+			return -EINVAL;
+		}
+
+		/* Check all except the base overlapping IPv4 filter slots. */
+		for (fidx = filter_id + 1; fidx < filter_id + 4; fidx++) {
+			f = &adapter->tids.ftid_tab[fidx];
+			if (f->valid) {
+				dev_err(adapter->pdev_dev,
+					"Invalid location.  IPv6 requires 4 slots and an IPv4 filter exists at %u\n",
+					fidx);
+				return -EINVAL;
+			}
+		}
+	}
+
+	/* Check to make sure that provided filter index is not
+	 * already in use by someone else
+	 */
+	f = &adapter->tids.ftid_tab[filter_id];
+	if (f->valid)
+		return -EBUSY;
+
+	fidx = filter_id + adapter->tids.ftid_base;
+	ret = cxgb4_set_ftid(&adapter->tids, filter_id,
+			     fs->type ? PF_INET6 : PF_INET);
+	if (ret)
+		return ret;
+
+	/* Check to make sure the filter requested is writable ... */
+	ret = writable_filter(f);
+	if (ret) {
+		/* Clear the bits we have set above */
+		cxgb4_clear_ftid(&adapter->tids, filter_id,
+				 fs->type ? PF_INET6 : PF_INET);
+		return ret;
+	}
+
+	/* Clear out any old resources being used by the filter before
+	 * we start constructing the new filter.
+	 */
+	if (f->valid)
+		clear_filter(adapter, f);
+
+	/* Convert the filter specification into our internal format.
+	 * We copy the PF/VF specification into the Outer VLAN field
+	 * here so the rest of the code -- including the interface to
+	 * the firmware -- doesn't have to constantly do these checks.
+	 */
+	f->fs = *fs;
+	f->fs.iq = iq;
+	f->dev = dev;
+
+	iconf = adapter->params.tp.ingress_config;
+	if (iconf & VNIC_F) {
+		f->fs.val.ovlan = (fs->val.pf << 13) | fs->val.vf;
+		f->fs.mask.ovlan = (fs->mask.pf << 13) | fs->mask.vf;
+		f->fs.val.ovlan_vld = fs->val.pfvf_vld;
+		f->fs.mask.ovlan_vld = fs->mask.pfvf_vld;
+	}
+
+	/* Attempt to set the filter.  If we don't succeed, we clear
+	 * it and return the failure.
+	 */
+	f->ctx = ctx;
+	f->tid = fidx; /* Save the actual tid */
+	ret = set_filter_wr(adapter, filter_id);
+	if (ret) {
+		cxgb4_clear_ftid(&adapter->tids, filter_id,
+				 fs->type ? PF_INET6 : PF_INET);
+		clear_filter(adapter, f);
+	}
+
+	return ret;
+}
+
+/* Check a delete filter request for validity and send it to the hardware.
+ * Return 0 on success, an error number otherwise.  We attach any provided
+ * filter operation context to the internal filter specification in order to
+ * facilitate signaling completion of the operation.
+ */
+int cxgb4_del_filter(struct net_device *dev, int filter_id,
+		     struct filter_ctx *ctx)
+{
+	struct adapter *adapter = netdev2adap(dev);
+	struct filter_entry *f;
+	unsigned int max_fidx;
+	int ret = 0;
+
+	max_fidx = adapter->tids.nftids;
+	if ((filter_id != (max_fidx + adapter->tids.nsftids - 1)) &&
+	    (filter_id >= max_fidx))
+		return -E2BIG;
+
+	f = &adapter->tids.ftid_tab[filter_id];
+	ret = writable_filter(f);
+	if (ret)
+		return ret;
+
+	if (f->valid) {
+		f->ctx = ctx;
+		cxgb4_clear_ftid(&adapter->tids, filter_id,
+				 f->fs.type ? PF_INET6 : PF_INET);
+		return del_filter_wr(adapter, filter_id);
+	}
+
+	/* If the caller has passed in a Completion Context then we need to
+	 * mark it as a successful completion so they don't stall waiting
+	 * for it.
+	 */
+	if (ctx) {
+		ctx->result = 0;
+		complete(&ctx->completion);
+	}
+	return ret;
+}
+
 /* Handle a filter write/deletion reply.
  */
 void filter_rpl(struct adapter *adap, const struct cpl_set_tcb_rpl *rpl)
 {
-	unsigned int idx = GET_TID(rpl);
-	unsigned int nidx = idx - adap->tids.ftid_base;
-	unsigned int ret;
-	struct filter_entry *f;
+	unsigned int tid = GET_TID(rpl);
+	struct filter_entry *f = NULL;
+	unsigned int max_fidx;
+	int idx;
 
-	if (idx >= adap->tids.ftid_base && nidx <
-	   (adap->tids.nftids + adap->tids.nsftids)) {
-		idx = nidx;
-		ret = TCB_COOKIE_G(rpl->cookie);
+	max_fidx = adap->tids.nftids + adap->tids.nsftids;
+	/* Get the corresponding filter entry for this tid */
+	if (adap->tids.ftid_tab) {
+		/* Check this in normal filter region */
+		idx = tid - adap->tids.ftid_base;
+		if (idx >= max_fidx)
+			return;
 		f = &adap->tids.ftid_tab[idx];
+		if (f->tid != tid)
+			return;
+	}
+
+	/* We found the filter entry for this tid */
+	if (f) {
+		unsigned int ret = TCB_COOKIE_G(rpl->cookie);
+		struct filter_ctx *ctx;
+
+		/* Pull off any filter operation context attached to the
+		 * filter.
+		 */
+		ctx = f->ctx;
+		f->ctx = NULL;
 
 		if (ret == FW_FILTER_WR_FLT_DELETED) {
 			/* Clear the filter when we get confirmation from the
 			 * hardware that the filter has been deleted.
 			 */
 			clear_filter(adap, f);
+			if (ctx)
+				ctx->result = 0;
 		} else if (ret == FW_FILTER_WR_SMT_TBL_FULL) {
 			dev_err(adap->pdev_dev, "filter %u setup failed due to full SMT\n",
 				idx);
 			clear_filter(adap, f);
+			if (ctx)
+				ctx->result = -ENOMEM;
 		} else if (ret == FW_FILTER_WR_FLT_ADDED) {
 			f->smtidx = (be64_to_cpu(rpl->oldval) >> 24) & 0xff;
 			f->pending = 0;  /* asynchronous setup completed */
 			f->valid = 1;
+			if (ctx) {
+				ctx->result = 0;
+				ctx->tid = idx;
+			}
 		} else {
 			/* Something went wrong.  Issue a warning about the
 			 * problem and clear everything out.
@@ -272,6 +662,10 @@ void filter_rpl(struct adapter *adap, const struct cpl_set_tcb_rpl *rpl)
 			dev_err(adap->pdev_dev, "filter %u setup failed with error %u\n",
 				idx, ret);
 			clear_filter(adap, f);
+			if (ctx)
+				ctx->result = -EINVAL;
 		}
+		if (ctx)
+			complete(&ctx->completion);
 	}
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
index f6bd0bf..23742cb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
@@ -44,4 +44,5 @@ int set_filter_wr(struct adapter *adapter, int fidx);
 int delete_filter(struct adapter *adapter, unsigned int fidx);
 
 int writable_filter(struct filter_entry *f);
+void clear_all_filters(struct adapter *adapter);
 #endif /* __CXGB4_FILTER_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 00f4d7f..af07f9d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1498,17 +1498,20 @@ static int tid_init(struct tid_info *t)
 {
 	size_t size;
 	unsigned int stid_bmap_size;
+	unsigned int ftid_bmap_size;
 	unsigned int natids = t->natids;
+	unsigned int max_ftids = t->nftids + t->nsftids;
 	struct adapter *adap = container_of(t, struct adapter, tids);
 
 	stid_bmap_size = BITS_TO_LONGS(t->nstids + t->nsftids);
+	ftid_bmap_size = BITS_TO_LONGS(t->nftids);
 	size = t->ntids * sizeof(*t->tid_tab) +
 	       natids * sizeof(*t->atid_tab) +
 	       t->nstids * sizeof(*t->stid_tab) +
 	       t->nsftids * sizeof(*t->stid_tab) +
 	       stid_bmap_size * sizeof(long) +
-	       t->nftids * sizeof(*t->ftid_tab) +
-	       t->nsftids * sizeof(*t->ftid_tab);
+	       max_ftids * sizeof(*t->ftid_tab) +
+	       ftid_bmap_size * sizeof(long);
 
 	t->tid_tab = t4_alloc_mem(size);
 	if (!t->tid_tab)
@@ -1518,8 +1521,10 @@ static int tid_init(struct tid_info *t)
 	t->stid_tab = (struct serv_entry *)&t->atid_tab[natids];
 	t->stid_bmap = (unsigned long *)&t->stid_tab[t->nstids + t->nsftids];
 	t->ftid_tab = (struct filter_entry *)&t->stid_bmap[stid_bmap_size];
+	t->ftid_bmap = (unsigned long *)&t->ftid_tab[max_ftids];
 	spin_lock_init(&t->stid_lock);
 	spin_lock_init(&t->atid_lock);
+	spin_lock_init(&t->ftid_lock);
 
 	t->stids_in_use = 0;
 	t->sftids_in_use = 0;
@@ -1534,12 +1539,16 @@ static int tid_init(struct tid_info *t)
 			t->atid_tab[natids - 1].next = &t->atid_tab[natids];
 		t->afree = t->atid_tab;
 	}
-	bitmap_zero(t->stid_bmap, t->nstids + t->nsftids);
-	/* Reserve stid 0 for T4/T5 adapters */
-	if (!t->stid_base &&
-	    (CHELSIO_CHIP_VERSION(adap->params.chip) <= CHELSIO_T5))
-		__set_bit(0, t->stid_bmap);
 
+	if (is_offload(adap)) {
+		bitmap_zero(t->stid_bmap, t->nstids + t->nsftids);
+		/* Reserve stid 0 for T4/T5 adapters */
+		if (!t->stid_base &&
+		    (CHELSIO_CHIP_VERSION(adap->params.chip) <= CHELSIO_T5))
+			__set_bit(0, t->stid_bmap);
+	}
+
+	bitmap_zero(t->ftid_bmap, t->nftids);
 	return 0;
 }
 
@@ -5200,7 +5209,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 				 i);
 	}
 
-	if (is_offload(adapter) && tid_init(&adapter->tids) < 0) {
+	if (tid_init(&adapter->tids) < 0) {
 		dev_warn(&pdev->dev, "could not allocate TID table, "
 			 "continuing\n");
 		adapter->params.offload = 0;
@@ -5383,13 +5392,7 @@ static void remove_one(struct pci_dev *pdev)
 		/* If we allocated filters, free up state associated with any
 		 * valid filters ...
 		 */
-		if (adapter->tids.ftid_tab) {
-			struct filter_entry *f = &adapter->tids.ftid_tab[0];
-			for (i = 0; i < (adapter->tids.nftids +
-					adapter->tids.nsftids); i++, f++)
-				if (f->valid)
-					clear_filter(adapter, f);
-		}
+		clear_all_filters(adapter);
 
 		if (adapter->flags & FULL_INIT_DONE)
 			cxgb_down(adapter);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index ab40372..7efb2d0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2016 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
@@ -104,6 +104,7 @@ struct tid_info {
 	unsigned int atid_base;
 
 	struct filter_entry *ftid_tab;
+	unsigned long *ftid_bmap;
 	unsigned int nftids;
 	unsigned int ftid_base;
 	unsigned int aftid_base;
@@ -124,6 +125,8 @@ struct tid_info {
 	atomic_t tids_in_use;
 	/* TIDs in the HASH */
 	atomic_t hash_tids_in_use;
+	/* lock for setting/clearing filter bitmap */
+	spinlock_t ftid_lock;
 };
 
 static inline void *lookup_tid(const struct tid_info *t, unsigned int tid)
@@ -183,6 +186,24 @@ int cxgb4_create_server_filter(const struct net_device *dev, unsigned int stid,
 int cxgb4_remove_server_filter(const struct net_device *dev, unsigned int stid,
 			       unsigned int queue, bool ipv6);
 
+/* Filter operation context to allow callers of cxgb4_set_filter() and
+ * cxgb4_del_filter() to wait for an asynchronous completion.
+ */
+struct filter_ctx {
+	struct completion completion;	/* completion rendezvous */
+	void *closure;			/* caller's opaque information */
+	int result;			/* result of operation */
+	u32 tid;			/* to store tid */
+};
+
+struct ch_filter_specification;
+
+int cxgb4_set_filter(struct net_device *dev, int filter_id,
+		     struct ch_filter_specification *fs,
+		     struct filter_ctx *ctx);
+int cxgb4_del_filter(struct net_device *dev, int filter_id,
+		     struct filter_ctx *ctx);
+
 static inline void set_wr_txq(struct sk_buff *skb, int prio, int queue)
 {
 	skb_set_queue_mapping(skb, (queue << 1) | prio);
-- 
2.5.3
