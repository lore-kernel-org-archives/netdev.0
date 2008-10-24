From: frank.blaschka@de.ibm.com
Subject: [patch 4/4] qeth: avoid skb_under_panic for malformatted inbound data
Date: Fri, 24 Oct 2008 11:16:55 +0200
Message-ID: <20081024091734.939461000@de.ibm.com>
References: <20081024091651.603673000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:60457 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbYJXJSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 05:18:52 -0400
Content-Disposition: inline; filename=605-qeth-panic.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

To make the qeth driver more robust in case of malformatted inbound
packets due to hardware problems, an additional check for
OSN-card-type is added for OSN-type packets.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l2_main.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

Index: git_linus/drivers/s390/net/qeth_l2_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_l2_main.c
+++ git_linus/drivers/s390/net/qeth_l2_main.c
@@ -449,12 +449,15 @@ static void qeth_l2_process_inbound_buff
 			netif_rx(skb);
 			break;
 		case QETH_HEADER_TYPE_OSN:
-			skb_push(skb, sizeof(struct qeth_hdr));
-			skb_copy_to_linear_data(skb, hdr,
+			if (card->info.type == QETH_CARD_TYPE_OSN) {
+				skb_push(skb, sizeof(struct qeth_hdr));
+				skb_copy_to_linear_data(skb, hdr,
 						sizeof(struct qeth_hdr));
-			len = skb->len;
-			card->osn_info.data_cb(skb);
-			break;
+				len = skb->len;
+				card->osn_info.data_cb(skb);
+				break;
+			}
+			/* else unknown */
 		default:
 			dev_kfree_skb_any(skb);
 			QETH_DBF_TEXT(TRACE, 3, "inbunkno");

-- 
