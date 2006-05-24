From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 2/5] s390: qeth driver fixes
Date: Wed, 24 May 2006 09:51:11 +0200
Message-ID: <20060524095111.4d4f2992@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:32112 "EHLO
	mtagate3.de.ibm.com") by vger.kernel.org with ESMTP id S932647AbWEXHus
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 03:50:48 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.6/8.13.6) with ESMTP id k4O7okDt036688
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 07:50:46 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4O7qPkc139268
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 09:52:25 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k4O7okcQ029053
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 09:50:46 +0200
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Ursula Braun <braunu@de.ibm.com>
From: Frank Pavlic <fpavlic@de.ibm.com>

	- correct checking of sscanf-%n value in qeth_string_to_ipaddr().
	- don't use netif_stop_queue outside the hard_start_xmit routine. 
	  Rather use netif_tx_disable.
	- don't call qeth_netdev_init on a recovery.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/qeth.h      |    2 +-
 drivers/s390/net/qeth_main.c |   22 +++++++++++-----------
 2 files changed, 12 insertions(+), 12 deletions(-)

ef153db1ac07db7ec4eba2ec29237c58944b5c7b
diff --git a/drivers/s390/net/qeth.h b/drivers/s390/net/qeth.h
index 4df0fcd..65e2b1b 100644
--- a/drivers/s390/net/qeth.h
+++ b/drivers/s390/net/qeth.h
@@ -1099,7 +1099,7 @@ qeth_string_to_ipaddr4(const char *buf, 
 
 	rc = sscanf(buf, "%d.%d.%d.%d%n", 
 		    &in[0], &in[1], &in[2], &in[3], &count);
-	if (rc != 4  || count) 
+	if (rc != 4  || count<=0)
 		return -EINVAL;
 	for (count = 0; count < 4; count++) {
 		if (in[count] > 255)
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index cb14642..0f6648f 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -3817,7 +3817,7 @@ qeth_stop(struct net_device *dev)
 
 	card = (struct qeth_card *) dev->priv;
 
-	netif_stop_queue(dev);
+	netif_tx_disable(dev);
 	card->dev->flags &= ~IFF_UP;
 	if (card->state == CARD_STATE_UP)
 		card->state = CARD_STATE_SOFTSETUP;
@@ -6359,12 +6359,9 @@ qeth_netdev_init(struct net_device *dev)
 	dev->vlan_rx_kill_vid = qeth_vlan_rx_kill_vid;
 	dev->vlan_rx_add_vid = qeth_vlan_rx_add_vid;
 #endif
-	dev->hard_header = card->orig_hard_header;
 	if (qeth_get_netdev_flags(card) & IFF_NOARP) {
 		dev->rebuild_header = NULL;
 		dev->hard_header = NULL;
-		if (card->options.fake_ll)
-			dev->hard_header = qeth_fake_header;
 		dev->header_cache_update = NULL;
 		dev->hard_header_cache = NULL;
 	}
@@ -6477,6 +6474,9 @@ retry:
 	/*network device will be recovered*/
 	if (card->dev) {
 		card->dev->hard_header = card->orig_hard_header;
+		if (card->options.fake_ll && 
+		    (qeth_get_netdev_flags(card) & IFF_NOARP))
+			card->dev->hard_header = qeth_fake_header;
 		return 0;
 	}
 	/* at first set_online allocate netdev */
@@ -7031,7 +7031,7 @@ qeth_softsetup_ipv6(struct qeth_card *ca
 
 	QETH_DBF_TEXT(trace,3,"softipv6");
 
-	netif_stop_queue(card->dev);
+	netif_tx_disable(card->dev);
 	rc = qeth_send_startlan(card, QETH_PROT_IPV6);
 	if (rc) {
 		PRINT_ERR("IPv6 startlan failed on %s\n",
@@ -7352,7 +7352,8 @@ qeth_set_large_send(struct qeth_card *ca
 		card->options.large_send = type;
 		return 0;
 	}
-	netif_stop_queue(card->dev);
+	if (card->state == CARD_STATE_UP)
+		netif_tx_disable(card->dev);
 	card->options.large_send = type;
 	switch (card->options.large_send) {
 	case QETH_LARGE_SEND_EDDP:
@@ -7374,7 +7375,8 @@ qeth_set_large_send(struct qeth_card *ca
 		card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG);
 		break;
 	}
-	netif_wake_queue(card->dev);
+	if (card->state == CARD_STATE_UP)
+		netif_wake_queue(card->dev);
 	return rc;
 }
 
@@ -7427,7 +7429,7 @@ qeth_softsetup_card(struct qeth_card *ca
 	if ((rc = qeth_setrouting_v6(card)))
 		QETH_DBF_TEXT_(setup, 2, "5err%d", rc);
 out:
-	netif_stop_queue(card->dev);
+	netif_tx_disable(card->dev);
 	return 0;
 }
 
@@ -7736,10 +7738,8 @@ static int
 qeth_register_netdev(struct qeth_card *card)
 {
 	QETH_DBF_TEXT(setup, 3, "regnetd");
-	if (card->dev->reg_state != NETREG_UNINITIALIZED) {
-		qeth_netdev_init(card->dev);
+	if (card->dev->reg_state != NETREG_UNINITIALIZED) 
 		return 0;
-	}
 	/* sysfs magic */
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
 	return register_netdev(card->dev);
-- 
1.2.4

