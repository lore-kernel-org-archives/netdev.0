From: frank.blaschka@de.ibm.com
Subject: [patch 2/7] [PATCH] af_iucv: add shutdown for HS transport
Date: Wed, 07 Mar 2012 13:06:24 +0100
Message-ID: <20120307120707.720168430@de.ibm.com>
References: <20120307120622.922387262@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp18.uk.ibm.com ([195.75.94.114]:47213 "EHLO
	e06smtp18.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753646Ab2CGMHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 07:07:11 -0500
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 7 Mar 2012 12:07:10 -0000
Content-Disposition: inline; filename=606-af_iucv-hs-shutdown.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

AF_IUCV sockets offer a shutdown function. This patch makes sure
shutdown works for HS transport as well.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 include/net/iucv/af_iucv.h |    1 
 net/iucv/af_iucv.c         |   79 +++++++++++++++++++++++++++++----------------
 2 files changed, 53 insertions(+), 27 deletions(-)

diff -urpN linux-2.6/include/net/iucv/af_iucv.h linux-2.6-patched/include/net/iucv/af_iucv.h
--- linux-2.6/include/net/iucv/af_iucv.h	2012-03-06 13:35:57.000000000 +0100
+++ linux-2.6-patched/include/net/iucv/af_iucv.h	2012-03-06 13:35:57.000000000 +0100
@@ -62,6 +62,7 @@ struct sock_msg_q {
 #define AF_IUCV_FLAG_SYN 0x2
 #define AF_IUCV_FLAG_FIN 0x4
 #define AF_IUCV_FLAG_WIN 0x8
+#define AF_IUCV_FLAG_SHT 0x10
 
 struct af_iucv_trans_hdr {
 	u16 magic;
diff -urpN linux-2.6/net/iucv/af_iucv.c linux-2.6-patched/net/iucv/af_iucv.c
--- linux-2.6/net/iucv/af_iucv.c	2012-03-06 13:35:57.000000000 +0100
+++ linux-2.6-patched/net/iucv/af_iucv.c	2012-03-06 13:35:57.000000000 +0100
@@ -165,8 +165,6 @@ static int afiucv_pm_freeze(struct devic
 	read_lock(&iucv_sk_list.lock);
 	sk_for_each(sk, node, &iucv_sk_list.head) {
 		iucv = iucv_sk(sk);
-		skb_queue_purge(&iucv->send_skb_q);
-		skb_queue_purge(&iucv->backlog_skb_q);
 		switch (sk->sk_state) {
 		case IUCV_DISCONN:
 		case IUCV_CLOSING:
@@ -405,7 +403,19 @@ static struct sock *__iucv_get_sock_by_n
 static void iucv_sock_destruct(struct sock *sk)
 {
 	skb_queue_purge(&sk->sk_receive_queue);
-	skb_queue_purge(&sk->sk_write_queue);
+	skb_queue_purge(&sk->sk_error_queue);
+
+	sk_mem_reclaim(sk);
+
+	if (!sock_flag(sk, SOCK_DEAD)) {
+		pr_err("Attempt to release alive iucv socket %p\n", sk);
+		return;
+	}
+
+	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
+	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(sk->sk_wmem_queued);
+	WARN_ON(sk->sk_forward_alloc);
 }
 
 /* Cleanup Listen */
@@ -1342,6 +1352,8 @@ static int iucv_sock_recvmsg(struct kioc
 
 	rlen   = skb->len;		/* real length of skb */
 	copied = min_t(unsigned int, rlen, len);
+	if (!rlen)
+		sk->sk_shutdown = sk->sk_shutdown | RCV_SHUTDOWN;
 
 	cskb = skb;
 	if (skb_copy_datagram_iovec(cskb, 0, msg->msg_iov, copied)) {
@@ -1493,42 +1505,47 @@ static int iucv_sock_shutdown(struct soc
 
 	lock_sock(sk);
 	switch (sk->sk_state) {
+	case IUCV_LISTEN:
 	case IUCV_DISCONN:
 	case IUCV_CLOSING:
 	case IUCV_CLOSED:
 		err = -ENOTCONN;
 		goto fail;
-
 	default:
-		sk->sk_shutdown |= how;
 		break;
 	}
 
 	if (how == SEND_SHUTDOWN || how == SHUTDOWN_MASK) {
-		txmsg.class = 0;
-		txmsg.tag = 0;
-		err = pr_iucv->message_send(iucv->path, &txmsg, IUCV_IPRMDATA,
-					0, (void *) iprm_shutdown, 8);
-		if (err) {
-			switch (err) {
-			case 1:
-				err = -ENOTCONN;
-				break;
-			case 2:
-				err = -ECONNRESET;
-				break;
-			default:
-				err = -ENOTCONN;
-				break;
+		if (iucv->transport == AF_IUCV_TRANS_IUCV) {
+			txmsg.class = 0;
+			txmsg.tag = 0;
+			err = pr_iucv->message_send(iucv->path, &txmsg,
+				IUCV_IPRMDATA, 0, (void *) iprm_shutdown, 8);
+			if (err) {
+				switch (err) {
+				case 1:
+					err = -ENOTCONN;
+					break;
+				case 2:
+					err = -ECONNRESET;
+					break;
+				default:
+					err = -ENOTCONN;
+					break;
+				}
 			}
-		}
+		} else
+			iucv_send_ctrl(sk, AF_IUCV_FLAG_SHT);
 	}
 
+	sk->sk_shutdown |= how;
 	if (how == RCV_SHUTDOWN || how == SHUTDOWN_MASK) {
-		err = pr_iucv->path_quiesce(iucv->path, NULL);
-		if (err)
-			err = -ENOTCONN;
-
+		if (iucv->transport == AF_IUCV_TRANS_IUCV) {
+			err = pr_iucv->path_quiesce(iucv->path, NULL);
+			if (err)
+				err = -ENOTCONN;
+/*			skb_queue_purge(&sk->sk_receive_queue); */
+		}
 		skb_queue_purge(&sk->sk_receive_queue);
 	}
 
@@ -2066,8 +2083,13 @@ static int afiucv_hs_callback_rx(struct
 		return NET_RX_SUCCESS;
 	}
 
+	if (sk->sk_shutdown & RCV_SHUTDOWN) {
+		kfree_skb(skb);
+		return NET_RX_SUCCESS;
+	}
+
 		/* write stuff from iucv_msg to skb cb */
-	if (skb->len <= sizeof(struct af_iucv_trans_hdr)) {
+	if (skb->len < sizeof(struct af_iucv_trans_hdr)) {
 		kfree_skb(skb);
 		return NET_RX_SUCCESS;
 	}
@@ -2173,7 +2195,10 @@ static int afiucv_hs_rcv(struct sk_buff
 			kfree_skb(skb);
 			break;
 		}
-		/* fall through */
+		/* fall through and receive non-zero length data */
+	case (AF_IUCV_FLAG_SHT):
+		/* shutdown request */
+		/* fall through and receive zero length data */
 	case 0:
 		/* plain data frame */
 		memcpy(CB_TRGCLS(skb), &trans_hdr->iucv_hdr.class,
