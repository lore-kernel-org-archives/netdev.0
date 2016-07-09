From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 3/6] sctp: add SCTP_PR_ASSOC_STATUS on sctp sockopt
Date: Sat,  9 Jul 2016 19:47:42 +0800
Message-ID: <63a9a850836134ba72b9377e8b99694d869e3fba.1468064737.git.lucien.xin@gmail.com>
References: <cover.1468064737.git.lucien.xin@gmail.com>
 <121aa41aceff56b3dda51c41b8f3c4d8662d65b7.1468064737.git.lucien.xin@gmail.com>
 <2b9ceacb55912e29c2d970772d0267e465c33dff.1468064737.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33148 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754AbcGILsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 07:48:06 -0400
In-Reply-To: <2b9ceacb55912e29c2d970772d0267e465c33dff.1468064737.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1468064737.git.lucien.xin@gmail.com>
References: <cover.1468064737.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds SCTP_PR_ASSOC_STATUS to sctp sockopt, which is used
to dump the prsctp statistics info from the asoc. The prsctp statistics
includes abandoned_sent/unsent from the asoc. abandoned_sent is the
count of the packets we drop packets from retransmit/transmited queue,
and abandoned_unsent is the count of the packets we drop from out_queue
according to the policy.

Note: another option for prsctp statistics dump described in rfc is
SCTP_PR_STREAM_STATUS, which is used to dump the prsctp statistics
info from each stream. But by now, linux doesn't yet have per stream
statistics info, it needs rfc6525 to be implemented. As the prsctp
statistics for each stream has to be based on per stream statistics,
we will delay it until rfc6525 is done in linux.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  3 +++
 include/uapi/linux/sctp.h  | 12 +++++++++
 net/sctp/socket.c          | 62 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 77 insertions(+)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 07115ca..d8e464a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1853,6 +1853,9 @@ struct sctp_association {
 	     prsctp_enable:1;
 
 	struct sctp_priv_assoc_stats stats;
+
+	__u64 abandoned_unsent[SCTP_PR_INDEX(MAX) + 1];
+	__u64 abandoned_sent[SCTP_PR_INDEX(MAX) + 1];
 };
 
 
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 984cf2e..d304f4c 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -114,6 +114,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_GET_ASSOC_STATS	112	/* Read only */
 #define SCTP_PR_SUPPORTED	113
 #define SCTP_DEFAULT_PRINFO	114
+#define SCTP_PR_ASSOC_STATUS	115
 
 /* PR-SCTP policies */
 #define SCTP_PR_SCTP_NONE	0x0000
@@ -926,6 +927,17 @@ struct sctp_paddrthlds {
 	__u16 spt_pathpfthld;
 };
 
+/*
+ * Socket Option for Getting the Association/Stream-Specific PR-SCTP Status
+ */
+struct sctp_prstatus {
+	sctp_assoc_t sprstat_assoc_id;
+	__u16 sprstat_sid;
+	__u16 sprstat_policy;
+	__u64 sprstat_abandoned_unsent;
+	__u64 sprstat_abandoned_sent;
+};
+
 struct sctp_default_prinfo {
 	sctp_assoc_t pr_assoc_id;
 	__u32 pr_value;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index c03fe1b..c3167c4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6330,6 +6330,64 @@ out:
 	return retval;
 }
 
+static int sctp_getsockopt_pr_assocstatus(struct sock *sk, int len,
+					  char __user *optval,
+					  int __user *optlen)
+{
+	struct sctp_prstatus params;
+	struct sctp_association *asoc;
+	int policy;
+	int retval = -EINVAL;
+
+	if (len < sizeof(params))
+		goto out;
+
+	len = sizeof(params);
+	if (copy_from_user(&params, optval, len)) {
+		retval = -EFAULT;
+		goto out;
+	}
+
+	policy = params.sprstat_policy;
+	if (policy & ~SCTP_PR_SCTP_MASK)
+		goto out;
+
+	asoc = sctp_id2assoc(sk, params.sprstat_assoc_id);
+	if (!asoc)
+		goto out;
+
+	if (policy == SCTP_PR_SCTP_NONE) {
+		params.sprstat_abandoned_unsent = 0;
+		params.sprstat_abandoned_sent = 0;
+		for (policy = 0; policy <= SCTP_PR_INDEX(MAX); policy++) {
+			params.sprstat_abandoned_unsent +=
+				asoc->abandoned_unsent[policy];
+			params.sprstat_abandoned_sent +=
+				asoc->abandoned_sent[policy];
+		}
+	} else {
+		params.sprstat_abandoned_unsent =
+			asoc->abandoned_unsent[__SCTP_PR_INDEX(policy)];
+		params.sprstat_abandoned_sent =
+			asoc->abandoned_sent[__SCTP_PR_INDEX(policy)];
+	}
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
+	retval = 0;
+
+out:
+	return retval;
+}
+
 static int sctp_getsockopt(struct sock *sk, int level, int optname,
 			   char __user *optval, int __user *optlen)
 {
@@ -6490,6 +6548,10 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_getsockopt_default_prinfo(sk, len, optval,
 							optlen);
 		break;
+	case SCTP_PR_ASSOC_STATUS:
+		retval = sctp_getsockopt_pr_assocstatus(sk, len, optval,
+							optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
2.1.0
