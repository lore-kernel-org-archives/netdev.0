From: frank.blaschka@de.ibm.com
Subject: [patch 2/4] qeth: exploit source MAC address for inbound layer3 packets
Date: Thu, 11 Dec 2008 14:23:11 +0100
Message-ID: <20081211132419.230735000@de.ibm.com>
References: <20081211132309.053505000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:52124 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755654AbYLKNYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 08:24:22 -0500
Content-Disposition: inline; filename=604-qeth-source-mac.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

OSA-devices operating in layer3 mode offer adding of the source MAC
address to the QDIO header of inbound packets. The qeth driver can
exploit this functionality to replace FAKELL-entries in the ethernet
header of received packets.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    1 -
 drivers/s390/net/qeth_core_main.c |    1 -
 drivers/s390/net/qeth_l3_main.c   |   16 +++++++++-------
 3 files changed, 9 insertions(+), 9 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2008-12-11 11:23:10.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2008-12-11 11:27:12.000000000 +0100
@@ -643,7 +643,6 @@ struct qeth_card_options {
 	int macaddr_mode;
 	int fake_broadcast;
 	int add_hhlen;
-	int fake_ll;
 	int layer2;
 	enum qeth_large_send_types large_send;
 	int performance_stats;
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2008-12-11 11:27:12.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2008-12-11 11:27:12.000000000 +0100
@@ -1072,7 +1072,6 @@ static void qeth_set_intial_options(stru
 	card->options.macaddr_mode = QETH_TR_MACADDR_NONCANONICAL;
 	card->options.fake_broadcast = 0;
 	card->options.add_hhlen = DEFAULT_ADD_HHLEN;
-	card->options.fake_ll = 0;
 	card->options.performance_stats = 0;
 	card->options.rx_sg_cb = QETH_RX_SG_CB;
 }
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2008-12-11 11:23:10.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2008-12-11 11:27:12.000000000 +0100
@@ -1207,12 +1207,9 @@ static int qeth_l3_start_ipa_source_mac(
 
 	QETH_DBF_TEXT(TRACE, 3, "stsrcmac");
 
-	if (!card->options.fake_ll)
-		return -EOPNOTSUPP;
-
 	if (!qeth_is_supported(card, IPA_SOURCE_MAC)) {
 		dev_info(&card->gdev->dev,
-			"Inbound source address not supported on %s\n",
+			"Inbound source MAC-address not supported on %s\n",
 			QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}
@@ -1221,7 +1218,7 @@ static int qeth_l3_start_ipa_source_mac(
 					  IPA_CMD_ASS_START, 0);
 	if (rc)
 		dev_warn(&card->gdev->dev,
-			"Starting proxy ARP support for %s failed\n",
+			"Starting source MAC-address support for %s failed\n",
 			QETH_CARD_IFNAME(card));
 	return rc;
 }
@@ -1921,8 +1918,13 @@ static inline __u16 qeth_l3_rebuild_skb(
 			memcpy(tg_addr, card->dev->dev_addr,
 				card->dev->addr_len);
 		}
-		card->dev->header_ops->create(skb, card->dev, prot, tg_addr,
-					      "FAKELL", card->dev->addr_len);
+		if (hdr->hdr.l3.ext_flags & QETH_HDR_EXT_SRC_MAC_ADDR)
+			card->dev->header_ops->create(skb, card->dev, prot,
+				tg_addr, &hdr->hdr.l3.dest_addr[2],
+				card->dev->addr_len);
+		else
+			card->dev->header_ops->create(skb, card->dev, prot,
+				tg_addr, "FAKELL", card->dev->addr_len);
 	}
 
 #ifdef CONFIG_TR

-- 
