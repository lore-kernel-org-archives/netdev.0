From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next v2 07/10] sctp: add sockopt to get/set stream scheduler
Date: Tue,  3 Oct 2017 19:20:14 -0300
Message-ID: <090a1bae18ebb608b325f494b41ceb682874ea61.1507069005.git.marcelo.leitner@gmail.com>
References: <cover.1507069005.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Xin Long <lucien.xin@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35691 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbdJCWUr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 18:20:47 -0400
In-Reply-To: <cover.1507069005.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As defined per RFC Draft ndata Section 4.3.2, named as
SCTP_STREAM_SCHEDULER.

See-also: https://tools.ietf.org/html/draft-ietf-tsvwg-sctp-ndata-13
Tested-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/uapi/linux/sctp.h |  1 +
 net/sctp/socket.c         | 75 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 76 insertions(+)

diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 4487e7625ddbd48be1868a8292a807ecd0a314bc..0050f10087d224bad87c8c54ad318003381aee12 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -122,6 +122,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_RESET_ASSOC	120
 #define SCTP_ADD_STREAMS	121
 #define SCTP_SOCKOPT_PEELOFF_FLAGS 122
+#define SCTP_STREAM_SCHEDULER	123
 
 /* PR-SCTP policies */
 #define SCTP_PR_SCTP_NONE	0x0000
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d207734326b085e60625e4333f74221481114892..ae35dbf2810f78c71ce77115ffe4b0e27a672abc 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -79,6 +79,7 @@
 #include <net/sock.h>
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
+#include <net/sctp/stream_sched.h>
 
 /* Forward declarations for internal helper functions. */
 static int sctp_writeable(struct sock *sk);
@@ -3914,6 +3915,36 @@ static int sctp_setsockopt_add_streams(struct sock *sk,
 	return retval;
 }
 
+static int sctp_setsockopt_scheduler(struct sock *sk,
+				     char __user *optval,
+				     unsigned int optlen)
+{
+	struct sctp_association *asoc;
+	struct sctp_assoc_value params;
+	int retval = -EINVAL;
+
+	if (optlen < sizeof(params))
+		goto out;
+
+	optlen = sizeof(params);
+	if (copy_from_user(&params, optval, optlen)) {
+		retval = -EFAULT;
+		goto out;
+	}
+
+	if (params.assoc_value > SCTP_SS_MAX)
+		goto out;
+
+	asoc = sctp_id2assoc(sk, params.assoc_id);
+	if (!asoc)
+		goto out;
+
+	retval = sctp_sched_set_sched(asoc, params.assoc_value);
+
+out:
+	return retval;
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -4095,6 +4126,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_ADD_STREAMS:
 		retval = sctp_setsockopt_add_streams(sk, optval, optlen);
 		break;
+	case SCTP_STREAM_SCHEDULER:
+		retval = sctp_setsockopt_scheduler(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -6793,6 +6827,43 @@ static int sctp_getsockopt_enable_strreset(struct sock *sk, int len,
 	return retval;
 }
 
+static int sctp_getsockopt_scheduler(struct sock *sk, int len,
+				     char __user *optval,
+				     int __user *optlen)
+{
+	struct sctp_assoc_value params;
+	struct sctp_association *asoc;
+	int retval = -EFAULT;
+
+	if (len < sizeof(params)) {
+		retval = -EINVAL;
+		goto out;
+	}
+
+	len = sizeof(params);
+	if (copy_from_user(&params, optval, len))
+		goto out;
+
+	asoc = sctp_id2assoc(sk, params.assoc_id);
+	if (!asoc) {
+		retval = -EINVAL;
+		goto out;
+	}
+
+	params.assoc_value = sctp_sched_get_sched(asoc);
+
+	if (put_user(len, optlen))
+		goto out;
+
+	if (copy_to_user(optval, &params, len))
+		goto out;
+
+	retval = 0;
+
+out:
+	return retval;
+}
+
 static int sctp_getsockopt(struct sock *sk, int level, int optname,
 			   char __user *optval, int __user *optlen)
 {
@@ -6975,6 +7046,10 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_getsockopt_enable_strreset(sk, len, optval,
 							 optlen);
 		break;
+	case SCTP_STREAM_SCHEDULER:
+		retval = sctp_getsockopt_scheduler(sk, len, optval,
+						   optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
2.13.5
