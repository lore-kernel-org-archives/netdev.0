From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 6/6] be2net: drop pkts that do not belong to the port
Date: Wed, 3 Aug 2011 11:27:46 +0530
Message-ID: <7da52ae4-5906-4360-9837-97354f0f58b7@exht1.ad.emulex.com>
References: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:24506 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754633Ab1HCF4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 01:56:34 -0400
In-Reply-To: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some BE skews, while in promiscuous mode, pkts that do not belong to a
port can arrive on that port. Drop such pkts.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be.h      |    2 +-
 drivers/net/benet/be_main.c |   30 +++++++++++++++++++++++-------
 2 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 1e7f009..12b5b51 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -217,7 +217,7 @@ struct be_rx_compl_info {
 	u16 vlan_tag;
 	u16 pkt_size;
 	u16 rxq_idx;
-	u16 mac_id;
+	u16 port;
 	u8 vlanf;
 	u8 num_rcvd;
 	u8 err;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index dba6941f..1a3acca 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1213,6 +1213,7 @@ static void be_parse_rx_compl_v1(struct be_adapter *adapter,
 		rxcp->vlan_tag = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vlan_tag,
 					       compl);
 	}
+	rxcp->port = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, port, compl);
 }
 
 static void be_parse_rx_compl_v0(struct be_adapter *adapter,
@@ -1245,6 +1246,7 @@ static void be_parse_rx_compl_v0(struct be_adapter *adapter,
 		rxcp->vlan_tag = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vlan_tag,
 					       compl);
 	}
+	rxcp->port = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, port, compl);
 }
 
 static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
@@ -1833,16 +1835,30 @@ static int be_poll_rx(struct napi_struct *napi, int budget)
 		if (!rxcp)
 			break;
 
-		/* Ignore flush completions */
-		if (rxcp->num_rcvd && rxcp->pkt_size) {
-			if (do_gro(rxcp))
-				be_rx_compl_process_gro(adapter, rxo, rxcp);
-			else
-				be_rx_compl_process(adapter, rxo, rxcp);
-		} else if (rxcp->pkt_size == 0) {
+		/* Is it a flush compl that has no data */
+		if (unlikely(rxcp->num_rcvd == 0))
+			goto loop_continue;
+
+		/* Discard compl with partial DMA Lancer B0 */
+		if (unlikely(!rxcp->pkt_size)) {
 			be_rx_compl_discard(adapter, rxo, rxcp);
+			goto loop_continue;
 		}
 
+		/* On BE drop pkts that arrive due to imperfect filtering in
+		 * promiscuous mode on some skews
+		 */
+		if (unlikely(rxcp->port != adapter->port_num &&
+				!lancer_chip(adapter))) {
+			be_rx_compl_discard(adapter, rxo, rxcp);
+			goto loop_continue;
+		}
+
+		if (do_gro(rxcp))
+			be_rx_compl_process_gro(adapter, rxo, rxcp);
+		else
+			be_rx_compl_process(adapter, rxo, rxcp);
+loop_continue:
 		be_rx_stats_update(rxo, rxcp);
 	}
 
-- 
1.7.4

