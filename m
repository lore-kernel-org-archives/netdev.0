From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 07/13] [PATCH] af_iucv: add sockopt() to enable/disable use of IPRM_DATA msgs
Date: Tue, 21 Apr 2009 12:35:04 +0200
Message-ID: <20090421103705.991214000@linux.vnet.ibm.com>
References: <20090421103457.965299000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:35701 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967AbZDUKhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 06:37:07 -0400
Content-Disposition: inline; filename=607-af_iucv-iprm-sockopt.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

Provide the socket operations getsocktopt() and setsockopt() to enable/disable
sending of data in the parameter list of IUCV messages.
The patch sets respective flag only.

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 include/linux/socket.h     |    1 
 include/net/iucv/af_iucv.h |    4 ++
 net/iucv/af_iucv.c         |   79 +++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 81 insertions(+), 3 deletions(-)

Index: net-2.6-uschi/include/linux/socket.h
===================================================================
--- net-2.6-uschi.orig/include/linux/socket.h
+++ net-2.6-uschi/include/linux/socket.h
@@ -303,6 +303,7 @@ struct ucred {
 #define SOL_BLUETOOTH	274
 #define SOL_PNPIPE	275
 #define SOL_RDS		276
+#define SOL_IUCV	277
 
 /* IPX options */
 #define IPX_TYPE	1
Index: net-2.6-uschi/include/net/iucv/af_iucv.h
===================================================================
--- net-2.6-uschi.orig/include/net/iucv/af_iucv.h
+++ net-2.6-uschi/include/net/iucv/af_iucv.h
@@ -73,8 +73,12 @@ struct iucv_sock {
 	struct sk_buff_head	backlog_skb_q;
 	struct sock_msg_q	message_q;
 	unsigned int		send_tag;
+	u8			flags;
 };
 
+/* iucv socket options (SOL_IUCV) */
+#define SO_IPRMDATA_MSG	0x0080		/* send/recv IPRM_DATA msgs */
+
 struct iucv_sock_list {
 	struct hlist_head head;
 	rwlock_t	  lock;
Index: net-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6-uschi/net/iucv/af_iucv.c
@@ -32,7 +32,7 @@
 #define CONFIG_IUCV_SOCK_DEBUG 1
 
 #define IPRMDATA 0x80
-#define VERSION "1.0"
+#define VERSION "1.1"
 
 static char iucv_userid[80];
 
@@ -227,6 +227,7 @@ static struct sock *iucv_sock_alloc(stru
 	spin_lock_init(&iucv_sk(sk)->message_q.lock);
 	skb_queue_head_init(&iucv_sk(sk)->backlog_skb_q);
 	iucv_sk(sk)->send_tag = 0;
+	iucv_sk(sk)->flags = 0;
 	iucv_sk(sk)->path = NULL;
 	memset(&iucv_sk(sk)->src_user_id , 0, 32);
 
@@ -1009,6 +1010,78 @@ static int iucv_sock_release(struct sock
 	return err;
 }
 
+/* getsockopt and setsockopt */
+static int iucv_sock_setsockopt(struct socket *sock, int level, int optname,
+				char __user *optval, int optlen)
+{
+	struct sock *sk = sock->sk;
+	struct iucv_sock *iucv = iucv_sk(sk);
+	int val;
+	int rc;
+
+	if (level != SOL_IUCV)
+		return -ENOPROTOOPT;
+
+	if (optlen < sizeof(int))
+		return -EINVAL;
+
+	if (get_user(val, (int __user *) optval))
+		return -EFAULT;
+
+	rc = 0;
+
+	lock_sock(sk);
+	switch (optname) {
+	case SO_IPRMDATA_MSG:
+		if (val)
+			iucv->flags |= IUCV_IPRMDATA;
+		else
+			iucv->flags &= ~IUCV_IPRMDATA;
+		break;
+	default:
+		rc = -ENOPROTOOPT;
+		break;
+	}
+	release_sock(sk);
+
+	return rc;
+}
+
+static int iucv_sock_getsockopt(struct socket *sock, int level, int optname,
+				char __user *optval, int __user *optlen)
+{
+	struct sock *sk = sock->sk;
+	struct iucv_sock *iucv = iucv_sk(sk);
+	int val, len;
+
+	if (level != SOL_IUCV)
+		return -ENOPROTOOPT;
+
+	if (get_user(len, optlen))
+		return -EFAULT;
+
+	if (len < 0)
+		return -EINVAL;
+
+	len = min_t(unsigned int, len, sizeof(int));
+
+	switch (optname) {
+	case SO_IPRMDATA_MSG:
+		val = (iucv->flags & IUCV_IPRMDATA) ? 1 : 0;
+		break;
+	default:
+		return -ENOPROTOOPT;
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
+
 /* Callback wrappers - called from iucv base support */
 static int iucv_callback_connreq(struct iucv_path *path,
 				 u8 ipvmid[8], u8 ipuser[16])
@@ -1237,8 +1310,8 @@ static struct proto_ops iucv_sock_ops = 
 	.mmap		= sock_no_mmap,
 	.socketpair	= sock_no_socketpair,
 	.shutdown	= iucv_sock_shutdown,
-	.setsockopt	= sock_no_setsockopt,
-	.getsockopt	= sock_no_getsockopt
+	.setsockopt	= iucv_sock_setsockopt,
+	.getsockopt	= iucv_sock_getsockopt,
 };
 
 static struct net_proto_family iucv_sock_family_ops = {

