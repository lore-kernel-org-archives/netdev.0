From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 13/27] sctp: add rfc6525 section 6.3.1
Date: Sun,  1 Jan 2017 19:20:30 +0800
Message-ID: <d5fb0969ea5d055dea5bdc257569530b6d2fc7c2.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
 <684ad8ddd79f23844883dede4c34360ce744dfc3.1483269426.git.lucien.xin@gmail.com>
 <c752879a5af358c08da949b391416452f1322c43.1483269426.git.lucien.xin@gmail.com>
 <be8a2770ddc2381266050c9f168add9802b90a49.1483269426.git.lucien.xin@gmail.com>
 <fc046afdda34c9b262ce57400c4256b14fd1a0fb.1483269426.git.lucien.xin@gmail.com>
 <d4f1b2a4fa19457e9867b0a1f84764a7a509459a.1483269426.git.lucien.xin@gmail.com>
 <31abc54d31ef0714322f137bff43458014d7c276.1483269426.git.lucien.xin@gmail.com>
 <58860816816d6d51b062235fd54dae6540a4797a.1483269426.git.lucien.xin@gmail.com>
 <229608faf7af54c0bf908694ca8349205bbf6eab.1483269426.git.lucien.xin@gmail.com>
 <c4f16844620cd3a2aa76596df9eaadf1505fc8e6.1483269426.git.lucien.xin@gmail.com>
 <1d0b270084289945c4b42ae36d0556648a3f9b64.1483269426.git.lucien.xin@gmail.com>
 <1e4560205cff3c10868d5614b62a3db14e87ccf0.1483269426.git.lucien.xin@gmail.com>
 <91b9171cc57c0f322d103dfbbcce1b9706800805.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33332 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932079AbdAALWh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:22:37 -0500
In-Reply-To: <91b9171cc57c0f322d103dfbbcce1b9706800805.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add sockopt SCTP_ENABLE_STREAM_RESET to set
strreset_enable to indicate which reconf request type it supports,
which is described in section 6.3.1.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  4 +++
 include/uapi/linux/sctp.h  |  7 ++++
 net/sctp/associola.c       |  1 +
 net/sctp/socket.c          | 84 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 96 insertions(+)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 7c46398..56282a3 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1253,6 +1253,8 @@ struct sctp_endpoint {
 	__u8  auth_enable:1,
 	      prsctp_enable:1,
 	      reconf_enable:1;
+
+	__u8  strreset_enable;
 };
 
 /* Recover the outter endpoint structure. */
@@ -1858,6 +1860,8 @@ struct sctp_association {
 	     prsctp_enable:1,
 	     reconf_enable:1;
 
+	__u8 strreset_enable;
+
 	/* stream arrays */
 	struct sctp_stream_out *streamout;
 	struct sctp_stream_in *streamin;
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 4d3b621..950d76a 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -116,6 +116,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_DEFAULT_PRINFO	114
 #define SCTP_PR_ASSOC_STATUS	115
 #define SCTP_RECONFIG_SUPPORTED	117
+#define SCTP_ENABLE_STREAM_RESET	118
 
 /* PR-SCTP policies */
 #define SCTP_PR_SCTP_NONE	0x0000
@@ -139,6 +140,12 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_PR_RTX_ENABLED(x)	(SCTP_PR_POLICY(x) == SCTP_PR_SCTP_RTX)
 #define SCTP_PR_PRIO_ENABLED(x)	(SCTP_PR_POLICY(x) == SCTP_PR_SCTP_PRIO)
 
+/* For enable stream reset */
+#define SCTP_ENABLE_RESET_STREAM_REQ	0x01
+#define SCTP_ENABLE_RESET_ASSOC_REQ	0x02
+#define SCTP_ENABLE_CHANGE_ASSOC_REQ	0x04
+#define SCTP_ENABLE_STRRESET_MASK	0x07
+
 /* These are bit fields for msghdr->msg_flags.  See section 5.1.  */
 /* On user space Linux, these live in <bits/socket.h> as an enum.  */
 enum sctp_msg_flags {
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index ab43cb6..44b8690 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -271,6 +271,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->active_key_id = ep->active_key_id;
 	asoc->prsctp_enable = ep->prsctp_enable;
 	asoc->reconf_enable = ep->reconf_enable;
+	asoc->strreset_enable = ep->strreset_enable;
 
 	/* Save the hmacs and chunks list into this association */
 	if (ep->auth_hmacs_list)
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e946bc2..3cae585 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3784,6 +3784,42 @@ static int sctp_setsockopt_reconfig_supported(struct sock *sk,
 	return retval;
 }
 
+static int sctp_setsockopt_enable_strreset(struct sock *sk,
+					   char __user *optval,
+					   unsigned int optlen)
+{
+	struct sctp_assoc_value params;
+	struct sctp_association *asoc;
+	int retval = -EINVAL;
+
+	if (optlen != sizeof(params))
+		goto out;
+
+	if (copy_from_user(&params, optval, optlen)) {
+		retval = -EFAULT;
+		goto out;
+	}
+
+	if (params.assoc_value & (~SCTP_ENABLE_STRRESET_MASK))
+		goto out;
+
+	asoc = sctp_id2assoc(sk, params.assoc_id);
+	if (asoc) {
+		asoc->strreset_enable = params.assoc_value;
+	} else if (!params.assoc_id) {
+		struct sctp_sock *sp = sctp_sk(sk);
+
+		sp->ep->strreset_enable = params.assoc_value;
+	} else {
+		goto out;
+	}
+
+	retval = 0;
+
+out:
+	return retval;
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -3953,6 +3989,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_RECONFIG_SUPPORTED:
 		retval = sctp_setsockopt_reconfig_supported(sk, optval, optlen);
 		break;
+	case SCTP_ENABLE_STREAM_RESET:
+		retval = sctp_setsockopt_enable_strreset(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -6478,6 +6517,47 @@ static int sctp_getsockopt_reconfig_supported(struct sock *sk, int len,
 	return retval;
 }
 
+static int sctp_getsockopt_enable_strreset(struct sock *sk, int len,
+					   char __user *optval,
+					   int __user *optlen)
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
+	if (asoc) {
+		params.assoc_value = asoc->strreset_enable;
+	} else if (!params.assoc_id) {
+		struct sctp_sock *sp = sctp_sk(sk);
+
+		params.assoc_value = sp->ep->strreset_enable;
+	} else {
+		retval = -EINVAL;
+		goto out;
+	}
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
@@ -6649,6 +6729,10 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_getsockopt_reconfig_supported(sk, len, optval,
 							    optlen);
 		break;
+	case SCTP_ENABLE_STREAM_RESET:
+		retval = sctp_getsockopt_enable_strreset(sk, len, optval,
+							 optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
2.1.0
