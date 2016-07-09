From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 2/6] sctp: add SCTP_DEFAULT_PRINFO into sctp sockopt
Date: Sat,  9 Jul 2016 19:47:41 +0800
Message-ID: <2b9ceacb55912e29c2d970772d0267e465c33dff.1468064737.git.lucien.xin@gmail.com>
References: <cover.1468064737.git.lucien.xin@gmail.com>
 <121aa41aceff56b3dda51c41b8f3c4d8662d65b7.1468064737.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33136 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbcGILsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 07:48:02 -0400
In-Reply-To: <121aa41aceff56b3dda51c41b8f3c4d8662d65b7.1468064737.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1468064737.git.lucien.xin@gmail.com>
References: <cover.1468064737.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds SCTP_DEFAULT_PRINFO to sctp sockopt. It is used
to set/get sctp Partially Reliable Policies' default params,
which includes 3 policies (ttl, rtx, prio) and their values.

Still, if we set policy params in sndinfo, we will use the params
of sndinfo against chunks, instead of the default params.

In this patch, we will use 5-8bit of sp/asoc->default_flags
to store prsctp policies, and reuse asoc->default_timetolive
to store their values. It means if we enable and set prsctp
policy, prior ttl timeout in sctp will not work any more.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/uapi/linux/sctp.h | 29 +++++++++++++++
 net/sctp/socket.c         | 91 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 120 insertions(+)

diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index aa08906..984cf2e 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -113,6 +113,29 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_SOCKOPT_CONNECTX3	111	/* CONNECTX requests (updated) */
 #define SCTP_GET_ASSOC_STATS	112	/* Read only */
 #define SCTP_PR_SUPPORTED	113
+#define SCTP_DEFAULT_PRINFO	114
+
+/* PR-SCTP policies */
+#define SCTP_PR_SCTP_NONE	0x0000
+#define SCTP_PR_SCTP_TTL	0x0010
+#define SCTP_PR_SCTP_RTX	0x0020
+#define SCTP_PR_SCTP_PRIO	0x0030
+#define SCTP_PR_SCTP_MAX	SCTP_PR_SCTP_PRIO
+#define SCTP_PR_SCTP_MASK	0x0030
+
+#define __SCTP_PR_INDEX(x)	((x >> 4) - 1)
+#define SCTP_PR_INDEX(x)	__SCTP_PR_INDEX(SCTP_PR_SCTP_ ## x)
+
+#define SCTP_PR_POLICY(x)	((x) & SCTP_PR_SCTP_MASK)
+#define SCTP_PR_SET_POLICY(flags, x)	\
+	do {				\
+		flags &= ~SCTP_PR_SCTP_MASK;	\
+		flags |= x;		\
+	} while (0)
+
+#define SCTP_PR_TTL_ENABLED(x)	(SCTP_PR_POLICY(x) == SCTP_PR_SCTP_TTL)
+#define SCTP_PR_RTX_ENABLED(x)	(SCTP_PR_POLICY(x) == SCTP_PR_SCTP_RTX)
+#define SCTP_PR_PRIO_ENABLED(x)	(SCTP_PR_POLICY(x) == SCTP_PR_SCTP_PRIO)
 
 /* These are bit fields for msghdr->msg_flags.  See section 5.1.  */
 /* On user space Linux, these live in <bits/socket.h> as an enum.  */
@@ -903,4 +926,10 @@ struct sctp_paddrthlds {
 	__u16 spt_pathpfthld;
 };
 
+struct sctp_default_prinfo {
+	sctp_assoc_t pr_assoc_id;
+	__u32 pr_value;
+	__u16 pr_policy;
+};
+
 #endif /* _UAPI_SCTP_H */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 7460dde..c03fe1b 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3694,6 +3694,47 @@ out:
 	return retval;
 }
 
+static int sctp_setsockopt_default_prinfo(struct sock *sk,
+					  char __user *optval,
+					  unsigned int optlen)
+{
+	struct sctp_default_prinfo info;
+	struct sctp_association *asoc;
+	int retval = -EINVAL;
+
+	if (optlen != sizeof(info))
+		goto out;
+
+	if (copy_from_user(&info, optval, sizeof(info))) {
+		retval = -EFAULT;
+		goto out;
+	}
+
+	if (info.pr_policy & ~SCTP_PR_SCTP_MASK)
+		goto out;
+
+	if (info.pr_policy == SCTP_PR_SCTP_NONE)
+		info.pr_value = 0;
+
+	asoc = sctp_id2assoc(sk, info.pr_assoc_id);
+	if (asoc) {
+		SCTP_PR_SET_POLICY(asoc->default_flags, info.pr_policy);
+		asoc->default_timetolive = info.pr_value;
+	} else if (!info.pr_assoc_id) {
+		struct sctp_sock *sp = sctp_sk(sk);
+
+		SCTP_PR_SET_POLICY(sp->default_flags, info.pr_policy);
+		sp->default_timetolive = info.pr_value;
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
@@ -3857,6 +3898,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_PR_SUPPORTED:
 		retval = sctp_setsockopt_pr_supported(sk, optval, optlen);
 		break;
+	case SCTP_DEFAULT_PRINFO:
+		retval = sctp_setsockopt_default_prinfo(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -6243,6 +6287,49 @@ out:
 	return retval;
 }
 
+static int sctp_getsockopt_default_prinfo(struct sock *sk, int len,
+					  char __user *optval,
+					  int __user *optlen)
+{
+	struct sctp_default_prinfo info;
+	struct sctp_association *asoc;
+	int retval = -EFAULT;
+
+	if (len < sizeof(info)) {
+		retval = -EINVAL;
+		goto out;
+	}
+
+	len = sizeof(info);
+	if (copy_from_user(&info, optval, len))
+		goto out;
+
+	asoc = sctp_id2assoc(sk, info.pr_assoc_id);
+	if (asoc) {
+		info.pr_policy = SCTP_PR_POLICY(asoc->default_flags);
+		info.pr_value = asoc->default_timetolive;
+	} else if (!info.pr_assoc_id) {
+		struct sctp_sock *sp = sctp_sk(sk);
+
+		info.pr_policy = SCTP_PR_POLICY(sp->default_flags);
+		info.pr_value = sp->default_timetolive;
+	} else {
+		retval = -EINVAL;
+		goto out;
+	}
+
+	if (put_user(len, optlen))
+		goto out;
+
+	if (copy_to_user(optval, &info, len))
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
@@ -6399,6 +6486,10 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_PR_SUPPORTED:
 		retval = sctp_getsockopt_pr_supported(sk, len, optval, optlen);
 		break;
+	case SCTP_DEFAULT_PRINFO:
+		retval = sctp_getsockopt_default_prinfo(sk, len, optval,
+							optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
2.1.0
