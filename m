From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/6] [SCTP] Implement SCTP_PARTIAL_DELIVERY_POINT option.
Date: Fri, 23 Mar 2007 09:52:48 -0400
Message-ID: <11746579722173-git-send-email-vladislav.yasevich@hp.com>
References: <1174657972645-git-send-email-vladislav.yasevich@hp.com>
Cc: sri@us.ibm.com, lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:37746 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422894AbXCWNwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 09:52:54 -0400
In-Reply-To: <1174657972645-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This option induces partial delivery to run as soon
as the specified amount of data has been accumulated on
the association.  However, we give preference to fully
reassembled messages over PD messages.  In any case,
window and buffer is freed up.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@.hp.com>
---
 include/net/sctp/structs.h |    1 +
 include/net/sctp/user.h    |    2 +
 net/sctp/socket.c          |   57 +++++++++++++++++++++++++++++++++++++++
 net/sctp/ulpqueue.c        |   64 +++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 120 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 6883c7d..f4bb396 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -307,6 +307,7 @@ struct sctp_sock {
 	__u8 v4mapped;
 	__u8 frag_interleave;
 	__u32 adaptation_ind;
+	__u32 pd_point;
 
 	atomic_t pd_mode;
 	/* Receive to here while partial delivery is in effect. */
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index e773160..9a83527 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -99,6 +99,8 @@ enum sctp_optname {
 #define SCTP_CONTEXT SCTP_CONTEXT
 	SCTP_FRAGMENT_INTERLEAVE,
 #define SCTP_FRAGMENT_INTERLEAVE SCTP_FRAGMENT_INTERLEAVE
+	SCTP_PARTIAL_DELIVERY_POINT,	/* Set/Get partial delivery point */
+#define SCTP_PARTIAL_DELIVERY_POINT SCTP_PARTIAL_DELIVERY_POINT
 
 	/* Internal Socket Options. Some of the sctp library functions are 
 	 * implemented using these socket options.
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 912073d..2d0c2ee 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2826,6 +2826,32 @@ static int sctp_setsockopt_fragment_interleave(struct sock *sk,
 	return 0;
 }
 
+/*
+ * 7.1.25.  Set or Get the sctp partial delivery point
+ *       (SCTP_PARTIAL_DELIVERY_POINT)
+ * This option will set or get the SCTP partial delivery point.  This
+ * point is the size of a message where the partial delivery API will be
+ * invoked to help free up rwnd space for the peer.  Setting this to a
+ * lower value will cause partial delivery's to happen more often.  The
+ * calls argument is an integer that sets or gets the partial delivery
+ * point.
+ */
+static int sctp_setsockopt_partial_delivery_point(struct sock *sk,
+						  char __user *optval,
+						  int optlen)
+{
+	u32 val;
+
+	if (optlen != sizeof(u32))
+		return -EINVAL;
+	if (get_user(val, (int __user *)optval))
+		return -EFAULT;
+
+	sctp_sk(sk)->pd_point = val;
+
+	return 0; /* is this the right error code? */
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -2905,6 +2931,9 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_DELAYED_ACK_TIME:
 		retval = sctp_setsockopt_delayed_ack_time(sk, optval, optlen);
 		break;
+	case SCTP_PARTIAL_DELIVERY_POINT:
+		retval = sctp_setsockopt_partial_delivery_point(sk, optval, optlen);
+		break;
 
 	case SCTP_INITMSG:
 		retval = sctp_setsockopt_initmsg(sk, optval, optlen);
@@ -4596,6 +4625,30 @@ static int sctp_getsockopt_fragment_interleave(struct sock *sk, int len,
 	return 0;
 }
 
+/*
+ * 7.1.25.  Set or Get the sctp partial delivery point
+ * (chapter and verse is quoted at sctp_setsockopt_partial_delivery_point())
+ */
+static int sctp_getsockopt_partial_delivery_point(struct sock *sk, int len,
+						  char __user *optval,
+						  int __user *optlen)
+{
+        u32 val;
+
+	if (len < sizeof(u32))
+		return -EINVAL;
+
+	len = sizeof(u32);
+
+	val = sctp_sk(sk)->pd_point;
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(optval, &val, len))
+		return -EFAULT;
+
+	return -ENOTSUPP;
+}
+
 SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 				char __user *optval, int __user *optlen)
 {
@@ -4712,6 +4765,10 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_getsockopt_fragment_interleave(sk, len, optval,
 							     optlen);
 		break;
+	case SCTP_PARTIAL_DELIVERY_POINT:
+		retval = sctp_getsockopt_partial_delivery_point(sk, len, optval,
+								optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 896e834..6f64b15 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -177,6 +177,15 @@ int sctp_clear_pd(struct sock *sk, struct sctp_association *asoc)
 	return 0;
 }
 
+/* Set the pd_mode on the socket and ulpq */
+static void sctp_ulpq_set_pd(struct sctp_ulpq *ulpq)
+{
+	struct sctp_sock *sp = sctp_sk(ulpq->asoc->base.sk);
+
+	atomic_inc(&sp->pd_mode);
+	ulpq->pd_mode = 1;
+}
+
 /* Clear the pd_mode and restart any pending messages waiting for delivery. */
 static int sctp_ulpq_clear_pd(struct sctp_ulpq *ulpq)
 {
@@ -395,6 +404,11 @@ static inline struct sctp_ulpevent *sctp_ulpq_retrieve_reassembled(struct sctp_u
 	struct sk_buff *first_frag = NULL;
 	__u32 ctsn, next_tsn;
 	struct sctp_ulpevent *retval = NULL;
+	struct sk_buff *pd_first = NULL;
+	struct sk_buff *pd_last = NULL;
+	size_t pd_len = 0;
+	struct sctp_association *asoc;
+	u32 pd_point;
 
 	/* Initialized to 0 just to avoid compiler warning message.  Will
 	 * never be used with this value. It is referenced only after it
@@ -410,6 +424,10 @@ static inline struct sctp_ulpevent *sctp_ulpq_retrieve_reassembled(struct sctp_u
 	 * we expect to find the remaining middle fragments and the last
 	 * fragment in order. If not, first_frag is reset to NULL and we
 	 * start the next pass when we find another first fragment.
+	 *
+	 * There is a potential to do partial delivery if user sets
+	 * SCTP_PARTIAL_DELIVERY_POINT option. Lets count some things here
+	 * to see if can do PD.
 	 */
 	skb_queue_walk(&ulpq->reasm, pos) {
 		cevent = sctp_skb2event(pos);
@@ -417,14 +435,32 @@ static inline struct sctp_ulpevent *sctp_ulpq_retrieve_reassembled(struct sctp_u
 
 		switch (cevent->msg_flags & SCTP_DATA_FRAG_MASK) {
 		case SCTP_DATA_FIRST_FRAG:
+			/* If this "FIRST_FRAG" is the first
+			 * element in the queue, then count it towards
+			 * possible PD.
+			 */
+			if (pos == ulpq->reasm.next) {
+			    pd_first = pos;
+			    pd_last = pos;
+			    pd_len = pos->len;
+			} else {
+			    pd_first = NULL;
+			    pd_last = NULL;
+			    pd_len = 0;
+			}
+
 			first_frag = pos;
 			next_tsn = ctsn + 1;
 			break;
 
 		case SCTP_DATA_MIDDLE_FRAG:
-			if ((first_frag) && (ctsn == next_tsn))
+			if ((first_frag) && (ctsn == next_tsn)) {
 				next_tsn++;
-			else
+				if (pd_first) {
+				    pd_last = pos;
+				    pd_len += pos->len;
+				}
+			} else
 				first_frag = NULL;
 			break;
 
@@ -435,7 +471,28 @@ static inline struct sctp_ulpevent *sctp_ulpq_retrieve_reassembled(struct sctp_u
 				first_frag = NULL;
 			break;
 		};
+	}
+
+	asoc = ulpq->asoc;
+	if (pd_first) {
+		/* Make sure we can enter partial deliver.
+		 * We can trigger partial delivery only if framgent
+		 * interleave is set, or the socket is not already
+		 * in  partial delivery.
+		 */
+		if (!sctp_sk(asoc->base.sk)->frag_interleave &&
+		    atomic_read(&sctp_sk(asoc->base.sk)->pd_mode))
+			goto done;
 
+		cevent = sctp_skb2event(pd_first);
+		pd_point = sctp_sk(asoc->base.sk)->pd_point;
+		if (pd_point && pd_point <= pd_len) {
+			retval = sctp_make_reassembled_event(&ulpq->reasm,
+							     pd_first,
+							     pd_last);
+			if (retval)
+				sctp_ulpq_set_pd(ulpq);
+		}
 	}
 done:
 	return retval;
@@ -876,8 +933,7 @@ void sctp_ulpq_partial_delivery(struct sctp_ulpq *ulpq,
 		/* Send event to the ULP.   */
 		if (event) {
 			sctp_ulpq_tail_event(ulpq, event);
-			atomic_inc(&sp->pd_mode);
-			ulpq->pd_mode = 1;
+			sctp_ulpq_set_pd(ulpq);
 			return;
 		}
 	}
-- 
1.5.0.3.438.gc49b2

