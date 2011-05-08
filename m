From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/15] l2tp: Fix locking in l2tp_ip.c
Date: Sun, 08 May 2011 15:37:25 -0700 (PDT)
Message-ID: <20110508.153725.189722608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42635
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755647Ab1EHWh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:37:57 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3325324C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Both l2tp_ip_connect() and l2tp_ip_sendmsg() must take the socket
lock.  They both modify socket state non-atomically, and in particular
l2tp_ip_sendmsg() increments socket private counters without using
atomic operations.
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/l2tp/l2tp_ip.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 8189960..bd0cc0b 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -311,6 +311,8 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	if (lsa->l2tp_family != AF_INET)
 		goto out;
 
+	lock_sock(sk);
+
 	sk_dst_reset(sk);
 
 	oif = sk->sk_bound_dev_if;
@@ -356,6 +358,7 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 
 	rc = 0;
 out:
+	release_sock(sk);
 	return rc;
 }
 
@@ -420,18 +423,23 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	int connected = 0;
 	__be32 daddr;
 
+	lock_sock(sk);
+
+	rc = -ENOTCONN;
 	if (sock_flag(sk, SOCK_DEAD))
-		return -ENOTCONN;
+		goto out;
 
 	/* Get and verify the address. */
 	if (msg->msg_name) {
 		struct sockaddr_l2tpip *lip = (struct sockaddr_l2tpip *) msg->msg_name;
+		rc = -EINVAL;
 		if (msg->msg_namelen < sizeof(*lip))
-			return -EINVAL;
+			goto out;
 
 		if (lip->l2tp_family != AF_INET) {
+			rc = -EAFNOSUPPORT;
 			if (lip->l2tp_family != AF_UNSPEC)
-				return -EAFNOSUPPORT;
+				goto out;
 		}
 
 		daddr = lip->l2tp_addr.s_addr;
@@ -510,12 +518,15 @@ error:
 		lsa->tx_errors++;
 	}
 
+out:
+	release_sock(sk);
 	return rc;
 
 no_route:
 	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
-	return -EHOSTUNREACH;
+	rc = -EHOSTUNREACH;
+	goto out;
 }
 
 static int l2tp_ip_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-- 
1.7.5.1

