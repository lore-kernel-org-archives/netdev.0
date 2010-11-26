From: frank.blaschka@de.ibm.com
Subject: [patch 1/4] [PATCH] qeth lcs: convert mc rwlock to RCU
Date: Fri, 26 Nov 2010 13:41:17 +0100
Message-ID: <20101126124153.951532622@de.ibm.com>
References: <20101126124116.123736494@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Sachin Sant <sachinp@in.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:59374 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406Ab0KZMmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 07:42:21 -0500
Content-Disposition: inline; filename=qeth_lcs_mc_lock.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Sant <sachinp@in.ibm.com>

Commit 1d7138de878d1d4210727c1200193e69596f93b3
igmp: RCU conversion of in_dev->mc_list

converted rwlock to RCU.

Update the s390 network drivers(qeth & lcs) code to adapt to this change.
V2 : Changes based on suggestions given by Eric Dumazet

Signed-off-by: Sachin Sant <sachinp@in.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/lcs.c          |   10 ++++++----
 drivers/s390/net/qeth_l3_main.c |   11 ++++++-----
 2 files changed, 12 insertions(+), 9 deletions(-)

--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -1188,7 +1188,8 @@ lcs_remove_mc_addresses(struct lcs_card
 	spin_lock_irqsave(&card->ipm_lock, flags);
 	list_for_each(l, &card->ipm_list) {
 		ipm = list_entry(l, struct lcs_ipm_list, list);
-		for (im4 = in4_dev->mc_list; im4 != NULL; im4 = im4->next) {
+		for (im4 = rcu_dereference(in4_dev->mc_list);
+		     im4 != NULL; im4 = rcu_dereference(im4->next_rcu)) {
 			lcs_get_mac_for_ipm(im4->multiaddr, buf, card->dev);
 			if ( (ipm->ipm.ip_addr == im4->multiaddr) &&
 			     (memcmp(buf, &ipm->ipm.mac_addr,
@@ -1233,7 +1234,8 @@ lcs_set_mc_addresses(struct lcs_card *ca
 	unsigned long flags;
 
 	LCS_DBF_TEXT(4, trace, "setmclst");
-	for (im4 = in4_dev->mc_list; im4; im4 = im4->next) {
+	for (im4 = rcu_dereference(in4_dev->mc_list); im4 != NULL;
+	     im4 = rcu_dereference(im4->next_rcu)) {
 		lcs_get_mac_for_ipm(im4->multiaddr, buf, card->dev);
 		ipm = lcs_check_addr_entry(card, im4, buf);
 		if (ipm != NULL)
@@ -1269,10 +1271,10 @@ lcs_register_mc_addresses(void *data)
 	in4_dev = in_dev_get(card->dev);
 	if (in4_dev == NULL)
 		goto out;
-	read_lock(&in4_dev->mc_list_lock);
+	rcu_read_lock();
 	lcs_remove_mc_addresses(card,in4_dev);
 	lcs_set_mc_addresses(card, in4_dev);
-	read_unlock(&in4_dev->mc_list_lock);
+	rcu_read_unlock();
 	in_dev_put(in4_dev);
 
 	netif_carrier_off(card->dev);
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1796,7 +1796,8 @@ static void qeth_l3_add_mc(struct qeth_c
 	char buf[MAX_ADDR_LEN];
 
 	QETH_CARD_TEXT(card, 4, "addmc");
-	for (im4 = in4_dev->mc_list; im4; im4 = im4->next) {
+	for (im4 = rcu_dereference(in4_dev->mc_list); im4 != NULL;
+	     im4 = rcu_dereference(im4->next_rcu)) {
 		qeth_l3_get_mac_for_ipm(im4->multiaddr, buf, in4_dev->dev);
 		ipm = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
 		if (!ipm)
@@ -1828,9 +1829,9 @@ static void qeth_l3_add_vlan_mc(struct q
 		in_dev = in_dev_get(netdev);
 		if (!in_dev)
 			continue;
-		read_lock(&in_dev->mc_list_lock);
+		rcu_read_lock();
 		qeth_l3_add_mc(card, in_dev);
-		read_unlock(&in_dev->mc_list_lock);
+		rcu_read_unlock();
 		in_dev_put(in_dev);
 	}
 }
@@ -1843,10 +1844,10 @@ static void qeth_l3_add_multicast_ipv4(s
 	in4_dev = in_dev_get(card->dev);
 	if (in4_dev == NULL)
 		return;
-	read_lock(&in4_dev->mc_list_lock);
+	rcu_read_lock();
 	qeth_l3_add_mc(card, in4_dev);
 	qeth_l3_add_vlan_mc(card);
-	read_unlock(&in4_dev->mc_list_lock);
+	rcu_read_unlock();
 	in_dev_put(in4_dev);
 }
 

