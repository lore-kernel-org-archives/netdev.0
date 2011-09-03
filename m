From: kaber@trash.net
Subject: [PATCH 05/11] netlink: add netlink_skb_set_owner_r()
Date: Sat,  3 Sep 2011 19:26:05 +0200
Message-ID: <1315070771-18576-6-git-send-email-kaber@trash.net>
References: <1315070771-18576-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56155 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298Ab1ICR0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 13:26:18 -0400
In-Reply-To: <1315070771-18576-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

For mmap'ed I/O a netlink specific skb destructor needs to be invoked after the
final kfree_skb() to clean up state in the memory mapped frames. This doesn
t work currently since the skb's ownership is transfered to the receiving
socket using skb_set_owner_r(), which orphans the skb, thereby invoking the
destructor prematurely.

Since netlink doesn't account skbs to the originating socket, there's no need
to orphan the skb. Add a netlink specific skb_set_owner_r() variant that does
not orphan the skb and use a netlink specific destructor to call sock_rfree().

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netlink/af_netlink.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7b9d7d0..1402acf 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -161,6 +161,20 @@ static void netlink_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	sk->sk_data_ready(sk, len);
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
@@ -838,7 +852,7 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 		}
 		return 1;
 	}
-	skb_set_owner_r(skb, sk);
+	netlink_skb_set_owner_r(skb, sk);
 	return 0;
 }
 
@@ -900,7 +914,7 @@ static inline int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb)
 	ret = -ECONNREFUSED;
 	if (nlk->netlink_rcv != NULL) {
 		ret = skb->len;
-		skb_set_owner_r(skb, sk);
+		netlink_skb_set_owner_r(skb, sk);
 		nlk->netlink_rcv(skb);
 	}
 	kfree_skb(skb);
-- 
1.7.4.4
