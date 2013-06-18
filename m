From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/5] net: sctp: migrate cookie life from timeval to ktime
Date: Tue, 18 Jun 2013 10:55:18 +0200
Message-ID: <1371545720-22950-4-git-send-email-dborkman@redhat.com>
References: <1371545720-22950-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798Ab3FRIz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 04:55:26 -0400
In-Reply-To: <1371545720-22950-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, SCTP code defines its own timeval functions (since timeval
is rarely used inside the kernel by others), namely tv_lt() and
TIMEVAL_ADD() macros, that operate on SCTP cookie expiration.

We might as well remove all those, and operate directly on ktime
structures for a couple of reasons: ktime is available on all archs;
complexity of ktime calculations depending on the arch is less than
(reduces to simpler arithmetic operations on archs with
BITS_PER_LONG == 64 or CONFIG_KTIME_SCALAR) or equal to timeval
functions; code becomes more readable; macros can be thrown out.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/sctp.h    | 18 ------------------
 include/net/sctp/structs.h |  6 +++---
 net/sctp/associola.c       |  8 +-------
 net/sctp/sm_make_chunk.c   | 19 ++++++++-----------
 net/sctp/socket.c          | 14 +++-----------
 5 files changed, 15 insertions(+), 50 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 15214a8..e6b95bc 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -560,24 +560,6 @@ for (pos = chunk->subh.fwdtsn_hdr->skip;\
 /* Round an int up to the next multiple of 4.  */
 #define WORD_ROUND(s) (((s)+3)&~3)
 
-/* Compare two timevals.  */
-#define tv_lt(s, t) \
-   (s.tv_sec < t.tv_sec || (s.tv_sec == t.tv_sec && s.tv_usec < t.tv_usec))
-
-/* Add tv1 to tv2. */
-#define TIMEVAL_ADD(tv1, tv2) \
-({ \
-        suseconds_t usecs = (tv2).tv_usec + (tv1).tv_usec; \
-        time_t secs = (tv2).tv_sec + (tv1).tv_sec; \
-\
-        if (usecs >= 1000000) { \
-                usecs -= 1000000; \
-                secs++; \
-        } \
-        (tv2).tv_sec = secs; \
-        (tv2).tv_usec = usecs; \
-})
-
 /* External references. */
 
 extern struct proto sctp_prot;
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 1bd4c41..e745c92 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -54,7 +54,7 @@
 #ifndef __sctp_structs_h__
 #define __sctp_structs_h__
 
-#include <linux/time.h>		/* We get struct timespec.    */
+#include <linux/ktime.h>
 #include <linux/socket.h>	/* linux/in.h needs this!!    */
 #include <linux/in.h>		/* We get struct sockaddr_in. */
 #include <linux/in6.h>		/* We get struct in6_addr     */
@@ -284,7 +284,7 @@ struct sctp_cookie {
 	__u32 peer_ttag;
 
 	/* When does this cookie expire? */
-	struct timeval expiration;
+	ktime_t expiration;
 
 	/* Number of inbound/outbound streams which are set
 	 * and negotiated during the INIT process.
@@ -1537,7 +1537,7 @@ struct sctp_association {
 	sctp_state_t state;
 
 	/* The cookie life I award for any cookie.  */
-	struct timeval cookie_life;
+	ktime_t cookie_life;
 
 	/* Overall     : The overall association error count.
 	 * Error Count : [Clear this any time I get something.]
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index bf6e6bd..9a383a8 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -102,13 +102,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	sctp_bind_addr_init(&asoc->base.bind_addr, ep->base.bind_addr.port);
 
 	asoc->state = SCTP_STATE_CLOSED;
-
-	/* Set these values from the socket values, a conversion between
-	 * millsecons to seconds/microseconds must also be done.
-	 */
-	asoc->cookie_life.tv_sec = sp->assocparams.sasoc_cookie_life / 1000;
-	asoc->cookie_life.tv_usec = (sp->assocparams.sasoc_cookie_life % 1000)
-					* 1000;
+	asoc->cookie_life = ms_to_ktime(sp->assocparams.sasoc_cookie_life);
 	asoc->frag_point = 0;
 	asoc->user_frag = sp->user_frag;
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index fc85487..dd71f1f 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1630,8 +1630,8 @@ static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
 	cookie->c.adaptation_ind = asoc->peer.adaptation_ind;
 
 	/* Set an expiration time for the cookie.  */
-	do_gettimeofday(&cookie->c.expiration);
-	TIMEVAL_ADD(asoc->cookie_life, cookie->c.expiration);
+	cookie->c.expiration = ktime_add(asoc->cookie_life,
+					 ktime_get());
 
 	/* Copy the peer's init packet.  */
 	memcpy(&cookie->c.peer_init[0], init_chunk->chunk_hdr,
@@ -1680,7 +1680,7 @@ struct sctp_association *sctp_unpack_cookie(
 	unsigned int len;
 	sctp_scope_t scope;
 	struct sk_buff *skb = chunk->skb;
-	struct timeval tv;
+	ktime_t kt;
 	struct hash_desc desc;
 
 	/* Header size is static data prior to the actual cookie, including
@@ -1757,11 +1757,11 @@ no_hmac:
 	 * down the new association establishment instead of every packet.
 	 */
 	if (sock_flag(ep->base.sk, SOCK_TIMESTAMP))
-		skb_get_timestamp(skb, &tv);
+		kt = skb_get_ktime(skb);
 	else
-		do_gettimeofday(&tv);
+		kt = ktime_get();
 
-	if (!asoc && tv_lt(bear_cookie->expiration, tv)) {
+	if (!asoc && ktime_compare(bear_cookie->expiration, kt) < 0) {
 		/*
 		 * Section 3.3.10.3 Stale Cookie Error (3)
 		 *
@@ -1773,9 +1773,7 @@ no_hmac:
 		len = ntohs(chunk->chunk_hdr->length);
 		*errp = sctp_make_op_error_space(asoc, chunk, len);
 		if (*errp) {
-			suseconds_t usecs = (tv.tv_sec -
-				bear_cookie->expiration.tv_sec) * 1000000L +
-				tv.tv_usec - bear_cookie->expiration.tv_usec;
+			suseconds_t usecs = ktime_to_us(ktime_sub(kt, bear_cookie->expiration));
 			__be32 n = htonl(usecs);
 
 			sctp_init_cause(*errp, SCTP_ERROR_STALE_COOKIE,
@@ -2514,8 +2512,7 @@ do_addr_param:
 		/* Suggested Cookie Life span increment's unit is msec,
 		 * (1/1000sec).
 		 */
-		asoc->cookie_life.tv_sec += stale / 1000;
-		asoc->cookie_life.tv_usec += (stale % 1000) * 1000;
+		asoc->cookie_life = ktime_add_ms(asoc->cookie_life, stale);
 		break;
 
 	case SCTP_PARAM_HOST_NAME_ADDRESS:
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 75fe92a..68a6b70 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2910,13 +2910,8 @@ static int sctp_setsockopt_associnfo(struct sock *sk, char __user *optval, unsig
 			asoc->max_retrans = assocparams.sasoc_asocmaxrxt;
 		}
 
-		if (assocparams.sasoc_cookie_life != 0) {
-			asoc->cookie_life.tv_sec =
-					assocparams.sasoc_cookie_life / 1000;
-			asoc->cookie_life.tv_usec =
-					(assocparams.sasoc_cookie_life % 1000)
-					* 1000;
-		}
+		if (assocparams.sasoc_cookie_life != 0)
+			asoc->cookie_life = ms_to_ktime(assocparams.sasoc_cookie_life);
 	} else {
 		/* Set the values to the endpoint */
 		struct sctp_sock *sp = sctp_sk(sk);
@@ -5068,10 +5063,7 @@ static int sctp_getsockopt_associnfo(struct sock *sk, int len,
 		assocparams.sasoc_asocmaxrxt = asoc->max_retrans;
 		assocparams.sasoc_peer_rwnd = asoc->peer.rwnd;
 		assocparams.sasoc_local_rwnd = asoc->a_rwnd;
-		assocparams.sasoc_cookie_life = (asoc->cookie_life.tv_sec
-						* 1000) +
-						(asoc->cookie_life.tv_usec
-						/ 1000);
+		assocparams.sasoc_cookie_life = ktime_to_ms(asoc->cookie_life);
 
 		list_for_each(pos, &asoc->peer.transport_addr_list) {
 			cnt ++;
-- 
1.7.11.7
