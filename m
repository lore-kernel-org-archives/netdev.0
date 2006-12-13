From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 3/4][SCTP]: Add support for SCTP_CONTEXT socket option.
Date: Wed, 13 Dec 2006 12:44:50 -0800
Message-ID: <1166042690.4670.12.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:55856 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750848AbWLMUpW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 15:45:22 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDKjNqC011942
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 15:45:23 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDKit0O193424
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 15:44:55 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDKit2D014349
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 15:44:55 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Add support for SCTP_CONTEXT socket option.

Signed-off-by: Ivan Skytte Jorgensen <isj-sctp@i1.dk>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/sctp/structs.h |    4 ++
 include/net/sctp/user.h    |    2 +
 net/sctp/associola.c       |    1 +
 net/sctp/socket.c          |   84 ++++++++++++++++++++++++++++++++++++++++++++
 net/sctp/ulpevent.c        |    4 ++
 5 files changed, 94 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index b00d85e..8d7f26d 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -275,6 +275,7 @@ struct sctp_sock {
 	__u16 default_flags;
 	__u32 default_context;
 	__u32 default_timetolive;
+	__u32 default_rcv_context;
 
 	/* Heartbeat interval: The endpoint sends out a Heartbeat chunk to
 	 * the destination address every heartbeat interval. This value
@@ -1657,6 +1658,9 @@ struct sctp_association {
 	__u32 default_context;
 	__u32 default_timetolive;
 
+	/* Default receive parameters */
+	__u32 default_rcv_context;
+
 	/* This tracks outbound ssn for a given stream.	 */
 	struct sctp_ssnmap *ssnmap;
 
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 1b7aae6..9e4a39f 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -95,6 +95,8 @@ #define SCTP_STATUS SCTP_STATUS
 #define SCTP_GET_PEER_ADDR_INFO SCTP_GET_PEER_ADDR_INFO
 	SCTP_DELAYED_ACK_TIME,
 #define SCTP_DELAYED_ACK_TIME SCTP_DELAYED_ACK_TIME
+	SCTP_CONTEXT,	/* Receive Context */
+#define SCTP_CONTEXT SCTP_CONTEXT
 
 	/* Internal Socket Options. Some of the sctp library functions are 
 	 * implemented using these socket options.
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index ad0057d..5db95ca 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -298,6 +298,7 @@ static struct sctp_association *sctp_ass
 	asoc->default_flags = sp->default_flags;
 	asoc->default_context = sp->default_context;
 	asoc->default_timetolive = sp->default_timetolive;
+	asoc->default_rcv_context = sp->default_rcv_context;
 
 	return asoc;
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index fa29eae..bdd8bd4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2746,6 +2746,46 @@ static int sctp_setsockopt_adaption_laye
 	return 0;
 }
 
+/*
+ * 7.1.29.  Set or Get the default context (SCTP_CONTEXT)
+ *
+ * The context field in the sctp_sndrcvinfo structure is normally only
+ * used when a failed message is retrieved holding the value that was
+ * sent down on the actual send call.  This option allows the setting of
+ * a default context on an association basis that will be received on
+ * reading messages from the peer.  This is especially helpful in the
+ * one-2-many model for an application to keep some reference to an
+ * internal state machine that is processing messages on the
+ * association.  Note that the setting of this value only effects
+ * received messages from the peer and does not effect the value that is
+ * saved with outbound messages.
+ */
+static int sctp_setsockopt_context(struct sock *sk, char __user *optval,
+				   int optlen)
+{
+	struct sctp_assoc_value params;
+	struct sctp_sock *sp;
+	struct sctp_association *asoc;
+
+	if (optlen != sizeof(struct sctp_assoc_value))
+		return -EINVAL;
+	if (copy_from_user(&params, optval, optlen))
+		return -EFAULT;
+
+	sp = sctp_sk(sk);
+
+	if (params.assoc_id != 0) {
+		asoc = sctp_id2assoc(sk, params.assoc_id);
+		if (!asoc)
+			return -EINVAL;
+		asoc->default_rcv_context = params.assoc_value;
+	} else {
+		sp->default_rcv_context = params.assoc_value;
+	}
+
+	return 0;
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -2857,6 +2897,9 @@ SCTP_STATIC int sctp_setsockopt(struct s
 	case SCTP_ADAPTION_LAYER:
 		retval = sctp_setsockopt_adaption_layer(sk, optval, optlen);
 		break;
+	case SCTP_CONTEXT:
+		retval = sctp_setsockopt_context(sk, optval, optlen);
+		break;
 
 	default:
 		retval = -ENOPROTOOPT;
@@ -3016,6 +3059,8 @@ SCTP_STATIC int sctp_init_sock(struct so
 	sp->default_context = 0;
 	sp->default_timetolive = 0;
 
+	sp->default_rcv_context = 0;
+
 	/* Initialize default setup parameters. These parameters
 	 * can be modified with the SCTP_INITMSG socket option or
 	 * overridden by the SCTP_INIT CMSG.
@@ -4421,6 +4466,42 @@ static int sctp_getsockopt_mappedv4(stru
 }
 
 /*
+ * 7.1.29.  Set or Get the default context (SCTP_CONTEXT)
+ * (chapter and verse is quoted at sctp_setsockopt_context())
+ */
+static int sctp_getsockopt_context(struct sock *sk, int len,
+				   char __user *optval, int __user *optlen)
+{
+	struct sctp_assoc_value params;
+	struct sctp_sock *sp;
+	struct sctp_association *asoc;
+
+	if (len != sizeof(struct sctp_assoc_value))
+		return -EINVAL;
+
+	if (copy_from_user(&params, optval, len))
+		return -EFAULT;
+
+	sp = sctp_sk(sk);
+
+	if (params.assoc_id != 0) {
+		asoc = sctp_id2assoc(sk, params.assoc_id);
+		if (!asoc)
+			return -EINVAL;
+		params.assoc_value = asoc->default_rcv_context;
+	} else {
+		params.assoc_value = sp->default_rcv_context;
+	}
+
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(optval, &params, len))
+		return -EFAULT;
+
+	return 0;
+}
+
+/*
  * 7.1.17 Set the maximum fragrmentation size (SCTP_MAXSEG)
  *
  * This socket option specifies the maximum size to put in any outgoing
@@ -4558,6 +4639,9 @@ SCTP_STATIC int sctp_getsockopt(struct s
 		retval = sctp_getsockopt_adaption_layer(sk, len, optval,
 							optlen);
 		break;
+	case SCTP_CONTEXT:
+		retval = sctp_getsockopt_context(sk, len, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index e255a70..93ac63b 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -849,8 +849,10 @@ void sctp_ulpevent_read_sndrcvinfo(const
 	 */
 	sinfo.sinfo_assoc_id = sctp_assoc2id(event->asoc);
 
+	/* context value that is set via SCTP_CONTEXT socket option. */
+	sinfo.sinfo_context = event->asoc->default_rcv_context;
+
 	/* These fields are not used while receiving. */
-	sinfo.sinfo_context = 0;
 	sinfo.sinfo_timetolive = 0;
 
 	put_cmsg(msghdr, IPPROTO_SCTP, SCTP_SNDRCV,


