From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 7/7] ip_vti/ip6_vti: Preserve skb->mark after rcv_cb call
Date: Thu, 28 May 2015 09:28:10 +0200
Message-ID: <1432798090-20657-8-git-send-email-steffen.klassert@secunet.com>
References: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51241 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752804AbbE1H2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 03:28:31 -0400
In-Reply-To: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

The vti6_rcv_cb and vti_rcv_cb calls were leaving the skb->mark modified
after completing the function.  This resulted in the original skb->mark
value being lost.  Since we only need skb->mark to be set for
xfrm_policy_check we can pull the assignment into the rcv_cb calls and then
just restore the original mark after xfrm_policy_check has been completed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_vti.c  | 9 +++++++--
 net/ipv6/ip6_vti.c | 9 +++++++--
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 4c318e1..0c15208 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -65,7 +65,6 @@ static int vti_input(struct sk_buff *skb, int nexthdr, __be32 spi,
 			goto drop;
 
 		XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4 = tunnel;
-		skb->mark = be32_to_cpu(tunnel->parms.i_key);
 
 		return xfrm_input(skb, nexthdr, spi, encap_type);
 	}
@@ -91,6 +90,8 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
 	struct pcpu_sw_netstats *tstats;
 	struct xfrm_state *x;
 	struct ip_tunnel *tunnel = XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4;
+	u32 orig_mark = skb->mark;
+	int ret;
 
 	if (!tunnel)
 		return 1;
@@ -107,7 +108,11 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
 	x = xfrm_input_state(skb);
 	family = x->inner_mode->afinfo->family;
 
-	if (!xfrm_policy_check(NULL, XFRM_POLICY_IN, skb, family))
+	skb->mark = be32_to_cpu(tunnel->parms.i_key);
+	ret = xfrm_policy_check(NULL, XFRM_POLICY_IN, skb, family);
+	skb->mark = orig_mark;
+
+	if (!ret)
 		return -EPERM;
 
 	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(skb->dev)));
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 104de4d..ff3bd86 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -322,7 +322,6 @@ static int vti6_rcv(struct sk_buff *skb)
 		}
 
 		XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 = t;
-		skb->mark = be32_to_cpu(t->parms.i_key);
 
 		rcu_read_unlock();
 
@@ -342,6 +341,8 @@ static int vti6_rcv_cb(struct sk_buff *skb, int err)
 	struct pcpu_sw_netstats *tstats;
 	struct xfrm_state *x;
 	struct ip6_tnl *t = XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6;
+	u32 orig_mark = skb->mark;
+	int ret;
 
 	if (!t)
 		return 1;
@@ -358,7 +359,11 @@ static int vti6_rcv_cb(struct sk_buff *skb, int err)
 	x = xfrm_input_state(skb);
 	family = x->inner_mode->afinfo->family;
 
-	if (!xfrm_policy_check(NULL, XFRM_POLICY_IN, skb, family))
+	skb->mark = be32_to_cpu(t->parms.i_key);
+	ret = xfrm_policy_check(NULL, XFRM_POLICY_IN, skb, family);
+	skb->mark = orig_mark;
+
+	if (!ret)
 		return -EPERM;
 
 	skb_scrub_packet(skb, !net_eq(t->net, dev_net(skb->dev)));
-- 
1.9.1
