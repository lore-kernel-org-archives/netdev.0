From: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 10/23] net, rds: convert rds_message.m_refcount from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 14:10:33 +0200
Message-ID: <1489752646-8749-11-git-send-email-elena.reshetova@intel.com>
References: <1489752646-8749-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-x25-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vyasevich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        zyan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sage-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
        jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
        herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
        jreuter-K7Hl1MveuGQ@public.gmane.org, ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
        keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489752646-8749-1-git-send-email-elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Signed-off-by: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/rds/message.c | 12 ++++++------
 net/rds/rds.h     |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/rds/message.c b/net/rds/message.c
index 49bfb51..4318cc9 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -48,8 +48,8 @@ static unsigned int	rds_exthdr_size[__RDS_EXTHDR_MAX] = {
 
 void rds_message_addref(struct rds_message *rm)
 {
-	rdsdebug("addref rm %p ref %d\n", rm, atomic_read(&rm->m_refcount));
-	atomic_inc(&rm->m_refcount);
+	rdsdebug("addref rm %p ref %d\n", rm, refcount_read(&rm->m_refcount));
+	refcount_inc(&rm->m_refcount);
 }
 EXPORT_SYMBOL_GPL(rds_message_addref);
 
@@ -83,9 +83,9 @@ static void rds_message_purge(struct rds_message *rm)
 
 void rds_message_put(struct rds_message *rm)
 {
-	rdsdebug("put rm %p ref %d\n", rm, atomic_read(&rm->m_refcount));
-	WARN(!atomic_read(&rm->m_refcount), "danger refcount zero on %p\n", rm);
-	if (atomic_dec_and_test(&rm->m_refcount)) {
+	rdsdebug("put rm %p ref %d\n", rm, refcount_read(&rm->m_refcount));
+	WARN(!refcount_read(&rm->m_refcount), "danger refcount zero on %p\n", rm);
+	if (refcount_dec_and_test(&rm->m_refcount)) {
 		BUG_ON(!list_empty(&rm->m_sock_item));
 		BUG_ON(!list_empty(&rm->m_conn_item));
 		rds_message_purge(rm);
@@ -206,7 +206,7 @@ struct rds_message *rds_message_alloc(unsigned int extra_len, gfp_t gfp)
 	rm->m_used_sgs = 0;
 	rm->m_total_sgs = extra_len / sizeof(struct scatterlist);
 
-	atomic_set(&rm->m_refcount, 1);
+	refcount_set(&rm->m_refcount, 1);
 	INIT_LIST_HEAD(&rm->m_sock_item);
 	INIT_LIST_HEAD(&rm->m_conn_item);
 	spin_lock_init(&rm->m_rs_lock);
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 7487597..8c205ff 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -355,7 +355,7 @@ static inline u32 rds_rdma_cookie_offset(rds_rdma_cookie_t cookie)
 #define RDS_MSG_FLUSH		8
 
 struct rds_message {
-	atomic_t		m_refcount;
+	refcount_t		m_refcount;
 	struct list_head	m_sock_item;
 	struct list_head	m_conn_item;
 	struct rds_incoming	m_inc;
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
