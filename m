From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH RFC 3/3] ip_vti/ip6_vti: Preserve skb->mark after
 rcv_cb call
Date: Tue, 26 May 2015 15:41:29 -0700
Message-ID: <20150526224129.1328.69180.stgit@ahduyck-vm-fedora22>
References: <20150526223849.1328.64212.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: steffen.klassert@secunet.com, davem@davemloft.net,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085AbbEZWla (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2015 18:41:30 -0400
In-Reply-To: <20150526223849.1328.64212.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vti6_rcv_cb and vti_rcv_cb calls were leaving the skb->mark modified
after completing the function.  This resulted in the original skb->mark
value being lost.  Since we only need skb->mark to be set for
xfrm_policy_check we can pull the assignment into the rcv_cb calls and then
just restore the original mark after xfrm_policy_check has been completed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/ip_vti.c  |    9 +++++++--
 net/ipv6/ip6_vti.c |    9 +++++++--
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 4c318e1c13c8..0c152087ca15 100644
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
index 104de4da3ff3..ff3bd863fa03 100644
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
