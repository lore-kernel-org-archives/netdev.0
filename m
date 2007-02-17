From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 3/5][SCTP]: Implement SCTP_MAX_BURST socket option.
Date: Fri, 16 Feb 2007 19:39:54 -0800
Message-ID: <1171683594.4568.12.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:55032 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946396AbXBQDj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 22:39:56 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1H3ecaW024512
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 22:40:38 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1H3dtN7232994
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 22:39:55 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1H3dtSj024422
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 22:39:55 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Implement SCTP_MAX_BURST socket option.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/sctp/constants.h |    2 +
 include/net/sctp/structs.h   |    1 +
 include/net/sctp/user.h      |    4 ++-
 net/sctp/associola.c         |    2 +
 net/sctp/protocol.c          |    2 +
 net/sctp/socket.c            |   61 ++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 68 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 5ddb855..bb37724 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -283,7 +283,7 @@ #define SCTP_RTO_ALPHA          3   /* 1
 #define SCTP_RTO_BETA           2   /* 1/4 when converted to right shifts. */
 
 /* Maximum number of new data packets that can be sent in a burst.  */
-#define SCTP_MAX_BURST		4
+#define SCTP_DEFAULT_MAX_BURST		4
 
 #define SCTP_CLOCK_GRANULARITY	1	/* 1 jiffy */
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 6883c7d..e3bcc6c 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -276,6 +276,7 @@ struct sctp_sock {
 	__u32 default_context;
 	__u32 default_timetolive;
 	__u32 default_rcv_context;
+	int max_burst;
 
 	/* Heartbeat interval: The endpoint sends out a Heartbeat chunk to
 	 * the destination address every heartbeat interval. This value
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 36a319e..81d85bc 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -99,8 +99,10 @@ #define SCTP_DELAYED_ACK_TIME SCTP_DELAY
 #define SCTP_CONTEXT SCTP_CONTEXT
 	SCTP_FRAGMENT_INTERLEAVE,
 #define SCTP_FRAGMENT_INTERLEAVE SCTP_FRAGMENT_INTERLEAVE
+	SCTP_MAX_BURST,
+#define SCTP_MAX_BURST SCTP_MAX_BURST
 
-	/* Internal Socket Options. Some of the sctp library functions are 
+	/* Internal Socket Options. Some of the sctp library functions are
 	 * implemented using these socket options.
 	 */
 	SCTP_SOCKOPT_BINDX_ADD = 100,/* BINDX requests for adding addresses. */
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 294be94..2f61d58 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -143,7 +143,7 @@ static struct sctp_association *sctp_ass
 	/* Initialize the maximum mumber of new data packets that can be sent
 	 * in a burst.
 	 */
-	asoc->max_burst = sctp_max_burst;
+	asoc->max_burst = sp->max_burst;
 
 	/* initialize association timers */
 	asoc->timeouts[SCTP_EVENT_TIMEOUT_NONE] = 0;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index e17a823..b9e6fb2 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1044,7 +1044,7 @@ SCTP_STATIC __init int sctp_init(void)
 	sctp_cookie_preserve_enable 	= 1;
 
 	/* Max.Burst		    - 4 */
-	sctp_max_burst 			= SCTP_MAX_BURST;
+	sctp_max_burst 			= SCTP_DEFAULT_MAX_BURST;
 
 	/* Association.Max.Retrans  - 10 attempts
 	 * Path.Max.Retrans         - 5  attempts (per destination address)
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 912073d..ed9872a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2826,6 +2826,36 @@ static int sctp_setsockopt_fragment_inte
 	return 0;
 }
 
+/*
+ * 7.1.28.  Set or Get the maximum burst (SCTP_MAX_BURST)
+ *
+ * This option will allow a user to change the maximum burst of packets
+ * that can be emitted by this association.  Note that the default value
+ * is 4, and some implementations may restrict this setting so that it
+ * can only be lowered.
+ *
+ * NOTE: This text doesn't seem right.  Do this on a socket basis with
+ * future associations inheriting the socket value.
+ */
+static int sctp_setsockopt_maxburst(struct sock *sk,
+				    char __user *optval,
+				    int optlen)
+{
+	int val;
+
+	if (optlen != sizeof(int))
+		return -EINVAL;
+	if (get_user(val, (int __user *)optval))
+		return -EFAULT;
+
+	if (val < 0)
+		return -EINVAL;
+
+	sctp_sk(sk)->max_burst = val;
+
+	return 0;
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -2943,6 +2973,9 @@ SCTP_STATIC int sctp_setsockopt(struct s
 	case SCTP_FRAGMENT_INTERLEAVE:
 		retval = sctp_setsockopt_fragment_interleave(sk, optval, optlen);
 		break;
+	case SCTP_MAX_BURST:
+		retval = sctp_setsockopt_maxburst(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -3102,6 +3135,7 @@ SCTP_STATIC int sctp_init_sock(struct so
 	sp->default_timetolive = 0;
 
 	sp->default_rcv_context = 0;
+	sp->max_burst = sctp_max_burst;
 
 	/* Initialize default setup parameters. These parameters
 	 * can be modified with the SCTP_INITMSG socket option or
@@ -4596,6 +4630,30 @@ static int sctp_getsockopt_fragment_inte
 	return 0;
 }
 
+/*
+ * 7.1.28.  Set or Get the maximum burst (SCTP_MAX_BURST)
+ * (chapter and verse is quoted at sctp_setsockopt_maxburst())
+ */
+static int sctp_getsockopt_maxburst(struct sock *sk, int len,
+				    char __user *optval,
+				    int __user *optlen)
+{
+        int val;
+
+	if (len < sizeof(int))
+		return -EINVAL;
+
+	len = sizeof(int);
+
+	val = sctp_sk(sk)->max_burst;
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
@@ -4712,6 +4770,9 @@ SCTP_STATIC int sctp_getsockopt(struct s
 		retval = sctp_getsockopt_fragment_interleave(sk, len, optval,
 							     optlen);
 		break;
+	case SCTP_MAX_BURST:
+		retval = sctp_getsockopt_maxburst(sk, len, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;


