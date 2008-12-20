From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 3/5] sctp: Implement socket option SCTP_GET_ASSOC_NUMBER
Date: Fri, 19 Dec 2008 20:47:50 -0500
Message-ID: <1229737672-28328-5-git-send-email-vladislav.yasevich@hp.com>
References: <1229737672-28328-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:42275 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752971AbYLTBr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 20:47:57 -0500
In-Reply-To: <1229737672-28328-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

Implement socket option SCTP_GET_ASSOC_NUMBER of the latest ietf socket
extensions API draft.

  8.2.5.  Get the Current Number of Associations (SCTP_GET_ASSOC_NUMBER)

   This option gets the current number of associations that are attached
   to a one-to-many style socket.  The option value is an uint32_t.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/user.h |    2 ++
 net/sctp/socket.c       |   35 +++++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index f205b10..b259fc5 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -118,6 +118,8 @@ enum sctp_optname {
 #define SCTP_PEER_AUTH_CHUNKS SCTP_PEER_AUTH_CHUNKS
 	SCTP_LOCAL_AUTH_CHUNKS,		/* Read only */
 #define SCTP_LOCAL_AUTH_CHUNKS SCTP_LOCAL_AUTH_CHUNKS
+	SCTP_GET_ASSOC_NUMBER,		/* Read only */
+#define SCTP_GET_ASSOC_NUMBER SCTP_GET_ASSOC_NUMBER
 
 
 	/* Internal Socket Options. Some of the sctp library functions are 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e432927..9f5fe23 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5460,6 +5460,38 @@ num:
 	return 0;
 }
 
+/*
+ * 8.2.5.  Get the Current Number of Associations (SCTP_GET_ASSOC_NUMBER)
+ * This option gets the current number of associations that are attached
+ * to a one-to-many style socket.  The option value is an uint32_t.
+ */
+static int sctp_getsockopt_assoc_number(struct sock *sk, int len,
+				    char __user *optval, int __user *optlen)
+{
+	struct sctp_sock *sp = sctp_sk(sk);
+	struct sctp_association *asoc;
+	u32 val = 0;
+
+	if (sctp_style(sk, TCP))
+		return -EOPNOTSUPP;
+
+	if (len < sizeof(u32))
+		return -EINVAL;
+
+	len = sizeof(u32);
+
+	list_for_each_entry(asoc, &(sp->ep->asocs), asocs) {
+		val++;
+	}
+
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(optval, &val, len))
+		return -EFAULT;
+
+	return 0;
+}
+
 SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 				char __user *optval, int __user *optlen)
 {
@@ -5602,6 +5634,9 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_getsockopt_local_auth_chunks(sk, len, optval,
 							optlen);
 		break;
+	case SCTP_GET_ASSOC_NUMBER:
+		retval = sctp_getsockopt_assoc_number(sk, len, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
1.5.3.5

