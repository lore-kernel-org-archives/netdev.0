From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/6] [SCTP] Implement SCTP_FRAGMENT_INTERLEAVE socket option
Date: Fri, 23 Mar 2007 09:52:47 -0400
Message-ID: <1174657972175-git-send-email-vladislav.yasevich@hp.com>
References: <1174657972645-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sri@us.ibm.com, lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:49637 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422926AbXCWNw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 09:52:59 -0400
In-Reply-To: <1174657972645-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This option was introduced in draft-ietf-tsvwg-sctpsocket-13.  It
prevents head-of-line blocking in the case of one-to-many endpoint.
Applications enabling this option really must enable SCTP_SNDRCV event
so that they would know where the data belongs.  Based on an
earlier patch by Ivan Skytte J=C3=B8rgensen.

Additionally, this functionality now permits multiple associations
on the same endpoint to enter Partial Delivery.  Applications should
be extra careful, when using this functionality, to track EOR indicator=
s.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h  |    3 +-
 include/net/sctp/ulpqueue.h |    2 +-
 include/net/sctp/user.h     |    4 +-
 net/sctp/socket.c           |   84 +++++++++++++++++++++++++++++++++++=
++---
 net/sctp/ulpqueue.c         |   88 ++++++++++++++++++++++++++++++++---=
-------
 5 files changed, 150 insertions(+), 31 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 31a8e88..6883c7d 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -304,10 +304,11 @@ struct sctp_sock {
 	__u32 autoclose;
 	__u8 nodelay;
 	__u8 disable_fragments;
-	__u8 pd_mode;
 	__u8 v4mapped;
+	__u8 frag_interleave;
 	__u32 adaptation_ind;
=20
+	atomic_t pd_mode;
 	/* Receive to here while partial delivery is in effect. */
 	struct sk_buff_head pd_lobby;
 };
diff --git a/include/net/sctp/ulpqueue.h b/include/net/sctp/ulpqueue.h
index a43c878..3421b19 100644
--- a/include/net/sctp/ulpqueue.h
+++ b/include/net/sctp/ulpqueue.h
@@ -77,7 +77,7 @@ void sctp_ulpq_partial_delivery(struct sctp_ulpq *, s=
truct sctp_chunk *, gfp_t);
 void sctp_ulpq_abort_pd(struct sctp_ulpq *, gfp_t);
=20
 /* Clear the partial data delivery condition on this socket. */
-int sctp_clear_pd(struct sock *sk);
+int sctp_clear_pd(struct sock *sk, struct sctp_association *asoc);
=20
 /* Skip over an SSN. */
 void sctp_ulpq_skip(struct sctp_ulpq *ulpq, __u16 sid, __u16 ssn);
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 67a30eb..e773160 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -97,6 +97,8 @@ enum sctp_optname {
 #define SCTP_DELAYED_ACK_TIME SCTP_DELAYED_ACK_TIME
 	SCTP_CONTEXT,	/* Receive Context */
 #define SCTP_CONTEXT SCTP_CONTEXT
+	SCTP_FRAGMENT_INTERLEAVE,
+#define SCTP_FRAGMENT_INTERLEAVE SCTP_FRAGMENT_INTERLEAVE
=20
 	/* Internal Socket Options. Some of the sctp library functions are=20
 	 * implemented using these socket options.
@@ -530,7 +532,7 @@ struct sctp_paddrparams {
 	__u32			spp_flags;
 } __attribute__((packed, aligned(4)));
=20
-/* 7.1.24. Delayed Ack Timer (SCTP_DELAYED_ACK_TIME)
+/* 7.1.23. Delayed Ack Timer (SCTP_DELAYED_ACK_TIME)
  *
  *   This options will get or set the delayed ack timer.  The time is =
set
  *   in milliseconds.  If the assoc_id is 0, then this sets or gets th=
e
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 536298c..912073d 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2249,7 +2249,7 @@ static int sctp_setsockopt_peer_addr_params(struc=
t sock *sk,
 	return 0;
 }
=20
-/* 7.1.24. Delayed Ack Timer (SCTP_DELAYED_ACK_TIME)
+/* 7.1.23. Delayed Ack Timer (SCTP_DELAYED_ACK_TIME)
  *
  *   This options will get or set the delayed ack timer.  The time is =
set
  *   in milliseconds.  If the assoc_id is 0, then this sets or gets th=
e
@@ -2786,6 +2786,46 @@ static int sctp_setsockopt_context(struct sock *=
sk, char __user *optval,
 	return 0;
 }
=20
+/*
+ * 7.1.24.  Get or set fragmented interleave (SCTP_FRAGMENT_INTERLEAVE=
)
+ *
+ * This options will at a minimum specify if the implementation is doi=
ng
+ * fragmented interleave.  Fragmented interleave, for a one to many
+ * socket, is when subsequent calls to receive a message may return
+ * parts of messages from different associations.  Some implementation=
s
+ * may allow you to turn this value on or off.  If so, when turned off=
,
+ * no fragment interleave will occur (which will cause a head of line
+ * blocking amongst multiple associations sharing the same one to many
+ * socket).  When this option is turned on, then each receive call may
+ * come from a different association (thus the user must receive data
+ * with the extended calls (e.g. sctp_recvmsg) to keep track of which
+ * association each receive belongs to.
+ *
+ * This option takes a boolean value.  A non-zero value indicates that
+ * fragmented interleave is on.  A value of zero indicates that
+ * fragmented interleave is off.
+ *
+ * Note that it is important that an implementation that allows this
+ * option to be turned on, have it off by default.  Otherwise an unawa=
re
+ * application using the one to many model may become confused and act
+ * incorrectly.
+ */
+static int sctp_setsockopt_fragment_interleave(struct sock *sk,
+					       char __user *optval,
+					       int optlen)
+{
+	int val;
+
+	if (optlen !=3D sizeof(int))
+		return -EINVAL;
+	if (get_user(val, (int __user *)optval))
+		return -EFAULT;
+
+	sctp_sk(sk)->frag_interleave =3D (val =3D=3D 0) ? 0 : 1;
+
+	return 0;
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -2900,7 +2940,9 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, =
int level, int optname,
 	case SCTP_CONTEXT:
 		retval =3D sctp_setsockopt_context(sk, optval, optlen);
 		break;
-
+	case SCTP_FRAGMENT_INTERLEAVE:
+		retval =3D sctp_setsockopt_fragment_interleave(sk, optval, optlen);
+		break;
 	default:
 		retval =3D -ENOPROTOOPT;
 		break;
@@ -3128,8 +3170,9 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 	sp->pf =3D sctp_get_pf_specific(sk->sk_family);
=20
 	/* Control variables for partial data delivery. */
-	sp->pd_mode           =3D 0;
+	atomic_set(&sp->pd_mode, 0);
 	skb_queue_head_init(&sp->pd_lobby);
+	sp->frag_interleave =3D 0;
=20
 	/* Create a per socket endpoint structure.  Even if we
 	 * change the data structure relationships, this may still
@@ -3636,7 +3679,7 @@ static int sctp_getsockopt_peer_addr_params(struc=
t sock *sk, int len,
 	return 0;
 }
=20
-/* 7.1.24. Delayed Ack Timer (SCTP_DELAYED_ACK_TIME)
+/* 7.1.23. Delayed Ack Timer (SCTP_DELAYED_ACK_TIME)
  *
  *   This options will get or set the delayed ack timer.  The time is =
set
  *   in milliseconds.  If the assoc_id is 0, then this sets or gets th=
e
@@ -4530,6 +4573,29 @@ static int sctp_getsockopt_maxseg(struct sock *s=
k, int len,
 	return 0;
 }
=20
+/*
+ * 7.1.24.  Get or set fragmented interleave (SCTP_FRAGMENT_INTERLEAVE=
)
+ * (chapter and verse is quoted at sctp_setsockopt_fragment_interleave=
())
+ */
+static int sctp_getsockopt_fragment_interleave(struct sock *sk, int le=
n,
+					       char __user *optval, int __user *optlen)
+{
+	int val;
+
+	if (len < sizeof(int))
+		return -EINVAL;
+
+	len =3D sizeof(int);
+
+	val =3D sctp_sk(sk)->frag_interleave;
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(optval, &val, len))
+		return -EFAULT;
+
+	return 0;
+}
+
 SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optnam=
e,
 				char __user *optval, int __user *optlen)
 {
@@ -4642,6 +4708,10 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk,=
 int level, int optname,
 	case SCTP_CONTEXT:
 		retval =3D sctp_getsockopt_context(sk, len, optval, optlen);
 		break;
+	case SCTP_FRAGMENT_INTERLEAVE:
+		retval =3D sctp_getsockopt_fragment_interleave(sk, len, optval,
+							     optlen);
+		break;
 	default:
 		retval =3D -ENOPROTOOPT;
 		break;
@@ -5706,9 +5776,9 @@ static void sctp_sock_migrate(struct sock *oldsk,=
 struct sock *newsk,
 	 * 3) Peeling off non-partial delivery; move pd_lobby to receive_queu=
e.
 	 */
 	skb_queue_head_init(&newsp->pd_lobby);
-	sctp_sk(newsk)->pd_mode =3D assoc->ulpq.pd_mode;
+	atomic_set(&sctp_sk(newsk)->pd_mode, assoc->ulpq.pd_mode);
=20
-	if (sctp_sk(oldsk)->pd_mode) {
+	if (atomic_read(&sctp_sk(oldsk)->pd_mode)) {
 		struct sk_buff_head *queue;
=20
 		/* Decide which queue to move pd_lobby skbs to. */
@@ -5734,7 +5804,7 @@ static void sctp_sock_migrate(struct sock *oldsk,=
 struct sock *newsk,
 		 * delivery to finish.
 		 */
 		if (assoc->ulpq.pd_mode)
-			sctp_clear_pd(oldsk);
+			sctp_clear_pd(oldsk, NULL);
=20
 	}
=20
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index f4759a9..896e834 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -138,18 +138,42 @@ int sctp_ulpq_tail_data(struct sctp_ulpq *ulpq, s=
truct sctp_chunk *chunk,
 /* Clear the partial delivery mode for this socket.   Note: This
  * assumes that no association is currently in partial delivery mode.
  */
-int sctp_clear_pd(struct sock *sk)
+int sctp_clear_pd(struct sock *sk, struct sctp_association *asoc)
 {
 	struct sctp_sock *sp =3D sctp_sk(sk);
=20
-	sp->pd_mode =3D 0;
-	if (!skb_queue_empty(&sp->pd_lobby)) {
-		struct list_head *list;
-		sctp_skb_list_tail(&sp->pd_lobby, &sk->sk_receive_queue);
-		list =3D (struct list_head *)&sctp_sk(sk)->pd_lobby;
-		INIT_LIST_HEAD(list);
-		return 1;
+	if (atomic_dec_and_test(&sp->pd_mode)) {
+		/* This means there are no other associations in PD, so
+		 * we can go ahead and clear out the lobby in one shot
+		 */
+		if (!skb_queue_empty(&sp->pd_lobby)) {
+			struct list_head *list;
+			sctp_skb_list_tail(&sp->pd_lobby, &sk->sk_receive_queue);
+			list =3D (struct list_head *)&sctp_sk(sk)->pd_lobby;
+			INIT_LIST_HEAD(list);
+			return 1;
+		}
+	} else {
+		/* There are other associations in PD, so we only need to
+		 * pull stuff out of the lobby that belongs to the
+		 * associations that is exiting PD (all of its notifications
+		 * are posted here).
+		 */
+		if (!skb_queue_empty(&sp->pd_lobby) && asoc) {
+			struct sk_buff *skb, *tmp;
+			struct sctp_ulpevent *event;
+
+			sctp_skb_for_each(skb, &sp->pd_lobby, tmp) {
+				event =3D sctp_skb2event(skb);
+				if (event->asoc =3D=3D asoc) {
+					__skb_unlink(skb, &sp->pd_lobby);
+					__skb_queue_tail(&sk->sk_receive_queue,
+							 skb);
+				}
+			}
+		}
 	}
+
 	return 0;
 }
=20
@@ -157,7 +181,7 @@ int sctp_clear_pd(struct sock *sk)
 static int sctp_ulpq_clear_pd(struct sctp_ulpq *ulpq)
 {
 	ulpq->pd_mode =3D 0;
-	return sctp_clear_pd(ulpq->asoc->base.sk);
+	return sctp_clear_pd(ulpq->asoc->base.sk, ulpq->asoc);
 }
=20
 /* If the SKB of 'event' is on a list, it is the first such member
@@ -187,17 +211,28 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, =
struct sctp_ulpevent *event)
 	 * the association the cause of the partial delivery.
 	 */
=20
-	if (!sctp_sk(sk)->pd_mode) {
+	if (atomic_read(&sctp_sk(sk)->pd_mode) =3D=3D 0) {
 		queue =3D &sk->sk_receive_queue;
-	} else if (ulpq->pd_mode) {
-		if (event->msg_flags & MSG_NOTIFICATION)
-			queue =3D &sctp_sk(sk)->pd_lobby;
-		else {
-			clear_pd =3D event->msg_flags & MSG_EOR;
-			queue =3D &sk->sk_receive_queue;
+	} else {
+		if (ulpq->pd_mode) {
+			if (event->msg_flags & MSG_NOTIFICATION)
+				queue =3D &sctp_sk(sk)->pd_lobby;
+			else {
+				clear_pd =3D event->msg_flags & MSG_EOR;
+				queue =3D &sk->sk_receive_queue;
+			}
+		} else {
+			/*
+			 * If fragment interleave is enabled, we
+			 * can queue this to the recieve queue instead
+			 * of the lobby.
+			 */
+			if (sctp_sk(sk)->frag_interleave)
+				queue =3D &sk->sk_receive_queue;
+			else
+				queue =3D &sctp_sk(sk)->pd_lobby;
 		}
-	} else
-		queue =3D &sctp_sk(sk)->pd_lobby;
+	}
=20
=20
 	/* If we are harvesting multiple skbs they will be
@@ -819,18 +854,29 @@ void sctp_ulpq_partial_delivery(struct sctp_ulpq =
*ulpq,
 {
 	struct sctp_ulpevent *event;
 	struct sctp_association *asoc;
+	struct sctp_sock *sp;
=20
 	asoc =3D ulpq->asoc;
+	sp =3D sctp_sk(asoc->base.sk);
=20
-	/* Are we already in partial delivery mode?  */
-	if (!sctp_sk(asoc->base.sk)->pd_mode) {
+	/* If the association is already in Partial Delivery mode
+	 * we have noting to do.
+	 */
+	if (ulpq->pd_mode)
+		return;
=20
+	/* If the user enabled fragment interleave socket option,
+	 * multiple associations can enter partial delivery.
+	 * Otherwise, we can only enter partial delivery if the
+	 * socket is not in partial deliver mode.
+	 */
+	if (sp->frag_interleave || atomic_read(&sp->pd_mode) =3D=3D 0) {
 		/* Is partial delivery possible?  */
 		event =3D sctp_ulpq_retrieve_first(ulpq);
 		/* Send event to the ULP.   */
 		if (event) {
 			sctp_ulpq_tail_event(ulpq, event);
-			sctp_sk(asoc->base.sk)->pd_mode =3D 1;
+			atomic_inc(&sp->pd_mode);
 			ulpq->pd_mode =3D 1;
 			return;
 		}
--=20
1.5.0.3.438.gc49b2

