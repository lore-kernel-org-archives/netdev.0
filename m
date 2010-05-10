From: kaber@trash.net
Subject: [PATCH 77/84] netfilter: bridge-netfilter: fix refragmenting IP traffic encapsulated in PPPoE traffic
Date: Mon, 10 May 2010 22:18:48 +0200
Message-ID: <1273522735-24672-78-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54509 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756950Ab0EJUT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:29 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bart De Schuymer <bdschuym@pandora.be>

The MTU for IP traffic encapsulated inside PPPoE traffic is smaller
than the MTU of the Ethernet device (1500). Connection tracking
gathers all IP packets and sometimes will refragment them in
ip_fragment(). We then need to subtract the length of the
encapsulating header from the mtu used in ip_fragment(). The check in
br_nf_dev_queue_xmit() which determines if ip_fragment() has to be
called is also updated for the PPPoE-encapsulated packets.
nf_bridge_copy_header() is also updated to make sure the PPPoE data
length field has the correct value.

Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter_bridge.h |    7 +++++++
 net/bridge/br_netfilter.c        |    2 +-
 net/ipv4/ip_output.c             |    4 ++++
 3 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index ea0e44b..0ddd161 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -68,6 +68,13 @@ static inline unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
 	}
 }
 
+static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
+{
+	if (unlikely(skb->nf_bridge->mask & BRNF_PPPoE))
+		return PPPOE_SES_HLEN;
+	return 0;
+}
+
 extern int br_handle_frame_finish(struct sk_buff *skb);
 /* Only used in br_device.c */
 static inline int br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 6b80ebc..93f80fe 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -745,7 +745,7 @@ static unsigned int br_nf_forward_arp(unsigned int hook, struct sk_buff *skb,
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
 	if (skb->nfct != NULL && skb->protocol == htons(ETH_P_IP) &&
-	    skb->len > skb->dev->mtu &&
+	    skb->len + nf_bridge_mtu_reduction(skb) > skb->dev->mtu &&
 	    !skb_is_gso(skb))
 		return ip_fragment(skb, br_dev_queue_push_xmit);
 	else
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index b0b2e30..d979710 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -469,6 +469,10 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 
 	hlen = iph->ihl * 4;
 	mtu = dst_mtu(&rt->u.dst) - hlen;	/* Size of data space */
+#ifdef CONFIG_BRIDGE_NETFILTER
+	if (skb->nf_bridge)
+		mtu -= nf_bridge_mtu_reduction(skb);
+#endif
 	IPCB(skb)->flags |= IPSKB_FRAG_COMPLETE;
 
 	/* When frag_list is given, use it. First, check its validity:
-- 
1.7.0.4

