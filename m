From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 10/13] qeth: add network device features for VLAN devices
Date: Thu, 16 Jun 2016 16:19:00 +0200
Message-ID: <1466086743-55484-11-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:37007 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754398AbcFPOTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 10:19:38 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GEIw2R095764
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:37 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23kr61ek6k-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:37 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Thu, 16 Jun 2016 15:19:34 +0100
In-Reply-To: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Wippel <hwippel@linux.vnet.ibm.com>

Network device features indicate the capabilities of network devices (e.g.,
TX checksum offloading and TSO) and their configuration state. Additional
network device features (vlan_features) indicate for each network device,
which capabilities can be used on VLAN devices, that are configured on the
respective base network device.

In the current qeth implementation, network device features are only set
for the base network devices and not for the VLAN devices. Thus, features
like TX checksum offloading cannot be used on VLAN devices.

This patch adds network device features to vlan_features, so they can be
used by VLAN devices.

Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 9 +++++++--
 drivers/s390/net/qeth_l3_main.c | 3 +++
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 928a4ad..9fd48de 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1113,11 +1113,16 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 	card->dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 	if (card->info.type == QETH_CARD_TYPE_OSD && !card->info.guestlan) {
 		card->dev->hw_features = NETIF_F_SG;
+		card->dev->vlan_features = NETIF_F_SG;
 		/* OSA 3S and earlier has no RX/TX support */
-		if (qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
+		if (qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM)) {
 			card->dev->hw_features |= NETIF_F_IP_CSUM;
-		if (qeth_is_supported(card, IPA_INBOUND_CHECKSUM))
+			card->dev->vlan_features |= NETIF_F_IP_CSUM;
+		}
+		if (qeth_is_supported(card, IPA_INBOUND_CHECKSUM)) {
 			card->dev->hw_features |= NETIF_F_RXCSUM;
+			card->dev->vlan_features |= NETIF_F_RXCSUM;
+		}
 		/* Turn on SG per default */
 		card->dev->features |= NETIF_F_SG;
 	}
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index fc81776..05f764c 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3106,6 +3106,9 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 				card->dev->hw_features = NETIF_F_SG |
 					NETIF_F_RXCSUM | NETIF_F_IP_CSUM |
 					NETIF_F_TSO;
+				card->dev->vlan_features = NETIF_F_SG |
+					NETIF_F_RXCSUM | NETIF_F_IP_CSUM |
+					NETIF_F_TSO;
 				card->dev->features = NETIF_F_SG;
 			}
 		}
-- 
2.6.6
