From: frank.blaschka@de.ibm.com
Subject: [patch 3/3] qeth: Fix missing pointer update
Date: Mon, 22 Apr 2013 13:12:29 +0200
Message-ID: <20130422111238.504245525@de.ibm.com>
References: <20130422111226.882214164@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:53558 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536Ab3DVLMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 07:12:44 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 22 Apr 2013 12:09:52 +0100
Content-Disposition: inline; filename=602-qeth-fix-pointer.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>
    
qeth_hdr_chk_and_bounce() can possibly shift the skb->data
pointer. However, the existing code didn't update the hdr pointer,
which should point to skb->data, accordingly.
Symptoms of this issue are sporadic recoveries.
   
Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |    2 +-
 drivers/s390/net/qeth_core_main.c |    4 +++-
 drivers/s390/net/qeth_l2_main.c   |    2 +-
 drivers/s390/net/qeth_l3_main.c   |    2 +-
 4 files changed, 6 insertions(+), 4 deletions(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -929,7 +929,7 @@ void qeth_core_get_drvinfo(struct net_de
 void qeth_dbf_longtext(debug_info_t *id, int level, char *text, ...);
 int qeth_core_ethtool_get_settings(struct net_device *, struct ethtool_cmd *);
 int qeth_set_access_ctrl_online(struct qeth_card *card, int fallback);
-int qeth_hdr_chk_and_bounce(struct sk_buff *, int);
+int qeth_hdr_chk_and_bounce(struct sk_buff *, struct qeth_hdr **, int);
 int qeth_configure_cq(struct qeth_card *, enum qeth_cq);
 int qeth_hw_trap(struct qeth_card *, enum qeth_diags_trap_action);
 int qeth_query_ipassists(struct qeth_card *, enum qeth_prot_versions prot);
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3717,7 +3717,7 @@ int qeth_get_elements_no(struct qeth_car
 }
 EXPORT_SYMBOL_GPL(qeth_get_elements_no);
 
-int qeth_hdr_chk_and_bounce(struct sk_buff *skb, int len)
+int qeth_hdr_chk_and_bounce(struct sk_buff *skb, struct qeth_hdr **hdr, int len)
 {
 	int hroom, inpage, rest;
 
@@ -3730,6 +3730,8 @@ int qeth_hdr_chk_and_bounce(struct sk_bu
 			return 1;
 		memmove(skb->data - rest, skb->data, skb->len - skb->data_len);
 		skb->data -= rest;
+		skb->tail -= rest;
+		*hdr = (struct qeth_hdr *)skb->data;
 		QETH_DBF_MESSAGE(2, "skb bounce len: %d rest: %d\n", len, rest);
 	}
 	return 0;
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -781,7 +781,7 @@ static int qeth_l2_hard_start_xmit(struc
 	}
 
 	if (card->info.type != QETH_CARD_TYPE_IQD) {
-		if (qeth_hdr_chk_and_bounce(new_skb,
+		if (qeth_hdr_chk_and_bounce(new_skb, &hdr,
 		    sizeof(struct qeth_hdr_layer2)))
 			goto tx_drop;
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3055,7 +3055,7 @@ static int qeth_l3_hard_start_xmit(struc
 		else
 			len = sizeof(struct qeth_hdr_layer3);
 
-		if (qeth_hdr_chk_and_bounce(new_skb, len))
+		if (qeth_hdr_chk_and_bounce(new_skb, &hdr, len))
 			goto tx_drop;
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
 					 elements_needed);
