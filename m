From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] gnet_stats: kernel-api doc for gnet stats/estimator
Date: Tue, 30 Nov 2004 16:56:30 +0100
Message-ID: <20041130155630.GH31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kernel-api documentation for gnet stats/estimator

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.10-rc2-bk13.orig/Documentation/DocBook/kernel-api.tmpl linux-2.6.10-rc2-bk13/Documentation/DocBook/kernel-api.tmpl
--- linux-2.6.10-rc2-bk13.orig/Documentation/DocBook/kernel-api.tmpl	2004-11-30 14:01:13.000000000 +0100
+++ linux-2.6.10-rc2-bk13/Documentation/DocBook/kernel-api.tmpl	2004-11-30 15:42:19.000000000 +0100
@@ -133,6 +133,11 @@
      <sect1><title>Socket Filter</title>
 !Enet/core/filter.c
      </sect1>
+     <sect1><title>Generic Network Statistics</title>
+!Iinclude/linux/gen_stats.h
+!Enet/core/gen_stats.c
+!Enet/core/gen_estimator.c
+     </sect1>
   </chapter>
 
   <chapter id="netdev">
diff -Nru linux-2.6.10-rc2-bk13.orig/include/linux/gen_stats.h linux-2.6.10-rc2-bk13/include/linux/gen_stats.h
--- linux-2.6.10-rc2-bk13.orig/include/linux/gen_stats.h	2004-11-30 14:01:11.000000000 +0100
+++ linux-2.6.10-rc2-bk13/include/linux/gen_stats.h	2004-11-30 14:41:46.000000000 +0100
@@ -14,6 +14,7 @@
 #define TCA_STATS_MAX (__TCA_STATS_MAX - 1)
 
 /**
+ * struct gnet_stats_basic - byte/packet throughput statistics
  * @bytes: number of seen bytes
  * @packets: number of seen packets
  */
@@ -24,6 +25,7 @@
 };
 
 /**
+ * struct gnet_stats_rate_est - rate estimator
  * @bps: current byte rate
  * @pps: current packet rate
  */
@@ -34,10 +36,12 @@
 };
 
 /**
+ * struct gnet_stats_queue - queuing statistics
  * @qlen: queue length
  * @backlog: backlog size of queue
  * @drops: number of dropped packets
  * @requeues: number of requeues
+ * @overlimits: number of enqueues over the limit
  */
 struct gnet_stats_queue
 {
@@ -49,6 +53,7 @@
 };
 
 /**
+ * struct gnet_estimator - rate estimator configuration
  * @interval: sampling period
  * @ewma_log: the log of measurement window weight
  */
diff -Nru linux-2.6.10-rc2-bk13.orig/net/core/gen_estimator.c linux-2.6.10-rc2-bk13/net/core/gen_estimator.c
--- linux-2.6.10-rc2-bk13.orig/net/core/gen_estimator.c	2004-11-30 14:01:12.000000000 +0100
+++ linux-2.6.10-rc2-bk13/net/core/gen_estimator.c	2004-11-30 15:54:24.000000000 +0100
@@ -132,6 +132,21 @@
 	read_unlock(&est_lock);
 }
 
+/**
+ * gen_new_estimator - create a new rate estimator
+ * @bstats: basic statistics
+ * @rate_est: rate estimator statistics
+ * @stats_lock: statistics lock
+ * @opt: rate estimator configuration TLV
+ *
+ * Creates a new rate estimator with &bstats as source and &rate_est
+ * as destination. A new timer with the interval specified in the
+ * configuration TLV is created. Upon each interval, the latest statistics
+ * will be read from &bstats and the estimated rate will be stored in
+ * &rate_est with the statistics lock grabed during this period.
+ * 
+ * Returns 0 on success or a negative error code.
+ */
 int gen_new_estimator(struct gnet_stats_basic *bstats,
 	struct gnet_stats_rate_est *rate_est, spinlock_t *stats_lock, struct rtattr *opt)
 {
@@ -173,6 +188,14 @@
 	return 0;
 }
 
+/**
+ * gen_kill_estimator - remove a rate estimator
+ * @bstats: basic statistics
+ * @rate_est: rate estimator statistics
+ *
+ * Removes the rate estimator specified by &bstats and &rate_est
+ * and deletes the timer.
+ */
 void gen_kill_estimator(struct gnet_stats_basic *bstats,
 	struct gnet_stats_rate_est *rate_est)
 {
@@ -200,6 +223,18 @@
 	}
 }
 
+/**
+ * gen_replace_estimator - replace rate estimator configruation
+ * @bstats: basic statistics
+ * @rate_est: rate estimator statistics
+ * @stats_lock: statistics lock
+ * @opt: rate estimator configuration TLV
+ *
+ * Replaces the configuration of a rate estimator by calling
+ * gen_kill_estimator() and gen_new_estimator().
+ * 
+ * Returns 0 on success or a negative error code.
+ */
 int
 gen_replace_estimator(struct gnet_stats_basic *bstats,
 	struct gnet_stats_rate_est *rate_est, spinlock_t *stats_lock,
diff -Nru linux-2.6.10-rc2-bk13.orig/net/core/gen_stats.c linux-2.6.10-rc2-bk13/net/core/gen_stats.c
--- linux-2.6.10-rc2-bk13.orig/net/core/gen_stats.c	2004-11-30 14:01:12.000000000 +0100
+++ linux-2.6.10-rc2-bk13/net/core/gen_stats.c	2004-11-30 15:34:59.000000000 +0100
@@ -34,6 +34,24 @@
 	return -1;
 }
 
+/**
+ * gnet_stats_start_copy_compat - start dumping procedure in compatibility mode
+ * @skb: socket buffer to put statistics TLVs into
+ * @type: TLV type for top level statistic TLV
+ * @tc_stats_type: TLV type for backward compatibility struct tc_stats TLV
+ * @xstats_type: TLV type for backward compatibility xstats TLV
+ * @lock: statistics lock
+ * @d: dumping handle
+ *
+ * Initializes the dumping handle, grabs the statistic lock and appends
+ * an empty TLV header to the socket buffer for use a container for all
+ * other statistic TLVS.
+ *
+ * The dumping handle is marked to be in backward compatibility mode telling
+ * all gnet_stats_copy_XXX() functions to fill a local copy of struct tc_stats.
+ *
+ * Returns 0 on success or -1 if the room in the socket buffer was not sufficient.
+ */
 int
 gnet_stats_start_copy_compat(struct sk_buff *skb, int type, int tc_stats_type,
 	int xstats_type, spinlock_t *lock, struct gnet_dump *d)
@@ -52,6 +70,19 @@
 	return gnet_stats_copy(d, type, NULL, 0);
 }
 
+/**
+ * gnet_stats_start_copy_compat - start dumping procedure in compatibility mode
+ * @skb: socket buffer to put statistics TLVs into
+ * @type: TLV type for top level statistic TLV
+ * @lock: statistics lock
+ * @d: dumping handle
+ *
+ * Initializes the dumping handle, grabs the statistic lock and appends
+ * an empty TLV header to the socket buffer for use a container for all
+ * other statistic TLVS.
+ *
+ * Returns 0 on success or -1 if the room in the socket buffer was not sufficient.
+ */
 int
 gnet_stats_start_copy(struct sk_buff *skb, int type, spinlock_t *lock,
 	struct gnet_dump *d)
@@ -59,7 +90,17 @@
 	return gnet_stats_start_copy_compat(skb, type, 0, 0, lock, d);
 }
 
-
+/**
+ * gnet_stats_copy_basic - copy basic statistics into statistic TLV
+ * @d: dumping handle
+ * @b: basic statistics
+ *
+ * Appends the basic statistics to the top level TLV created by
+ * gnet_stats_start_copy().
+ *
+ * Returns 0 on success or -1 with the statistic lock released
+ * if the room in the socket buffer was not sufficient.
+ */
 int
 gnet_stats_copy_basic(struct gnet_dump *d, struct gnet_stats_basic *b)
 {
@@ -71,6 +112,17 @@
 	return gnet_stats_copy(d, TCA_STATS_BASIC, b, sizeof(*b));
 }
 
+/**
+ * gnet_stats_copy_rate_est - copy rate estimator statistics into statistics TLV
+ * @d: dumping handle
+ * @r: rate estimator statistics
+ *
+ * Appends the rate estimator statistics to the top level TLV created by
+ * gnet_stats_start_copy().
+ *
+ * Returns 0 on success or -1 with the statistic lock released
+ * if the room in the socket buffer was not sufficient.
+ */
 int
 gnet_stats_copy_rate_est(struct gnet_dump *d, struct gnet_stats_rate_est *r)
 {
@@ -82,6 +134,17 @@
 	return gnet_stats_copy(d, TCA_STATS_RATE_EST, r, sizeof(*r));
 }
 
+/**
+ * gnet_stats_copy_queue - copy queue statistics into statistics TLV
+ * @d: dumping handle
+ * @q: queue statistics
+ *
+ * Appends the queue statistics to the top level TLV created by
+ * gnet_stats_start_copy().
+ *
+ * Returns 0 on success or -1 with the statistic lock released
+ * if the room in the socket buffer was not sufficient.
+ */
 int
 gnet_stats_copy_queue(struct gnet_dump *d, struct gnet_stats_queue *q)
 {
@@ -95,6 +158,19 @@
 	return gnet_stats_copy(d, TCA_STATS_QUEUE, q, sizeof(*q));
 }
 
+/**
+ * gnet_stats_copy_app - copy application specific statistics into statistics TLV
+ * @d: dumping handle
+ * @st: application specific statistics data
+ * @len: length of data
+ *
+ * Appends the application sepecific statistics to the top level TLV created by
+ * gnet_stats_start_copy() and remembers the data for XSTATS if the dumping
+ * handle is in backward compatibility mode.
+ *
+ * Returns 0 on success or -1 with the statistic lock released
+ * if the room in the socket buffer was not sufficient.
+ */
 int
 gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
 {
@@ -103,6 +179,18 @@
 	return gnet_stats_copy(d, TCA_STATS_APP, st, len);
 }
 
+/**
+ * gnet_stats_finish_copy - finish dumping procedure
+ * @d: dumping handle
+ *
+ * Corrects the length of the top level TLV to include all TLVs added
+ * by gnet_stats_copy_XXX() calls. Adds the backward compatibility TLVs
+ * if gnet_stats_start_copy_compat() was used and releases the statistics
+ * lock.
+ *
+ * Returns 0 on success or -1 with the statistic lock released
+ * if the room in the socket buffer was not sufficient.
+ */
 int
 gnet_stats_finish_copy(struct gnet_dump *d)
 {
