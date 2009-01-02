From: frank.blaschka@de.ibm.com
Subject: [patch 5/6] qeth: No large send using EDDP for HiperSockets.
Date: Fri, 02 Jan 2009 16:01:44 +0100
Message-ID: <20090102150255.989302000@de.ibm.com>
References: <20090102150139.830998000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:34244 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbZABPC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 10:02:59 -0500
Content-Disposition: inline; filename=609-qeth-eddp.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-Dieter Wacker <kdwacker@de.ibm.com>

The device driver qeth dos not support large send using EDDP for 
HiperSockets.

Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2009-01-02 10:22:08.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2009-01-02 10:22:08.000000000 +0100
@@ -287,8 +287,15 @@ int qeth_set_large_send(struct qeth_card
 	card->options.large_send = type;
 	switch (card->options.large_send) {
 	case QETH_LARGE_SEND_EDDP:
-		card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
+		if (card->info.type != QETH_CARD_TYPE_IQD) {
+			card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
 					NETIF_F_HW_CSUM;
+		} else {
+			card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
+						NETIF_F_HW_CSUM);
+			card->options.large_send = QETH_LARGE_SEND_NO;
+			rc = -EOPNOTSUPP;
+		}
 		break;
 	case QETH_LARGE_SEND_TSO:
 		if (qeth_is_supported(card, IPA_OUTBOUND_TSO)) {

-- 
