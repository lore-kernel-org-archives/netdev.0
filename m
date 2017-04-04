From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next] sfc: don't insert mc_list on low-latency firmware if
 it's too long
Date: Tue, 4 Apr 2017 17:02:49 +0100
Message-ID: <55dbbc43-2949-fb9a-b3e0-cb21453fb928@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:47258 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754230AbdDDQIh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 12:08:37 -0400
Received: from dispatch1-us1.ppe-hosted.com (localhost.localdomain [127.0.0.1])
        by dispatch1-us1.ppe-hosted.com (Proofpoint Essentials ESMTP Server) with ESMTP id 332AB14C0D6
        for <netdev@vger.kernel.org>; Tue,  4 Apr 2017 16:03:04 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the mc_list is longer than 256 addresses, we enter mc_promisc mode.
If we're in mc_promisc mode and the firmware doesn't support cascaded
 multicast, normally we also insert our mc_list, to prevent stealing by
 another VI.  However, if the mc_list was too long, this isn't really
 helpful - the MC groups that didn't fit in the list can still get
 stolen, and having only some of them stealable will probably cause
 more confusing behaviour than having them all stealable.  Since
 inserting 256 multicast filters takes a long time and can lead to MCDI
 state machine timeouts, just skip the mc_list insert in this overflow
 condition.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index c60c2d4..78efb28 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -119,6 +119,7 @@ struct efx_ef10_filter_table {
 	bool mc_promisc;
 /* Whether in multicast promiscuous mode when last changed */
 	bool mc_promisc_last;
+	bool mc_overflow; /* Too many MC addrs; should always imply mc_promisc */
 	bool vlan_filter;
 	struct list_head vlan_list;
 };
@@ -5058,6 +5059,7 @@ static void efx_ef10_filter_mc_addr_list(struct efx_nic *efx)
 	struct netdev_hw_addr *mc;
 	unsigned int i, addr_count;
 
+	table->mc_overflow = false;
 	table->mc_promisc = !!(net_dev->flags & (IFF_PROMISC | IFF_ALLMULTI));
 
 	addr_count = netdev_mc_count(net_dev);
@@ -5065,6 +5067,7 @@ static void efx_ef10_filter_mc_addr_list(struct efx_nic *efx)
 	netdev_for_each_mc_addr(mc, net_dev) {
 		if (i >= EFX_EF10_FILTER_DEV_MC_MAX) {
 			table->mc_promisc = true;
+			table->mc_overflow = true;
 			break;
 		}
 		ether_addr_copy(table->dev_mc_list[i].addr, mc->addr);
@@ -5469,12 +5472,15 @@ static void efx_ef10_filter_vlan_sync_rx_mode(struct efx_nic *efx,
 			}
 		} else {
 			/* If we failed to insert promiscuous filters, don't
-			 * rollback.  Regardless, also insert the mc_list
+			 * rollback.  Regardless, also insert the mc_list,
+			 * unless it's incomplete due to overflow
 			 */
 			efx_ef10_filter_insert_def(efx, vlan,
 						   EFX_ENCAP_TYPE_NONE,
 						   true, false);
-			efx_ef10_filter_insert_addr_list(efx, vlan, true, false);
+			if (!table->mc_overflow)
+				efx_ef10_filter_insert_addr_list(efx, vlan,
+								 true, false);
 		}
 	} else {
 		/* If any filters failed to insert, rollback and fall back to
