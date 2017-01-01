From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 12/27] sctp: add get and set sockopt for reconf_enable
Date: Sun,  1 Jan 2017 19:20:29 +0800
Message-ID: <91b9171cc57c0f322d103dfbbcce1b9706800805.1483269426.git.lucien.xin@gmail.com>
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
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34679 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932079AbdAALW2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:22:28 -0500
In-Reply-To: <1e4560205cff3c10868d5614b62a3db14e87ccf0.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is to add SCTP_RECONFIG_SUPPORTED sockopt, it would
set and get asoc reconf_enable value when asoc_id is set, or it
would set and get ep reconf_enalbe value if asoc_id is 0.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/uapi/linux/sctp.h |  1 +
 net/sctp/socket.c         | 81 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 82 insertions(+)

diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index a406adc..4d3b621 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -115,6 +115,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_PR_SUPPORTED	113
 #define SCTP_DEFAULT_PRINFO	114
 #define SCTP_PR_ASSOC_STATUS	115
+#define SCTP_RECONFIG_SUPPORTED	117
 
 /* PR-SCTP policies */
 #define SCTP_PR_SCTP_NONE	0x0000
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 318c678..e946bc2 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3751,6 +3751,39 @@ static int sctp_setsockopt_default_prinfo(struct sock *sk,
 	return retval;
 }
 
+static int sctp_setsockopt_reconfig_supported(struct sock *sk,
+					      char __user *optval,
+					      unsigned int optlen)
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
+	asoc = sctp_id2assoc(sk, params.assoc_id);
+	if (asoc) {
+		asoc->reconf_enable = !!params.assoc_value;
+	} else if (!params.assoc_id) {
+		struct sctp_sock *sp = sctp_sk(sk);
+
+		sp->ep->reconf_enable = !!params.assoc_value;
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
@@ -3917,6 +3950,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_DEFAULT_PRINFO:
 		retval = sctp_setsockopt_default_prinfo(sk, optval, optlen);
 		break;
+	case SCTP_RECONFIG_SUPPORTED:
+		retval = sctp_setsockopt_reconfig_supported(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -6401,6 +6437,47 @@ static int sctp_getsockopt_pr_assocstatus(struct sock *sk, int len,
 	return retval;
 }
 
+static int sctp_getsockopt_reconfig_supported(struct sock *sk, int len,
+					      char __user *optval,
+					      int __user *optlen)
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
+		params.assoc_value = asoc->reconf_enable;
+	} else if (!params.assoc_id) {
+		struct sctp_sock *sp = sctp_sk(sk);
+
+		params.assoc_value = sp->ep->reconf_enable;
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
@@ -6568,6 +6645,10 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_getsockopt_pr_assocstatus(sk, len, optval,
 							optlen);
 		break;
+	case SCTP_RECONFIG_SUPPORTED:
+		retval = sctp_getsockopt_reconfig_supported(sk, len, optval,
+							    optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
2.1.0
