From: frank.blaschka@de.ibm.com
Subject: [patch 4/5] [PATCH] qeth: omit upstream checksumming for HiperSockets
Date: Wed, 20 May 2009 09:38:40 +0200
Message-ID: <20090520073928.073471000@de.ibm.com>
References: <20090520073836.897878000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:60034 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754969AbZETHj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 03:39:28 -0400
Content-Disposition: inline; filename=615-qeth-checksum-hipersocket.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

For HiperSocket devices receive-path checksumming is not required.
Thus NO_CHECKSUMMING is used as default for HiperSocket interfaces.
For layer3 devices configured with NO_CHECKSUMMING received skbs
should have set their ip_summed field to CHECKSUM_UNNECESSARY.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    2 ++
 drivers/s390/net/qeth_l3_main.c   |   20 +++++++++++++-------
 2 files changed, 15 insertions(+), 7 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2009-05-20 08:56:25.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2009-05-20 08:56:43.000000000 +0200
@@ -1140,6 +1140,8 @@ static int qeth_setup_card(struct qeth_c
 	card->ipato.enabled = 0;
 	card->ipato.invert4 = 0;
 	card->ipato.invert6 = 0;
+	if (card->info.type == QETH_CARD_TYPE_IQD)
+		card->options.checksum_type = NO_CHECKSUMMING;
 	/* init QDIO stuff */
 	qeth_init_qdio_info(card);
 	return 0;
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2009-05-20 08:56:42.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2009-05-20 08:56:43.000000000 +0200
@@ -1920,16 +1920,22 @@ static inline __u16 qeth_l3_rebuild_skb(
 		 hdr->hdr.l3.vlan_id : *((u16 *)&hdr->hdr.l3.dest_addr[12]);
 	}
 
-	skb->ip_summed = card->options.checksum_type;
-	if (card->options.checksum_type == HW_CHECKSUMMING) {
+	switch (card->options.checksum_type) {
+	case SW_CHECKSUMMING:
+		skb->ip_summed = CHECKSUM_NONE;
+		break;
+	case NO_CHECKSUMMING:
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		break;
+	case HW_CHECKSUMMING:
 		if ((hdr->hdr.l3.ext_flags &
-		      (QETH_HDR_EXT_CSUM_HDR_REQ |
-		       QETH_HDR_EXT_CSUM_TRANSP_REQ)) ==
-		     (QETH_HDR_EXT_CSUM_HDR_REQ |
-		      QETH_HDR_EXT_CSUM_TRANSP_REQ))
+		    (QETH_HDR_EXT_CSUM_HDR_REQ |
+		     QETH_HDR_EXT_CSUM_TRANSP_REQ)) ==
+		    (QETH_HDR_EXT_CSUM_HDR_REQ |
+		     QETH_HDR_EXT_CSUM_TRANSP_REQ))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		else
-			skb->ip_summed = SW_CHECKSUMMING;
+			skb->ip_summed = CHECKSUM_NONE;
 	}
 
 	return vlan_id;

