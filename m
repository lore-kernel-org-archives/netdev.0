From: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 19/23] net, sctp: convert sctp_transport.refcnt from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 14:10:42 +0200
Message-ID: <1489752646-8749-20-git-send-email-elena.reshetova@intel.com>
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
 include/net/sctp/structs.h | 2 +-
 net/sctp/transport.c       | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 7ee0c26..ac3184e 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -731,7 +731,7 @@ struct sctp_transport {
 	struct rhlist_head node;
 
 	/* Reference counting. */
-	atomic_t refcnt;
+	refcount_t refcnt;
 		/* RTO-Pending : A flag used to track if one of the DATA
 		 *		chunks sent to this address is currently being
 		 *		used to compute a RTT. If this flag is 0,
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 3379668..45a5774 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -99,7 +99,7 @@ static struct sctp_transport *sctp_transport_init(struct net *net,
 	/* Initialize the 64-bit random nonce sent with heartbeat. */
 	get_random_bytes(&peer->hb_nonce, sizeof(peer->hb_nonce));
 
-	atomic_set(&peer->refcnt, 1);
+	refcount_set(&peer->refcnt, 1);
 
 	return peer;
 }
@@ -172,7 +172,7 @@ static void sctp_transport_destroy_rcu(struct rcu_head *head)
  */
 static void sctp_transport_destroy(struct sctp_transport *transport)
 {
-	if (unlikely(atomic_read(&transport->refcnt))) {
+	if (unlikely(refcount_read(&transport->refcnt))) {
 		WARN(1, "Attempt to destroy undead transport %p!\n", transport);
 		return;
 	}
@@ -316,7 +316,7 @@ void sctp_transport_route(struct sctp_transport *transport,
 /* Hold a reference to a transport.  */
 int sctp_transport_hold(struct sctp_transport *transport)
 {
-	return atomic_add_unless(&transport->refcnt, 1, 0);
+	return refcount_inc_not_zero(&transport->refcnt);
 }
 
 /* Release a reference to a transport and clean up
@@ -324,7 +324,7 @@ int sctp_transport_hold(struct sctp_transport *transport)
  */
 void sctp_transport_put(struct sctp_transport *transport)
 {
-	if (atomic_dec_and_test(&transport->refcnt))
+	if (refcount_dec_and_test(&transport->refcnt))
 		sctp_transport_destroy(transport);
 }
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
