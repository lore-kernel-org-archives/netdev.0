From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 05/14] netlink: add netlink_skb_set_owner_r()
Date: Wed, 17 Apr 2013 18:47:00 +0200
Message-ID: <1366217229-22705-6-git-send-email-kaber@trash.net>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60952 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936093Ab3DQQr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 12:47:26 -0400
In-Reply-To: <1366217229-22705-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For mmap'ed I/O a netlink specific skb destructor needs to be invoked
after the final kfree_skb() to clean up state. This doesn't work currently
since the skb's ownership is transfered to the receiving socket using
skb_set_owner_r(), which orphans the skb, thereby invoking the destructor
prematurely.

Since netlink doesn't account skbs to the originating socket, there's no
need to orphan the skb. Add a netlink specific skb_set_owner_r() variant
that does not orphan the skb and use a netlink specific destructor to
call sock_rfree().

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netlink/af_netlink.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 26779c2..58b9025 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -119,6 +119,20 @@ static void netlink_consume_callback(struct netlink_callback *cb)
 	kfree(cb);
 }
 
+static void netlink_skb_destructor(struct sk_buff *skb)
+{
+	sock_rfree(skb);
+}
+
+static void netlink_skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
+{
+	WARN_ON(skb->sk != NULL);
+	skb->sk = sk;
+	skb->destructor = netlink_skb_destructor;
+	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
+	sk_mem_charge(sk, skb->truesize);
+}
+
 static void netlink_sock_destruct(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -820,7 +834,7 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 		}
 		return 1;
 	}
-	skb_set_owner_r(skb, sk);
+	netlink_skb_set_owner_r(skb, sk);
 	return 0;
 }
 
@@ -890,7 +904,7 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 	ret = -ECONNREFUSED;
 	if (nlk->netlink_rcv != NULL) {
 		ret = skb->len;
-		skb_set_owner_r(skb, sk);
+		netlink_skb_set_owner_r(skb, sk);
 		NETLINK_CB(skb).sk = ssk;
 		nlk->netlink_rcv(skb);
 		consume_skb(skb);
@@ -962,7 +976,7 @@ static int netlink_broadcast_deliver(struct sock *sk, struct sk_buff *skb)
 
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
 	    !test_bit(NETLINK_CONGESTED, &nlk->state)) {
-		skb_set_owner_r(skb, sk);
+		netlink_skb_set_owner_r(skb, sk);
 		__netlink_sendskb(sk, skb);
 		return atomic_read(&sk->sk_rmem_alloc) > (sk->sk_rcvbuf >> 1);
 	}
-- 
1.8.1.4
