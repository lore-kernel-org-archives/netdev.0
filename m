From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 04/11] netlink: add netlink_skb_set_owner_r()
Date: Mon, 20 Aug 2012 08:18:45 +0200
Message-ID: <1345443532-3707-5-git-send-email-kaber@trash.net>
References: <1345443532-3707-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florian.Westphal@Sophos.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345443532-3707-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For mmap'ed I/O a netlink specific skb destructor needs to be invoked after the
final kfree_skb() to clean up state. This doesn't work currently since the skb's
ownership is transfered to the receiving socket using skb_set_owner_r(), which
orphans the skb, thereby invoking the destructor prematurely.

Since netlink doesn't account skbs to the originating socket, there's no need
to orphan the skb. Add a netlink specific skb_set_owner_r() variant that does
not orphan the skb and use a netlink specific destructor to call sock_rfree().

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netlink/af_netlink.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 3233601..e2d0177 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -166,6 +166,20 @@ static void netlink_consume_callback(struct netlink_callback *cb)
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
@@ -855,7 +869,7 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 		}
 		return 1;
 	}
-	skb_set_owner_r(skb, sk);
+	netlink_skb_set_owner_r(skb, sk);
 	return 0;
 }
 
@@ -924,7 +938,7 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb)
 	ret = -ECONNREFUSED;
 	if (nlk->netlink_rcv != NULL) {
 		ret = skb->len;
-		skb_set_owner_r(skb, sk);
+		netlink_skb_set_owner_r(skb, sk);
 		nlk->netlink_rcv(skb);
 		consume_skb(skb);
 	} else {
-- 
1.7.7.6

