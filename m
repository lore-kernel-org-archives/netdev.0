From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH RFC 3/6] net/ncsi: Manage NCSI device
Date: Mon,  9 Nov 2015 11:10:03 +1100
Message-ID: <1447027806-4744-4-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, davem@davemloft.net,
	sergei.shtylyov@cogentembedded.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:38044 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbbKIALQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 19:11:16 -0500
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Mon, 9 Nov 2015 10:11:13 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 63AC32BB0052
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2015 11:11:09 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tA90Asrr32899290
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:11:03 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tA90AZ3G016904
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:10:36 +1100
In-Reply-To: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To the network interface that can run in NCSI mode on BMC side,
there might have multiple NCSI packages/channels. The available
NCSI packages/channels (topology) needs to be probed and one
channel should be selected as active one from the available
channels before the network interface on BMC side starts to
work. On the other hand, the active NCSI package/channel should
be disabled when the network interface on BMC is going to be
brought down. Besides, the active channel needs fail over to
another one when BMC receives AEN telling that current active
channel isn't working any more.

This introduces various state to NCSI device (struct ncsi_dev_priv)
to fulfil above tasks.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 include/net/ncsi.h     |  27 +++
 net/ncsi/internal.h    |   1 +
 net/ncsi/ncsi-aen.c    |   9 +-
 net/ncsi/ncsi-manage.c | 536 +++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 570 insertions(+), 3 deletions(-)

diff --git a/include/net/ncsi.h b/include/net/ncsi.h
index 2735f19..4d49c41 100644
--- a/include/net/ncsi.h
+++ b/include/net/ncsi.h
@@ -27,4 +27,31 @@ struct ncsi_dev {
 	void			(*nd_handler)(struct ncsi_dev *ndev);
 };
 
+#ifdef CONFIG_NET_NCSI
+struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
+				   void (*notifier)(struct ncsi_dev *nd));
+int ncsi_start_dev(struct ncsi_dev *nd);
+int ncsi_stop_dev(struct ncsi_dev *nd);
+void ncsi_unregister_dev(struct ncsi_dev *nd);
+#else /* !CONFIG_NET_NCSI */
+static inline struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
+						 void (*notifier)(struct ncsi_dev *nd))
+{
+	return NULL;
+}
+
+static inline int ncsi_start_dev(struct ncsi_dev *nd)
+{
+	return -ENOTTY;
+}
+
+static inline int ncsi_stop_dev(struct ncsi_dev *nd)
+{
+	return -ENOTTY;
+}
+
+void inline ncsi_unregister_dev(struct ncsi_dev *nd)
+{
+}
+#endif /* CONFIG_NET_NCSI */
 #endif /* __NET_NCSI_H */
diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index 41e91d8..e9091e8 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -302,6 +302,7 @@ void ncsi_find_package_and_channel(struct ncsi_dev_priv *ndp,
 struct ncsi_req *ncsi_alloc_req(struct ncsi_dev_priv *ndp);
 void ncsi_free_req(struct ncsi_req *nr, bool check, bool timeout);
 struct ncsi_dev *ncsi_find_dev(struct net_device *dev);
+int ncsi_config_dev(struct ncsi_dev *nd);
 
 /* Packet handlers */
 int ncsi_xmit_cmd(struct ncsi_cmd_arg *nca);
diff --git a/net/ncsi/ncsi-aen.c b/net/ncsi/ncsi-aen.c
index 9078c3b..e1f686f 100644
--- a/net/ncsi/ncsi-aen.c
+++ b/net/ncsi/ncsi-aen.c
@@ -60,6 +60,7 @@ static int ncsi_validate_aen_pkt(struct ncsi_aen_pkt_hdr *h,
 static int ncsi_aen_handler_lsc(struct ncsi_dev_priv *ndp,
 				struct ncsi_aen_pkt_hdr *h)
 {
+	struct ncsi_dev *nd = &ndp->ndp_ndev;
 	struct ncsi_aen_lsc_pkt *lsc;
 	struct ncsi_channel *nc;
 	struct ncsi_channel_mode *ncm;
@@ -88,7 +89,7 @@ static int ncsi_aen_handler_lsc(struct ncsi_dev_priv *ndp,
 	 * we have to choose another channel to be active one.
 	 */
 	ndp->ndp_flags |= NCSI_DEV_FLAG_CHANGE_ACTIVE;
-	/* FIXME: Stop active channel and choose another one */
+	ncsi_stop_dev(nd);
 
 	return 0;
 }
@@ -96,6 +97,7 @@ static int ncsi_aen_handler_lsc(struct ncsi_dev_priv *ndp,
 static int ncsi_aen_handler_cr(struct ncsi_dev_priv *ndp,
 			       struct ncsi_aen_pkt_hdr *h)
 {
+	struct ncsi_dev *nd = &ndp->ndp_ndev;
 	struct ncsi_channel *nc;
 	int ret;
 
@@ -113,7 +115,7 @@ static int ncsi_aen_handler_cr(struct ncsi_dev_priv *ndp,
 	    ndp->ndp_active_channel != nc)
 		return 0;
 
-	/* FIXME: Reconfigure active channel */
+	ncsi_config_dev(nd);
 
 	return 0;
 }
@@ -121,6 +123,7 @@ static int ncsi_aen_handler_cr(struct ncsi_dev_priv *ndp,
 static int ncsi_aen_handler_hncdsc(struct ncsi_dev_priv *ndp,
 				   struct ncsi_aen_pkt_hdr *h)
 {
+	struct ncsi_dev *nd = &ndp->ndp_ndev;
 	struct ncsi_channel *nc;
 	struct ncsi_channel_mode *ncm;
 	struct ncsi_aen_hncdsc_pkt *hncdsc;
@@ -149,7 +152,7 @@ static int ncsi_aen_handler_hncdsc(struct ncsi_dev_priv *ndp,
 	 * is down on the active channel.
 	 */
 	ndp->ndp_flags |= NCSI_DEV_FLAG_CHANGE_ACTIVE;
-	/* FIXME: Stop and choose another channel as active one */
+	ncsi_stop_dev(nd);
 
 	return 0;
 }
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index eb23222..50c3137 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -18,6 +18,7 @@
 #include <net/net_namespace.h>
 #include <net/sock.h>
 
+#include "ncsi-pkt.h"
 #include "internal.h"
 
 LIST_HEAD(ncsi_dev_list);
@@ -345,6 +346,8 @@ void ncsi_free_req(struct ncsi_req *nr, bool check, bool timeout)
 	nr->nr_used = false;
 	spin_unlock(&ndp->ndp_req_lock);
 
+	if (check && cmd && atomic_dec_return(&ndp->ndp_pending_reqs) == 0)
+		schedule_work(&ndp->ndp_work);
 	/* Release command and response */
 	consume_skb(cmd);
 	consume_skb(rsp);
@@ -361,3 +364,536 @@ struct ncsi_dev *ncsi_find_dev(struct net_device *dev)
 
 	return NULL;
 }
+
+static int ncsi_select_active_channel(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+
+	/* For now, we simply choose the first valid channel as active one.
+	 * There might be more factors, like the channel's capacity, can
+	 * be considered to pick the active channel in future.
+	 */
+	NCSI_FOR_EACH_PACKAGE(ndp, np) {
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			ndp->ndp_active_package = np;
+			ndp->ndp_active_channel = nc;
+			return 0;
+		}
+	}
+
+	return -ENXIO;
+}
+
+static void ncsi_dev_config(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_dev *nd = &ndp->ndp_ndev;
+	struct net_device *dev = nd->nd_dev;
+	struct ncsi_package *np = ndp->ndp_active_package;
+	struct ncsi_channel *nc = ndp->ndp_active_channel;
+	struct ncsi_cmd_arg nca;
+	unsigned char index;
+	int ret;
+
+	nca.nca_ndp = ndp;
+
+	/* When we're reconfiguring the active channel, the active package
+	 * should be selected and the old setting on the active channel
+	 * should be cleared.
+	 */
+	switch (nd->nd_state) {
+	case ncsi_dev_state_config:
+	case ncsi_dev_state_config_sp:
+		atomic_set(&ndp->ndp_pending_reqs, 1);
+
+		/* Select the specific package */
+		nca.nca_type = NCSI_PKT_CMD_SP;
+		nca.nca_bytes[0] = 1;
+		nca.nca_package = np->np_id;
+		nca.nca_channel = 0x1f;
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		nd->nd_state = ncsi_dev_state_config_cis;
+		break;
+	case ncsi_dev_state_config_cis:
+		atomic_set(&ndp->ndp_pending_reqs, 1);
+
+		/* Clear initial state */
+		nca.nca_type = NCSI_PKT_CMD_CIS;
+		nca.nca_package = np->np_id;
+		nca.nca_channel = nc->nc_id;
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		nd->nd_state = ncsi_dev_state_config_sma;
+		break;
+	case ncsi_dev_state_config_sma:
+	case ncsi_dev_state_config_ebf:
+	case ncsi_dev_state_config_ecnt:
+	case ncsi_dev_state_config_ec:
+	case ncsi_dev_state_config_gls:
+		atomic_set(&ndp->ndp_pending_reqs, 1);
+
+		nca.nca_package = np->np_id;
+		nca.nca_channel = nc->nc_id;
+
+		/* Use first entry in unicast filter table. Note that
+		 * the MAC filter table starts from entry 1 instead of
+		 * 0.
+		 */
+		if (nd->nd_state == ncsi_dev_state_config_sma) {
+			nca.nca_type = NCSI_PKT_CMD_SMA;
+			for (index = 0; index < 6; index++)
+				nca.nca_bytes[index] = dev->dev_addr[index];
+			nca.nca_bytes[6] = 0x1;
+			nca.nca_bytes[7] = 0x1;
+			nd->nd_state = ncsi_dev_state_config_ebf;
+		} else if (nd->nd_state == ncsi_dev_state_config_ebf) {
+			nca.nca_type = NCSI_PKT_CMD_EBF;
+			nca.nca_dwords[0] = nc->nc_caps[NCSI_CAP_BC].ncc_cap;
+			nd->nd_state = ncsi_dev_state_config_ecnt;
+		} else if (nd->nd_state == ncsi_dev_state_config_ecnt) {
+			nca.nca_type = NCSI_PKT_CMD_ECNT;
+			nd->nd_state = ncsi_dev_state_config_ec;
+		} else if (nd->nd_state == ncsi_dev_state_config_ec) {
+			nca.nca_type = NCSI_PKT_CMD_EC;
+			nd->nd_state = ncsi_dev_state_config_gls;
+		} else if (nd->nd_state == ncsi_dev_state_config_gls) {
+			nca.nca_type = NCSI_PKT_CMD_GLS;
+			nd->nd_state = ncsi_dev_state_config_done;
+		}
+
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		break;
+	case ncsi_dev_state_config_done:
+		nd->nd_state = ncsi_dev_state_functional;
+		nd->nd_link_up = 0;
+		if (nc->nc_modes[NCSI_MODE_LINK].ncm_data[2] & 0x1)
+			nd->nd_link_up = 1;
+
+		if (!(ndp->ndp_flags & NCSI_DEV_FLAG_CHANGE_ACTIVE))
+			nd->nd_handler(nd);
+		ndp->ndp_flags &= ~NCSI_DEV_FLAG_CHANGE_ACTIVE;
+
+		break;
+	default:
+		pr_debug("%s: Unrecognized NCSI dev state 0x%x\n",
+			 __func__, nd->nd_state);
+		return;
+	}
+
+	return;
+
+error:
+	nd->nd_state = ncsi_dev_state_functional;
+	nd->nd_link_up = 0;
+	ndp->ndp_flags &= ~NCSI_DEV_FLAG_CHANGE_ACTIVE;
+	nd->nd_handler(nd);
+}
+
+static void ncsi_dev_start(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_dev *nd = &ndp->ndp_ndev;
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	struct ncsi_cmd_arg nca;
+	unsigned char index;
+	int ret;
+
+	nca.nca_ndp = ndp;
+	switch (nd->nd_state) {
+	case ncsi_dev_state_start:
+		nd->nd_state = ncsi_dev_state_start_deselect;
+		/* Fall through */
+	case ncsi_dev_state_start_deselect:
+		atomic_set(&ndp->ndp_pending_reqs, 8);
+
+		/* Deselect all possible packages */
+		nca.nca_type = NCSI_PKT_CMD_DP;
+		nca.nca_channel = 0x1f;
+		for (index = 0; index < 8; index++) {
+			nca.nca_package = index;
+			ret = ncsi_xmit_cmd(&nca);
+			if (ret)
+				goto error;
+		}
+
+		nd->nd_state = ncsi_dev_state_start_package;
+		break;
+	case ncsi_dev_state_start_package:
+		atomic_set(&ndp->ndp_pending_reqs, 16);
+
+		/* Select all possible packages */
+		nca.nca_type = NCSI_PKT_CMD_SP;
+		nca.nca_bytes[0] = 1;
+		nca.nca_channel = 0x1f;
+		for (index = 0; index < 8; index++) {
+			nca.nca_package = index;
+			ret = ncsi_xmit_cmd(&nca);
+			if (ret)
+				goto error;
+		}
+
+		/* Disable all possible packages */
+		nca.nca_type = NCSI_PKT_CMD_DP;
+		for (index = 0; index < 8; index++) {
+			nca.nca_package = index;
+			ret = ncsi_xmit_cmd(&nca);
+			if (ret)
+				goto error;
+		}
+
+		nd->nd_state = ncsi_dev_state_start_channel;
+		break;
+	case ncsi_dev_state_start_channel:
+		/* The available packages should have been detected. To
+		 * iterate every package to probe its channels.
+		 */
+		if (!ndp->ndp_active_package) {
+			ndp->ndp_active_package = list_first_or_null_rcu(
+				&ndp->ndp_packages, struct ncsi_package,
+				np_node);
+			if (!ndp->ndp_active_package)
+				goto error;
+		} else {
+			if (list_is_last(&ndp->ndp_active_package->np_node,
+					 &ndp->ndp_packages)) {
+				nd->nd_state = ncsi_dev_state_start_active;
+				goto choose_active_channel;
+			}
+
+			ndp->ndp_active_package = list_entry_rcu(
+				ndp->ndp_active_package->np_node.next,
+				struct ncsi_package, np_node);
+		}
+		/* Fall through */
+	case ncsi_dev_state_start_sp:
+		atomic_set(&ndp->ndp_pending_reqs, 1);
+
+		/* Select the specific package */
+		nca.nca_type = NCSI_PKT_CMD_SP;
+		nca.nca_bytes[0] = 1;
+		nca.nca_package = ndp->ndp_active_package->np_id;
+		nca.nca_channel = 0x1f;
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		nd->nd_state = ncsi_dev_state_start_cis;
+		break;
+	case ncsi_dev_state_start_cis:
+		atomic_set(&ndp->ndp_pending_reqs, 0x20);
+
+		/* Clear initial state */
+		nca.nca_type = NCSI_PKT_CMD_CIS;
+		nca.nca_package = ndp->ndp_active_package->np_id;
+		for (index = 0; index < 0x20; index++) {
+			nca.nca_channel = index;
+			ret = ncsi_xmit_cmd(&nca);
+			if (ret)
+				goto error;
+		}
+
+		nd->nd_state = ncsi_dev_state_start_gvi;
+		break;
+	case ncsi_dev_state_start_gvi:
+	case ncsi_dev_state_start_gc:
+		/* The available channels of the active package should have
+		 * been populated.
+		 */
+		np = ndp->ndp_active_package;
+		atomic_set(&ndp->ndp_pending_reqs,
+			   atomic_read(&np->np_channel_num));
+
+		/* Get version information or get capacity */
+		if (nd->nd_state == ncsi_dev_state_start_gvi)
+			nca.nca_type = NCSI_PKT_CMD_GVI;
+		else
+			nca.nca_type = NCSI_PKT_CMD_GC;
+
+		nca.nca_package = np->np_id;
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			nca.nca_channel = nc->nc_id;
+			ret = ncsi_xmit_cmd(&nca);
+			if (ret)
+				goto error;
+		}
+
+		if (nd->nd_state == ncsi_dev_state_start_gvi)
+			nd->nd_state = ncsi_dev_state_start_gc;
+		else
+			nd->nd_state = ncsi_dev_state_start_dp;
+		break;
+	case ncsi_dev_state_start_dp:
+		atomic_set(&ndp->ndp_pending_reqs, 1);
+
+		/* Deselect the active package */
+		nca.nca_type = NCSI_PKT_CMD_DP;
+		nca.nca_package = ndp->ndp_active_package->np_id;
+		nca.nca_channel = 0x1f;
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		nd->nd_state = ncsi_dev_state_start_channel;
+		break;
+	case ncsi_dev_state_start_active:
+choose_active_channel:
+		/* All packages and channels should have been populated. Also,
+		 * the information for all channels should have been retrieved.
+		 */
+		ndp->ndp_active_package = NULL;
+		ncsi_select_active_channel(ndp);
+		if (!ndp->ndp_active_package ||
+		    !ndp->ndp_active_channel)
+			goto error;
+
+		/* To configure the active channel */
+		nd->nd_state = ncsi_dev_state_config_sma;
+		ncsi_dev_config(ndp);
+	default:
+		pr_debug("%s: Unrecognized NCSI dev state 0x%x\n",
+			 __func__, nd->nd_state);
+	}
+
+	return;
+
+error:
+	ndp->ndp_flags &= ~NCSI_DEV_FLAG_CHANGE_ACTIVE;
+	nd->nd_state = ncsi_dev_state_functional;
+	nd->nd_link_up = 0;
+	nd->nd_handler(nd);
+}
+
+static void ncsi_dev_stop(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_dev *nd = &ndp->ndp_ndev;
+	struct ncsi_package *np, *tmp;
+	struct ncsi_channel *nc;
+	struct ncsi_cmd_arg nca;
+	int ret;
+
+	nca.nca_ndp = ndp;
+	switch (nd->nd_state) {
+	case ncsi_dev_state_stop:
+		/* If there're no active channel, we're done */
+		if (!ndp->ndp_active_channel) {
+			nd->nd_state = ncsi_dev_state_stop_done;
+			goto done;
+		}
+
+		nd->nd_state = ncsi_dev_state_stop_select;
+		/* Fall through */
+	case ncsi_dev_state_stop_select:
+	case ncsi_dev_state_stop_dcnt:
+	case ncsi_dev_state_stop_dc:
+	case ncsi_dev_state_stop_deselect:
+		atomic_set(&ndp->ndp_pending_reqs, 1);
+
+		np = ndp->ndp_active_package;
+		nc = ndp->ndp_active_channel;
+		nca.nca_package = np->np_id;
+		if (nd->nd_state == ncsi_dev_state_stop_select) {
+			nca.nca_type = NCSI_PKT_CMD_SP;
+			nca.nca_channel = 0x1f;
+			nca.nca_bytes[0] = 1;
+			nd->nd_state = ncsi_dev_state_stop_dcnt;
+		} else if (nd->nd_state == ncsi_dev_state_stop_dcnt) {
+			nca.nca_type = NCSI_PKT_CMD_DCNT;
+			nca.nca_channel = nc->nc_id;
+			nd->nd_state = ncsi_dev_state_stop_dc;
+		} else if (nd->nd_state == ncsi_dev_state_stop_dc) {
+			nca.nca_type = NCSI_PKT_CMD_DC;
+			nca.nca_channel = nc->nc_id;
+			nca.nca_bytes[0] = 1;
+			nd->nd_state = ncsi_dev_state_stop_deselect;
+		} else if (nd->nd_state == ncsi_dev_state_stop_deselect) {
+			nca.nca_type = NCSI_PKT_CMD_DP;
+			nca.nca_channel = 0x1f;
+			nd->nd_state = ncsi_dev_state_stop_done;
+		}
+
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret) {
+			nd->nd_state = ncsi_dev_state_stop_done;
+			goto done;
+		}
+
+		break;
+	case ncsi_dev_state_stop_done:
+done:
+		spin_lock(&ndp->ndp_package_lock);
+		list_for_each_entry_safe(np, tmp, &ndp->ndp_packages, np_node)
+			ncsi_release_package(np);
+		spin_unlock(&ndp->ndp_package_lock);
+
+		if (!(ndp->ndp_flags & NCSI_DEV_FLAG_CHANGE_ACTIVE)) {
+			nd->nd_state = ncsi_dev_state_functional;
+			nd->nd_link_up = 0;
+			nd->nd_handler(nd);
+		} else {
+			nd->nd_state = ncsi_dev_state_start;
+			ncsi_dev_start(ndp);
+		}
+
+		break;
+	default:
+		pr_warn("%s: Unsupported NCSI dev state 0x%x\n",
+			__func__, nd->nd_state);
+	}
+}
+
+static void ncsi_dev_work(struct work_struct *work)
+{
+	struct ncsi_dev_priv *ndp = container_of(work, struct ncsi_dev_priv,
+						 ndp_work);
+	struct ncsi_dev *nd = &ndp->ndp_ndev;
+
+	switch (nd->nd_state & ncsi_dev_state_major) {
+	case ncsi_dev_state_start:
+		ncsi_dev_start(ndp);
+		break;
+	case ncsi_dev_state_stop:
+		ncsi_dev_stop(ndp);
+		break;
+	case ncsi_dev_state_config:
+		ncsi_dev_config(ndp);
+		break;
+	default:
+		pr_warn("%s: Unsupported NCSI dev state 0x%x\n",
+			__func__, nd->nd_state);
+	}
+}
+
+static void ncsi_req_timeout(unsigned long data)
+{
+	struct ncsi_req *nr = (struct ncsi_req *)data;
+	struct ncsi_dev_priv *ndp = nr->nr_ndp;
+
+	/* If the request already had associated response,
+	 * let the response handler to release it.
+	 */
+	spin_lock(&ndp->ndp_req_lock);
+	nr->nr_timer_enabled = false;
+	if (nr->nr_rsp || !nr->nr_cmd) {
+		spin_unlock(&ndp->ndp_req_lock);
+		return;
+	}
+	spin_unlock(&ndp->ndp_req_lock);
+
+	/* Release the request */
+	ncsi_free_req(nr, true, true);
+}
+
+struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
+				   void (*handler)(struct ncsi_dev *ndev))
+{
+	struct ncsi_dev_priv *ndp;
+	struct ncsi_dev *nd;
+	int idx;
+
+	/* Check if the device has been registered or not */
+	nd = ncsi_find_dev(dev);
+	if (nd)
+		return nd;
+
+	/* Create NCSI device */
+	ndp = kzalloc(sizeof(*ndp), GFP_ATOMIC);
+	if (!ndp) {
+		pr_warn("%s: Out of memory !\n", __func__);
+		return NULL;
+	}
+
+	nd = &ndp->ndp_ndev;
+	nd->nd_state = ncsi_dev_state_registered;
+	nd->nd_dev = dev;
+	nd->nd_handler = handler;
+
+	/* Initialize private NCSI device */
+	spin_lock_init(&ndp->ndp_package_lock);
+	INIT_LIST_HEAD(&ndp->ndp_packages);
+	INIT_WORK(&ndp->ndp_work, ncsi_dev_work);
+	spin_lock_init(&ndp->ndp_req_lock);
+	atomic_set(&ndp->ndp_last_req_idx, 0);
+	for (idx = 0; idx < 256; idx++) {
+		ndp->ndp_reqs[idx].nr_id = idx;
+		ndp->ndp_reqs[idx].nr_ndp = ndp;
+		setup_timer(&ndp->ndp_reqs[idx].nr_timer, ncsi_req_timeout,
+			    (unsigned long)&ndp->ndp_reqs[idx]);
+	}
+
+	spin_lock(&ncsi_dev_lock);
+	list_add_tail_rcu(&ndp->ndp_node, &ncsi_dev_list);
+	spin_unlock(&ncsi_dev_lock);
+
+	/* Register NCSI packet receiption handler */
+	ndp->ndp_ptype.type = cpu_to_be16(ETH_P_NCSI);
+	ndp->ndp_ptype.func = ncsi_rcv_rsp;
+	ndp->ndp_ptype.dev = dev;
+	dev_add_pack(&ndp->ndp_ptype);
+
+	return nd;
+}
+EXPORT_SYMBOL_GPL(ncsi_register_dev);
+
+int ncsi_start_dev(struct ncsi_dev *nd)
+{
+	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
+
+	if (nd->nd_state != ncsi_dev_state_registered &&
+	    nd->nd_state != ncsi_dev_state_functional)
+		return -ENOTTY;
+
+	nd->nd_state = ncsi_dev_state_start;
+	schedule_work(&ndp->ndp_work);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ncsi_start_dev);
+
+int ncsi_config_dev(struct ncsi_dev *nd)
+{
+	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
+
+	if (nd->nd_state != ncsi_dev_state_functional)
+		return -ENOTTY;
+
+	nd->nd_state = ncsi_dev_state_config;
+	schedule_work(&ndp->ndp_work);
+
+	return 0;
+}
+
+int ncsi_stop_dev(struct ncsi_dev *nd)
+{
+	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
+
+	if (nd->nd_state != ncsi_dev_state_functional)
+		return -ENOTTY;
+
+	nd->nd_state = ncsi_dev_state_stop;
+	schedule_work(&ndp->ndp_work);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ncsi_stop_dev);
+
+void ncsi_unregister_dev(struct ncsi_dev *nd)
+{
+	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
+	struct ncsi_package *np, *tmp;
+
+	dev_remove_pack(&ndp->ndp_ptype);
+
+	spin_lock(&ndp->ndp_package_lock);
+	list_for_each_entry_safe(np, tmp, &ndp->ndp_packages, np_node)
+		ncsi_release_package(np);
+	spin_unlock(&ndp->ndp_package_lock);
+}
+EXPORT_SYMBOL_GPL(ncsi_unregister_dev);
-- 
2.1.0
