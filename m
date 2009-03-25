From: frank.blaschka@de.ibm.com
Subject: [patch 5/6] [PATCH] qeth: check for completion of a running recovery
Date: Wed, 25 Mar 2009 07:57:18 +0100
Message-ID: <20090325065809.218719000@de.ibm.com>
References: <20090325065713.054133000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:47647 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755449AbZCYG6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:58:12 -0400
Content-Disposition: inline; filename=618-qeth-recovery.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

When a recovery is started for a qeth device, additional invocations
to change a mac address, to configure a VLAN interface on top, or to
add multicast addresses should wait till recovery is finished,
otherwise recovery might fail.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l2_main.c |   15 +++++++++++++++
 drivers/s390/net/qeth_l3_main.c |    7 +++++++
 2 files changed, 22 insertions(+)

diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2009-03-20 09:46:53.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2009-03-20 09:46:53.000000000 +0100
@@ -327,6 +327,10 @@ static void qeth_l2_vlan_rx_add_vid(stru
 	struct qeth_vlan_vid *id;
 
 	QETH_DBF_TEXT_(TRACE, 4, "aid:%d", vid);
+	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
+		QETH_DBF_TEXT(TRACE, 3, "aidREC");
+		return;
+	}
 	id = kmalloc(sizeof(struct qeth_vlan_vid), GFP_ATOMIC);
 	if (id) {
 		id->vid = vid;
@@ -343,6 +347,10 @@ static void qeth_l2_vlan_rx_kill_vid(str
 	struct qeth_card *card = dev->ml_priv;
 
 	QETH_DBF_TEXT_(TRACE, 4, "kid:%d", vid);
+	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
+		QETH_DBF_TEXT(TRACE, 3, "kidREC");
+		return;
+	}
 	spin_lock_bh(&card->vlanlock);
 	list_for_each_entry(id, &card->vid_list, list) {
 		if (id->vid == vid) {
@@ -594,6 +602,10 @@ static int qeth_l2_set_mac_address(struc
 	}
 	QETH_DBF_TEXT_(TRACE, 3, "%s", CARD_BUS_ID(card));
 	QETH_DBF_HEX(TRACE, 3, addr->sa_data, OSA_ADDR_LEN);
+	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
+		QETH_DBF_TEXT(TRACE, 3, "setmcREC");
+		return -ERESTARTSYS;
+	}
 	rc = qeth_l2_send_delmac(card, &card->dev->dev_addr[0]);
 	if (!rc)
 		rc = qeth_l2_send_setmac(card, addr->sa_data);
@@ -609,6 +621,9 @@ static void qeth_l2_set_multicast_list(s
 		return ;
 
 	QETH_DBF_TEXT(TRACE, 3, "setmulti");
+	if (qeth_threads_running(card, QETH_RECOVER_THREAD) &&
+	    (card->state != CARD_STATE_UP))
+		return;
 	qeth_l2_del_all_mc(card);
 	spin_lock_bh(&card->mclock);
 	for (dm = dev->mc_list; dm; dm = dm->next)
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2009-03-20 09:46:52.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2009-03-20 09:46:53.000000000 +0100
@@ -1838,6 +1838,10 @@ static void qeth_l3_vlan_rx_kill_vid(str
 	unsigned long flags;
 
 	QETH_DBF_TEXT_(TRACE, 4, "kid:%d", vid);
+	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
+		QETH_DBF_TEXT(TRACE, 3, "kidREC");
+		return;
+	}
 	spin_lock_irqsave(&card->vlanlock, flags);
 	/* unregister IP addresses of vlan device */
 	qeth_l3_free_vlan_addresses(card, vid);
@@ -2101,6 +2105,9 @@ static void qeth_l3_set_multicast_list(s
 	struct qeth_card *card = dev->ml_priv;
 
 	QETH_DBF_TEXT(TRACE, 3, "setmulti");
+	if (qeth_threads_running(card, QETH_RECOVER_THREAD) &&
+	    (card->state != CARD_STATE_UP))
+		return;
 	qeth_l3_delete_mc_addresses(card);
 	qeth_l3_add_multicast_ipv4(card);
 #ifdef CONFIG_QETH_IPV6

