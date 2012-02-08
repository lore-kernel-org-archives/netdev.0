From: frank.blaschka@de.ibm.com
Subject: [patch 3/6] [PATCH] af_iucv: change net_device handling for HS transport
Date: Wed, 08 Feb 2012 11:19:47 +0100
Message-ID: <20120208102029.346652378@de.ibm.com>
References: <20120208101944.272235343@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:41683 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756076Ab2BHKVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 05:21:13 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 8 Feb 2012 10:21:11 -0000
Content-Disposition: inline; filename=603-af_iucv-netdev-hs-transport.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

This patch saves the net_device in the iucv_sock structure during
bind in order to fasten skb sending.
In addition some other small improvements are made for HS transport:
   - error checking when sending skbs
   - locking changes in afiucv_hs_callback_txnotify
   - skb freeing in afiucv_hs_callback_txnotify
And finally it contains code cleanup to get rid of iucv_skb_queue_purge.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 include/net/iucv/af_iucv.h |    1 
 net/iucv/af_iucv.c         |  119 +++++++++++++++++++++++----------------------
 2 files changed, 63 insertions(+), 57 deletions(-)

--- a/include/net/iucv/af_iucv.h
+++ b/include/net/iucv/af_iucv.h
@@ -113,6 +113,7 @@ struct iucv_sock {
 	spinlock_t		accept_q_lock;
 	struct sock		*parent;
 	struct iucv_path	*path;
+	struct net_device	*hs_dev;
 	struct sk_buff_head	send_skb_q;
 	struct sk_buff_head	backlog_skb_q;
 	struct sock_msg_q	message_q;
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -131,17 +131,6 @@ static inline void low_nmcpy(unsigned ch
        memcpy(&dst[8], src, 8);
 }
 
-static void iucv_skb_queue_purge(struct sk_buff_head *list)
-{
-	struct sk_buff *skb;
-
-	while ((skb = skb_dequeue(list)) != NULL) {
-		if (skb->dev)
-			dev_put(skb->dev);
-		kfree_skb(skb);
-	}
-}
-
 static int afiucv_pm_prepare(struct device *dev)
 {
 #ifdef CONFIG_PM_DEBUG
@@ -176,7 +165,7 @@ static int afiucv_pm_freeze(struct devic
 	read_lock(&iucv_sk_list.lock);
 	sk_for_each(sk, node, &iucv_sk_list.head) {
 		iucv = iucv_sk(sk);
-		iucv_skb_queue_purge(&iucv->send_skb_q);
+		skb_queue_purge(&iucv->send_skb_q);
 		skb_queue_purge(&iucv->backlog_skb_q);
 		switch (sk->sk_state) {
 		case IUCV_DISCONN:
@@ -337,7 +326,6 @@ static void iucv_sock_wake_msglim(struct
 static int afiucv_hs_send(struct iucv_message *imsg, struct sock *sock,
 		   struct sk_buff *skb, u8 flags)
 {
-	struct net *net = sock_net(sock);
 	struct iucv_sock *iucv = iucv_sk(sock);
 	struct af_iucv_trans_hdr *phs_hdr;
 	struct sk_buff *nskb;
@@ -374,10 +362,10 @@ static int afiucv_hs_send(struct iucv_me
 	if (imsg)
 		memcpy(&phs_hdr->iucv_hdr, imsg, sizeof(struct iucv_message));
 
-	skb->dev = dev_get_by_index(net, sock->sk_bound_dev_if);
+	skb->dev = iucv->hs_dev;
 	if (!skb->dev)
 		return -ENODEV;
-	if (!(skb->dev->flags & IFF_UP))
+	if (!(skb->dev->flags & IFF_UP) || !netif_carrier_ok(skb->dev))
 		return -ENETDOWN;
 	if (skb->len > skb->dev->mtu) {
 		if (sock->sk_type == SOCK_SEQPACKET)
@@ -392,15 +380,14 @@ static int afiucv_hs_send(struct iucv_me
 		return -ENOMEM;
 	skb_queue_tail(&iucv->send_skb_q, nskb);
 	err = dev_queue_xmit(skb);
-	if (err) {
+	if (net_xmit_eval(err)) {
 		skb_unlink(nskb, &iucv->send_skb_q);
-		dev_put(nskb->dev);
 		kfree_skb(nskb);
 	} else {
 		atomic_sub(confirm_recv, &iucv->msg_recv);
 		WARN_ON(atomic_read(&iucv->msg_recv) < 0);
 	}
-	return err;
+	return net_xmit_eval(err);
 }
 
 static struct sock *__iucv_get_sock_by_name(char *nm)
@@ -471,7 +458,8 @@ static void iucv_sock_close(struct sock
 {
 	struct iucv_sock *iucv = iucv_sk(sk);
 	unsigned long timeo;
-	int err, blen;
+	int err = 0;
+	int blen;
 	struct sk_buff *skb;
 
 	lock_sock(sk);
@@ -498,7 +486,7 @@ static void iucv_sock_close(struct sock
 		sk->sk_state = IUCV_CLOSING;
 		sk->sk_state_change(sk);
 
-		if (!skb_queue_empty(&iucv->send_skb_q)) {
+		if (!err && !skb_queue_empty(&iucv->send_skb_q)) {
 			if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime)
 				timeo = sk->sk_lingertime;
 			else
@@ -515,13 +503,19 @@ static void iucv_sock_close(struct sock
 		sk->sk_err = ECONNRESET;
 		sk->sk_state_change(sk);
 
-		iucv_skb_queue_purge(&iucv->send_skb_q);
+		skb_queue_purge(&iucv->send_skb_q);
 		skb_queue_purge(&iucv->backlog_skb_q);
 
 	default:   /* fall through */
 		iucv_sever_path(sk, 1);
 	}
 
+	if (iucv->hs_dev) {
+		dev_put(iucv->hs_dev);
+		iucv->hs_dev = NULL;
+		sk->sk_bound_dev_if = 0;
+	}
+
 	/* mark socket for deletion by iucv_sock_kill() */
 	sock_set_flag(sk, SOCK_ZAPPED);
 
@@ -713,7 +707,6 @@ static int iucv_sock_bind(struct socket
 		goto done_unlock;
 
 	/* Bind the socket */
-
 	if (pr_iucv)
 		if (!memcmp(sa->siucv_user_id, iucv_userid, 8))
 			goto vm_bind; /* VM IUCV transport */
@@ -727,6 +720,8 @@ static int iucv_sock_bind(struct socket
 			memcpy(iucv->src_name, sa->siucv_name, 8);
 			memcpy(iucv->src_user_id, sa->siucv_user_id, 8);
 			sk->sk_bound_dev_if = dev->ifindex;
+			iucv->hs_dev = dev;
+			dev_hold(dev);
 			sk->sk_state = IUCV_BOUND;
 			iucv->transport = AF_IUCV_TRANS_HIPER;
 			if (!iucv->msglimit)
@@ -1128,8 +1123,10 @@ static int iucv_sock_sendmsg(struct kioc
 			noblock, &err);
 	else
 		skb = sock_alloc_send_skb(sk, len, noblock, &err);
-	if (!skb)
+	if (!skb) {
+		err = -ENOMEM;
 		goto out;
+	}
 	if (iucv->transport == AF_IUCV_TRANS_HIPER)
 		skb_reserve(skb, sizeof(struct af_iucv_trans_hdr) + ETH_HLEN);
 	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
@@ -1152,6 +1149,7 @@ static int iucv_sock_sendmsg(struct kioc
 	/* increment and save iucv message tag for msg_completion cbk */
 	txmsg.tag = iucv->send_tag++;
 	memcpy(CB_TAG(skb), &txmsg.tag, CB_TAG_LEN);
+
 	if (iucv->transport == AF_IUCV_TRANS_HIPER) {
 		atomic_inc(&iucv->msg_sent);
 		err = afiucv_hs_send(&txmsg, sk, skb, 0);
@@ -1206,8 +1204,6 @@ release:
 	return len;
 
 fail:
-	if (skb->dev)
-		dev_put(skb->dev);
 	kfree_skb(skb);
 out:
 	release_sock(sk);
@@ -1400,7 +1396,14 @@ static int iucv_sock_recvmsg(struct kioc
 		}
 
 		kfree_skb(skb);
-		atomic_inc(&iucv->msg_recv);
+		if (iucv->transport == AF_IUCV_TRANS_HIPER) {
+			atomic_inc(&iucv->msg_recv);
+			if (atomic_read(&iucv->msg_recv) > iucv->msglimit) {
+				WARN_ON(1);
+				iucv_sock_close(sk);
+				return -EFAULT;
+			}
+		}
 
 		/* Queue backlog skbs */
 		spin_lock_bh(&iucv->message_q.lock);
@@ -1957,6 +1960,8 @@ static int afiucv_hs_callback_syn(struct
 	memcpy(niucv->src_name, iucv->src_name, 8);
 	memcpy(niucv->src_user_id, iucv->src_user_id, 8);
 	nsk->sk_bound_dev_if = sk->sk_bound_dev_if;
+	niucv->hs_dev = iucv->hs_dev;
+	dev_hold(niucv->hs_dev);
 	afiucv_swap_src_dest(skb);
 	trans_hdr->flags = AF_IUCV_FLAG_SYN | AF_IUCV_FLAG_ACK;
 	trans_hdr->window = niucv->msglimit;
@@ -2025,12 +2030,15 @@ static int afiucv_hs_callback_fin(struct
 	struct iucv_sock *iucv = iucv_sk(sk);
 
 	/* other end of connection closed */
-	if (iucv) {
-		bh_lock_sock(sk);
+	if (!iucv)
+		goto out;
+	bh_lock_sock(sk);
+	if (sk->sk_state == IUCV_CONNECTED) {
 		sk->sk_state = IUCV_DISCONN;
 		sk->sk_state_change(sk);
-		bh_unlock_sock(sk);
 	}
+	bh_unlock_sock(sk);
+out:
 	kfree_skb(skb);
 	return NET_RX_SUCCESS;
 }
@@ -2175,11 +2183,11 @@ static int afiucv_hs_rcv(struct sk_buff
 		break;
 	case (AF_IUCV_FLAG_WIN):
 		err = afiucv_hs_callback_win(sk, skb);
-		if (skb->len > sizeof(struct af_iucv_trans_hdr))
-			err = afiucv_hs_callback_rx(sk, skb);
-		else
-			kfree(skb);
-		break;
+		if (skb->len == sizeof(struct af_iucv_trans_hdr)) {
+			kfree_skb(skb);
+			break;
+		}
+		/* fall through */
 	case 0:
 		/* plain data frame */
 		memcpy(CB_TRGCLS(skb), &trans_hdr->iucv_hdr.class,
@@ -2205,65 +2213,64 @@ static void afiucv_hs_callback_txnotify(
 	struct iucv_sock *iucv = NULL;
 	struct sk_buff_head *list;
 	struct sk_buff *list_skb;
-	struct sk_buff *this = NULL;
+	struct sk_buff *nskb;
 	unsigned long flags;
 	struct hlist_node *node;
 
-	read_lock(&iucv_sk_list.lock);
+	read_lock_irqsave(&iucv_sk_list.lock, flags);
 	sk_for_each(sk, node, &iucv_sk_list.head)
 		if (sk == isk) {
 			iucv = iucv_sk(sk);
 			break;
 		}
-	read_unlock(&iucv_sk_list.lock);
+	read_unlock_irqrestore(&iucv_sk_list.lock, flags);
 
-	if (!iucv)
+	if (!iucv || sock_flag(sk, SOCK_ZAPPED))
 		return;
 
-	bh_lock_sock(sk);
 	list = &iucv->send_skb_q;
-	list_skb = list->next;
+	spin_lock_irqsave(&list->lock, flags);
 	if (skb_queue_empty(list))
 		goto out_unlock;
-
-	spin_lock_irqsave(&list->lock, flags);
+	list_skb = list->next;
+	nskb = list_skb->next;
 	while (list_skb != (struct sk_buff *)list) {
 		if (skb_shinfo(list_skb) == skb_shinfo(skb)) {
-			this = list_skb;
 			switch (n) {
 			case TX_NOTIFY_OK:
-				__skb_unlink(this, list);
+				__skb_unlink(list_skb, list);
+				kfree_skb(list_skb);
 				iucv_sock_wake_msglim(sk);
-				dev_put(this->dev);
-				kfree_skb(this);
 				break;
 			case TX_NOTIFY_PENDING:
 				atomic_inc(&iucv->pendings);
 				break;
 			case TX_NOTIFY_DELAYED_OK:
-				__skb_unlink(this, list);
+				__skb_unlink(list_skb, list);
 				atomic_dec(&iucv->pendings);
 				if (atomic_read(&iucv->pendings) <= 0)
 					iucv_sock_wake_msglim(sk);
-				dev_put(this->dev);
-				kfree_skb(this);
+				kfree_skb(list_skb);
 				break;
 			case TX_NOTIFY_UNREACHABLE:
 			case TX_NOTIFY_DELAYED_UNREACHABLE:
 			case TX_NOTIFY_TPQFULL: /* not yet used */
 			case TX_NOTIFY_GENERALERROR:
 			case TX_NOTIFY_DELAYED_GENERALERROR:
-				__skb_unlink(this, list);
-				dev_put(this->dev);
-				kfree_skb(this);
-				sk->sk_state = IUCV_DISCONN;
-				sk->sk_state_change(sk);
+				__skb_unlink(list_skb, list);
+				kfree_skb(list_skb);
+				if (sk->sk_state == IUCV_CONNECTED) {
+					sk->sk_state = IUCV_DISCONN;
+					sk->sk_state_change(sk);
+				}
 				break;
 			}
 			break;
 		}
-		list_skb = list_skb->next;
+		list_skb = nskb;
+		nskb = nskb->next;
 	}
+out_unlock:
 	spin_unlock_irqrestore(&list->lock, flags);
 
 	if (sk->sk_state == IUCV_CLOSING) {
@@ -2273,8 +2280,6 @@ static void afiucv_hs_callback_txnotify(
 		}
 	}
 
-out_unlock:
-	bh_unlock_sock(sk);
 }
 static const struct proto_ops iucv_sock_ops = {
 	.family		= PF_IUCV,
