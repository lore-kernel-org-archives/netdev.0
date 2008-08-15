From: frank.blaschka@de.ibm.com
Subject: [patch 2/3] qeth: l2 write unicast list to hardware
Date: Fri, 15 Aug 2008 08:02:59 +0200
Message-ID: <20080815060352.278494000@de.ibm.com>
References: <20080815060257.501264000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:48381 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbYHOGD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 02:03:56 -0400
Content-Disposition: inline; filename=601-qeth-unicast.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

In case the netdev unicast list contains additional entries we have
to register/deregister them.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h    |    1 +
 drivers/s390/net/qeth_l2_main.c |   27 ++++++++++++++++++++++-----
 2 files changed, 23 insertions(+), 5 deletions(-)

Index: git_linus/drivers/s390/net/qeth_core.h
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_core.h	2008-08-08 13:57:27.000000000 +0200
+++ git_linus/drivers/s390/net/qeth_core.h	2008-08-15 07:50:15.000000000 +0200
@@ -689,6 +689,7 @@
 	struct list_head list;
 	__u8 mc_addr[MAX_ADDR_LEN];
 	unsigned char mc_addrlen;
+	int is_vmac;
 };
 
 struct qeth_card {
Index: git_linus/drivers/s390/net/qeth_l2_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_l2_main.c	2008-08-08 13:57:27.000000000 +0200
+++ git_linus/drivers/s390/net/qeth_l2_main.c	2008-08-15 07:50:15.000000000 +0200
@@ -177,9 +177,10 @@
 					  qeth_l2_send_delgroupmac_cb);
 }
 
-static void qeth_l2_add_mc(struct qeth_card *card, __u8 *mac)
+static void qeth_l2_add_mc(struct qeth_card *card, __u8 *mac, int vmac)
 {
 	struct qeth_mc_mac *mc;
+	int rc;
 
 	mc = kmalloc(sizeof(struct qeth_mc_mac), GFP_ATOMIC);
 
@@ -188,8 +189,16 @@
 
 	memcpy(mc->mc_addr, mac, OSA_ADDR_LEN);
 	mc->mc_addrlen = OSA_ADDR_LEN;
+	mc->is_vmac = vmac;
+
+	if (vmac) {
+		rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETVMAC,
+					NULL);
+	} else {
+		rc = qeth_l2_send_setgroupmac(card, mac);
+	}
 
-	if (!qeth_l2_send_setgroupmac(card, mac))
+	if (!rc)
 		list_add_tail(&mc->list, &card->mc_list);
 	else
 		kfree(mc);
@@ -201,7 +210,11 @@
 
 	spin_lock_bh(&card->mclock);
 	list_for_each_entry_safe(mc, tmp, &card->mc_list, list) {
-		qeth_l2_send_delgroupmac(card, mc->mc_addr);
+		if (mc->is_vmac)
+			qeth_l2_send_setdelmac(card, mc->mc_addr,
+					IPA_CMD_DELVMAC, NULL);
+		else
+			qeth_l2_send_delgroupmac(card, mc->mc_addr);
 		list_del(&mc->list);
 		kfree(mc);
 	}
@@ -590,7 +603,7 @@
 static void qeth_l2_set_multicast_list(struct net_device *dev)
 {
 	struct qeth_card *card = dev->ml_priv;
-	struct dev_mc_list *dm;
+	struct dev_addr_list *dm;
 
 	if (card->info.type == QETH_CARD_TYPE_OSN)
 		return ;
@@ -599,7 +612,11 @@
 	qeth_l2_del_all_mc(card);
 	spin_lock_bh(&card->mclock);
 	for (dm = dev->mc_list; dm; dm = dm->next)
-		qeth_l2_add_mc(card, dm->dmi_addr);
+		qeth_l2_add_mc(card, dm->da_addr, 0);
+
+	for (dm = dev->uc_list; dm; dm = dm->next)
+		qeth_l2_add_mc(card, dm->da_addr, 1);
+
 	spin_unlock_bh(&card->mclock);
 	if (!qeth_adp_supported(card, IPA_SETADP_SET_PROMISC_MODE))
 		return;

-- 
