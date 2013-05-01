From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 2/4] be2net: Fix to use 32-bit stats to report
 rx_drops_no_fragment
Date: Wed, 1 May 2013 14:37:27 -0500
Message-ID: <20130501193726.GA3807@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:6206 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756854Ab3EATha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 15:37:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only BE devices provide 16-bit counter for rx_drops_no_fragment.
All other devices provide a 32-bit counter for this stat.
Use the 32-bit value where available.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 1232e91..e0eaad1 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -458,11 +458,26 @@ static void accumulate_16bit_val(u32 *acc, u16 val)
 	ACCESS_ONCE(*acc) = newacc;
 }
 
+void populate_erx_stats(struct be_adapter *adapter,
+			struct be_rx_obj *rxo,
+			u32 erx_stat)
+{
+	if (!BEx_chip(adapter))
+		rx_stats(rxo)->rx_drops_no_frags = erx_stat;
+	else
+		/* below erx HW counter can actually wrap around after
+		 * 65535. Driver accumulates a 32-bit value
+		 */
+		accumulate_16bit_val(&rx_stats(rxo)->rx_drops_no_frags,
+				     (u16)erx_stat);
+}
+
 void be_parse_stats(struct be_adapter *adapter)
 {
 	struct be_erx_stats_v1 *erx = be_erx_stats_from_cmd(adapter);
 	struct be_rx_obj *rxo;
 	int i;
+	u32 erx_stat;
 
 	if (lancer_chip(adapter)) {
 		populate_lancer_stats(adapter);
@@ -475,12 +490,8 @@ void be_parse_stats(struct be_adapter *adapter)
 
 		/* as erx_v1 is longer than v0, ok to use v1 for v0 access */
 		for_all_rx_queues(adapter, rxo, i) {
-			/* below erx HW counter can actually wrap around after
-			 * 65535. Driver accumulates a 32-bit value
-			 */
-			accumulate_16bit_val(&rx_stats(rxo)->rx_drops_no_frags,
-					     (u16)erx->rx_drops_no_fragments \
-					     [rxo->q.id]);
+			erx_stat = erx->rx_drops_no_fragments[rxo->q.id];
+			populate_erx_stats(adapter, rxo, erx_stat);
 		}
 	}
 }
-- 
1.7.10.4
