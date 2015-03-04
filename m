From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/3] be2net: avoid creating the non-RSS default RXQ if FW allows to
Date: Wed, 4 Mar 2015 00:44:32 -0500
Message-ID: <1425447874-5406-2-git-send-email-sathya.perla@emulex.com>
References: <1425447874-5406-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:7417 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940AbbCDFl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 00:41:26 -0500
In-Reply-To: <1425447874-5406-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

On BE2, BE3 and Skhawk-R chips one non-RSS (called "default") RXQ was
needed to receive non-IP traffic. Some FW versions now export a
capability called IFACE_FLAGS_DEFQ_RSS where this requirement doesn't hold.
On such FWs the driver now does not create the non-RSS default queue.
This prevents wasting one RXQ per VF.
Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |  5 +--
 drivers/net/ethernet/emulex/benet/be_cmds.c    |  3 --
 drivers/net/ethernet/emulex/benet/be_cmds.h    |  5 +--
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c    | 50 +++++++++++++++++---------
 5 files changed, 41 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index fac806a..7e13fab 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -488,6 +488,8 @@ struct be_adapter {
 
 	/* Rx rings */
 	u16 num_rx_qs;
+	u16 num_rss_qs;
+	u16 need_def_rxq;
 	struct be_rx_obj rx_obj[MAX_RX_QS];
 	u32 big_page_size;	/* Compounded page size shared by rx wrbs */
 
@@ -635,9 +637,8 @@ extern const struct ethtool_ops be_ethtool_ops;
 	for (i = 0, rxo = &adapter->rx_obj[i]; i < adapter->num_rx_qs;	\
 		i++, rxo++)
 
-/* Skip the default non-rss queue (last one)*/
 #define for_all_rss_queues(adapter, rxo, i)				\
-	for (i = 0, rxo = &adapter->rx_obj[i]; i < (adapter->num_rx_qs - 1);\
+	for (i = 0, rxo = &adapter->rx_obj[i]; i < adapter->num_rss_qs;	\
 		i++, rxo++)
 
 #define for_all_tx_queues(adapter, txo, i)				\
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index f6db7b3..43dea7a 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3580,9 +3580,6 @@ static void be_copy_nic_desc(struct be_resources *res,
 	/* Clear flags that driver is not interested in */
 	res->if_cap_flags = le32_to_cpu(desc->cap_flags) &
 				BE_IF_CAP_FLAGS_WANT;
-	/* Need 1 RXQ as the default RXQ */
-	if (res->max_rss_qs && res->max_rss_qs == res->max_rx_qs)
-		res->max_rss_qs -= 1;
 }
 
 /* Uses Mbox */
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index db761e8e..4951482 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -588,14 +588,15 @@ enum be_if_flags {
 	BE_IF_FLAGS_MCAST_PROMISCUOUS = 0x200,
 	BE_IF_FLAGS_PASS_L2_ERRORS = 0x400,
 	BE_IF_FLAGS_PASS_L3L4_ERRORS = 0x800,
-	BE_IF_FLAGS_MULTICAST = 0x1000
+	BE_IF_FLAGS_MULTICAST = 0x1000,
+	BE_IF_FLAGS_DEFQ_RSS = 0x1000000
 };
 
 #define BE_IF_CAP_FLAGS_WANT (BE_IF_FLAGS_RSS | BE_IF_FLAGS_PROMISCUOUS |\
 			 BE_IF_FLAGS_BROADCAST | BE_IF_FLAGS_VLAN_PROMISCUOUS |\
 			 BE_IF_FLAGS_VLAN | BE_IF_FLAGS_MCAST_PROMISCUOUS |\
 			 BE_IF_FLAGS_PASS_L3L4_ERRORS | BE_IF_FLAGS_MULTICAST |\
-			 BE_IF_FLAGS_UNTAGGED)
+			 BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_DEFQ_RSS)
 
 #define BE_IF_FLAGS_ALL_PROMISCUOUS	(BE_IF_FLAGS_PROMISCUOUS | \
 					 BE_IF_FLAGS_VLAN_PROMISCUOUS |\
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 4d2de47..b765c24 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -1097,7 +1097,7 @@ static int be_set_rss_hash_opts(struct be_adapter *adapter,
 		return status;
 
 	if (be_multi_rxq(adapter)) {
-		for (j = 0; j < 128; j += adapter->num_rx_qs - 1) {
+		for (j = 0; j < 128; j += adapter->num_rss_qs) {
 			for_all_rss_queues(adapter, rxo, i) {
 				if ((j + i) >= 128)
 					break;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b2277a4..6121a04 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2454,13 +2454,19 @@ static int be_rx_cqs_create(struct be_adapter *adapter)
 	int rc, i;
 
 	/* We can create as many RSS rings as there are EQs. */
-	adapter->num_rx_qs = adapter->num_evt_qs;
+	adapter->num_rss_qs = adapter->num_evt_qs;
 
-	/* We'll use RSS only if atleast 2 RSS rings are supported.
-	 * When RSS is used, we'll need a default RXQ for non-IP traffic.
+	/* We'll use RSS only if atleast 2 RSS rings are supported. */
+	if (adapter->num_rss_qs <= 1)
+		adapter->num_rss_qs = 0;
+
+	adapter->num_rx_qs = adapter->num_rss_qs + adapter->need_def_rxq;
+
+	/* When the interface is not capable of RSS rings (and there is no
+	 * need to create a default RXQ) we'll still need one RXQ
 	 */
-	if (adapter->num_rx_qs > 1)
-		adapter->num_rx_qs++;
+	if (adapter->num_rx_qs == 0)
+		adapter->num_rx_qs = 1;
 
 	adapter->big_page_size = (1 << get_order(rx_frag_size)) * PAGE_SIZE;
 	for_all_rx_queues(adapter, rxo, i) {
@@ -2479,8 +2485,7 @@ static int be_rx_cqs_create(struct be_adapter *adapter)
 	}
 
 	dev_info(&adapter->pdev->dev,
-		 "created %d RSS queue(s) and 1 default RX queue\n",
-		 adapter->num_rx_qs - 1);
+		 "created %d RX queue(s)\n", adapter->num_rx_qs);
 	return 0;
 }
 
@@ -3110,12 +3115,14 @@ static int be_rx_qs_create(struct be_adapter *adapter)
 			return rc;
 	}
 
-	/* The FW would like the default RXQ to be created first */
-	rxo = default_rxo(adapter);
-	rc = be_cmd_rxq_create(adapter, &rxo->q, rxo->cq.id, rx_frag_size,
-			       adapter->if_handle, false, &rxo->rss_id);
-	if (rc)
-		return rc;
+	if (adapter->need_def_rxq || !adapter->num_rss_qs) {
+		rxo = default_rxo(adapter);
+		rc = be_cmd_rxq_create(adapter, &rxo->q, rxo->cq.id,
+				       rx_frag_size, adapter->if_handle,
+				       false, &rxo->rss_id);
+		if (rc)
+			return rc;
+	}
 
 	for_all_rss_queues(adapter, rxo, i) {
 		rc = be_cmd_rxq_create(adapter, &rxo->q, rxo->cq.id,
@@ -3126,8 +3133,7 @@ static int be_rx_qs_create(struct be_adapter *adapter)
 	}
 
 	if (be_multi_rxq(adapter)) {
-		for (j = 0; j < RSS_INDIR_TABLE_LEN;
-			j += adapter->num_rx_qs - 1) {
+		for (j = 0; j < RSS_INDIR_TABLE_LEN; j += adapter->num_rss_qs) {
 			for_all_rss_queues(adapter, rxo, i) {
 				if ((j + i) >= RSS_INDIR_TABLE_LEN)
 					break;
@@ -3439,7 +3445,7 @@ static int be_if_create(struct be_adapter *adapter, u32 *if_handle,
 
 	en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
 		   BE_IF_FLAGS_MULTICAST | BE_IF_FLAGS_PASS_L3L4_ERRORS |
-		   BE_IF_FLAGS_RSS;
+		   BE_IF_FLAGS_RSS | BE_IF_FLAGS_DEFQ_RSS;
 
 	en_flags &= cap_flags;
 
@@ -3649,6 +3655,7 @@ static void BEx_get_resources(struct be_adapter *adapter,
 		res->max_evt_qs = 1;
 
 	res->if_cap_flags = BE_IF_CAP_FLAGS_WANT;
+	res->if_cap_flags &= ~BE_IF_FLAGS_DEFQ_RSS;
 	if (!(adapter->function_caps & BE_FUNCTION_CAPS_RSS))
 		res->if_cap_flags &= ~BE_IF_FLAGS_RSS;
 }
@@ -3731,12 +3738,23 @@ static int be_get_resources(struct be_adapter *adapter)
 		if (status)
 			return status;
 
+		/* If a deafault RXQ must be created, we'll use up one RSSQ*/
+		if (res.max_rss_qs && res.max_rss_qs == res.max_rx_qs &&
+		    !(res.if_cap_flags & BE_IF_FLAGS_DEFQ_RSS))
+			res.max_rss_qs -= 1;
+
 		/* If RoCE may be enabled stash away half the EQs for RoCE */
 		if (be_roce_supported(adapter))
 			res.max_evt_qs /= 2;
 		adapter->res = res;
 	}
 
+	/* If FW supports RSS default queue, then skip creating non-RSS
+	 * queue for non-IP traffic.
+	 */
+	adapter->need_def_rxq = (be_if_cap_flags(adapter) &
+				 BE_IF_FLAGS_DEFQ_RSS) ? 0 : 1;
+
 	dev_info(dev, "Max: txqs %d, rxqs %d, rss %d, eqs %d, vfs %d\n",
 		 be_max_txqs(adapter), be_max_rxqs(adapter),
 		 be_max_rss(adapter), be_max_eqs(adapter),
-- 
2.2.0
