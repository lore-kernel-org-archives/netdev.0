From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 08/13] [PATCH] af_iucv: Support data in IUCV msg parameter lists (IPRMDATA)
Date: Tue, 21 Apr 2009 12:35:05 +0200
Message-ID: <20090421103706.132570000@linux.vnet.ibm.com>
References: <20090421103457.965299000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:36276 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754376AbZDUKhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 06:37:08 -0400
Content-Disposition: inline; filename=608-af_iucv-iprmdata.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

The patch allows to send and receive data in the parameter list of an
iucv message.
The parameter list is an arry of 8 bytes that are used by af_iucv as
follows:
	0..6  7 bytes for socket data and
	   7  1 byte to store the data length.

Instead of storing the data length directly, the difference
between 0xFF and the data length is used.
This convention does not interfere with the existing use of PRM
messages for shutting down the send direction of an AF_IUCV socket
(shutdown() operation).  Data lenghts greater than 7 (or PRM message
byte 8 is less than 0xF8) denotes to special messages.
Currently, the special SEND_SHUTDOWN message is supported only.

To use IPRM messages, both communicators must set the IUCV_IPRMDATA
flag during path negotiation, i.e. in iucv_connect() and
path_pending().

To be compatible to older af_iucv implementations, sending PRM
messages is controlled by the socket option SO_IPRMDATA_MSG.
Receiving PRM messages does not depend on the socket option (but
requires the IUCV_IPRMDATA path flag to be set).

Sending/Receiving data in the parameter list improves performance for
small amounts of data by reducing message_completion() interrupts and
memory copy operations.

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |  121 ++++++++++++++++++++++++++++++++++++++++++++---------
 net/iucv/iucv.c    |    2 
 2 files changed, 103 insertions(+), 20 deletions(-)

Index: net-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6-uschi/net/iucv/af_iucv.c
@@ -29,9 +29,6 @@
 #include <net/iucv/iucv.h>
 #include <net/iucv/af_iucv.h>
 
-#define CONFIG_IUCV_SOCK_DEBUG 1
-
-#define IPRMDATA 0x80
 #define VERSION "1.1"
 
 static char iucv_userid[80];
@@ -44,6 +41,10 @@ static struct proto iucv_proto = {
 	.obj_size	= sizeof(struct iucv_sock),
 };
 
+/* special AF_IUCV IPRM messages */
+static const u8 iprm_shutdown[8] =
+	{0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01};
+
 static void iucv_sock_kill(struct sock *sk);
 static void iucv_sock_close(struct sock *sk);
 
@@ -80,6 +81,37 @@ static inline void low_nmcpy(unsigned ch
        memcpy(&dst[8], src, 8);
 }
 
+/**
+ * iucv_msg_length() - Returns the length of an iucv message.
+ * @msg:	Pointer to struct iucv_message, MUST NOT be NULL
+ *
+ * The function returns the length of the specified iucv message @msg of data
+ * stored in a buffer and of data stored in the parameter list (PRMDATA).
+ *
+ * For IUCV_IPRMDATA, AF_IUCV uses the following convention to transport socket
+ * data:
+ *	PRMDATA[0..6]	socket data (max 7 bytes);
+ *	PRMDATA[7]	socket data length value (len is 0xff - PRMDATA[7])
+ *
+ * The socket data length is computed by substracting the socket data length
+ * value from 0xFF.
+ * If the socket data len is greater 7, then PRMDATA can be used for special
+ * notifications (see iucv_sock_shutdown); and further,
+ * if the socket data len is > 7, the function returns 8.
+ *
+ * Use this function to allocate socket buffers to store iucv message data.
+ */
+static inline size_t iucv_msg_length(struct iucv_message *msg)
+{
+	size_t datalen;
+
+	if (msg->flags & IUCV_IPRMDATA) {
+		datalen = 0xff - msg->rmmsg[7];
+		return (datalen < 8) ? datalen : 8;
+	}
+	return msg->length;
+}
+
 /* Timers */
 static void iucv_sock_timeout(unsigned long arg)
 {
@@ -490,7 +522,7 @@ static int iucv_sock_connect(struct sock
 	iucv = iucv_sk(sk);
 	/* Create path. */
 	iucv->path = iucv_path_alloc(IUCV_QUEUELEN_DEFAULT,
-				     IPRMDATA, GFP_KERNEL);
+				     IUCV_IPRMDATA, GFP_KERNEL);
 	if (!iucv->path) {
 		err = -ENOMEM;
 		goto done;
@@ -524,8 +556,7 @@ static int iucv_sock_connect(struct sock
 	}
 
 	if (sk->sk_state == IUCV_DISCONN) {
-		release_sock(sk);
-		return -ECONNREFUSED;
+		err = -ECONNREFUSED;
 	}
 
 	if (err) {
@@ -639,6 +670,30 @@ static int iucv_sock_getname(struct sock
 	return 0;
 }
 
+/**
+ * iucv_send_iprm() - Send socket data in parameter list of an iucv message.
+ * @path:	IUCV path
+ * @msg:	Pointer to a struct iucv_message
+ * @skb:	The socket data to send, skb->len MUST BE <= 7
+ *
+ * Send the socket data in the parameter list in the iucv message
+ * (IUCV_IPRMDATA). The socket data is stored at index 0 to 6 in the parameter
+ * list and the socket data len at index 7 (last byte).
+ * See also iucv_msg_length().
+ *
+ * Returns the error code from the iucv_message_send() call.
+ */
+static int iucv_send_iprm(struct iucv_path *path, struct iucv_message *msg,
+			  struct sk_buff *skb)
+{
+	u8 prmdata[8];
+
+	memcpy(prmdata, (void *) skb->data, skb->len);
+	prmdata[7] = 0xff - (u8) skb->len;
+	return iucv_message_send(path, msg, IUCV_IPRMDATA, 0,
+				 (void *) prmdata, 8);
+}
+
 static int iucv_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 			     struct msghdr *msg, size_t len)
 {
@@ -680,8 +735,29 @@ static int iucv_sock_sendmsg(struct kioc
 		txmsg.tag = iucv->send_tag++;
 		memcpy(skb->cb, &txmsg.tag, 4);
 		skb_queue_tail(&iucv->send_skb_q, skb);
-		err = iucv_message_send(iucv->path, &txmsg, 0, 0,
-					(void *) skb->data, skb->len);
+
+		if (((iucv->path->flags & IUCV_IPRMDATA) & iucv->flags)
+		    && skb->len <= 7) {
+			err = iucv_send_iprm(iucv->path, &txmsg, skb);
+
+			/* on success: there is no message_complete callback
+			 * for an IPRMDATA msg; remove skb from send queue */
+			if (err == 0) {
+				skb_unlink(skb, &iucv->send_skb_q);
+				kfree_skb(skb);
+			}
+
+			/* this error should never happen since the
+			 * IUCV_IPRMDATA path flag is set... sever path */
+			if (err == 0x15) {
+				iucv_path_sever(iucv->path, NULL);
+				skb_unlink(skb, &iucv->send_skb_q);
+				err = -EPIPE;
+				goto fail;
+			}
+		} else
+			err = iucv_message_send(iucv->path, &txmsg, 0, 0,
+						(void *) skb->data, skb->len);
 		if (err) {
 			if (err == 3) {
 				user_id[8] = 0;
@@ -747,19 +823,25 @@ static void iucv_process_message(struct 
 				 struct iucv_message *msg)
 {
 	int rc;
+	unsigned int len;
 
-	if (msg->flags & IPRMDATA) {
-		skb->data = NULL;
-		skb->len = 0;
+	len = iucv_msg_length(msg);
+
+	/* check for special IPRM messages (e.g. iucv_sock_shutdown) */
+	if ((msg->flags & IUCV_IPRMDATA) && len > 7) {
+		if (memcmp(msg->rmmsg, iprm_shutdown, 8) == 0) {
+			skb->data = NULL;
+			skb->len = 0;
+		}
 	} else {
-		rc = iucv_message_receive(path, msg, 0, skb->data,
-					  msg->length, NULL);
+		rc = iucv_message_receive(path, msg, msg->flags & IUCV_IPRMDATA,
+					  skb->data, len, NULL);
 		if (rc) {
 			kfree_skb(skb);
 			return;
 		}
 		if (skb->truesize >= sk->sk_rcvbuf / 4) {
-			rc = iucv_fragment_skb(sk, skb, msg->length);
+			rc = iucv_fragment_skb(sk, skb, len);
 			kfree_skb(skb);
 			skb = NULL;
 			if (rc) {
@@ -770,7 +852,7 @@ static void iucv_process_message(struct 
 		} else {
 			skb_reset_transport_header(skb);
 			skb_reset_network_header(skb);
-			skb->len = msg->length;
+			skb->len = len;
 		}
 	}
 
@@ -785,7 +867,7 @@ static void iucv_process_message_q(struc
 	struct sock_msg_q *p, *n;
 
 	list_for_each_entry_safe(p, n, &iucv->message_q.list, list) {
-		skb = alloc_skb(p->msg.length, GFP_ATOMIC | GFP_DMA);
+		skb = alloc_skb(iucv_msg_length(&p->msg), GFP_ATOMIC | GFP_DMA);
 		if (!skb)
 			break;
 		iucv_process_message(sk, skb, p->path, &p->msg);
@@ -931,7 +1013,6 @@ static int iucv_sock_shutdown(struct soc
 	struct iucv_sock *iucv = iucv_sk(sk);
 	struct iucv_message txmsg;
 	int err = 0;
-	u8 prmmsg[8] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01};
 
 	how++;
 
@@ -956,7 +1037,7 @@ static int iucv_sock_shutdown(struct soc
 		txmsg.class = 0;
 		txmsg.tag = 0;
 		err = iucv_message_send(iucv->path, &txmsg, IUCV_IPRMDATA, 0,
-					(void *) prmmsg, 8);
+					(void *) iprm_shutdown, 8);
 		if (err) {
 			switch (err) {
 			case 1:
@@ -1204,11 +1285,11 @@ static void iucv_callback_rx(struct iucv
 		goto save_message;
 
 	len = atomic_read(&sk->sk_rmem_alloc);
-	len += msg->length + sizeof(struct sk_buff);
+	len += iucv_msg_length(msg) + sizeof(struct sk_buff);
 	if (len > sk->sk_rcvbuf)
 		goto save_message;
 
-	skb = alloc_skb(msg->length, GFP_ATOMIC | GFP_DMA);
+	skb = alloc_skb(iucv_msg_length(msg), GFP_ATOMIC | GFP_DMA);
 	if (!skb)
 		goto save_message;
 
Index: net-2.6-uschi/net/iucv/iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/iucv.c
+++ net-2.6-uschi/net/iucv/iucv.c
@@ -1388,6 +1388,8 @@ static void iucv_path_complete(struct iu
 	struct iucv_path_complete *ipc = (void *) data;
 	struct iucv_path *path = iucv_path_table[ipc->ippathid];
 
+	if (path)
+		path->flags = ipc->ipflags1;
 	if (path && path->handler && path->handler->path_complete)
 		path->handler->path_complete(path, ipc->ipuser);
 }

