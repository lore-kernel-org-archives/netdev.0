From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv4 net-next 5/6] sctp: add sockopt SCTP_ENABLE_STREAM_RESET
Date: Wed, 18 Jan 2017 00:44:46 +0800
Message-ID: <21082127c66a2576338a860a092231ae3c5cd94a.1484670664.git.lucien.xin@gmail.com>
References: <cover.1484670664.git.lucien.xin@gmail.com>
 <eff824eb34c55a83e35334597e6d510a5dde3ce6.1484670664.git.lucien.xin@gmail.com>
 <1a1ff083ca37b6de6bacf038ae5d0367f0112edd.1484670664.git.lucien.xin@gmail.com>
 <9c7e8c3427aa17874b192a06175800c333a54438.1484670664.git.lucien.xin@gmail.com>
 <d016227bd6d957ee304bb9a7454a7e378801c6cf.1484670664.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34203 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdAQQpi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 11:45:38 -0500
In-Reply-To: <d016227bd6d957ee304bb9a7454a7e378801c6cf.1484670664.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1484670664.git.lucien.xin@gmail.com>
References: <cover.1484670664.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add sockopt SCTP_ENABLE_STREAM_RESET to get/set
strreset_enable to indicate which reconf request type it supports,
which is described in rfc6525 section 6.3.1.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  4 +++
 include/uapi/linux/sctp.h  |  7 ++++
 net/sctp/associola.c       |  1 +
 net/sctp/socket.c          | 84 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 96 insertions(+)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index ee037ef..d99b76e 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1257,6 +1257,8 @@ struct sctp_endpoint {
 	__u8  auth_enable:1,
 	      prsctp_enable:1,
 	      reconf_enable:1;
+
+	__u8  strreset_enable;
 };
 
 /* Recover the outter endpoint structure. */
@@ -1872,6 +1874,8 @@ struct sctp_association {
 	     prsctp_enable:1,
 	     reconf_enable:1;
 
+	__u8 strreset_enable;
+
 	__u32 strreset_outseq; /* Update after receiving response */
 	__u32 strreset_inseq; /* Update after receiving request */
 
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index a406adc..867be0f 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -115,6 +115,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_PR_SUPPORTED	113
 #define SCTP_DEFAULT_PRINFO	114
 #define SCTP_PR_ASSOC_STATUS	115
+#define SCTP_ENABLE_STREAM_RESET	118
 
 /* PR-SCTP policies */
 #define SCTP_PR_SCTP_NONE	0x0000
@@ -138,6 +139,12 @@ typedef __s32 sctp_assoc_t;
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
index 68b99ad..e50dc6d 100644
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
index 318c678..ae07db4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3751,6 +3751,42 @@ static int sctp_setsockopt_default_prinfo(struct sock *sk,
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
@@ -3917,6 +3953,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_DEFAULT_PRINFO:
 		retval = sctp_setsockopt_default_prinfo(sk, optval, optlen);
 		break;
+	case SCTP_ENABLE_STREAM_RESET:
+		retval = sctp_setsockopt_enable_strreset(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -6401,6 +6440,47 @@ static int sctp_getsockopt_pr_assocstatus(struct sock *sk, int len,
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
@@ -6568,6 +6648,10 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_getsockopt_pr_assocstatus(sk, len, optval,
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
