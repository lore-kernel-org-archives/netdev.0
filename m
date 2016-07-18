From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH 1/2] net/ipv4: Introduce IPSKB_FRAG_SEGS bit to inet_skb_parm.flags
Date: Mon, 18 Jul 2016 14:49:33 +0300
Message-ID: <1468842574-1243-2-git-send-email-shmulik.ladkani@gmail.com>
References: <1468842574-1243-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: shmulik.ladkani@ravellosystems.com,
	Eric Dumazet <edumazet@google.com>, shmulik.ladkani@gmail.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31911 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbcGRLup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 07:50:45 -0400
In-Reply-To: <1468842574-1243-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This flag indicates whether fragmentation of segments is allowed.

Formerly this policy was hardcoded according to IPSKB_FORWARDED (set by
either ip_forward or ipmr_forward).

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 include/net/ip.h      | 1 +
 net/ipv4/ip_forward.c | 2 +-
 net/ipv4/ip_output.c  | 6 ++++--
 net/ipv4/ipmr.c       | 2 +-
 4 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 08f36cd..9742b92 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -47,6 +47,7 @@ struct inet_skb_parm {
 #define IPSKB_REROUTED		BIT(4)
 #define IPSKB_DOREDIRECT	BIT(5)
 #define IPSKB_FRAG_PMTU		BIT(6)
+#define IPSKB_FRAG_SEGS		BIT(7)
 
 	u16			frag_max_size;
 };
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 9f0a7b9..8b4ffd2 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -117,7 +117,7 @@ int ip_forward(struct sk_buff *skb)
 	if (opt->is_strictroute && rt->rt_uses_gateway)
 		goto sr_failed;
 
-	IPCB(skb)->flags |= IPSKB_FORWARDED;
+	IPCB(skb)->flags |= IPSKB_FORWARDED | IPSKB_FRAG_SEGS;
 	mtu = ip_dst_mtu_maybe_forward(&rt->dst, true);
 	if (ip_exceeds_mtu(skb, mtu)) {
 		IP_INC_STATS(net, IPSTATS_MIB_FRAGFAILS);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e23f141..dde37fb 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -223,8 +223,10 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 	struct sk_buff *segs;
 	int ret = 0;
 
-	/* common case: locally created skb or seglen is <= mtu */
-	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
+	/* common case: fragmentation of segments is not allowed,
+	 * or seglen is <= mtu
+	 */
+	if (((IPCB(skb)->flags & IPSKB_FRAG_SEGS) == 0) ||
 	      skb_gso_validate_mtu(skb, mtu))
 		return ip_finish_output2(net, sk, skb);
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index e0d76f5..eec2341 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1749,7 +1749,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 		vif->dev->stats.tx_bytes += skb->len;
 	}
 
-	IPCB(skb)->flags |= IPSKB_FORWARDED;
+	IPCB(skb)->flags |= IPSKB_FORWARDED | IPSKB_FRAG_SEGS;
 
 	/* RFC1584 teaches, that DVMRP/PIM router must deliver packets locally
 	 * not only before forwarding, but after forwarding on all output
-- 
1.9.1
