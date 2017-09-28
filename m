From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 08/10] sctp: add sockopt to get/set stream scheduler parameters
Date: Thu, 28 Sep 2017 17:25:21 -0300
Message-ID: <3fb07e1fbc36620c1ed3820fda34a3e5ce1856c2.1506536044.git.marcelo.leitner@gmail.com>
References: <cover.1506536044.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Xin Long <lucien.xin@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:50185 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751805AbdI1UZz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 16:25:55 -0400
In-Reply-To: <cover.1506536044.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As defined per RFC Draft ndata Section 4.3.3, named as
SCTP_STREAM_SCHEDULER_VALUE.

See-also: https://tools.ietf.org/html/draft-ietf-tsvwg-sctp-ndata-13
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/uapi/linux/sctp.h |  7 +++++
 net/sctp/socket.c         | 77 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 84 insertions(+)

diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 0050f10087d224bad87c8c54ad318003381aee12..00ac417d2c4f8468ea2aad32e59806be5c5aa08d 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -123,6 +123,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_ADD_STREAMS	121
 #define SCTP_SOCKOPT_PEELOFF_FLAGS 122
 #define SCTP_STREAM_SCHEDULER	123
+#define SCTP_STREAM_SCHEDULER_VALUE	124
 
 /* PR-SCTP policies */
 #define SCTP_PR_SCTP_NONE	0x0000
@@ -815,6 +816,12 @@ struct sctp_assoc_value {
     uint32_t                assoc_value;
 };
 
+struct sctp_stream_value {
+	sctp_assoc_t assoc_id;
+	uint16_t stream_id;
+	uint16_t stream_value;
+};
+
 /*
  * 7.2.2 Peer Address Information
  *
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ae35dbf2810f78c71ce77115ffe4b0e27a672abc..88c28421ec151e83665efcbcbd8a6403b122205a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3945,6 +3945,34 @@ static int sctp_setsockopt_scheduler(struct sock *sk,
 	return retval;
 }
 
+static int sctp_setsockopt_scheduler_value(struct sock *sk,
+					   char __user *optval,
+					   unsigned int optlen)
+{
+	struct sctp_association *asoc;
+	struct sctp_stream_value params;
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
+	asoc = sctp_id2assoc(sk, params.assoc_id);
+	if (!asoc)
+		goto out;
+
+	retval = sctp_sched_set_value(asoc, params.stream_id,
+				      params.stream_value, GFP_KERNEL);
+
+out:
+	return retval;
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -4129,6 +4157,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_STREAM_SCHEDULER:
 		retval = sctp_setsockopt_scheduler(sk, optval, optlen);
 		break;
+	case SCTP_STREAM_SCHEDULER_VALUE:
+		retval = sctp_setsockopt_scheduler_value(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -6864,6 +6895,48 @@ static int sctp_getsockopt_scheduler(struct sock *sk, int len,
 	return retval;
 }
 
+static int sctp_getsockopt_scheduler_value(struct sock *sk, int len,
+					   char __user *optval,
+					   int __user *optlen)
+{
+	struct sctp_stream_value params;
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
+	retval = sctp_sched_get_value(asoc, params.stream_id,
+				      &params.stream_value);
+	if (retval)
+		goto out;
+
+	if (put_user(len, optlen)) {
+		retval = -EFAULT;
+		goto out;
+	}
+
+	if (copy_to_user(optval, &params, len)) {
+		retval = -EFAULT;
+		goto out;
+	}
+
+out:
+	return retval;
+}
+
 static int sctp_getsockopt(struct sock *sk, int level, int optname,
 			   char __user *optval, int __user *optlen)
 {
@@ -7050,6 +7123,10 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_getsockopt_scheduler(sk, len, optval,
 						   optlen);
 		break;
+	case SCTP_STREAM_SCHEDULER_VALUE:
+		retval = sctp_getsockopt_scheduler_value(sk, len, optval,
+							 optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
2.13.5
