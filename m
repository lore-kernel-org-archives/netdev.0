From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 05/13] [PATCH] af_iucv: sync sk shutdown flag if iucv path is quiesced
Date: Tue, 21 Apr 2009 12:35:02 +0200
Message-ID: <20090421103705.732592000@linux.vnet.ibm.com>
References: <20090421103457.965299000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:46969 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872AbZDUKhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 06:37:07 -0400
Content-Disposition: inline; filename=605-af_iucv-sync-shutdown.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

If the af_iucv communication partner quiesces the path to shutdown its
receive direction, provide a quiesce callback implementation to shutdown
the (local) send direction. This ensures that both sides are synchronized.

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |   19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

Index: net-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6-uschi/net/iucv/af_iucv.c
@@ -54,6 +54,7 @@ static void iucv_callback_connack(struct
 static int iucv_callback_connreq(struct iucv_path *, u8 ipvmid[8],
 				 u8 ipuser[16]);
 static void iucv_callback_connrej(struct iucv_path *, u8 ipuser[16]);
+static void iucv_callback_shutdown(struct iucv_path *, u8 ipuser[16]);
 
 static struct iucv_sock_list iucv_sk_list = {
 	.lock = __RW_LOCK_UNLOCKED(iucv_sk_list.lock),
@@ -65,7 +66,8 @@ static struct iucv_handler af_iucv_handl
 	.path_complete	  = iucv_callback_connack,
 	.path_severed	  = iucv_callback_connrej,
 	.message_pending  = iucv_callback_rx,
-	.message_complete = iucv_callback_txdone
+	.message_complete = iucv_callback_txdone,
+	.path_quiesced	  = iucv_callback_shutdown,
 };
 
 static inline void high_nmcpy(unsigned char *dst, char *src)
@@ -1202,6 +1204,21 @@ static void iucv_callback_connrej(struct
 	sk->sk_state_change(sk);
 }
 
+/* called if the other communication side shuts down its RECV direction;
+ * in turn, the callback sets SEND_SHUTDOWN to disable sending of data.
+ */
+static void iucv_callback_shutdown(struct iucv_path *path, u8 ipuser[16])
+{
+	struct sock *sk = path->private;
+
+	bh_lock_sock(sk);
+	if (sk->sk_state != IUCV_CLOSED) {
+		sk->sk_shutdown |= SEND_SHUTDOWN;
+		sk->sk_state_change(sk);
+	}
+	bh_unlock_sock(sk);
+}
+
 static struct proto_ops iucv_sock_ops = {
 	.family		= PF_IUCV,
 	.owner		= THIS_MODULE,

