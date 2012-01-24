From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 3/3] infiniband: nes: Convert nes_addr_resolve_neigh() over
 to dst_neigh_lookup().
Date: Tue, 24 Jan 2012 18:16:03 -0500 (EST)
Message-ID: <20120124.181603.2050827731650521325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Now we must provide the IP destination address, and a reference has
to be dropped when we're done with the entry.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/infiniband/hw/nes/nes_cm.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index 425065b..fc5192e 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -1348,8 +1348,9 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 	else
 		netdev = nesvnic->netdev;
 
+	neigh = dst_neigh_lookup(&rt->dst, &dst_ip);
+
 	rcu_read_lock();
-	neigh = dst_get_neighbour_noref(&rt->dst);
 	if (neigh) {
 		if (neigh->nud_state & NUD_VALID) {
 			nes_debug(NES_DBG_CM, "Neighbor MAC address for 0x%08X"
@@ -1360,8 +1361,7 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 				if (!memcmp(nesadapter->arp_table[arpindex].mac_addr,
 					    neigh->ha, ETH_ALEN)) {
 					/* Mac address same as in nes_arp_table */
-					ip_rt_put(rt);
-					return rc;
+					goto out;
 				}
 
 				nes_manage_arp_cache(nesvnic->netdev,
@@ -1377,7 +1377,12 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 			neigh_event_send(neigh, NULL);
 		}
 	}
+out:
 	rcu_read_unlock();
+
+	if (neigh)
+		neigh_release(neigh);
+
 	ip_rt_put(rt);
 	return rc;
 }
-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
