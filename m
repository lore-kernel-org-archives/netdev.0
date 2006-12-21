From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 3/4][SCTP]: Implement SCTP_FRAGMENT_INTERLEAVE socket
	option.
Date: Wed, 20 Dec 2006 16:00:57 -0800
Message-ID: <1166659257.5722.17.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:35587 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161030AbWLUABC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 19:01:02 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBL010xT002498
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 19:01:00 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBL00xUa295678
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 19:00:59 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBL00wZs011949
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 19:00:58 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Implement SCTP_FRAGMENT_INTERLEAVE socket option.

This option was introduced in draft-ietf-tsvwg-sctpsocket-13.  It
prevents head-of-line blocking in the case of one-to-many endpoint.
Applications enabling this option really must enable SCTP_SNDRCV event
so that they would know where the data belongs.  Based on an
earlier patch by Ivan Skytte J=C3=B8rgensen.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/sctp/structs.h |    1 +
 include/net/sctp/user.h    |    4 ++
 net/sctp/socket.c          |   75 ++++++++++++++++++++++++++++++++++++=
+++++++-
 net/sctp/ulpqueue.c        |   30 ++++++++++++------
 4 files changed, 97 insertions(+), 13 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index c9075d0..7497cec 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -306,6 +306,7 @@ struct sctp_sock {
 	__u8 disable_fragments;
 	__u8 pd_mode;
 	__u8 v4mapped;
+	__u8 frag_interleave;
 	__u32 adaptation_ind;
=20
 	/* Receive to here while partial delivery is in effect. */
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 4116b0d..8c1d68c 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -97,6 +97,8 @@ #define SCTP_GET_PEER_ADDR_INFO SCTP_GET
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
index ec70201..91bef1e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2249,7 +2249,7 @@ static int sctp_setsockopt_peer_addr_par
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
@@ -2786,6 +2786,46 @@ static int sctp_setsockopt_context(struc
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
@@ -2900,7 +2940,9 @@ SCTP_STATIC int sctp_setsockopt(struct s
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
@@ -3130,6 +3172,7 @@ SCTP_STATIC int sctp_init_sock(struct so
 	/* Control variables for partial data delivery. */
 	sp->pd_mode           =3D 0;
 	skb_queue_head_init(&sp->pd_lobby);
+	sp->frag_interleave =3D 0;
=20
 	/* Create a per socket endpoint structure.  Even if we
 	 * change the data structure relationships, this may still
@@ -4530,6 +4573,30 @@ static int sctp_getsockopt_maxseg(struct
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
+					       char __user *optval,
+					       int __user *optlen)
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
@@ -4642,6 +4709,10 @@ SCTP_STATIC int sctp_getsockopt(struct s
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
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index e1d1442..d1e4ebd 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -184,20 +184,30 @@ int sctp_ulpq_tail_event(struct sctp_ulp
=20
 	/* If we are in partial delivery mode, post to the lobby until
 	 * partial delivery is cleared, unless, of course _this_ is
-	 * the association the cause of the partial delivery.
+	 * the association that caused partial delivery.
 	 */
-
 	if (!sctp_sk(sk)->pd_mode) {
 		queue =3D &sk->sk_receive_queue;
-	} else if (ulpq->pd_mode) {
-		if (event->msg_flags & MSG_NOTIFICATION)
-		       	queue =3D &sctp_sk(sk)->pd_lobby;
-		else {
-			clear_pd =3D event->msg_flags & MSG_EOR;
-			queue =3D &sk->sk_receive_queue;
+	} else {
+		if (ulpq->pd_mode) {
+			if (event->msg_flags & MSG_NOTIFICATION)
+		       		queue =3D &sctp_sk(sk)->pd_lobby;
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

 	/* If we are harvesting multiple skbs they will be


