From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3] [NET]: Improve gnet_stats_* dumping logic to be less error prone
Date: Sat, 2 Apr 2005 01:28:36 +0200
Message-ID: <20050401232835.GM3086@postel.suug.ch>
References: <20050401232654.GJ3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050401232654.GJ3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/04/01 15:01:24+02:00 tgraf@suug.ch 
#   [NET]: Improve gnet_stats_* dumping logic to be less error prone
#   
#   The recent additions to make gnet_stats_* useable for action
#   statistics dumping in two steps introcuded a few error prone
#   assumptions which can easly be forgotten. This patch fixes this
#   up by simplifying the process of adding new fields to struct
#   gnet_dump or adding additional backward compatibility TLVs.
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/core/gen_stats.c
#   2005/04/01 15:01:12+02:00 tgraf@suug.ch +24 -13
#   [NET]: Improve gnet_stats_* dumping logic to be less error prone
# 
diff -Nru a/net/core/gen_stats.c b/net/core/gen_stats.c
--- a/net/core/gen_stats.c	2005-04-02 01:18:26 +02:00
+++ b/net/core/gen_stats.c	2005-04-02 01:18:26 +02:00
@@ -26,9 +26,7 @@
 static inline int
 gnet_stats_copy(struct gnet_dump *d, int type, void *buf, int size)
 {
-	if (type)
-		RTA_PUT(d->skb, type, size, buf);
-
+	RTA_PUT(d->skb, type, size, buf);
 	return 0;
 
 rtattr_failure:
@@ -58,6 +56,8 @@
 gnet_stats_start_copy_compat(struct sk_buff *skb, int type, int tc_stats_type,
 	int xstats_type, spinlock_t *lock, struct gnet_dump *d)
 {
+	memset(d, 0, sizeof(*d));
+	
 	spin_lock_bh(lock);
 	d->lock = lock;
 	if (type)
@@ -65,12 +65,11 @@
 	d->skb = skb;
 	d->compat_tc_stats = tc_stats_type;
 	d->compat_xstats = xstats_type;
-	d->xstats = NULL;
 
-	if (d->compat_tc_stats)
-		memset(&d->tc_stats, 0, sizeof(d->tc_stats));
+	if (d->tail)
+		return gnet_stats_copy(d, type, NULL, 0);
 
-	return gnet_stats_copy(d, type, NULL, 0);
+	return 0;
 }
 
 /**
@@ -111,8 +110,11 @@
 		d->tc_stats.bytes = b->bytes;
 		d->tc_stats.packets = b->packets;
 	}
-	
-	return gnet_stats_copy(d, TCA_STATS_BASIC, b, sizeof(*b));
+
+	if (d->tail)
+		return gnet_stats_copy(d, TCA_STATS_BASIC, b, sizeof(*b));
+
+	return 0;
 }
 
 /**
@@ -134,7 +136,10 @@
 		d->tc_stats.pps = r->pps;
 	}
 
-	return gnet_stats_copy(d, TCA_STATS_RATE_EST, r, sizeof(*r));
+	if (d->tail)
+		return gnet_stats_copy(d, TCA_STATS_RATE_EST, r, sizeof(*r));
+
+	return 0;
 }
 
 /**
@@ -157,8 +162,11 @@
 		d->tc_stats.backlog = q->backlog;
 		d->tc_stats.overlimits = q->overlimits;
 	}
-		
-	return gnet_stats_copy(d, TCA_STATS_QUEUE, q, sizeof(*q));
+
+	if (d->tail)
+		return gnet_stats_copy(d, TCA_STATS_QUEUE, q, sizeof(*q));
+
+	return 0;
 }
 
 /**
@@ -182,7 +190,10 @@
 		d->xstats_len = len;
 	}
 
-	return gnet_stats_copy(d, TCA_STATS_APP, st, len);
+	if (d->tail)
+		return gnet_stats_copy(d, TCA_STATS_APP, st, len);
+
+	return 0;
 }
 
 /**
