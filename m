From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 11/11] udp: dst lookup in early demux for unconnected sockets
Date: Tue, 26 Sep 2017 22:18:53 +0200
Message-ID: <accc6eb9b572f7f595deaca91a0c8f95a5144916.1506114055.git.pabeni@redhat.com>
References: <cover.1506114055.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53394 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935846AbdIZUTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 16:19:09 -0400
In-Reply-To: <cover.1506114055.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that all the helper are in place we can leverage them to
fetch the appropriate destination for unconnected sockets,
looking up the ifaddr cache if not local bind are not allowed.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 10 ++++++++--
 net/ipv6/udp.c |  9 ++++++++-
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b7202a15f360..87d48101efe2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2259,9 +2259,15 @@ int udp_v4_early_demux(struct sk_buff *skb)
 		return 0;
 
 	skb_set_noref_sk(skb, sk);
-	if (udp_use_rx_dst_cache(sk, skb))
+	if (udp_use_rx_dst_cache(sk, skb)) {
 		udp_set_skb_rx_dst(sk, skb, 0);
-	return 0;
+		return 0;
+	}
+
+	if (net->ipv4.sysctl_ip_nonlocal_bind)
+		return 0;
+
+	return ip_route_try_local_rcu(net, skb, iph);
 }
 
 int udp_rcv(struct sk_buff *skb)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 67d340679c3a..360d54bc2359 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -935,8 +935,15 @@ static void udp_v6_early_demux(struct sk_buff *skb)
 		return;
 
 	skb_set_noref_sk(skb, sk);
-	if (udp6_use_rx_dst_cache(sk))
+	if (udp6_use_rx_dst_cache(sk)) {
 		udp_set_skb_rx_dst(sk, skb, inet6_sk(sk)->rx_dst_cookie);
+		return;
+	}
+
+	if (net->ipv6.sysctl.ip_nonlocal_bind)
+		return;
+
+	ip6_route_try_local_rcu_bh(net, skb);
 }
 
 static __inline__ int udpv6_rcv(struct sk_buff *skb)
-- 
2.13.5
