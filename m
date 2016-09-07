From: thomas.zeitlhofer+lkml@ze-it.at
Subject: [PATCH v2] vti: use right inner_mode for inbound inter address
 family policy checks
Date: Wed, 7 Sep 2016 20:40:38 +0200
Message-ID: <20160907184038.2neg44xtvlunlrmu@toau>
References: <20160904105713.3mqgszgqi7waxk5l@toau>
 <20160906111522.GG31137@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vie01a-dmta-pe01-2.mx.upcmail.net ([62.179.121.155]:43171 "EHLO
        vie01a-dmta-pe01-2.mx.upcmail.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751810AbcIGSkw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 14:40:52 -0400
Received: from [172.31.216.44] (helo=vie01a-pemc-psmtp-pe02)
        by vie01a-dmta-pe01.mx.upcmail.net with esmtp (Exim 4.87)
        (envelope-from <thomas.zeitlhofer+lkml@ze-it.at>)
        id 1bhhmD-0005LL-4Z
        for netdev@vger.kernel.org; Wed, 07 Sep 2016 20:40:49 +0200
Content-Disposition: inline
In-Reply-To: <20160906111522.GG31137@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of inter address family tunneling (IPv6 over vti4 or IPv4 over
vti6), the inbound policy checks in vti_rcv_cb() and vti6_rcv_cb() are
using the wrong address family. As a result, all inbound inter address
family traffic is dropped.

Use the xfrm_ip2inner_mode() helper, as done in xfrm_input() (i.e., also
increment LINUX_MIB_XFRMINSTATEMODEERROR in case of error), to select the
inner_mode that contains the right address family for the inbound policy
checks.

Signed-off-by: Thomas Zeitlhofer <thomas.zeitlhofer+lkml@ze-it.at>
---

Notes:
    v2: implement review comments from Steffen (thanks for the reply):
    
    	- return -EINVAL in case of error
    
    	- increment LINUX_MIB_XFRMINSTATEMODEERROR in case of error
    
    	  Just to point that out, in case there are arguments against it:
    	  this is done in the namespace of skb->dev and not in the
    	  t(unnel)?->net namespace.
    
    	and update the commit message accordingly.

 net/ipv4/ip_vti.c  | 15 ++++++++++++++-
 net/ipv6/ip6_vti.c | 15 ++++++++++++++-
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index a917903..c9957ed 100644
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
2.1.4
