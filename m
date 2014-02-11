From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/3] net: GSO encapsulation for IP packets
Date: Tue, 11 Feb 2014 09:43:56 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1402110928030.7010@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ogerlitz@mellanox.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:54610 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbaBKRn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 12:43:58 -0500
Received: by mail-qa0-f73.google.com with SMTP id w5so1008509qac.2
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 09:43:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The UDP GSO code assume that only encapsulated packets are Ethernet
frames. This patch fixes that so that we can support IP protocol
encpasulation (GUE, GRE/UDP, etc.)

We overload the inner_protocol field in the skb to store either the
Ethertype or the IP protocol (latter is indicated by ip_encapsulation
bit). As far as I can tell this should not adversely affect preexiting
uses for inner_protocol.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h |  8 ++++++--
 net/core/skbuff.c      |  1 +
 net/ipv4/udp.c         | 12 +++++++++++-
 3 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 1f689e6..757ed39 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -512,7 +512,11 @@ struct sk_buff {
 	 * headers if needed
 	 */
 	__u8			encapsulation:1;
-	/* 6/8 bit hole (depending on ndisc_nodetype presence) */
+	/* skbuf encpasulates an IP packet, inner_protocol should be
+	 * interpreted as an IP protocol, encapsulation bit is also set
+	 */
+	__u8			ip_encapsulation:1;
+	/* 5/7 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
@@ -530,7 +534,7 @@ struct sk_buff {
 		__u32		reserved_tailroom;
 	};
 
-	__be16			inner_protocol;
+	__u16			inner_protocol;
 	__u16			inner_transport_header;
 	__u16			inner_network_header;
 	__u16			inner_mac_header;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8f519db..64c6190 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -687,6 +687,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->ooo_okay		= old->ooo_okay;
 	new->no_fcs		= old->no_fcs;
 	new->encapsulation	= old->encapsulation;
+	new->ip_encapsulation	= old->ip_encapsulation;
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 77bd16f..48d8cb2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2497,7 +2497,17 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
-	segs = skb_mac_gso_segment(skb, enc_features);
+
+	if (skb->ip_encapsulation) {
+		const struct net_offload *ops;
+		ops = rcu_dereference(inet_offloads[skb->inner_protocol]);
+		if (likely(ops && ops->callbacks.gso_segment))
+			segs = ops->callbacks.gso_segment(skb, enc_features);
+	} else {
+		skb->protocol = htons(ETH_P_TEB);
+		segs = skb_mac_gso_segment(skb, enc_features);
+	}
+
 	if (!segs || IS_ERR(segs)) {
 		skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
 				     mac_len);
-- 
1.9.0.rc1.175.g0b1dcb5
