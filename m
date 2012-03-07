From: frank.blaschka@de.ibm.com
Subject: [patch 1/7] [PATCH] af_iucv: handle netdev events
Date: Wed, 07 Mar 2012 13:06:23 +0100
Message-ID: <20120307120707.612936917@de.ibm.com>
References: <20120307120622.922387262@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp18.uk.ibm.com ([195.75.94.114]:47218 "EHLO
	e06smtp18.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755602Ab2CGMHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 07:07:13 -0500
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 7 Mar 2012 12:07:11 -0000
Content-Disposition: inline; filename=605-af_iucv-netdev-events.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

In case of transport through HiperSockets the underlying network 
interface may switch to DOWN state or the underlying network device
may recover. In both cases the socket must change to IUCV_DISCONN
state. If the interface goes down, af_iucv has a chance to notify
its connection peer in addition.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 net/iucv/af_iucv.c |  106 +++++++++++++++++++++++++++++++----------------------
 1 file changed, 62 insertions(+), 44 deletions(-)

diff -urpN linux-2.6/net/iucv/af_iucv.c linux-2.6-patched/net/iucv/af_iucv.c
--- linux-2.6/net/iucv/af_iucv.c	2012-03-06 13:35:57.000000000 +0100
+++ linux-2.6-patched/net/iucv/af_iucv.c	2012-03-06 13:35:57.000000000 +0100
@@ -453,14 +453,28 @@ static void iucv_sever_path(struct sock
 	}
 }
 
+/* Send FIN through an IUCV socket for HIPER transport */
+static int iucv_send_ctrl(struct sock *sk, u8 flags)
+{
+	int err = 0;
+	int blen;
+	struct sk_buff *skb;
+
+	blen = sizeof(struct af_iucv_trans_hdr) + ETH_HLEN;
+	skb = sock_alloc_send_skb(sk, blen, 1, &err);
+	if (skb) {
+		skb_reserve(skb, blen);
+		err = afiucv_hs_send(NULL, sk, skb, flags);
+	}
+	return err;
+}
+
 /* Close an IUCV socket */
 static void iucv_sock_close(struct sock *sk)
 {
 	struct iucv_sock *iucv = iucv_sk(sk);
 	unsigned long timeo;
 	int err = 0;
-	int blen;
-	struct sk_buff *skb;
 
 	lock_sock(sk);
 
@@ -471,14 +485,7 @@ static void iucv_sock_close(struct sock
 
 	case IUCV_CONNECTED:
 		if (iucv->transport == AF_IUCV_TRANS_HIPER) {
-			/* send fin */
-			blen = sizeof(struct af_iucv_trans_hdr) + ETH_HLEN;
-			skb = sock_alloc_send_skb(sk, blen, 1, &err);
-			if (skb) {
-				skb_reserve(skb, blen);
-				err = afiucv_hs_send(NULL, sk, skb,
-						     AF_IUCV_FLAG_FIN);
-			}
+			err = iucv_send_ctrl(sk, AF_IUCV_FLAG_FIN);
 			sk->sk_state = IUCV_DISCONN;
 			sk->sk_state_change(sk);
 		}
@@ -782,26 +789,6 @@ static int iucv_sock_autobind(struct soc
 	return err;
 }
 
-static int afiucv_hs_connect(struct socket *sock)
-{
-	struct sock *sk = sock->sk;
-	struct sk_buff *skb;
-	int blen = sizeof(struct af_iucv_trans_hdr) + ETH_HLEN;
-	int err = 0;
-
-	/* send syn */
-	skb = sock_alloc_send_skb(sk, blen, 1, &err);
-	if (!skb) {
-		err = -ENOMEM;
-		goto done;
-	}
-	skb->dev = NULL;
-	skb_reserve(skb, blen);
-	err = afiucv_hs_send(NULL, sk, skb, AF_IUCV_FLAG_SYN);
-done:
-	return err;
-}
-
 static int afiucv_path_connect(struct socket *sock, struct sockaddr *addr)
 {
 	struct sockaddr_iucv *sa = (struct sockaddr_iucv *) addr;
@@ -882,7 +869,7 @@ static int iucv_sock_connect(struct sock
 	memcpy(iucv->dst_name, sa->siucv_name, 8);
 
 	if (iucv->transport == AF_IUCV_TRANS_HIPER)
-		err = afiucv_hs_connect(sock);
+		err = iucv_send_ctrl(sock->sk, AF_IUCV_FLAG_SYN);
 	else
 		err = afiucv_path_connect(sock, addr);
 	if (err)
@@ -1332,8 +1319,7 @@ static int iucv_sock_recvmsg(struct kioc
 	struct sock *sk = sock->sk;
 	struct iucv_sock *iucv = iucv_sk(sk);
 	unsigned int copied, rlen;
-	struct sk_buff *skb, *rskb, *cskb, *sskb;
-	int blen;
+	struct sk_buff *skb, *rskb, *cskb;
 	int err = 0;
 
 	if ((sk->sk_state == IUCV_DISCONN) &&
@@ -1422,15 +1408,7 @@ static int iucv_sock_recvmsg(struct kioc
 				iucv_process_message_q(sk);
 			if (atomic_read(&iucv->msg_recv) >=
 							iucv->msglimit / 2) {
-				/* send WIN to peer */
-				blen = sizeof(struct af_iucv_trans_hdr) +
-					ETH_HLEN;
-				sskb = sock_alloc_send_skb(sk, blen, 1, &err);
-				if (sskb) {
-					skb_reserve(sskb, blen);
-					err = afiucv_hs_send(NULL, sk, sskb,
-							     AF_IUCV_FLAG_WIN);
-				}
+				err = iucv_send_ctrl(sk, AF_IUCV_FLAG_WIN);
 				if (err) {
 					sk->sk_state = IUCV_DISCONN;
 					sk->sk_state_change(sk);
@@ -2289,6 +2267,44 @@ out_unlock:
 	}
 
 }
+
+/*
+ * afiucv_netdev_event: handle netdev notifier chain events
+ */
+static int afiucv_netdev_event(struct notifier_block *this,
+			       unsigned long event, void *ptr)
+{
+	struct net_device *event_dev = (struct net_device *)ptr;
+	struct hlist_node *node;
+	struct sock *sk;
+	struct iucv_sock *iucv;
+
+	switch (event) {
+	case NETDEV_REBOOT:
+	case NETDEV_GOING_DOWN:
+		sk_for_each(sk, node, &iucv_sk_list.head) {
+			iucv = iucv_sk(sk);
+			if ((iucv->hs_dev == event_dev) &&
+			    (sk->sk_state == IUCV_CONNECTED)) {
+				if (event == NETDEV_GOING_DOWN)
+					iucv_send_ctrl(sk, AF_IUCV_FLAG_FIN);
+				sk->sk_state = IUCV_DISCONN;
+				sk->sk_state_change(sk);
+			}
+		}
+		break;
+	case NETDEV_DOWN:
+	case NETDEV_UNREGISTER:
+	default:
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block afiucv_netdev_notifier = {
+	.notifier_call = afiucv_netdev_event,
+};
+
 static const struct proto_ops iucv_sock_ops = {
 	.family		= PF_IUCV,
 	.owner		= THIS_MODULE,
@@ -2388,7 +2404,8 @@ static int __init afiucv_init(void)
 		err = afiucv_iucv_init();
 		if (err)
 			goto out_sock;
-	}
+	} else
+		register_netdevice_notifier(&afiucv_netdev_notifier);
 	dev_add_pack(&iucv_packet_type);
 	return 0;
 
@@ -2409,7 +2426,8 @@ static void __exit afiucv_exit(void)
 		driver_unregister(&af_iucv_driver);
 		pr_iucv->iucv_unregister(&af_iucv_handler, 0);
 		symbol_put(iucv_if);
-	}
+	} else
+		unregister_netdevice_notifier(&afiucv_netdev_notifier);
 	dev_remove_pack(&iucv_packet_type);
 	sock_unregister(PF_IUCV);
 	proto_unregister(&iucv_proto);
