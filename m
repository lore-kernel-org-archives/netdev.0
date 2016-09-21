From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/4] vti: use right inner_mode for inbound inter address family policy checks
Date: Wed, 21 Sep 2016 13:05:44 +0200
Message-ID: <1474455946-674-3-git-send-email-steffen.klassert@secunet.com>
References: <1474455946-674-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:38346 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756990AbcIULF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 07:05:57 -0400
In-Reply-To: <1474455946-674-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "thomas.zeitlhofer+lkml@ze-it.at" <thomas.zeitlhofer+lkml@ze-it.at>

In case of inter address family tunneling (IPv6 over vti4 or IPv4 over
vti6), the inbound policy checks in vti_rcv_cb() and vti6_rcv_cb() are
using the wrong address family. As a result, all inbound inter address
family traffic is dropped.

Use the xfrm_ip2inner_mode() helper, as done in xfrm_input() (i.e., also
increment LINUX_MIB_XFRMINSTATEMODEERROR in case of error), to select the
inner_mode that contains the right address family for the inbound policy
checks.

Signed-off-by: Thomas Zeitlhofer <thomas.zeitlhofer+lkml@ze-it.at>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_vti.c  | 15 ++++++++++++++-
 net/ipv6/ip6_vti.c | 15 ++++++++++++++-
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index cc701fa..5d7944f 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -88,6 +88,7 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
 	struct net_device *dev;
 	struct pcpu_sw_netstats *tstats;
 	struct xfrm_state *x;
+	struct xfrm_mode *inner_mode;
 	struct ip_tunnel *tunnel = XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4;
 	u32 orig_mark = skb->mark;
 	int ret;
@@ -105,7 +106,19 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
 	}
 
 	x = xfrm_input_state(skb);
-	family = x->inner_mode->afinfo->family;
+
+	inner_mode = x->inner_mode;
+
+	if (x->sel.family == AF_UNSPEC) {
+		inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
+		if (inner_mode == NULL) {
+			XFRM_INC_STATS(dev_net(skb->dev),
+				       LINUX_MIB_XFRMINSTATEMODEERROR);
+			return -EINVAL;
+		}
+	}
+
+	family = inner_mode->afinfo->family;
 
 	skb->mark = be32_to_cpu(tunnel->parms.i_key);
 	ret = xfrm_policy_check(NULL, XFRM_POLICY_IN, skb, family);
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index d90a11f..52a2f73 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -340,6 +340,7 @@ static int vti6_rcv_cb(struct sk_buff *skb, int err)
 	struct net_device *dev;
 	struct pcpu_sw_netstats *tstats;
 	struct xfrm_state *x;
+	struct xfrm_mode *inner_mode;
 	struct ip6_tnl *t = XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6;
 	u32 orig_mark = skb->mark;
 	int ret;
@@ -357,7 +358,19 @@ static int vti6_rcv_cb(struct sk_buff *skb, int err)
 	}
 
 	x = xfrm_input_state(skb);
-	family = x->inner_mode->afinfo->family;
+
+	inner_mode = x->inner_mode;
+
+	if (x->sel.family == AF_UNSPEC) {
+		inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
+		if (inner_mode == NULL) {
+			XFRM_INC_STATS(dev_net(skb->dev),
+				       LINUX_MIB_XFRMINSTATEMODEERROR);
+			return -EINVAL;
+		}
+	}
+
+	family = inner_mode->afinfo->family;
 
 	skb->mark = be32_to_cpu(t->parms.i_key);
 	ret = xfrm_policy_check(NULL, XFRM_POLICY_IN, skb, family);
-- 
1.9.1
