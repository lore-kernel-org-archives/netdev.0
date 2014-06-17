From: Geir Ola Vaagland <geirola@gmail.com>
Subject: [PATCH net-next 4/6] Support for SCTP_NXTINFO socket option
Date: Tue, 17 Jun 2014 17:01:34 +0200
Message-ID: <1403017296-28469-5-git-send-email-geirola@gmail.com>
References: <1403017296-28469-1-git-send-email-geirola@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:62894 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933047AbaFQPBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 11:01:47 -0400
In-Reply-To: <1403017296-28469-1-git-send-email-geirola@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Geir Ola Vaagland <geirola@gmail.com>
---
 include/net/sctp/structs.h |  1 +
 include/uapi/linux/sctp.h  |  1 +
 net/sctp/socket.c          | 43 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 45 insertions(+)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 5ed8a3c..06585b8 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -217,6 +217,7 @@ struct sctp_sock {
 	__u32 adaptation_ind;
 	__u32 pd_point;
 	__u8 recvrcvinfo;
+	__u8 recvnxtinfo;
 
 	atomic_t pd_mode;
 	/* Receive to here while partial delivery is in effect. */
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index d725e30..986563e 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -98,6 +98,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_PEER_ADDR_THLDS	31
 
 #define SCTP_RECVRCVINFO 32
+#define SCTP_RECVNXTINFO 33
 
 /* Internal Socket Options. Some of the sctp library functions are
  * implemented using these socket options.
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 57657b6..10e12da 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3602,6 +3602,20 @@ static int sctp_setsockopt_recvrcvinfo(struct sock *sk,
 }
 
 
+static int sctp_setsockopt_recvnxtinfo(struct sock *sk,
+					char __user *optval,
+					unsigned int optlen){
+	int val;
+
+	if (optlen < sizeof(int))
+		return -EINVAL;
+
+	if (get_user(val, (int __user *)optval))
+		return -EFAULT;
+
+	sctp_sk(sk)->recvnxtinfo = (val == 0) ? 0 : 1;
+	return 0;
+}
 
 /* API 6.2 setsockopt(), getsockopt()
  *
@@ -3757,6 +3771,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_RECVRCVINFO:
 		retval = sctp_setsockopt_recvrcvinfo(sk, optval, optlen);
 		break;
+	case SCTP_RECVNXTINFO:
+		retval = sctp_setsockopt_recvnxtinfo(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -4006,6 +4023,9 @@ static int sctp_init_sock(struct sock *sk)
 	/* No SCTP_RECVRCVINFO by default. */
 	sp->recvrcvinfo = 0;
 
+	/* No SCTP_RECVNXTINFO by default. */
+	sp->recvnxtinfo = 0;
+
 	/* Enable by default. */
 	sp->v4mapped          = 1;
 
@@ -5777,6 +5797,26 @@ static int sctp_getsockopt_assoc_stats(struct sock *sk, int len,
 	return 0;
 }
 
+static int sctp_getsockopt_recvnxtinfo(struct sock *sk,
+					int len,
+					char __user *optval,
+					int __user *optlen){
+
+	int val;
+	if (len < sizeof(int))
+		return -EINVAL;
+
+	len = sizeof(int);
+	val = (sctp_sk(sk)->recvnxtinfo == 1);
+
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(optval, &val, len))
+		return -EFAULT;
+
+	return 0;
+}
+
 static int sctp_getsockopt_recvrcvinfo(struct sock *sk,
 		int len,
 		char __user *optval,
@@ -5944,6 +5984,9 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_RECVRCVINFO:
 		retval = sctp_getsockopt_recvrcvinfo(sk, len, optval, optlen);
 		break;
+	case SCTP_RECVNXTINFO:
+		retval = sctp_getsockopt_recvnxtinfo(sk, len, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
