From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] netfilter: tproxy: properly refcount tcp listeners
Date: Wed, 17 Aug 2016 09:56:46 -0700
Message-ID: <1471453006.29842.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <627722c51d9ce454dfaf1a79519ceb59@nuclearcat.com>
	 <1471448525.29842.1.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1471449871.29842.3.camel@edumazet-glaptop3.roam.corp.google.com>
	 <09c3ca74357572464b5ff280f1cd0ddc@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35326 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbcHQQ4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 12:56:51 -0400
In-Reply-To: <09c3ca74357572464b5ff280f1cd0ddc@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

inet_lookup_listener() and inet6_lookup_listener() no longer
take a reference on the found listener.

This minimal patch adds back the refcounting, but we might do
this differently in net-next later.

Fixes: 3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under synflood")
Reported-and-tested-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Note: bug added in 4.7, stable candidate.

 net/netfilter/xt_TPROXY.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 7f4414d26a66..663c4c3c9072 100644
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
