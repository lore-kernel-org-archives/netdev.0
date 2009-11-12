From: frank.blaschka@de.ibm.com
Subject: [patch 4/5] [PATCH] qeth: rework TSO functions
Date: Thu, 12 Nov 2009 11:11:44 +0100
Message-ID: <20091112101301.126320000@de.ibm.com>
References: <20091112101140.882313000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.17.164]:33991 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbZKLKM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 05:12:57 -0500
Content-Disposition: inline; filename=609-qeth-rework-tso.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

The maximum TSO size OSA can handle is 15 * PAGE_SIZE. This
patch reduces gso_max_size to this value and adds some sanity
checks and statistics to the TSO implementation.
Since only layer 3 is able to do TSO move all TSO related functions
to the qeth_l3 module.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    2 -
 drivers/s390/net/qeth_core_main.c |   37 +------------------
 drivers/s390/net/qeth_core_sys.c  |   48 -------------------------
 drivers/s390/net/qeth_l2_main.c   |    1 
 drivers/s390/net/qeth_l3.h        |    1 
 drivers/s390/net/qeth_l3_main.c   |   71 +++++++++++++++++++++++++++++++-------
 drivers/s390/net/qeth_l3_sys.c    |   48 +++++++++++++++++++++++++
 7 files changed, 110 insertions(+), 98 deletions(-)

Index: git_net-next/drivers/s390/net/qeth_core.h
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_core.h
+++ git_net-next/drivers/s390/net/qeth_core.h
@@ -134,6 +134,7 @@ struct qeth_perf_stats {
 	unsigned int sg_frags_rx;
 	unsigned int sg_alloc_page_rx;
 	unsigned int tx_csum;
+	unsigned int tx_lin;
 };
 
 /* Routing stuff */
@@ -835,7 +836,6 @@ void qeth_prepare_ipa_cmd(struct qeth_ca
 struct qeth_cmd_buffer *qeth_wait_for_buffer(struct qeth_channel *);
 int qeth_mdio_read(struct net_device *, int, int);
 int qeth_snmp_command(struct qeth_card *, char __user *);
-int qeth_set_large_send(struct qeth_card *, enum qeth_large_send_types);
 struct qeth_cmd_buffer *qeth_get_adapter_cmd(struct qeth_card *, __u32, __u32);
 int qeth_default_setadapterparms_cb(struct qeth_card *, struct qeth_reply *,
 					unsigned long);
Index: git_net-next/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_core_main.c
+++ git_net-next/drivers/s390/net/qeth_core_main.c
@@ -270,41 +270,6 @@ int qeth_realloc_buffer_pool(struct qeth
 	return qeth_alloc_buffer_pool(card);
 }
 
-int qeth_set_large_send(struct qeth_card *card,
-		enum qeth_large_send_types type)
-{
-	int rc = 0;
-
-	if (card->dev == NULL) {
-		card->options.large_send = type;
-		return 0;
-	}
-	if (card->state == CARD_STATE_UP)
-		netif_tx_disable(card->dev);
-	card->options.large_send = type;
-	switch (card->options.large_send) {
-	case QETH_LARGE_SEND_TSO:
-		if (qeth_is_supported(card, IPA_OUTBOUND_TSO)) {
-			card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
-						NETIF_F_HW_CSUM;
-		} else {
-			card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
-						NETIF_F_HW_CSUM);
-			card->options.large_send = QETH_LARGE_SEND_NO;
-			rc = -EOPNOTSUPP;
-		}
-		break;
-	default: /* includes QETH_LARGE_SEND_NO */
-		card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
-					NETIF_F_HW_CSUM);
-		break;
-	}
-	if (card->state == CARD_STATE_UP)
-		netif_wake_queue(card->dev);
-	return rc;
-}
-EXPORT_SYMBOL_GPL(qeth_set_large_send);
-
 static int qeth_issue_next_read(struct qeth_card *card)
 {
 	int rc;
@@ -4460,6 +4425,7 @@ static struct {
 	{"tx do_QDIO time"},
 	{"tx do_QDIO count"},
 	{"tx csum"},
+	{"tx lin"},
 };
 
 int qeth_core_get_sset_count(struct net_device *dev, int stringset)
@@ -4517,6 +4483,7 @@ void qeth_core_get_ethtool_stats(struct 
 	data[31] = card->perf_stats.outbound_do_qdio_time;
 	data[32] = card->perf_stats.outbound_do_qdio_cnt;
 	data[33] = card->perf_stats.tx_csum;
+	data[34] = card->perf_stats.tx_lin;
 }
 EXPORT_SYMBOL_GPL(qeth_core_get_ethtool_stats);
 
Index: git_net-next/drivers/s390/net/qeth_core_sys.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_core_sys.c
+++ git_net-next/drivers/s390/net/qeth_core_sys.c
@@ -416,53 +416,6 @@ static ssize_t qeth_dev_layer2_store(str
 static DEVICE_ATTR(layer2, 0644, qeth_dev_layer2_show,
 		   qeth_dev_layer2_store);
 
-static ssize_t qeth_dev_large_send_show(struct device *dev,
-				struct device_attribute *attr, char *buf)
-{
-	struct qeth_card *card = dev_get_drvdata(dev);
-
-	if (!card)
-		return -EINVAL;
-
-	switch (card->options.large_send) {
-	case QETH_LARGE_SEND_NO:
-		return sprintf(buf, "%s\n", "no");
-	case QETH_LARGE_SEND_TSO:
-		return sprintf(buf, "%s\n", "TSO");
-	default:
-		return sprintf(buf, "%s\n", "N/A");
-	}
-}
-
-static ssize_t qeth_dev_large_send_store(struct device *dev,
-		struct device_attribute *attr, const char *buf, size_t count)
-{
-	struct qeth_card *card = dev_get_drvdata(dev);
-	enum qeth_large_send_types type;
-	int rc = 0;
-	char *tmp;
-
-	if (!card)
-		return -EINVAL;
-	tmp = strsep((char **) &buf, "\n");
-	if (!strcmp(tmp, "no")) {
-		type = QETH_LARGE_SEND_NO;
-	} else if (!strcmp(tmp, "TSO")) {
-		type = QETH_LARGE_SEND_TSO;
-	} else {
-		return -EINVAL;
-	}
-	if (card->options.large_send == type)
-		return count;
-	rc = qeth_set_large_send(card, type);
-	if (rc)
-		return rc;
-	return count;
-}
-
-static DEVICE_ATTR(large_send, 0644, qeth_dev_large_send_show,
-		   qeth_dev_large_send_store);
-
 #define ATTR_QETH_ISOLATION_NONE	("none")
 #define ATTR_QETH_ISOLATION_FWD		("forward")
 #define ATTR_QETH_ISOLATION_DROP	("drop")
@@ -658,7 +611,6 @@ static struct attribute *qeth_device_att
 	&dev_attr_recover.attr,
 	&dev_attr_performance_stats.attr,
 	&dev_attr_layer2.attr,
-	&dev_attr_large_send.attr,
 	&dev_attr_isolation.attr,
 	NULL,
 };
Index: git_net-next/drivers/s390/net/qeth_l2_main.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_l2_main.c
+++ git_net-next/drivers/s390/net/qeth_l2_main.c
@@ -978,7 +978,6 @@ static int __qeth_l2_set_online(struct c
 	if (card->info.type != QETH_CARD_TYPE_OSN) {
 		/* configure isolation level */
 		qeth_set_access_ctrl_online(card);
-		qeth_set_large_send(card, card->options.large_send);
 		qeth_l2_process_vlans(card, 0);
 	}
 
Index: git_net-next/drivers/s390/net/qeth_l3.h
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_l3.h
+++ git_net-next/drivers/s390/net/qeth_l3.h
@@ -60,5 +60,6 @@ void qeth_l3_del_vipa(struct qeth_card *
 int qeth_l3_add_rxip(struct qeth_card *, enum qeth_prot_versions, const u8 *);
 void qeth_l3_del_rxip(struct qeth_card *card, enum qeth_prot_versions,
 			const u8 *);
+int qeth_l3_set_large_send(struct qeth_card *, enum qeth_large_send_types);
 
 #endif /* __QETH_L3_H__ */
Index: git_net-next/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_l3_main.c
+++ git_net-next/drivers/s390/net/qeth_l3_main.c
@@ -41,6 +41,32 @@ static int qeth_l3_deregister_addr_entry
 static int __qeth_l3_set_online(struct ccwgroup_device *, int);
 static int __qeth_l3_set_offline(struct ccwgroup_device *, int);
 
+int qeth_l3_set_large_send(struct qeth_card *card,
+		enum qeth_large_send_types type)
+{
+	int rc = 0;
+
+	card->options.large_send = type;
+	if (card->dev == NULL)
+		return 0;
+
+	if (card->options.large_send == QETH_LARGE_SEND_TSO) {
+		if (qeth_is_supported(card, IPA_OUTBOUND_TSO)) {
+			card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
+					NETIF_F_HW_CSUM;
+		} else {
+			card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
+					NETIF_F_HW_CSUM);
+			card->options.large_send = QETH_LARGE_SEND_NO;
+			rc = -EOPNOTSUPP;
+		}
+	} else {
+		card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
+					NETIF_F_HW_CSUM);
+		card->options.large_send = QETH_LARGE_SEND_NO;
+	}
+	return rc;
+}
 
 static int qeth_l3_isxdigit(char *buf)
 {
@@ -2686,6 +2712,24 @@ static void qeth_tx_csum(struct sk_buff 
 	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
 }
 
+static inline int qeth_l3_tso_elements(struct sk_buff *skb)
+{
+	unsigned long tcpd = (unsigned long)tcp_hdr(skb) +
+		tcp_hdr(skb)->doff * 4;
+	int tcpd_len = skb->len - (tcpd - (unsigned long)skb->data);
+	int elements = PFN_UP(tcpd + tcpd_len) - PFN_DOWN(tcpd);
+	elements += skb_shinfo(skb)->nr_frags;
+	return elements;
+}
+
+static inline int qeth_l3_tso_check(struct sk_buff *skb)
+{
+	int len = ((unsigned long)tcp_hdr(skb) + tcp_hdr(skb)->doff * 4) -
+		(unsigned long)skb->data;
+	return (((unsigned long)skb->data & PAGE_MASK) !=
+		(((unsigned long)skb->data + len) & PAGE_MASK));
+}
+
 static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	int rc;
@@ -2779,16 +2823,21 @@ static int qeth_l3_hard_start_xmit(struc
 	/* fix hardware limitation: as long as we do not have sbal
 	 * chaining we can not send long frag lists
 	 */
-	if ((large_send == QETH_LARGE_SEND_TSO) &&
-	    ((skb_shinfo(new_skb)->nr_frags + 2) > 16)) {
-		if (skb_linearize(new_skb))
-			goto tx_drop;
+	if (large_send == QETH_LARGE_SEND_TSO) {
+		if (qeth_l3_tso_elements(new_skb) + 1 > 16) {
+			if (skb_linearize(new_skb))
+				goto tx_drop;
+			if (card->options.performance_stats)
+				card->perf_stats.tx_lin++;
+		}
 	}
 
 	if ((large_send == QETH_LARGE_SEND_TSO) &&
 	    (cast_type == RTN_UNSPEC)) {
 		hdr = (struct qeth_hdr *)skb_push(new_skb,
 						sizeof(struct qeth_hdr_tso));
+		if (qeth_l3_tso_check(new_skb))
+			QETH_DBF_MESSAGE(2, "tso skb misaligned\n");
 		memset(hdr, 0, sizeof(struct qeth_hdr_tso));
 		qeth_l3_fill_header(card, hdr, new_skb, ipv, cast_type);
 		qeth_tso_fill_header(card, hdr, new_skb);
@@ -2931,20 +2980,15 @@ static int qeth_l3_ethtool_set_rx_csum(s
 static int qeth_l3_ethtool_set_tso(struct net_device *dev, u32 data)
 {
 	struct qeth_card *card = dev->ml_priv;
+	int rc = 0;
 
 	if (data) {
-		if (card->options.large_send == QETH_LARGE_SEND_NO) {
-			if (card->info.type == QETH_CARD_TYPE_IQD)
-				return -EPERM;
-			else
-				card->options.large_send = QETH_LARGE_SEND_TSO;
-			dev->features |= NETIF_F_TSO;
-		}
+		rc = qeth_l3_set_large_send(card, QETH_LARGE_SEND_TSO);
 	} else {
 		dev->features &= ~NETIF_F_TSO;
 		card->options.large_send = QETH_LARGE_SEND_NO;
 	}
-	return 0;
+	return rc;
 }
 
 static const struct ethtool_ops qeth_l3_ethtool_ops = {
@@ -3060,6 +3104,7 @@ static int qeth_l3_setup_netdev(struct q
 				NETIF_F_HW_VLAN_RX |
 				NETIF_F_HW_VLAN_FILTER;
 	card->dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	card->dev->gso_max_size = 15 * PAGE_SIZE;
 
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
 	return register_netdev(card->dev);
@@ -3189,7 +3234,7 @@ static int __qeth_l3_set_online(struct c
 		goto out_remove;
 	} else
 		card->lan_online = 1;
-	qeth_set_large_send(card, card->options.large_send);
+	qeth_l3_set_large_send(card, card->options.large_send);
 
 	rc = qeth_l3_setadapter_parms(card);
 	if (rc)
Index: git_net-next/drivers/s390/net/qeth_l3_sys.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_l3_sys.c
+++ git_net-next/drivers/s390/net/qeth_l3_sys.c
@@ -318,6 +318,53 @@ static ssize_t qeth_l3_dev_checksum_stor
 static DEVICE_ATTR(checksumming, 0644, qeth_l3_dev_checksum_show,
 		qeth_l3_dev_checksum_store);
 
+static ssize_t qeth_l3_dev_large_send_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	switch (card->options.large_send) {
+	case QETH_LARGE_SEND_NO:
+		return sprintf(buf, "%s\n", "no");
+	case QETH_LARGE_SEND_TSO:
+		return sprintf(buf, "%s\n", "TSO");
+	default:
+		return sprintf(buf, "%s\n", "N/A");
+	}
+}
+
+static ssize_t qeth_l3_dev_large_send_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	enum qeth_large_send_types type;
+	int rc = 0;
+	char *tmp;
+
+	if (!card)
+		return -EINVAL;
+	tmp = strsep((char **) &buf, "\n");
+	if (!strcmp(tmp, "no"))
+		type = QETH_LARGE_SEND_NO;
+	else if (!strcmp(tmp, "TSO"))
+		type = QETH_LARGE_SEND_TSO;
+	else
+		return -EINVAL;
+
+	if (card->options.large_send == type)
+		return count;
+	rc = qeth_l3_set_large_send(card, type);
+	if (rc)
+		return rc;
+	return count;
+}
+
+static DEVICE_ATTR(large_send, 0644, qeth_l3_dev_large_send_show,
+		   qeth_l3_dev_large_send_store);
+
 static struct attribute *qeth_l3_device_attrs[] = {
 	&dev_attr_route4.attr,
 	&dev_attr_route6.attr,
@@ -325,6 +372,7 @@ static struct attribute *qeth_l3_device_
 	&dev_attr_broadcast_mode.attr,
 	&dev_attr_canonical_macaddr.attr,
 	&dev_attr_checksumming.attr,
+	&dev_attr_large_send.attr,
 	NULL,
 };
 

