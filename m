From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 4/8] ehea: Fix TSO and hw checksums with non-accelerated vlan packets.
Date: Mon, 25 Aug 2014 10:34:51 -0400
Message-ID: <1408977295-9162-5-git-send-email-vyasevic@redhat.com>
References: <1408977295-9162-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:45065 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932345AbaHYOfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 10:35:19 -0400
Received: by mail-qg0-f49.google.com with SMTP id j107so12917300qga.8
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 07:35:19 -0700 (PDT)
In-Reply-To: <1408977295-9162-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver claims that it can do TSO and IP checksums on vlan
devices and also allows user to control vlan acceleration offloading.
This makes it possible to push traffic to this driver that has TSO or
partial checksums set, but also have a non-accelearted vlan
header.  In this case, the driver will fail to correctly
identify such traffic and will not correctly perform
segmentation and checksum calculation.

Fix this by using vlan_get_protocol() helper instead of
assuming skb->protocol always has this information.

CC: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index a0b418e..566b17d 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1994,7 +1994,7 @@ static void xmit_common(struct sk_buff *skb, struct ehea_swqe *swqe)
 {
 	swqe->tx_control |= EHEA_SWQE_IMM_DATA_PRESENT | EHEA_SWQE_CRC;
 
-	if (skb->protocol != htons(ETH_P_IP))
+	if (vlan_get_protocol(skb) != htons(ETH_P_IP))
 		return;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
-- 
1.9.3
