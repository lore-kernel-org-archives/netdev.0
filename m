From: frank.blaschka@de.ibm.com
Subject: [patch 03/10] [PATCH] af_iucv: release reference to HS device
Date: Tue, 20 Dec 2011 09:56:29 +0100
Message-ID: <20111220085735.796970311@de.ibm.com>
References: <20111220085626.924756639@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:59932 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865Ab1LTI5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 03:57:39 -0500
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 20 Dec 2011 08:57:37 -0000
Content-Disposition: inline; filename=602-af_iucv-release-skb-hs.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

For HiperSockets transport skbs sent are bound to one of the
available HiperSockets devices. Add missing release of reference to
a HiperSockets device before freeing an skb.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 net/iucv/af_iucv.c |   37 ++++++++++++++++++++++++-------------
 1 file changed, 24 insertions(+), 13 deletions(-)

--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -130,6 +130,17 @@ static inline void low_nmcpy(unsigned ch
        memcpy(&dst[8], src, 8);
 }
 
+static void iucv_skb_queue_purge(struct sk_buff_head *list)
+{
+	struct sk_buff *skb;
+
+	while ((skb = skb_dequeue(list)) != NULL) {
+		if (skb->dev)
+			dev_put(skb->dev);
+		kfree_skb(skb);
+	}
+}
+
 static int afiucv_pm_prepare(struct device *dev)
 {
 #ifdef CONFIG_PM_DEBUG
@@ -164,7 +175,7 @@ static int afiucv_pm_freeze(struct devic
 	read_lock(&iucv_sk_list.lock);
 	sk_for_each(sk, node, &iucv_sk_list.head) {
 		iucv = iucv_sk(sk);
-		skb_queue_purge(&iucv->send_skb_q);
+		iucv_skb_queue_purge(&iucv->send_skb_q);
 		skb_queue_purge(&iucv->backlog_skb_q);
 		switch (sk->sk_state) {
 		case IUCV_SEVERED:
@@ -366,9 +377,7 @@ static int afiucv_hs_send(struct iucv_me
 	if (imsg)
 		memcpy(&phs_hdr->iucv_hdr, imsg, sizeof(struct iucv_message));
 
-	rcu_read_lock();
-	skb->dev = dev_get_by_index_rcu(net, sock->sk_bound_dev_if);
-	rcu_read_unlock();
+	skb->dev = dev_get_by_index(net, sock->sk_bound_dev_if);
 	if (!skb->dev)
 		return -ENODEV;
 	if (!(skb->dev->flags & IFF_UP))
@@ -388,6 +397,7 @@ static int afiucv_hs_send(struct iucv_me
 	err = dev_queue_xmit(skb);
 	if (err) {
 		skb_unlink(nskb, &iucv->send_skb_q);
+		dev_put(nskb->dev);
 		kfree_skb(nskb);
 	} else {
 		atomic_sub(confirm_recv, &iucv->msg_recv);
@@ -481,16 +491,14 @@ static void iucv_sock_close(struct sock
 			blen = sizeof(struct af_iucv_trans_hdr) + ETH_HLEN;
 			skb = sock_alloc_send_skb(sk, blen, 1, &err);
 			if (skb) {
-				skb_reserve(skb,
-					sizeof(struct af_iucv_trans_hdr) +
-					ETH_HLEN);
+				skb_reserve(skb, blen);
 				err = afiucv_hs_send(NULL, sk, skb,
 						     AF_IUCV_FLAG_FIN);
 			}
 			sk->sk_state = IUCV_DISCONN;
 			sk->sk_state_change(sk);
 		}
-	case IUCV_DISCONN:
+	case IUCV_DISCONN:   /* fall through */
 		sk->sk_state = IUCV_CLOSING;
 		sk->sk_state_change(sk);
 
@@ -520,7 +528,7 @@ static void iucv_sock_close(struct sock
 		sk->sk_err = ECONNRESET;
 		sk->sk_state_change(sk);
 
-		skb_queue_purge(&iucv->send_skb_q);
+		iucv_skb_queue_purge(&iucv->send_skb_q);
 		skb_queue_purge(&iucv->backlog_skb_q);
 		break;
 
@@ -739,7 +747,7 @@ static int iucv_sock_bind(struct socket
 		if (!memcmp(dev->perm_addr, uid, 8)) {
 			memcpy(iucv->src_name, sa->siucv_name, 8);
 			memcpy(iucv->src_user_id, sa->siucv_user_id, 8);
-			sock->sk->sk_bound_dev_if = dev->ifindex;
+			sk->sk_bound_dev_if = dev->ifindex;
 			sk->sk_state = IUCV_BOUND;
 			iucv->transport = AF_IUCV_TRANS_HIPER;
 			if (!iucv->msglimit)
@@ -1225,6 +1233,8 @@ release:
 	return len;
 
 fail:
+	if (skb->dev)
+		dev_put(skb->dev);
 	kfree_skb(skb);
 out:
 	release_sock(sk);
@@ -1441,9 +1451,7 @@ static int iucv_sock_recvmsg(struct kioc
 					ETH_HLEN;
 				sskb = sock_alloc_send_skb(sk, blen, 1, &err);
 				if (sskb) {
-					skb_reserve(sskb,
-						sizeof(struct af_iucv_trans_hdr)
-						+ ETH_HLEN);
+					skb_reserve(sskb, blen);
 					err = afiucv_hs_send(NULL, sk, sskb,
 							     AF_IUCV_FLAG_WIN);
 				}
@@ -2261,6 +2269,7 @@ static void afiucv_hs_callback_txnotify(
 			case TX_NOTIFY_OK:
 				__skb_unlink(this, list);
 				iucv_sock_wake_msglim(sk);
+				dev_put(this->dev);
 				kfree_skb(this);
 				break;
 			case TX_NOTIFY_PENDING:
@@ -2271,6 +2280,7 @@ static void afiucv_hs_callback_txnotify(
 				atomic_dec(&iucv->pendings);
 				if (atomic_read(&iucv->pendings) <= 0)
 					iucv_sock_wake_msglim(sk);
+				dev_put(this->dev);
 				kfree_skb(this);
 				break;
 			case TX_NOTIFY_UNREACHABLE:
@@ -2279,6 +2289,7 @@ static void afiucv_hs_callback_txnotify(
 			case TX_NOTIFY_GENERALERROR:
 			case TX_NOTIFY_DELAYED_GENERALERROR:
 				__skb_unlink(this, list);
+				dev_put(this->dev);
 				kfree_skb(this);
 				if (!list_empty(&iucv->accept_q))
 					sk->sk_state = IUCV_SEVERED;
