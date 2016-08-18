From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6] netfilter: tproxy: properly refcount tcp listeners
Date: Thu, 18 Aug 2016 19:29:06 +0200
Message-ID: <1471541348-1538-5-git-send-email-pablo@netfilter.org>
References: <1471541348-1538-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1471541348-1538-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

inet_lookup_listener() and inet6_lookup_listener() no longer
take a reference on the found listener.

This minimal patch adds back the refcounting, but we might do
this differently in net-next later.

Fixes: 3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under synflood")
Reported-and-tested-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TPROXY.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 7f4414d..663c4c3 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -127,6 +127,8 @@ nf_tproxy_get_sock_v4(struct net *net, struct sk_buff *skb, void *hp,
 						    daddr, dport,
 						    in->ifindex);
 
+			if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
+				sk = NULL;
 			/* NOTE: we return listeners even if bound to
 			 * 0.0.0.0, those are filtered out in
 			 * xt_socket, since xt_TPROXY needs 0 bound
@@ -195,6 +197,8 @@ nf_tproxy_get_sock_v6(struct net *net, struct sk_buff *skb, int thoff, void *hp,
 						   daddr, ntohs(dport),
 						   in->ifindex);
 
+			if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
+				sk = NULL;
 			/* NOTE: we return listeners even if bound to
 			 * 0.0.0.0, those are filtered out in
 			 * xt_socket, since xt_TPROXY needs 0 bound
-- 
2.1.4

