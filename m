From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 2/6] be2net: fix to not drop unfiltered vlan pkts
Date: Fri, 18 Mar 2011 18:50:58 +0530
Message-ID: <e340379d-68e1-42af-b7b7-94e07e729884@exht1.ad.emulex.com>
References: <1300454462-1234-1-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-2-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:9934 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756493Ab1CRNVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 09:21:21 -0400
In-Reply-To: <1300454462-1234-2-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the device is in promiscuous mode, the driver can receive vlan packets
(tag is always stripped by card) even when there is no vlan configuration.
Such packets must be sent to the stack and not dropped.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 97c5167..18c6da4 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1013,15 +1013,10 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 	skb->truesize = skb->len + sizeof(struct sk_buff);
 	skb->protocol = eth_type_trans(skb, adapter->netdev);
 
-	if (unlikely(rxcp->vlanf)) {
-		if (!adapter->vlan_grp || adapter->vlans_added == 0) {
-			kfree_skb(skb);
-			return;
-		}
+	if (unlikely(rxcp->vlanf))
 		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp, rxcp->vid);
-	} else {
+	else
 		netif_receive_skb(skb);
-	}
 }
 
 /* Process the RX completion indicated by rxcp when GRO is enabled */
-- 
1.6.5.2

