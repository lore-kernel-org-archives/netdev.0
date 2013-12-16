From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/4 v3] net: Add utility functions to clear rxhash
Date: Sun, 15 Dec 2013 22:12:18 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312152208460.20838@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:45273 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336Ab3LPGMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 01:12:19 -0500
Received: by mail-oa0-f73.google.com with SMTP id i4so867990oah.0
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 22:12:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In several places 'skb->rxhash = 0' is being done to clear the
rxhash value in an skb.  This does not clear l4_rxhash which could
still be set so that the rxhash wouldn't be recalculated on subsequent
call to skb_get_rxhash.  This patch adds an explict function to clear
all the rxhash related information in the skb properly.

skb_clear_hash_if_not_l4 clears the rxhash only if it is not marked as
l4_rxhash.

Fixed up places where 'skb->rxhash = 0' was being called.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h    | 12 ++++++++++++
 include/net/dst.h         |  5 ++---
 net/ipv4/ip_fragment.c    |  2 +-
 net/ipv4/ip_tunnel_core.c |  5 ++---
 net/openvswitch/actions.c | 10 +++++-----
 5 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4725b95..7deb7ad 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -712,6 +712,18 @@ static inline __u32 skb_get_hash(struct sk_buff *skb)
 	return skb->rxhash;
 }
 
+static inline void skb_clear_hash(struct sk_buff *skb)
+{
+	skb->rxhash = 0;
+	skb->l4_rxhash = 0;
+}
+
+static inline void skb_clear_hash_if_not_l4(struct sk_buff *skb)
+{
+	if (!skb->l4_rxhash)
+		skb_clear_hash(skb);
+}
+
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 static inline unsigned char *skb_end_pointer(const struct sk_buff *skb)
 {
diff --git a/include/net/dst.h b/include/net/dst.h
index 44995c1..77eb53f 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -322,12 +322,11 @@ static inline void __skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev,
 	skb->dev = dev;
 
 	/*
-	 * Clear rxhash so that we can recalulate the hash for the
+	 * Clear hash so that we can recalulate the hash for the
 	 * encapsulated packet, unless we have already determine the hash
 	 * over the L4 4-tuple.
 	 */
-	if (!skb->l4_rxhash)
-		skb->rxhash = 0;
+	skb_clear_hash_if_not_l4(skb);
 	skb_set_queue_mapping(skb, 0);
 	skb_scrub_packet(skb, !net_eq(net, dev_net(dev)));
 }
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 2481993..c10a3ce 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -704,7 +704,7 @@ struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
 			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
 			if (ip_defrag(skb, user))
 				return NULL;
-			skb->rxhash = 0;
+			skb_clear_hash(skb);
 		}
 	}
 	return skb;
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 42ffbc8..6156f4e 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -56,7 +56,7 @@ int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
 
 	skb_scrub_packet(skb, xnet);
 
-	skb->rxhash = 0;
+	skb_clear_hash(skb);
 	skb_dst_set(skb, &rt->dst);
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
@@ -107,8 +107,7 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto)
 
 	nf_reset(skb);
 	secpath_reset(skb);
-	if (!skb->l4_rxhash)
-		skb->rxhash = 0;
+	skb_clear_hash_if_not_l4(skb);
 	skb_dst_drop(skb);
 	skb->vlan_tci = 0;
 	skb_set_queue_mapping(skb, 0);
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 65cfaa8..716b7ee 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -165,7 +165,7 @@ static void set_ip_addr(struct sk_buff *skb, struct iphdr *nh,
 	}
 
 	csum_replace4(&nh->check, *addr, new_addr);
-	skb->rxhash = 0;
+	skb_clear_hash(skb);
 	*addr = new_addr;
 }
 
@@ -199,7 +199,7 @@ static void set_ipv6_addr(struct sk_buff *skb, u8 l4_proto,
 	if (recalculate_csum)
 		update_ipv6_checksum(skb, l4_proto, addr, new_addr);
 
-	skb->rxhash = 0;
+	skb_clear_hash(skb);
 	memcpy(addr, new_addr, sizeof(__be32[4]));
 }
 
@@ -296,7 +296,7 @@ static void set_tp_port(struct sk_buff *skb, __be16 *port,
 {
 	inet_proto_csum_replace2(check, skb, *port, new_port, 0);
 	*port = new_port;
-	skb->rxhash = 0;
+	skb_clear_hash(skb);
 }
 
 static void set_udp_port(struct sk_buff *skb, __be16 *port, __be16 new_port)
@@ -310,7 +310,7 @@ static void set_udp_port(struct sk_buff *skb, __be16 *port, __be16 new_port)
 			uh->check = CSUM_MANGLED_0;
 	} else {
 		*port = new_port;
-		skb->rxhash = 0;
+		skb_clear_hash(skb);
 	}
 }
 
@@ -381,7 +381,7 @@ static int set_sctp(struct sk_buff *skb,
 		/* Carry any checksum errors through. */
 		sh->checksum = old_csum ^ old_correct_csum ^ new_csum;
 
-		skb->rxhash = 0;
+		skb_clear_hash(skb);
 	}
 
 	return 0;
-- 
1.8.5.1
