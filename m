From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 12/13] [PATCH] af_iucv: New socket option for setting IUCV MSGLIMITs
Date: Tue, 21 Apr 2009 12:35:09 +0200
Message-ID: <20090421103706.652855000@linux.vnet.ibm.com>
References: <20090421103457.965299000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:51475 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754596AbZDUKhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 06:37:09 -0400
Content-Disposition: inline; filename=612-af_iucv-msglimit.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

The SO_MSGLIMIT socket option modifies the message limit for new
IUCV communication paths.

The message limit specifies the maximum number of outstanding messages
that are allowed for connections. This setting can be lowered by z/VM
when an IUCV connection is established.

Expects an integer value in the range of 1 to 65535.
The default value is 65535.

The message limit must be set before calling connect() or listen()
for sockets.

If sockets are already connected or in state listen, changing the message
limit is not supported.
For reading the message limit value, unconnected sockets return the limit
that has been set or the default limit. For connected sockets, the actual
message limit is returned. The actual message limit is assigned by z/VM
for each connection and it depends on IUCV MSGLIMIT authorizations
specified for the z/VM guest virtual machine.

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 include/net/iucv/af_iucv.h |    2 ++
 net/iucv/af_iucv.c         |   27 +++++++++++++++++++++++++--
 2 files changed, 27 insertions(+), 2 deletions(-)

Index: net-2.6-uschi/include/net/iucv/af_iucv.h
===================================================================
--- net-2.6-uschi.orig/include/net/iucv/af_iucv.h
+++ net-2.6-uschi/include/net/iucv/af_iucv.h
@@ -74,10 +74,12 @@ struct iucv_sock {
 	struct sock_msg_q	message_q;
 	unsigned int		send_tag;
 	u8			flags;
+	u16			msglimit;
 };
 
 /* iucv socket options (SOL_IUCV) */
 #define SO_IPRMDATA_MSG	0x0080		/* send/recv IPRM_DATA msgs */
+#define SO_MSGLIMIT	0x1000		/* get/set IUCV MSGLIMIT */
 
 /* iucv related control messages (scm) */
 #define SCM_IUCV_TRGCLS	0x0001		/* target class control message */
Index: net-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6-uschi/net/iucv/af_iucv.c
@@ -269,6 +269,7 @@ static struct sock *iucv_sock_alloc(stru
 	skb_queue_head_init(&iucv_sk(sk)->backlog_skb_q);
 	iucv_sk(sk)->send_tag = 0;
 	iucv_sk(sk)->flags = 0;
+	iucv_sk(sk)->msglimit = IUCV_QUEUELEN_DEFAULT;
 	iucv_sk(sk)->path = NULL;
 	memset(&iucv_sk(sk)->src_user_id , 0, 32);
 
@@ -539,7 +540,7 @@ static int iucv_sock_connect(struct sock
 
 	iucv = iucv_sk(sk);
 	/* Create path. */
-	iucv->path = iucv_path_alloc(IUCV_QUEUELEN_DEFAULT,
+	iucv->path = iucv_path_alloc(iucv->msglimit,
 				     IUCV_IPRMDATA, GFP_KERNEL);
 	if (!iucv->path) {
 		err = -ENOMEM;
@@ -1225,6 +1226,20 @@ static int iucv_sock_setsockopt(struct s
 		else
 			iucv->flags &= ~IUCV_IPRMDATA;
 		break;
+	case SO_MSGLIMIT:
+		switch (sk->sk_state) {
+		case IUCV_OPEN:
+		case IUCV_BOUND:
+			if (val < 1 || val > (u16)(~0))
+				rc = -EINVAL;
+			else
+				iucv->msglimit = val;
+			break;
+		default:
+			rc = -EINVAL;
+			break;
+		}
+		break;
 	default:
 		rc = -ENOPROTOOPT;
 		break;
@@ -1256,6 +1271,12 @@ static int iucv_sock_getsockopt(struct s
 	case SO_IPRMDATA_MSG:
 		val = (iucv->flags & IUCV_IPRMDATA) ? 1 : 0;
 		break;
+	case SO_MSGLIMIT:
+		lock_sock(sk);
+		val = (iucv->path != NULL) ? iucv->path->msglim	/* connected */
+					   : iucv->msglimit;	/* default */
+		release_sock(sk);
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -1345,7 +1366,9 @@ static int iucv_callback_connreq(struct 
 	memcpy(nuser_data + 8, niucv->src_name, 8);
 	ASCEBC(nuser_data + 8, 8);
 
-	path->msglim = IUCV_QUEUELEN_DEFAULT;
+	/* set message limit for path based on msglimit of accepting socket */
+	niucv->msglimit = iucv->msglimit;
+	path->msglim = iucv->msglimit;
 	err = iucv_path_accept(path, &af_iucv_handler, nuser_data, nsk);
 	if (err) {
 		err = iucv_path_sever(path, user_data);

