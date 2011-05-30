From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 13/17] batman-adv: move smallest_signed_int(), seq_before() and seq_after() into main.h
Date: Mon, 30 May 2011 09:22:58 +0200
Message-ID: <1306740182-2665-14-git-send-email-sven@narfation.org>
References: <1306740182-2665-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:60268 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755020Ab1E3HXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2011 03:23:22 -0400
In-Reply-To: <1306740182-2665-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

smallest_signed_int(), seq_before() and seq_after() are very useful
functions that help to handle comparisons between sequence numbers.
However they were only defined in vis.c. With this patch every
batman-adv function will be able to use them.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/main.h |   16 ++++++++++++++++
 net/batman-adv/vis.c  |   16 ----------------
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 0150897a..80be5ad 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -182,4 +182,20 @@ static inline int compare_eth(const void *data1, const void *data2)
 
 #define atomic_dec_not_zero(v)	atomic_add_unless((v), -1, 0)
 
+/* Returns the smallest signed integer in two's complement with the sizeof x */
+#define smallest_signed_int(x) (1u << (7u + 8u * (sizeof(x) - 1u)))
+
+/* Checks if a sequence number x is a predecessor/successor of y.
+ * they handle overflows/underflows and can correctly check for a
+ * predecessor/successor unless the variable sequence number has grown by
+ * more then 2**(bitwidth(x)-1)-1.
+ * This means that for a uint8_t with the maximum value 255, it would think:
+ *  - when adding nothing - it is neither a predecessor nor a successor
+ *  - before adding more than 127 to the starting value - it is a predecessor,
+ *  - when adding 128 - it is neither a predecessor nor a successor,
+ *  - after adding more than 127 to the starting value - it is a successor */
+#define seq_before(x, y) ({typeof(x) _dummy = (x - y); \
+			_dummy > smallest_signed_int(_dummy); })
+#define seq_after(x, y) seq_before(y, x)
+
 #endif /* _NET_BATMAN_ADV_MAIN_H_ */
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index ea8d7e9..355c6e5 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -30,22 +30,6 @@
 
 #define MAX_VIS_PACKET_SIZE 1000
 
-/* Returns the smallest signed integer in two's complement with the sizeof x */
-#define smallest_signed_int(x) (1u << (7u + 8u * (sizeof(x) - 1u)))
-
-/* Checks if a sequence number x is a predecessor/successor of y.
- * they handle overflows/underflows and can correctly check for a
- * predecessor/successor unless the variable sequence number has grown by
- * more then 2**(bitwidth(x)-1)-1.
- * This means that for a uint8_t with the maximum value 255, it would think:
- *  - when adding nothing - it is neither a predecessor nor a successor
- *  - before adding more than 127 to the starting value - it is a predecessor,
- *  - when adding 128 - it is neither a predecessor nor a successor,
- *  - after adding more than 127 to the starting value - it is a successor */
-#define seq_before(x, y) ({typeof(x) _dummy = (x - y); \
-			_dummy > smallest_signed_int(_dummy); })
-#define seq_after(x, y) seq_before(y, x)
-
 static void start_vis_timer(struct bat_priv *bat_priv);
 
 /* free the info */
-- 
1.7.5.3

