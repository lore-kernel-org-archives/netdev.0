From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v2 11/18] RDS: IB: add few useful cache stasts
Date: Tue,  6 Dec 2016 20:01:49 -0800
Message-ID: <1481083316-11648-12-git-send-email-santosh.shilimkar@oracle.com>
References: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tracks the ib receive cache total, incoming and frag allocations.

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.h       | 7 +++++++
 net/rds/ib_recv.c  | 6 ++++++
 net/rds/ib_stats.c | 2 ++
 3 files changed, 15 insertions(+)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index 97e7696..4987387 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -151,6 +151,7 @@ struct rds_ib_connection {
 	u64			i_ack_recv;	/* last ACK received */
 	struct rds_ib_refill_cache i_cache_incs;
 	struct rds_ib_refill_cache i_cache_frags;
+	atomic_t		i_cache_allocs;
 
 	/* sending acks */
 	unsigned long		i_ack_flags;
@@ -254,6 +255,8 @@ struct rds_ib_statistics {
 	uint64_t	s_ib_rx_refill_from_cq;
 	uint64_t	s_ib_rx_refill_from_thread;
 	uint64_t	s_ib_rx_alloc_limit;
+	uint64_t	s_ib_rx_total_frags;
+	uint64_t	s_ib_rx_total_incs;
 	uint64_t	s_ib_rx_credit_updates;
 	uint64_t	s_ib_ack_sent;
 	uint64_t	s_ib_ack_send_failure;
@@ -276,6 +279,8 @@ struct rds_ib_statistics {
 	uint64_t	s_ib_rdma_mr_1m_reused;
 	uint64_t	s_ib_atomic_cswp;
 	uint64_t	s_ib_atomic_fadd;
+	uint64_t	s_ib_recv_added_to_cache;
+	uint64_t	s_ib_recv_removed_from_cache;
 };
 
 extern struct workqueue_struct *rds_ib_wq;
@@ -406,6 +411,8 @@ int rds_ib_send_grab_credits(struct rds_ib_connection *ic, u32 wanted,
 /* ib_stats.c */
 DECLARE_PER_CPU(struct rds_ib_statistics, rds_ib_stats);
 #define rds_ib_stats_inc(member) rds_stats_inc_which(rds_ib_stats, member)
+#define rds_ib_stats_add(member, count) \
+		rds_stats_add_which(rds_ib_stats, member, count)
 unsigned int rds_ib_stats_info_copy(struct rds_info_iterator *iter,
 				    unsigned int avail);
 
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 6803b75..4b0f126 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -194,6 +194,8 @@ static void rds_ib_frag_free(struct rds_ib_connection *ic,
 	rdsdebug("frag %p page %p\n", frag, sg_page(&frag->f_sg));
 
 	rds_ib_recv_cache_put(&frag->f_cache_entry, &ic->i_cache_frags);
+	atomic_add(RDS_FRAG_SIZE / SZ_1K, &ic->i_cache_allocs);
+	rds_ib_stats_add(s_ib_recv_added_to_cache, RDS_FRAG_SIZE);
 }
 
 /* Recycle inc after freeing attached frags */
@@ -261,6 +263,7 @@ static struct rds_ib_incoming *rds_ib_refill_one_inc(struct rds_ib_connection *i
 			atomic_dec(&rds_ib_allocation);
 			return NULL;
 		}
+		rds_ib_stats_inc(s_ib_rx_total_incs);
 	}
 	INIT_LIST_HEAD(&ibinc->ii_frags);
 	rds_inc_init(&ibinc->ii_inc, ic->conn, ic->conn->c_faddr);
@@ -278,6 +281,8 @@ static struct rds_page_frag *rds_ib_refill_one_frag(struct rds_ib_connection *ic
 	cache_item = rds_ib_recv_cache_get(&ic->i_cache_frags);
 	if (cache_item) {
 		frag = container_of(cache_item, struct rds_page_frag, f_cache_entry);
+		atomic_sub(RDS_FRAG_SIZE / SZ_1K, &ic->i_cache_allocs);
+		rds_ib_stats_add(s_ib_recv_added_to_cache, RDS_FRAG_SIZE);
 	} else {
 		frag = kmem_cache_alloc(rds_ib_frag_slab, slab_mask);
 		if (!frag)
@@ -290,6 +295,7 @@ static struct rds_page_frag *rds_ib_refill_one_frag(struct rds_ib_connection *ic
 			kmem_cache_free(rds_ib_frag_slab, frag);
 			return NULL;
 		}
+		rds_ib_stats_inc(s_ib_rx_total_frags);
 	}
 
 	INIT_LIST_HEAD(&frag->f_item);
diff --git a/net/rds/ib_stats.c b/net/rds/ib_stats.c
index 7e78dca..9252ad1 100644
--- a/net/rds/ib_stats.c
+++ b/net/rds/ib_stats.c
@@ -55,6 +55,8 @@
 	"ib_rx_refill_from_cq",
 	"ib_rx_refill_from_thread",
 	"ib_rx_alloc_limit",
+	"ib_rx_total_frags",
+	"ib_rx_total_incs",
 	"ib_rx_credit_updates",
 	"ib_ack_sent",
 	"ib_ack_send_failure",
-- 
1.9.1
