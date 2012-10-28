From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 07/16] batman-adv: Remove extra check in batadv_bit_get_packet
Date: Sun, 28 Oct 2012 12:17:08 +0100
Message-ID: <1351423037-5292-8-git-send-email-ordex@autistici.org>
References: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:55827 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab2J1LS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 07:18:28 -0400
In-Reply-To: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batadv_bit_get_packet checks for all common situations before it decides that
the new received packet indicates that the host was restarted. This extra
condition check at the end of the function is not necessary because this
condition is always true.

This patch addresses Coverity #712296: Logically dead code

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bitarray.c | 23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index aea174c..5453b17 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -79,20 +79,17 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
 	 * or the old packet got delayed somewhere in the network. The
 	 * packet should be dropped without calling this function if the
 	 * seqno window is protected.
+	 *
+	 * seq_num_diff <= -BATADV_TQ_LOCAL_WINDOW_SIZE
+	 * or
+	 * seq_num_diff >= BATADV_EXPECTED_SEQNO_RANGE
 	 */
-	if (seq_num_diff <= -BATADV_TQ_LOCAL_WINDOW_SIZE ||
-	    seq_num_diff >= BATADV_EXPECTED_SEQNO_RANGE) {
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+		   "Other host probably restarted!\n");
 
-		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "Other host probably restarted!\n");
+	bitmap_zero(seq_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
+	if (set_mark)
+		batadv_set_bit(seq_bits, 0);
 
-		bitmap_zero(seq_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
-		if (set_mark)
-			batadv_set_bit(seq_bits, 0);
-
-		return 1;
-	}
-
-	/* never reached */
-	return 0;
+	return 1;
 }
-- 
1.7.12.4
