From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 2/4] net: u64_stats_fetch_begin_bh() and
 u64_stats_fetch_retry_bh()
Date: Thu, 24 Jun 2010 12:54:06 +0200
Message-ID: <1277376846.2816.283.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:50894 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754559Ab0FXKyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 06:54:09 -0400
Received: by wwi17 with SMTP id 17so93042wwi.19
        for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 03:54:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Must disable preemption in case of 32bit UP in u64_stats_fetch_begin()
and u64_stats_fetch_retry()

- Add new u64_stats_fetch_begin_bh() and u64_stats_fetch_retry_bh() for
network usage, disabling BH on 32bit UP only.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/u64_stats_sync.h |   59 +++++++++++++++++++++++--------
 1 file changed, 44 insertions(+), 15 deletions(-)

diff --git a/include/linux/u64_stats_sync.h b/include/linux/u64_stats_sync.h
index 201d319..00c1592 100644
--- a/include/linux/u64_stats_sync.h
+++ b/include/linux/u64_stats_sync.h
@@ -27,6 +27,9 @@
  *    (On UP, there is no seqcount_t protection, a reader allowing interrupts could
  *     read partial values)
  *
+ * 7) For softirq uses, readers can use u64_stats_fetch_begin_bh() and
+ *    u64_stats_fetch_retry_bh() helpers
+ *
  * Usage :
  *
  * Stats producer (writer) should use following template granted it already got
@@ -58,54 +61,80 @@
  */
 #include <linux/seqlock.h>
 
-#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
 struct u64_stats_sync {
+#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
 	seqcount_t	seq;
+#endif
 };
 
 static void inline u64_stats_update_begin(struct u64_stats_sync *syncp)
 {
+#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
 	write_seqcount_begin(&syncp->seq);
+#endif
 }
 
 static void inline u64_stats_update_end(struct u64_stats_sync *syncp)
 {
+#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
 	write_seqcount_end(&syncp->seq);
+#endif
 }
 
 static unsigned int inline u64_stats_fetch_begin(const struct u64_stats_sync *syncp)
 {
+#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
 	return read_seqcount_begin(&syncp->seq);
+#else
+#if BITS_PER_LONG==32
+	preempt_disable();
+#endif
+	return 0;
+#endif
 }
 
 static bool inline u64_stats_fetch_retry(const struct u64_stats_sync *syncp,
 					 unsigned int start)
 {
+#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
 	return read_seqcount_retry(&syncp->seq, start);
-}
-
 #else
-struct u64_stats_sync {
-};
-
-static void inline u64_stats_update_begin(struct u64_stats_sync *syncp)
-{
-}
-
-static void inline u64_stats_update_end(struct u64_stats_sync *syncp)
-{
+#if BITS_PER_LONG==32
+	preempt_enable();
+#endif
+	return false;
+#endif
 }
 
-static unsigned int inline u64_stats_fetch_begin(const struct u64_stats_sync *syncp)
+/*
+ * In case softirq handlers can update u64 counters, readers can use following helpers
+ * - SMP 32bit arches use seqcount protection, irq safe.
+ * - UP 32bit must disable BH.
+ * - 64bit have no problem atomically reading u64 values, irq safe.
+ */
+static unsigned int inline u64_stats_fetch_begin_bh(const struct u64_stats_sync *syncp)
 {
+#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
+	return read_seqcount_begin(&syncp->seq);
+#else
+#if BITS_PER_LONG==32
+	local_bh_disable();
+#endif
 	return 0;
+#endif
 }
 
-static bool inline u64_stats_fetch_retry(const struct u64_stats_sync *syncp,
+static bool inline u64_stats_fetch_retry_bh(const struct u64_stats_sync *syncp,
 					 unsigned int start)
 {
+#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
+	return read_seqcount_retry(&syncp->seq, start);
+#else
+#if BITS_PER_LONG==32
+	local_bh_enable();
+#endif
 	return false;
-}
 #endif
+}
 
 #endif /* _LINUX_U64_STATS_SYNC_H */


