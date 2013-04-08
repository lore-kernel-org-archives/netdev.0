From: frank.blaschka@de.ibm.com
Subject: [patch 1/2] af_iucv: fix recvmsg by replacing skb_pull() function
Date: Mon, 08 Apr 2013 10:19:26 +0200
Message-ID: <20130408082003.666955316@de.ibm.com>
References: <20130408081925.995757091@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:46522 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934852Ab3DHIUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 04:20:10 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 8 Apr 2013 09:18:38 +0100
Content-Disposition: inline; filename=601-af-iucv-skb-pull.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

When receiving data messages, the "BUG_ON(skb->len < skb->data_len)" in
the skb_pull() function triggers a kernel panic.

Replace the skb_pull logic by a per skb offset as advised by
Eric Dumazet.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Reviewed-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
---
 include/net/iucv/af_iucv.h |    8 ++++++++
 net/iucv/af_iucv.c         |   34 ++++++++++++++++------------------
 2 files changed, 24 insertions(+), 18 deletions(-)

--- a/include/net/iucv/af_iucv.h
+++ b/include/net/iucv/af_iucv.h
@@ -130,6 +130,14 @@ struct iucv_sock {
 					       enum iucv_tx_notify n);
 };
 
+struct iucv_skb_cb {
+	u32	class;		/* target class of message */
+	u32	tag;		/* tag associated with message */
+	u32	offset;		/* offset for skb receival */
+};
+
+#define IUCV_SKB_CB(__skb)	((struct iucv_skb_cb *)&((__skb)->cb[0]))
+
 /* iucv socket options (SOL_IUCV) */
 #define SO_IPRMDATA_MSG	0x0080		/* send/recv IPRM_DATA msgs */
 #define SO_MSGLIMIT	0x1000		/* get/set IUCV MSGLIMIT */
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -49,12 +49,6 @@ static const u8 iprm_shutdown[8] =
 
 #define TRGCLS_SIZE	(sizeof(((struct iucv_message *)0)->class))
 
-/* macros to set/get socket control buffer at correct offset */
-#define CB_TAG(skb)	((skb)->cb)		/* iucv message tag */
-#define CB_TAG_LEN	(sizeof(((struct iucv_message *) 0)->tag))
-#define CB_TRGCLS(skb)	((skb)->cb + CB_TAG_LEN) /* iucv msg target class */
-#define CB_TRGCLS_LEN	(TRGCLS_SIZE)
-
 #define __iucv_sock_wait(sk, condition, timeo, ret)			\
 do {									\
 	DEFINE_WAIT(__wait);						\
@@ -1141,7 +1135,7 @@ static int iucv_sock_sendmsg(struct kioc
 
 	/* increment and save iucv message tag for msg_completion cbk */
 	txmsg.tag = iucv->send_tag++;
-	memcpy(CB_TAG(skb), &txmsg.tag, CB_TAG_LEN);
+	IUCV_SKB_CB(skb)->tag = txmsg.tag;
 
 	if (iucv->transport == AF_IUCV_TRANS_HIPER) {
 		atomic_inc(&iucv->msg_sent);
@@ -1224,7 +1218,7 @@ static int iucv_fragment_skb(struct sock
 			return -ENOMEM;
 
 		/* copy target class to control buffer of new skb */
-		memcpy(CB_TRGCLS(nskb), CB_TRGCLS(skb), CB_TRGCLS_LEN);
+		IUCV_SKB_CB(nskb)->class = IUCV_SKB_CB(skb)->class;
 
 		/* copy data fragment */
 		memcpy(nskb->data, skb->data + copied, size);
@@ -1256,7 +1250,7 @@ static void iucv_process_message(struct
 
 	/* store msg target class in the second 4 bytes of skb ctrl buffer */
 	/* Note: the first 4 bytes are reserved for msg tag */
-	memcpy(CB_TRGCLS(skb), &msg->class, CB_TRGCLS_LEN);
+	IUCV_SKB_CB(skb)->class = msg->class;
 
 	/* check for special IPRM messages (e.g. iucv_sock_shutdown) */
 	if ((msg->flags & IUCV_IPRMDATA) && len > 7) {
@@ -1292,6 +1286,7 @@ static void iucv_process_message(struct
 		}
 	}
 
+	IUCV_SKB_CB(skb)->offset = 0;
 	if (sock_queue_rcv_skb(sk, skb))
 		skb_queue_head(&iucv_sk(sk)->backlog_skb_q, skb);
 }
@@ -1327,6 +1322,7 @@ static int iucv_sock_recvmsg(struct kioc
 	unsigned int copied, rlen;
 	struct sk_buff *skb, *rskb, *cskb;
 	int err = 0;
+	u32 offset;
 
 	msg->msg_namelen = 0;
 
@@ -1348,13 +1344,14 @@ static int iucv_sock_recvmsg(struct kioc
 		return err;
 	}
 
-	rlen   = skb->len;		/* real length of skb */
+	offset = IUCV_SKB_CB(skb)->offset;
+	rlen   = skb->len - offset;		/* real length of skb */
 	copied = min_t(unsigned int, rlen, len);
 	if (!rlen)
 		sk->sk_shutdown = sk->sk_shutdown | RCV_SHUTDOWN;
 
 	cskb = skb;
-	if (skb_copy_datagram_iovec(cskb, 0, msg->msg_iov, copied)) {
+	if (skb_copy_datagram_iovec(cskb, offset, msg->msg_iov, copied)) {
 		if (!(flags & MSG_PEEK))
 			skb_queue_head(&sk->sk_receive_queue, skb);
 		return -EFAULT;
@@ -1372,7 +1369,8 @@ static int iucv_sock_recvmsg(struct kioc
 	 * get the trgcls from the control buffer of the skb due to
 	 * fragmentation of original iucv message. */
 	err = put_cmsg(msg, SOL_IUCV, SCM_IUCV_TRGCLS,
-			CB_TRGCLS_LEN, CB_TRGCLS(skb));
+		       sizeof(IUCV_SKB_CB(skb)->class),
+		       (void *)&IUCV_SKB_CB(skb)->class);
 	if (err) {
 		if (!(flags & MSG_PEEK))
 			skb_queue_head(&sk->sk_receive_queue, skb);
@@ -1384,9 +1382,8 @@ static int iucv_sock_recvmsg(struct kioc
 
 		/* SOCK_STREAM: re-queue skb if it contains unreceived data */
 		if (sk->sk_type == SOCK_STREAM) {
-			skb_pull(skb, copied);
-			if (skb->len) {
-				skb_queue_head(&sk->sk_receive_queue, skb);
+			if (copied < rlen) {
+				IUCV_SKB_CB(skb)->offset = offset + copied;
 				goto done;
 			}
 		}
@@ -1405,6 +1402,7 @@ static int iucv_sock_recvmsg(struct kioc
 		spin_lock_bh(&iucv->message_q.lock);
 		rskb = skb_dequeue(&iucv->backlog_skb_q);
 		while (rskb) {
+			IUCV_SKB_CB(rskb)->offset = 0;
 			if (sock_queue_rcv_skb(sk, rskb)) {
 				skb_queue_head(&iucv->backlog_skb_q,
 						rskb);
@@ -1832,7 +1830,7 @@ static void iucv_callback_txdone(struct
 		spin_lock_irqsave(&list->lock, flags);
 
 		while (list_skb != (struct sk_buff *)list) {
-			if (!memcmp(&msg->tag, CB_TAG(list_skb), CB_TAG_LEN)) {
+			if (msg->tag != IUCV_SKB_CB(list_skb)->tag) {
 				this = list_skb;
 				break;
 			}
@@ -2093,6 +2091,7 @@ static int afiucv_hs_callback_rx(struct
 	skb_pull(skb, sizeof(struct af_iucv_trans_hdr));
 	skb_reset_transport_header(skb);
 	skb_reset_network_header(skb);
+	IUCV_SKB_CB(skb)->offset = 0;
 	spin_lock(&iucv->message_q.lock);
 	if (skb_queue_empty(&iucv->backlog_skb_q)) {
 		if (sock_queue_rcv_skb(sk, skb)) {
@@ -2197,8 +2196,7 @@ static int afiucv_hs_rcv(struct sk_buff
 		/* fall through and receive zero length data */
 	case 0:
 		/* plain data frame */
-		memcpy(CB_TRGCLS(skb), &trans_hdr->iucv_hdr.class,
-		       CB_TRGCLS_LEN);
+		IUCV_SKB_CB(skb)->class = trans_hdr->iucv_hdr.class;
 		err = afiucv_hs_callback_rx(sk, skb);
 		break;
 	default:
