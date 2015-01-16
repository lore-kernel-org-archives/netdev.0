From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 3/5] qeth: use qeth_card_hw_is_reachable() everywhere
Date: Fri, 16 Jan 2015 14:05:47 +0100
Message-ID: <1421413549-56937-4-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1421413549-56937-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Eugene Crosser <Eugene.Crosser@ru.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:53184 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755443AbbAPNGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 08:06:39 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 16 Jan 2015 13:06:37 -0000
In-Reply-To: <1421413549-56937-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

qeth_card_hw_is_reachable() was introduced as part of a new
functionality, but it is a useful abstraction that can replace
verbose checks througout the rest of the `qeth` driver.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Reviewed-by: Thomas-Mich Richter <tmricht@de.ibm.com>
---
 drivers/s390/net/qeth_core_sys.c | 7 +++----
 drivers/s390/net/qeth_l2_main.c  | 6 ++----
 drivers/s390/net/qeth_l3_main.c  | 7 ++-----
 drivers/s390/net/qeth_l3_sys.c   | 3 +--
 4 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/drivers/s390/net/qeth_core_sys.c b/drivers/s390/net/qeth_core_sys.c
index 15523f0..8c76574 100644
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -531,8 +531,7 @@ static ssize_t qeth_dev_isolation_store(struct device *dev,
 	/* defer IP assist if device is offline (until discipline->set_online)*/
 	card->options.prev_isolation = card->options.isolation;
 	card->options.isolation = isolation;
-	if (card->state == CARD_STATE_SOFTSETUP ||
-	    card->state == CARD_STATE_UP) {
+	if (qeth_card_hw_is_reachable(card)) {
 		int ipa_rc = qeth_set_access_ctrl_online(card, 1);
 		if (ipa_rc != 0)
 			rc = ipa_rc;
@@ -555,7 +554,7 @@ static ssize_t qeth_dev_switch_attrs_show(struct device *dev,
 	if (!card)
 		return -EINVAL;
 
-	if (card->state != CARD_STATE_SOFTSETUP && card->state != CARD_STATE_UP)
+	if (!qeth_card_hw_is_reachable(card))
 		return sprintf(buf, "n/a\n");
 
 	rc = qeth_query_switch_attributes(card, &sw_info);
@@ -606,7 +605,7 @@ static ssize_t qeth_hw_trap_store(struct device *dev,
 		return -EINVAL;
 
 	mutex_lock(&card->conf_mutex);
-	if (card->state == CARD_STATE_SOFTSETUP || card->state == CARD_STATE_UP)
+	if (qeth_card_hw_is_reachable(card))
 		state = 1;
 	tmp = strsep(&curtoken, "\n");
 
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index d02cd1a..f5f409d 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -48,8 +48,7 @@ static int qeth_l2_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!card)
 		return -ENODEV;
 
-	if ((card->state != CARD_STATE_UP) &&
-		(card->state != CARD_STATE_SOFTSETUP))
+	if (!qeth_card_hw_is_reachable(card))
 		return -ENODEV;
 
 	if (card->info.type == QETH_CARD_TYPE_OSN)
@@ -1344,8 +1343,7 @@ int qeth_osn_assist(struct net_device *dev, void *data, int data_len)
 	if (!card)
 		return -ENODEV;
 	QETH_CARD_TEXT(card, 2, "osnsdmc");
-	if ((card->state != CARD_STATE_UP) &&
-	    (card->state != CARD_STATE_SOFTSETUP))
+	if (!qeth_card_hw_is_reachable(card))
 		return -ENODEV;
 	iob = qeth_wait_for_buffer(&card->write);
 	memcpy(iob->data+IPA_PDU_HEADER_SIZE, data, data_len);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index dd4ab8d..1432b10 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -432,10 +432,8 @@ void qeth_l3_set_ip_addr_list(struct qeth_card *card)
 	QETH_CARD_TEXT(card, 2, "sdiplist");
 	QETH_CARD_HEX(card, 2, &card, sizeof(void *));
 
-	if ((card->state != CARD_STATE_UP &&
-	     card->state != CARD_STATE_SOFTSETUP) || card->options.sniffer) {
+	if (!qeth_card_hw_is_reachable(card) || card->options.sniffer)
 		return;
-	}
 
 	spin_lock_irqsave(&card->ip_lock, flags);
 	tbd_list = card->ip_tbd_list;
@@ -2626,8 +2624,7 @@ static int qeth_l3_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!card)
 		return -ENODEV;
 
-	if ((card->state != CARD_STATE_UP) &&
-		(card->state != CARD_STATE_SOFTSETUP))
+	if (!qeth_card_hw_is_reachable(card))
 		return -ENODEV;
 
 	switch (cmd) {
diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_sys.c
index adef5f5..c4dcd66 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -78,8 +78,7 @@ static ssize_t qeth_l3_dev_route_store(struct qeth_card *card,
 		rc = -EINVAL;
 		goto out;
 	}
-	if (((card->state == CARD_STATE_SOFTSETUP) ||
-	     (card->state == CARD_STATE_UP)) &&
+	if (qeth_card_hw_is_reachable(card) &&
 	    (old_route_type != route->type)) {
 		if (prot == QETH_PROT_IPV4)
 			rc = qeth_l3_setrouting_v4(card);
-- 
2.1.4
