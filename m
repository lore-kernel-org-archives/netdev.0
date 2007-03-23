From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 6/6] [SCTP] Implement SCTP_MAX_BURST socket option.
Date: Fri, 23 Mar 2007 09:52:52 -0400
Message-ID: <11746579733157-git-send-email-vladislav.yasevich@hp.com>
References: <1174657972645-git-send-email-vladislav.yasevich@hp.com>
Cc: sri@us.ibm.com, lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:49621 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422919AbXCWNw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 09:52:59 -0400
In-Reply-To: <1174657972645-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/constants.h |    2 +-
 include/net/sctp/structs.h   |    1 +
 include/net/sctp/user.h      |    2 +
 net/sctp/associola.c         |    2 +-
 net/sctp/protocol.c          |    2 +-
 net/sctp/socket.c            |   61 ++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 67 insertions(+), 3 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 5ddb855..bb37724 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -283,7 +283,7 @@ enum { SCTP_MAX_GABS = 16 };
 #define SCTP_RTO_BETA           2   /* 1/4 when converted to right shifts. */
 
 /* Maximum number of new data packets that can be sent in a burst.  */
-#define SCTP_MAX_BURST		4
+#define SCTP_DEFAULT_MAX_BURST		4
 
 #define SCTP_CLOCK_GRANULARITY	1	/* 1 jiffy */
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index f4bb396..8135815 100644
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
index 1b3153c..6d2b577 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -101,6 +101,8 @@ enum sctp_optname {
 #define SCTP_FRAGMENT_INTERLEAVE SCTP_FRAGMENT_INTERLEAVE
 	SCTP_PARTIAL_DELIVERY_POINT,	/* Set/Get partial delivery point */
 #define SCTP_PARTIAL_DELIVERY_POINT SCTP_PARTIAL_DELIVERY_POINT
+	SCTP_MAX_BURST,		/* Set/Get max burst */
+#define SCTP_MAX_BURST SCTP_MAX_BURST
 
 	/* Internal Socket Options. Some of the sctp library functions are 
 	 * implemented using these socket options.
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 294be94..2f61d58 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -143,7 +143,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	/* Initialize the maximum mumber of new data packets that can be sent
 	 * in a burst.
 	 */
-	asoc->max_burst = sctp_max_burst;
+	asoc->max_burst = sp->max_burst;
 
 	/* initialize association timers */
 	asoc->timeouts[SCTP_EVENT_TIMEOUT_NONE] = 0;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 7c28c9b..c361deb 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1042,7 +1042,7 @@ SCTP_STATIC __init int sctp_init(void)
 	sctp_cookie_preserve_enable 	= 1;
 
 	/* Max.Burst		    - 4 */
-	sctp_max_burst 			= SCTP_MAX_BURST;
+	sctp_max_burst 			= SCTP_DEFAULT_MAX_BURST;
 
 	/* Association.Max.Retrans  - 10 attempts
 	 * Path.Max.Retrans         - 5  attempts (per destination address)
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 8939536..e45cff4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2886,6 +2886,36 @@ static int sctp_setsockopt_partial_delivery_point(struct sock *sk,
 	return 0; /* is this the right error code? */
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
@@ -3006,6 +3036,9 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_FRAGMENT_INTERLEAVE:
 		retval = sctp_setsockopt_fragment_interleave(sk, optval, optlen);
 		break;
+	case SCTP_MAX_BURST:
+		retval = sctp_setsockopt_maxburst(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -3165,6 +3198,7 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 	sp->default_timetolive = 0;
 
 	sp->default_rcv_context = 0;
+	sp->max_burst = sctp_max_burst;
 
 	/* Initialize default setup parameters. These parameters
 	 * can be modified with the SCTP_INITMSG socket option or
@@ -4683,6 +4717,30 @@ static int sctp_getsockopt_partial_delivery_point(struct sock *sk, int len,
 	return -ENOTSUPP;
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
@@ -4803,6 +4861,9 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_getsockopt_partial_delivery_point(sk, len, optval,
 								optlen);
 		break;
+	case SCTP_MAX_BURST:
+		retval = sctp_getsockopt_maxburst(sk, len, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
1.5.0.3.438.gc49b2

