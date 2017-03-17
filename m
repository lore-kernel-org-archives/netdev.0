From: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 18/23] net, sctp: convert sctp_chunk.refcnt from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 14:10:41 +0200
Message-ID: <1489752646-8749-19-git-send-email-elena.reshetova@intel.com>
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
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489752646-8749-1-git-send-email-elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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
 include/net/sctp/structs.h | 2 +-
 net/sctp/sm_make_chunk.c   | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 106e1d3..7ee0c26 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -520,7 +520,7 @@ int sctp_chunk_abandoned(struct sctp_chunk *);
 struct sctp_chunk {
 	struct list_head list;
 
-	atomic_t refcnt;
+	refcount_t refcnt;
 
 	/* How many times this chunk have been sent, for prsctp RTX policy */
 	int sent_count;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 969a30c..a54add6 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1346,7 +1346,7 @@ struct sctp_chunk *sctp_chunkify(struct sk_buff *skb,
 	INIT_LIST_HEAD(&retval->transmitted_list);
 	INIT_LIST_HEAD(&retval->frag_list);
 	SCTP_DBG_OBJCNT_INC(chunk);
-	atomic_set(&retval->refcnt, 1);
+	refcount_set(&retval->refcnt, 1);
 
 nodata:
 	return retval;
@@ -1459,13 +1459,13 @@ void sctp_chunk_free(struct sctp_chunk *chunk)
 /* Grab a reference to the chunk. */
 void sctp_chunk_hold(struct sctp_chunk *ch)
 {
-	atomic_inc(&ch->refcnt);
+	refcount_inc(&ch->refcnt);
 }
 
 /* Release a reference to the chunk. */
 void sctp_chunk_put(struct sctp_chunk *ch)
 {
-	if (atomic_dec_and_test(&ch->refcnt))
+	if (refcount_dec_and_test(&ch->refcnt))
 		sctp_chunk_destroy(ch);
 }
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
