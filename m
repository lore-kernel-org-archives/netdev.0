From: frank.blaschka@de.ibm.com
Subject: [patch 06/13] [PATCH] af_iucv: cleanup - use iucv_sk(sk) early
Date: Mon, 08 Aug 2011 13:33:52 +0200
Message-ID: <20110808113515.922754150@de.ibm.com>
References: <20110808113346.516293249@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:55187 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203Ab1HHLfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 07:35:31 -0400
Content-Disposition: inline; filename=net1117-af_iucv-cleanup-use-iucv_sk-early.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Code cleanup making make use of local variable for struct iucv_sock.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 net/iucv/af_iucv.c |   44 +++++++++++++++++++++++---------------------
 1 file changed, 23 insertions(+), 21 deletions(-)

--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -446,23 +446,25 @@ static void iucv_sock_init(struct sock *
 static struct sock *iucv_sock_alloc(struct socket *sock, int proto, gfp_t prio)
 {
 	struct sock *sk;
+	struct iucv_sock *iucv;
 
 	sk = sk_alloc(&init_net, PF_IUCV, prio, &iucv_proto);
 	if (!sk)
 		return NULL;
+	iucv = iucv_sk(sk);
 
 	sock_init_data(sock, sk);
-	INIT_LIST_HEAD(&iucv_sk(sk)->accept_q);
-	spin_lock_init(&iucv_sk(sk)->accept_q_lock);
-	skb_queue_head_init(&iucv_sk(sk)->send_skb_q);
-	INIT_LIST_HEAD(&iucv_sk(sk)->message_q.list);
-	spin_lock_init(&iucv_sk(sk)->message_q.lock);
-	skb_queue_head_init(&iucv_sk(sk)->backlog_skb_q);
-	iucv_sk(sk)->send_tag = 0;
-	iucv_sk(sk)->flags = 0;
-	iucv_sk(sk)->msglimit = IUCV_QUEUELEN_DEFAULT;
-	iucv_sk(sk)->path = NULL;
-	memset(&iucv_sk(sk)->src_user_id , 0, 32);
+	INIT_LIST_HEAD(&iucv->accept_q);
+	spin_lock_init(&iucv->accept_q_lock);
+	skb_queue_head_init(&iucv->send_skb_q);
+	INIT_LIST_HEAD(&iucv->message_q.list);
+	spin_lock_init(&iucv->message_q.lock);
+	skb_queue_head_init(&iucv->backlog_skb_q);
+	iucv->send_tag = 0;
+	iucv->flags = 0;
+	iucv->msglimit = IUCV_QUEUELEN_DEFAULT;
+	iucv->path = NULL;
+	memset(&iucv->src_user_id , 0, 32);
 
 	sk->sk_destruct = iucv_sock_destruct;
 	sk->sk_sndtimeo = IUCV_CONN_TIMEOUT;
@@ -669,7 +671,7 @@ static int iucv_sock_connect(struct sock
 {
 	struct sockaddr_iucv *sa = (struct sockaddr_iucv *) addr;
 	struct sock *sk = sock->sk;
-	struct iucv_sock *iucv;
+	struct iucv_sock *iucv = iucv_sk(sk);
 	unsigned char user_data[16];
 	int err;
 
@@ -691,14 +693,13 @@ static int iucv_sock_connect(struct sock
 	lock_sock(sk);
 
 	/* Set the destination information */
-	memcpy(iucv_sk(sk)->dst_user_id, sa->siucv_user_id, 8);
-	memcpy(iucv_sk(sk)->dst_name, sa->siucv_name, 8);
+	memcpy(iucv->dst_user_id, sa->siucv_user_id, 8);
+	memcpy(iucv->dst_name, sa->siucv_name, 8);
 
 	high_nmcpy(user_data, sa->siucv_name);
-	low_nmcpy(user_data, iucv_sk(sk)->src_name);
+	low_nmcpy(user_data, iucv->src_name);
 	ASCEBC(user_data, sizeof(user_data));
 
-	iucv = iucv_sk(sk);
 	/* Create path. */
 	iucv->path = iucv_path_alloc(iucv->msglimit,
 				     IUCV_IPRMDATA, GFP_KERNEL);
@@ -836,20 +837,21 @@ static int iucv_sock_getname(struct sock
 {
 	struct sockaddr_iucv *siucv = (struct sockaddr_iucv *) addr;
 	struct sock *sk = sock->sk;
+	struct iucv_sock *iucv = iucv_sk(sk);
 
 	addr->sa_family = AF_IUCV;
 	*len = sizeof(struct sockaddr_iucv);
 
 	if (peer) {
-		memcpy(siucv->siucv_user_id, iucv_sk(sk)->dst_user_id, 8);
-		memcpy(siucv->siucv_name, &iucv_sk(sk)->dst_name, 8);
+		memcpy(siucv->siucv_user_id, iucv->dst_user_id, 8);
+		memcpy(siucv->siucv_name, iucv->dst_name, 8);
 	} else {
-		memcpy(siucv->siucv_user_id, iucv_sk(sk)->src_user_id, 8);
-		memcpy(siucv->siucv_name, iucv_sk(sk)->src_name, 8);
+		memcpy(siucv->siucv_user_id, iucv->src_user_id, 8);
+		memcpy(siucv->siucv_name, iucv->src_name, 8);
 	}
 	memset(&siucv->siucv_port, 0, sizeof(siucv->siucv_port));
 	memset(&siucv->siucv_addr, 0, sizeof(siucv->siucv_addr));
-	memset(siucv->siucv_nodeid, 0, sizeof(siucv->siucv_nodeid));
+	memset(&siucv->siucv_nodeid, 0, sizeof(siucv->siucv_nodeid));
 
 	return 0;
 }

