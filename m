From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 2/5] l2tp: hold socket before dropping lock in
 l2tp_ip{,6}_recv()
Date: Mon, 28 Nov 2016 20:39:57 +0100
Message-ID: <7e2a79e6e3e72996a3c184e8259c993a7cbcc15b.1480360512.git.g.nault@alphalink.fr>
References: <cover.1480360512.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:48838 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753838AbcK1TkA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 14:40:00 -0500
Content-Disposition: inline
In-Reply-To: <cover.1480360512.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Socket must be held while under the protection of the l2tp lock; there
is no guarantee that sk remains valid after the read_unlock_bh() call.

Same issue for l2tp_ip and l2tp_ip6.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ip.c  | 11 ++++++-----
 net/l2tp/l2tp_ip6.c | 11 ++++++-----
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 1f57094..4d1c942 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -183,14 +183,15 @@ static int l2tp_ip_recv(struct sk_buff *skb)
 
 		read_lock_bh(&l2tp_ip_lock);
 		sk = __l2tp_ip_bind_lookup(net, iph->daddr, 0, tunnel_id);
+		if (!sk) {
+			read_unlock_bh(&l2tp_ip_lock);
+			goto discard;
+		}
+
+		sock_hold(sk);
 		read_unlock_bh(&l2tp_ip_lock);
 	}
 
-	if (sk == NULL)
-		goto discard;
-
-	sock_hold(sk);
-
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_put;
 
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index af9abff..e3fc778 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -198,14 +198,15 @@ static int l2tp_ip6_recv(struct sk_buff *skb)
 		read_lock_bh(&l2tp_ip6_lock);
 		sk = __l2tp_ip6_bind_lookup(net, &iph->daddr,
 					    0, tunnel_id);
+		if (!sk) {
+			read_unlock_bh(&l2tp_ip6_lock);
+			goto discard;
+		}
+
+		sock_hold(sk);
 		read_unlock_bh(&l2tp_ip6_lock);
 	}
 
-	if (sk == NULL)
-		goto discard;
-
-	sock_hold(sk);
-
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_put;
 
-- 
2.10.2
