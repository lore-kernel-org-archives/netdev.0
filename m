From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH net-next 1/2] net: More fine-grained support for
	encapsulated GSO features
Date: Tue, 23 Apr 2013 11:19:15 +0900
Message-ID: <1366683556-4956-2-git-send-email-horms@verge.net.au>
References: <1366683556-4956-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Joseph Gasparakis <joseph.gasparakis-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1366683556-4956-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

"net: Add support for hardware-offloaded encapsulation" introduced
the encapsulation field of struct skb, which when set provides hints
that GSO should handle an skb that encapsulates a packet.

This patch adds an encapsulation_features field which provides
a hint to dev dev_hard_start_xmit() that harware-offload encapsulation
features should be used. Previously this hint was provided by the
encapsulation field.

The other uses of the encapsulation field are left unchanged.

The two in-tree locations that set the encapsulation have been updated to
also set encapsulation_field.

The motivation for this is to provide support segmentation of GSO MPLS skbs.
This may be necessary when a non-MPLS GSO skb is turned into an MPLS GSO
skb by Open vSwtich and its MPLS push action.

In this case it  harware-offload encapsulation features should be used,
actually to be more exact software segmentation should be selected, but
other hints provided by the encapsulation field are not applicable.

Cc: Joseph Gasparakis <joseph.gasparakis-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 include/linux/skbuff.h | 9 ++++++++-
 net/core/dev.c         | 2 +-
 net/core/skbuff.c      | 1 +
 net/ipv4/gre.c         | 1 +
 net/ipv4/ipip.c        | 1 +
 5 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2e0ced1..d9ec1de 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -494,7 +494,14 @@ struct sk_buff {
 	 * headers if needed
 	 */
 	__u8			encapsulation:1;
-	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
+	/* Encapsulation protocol and NIC drivers should use
+	 * this flag to indicate to each other if the skb contains
+	 * encapsulated packet and GSO should use encapsulation features
+	 * instead of standard features for the netdev. This is typically
+	 * a subset of cases where skb->encapsulation is set.
+	 */
+	__u8			encapsulation_features:1;
+	/* 6/8 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #ifdef CONFIG_NET_DMA
diff --git a/net/core/dev.c b/net/core/dev.c
index 9e26b8d..53236c5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2498,7 +2498,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		 * hardware encapsulation features instead of standard
 		 * features for the netdev
 		 */
-		if (skb->encapsulation)
+		if (skb->encapsulation_features)
 			features &= dev->hw_enc_features;
 
 		if (netif_needs_gso(skb, features)) {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 898cf5c..f23d136 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -708,6 +708,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->l4_rxhash		= old->l4_rxhash;
 	new->no_fcs		= old->no_fcs;
 	new->encapsulation	= old->encapsulation;
+	new->encapsulation_features = old->encapsulation_features;
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index 0ae998b..8420f29 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -157,6 +157,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	}
 
 	skb->encapsulation = 0;
+	skb->encapsulation_features = 0;
 
 	if (unlikely(!pskb_may_pull(skb, ghl)))
 		goto out;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 77bfcce..a6db3c0 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -220,6 +220,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (likely(!skb->encapsulation)) {
 		skb_reset_inner_headers(skb);
 		skb->encapsulation = 1;
+		skb->encapsulation_features = 1;
 	}
 
 	ip_tunnel_xmit(skb, dev, tiph);
-- 
1.8.2.1
