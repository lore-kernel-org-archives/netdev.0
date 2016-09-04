From: Thomas Zeitlhofer <thomas.zeitlhofer+lkml@ze-it.at>
Subject: [PATCH] vti: use right inner_mode for inbound inter address family
 policy checks
Date: Sun, 4 Sep 2016 12:57:13 +0200
Message-ID: <20160904105713.3mqgszgqi7waxk5l@toau>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vie01a-qmta-pe01-2.mx.upcmail.net ([62.179.121.179]:49911 "EHLO
        vie01a-qmta-pe01-2.mx.upcmail.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752758AbcIDLNH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2016 07:13:07 -0400
Received: from [172.31.218.36] (helo=vie01a-dmta-pe02-3.mx.upcmail.net)
        by vie01a-pqmta-pe01.mx.upcmail.net with esmtp (Exim 4.87)
        (envelope-from <thomas.zeitlhofer+lkml@ze-it.at>)
        id 1bgV72-0007TX-Ic
        for netdev@vger.kernel.org; Sun, 04 Sep 2016 12:57:20 +0200
Received: from [172.31.216.44] (helo=vie01a-pemc-psmtp-pe02)
        by vie01a-dmta-pe02.mx.upcmail.net with esmtp (Exim 4.87)
        (envelope-from <thomas.zeitlhofer+lkml@ze-it.at>)
        id 1bgV6z-0008HI-N5
        for netdev@vger.kernel.org; Sun, 04 Sep 2016 12:57:17 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of inter address family tunneling (IPv6 over vti4 or IPv4 over
vti6), the inbound policy checks in vti_rcv_cb and vti6_rcv_cb are using
the wrong address family. As a result, all inbound inter address family
traffic is dropped.

Use the xfrm_ip2inner_mode helper (as done in xfrm_prepare_input and
xfrm_input) to select the inner_mode that contains the right address family
for the inbound policy checks.

Signed-off-by: Thomas Zeitlhofer <thomas.zeitlhofer+lkml@ze-it.at>
---

Notes:
    The patch was developed by looking at the code, but without knowledge of
    the XFRM code in the kernel. It has been successfully tested, but it is
    more a guess that might be helpful for the maintainers to find a proper
    solution.

 net/ipv4/ip_vti.c  | 12 +++++++++++-
 net/ipv6/ip6_vti.c | 12 +++++++++++-
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index a917903..44d5449 100644
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
@@ -105,7 +106,16 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
 	}
 
 	x = xfrm_input_state(skb);
-	family = x->inner_mode->afinfo->family;
+
+	inner_mode = x->inner_mode;
+
+	if (x->sel.family == AF_UNSPEC) {
+		inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
+		if (inner_mode == NULL)
+			return -EPERM;
+	}
+
+	family = inner_mode->afinfo->family;
 
 	skb->mark = be32_to_cpu(tunnel->parms.i_key);
 	ret = xfrm_policy_check(NULL, XFRM_POLICY_IN, skb, family);
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index d90a11f..3149757 100644
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
@@ -357,7 +358,16 @@ static int vti6_rcv_cb(struct sk_buff *skb, int err)
 	}
 
 	x = xfrm_input_state(skb);
-	family = x->inner_mode->afinfo->family;
+
+	inner_mode = x->inner_mode;
+
+	if (x->sel.family == AF_UNSPEC) {
+		inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
+		if (inner_mode == NULL)
+			return -EPERM;
+	}
+
+	family = inner_mode->afinfo->family;
 
 	skb->mark = be32_to_cpu(t->parms.i_key);
 	ret = xfrm_policy_check(NULL, XFRM_POLICY_IN, skb, family);
-- 
2.1.4
