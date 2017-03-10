From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 7/7] sctp: add get and set sockopt for reconf_enable
Date: Fri, 10 Mar 2017 12:11:12 +0800
Message-ID: <17238dd523ccf03a8bee5c51b90bc2a93789d437.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
 <7bf94990cf77044e0286adc2f393af4c9010213c.1489118815.git.lucien.xin@gmail.com>
 <f224235b4621ea3a182e959873f6fe0ba78e5416.1489118815.git.lucien.xin@gmail.com>
 <70b0da1e9de612702d0ddcdeab67e56b6d11fd78.1489118815.git.lucien.xin@gmail.com>
 <f73e5ede81d0eeccdf955eb7d77eadcda5166c9e.1489118815.git.lucien.xin@gmail.com>
 <7def0879be34d7e8a8bc1f11cc62ae8570bfcf26.1489118815.git.lucien.xin@gmail.com>
 <6be290927b01181a7dc18ebef5c0a0f5de62fd82.1489118815.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34172 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754502AbdCJEMT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 23:12:19 -0500
In-Reply-To: <6be290927b01181a7dc18ebef5c0a0f5de62fd82.1489118815.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is to add SCTP_RECONFIG_SUPPORTED sockopt, it would
set and get asoc reconf_enable value when asoc_id is set, or it
would set and get ep reconf_enalbe value if asoc_id is 0.

It is also to add sysctl interface for users to set the default
value for reconf_enable.

After this patch, stream reconf will work.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/uapi/linux/sctp.h |  1 +
 net/sctp/socket.c         | 81 +++++++++++++++++++++++++++++++++++++++++++++++
 net/sctp/sysctl.c         |  7 ++++
 3 files changed, 89 insertions(+)

diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index fd652e6..7212870 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -115,6 +115,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_PR_SUPPORTED	113
 #define SCTP_DEFAULT_PRINFO	114
 #define SCTP_PR_ASSOC_STATUS	115
+#define SCTP_RECONFIG_SUPPORTED	117
 #define SCTP_ENABLE_STREAM_RESET	118
 #define SCTP_RESET_STREAMS	119
 #define SCTP_RESET_ASSOC	120
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 6f0a9be..24e28cf 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3758,6 +3758,39 @@ static int sctp_setsockopt_default_prinfo(struct sock *sk,
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
 static int sctp_setsockopt_enable_strreset(struct sock *sk,
 					   char __user *optval,
 					   unsigned int optlen)
@@ -4038,6 +4071,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_DEFAULT_PRINFO:
 		retval = sctp_setsockopt_default_prinfo(sk, optval, optlen);
 		break;
+	case SCTP_RECONFIG_SUPPORTED:
+		retval = sctp_setsockopt_reconfig_supported(sk, optval, optlen);
+		break;
 	case SCTP_ENABLE_STREAM_RESET:
 		retval = sctp_setsockopt_enable_strreset(sk, optval, optlen);
 		break;
@@ -6540,6 +6576,47 @@ static int sctp_getsockopt_pr_assocstatus(struct sock *sk, int len,
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
 static int sctp_getsockopt_enable_strreset(struct sock *sk, int len,
 					   char __user *optval,
 					   int __user *optlen)
@@ -6748,6 +6825,10 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_getsockopt_pr_assocstatus(sk, len, optval,
 							optlen);
 		break;
+	case SCTP_RECONFIG_SUPPORTED:
+		retval = sctp_getsockopt_reconfig_supported(sk, len, optval,
+							    optlen);
+		break;
 	case SCTP_ENABLE_STREAM_RESET:
 		retval = sctp_getsockopt_enable_strreset(sk, len, optval,
 							 optlen);
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index daf8554..0e732f6 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -275,6 +275,13 @@ static struct ctl_table sctp_net_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "reconf_enable",
+		.data		= &init_net.sctp.reconf_enable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "auth_enable",
 		.data		= &init_net.sctp.auth_enable,
 		.maxlen		= sizeof(int),
-- 
2.1.0
