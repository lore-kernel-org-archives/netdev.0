From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 09/13] [PATCH] af_iucv: Modify iucv msg target class using control msghdr
Date: Tue, 21 Apr 2009 12:35:06 +0200
Message-ID: <20090421103706.262938000@linux.vnet.ibm.com>
References: <20090421103457.965299000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:42848 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754555AbZDUKhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 06:37:08 -0400
Content-Disposition: inline; filename=609-af_iucv-target-class.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

Allow 'classification' of socket data that is sent or received over
an af_iucv socket. For classification of data, the target class of an
(native) iucv message is used.

This patch provides the cmsg interface for iucv_sock_recvmsg() and
iucv_sock_sendmsg().  Applications can use the msg_control field of
struct msghdr to set or get the target class as a
"socket control message" (SCM/CMSG).

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 include/net/iucv/af_iucv.h |    3 +
 net/iucv/af_iucv.c         |   79 ++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 78 insertions(+), 4 deletions(-)

Index: net-2.6-uschi/include/net/iucv/af_iucv.h
===================================================================
--- net-2.6-uschi.orig/include/net/iucv/af_iucv.h
+++ net-2.6-uschi/include/net/iucv/af_iucv.h
@@ -79,6 +79,9 @@ struct iucv_sock {
 /* iucv socket options (SOL_IUCV) */
 #define SO_IPRMDATA_MSG	0x0080		/* send/recv IPRM_DATA msgs */
 
+/* iucv related control messages (scm) */
+#define SCM_IUCV_TRGCLS	0x0001		/* target class control message */
+
 struct iucv_sock_list {
 	struct hlist_head head;
 	rwlock_t	  lock;
Index: net-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6-uschi/net/iucv/af_iucv.c
@@ -45,6 +45,15 @@ static struct proto iucv_proto = {
 static const u8 iprm_shutdown[8] =
 	{0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01};
 
+#define TRGCLS_SIZE	(sizeof(((struct iucv_message *)0)->class))
+
+/* macros to set/get socket control buffer at correct offset */
+#define CB_TAG(skb)	((skb)->cb)		/* iucv message tag */
+#define CB_TAG_LEN	(sizeof(((struct iucv_message *) 0)->tag))
+#define CB_TRGCLS(skb)	((skb)->cb + CB_TAG_LEN) /* iucv msg target class */
+#define CB_TRGCLS_LEN	(TRGCLS_SIZE)
+
+
 static void iucv_sock_kill(struct sock *sk);
 static void iucv_sock_close(struct sock *sk);
 
@@ -701,6 +710,8 @@ static int iucv_sock_sendmsg(struct kioc
 	struct iucv_sock *iucv = iucv_sk(sk);
 	struct sk_buff *skb;
 	struct iucv_message txmsg;
+	struct cmsghdr *cmsg;
+	int cmsg_done;
 	char user_id[9];
 	char appl_id[9];
 	int err;
@@ -720,6 +731,48 @@ static int iucv_sock_sendmsg(struct kioc
 	}
 
 	if (sk->sk_state == IUCV_CONNECTED) {
+		/* initialize defaults */
+		cmsg_done   = 0;	/* check for duplicate headers */
+		txmsg.class = 0;
+
+		/* iterate over control messages */
+		for (cmsg = CMSG_FIRSTHDR(msg); cmsg;
+		     cmsg = CMSG_NXTHDR(msg, cmsg)) {
+
+			if (!CMSG_OK(msg, cmsg)) {
+				err = -EINVAL;
+				goto out;
+			}
+
+			if (cmsg->cmsg_level != SOL_IUCV)
+				continue;
+
+			if (cmsg->cmsg_type & cmsg_done) {
+				err = -EINVAL;
+				goto out;
+			}
+			cmsg_done |= cmsg->cmsg_type;
+
+			switch (cmsg->cmsg_type) {
+			case SCM_IUCV_TRGCLS:
+				if (cmsg->cmsg_len != CMSG_LEN(TRGCLS_SIZE)) {
+					err = -EINVAL;
+					goto out;
+				}
+
+				/* set iucv message target class */
+				memcpy(&txmsg.class,
+					(void *) CMSG_DATA(cmsg), TRGCLS_SIZE);
+
+				break;
+
+			default:
+				err = -EINVAL;
+				goto out;
+				break;
+			}
+		}
+
 		if (!(skb = sock_alloc_send_skb(sk, len,
 						msg->msg_flags & MSG_DONTWAIT,
 						&err)))
@@ -730,10 +783,9 @@ static int iucv_sock_sendmsg(struct kioc
 			goto fail;
 		}
 
-		txmsg.class = 0;
-		memcpy(&txmsg.class, skb->data, skb->len >= 4 ? 4 : skb->len);
+		/* increment and save iucv message tag for msg_completion cbk */
 		txmsg.tag = iucv->send_tag++;
-		memcpy(skb->cb, &txmsg.tag, 4);
+		memcpy(CB_TAG(skb), &txmsg.tag, CB_TAG_LEN);
 		skb_queue_tail(&iucv->send_skb_q, skb);
 
 		if (((iucv->path->flags & IUCV_IPRMDATA) & iucv->flags)
@@ -804,6 +856,10 @@ static int iucv_fragment_skb(struct sock
 		if (!nskb)
 			return -ENOMEM;
 
+		/* copy target class to control buffer of new skb */
+		memcpy(CB_TRGCLS(nskb), CB_TRGCLS(skb), CB_TRGCLS_LEN);
+
+		/* copy data fragment */
 		memcpy(nskb->data, skb->data + copied, size);
 		copied += size;
 		dataleft -= size;
@@ -827,6 +883,10 @@ static void iucv_process_message(struct 
 
 	len = iucv_msg_length(msg);
 
+	/* store msg target class in the second 4 bytes of skb ctrl buffer */
+	/* Note: the first 4 bytes are reserved for msg tag */
+	memcpy(CB_TRGCLS(skb), &msg->class, CB_TRGCLS_LEN);
+
 	/* check for special IPRM messages (e.g. iucv_sock_shutdown) */
 	if ((msg->flags & IUCV_IPRMDATA) && len > 7) {
 		if (memcmp(msg->rmmsg, iprm_shutdown, 8) == 0) {
@@ -920,6 +980,17 @@ static int iucv_sock_recvmsg(struct kioc
 
 	len -= copied;
 
+	/* create control message to store iucv msg target class:
+	 * get the trgcls from the control buffer of the skb due to
+	 * fragmentation of original iucv message. */
+	err = put_cmsg(msg, SOL_IUCV, SCM_IUCV_TRGCLS,
+			CB_TRGCLS_LEN, CB_TRGCLS(skb));
+	if (err) {
+		if (!(flags & MSG_PEEK))
+			skb_queue_head(&sk->sk_receive_queue, skb);
+		return err;
+	}
+
 	/* Mark read part of skb as used */
 	if (!(flags & MSG_PEEK)) {
 		skb_pull(skb, copied);
@@ -1324,7 +1395,7 @@ static void iucv_callback_txdone(struct 
 		spin_lock_irqsave(&list->lock, flags);
 
 		while (list_skb != (struct sk_buff *)list) {
-			if (!memcmp(&msg->tag, list_skb->cb, 4)) {
+			if (!memcmp(&msg->tag, CB_TAG(list_skb), CB_TAG_LEN)) {
 				this = list_skb;
 				break;
 			}

