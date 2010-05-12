From: frank.blaschka@de.ibm.com
Subject: [patch 3/3] [PATCH] qeth: synchronize configuration interface
Date: Wed, 12 May 2010 07:34:47 +0200
Message-ID: <20100512053528.753949000@de.ibm.com>
References: <20100512053444.035939000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:51174 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab0ELFfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 01:35:30 -0400
Content-Disposition: inline; filename=609-qeth-sync-conf.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Synchronize access to the drivers configuration interface.
Also do not allow configuration changes during online/offline
transition.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    1 
 drivers/s390/net/qeth_core_main.c |    1 
 drivers/s390/net/qeth_core_sys.c  |  148 ++++++++++++++---------
 drivers/s390/net/qeth_l2_main.c   |    8 +
 drivers/s390/net/qeth_l3_main.c   |    8 +
 drivers/s390/net/qeth_l3_sys.c    |  244 +++++++++++++++++++++-----------------
 6 files changed, 242 insertions(+), 168 deletions(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -740,6 +740,7 @@ struct qeth_card {
 	atomic_t force_alloc_skb;
 	struct service_level qeth_service_level;
 	struct qdio_ssqd_desc ssqd;
+	struct mutex conf_mutex;
 };
 
 struct qeth_card_list_struct {
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1100,6 +1100,7 @@ static int qeth_setup_card(struct qeth_c
 	spin_lock_init(&card->lock);
 	spin_lock_init(&card->ip_lock);
 	spin_lock_init(&card->thread_mask_lock);
+	mutex_init(&card->conf_mutex);
 	card->thread_start_mask = 0;
 	card->thread_allowed_mask = 0;
 	card->thread_running_mask = 0;
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -122,23 +122,32 @@ static ssize_t qeth_dev_portno_store(str
 	struct qeth_card *card = dev_get_drvdata(dev);
 	char *tmp;
 	unsigned int portno, limit;
+	int rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	if ((card->state != CARD_STATE_DOWN) &&
-	    (card->state != CARD_STATE_RECOVER))
-		return -EPERM;
+	    (card->state != CARD_STATE_RECOVER)) {
+		rc = -EPERM;
+		goto out;
+	}
 
 	portno = simple_strtoul(buf, &tmp, 16);
-	if (portno > QETH_MAX_PORTNO)
-		return -EINVAL;
+	if (portno > QETH_MAX_PORTNO) {
+		rc = -EINVAL;
+		goto out;
+	}
 	limit = (card->ssqd.pcnt ? card->ssqd.pcnt - 1 : card->ssqd.pcnt);
-	if (portno > limit)
-		return -EINVAL;
-
+	if (portno > limit) {
+		rc = -EINVAL;
+		goto out;
+	}
 	card->info.portno = portno;
-	return count;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static DEVICE_ATTR(portno, 0644, qeth_dev_portno_show, qeth_dev_portno_store);
@@ -165,18 +174,23 @@ static ssize_t qeth_dev_portname_store(s
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
 	char *tmp;
-	int i;
+	int i, rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	if ((card->state != CARD_STATE_DOWN) &&
-	    (card->state != CARD_STATE_RECOVER))
-		return -EPERM;
+	    (card->state != CARD_STATE_RECOVER)) {
+		rc = -EPERM;
+		goto out;
+	}
 
 	tmp = strsep((char **) &buf, "\n");
-	if ((strlen(tmp) > 8) || (strlen(tmp) == 0))
-		return -EINVAL;
+	if ((strlen(tmp) > 8) || (strlen(tmp) == 0)) {
+		rc = -EINVAL;
+		goto out;
+	}
 
 	card->info.portname[0] = strlen(tmp);
 	/* for beauty reasons */
@@ -184,8 +198,9 @@ static ssize_t qeth_dev_portname_store(s
 		card->info.portname[i] = ' ';
 	strcpy(card->info.portname + 1, tmp);
 	ASCEBC(card->info.portname + 1, 8);
-
-	return count;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static DEVICE_ATTR(portname, 0644, qeth_dev_portname_show,
@@ -215,20 +230,25 @@ static ssize_t qeth_dev_prioqing_store(s
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
 	char *tmp;
+	int rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	if ((card->state != CARD_STATE_DOWN) &&
-	    (card->state != CARD_STATE_RECOVER))
-		return -EPERM;
+	    (card->state != CARD_STATE_RECOVER)) {
+		rc = -EPERM;
+		goto out;
+	}
 
 	/* check if 1920 devices are supported ,
 	 * if though we have to permit priority queueing
 	 */
 	if (card->qdio.no_out_queues == 1) {
 		card->qdio.do_prio_queueing = QETH_PRIOQ_DEFAULT;
-		return -EPERM;
+		rc = -EPERM;
+		goto out;
 	}
 
 	tmp = strsep((char **) &buf, "\n");
@@ -251,10 +271,11 @@ static ssize_t qeth_dev_prioqing_store(s
 	} else if (!strcmp(tmp, "no_prio_queueing")) {
 		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
 		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
-	} else {
-		return -EINVAL;
-	}
-	return count;
+	} else
+		rc = -EINVAL;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static DEVICE_ATTR(priority_queueing, 0644, qeth_dev_prioqing_show,
@@ -277,14 +298,17 @@ static ssize_t qeth_dev_bufcnt_store(str
 	struct qeth_card *card = dev_get_drvdata(dev);
 	char *tmp;
 	int cnt, old_cnt;
-	int rc;
+	int rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	if ((card->state != CARD_STATE_DOWN) &&
-	    (card->state != CARD_STATE_RECOVER))
-		return -EPERM;
+	    (card->state != CARD_STATE_RECOVER)) {
+		rc = -EPERM;
+		goto out;
+	}
 
 	old_cnt = card->qdio.in_buf_pool.buf_count;
 	cnt = simple_strtoul(buf, &tmp, 10);
@@ -293,7 +317,9 @@ static ssize_t qeth_dev_bufcnt_store(str
 	if (old_cnt != cnt) {
 		rc = qeth_realloc_buffer_pool(card, cnt);
 	}
-	return count;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static DEVICE_ATTR(buffer_count, 0644, qeth_dev_bufcnt_show,
@@ -337,25 +363,27 @@ static ssize_t qeth_dev_performance_stat
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
 	char *tmp;
-	int i;
+	int i, rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	i = simple_strtoul(buf, &tmp, 16);
 	if ((i == 0) || (i == 1)) {
 		if (i == card->options.performance_stats)
-			return count;
+			goto out;;
 		card->options.performance_stats = i;
 		if (i == 0)
 			memset(&card->perf_stats, 0,
 				sizeof(struct qeth_perf_stats));
 		card->perf_stats.initial_rx_packets = card->stats.rx_packets;
 		card->perf_stats.initial_tx_packets = card->stats.tx_packets;
-	} else {
-		return -EINVAL;
-	}
-	return count;
+	} else
+		rc = -EINVAL;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static DEVICE_ATTR(performance_stats, 0644, qeth_dev_performance_stats_show,
@@ -377,15 +405,17 @@ static ssize_t qeth_dev_layer2_store(str
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
 	char *tmp;
-	int i, rc;
+	int i, rc = 0;
 	enum qeth_discipline_id newdis;
 
 	if (!card)
 		return -EINVAL;
 
-	if (((card->state != CARD_STATE_DOWN) &&
-	     (card->state != CARD_STATE_RECOVER)))
-		return -EPERM;
+	mutex_lock(&card->conf_mutex);
+	if (card->state != CARD_STATE_DOWN) {
+		rc = -EPERM;
+		goto out;
+	}
 
 	i = simple_strtoul(buf, &tmp, 16);
 	switch (i) {
@@ -396,12 +426,13 @@ static ssize_t qeth_dev_layer2_store(str
 		newdis = QETH_DISCIPLINE_LAYER2;
 		break;
 	default:
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out;
 	}
 
-	if (card->options.layer2 == newdis) {
-		return count;
-	} else {
+	if (card->options.layer2 == newdis)
+		goto out;
+	else {
 		if (card->discipline.ccwgdriver) {
 			card->discipline.ccwgdriver->remove(card->gdev);
 			qeth_core_free_discipline(card);
@@ -410,12 +441,12 @@ static ssize_t qeth_dev_layer2_store(str
 
 	rc = qeth_core_load_discipline(card, newdis);
 	if (rc)
-		return rc;
+		goto out;
 
 	rc = card->discipline.ccwgdriver->probe(card->gdev);
-	if (rc)
-		return rc;
-	return count;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static DEVICE_ATTR(layer2, 0644, qeth_dev_layer2_show,
@@ -454,11 +485,10 @@ static ssize_t qeth_dev_isolation_store(
 	char *tmp, *curtoken;
 	curtoken = (char *) buf;
 
-	if (!card) {
-		rc = -EINVAL;
-		goto out;
-	}
+	if (!card)
+		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	/* check for unknown, too, in case we do not yet know who we are */
 	if (card->info.type != QETH_CARD_TYPE_OSAE &&
 	    card->info.type != QETH_CARD_TYPE_UNKNOWN) {
@@ -491,6 +521,7 @@ static ssize_t qeth_dev_isolation_store(
 			rc = ipa_rc;
 	}
 out:
+	mutex_unlock(&card->conf_mutex);
 	return rc;
 }
 
@@ -510,22 +541,25 @@ static ssize_t qeth_dev_blkt_store(struc
 		const char *buf, size_t count, int *value, int max_value)
 {
 	char *tmp;
-	int i;
+	int i, rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	if ((card->state != CARD_STATE_DOWN) &&
-	    (card->state != CARD_STATE_RECOVER))
-		return -EPERM;
-
+	    (card->state != CARD_STATE_RECOVER)) {
+		rc = -EPERM;
+		goto out;
+	}
 	i = simple_strtoul(buf, &tmp, 10);
-	if (i <= max_value) {
+	if (i <= max_value)
 		*value = i;
-	} else {
-		return -EINVAL;
-	}
-	return count;
+	else
+		rc = -EINVAL;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static ssize_t qeth_dev_blkt_total_show(struct device *dev,
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -924,6 +924,7 @@ static int __qeth_l2_set_online(struct c
 	enum qeth_card_states recover_flag;
 
 	BUG_ON(!card);
+	mutex_lock(&card->conf_mutex);
 	QETH_DBF_TEXT(SETUP, 2, "setonlin");
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
@@ -956,7 +957,7 @@ static int __qeth_l2_set_online(struct c
 			dev_warn(&card->gdev->dev,
 				"The LAN is offline\n");
 			card->lan_online = 0;
-			return 0;
+			goto out;
 		}
 		rc = -ENODEV;
 		goto out_remove;
@@ -995,6 +996,8 @@ static int __qeth_l2_set_online(struct c
 	}
 	/* let user_space know that device is online */
 	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);
+out:
+	mutex_unlock(&card->conf_mutex);
 	return 0;
 
 out_remove:
@@ -1007,6 +1010,7 @@ out_remove:
 		card->state = CARD_STATE_RECOVER;
 	else
 		card->state = CARD_STATE_DOWN;
+	mutex_unlock(&card->conf_mutex);
 	return rc;
 }
 
@@ -1022,6 +1026,7 @@ static int __qeth_l2_set_offline(struct 
 	int rc = 0, rc2 = 0, rc3 = 0;
 	enum qeth_card_states recover_flag;
 
+	mutex_lock(&card->conf_mutex);
 	QETH_DBF_TEXT(SETUP, 3, "setoffl");
 	QETH_DBF_HEX(SETUP, 3, &card, sizeof(void *));
 
@@ -1040,6 +1045,7 @@ static int __qeth_l2_set_offline(struct 
 		card->state = CARD_STATE_RECOVER;
 	/* let user_space know that device is offline */
 	kobject_uevent(&cgdev->dev.kobj, KOBJ_CHANGE);
+	mutex_unlock(&card->conf_mutex);
 	return 0;
 }
 
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3378,6 +3378,7 @@ static int __qeth_l3_set_online(struct c
 	enum qeth_card_states recover_flag;
 
 	BUG_ON(!card);
+	mutex_lock(&card->conf_mutex);
 	QETH_DBF_TEXT(SETUP, 2, "setonlin");
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
@@ -3409,7 +3410,7 @@ static int __qeth_l3_set_online(struct c
 			dev_warn(&card->gdev->dev,
 				"The LAN is offline\n");
 			card->lan_online = 0;
-			return 0;
+			goto out;
 		}
 		rc = -ENODEV;
 		goto out_remove;
@@ -3456,6 +3457,8 @@ static int __qeth_l3_set_online(struct c
 	}
 	/* let user_space know that device is online */
 	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);
+out:
+	mutex_unlock(&card->conf_mutex);
 	return 0;
 out_remove:
 	card->use_hard_stop = 1;
@@ -3467,6 +3470,7 @@ out_remove:
 		card->state = CARD_STATE_RECOVER;
 	else
 		card->state = CARD_STATE_DOWN;
+	mutex_unlock(&card->conf_mutex);
 	return rc;
 }
 
@@ -3482,6 +3486,7 @@ static int __qeth_l3_set_offline(struct 
 	int rc = 0, rc2 = 0, rc3 = 0;
 	enum qeth_card_states recover_flag;
 
+	mutex_lock(&card->conf_mutex);
 	QETH_DBF_TEXT(SETUP, 3, "setoffl");
 	QETH_DBF_HEX(SETUP, 3, &card, sizeof(void *));
 
@@ -3500,6 +3505,7 @@ static int __qeth_l3_set_offline(struct 
 		card->state = CARD_STATE_RECOVER;
 	/* let user_space know that device is offline */
 	kobject_uevent(&cgdev->dev.kobj, KOBJ_CHANGE);
+	mutex_unlock(&card->conf_mutex);
 	return 0;
 }
 
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -70,10 +70,10 @@ static ssize_t qeth_l3_dev_route_store(s
 {
 	enum qeth_routing_types old_route_type = route->type;
 	char *tmp;
-	int rc;
+	int rc = 0;
 
 	tmp = strsep((char **) &buf, "\n");
-
+	mutex_lock(&card->conf_mutex);
 	if (!strcmp(tmp, "no_router")) {
 		route->type = NO_ROUTER;
 	} else if (!strcmp(tmp, "primary_connector")) {
@@ -87,7 +87,8 @@ static ssize_t qeth_l3_dev_route_store(s
 	} else if (!strcmp(tmp, "multicast_router")) {
 		route->type = MULTICAST_ROUTER;
 	} else {
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out;
 	}
 	if (((card->state == CARD_STATE_SOFTSETUP) ||
 	     (card->state == CARD_STATE_UP)) &&
@@ -97,7 +98,9 @@ static ssize_t qeth_l3_dev_route_store(s
 		else if (prot == QETH_PROT_IPV6)
 			rc = qeth_l3_setrouting_v6(card);
 	}
-	return count;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static ssize_t qeth_l3_dev_route4_store(struct device *dev,
@@ -157,22 +160,26 @@ static ssize_t qeth_l3_dev_fake_broadcas
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
 	char *tmp;
-	int i;
+	int i, rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	if ((card->state != CARD_STATE_DOWN) &&
-	    (card->state != CARD_STATE_RECOVER))
-		return -EPERM;
+	    (card->state != CARD_STATE_RECOVER)) {
+		rc = -EPERM;
+		goto out;
+	}
 
 	i = simple_strtoul(buf, &tmp, 16);
 	if ((i == 0) || (i == 1))
 		card->options.fake_broadcast = i;
-	else {
-		return -EINVAL;
-	}
-	return count;
+	else
+		rc = -EINVAL;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static DEVICE_ATTR(fake_broadcast, 0644, qeth_l3_dev_fake_broadcast_show,
@@ -200,31 +207,35 @@ static ssize_t qeth_l3_dev_broadcast_mod
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
 	char *tmp;
+	int rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	if ((card->state != CARD_STATE_DOWN) &&
-	    (card->state != CARD_STATE_RECOVER))
-		return -EPERM;
+	    (card->state != CARD_STATE_RECOVER)) {
+		rc = -EPERM;
+		goto out;
+	}
 
 	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
 	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR))) {
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out;
 	}
 
 	tmp = strsep((char **) &buf, "\n");
 
-	if (!strcmp(tmp, "local")) {
+	if (!strcmp(tmp, "local"))
 		card->options.broadcast_mode = QETH_TR_BROADCAST_LOCAL;
-		return count;
-	} else if (!strcmp(tmp, "all_rings")) {
+	else if (!strcmp(tmp, "all_rings"))
 		card->options.broadcast_mode = QETH_TR_BROADCAST_ALLRINGS;
-		return count;
-	} else {
-		return -EINVAL;
-	}
-	return count;
+	else
+		rc = -EINVAL;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static DEVICE_ATTR(broadcast_mode, 0644, qeth_l3_dev_broadcast_mode_show,
@@ -251,18 +262,22 @@ static ssize_t qeth_l3_dev_canonical_mac
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
 	char *tmp;
-	int i;
+	int i, rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	if ((card->state != CARD_STATE_DOWN) &&
-	    (card->state != CARD_STATE_RECOVER))
-		return -EPERM;
+	    (card->state != CARD_STATE_RECOVER)) {
+		rc = -EPERM;
+		goto out;
+	}
 
 	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
 	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR))) {
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out;
 	}
 
 	i = simple_strtoul(buf, &tmp, 16);
@@ -270,10 +285,11 @@ static ssize_t qeth_l3_dev_canonical_mac
 		card->options.macaddr_mode = i?
 			QETH_TR_MACADDR_CANONICAL :
 			QETH_TR_MACADDR_NONCANONICAL;
-	else {
-		return -EINVAL;
-	}
-	return count;
+	else
+		rc = -EINVAL;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static DEVICE_ATTR(canonical_macaddr, 0644, qeth_l3_dev_canonical_macaddr_show,
@@ -297,11 +313,12 @@ static ssize_t qeth_l3_dev_checksum_stor
 	struct qeth_card *card = dev_get_drvdata(dev);
 	enum qeth_checksum_types csum_type;
 	char *tmp;
-	int rc;
+	int rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	tmp = strsep((char **) &buf, "\n");
 	if (!strcmp(tmp, "sw_checksumming"))
 		csum_type = SW_CHECKSUMMING;
@@ -309,13 +326,15 @@ static ssize_t qeth_l3_dev_checksum_stor
 		csum_type = HW_CHECKSUMMING;
 	else if (!strcmp(tmp, "no_checksumming"))
 		csum_type = NO_CHECKSUMMING;
-	else
-		return -EINVAL;
+	else {
+		rc = -EINVAL;
+		goto out;
+	}
 
 	rc = qeth_l3_set_rx_csum(card, csum_type);
-	if (rc)
-		return rc;
-	return count;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static DEVICE_ATTR(checksumming, 0644, qeth_l3_dev_checksum_show,
@@ -336,7 +355,7 @@ static ssize_t qeth_l3_dev_sniffer_store
 		struct device_attribute *attr, const char *buf, size_t count)
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
-	int ret;
+	int rc = 0;
 	unsigned long i;
 
 	if (!card)
@@ -345,19 +364,24 @@ static ssize_t qeth_l3_dev_sniffer_store
 	if (card->info.type != QETH_CARD_TYPE_IQD)
 		return -EPERM;
 
+	mutex_lock(&card->conf_mutex);
 	if ((card->state != CARD_STATE_DOWN) &&
-	    (card->state != CARD_STATE_RECOVER))
-		return -EPERM;
+	    (card->state != CARD_STATE_RECOVER)) {
+		rc = -EPERM;
+		goto out;
+	}
 
-	ret = strict_strtoul(buf, 16, &i);
-	if (ret)
-		return -EINVAL;
+	rc = strict_strtoul(buf, 16, &i);
+	if (rc) {
+		rc = -EINVAL;
+		goto out;
+	}
 	switch (i) {
 	case 0:
 		card->options.sniffer = i;
 		break;
 	case 1:
-		ret = qdio_get_ssqd_desc(CARD_DDEV(card), &card->ssqd);
+		qdio_get_ssqd_desc(CARD_DDEV(card), &card->ssqd);
 		if (card->ssqd.qdioac2 & QETH_SNIFF_AVAIL) {
 			card->options.sniffer = i;
 			if (card->qdio.init_pool.buf_count !=
@@ -366,11 +390,13 @@ static ssize_t qeth_l3_dev_sniffer_store
 					QETH_IN_BUF_COUNT_MAX);
 			break;
 		} else
-			return -EPERM;
+			rc = -EPERM;
 	default:   /* fall through */
-		return -EINVAL;
+		rc = -EINVAL;
 	}
-	return count;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static DEVICE_ATTR(sniffer, 0644, qeth_l3_dev_sniffer_show,
@@ -412,12 +438,11 @@ static ssize_t qeth_l3_dev_large_send_st
 	else
 		return -EINVAL;
 
-	if (card->options.large_send == type)
-		return count;
-	rc = qeth_l3_set_large_send(card, type);
-	if (rc)
-		return rc;
-	return count;
+	mutex_lock(&card->conf_mutex);
+	if (card->options.large_send != type)
+		rc = qeth_l3_set_large_send(card, type);
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static DEVICE_ATTR(large_send, 0644, qeth_l3_dev_large_send_show,
@@ -455,13 +480,17 @@ static ssize_t qeth_l3_dev_ipato_enable_
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
 	char *tmp;
+	int rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	if ((card->state != CARD_STATE_DOWN) &&
-	    (card->state != CARD_STATE_RECOVER))
-		return -EPERM;
+	    (card->state != CARD_STATE_RECOVER)) {
+		rc = -EPERM;
+		goto out;
+	}
 
 	tmp = strsep((char **) &buf, "\n");
 	if (!strcmp(tmp, "toggle")) {
@@ -470,10 +499,11 @@ static ssize_t qeth_l3_dev_ipato_enable_
 		card->ipato.enabled = 1;
 	} else if (!strcmp(tmp, "0")) {
 		card->ipato.enabled = 0;
-	} else {
-		return -EINVAL;
-	}
-	return count;
+	} else
+		rc = -EINVAL;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static QETH_DEVICE_ATTR(ipato_enable, enable, 0644,
@@ -497,10 +527,12 @@ static ssize_t qeth_l3_dev_ipato_invert4
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
 	char *tmp;
+	int rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	tmp = strsep((char **) &buf, "\n");
 	if (!strcmp(tmp, "toggle")) {
 		card->ipato.invert4 = (card->ipato.invert4)? 0 : 1;
@@ -508,10 +540,10 @@ static ssize_t qeth_l3_dev_ipato_invert4
 		card->ipato.invert4 = 1;
 	} else if (!strcmp(tmp, "0")) {
 		card->ipato.invert4 = 0;
-	} else {
-		return -EINVAL;
-	}
-	return count;
+	} else
+		rc = -EINVAL;
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static QETH_DEVICE_ATTR(ipato_invert4, invert4, 0644,
@@ -593,27 +625,28 @@ static ssize_t qeth_l3_dev_ipato_add_sto
 	struct qeth_ipato_entry *ipatoe;
 	u8 addr[16];
 	int mask_bits;
-	int rc;
+	int rc = 0;
 
+	mutex_lock(&card->conf_mutex);
 	rc = qeth_l3_parse_ipatoe(buf, proto, addr, &mask_bits);
 	if (rc)
-		return rc;
+		goto out;
 
 	ipatoe = kzalloc(sizeof(struct qeth_ipato_entry), GFP_KERNEL);
 	if (!ipatoe) {
-		return -ENOMEM;
+		rc = -ENOMEM;
+		goto out;
 	}
 	ipatoe->proto = proto;
 	memcpy(ipatoe->addr, addr, (proto == QETH_PROT_IPV4)? 4:16);
 	ipatoe->mask_bits = mask_bits;
 
 	rc = qeth_l3_add_ipato_entry(card, ipatoe);
-	if (rc) {
+	if (rc)
 		kfree(ipatoe);
-		return rc;
-	}
-
-	return count;
+out:
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static ssize_t qeth_l3_dev_ipato_add4_store(struct device *dev,
@@ -636,15 +669,14 @@ static ssize_t qeth_l3_dev_ipato_del_sto
 {
 	u8 addr[16];
 	int mask_bits;
-	int rc;
+	int rc = 0;
 
+	mutex_lock(&card->conf_mutex);
 	rc = qeth_l3_parse_ipatoe(buf, proto, addr, &mask_bits);
-	if (rc)
-		return rc;
-
-	qeth_l3_del_ipato_entry(card, proto, addr, mask_bits);
-
-	return count;
+	if (!rc)
+		qeth_l3_del_ipato_entry(card, proto, addr, mask_bits);
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static ssize_t qeth_l3_dev_ipato_del4_store(struct device *dev,
@@ -677,10 +709,12 @@ static ssize_t qeth_l3_dev_ipato_invert6
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
 	char *tmp;
+	int rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
+	mutex_lock(&card->conf_mutex);
 	tmp = strsep((char **) &buf, "\n");
 	if (!strcmp(tmp, "toggle")) {
 		card->ipato.invert6 = (card->ipato.invert6)? 0 : 1;
@@ -688,10 +722,10 @@ static ssize_t qeth_l3_dev_ipato_invert6
 		card->ipato.invert6 = 1;
 	} else if (!strcmp(tmp, "0")) {
 		card->ipato.invert6 = 0;
-	} else {
-		return -EINVAL;
-	}
-	return count;
+	} else
+		rc = -EINVAL;
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static QETH_DEVICE_ATTR(ipato_invert6, invert6, 0644,
@@ -813,15 +847,12 @@ static ssize_t qeth_l3_dev_vipa_add_stor
 	u8 addr[16] = {0, };
 	int rc;
 
+	mutex_lock(&card->conf_mutex);
 	rc = qeth_l3_parse_vipae(buf, proto, addr);
-	if (rc)
-		return rc;
-
-	rc = qeth_l3_add_vipa(card, proto, addr);
-	if (rc)
-		return rc;
-
-	return count;
+	if (!rc)
+		rc = qeth_l3_add_vipa(card, proto, addr);
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static ssize_t qeth_l3_dev_vipa_add4_store(struct device *dev,
@@ -845,13 +876,12 @@ static ssize_t qeth_l3_dev_vipa_del_stor
 	u8 addr[16];
 	int rc;
 
+	mutex_lock(&card->conf_mutex);
 	rc = qeth_l3_parse_vipae(buf, proto, addr);
-	if (rc)
-		return rc;
-
-	qeth_l3_del_vipa(card, proto, addr);
-
-	return count;
+	if (!rc)
+		qeth_l3_del_vipa(card, proto, addr);
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static ssize_t qeth_l3_dev_vipa_del4_store(struct device *dev,
@@ -979,15 +1009,12 @@ static ssize_t qeth_l3_dev_rxip_add_stor
 	u8 addr[16] = {0, };
 	int rc;
 
+	mutex_lock(&card->conf_mutex);
 	rc = qeth_l3_parse_rxipe(buf, proto, addr);
-	if (rc)
-		return rc;
-
-	rc = qeth_l3_add_rxip(card, proto, addr);
-	if (rc)
-		return rc;
-
-	return count;
+	if (!rc)
+		rc = qeth_l3_add_rxip(card, proto, addr);
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static ssize_t qeth_l3_dev_rxip_add4_store(struct device *dev,
@@ -1011,13 +1038,12 @@ static ssize_t qeth_l3_dev_rxip_del_stor
 	u8 addr[16];
 	int rc;
 
+	mutex_lock(&card->conf_mutex);
 	rc = qeth_l3_parse_rxipe(buf, proto, addr);
-	if (rc)
-		return rc;
-
-	qeth_l3_del_rxip(card, proto, addr);
-
-	return count;
+	if (!rc)
+		qeth_l3_del_rxip(card, proto, addr);
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
 }
 
 static ssize_t qeth_l3_dev_rxip_del4_store(struct device *dev,

