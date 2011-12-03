From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/9] infiniband: nes: Use dst's neighbour entry.
Date: Fri, 02 Dec 2011 21:52:27 -0500 (EST)
Message-ID: <20111202.215227.526958004729466816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52083 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859Ab1LCCw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 21:52:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Do this instead of performing a by-hand lookup.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/hw/nes/nes_cm.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index 686667a..b1e6cae 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -1348,7 +1348,8 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 	else
 		netdev = nesvnic->netdev;
 
-	neigh = neigh_lookup(&arp_tbl, &rt->rt_gateway, netdev);
+	rcu_read_lock();
+	neigh = dst_get_neighbour_noref(&rt->dst);
 	if (neigh) {
 		if (neigh->nud_state & NUD_VALID) {
 			nes_debug(NES_DBG_CM, "Neighbor MAC address for 0x%08X"
@@ -1359,7 +1360,6 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 				if (!memcmp(nesadapter->arp_table[arpindex].mac_addr,
 					    neigh->ha, ETH_ALEN)) {
 					/* Mac address same as in nes_arp_table */
-					neigh_release(neigh);
 					ip_rt_put(rt);
 					return rc;
 				}
@@ -1373,15 +1373,11 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 					     dst_ip, NES_ARP_ADD);
 			rc = nes_arp_table(nesvnic->nesdev, dst_ip, NULL,
 					   NES_ARP_RESOLVE);
+		} else {
+			neigh_event_send(neigh, NULL);
 		}
-		neigh_release(neigh);
-	}
-
-	if ((neigh == NULL) || (!(neigh->nud_state & NUD_VALID))) {
-		rcu_read_lock();
-		neigh_event_send(dst_get_neighbour_noref(&rt->dst), NULL);
-		rcu_read_unlock();
 	}
+	rcu_read_unlock();
 	ip_rt_put(rt);
 	return rc;
 }
-- 
1.7.7.3
