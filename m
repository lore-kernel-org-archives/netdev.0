From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: s390: convert to hw_features
Date: Tue, 19 Apr 2011 12:43:20 +0200 (CEST)
Message-ID: <20110419104320.314AB13A66@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ursula Braun <ursula.braun@de.ibm.com>,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>,
	linux390@de.ibm.com, Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux-s390@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46859 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754423Ab1DSKnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 06:43:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

options.large_send was easy to get rid of. options.checksum_type has de=
eper
roots so is left for later cleanup.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/s390/net/qeth_core.h    |    7 --
 drivers/s390/net/qeth_l3_main.c |  117 +++++++++++--------------------=
--------
 drivers/s390/net/qeth_l3_sys.c  |   35 ++++++-----
 3 files changed, 52 insertions(+), 107 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.=
h
index af3f7b0..8d6146a 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -407,12 +407,6 @@ struct qeth_qdio_q {
 	int next_buf_to_init;
 } __attribute__ ((aligned(256)));
=20
-/* possible types of qeth large_send support */
-enum qeth_large_send_types {
-	QETH_LARGE_SEND_NO,
-	QETH_LARGE_SEND_TSO,
-};
-
 struct qeth_qdio_out_buffer {
 	struct qdio_buffer *buffer;
 	atomic_t state;
@@ -651,7 +645,6 @@ struct qeth_card_options {
 	int fake_broadcast;
 	int add_hhlen;
 	int layer2;
-	enum qeth_large_send_types large_send;
 	int performance_stats;
 	int rx_sg_cb;
 	enum qeth_ipa_isolation_modes isolation;
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3=
_main.c
index 142e5f6..1496661 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -43,33 +43,6 @@ static int qeth_l3_deregister_addr_entry(struct qeth=
_card *,
 static int __qeth_l3_set_online(struct ccwgroup_device *, int);
 static int __qeth_l3_set_offline(struct ccwgroup_device *, int);
=20
-int qeth_l3_set_large_send(struct qeth_card *card,
-		enum qeth_large_send_types type)
-{
-	int rc =3D 0;
-
-	card->options.large_send =3D type;
-	if (card->dev =3D=3D NULL)
-		return 0;
-
-	if (card->options.large_send =3D=3D QETH_LARGE_SEND_TSO) {
-		if (qeth_is_supported(card, IPA_OUTBOUND_TSO)) {
-			card->dev->features |=3D NETIF_F_TSO | NETIF_F_SG |
-					NETIF_F_IP_CSUM;
-		} else {
-			card->dev->features &=3D ~(NETIF_F_TSO | NETIF_F_SG |
-					NETIF_F_IP_CSUM);
-			card->options.large_send =3D QETH_LARGE_SEND_NO;
-			rc =3D -EOPNOTSUPP;
-		}
-	} else {
-		card->dev->features &=3D ~(NETIF_F_TSO | NETIF_F_SG |
-					NETIF_F_IP_CSUM);
-		card->options.large_send =3D QETH_LARGE_SEND_NO;
-	}
-	return rc;
-}
-
 static int qeth_l3_isxdigit(char *buf)
 {
 	while (*buf) {
@@ -1485,6 +1458,7 @@ int qeth_l3_set_rx_csum(struct qeth_card *card,
 			if (rc)
 				return -EIO;
 		}
+		card->dev->features |=3D NETIF_F_RXCSUM;
 	} else {
 		if (csum_type =3D=3D HW_CHECKSUMMING) {
 			if (card->state !=3D CARD_STATE_DOWN) {
@@ -1496,6 +1470,7 @@ int qeth_l3_set_rx_csum(struct qeth_card *card,
 					return -EIO;
 			}
 		}
+		card->dev->features &=3D ~NETIF_F_RXCSUM;
 	}
 	card->options.checksum_type =3D csum_type;
 	return rc;
@@ -1580,10 +1555,8 @@ static int qeth_l3_start_ipa_tso(struct qeth_car=
d *card)
 			dev_info(&card->gdev->dev,
 				"Outbound TSO enabled\n");
 	}
-	if (rc && (card->options.large_send =3D=3D QETH_LARGE_SEND_TSO)) {
-		card->options.large_send =3D QETH_LARGE_SEND_NO;
-		card->dev->features &=3D ~(NETIF_F_TSO | NETIF_F_SG);
-	}
+	if (rc)
+		card->dev->features &=3D ~NETIF_F_TSO;
 	return rc;
 }
=20
@@ -3024,7 +2997,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff=
 *skb, struct net_device *dev)
 	struct qeth_qdio_out_q *queue =3D card->qdio.out_qs
 		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
 	int tx_bytes =3D skb->len;
-	enum qeth_large_send_types large_send =3D QETH_LARGE_SEND_NO;
+	bool large_send;
 	int data_offset =3D -1;
 	int nr_frags;
=20
@@ -3046,8 +3019,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff=
 *skb, struct net_device *dev)
 		card->perf_stats.outbound_start_time =3D qeth_get_micros();
 	}
=20
-	if (skb_is_gso(skb))
-		large_send =3D card->options.large_send;
+	large_send =3D skb_is_gso(skb);
=20
 	if ((card->info.type =3D=3D QETH_CARD_TYPE_IQD) && (!large_send) &&
 	    (skb_shinfo(skb)->nr_frags =3D=3D 0)) {
@@ -3096,7 +3068,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff=
 *skb, struct net_device *dev)
 	/* fix hardware limitation: as long as we do not have sbal
 	 * chaining we can not send long frag lists
 	 */
-	if (large_send =3D=3D QETH_LARGE_SEND_TSO) {
+	if (large_send) {
 		if (qeth_l3_tso_elements(new_skb) + 1 > 16) {
 			if (skb_linearize(new_skb))
 				goto tx_drop;
@@ -3105,8 +3077,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff=
 *skb, struct net_device *dev)
 		}
 	}
=20
-	if ((large_send =3D=3D QETH_LARGE_SEND_TSO) &&
-	    (cast_type =3D=3D RTN_UNSPEC)) {
+	if (large_send && (cast_type =3D=3D RTN_UNSPEC)) {
 		hdr =3D (struct qeth_hdr *)skb_push(new_skb,
 						sizeof(struct qeth_hdr_tso));
 		memset(hdr, 0, sizeof(struct qeth_hdr_tso));
@@ -3141,7 +3112,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff=
 *skb, struct net_device *dev)
=20
 	if (card->info.type !=3D QETH_CARD_TYPE_IQD) {
 		int len;
-		if (large_send =3D=3D QETH_LARGE_SEND_TSO)
+		if (large_send)
 			len =3D ((unsigned long)tcp_hdr(new_skb) +
 				tcp_hdr(new_skb)->doff * 4) -
 				(unsigned long)new_skb->data;
@@ -3162,7 +3133,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff=
 *skb, struct net_device *dev)
 		if (new_skb !=3D skb)
 			dev_kfree_skb_any(skb);
 		if (card->options.performance_stats) {
-			if (large_send !=3D QETH_LARGE_SEND_NO) {
+			if (large_send) {
 				card->perf_stats.large_send_bytes +=3D tx_bytes;
 				card->perf_stats.large_send_cnt++;
 			}
@@ -3248,65 +3219,40 @@ static int qeth_l3_stop(struct net_device *dev)
 	return 0;
 }
=20
-static u32 qeth_l3_ethtool_get_rx_csum(struct net_device *dev)
+static u32 qeth_l3_fix_features(struct net_device *dev, u32 features)
 {
 	struct qeth_card *card =3D dev->ml_priv;
=20
-	return (card->options.checksum_type =3D=3D HW_CHECKSUMMING);
+	if (!qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
+		features &=3D ~NETIF_F_IP_CSUM;
+	if (!qeth_is_supported(card, IPA_OUTBOUND_TSO))
+		features &=3D ~NETIF_F_TSO;
+	if (!qeth_is_supported(card, IPA_INBOUND_CHECKSUM))
+		features &=3D ~NETIF_F_RXCSUM;
+
+	return features;
 }
=20
-static int qeth_l3_ethtool_set_rx_csum(struct net_device *dev, u32 dat=
a)
+static int qeth_l3_set_features(struct net_device *dev, u32 features)
 {
-	struct qeth_card *card =3D dev->ml_priv;
 	enum qeth_checksum_types csum_type;
+	struct qeth_card *card =3D dev->ml_priv;
+	u32 changed =3D dev->features ^ features;
=20
-	if (data)
+	if (!(changed & NETIF_F_RXCSUM))
+		return 0;
+
+	if (features & NETIF_F_RXCSUM)
 		csum_type =3D HW_CHECKSUMMING;
 	else
 		csum_type =3D SW_CHECKSUMMING;
=20
+	dev->features =3D features ^ NETIF_F_RXCSUM;
 	return qeth_l3_set_rx_csum(card, csum_type);
 }
=20
-static int qeth_l3_ethtool_set_tso(struct net_device *dev, u32 data)
-{
-	struct qeth_card *card =3D dev->ml_priv;
-	int rc =3D 0;
-
-	if (data) {
-		rc =3D qeth_l3_set_large_send(card, QETH_LARGE_SEND_TSO);
-	} else {
-		dev->features &=3D ~NETIF_F_TSO;
-		card->options.large_send =3D QETH_LARGE_SEND_NO;
-	}
-	return rc;
-}
-
-static int qeth_l3_ethtool_set_tx_csum(struct net_device *dev, u32 dat=
a)
-{
-	struct qeth_card *card =3D dev->ml_priv;
-
-	if (data) {
-		if (qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
-			dev->features |=3D NETIF_F_IP_CSUM;
-		else
-			return -EPERM;
-	} else
-		dev->features &=3D ~NETIF_F_IP_CSUM;
-
-	return 0;
-}
-
 static const struct ethtool_ops qeth_l3_ethtool_ops =3D {
 	.get_link =3D ethtool_op_get_link,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D qeth_l3_ethtool_set_tx_csum,
-	.get_rx_csum =3D qeth_l3_ethtool_get_rx_csum,
-	.set_rx_csum =3D qeth_l3_ethtool_set_rx_csum,
-	.get_sg      =3D ethtool_op_get_sg,
-	.set_sg      =3D ethtool_op_set_sg,
-	.get_tso     =3D ethtool_op_get_tso,
-	.set_tso     =3D qeth_l3_ethtool_set_tso,
 	.get_strings =3D qeth_core_get_strings,
 	.get_ethtool_stats =3D qeth_core_get_ethtool_stats,
 	.get_sset_count =3D qeth_core_get_sset_count,
@@ -3347,6 +3293,8 @@ static const struct net_device_ops qeth_l3_netdev=
_ops =3D {
 	.ndo_set_multicast_list =3D qeth_l3_set_multicast_list,
 	.ndo_do_ioctl	   	=3D qeth_l3_do_ioctl,
 	.ndo_change_mtu	   	=3D qeth_change_mtu,
+	.ndo_fix_features   	=3D qeth_l3_fix_features,
+	.ndo_set_features   	=3D qeth_l3_set_features,
 	.ndo_vlan_rx_register	=3D qeth_l3_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	=3D qeth_l3_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid   =3D qeth_l3_vlan_rx_kill_vid,
@@ -3362,6 +3310,8 @@ static const struct net_device_ops qeth_l3_osa_ne=
tdev_ops =3D {
 	.ndo_set_multicast_list =3D qeth_l3_set_multicast_list,
 	.ndo_do_ioctl	   	=3D qeth_l3_do_ioctl,
 	.ndo_change_mtu	   	=3D qeth_change_mtu,
+	.ndo_fix_features   	=3D qeth_l3_fix_features,
+	.ndo_set_features   	=3D qeth_l3_set_features,
 	.ndo_vlan_rx_register	=3D qeth_l3_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	=3D qeth_l3_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid   =3D qeth_l3_vlan_rx_kill_vid,
@@ -3392,8 +3342,6 @@ static int qeth_l3_setup_netdev(struct qeth_card =
*card)
 			if (!(card->info.unique_id & UNIQUE_ID_NOT_BY_CARD))
 				card->dev->dev_id =3D card->info.unique_id &
 							 0xffff;
-			if (!card->info.guestlan)
-				card->dev->features |=3D NETIF_F_GRO;
 		}
 	} else if (card->info.type =3D=3D QETH_CARD_TYPE_IQD) {
 		card->dev =3D alloc_netdev(0, "hsi%d", ether_setup);
@@ -3409,6 +3357,8 @@ static int qeth_l3_setup_netdev(struct qeth_card =
*card)
 	card->dev->watchdog_timeo =3D QETH_TX_TIMEOUT;
 	card->dev->mtu =3D card->info.initial_mtu;
 	SET_ETHTOOL_OPS(card->dev, &qeth_l3_ethtool_ops);
+	card->dev->hw_features =3D NETIF_F_SG | NETIF_F_RXCSUM |
+		NETIF_F_IP_CSUM | NETIF_F_TSO;
 	card->dev->features |=3D	NETIF_F_HW_VLAN_TX |
 				NETIF_F_HW_VLAN_RX |
 				NETIF_F_HW_VLAN_FILTER;
@@ -3516,7 +3466,6 @@ contin:
 		rc =3D qeth_l3_start_ipassists(card);
 		if (rc)
 			QETH_DBF_TEXT_(SETUP, 2, "3err%d", rc);
-		qeth_l3_set_large_send(card, card->options.large_send);
 		rc =3D qeth_l3_setrouting_v4(card);
 		if (rc)
 			QETH_DBF_TEXT_(SETUP, 2, "4err%d", rc);
diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_=
sys.c
index 67cfa68..bf9f003 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -410,39 +410,42 @@ static ssize_t qeth_l3_dev_large_send_show(struct=
 device *dev,
 	if (!card)
 		return -EINVAL;
=20
-	switch (card->options.large_send) {
-	case QETH_LARGE_SEND_NO:
+	if (!(card->dev->features & NETIF_F_TSO))
 		return sprintf(buf, "%s\n", "no");
-	case QETH_LARGE_SEND_TSO:
+	else
 		return sprintf(buf, "%s\n", "TSO");
-	default:
-		return sprintf(buf, "%s\n", "N/A");
-	}
 }
=20
 static ssize_t qeth_l3_dev_large_send_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
-	struct qeth_card *card =3D dev_get_drvdata(dev);
-	enum qeth_large_send_types type;
-	int rc =3D 0;
+	struct qeth_card *card;
 	char *tmp;
+	int enable;
=20
 	if (!card)
 		return -EINVAL;
 	tmp =3D strsep((char **) &buf, "\n");
 	if (!strcmp(tmp, "no"))
-		type =3D QETH_LARGE_SEND_NO;
+		enable =3D 0;
 	else if (!strcmp(tmp, "TSO"))
-		type =3D QETH_LARGE_SEND_TSO;
+		enable =3D 1;
 	else
 		return -EINVAL;
=20
-	mutex_lock(&card->conf_mutex);
-	if (card->options.large_send !=3D type)
-		rc =3D qeth_l3_set_large_send(card, type);
-	mutex_unlock(&card->conf_mutex);
-	return rc ? rc : count;
+	rtnl_lock();
+
+	card =3D dev_get_drvdata(dev);
+
+	if (enable)
+		card->dev->wanted_features |=3D NETIF_F_TSO;
+	else
+		card->dev->wanted_features &=3D ~NETIF_F_TSO;
+	netdev_update_features(card->dev);
+
+	rtnl_unlock();
+
+	return count;
 }
=20
 static DEVICE_ATTR(large_send, 0644, qeth_l3_dev_large_send_show,
--=20
1.7.2.5

