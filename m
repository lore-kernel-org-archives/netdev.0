From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 03/10 net-next] l2tp: remove unused stats from l2tp_ip socket
Date: Mon, 30 Apr 2012 08:48:48 +0100
Message-ID: <1335772135-27910-4-git-send-email-jchapman@katalix.com>
References: <1335772135-27910-1-git-send-email-jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:53473 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752297Ab2D3Hs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 03:48:58 -0400
Received: from localhost.localdomain (jchapman.plus.com [80.229.30.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: james)
	by mail.katalix.com (Postfix) with ESMTPSA id 3ED23A62111
	for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 08:48:57 +0100 (BST)
In-Reply-To: <1335772135-27910-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The l2tp_ip socket currently maintains packet/byte stats in its
private socket structure. But these counters aren't exposed to
userspace and so serve no purpose. The counters were also
smp-unsafe. So this patch just gets rid of the stats.

While here, change a couple of internal __u32 variables to u32.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_ip.c |   32 ++++----------------------------
 1 files changed, 4 insertions(+), 28 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 5162592..adefe52 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -32,15 +32,8 @@ struct l2tp_ip_sock {
 	/* inet_sock has to be the first member of l2tp_ip_sock */
 	struct inet_sock	inet;
 
-	__u32			conn_id;
-	__u32			peer_conn_id;
-
-	__u64			tx_packets;
-	__u64			tx_bytes;
-	__u64			tx_errors;
-	__u64			rx_packets;
-	__u64			rx_bytes;
-	__u64			rx_errors;
+	u32			conn_id;
+	u32			peer_conn_id;
 };
 
 static DEFINE_RWLOCK(l2tp_ip_lock);
@@ -298,7 +291,6 @@ out_in_use:
 static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct sockaddr_l2tpip *lsa = (struct sockaddr_l2tpip *) uaddr;
-	struct inet_sock *inet = inet_sk(sk);
 	int rc;
 
 	if (addr_len < sizeof(*lsa))
@@ -374,7 +366,6 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 {
 	struct sk_buff *skb;
 	int rc;
-	struct l2tp_ip_sock *lsa = l2tp_ip_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct rtable *rt = NULL;
 	struct flowi4 *fl4;
@@ -473,14 +464,8 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	rcu_read_unlock();
 
 error:
-	/* Update stats */
-	if (rc >= 0) {
-		lsa->tx_packets++;
-		lsa->tx_bytes += len;
+	if (rc >= 0)
 		rc = len;
-	} else {
-		lsa->tx_errors++;
-	}
 
 out:
 	release_sock(sk);
@@ -498,7 +483,6 @@ static int l2tp_ip_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 			   size_t len, int noblock, int flags, int *addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	struct l2tp_ip_sock *lsk = l2tp_ip_sk(sk);
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
 	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
@@ -540,15 +524,7 @@ static int l2tp_ip_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 done:
 	skb_free_datagram(sk, skb);
 out:
-	if (err) {
-		lsk->rx_errors++;
-		return err;
-	}
-
-	lsk->rx_packets++;
-	lsk->rx_bytes += copied;
-
-	return copied;
+	return err ? err : copied;
 }
 
 static struct proto l2tp_ip_prot = {
-- 
1.7.0.4
