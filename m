From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/5] vxlan: move inner L2 header processing to a separate function
Date: Tue, 23 Feb 2016 18:02:56 +0100
Message-ID: <8a973ea536a1039073d8135539ca54a9ed36e73b.1456246786.git.jbenc@redhat.com>
References: <cover.1456246786.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49635 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858AbcBWRDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 12:03:09 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id A20C5C00070D
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 17:03:09 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-63.brq.redhat.com [10.40.204.63])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1NH36AF008009
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 12:03:09 -0500
In-Reply-To: <cover.1456246786.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code will be different for VXLAN-GPE, so move it to a separate
function. It will also make the rx path less spaghetti-like.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 49 +++++++++++++++++++++++++++++++++----------------
 1 file changed, 33 insertions(+), 16 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 656a303c0ac8..68a8f9f43e2a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1191,15 +1191,11 @@ out:
 	unparsed->vx_flags &= ~VXLAN_GBP_USED_BITS;
 }
 
-static void vxlan_rcv(struct vxlan_dev *vxlan, struct vxlan_sock *vs,
-		      struct sk_buff *skb, struct vxlan_metadata *md,
-		      struct metadata_dst *tun_dst)
+static bool vxlan_set_mac(struct vxlan_dev *vxlan,
+			  struct vxlan_sock *vs,
+			  struct sk_buff *skb)
 {
-	struct iphdr *oip = NULL;
-	struct ipv6hdr *oip6 = NULL;
-	struct pcpu_sw_netstats *stats;
 	union vxlan_addr saddr;
-	int err = 0;
 
 	skb_reset_mac_header(skb);
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
@@ -1207,30 +1203,51 @@ static void vxlan_rcv(struct vxlan_dev *vxlan, struct vxlan_sock *vs,
 
 	/* Ignore packet loops (and multicast echo) */
 	if (ether_addr_equal(eth_hdr(skb)->h_source, vxlan->dev->dev_addr))
-		goto drop;
+		return false;
 
 	/* Get data from the outer IP header */
 	if (vxlan_get_sk_family(vs) == AF_INET) {
-		oip = ip_hdr(skb);
-		saddr.sin.sin_addr.s_addr = oip->saddr;
+		saddr.sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
 		saddr.sa.sa_family = AF_INET;
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
-		oip6 = ipv6_hdr(skb);
-		saddr.sin6.sin6_addr = oip6->saddr;
+		saddr.sin6.sin6_addr = ipv6_hdr(skb)->saddr;
 		saddr.sa.sa_family = AF_INET6;
 #endif
 	}
 
+	if ((vxlan->flags & VXLAN_F_LEARN) &&
+	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source))
+		return false;
+
+	return true;
+}
+
+static void vxlan_rcv(struct vxlan_dev *vxlan, struct vxlan_sock *vs,
+		      struct sk_buff *skb, struct vxlan_metadata *md,
+		      struct metadata_dst *tun_dst)
+{
+	struct iphdr *oip = NULL;
+	struct ipv6hdr *oip6 = NULL;
+	struct pcpu_sw_netstats *stats;
+	int err = 0;
+
+	if (!vxlan_set_mac(vxlan, vs, skb))
+		goto drop;
+
+	/* Get data from the outer IP header */
+	if (vxlan_get_sk_family(vs) == AF_INET)
+		oip = ip_hdr(skb);
+#if IS_ENABLED(CONFIG_IPV6)
+	else
+		oip6 = ipv6_hdr(skb);
+#endif
+
 	if (tun_dst) {
 		skb_dst_set(skb, (struct dst_entry *)tun_dst);
 		tun_dst = NULL;
 	}
 
-	if ((vxlan->flags & VXLAN_F_LEARN) &&
-	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source))
-		goto drop;
-
 	skb_reset_network_header(skb);
 
 	if (oip6)
-- 
1.8.3.1
