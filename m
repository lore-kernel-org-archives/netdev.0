From: Tom Herbert <therbert@google.com>
Subject: [PATCH 01/17] net: Add utility function to clear rxhash
Date: Mon, 25 Nov 2013 21:46:05 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252141350.23058@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f73.google.com ([209.85.160.73]:59060 "EHLO
	mail-pb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444Ab3KZFqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 00:46:07 -0500
Received: by mail-pb0-f73.google.com with SMTP id rq2so741144pbb.2
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 21:46:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In several places 'skb->rxhash = 0' is being done to clear the
rxhash value in an skb.  This does not clear l4_rxhash which could
still be set so that the rxhash wouldn't be recalculated on subsequent
call to skb_get_rxhash.  This patch adds an explict function to clear
all the rxhash related information in the skb properly.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h    |  6 ++++++
 net/ipv4/ip_fragment.c    |  2 +-
 net/ipv4/ip_tunnel_core.c |  4 ++--
 net/openvswitch/actions.c | 10 +++++-----
 4 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 215b5ea..76d3aa9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -712,6 +712,12 @@ static inline __u32 skb_get_rxhash(struct sk_buff *skb)
 	return skb->rxhash;
 }
 
+static inline void skb_clear_rxhash(struct sk_buff *skb)
+{
+	skb->rxhash = 0;
+	skb->l4_rxhash = 0;
+}
+
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 static inline unsigned char *skb_end_pointer(const struct sk_buff *skb)
 {
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 2481993..3bc1d0d 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -704,7 +704,7 @@ struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
 			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
 			if (ip_defrag(skb, user))
 				return NULL;
-			skb->rxhash = 0;
+			skb_clear_rxhash(skb);
 		}
 	}
 	return skb;
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 42ffbc8..2148c1d 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -56,7 +56,7 @@ int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
 
 	skb_scrub_packet(skb, xnet);
 
-	skb->rxhash = 0;
+	skb_clear_rxhash(skb);
 	skb_dst_set(skb, &rt->dst);
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
@@ -108,7 +108,7 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto)
 	nf_reset(skb);
 	secpath_reset(skb);
 	if (!skb->l4_rxhash)
-		skb->rxhash = 0;
+		skb_clear_rxhash(skb);
 	skb_dst_drop(skb);
 	skb->vlan_tci = 0;
 	skb_set_queue_mapping(skb, 0);
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 65cfaa8..ab0d925 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -165,7 +165,7 @@ static void set_ip_addr(struct sk_buff *skb, struct iphdr *nh,
 	}
 
 	csum_replace4(&nh->check, *addr, new_addr);
-	skb->rxhash = 0;
+	skb_clear_rxhash(skb);
 	*addr = new_addr;
 }
 
@@ -199,7 +199,7 @@ static void set_ipv6_addr(struct sk_buff *skb, u8 l4_proto,
 	if (recalculate_csum)
 		update_ipv6_checksum(skb, l4_proto, addr, new_addr);
 
-	skb->rxhash = 0;
+	skb_clear_rxhash(skb);
 	memcpy(addr, new_addr, sizeof(__be32[4]));
 }
 
@@ -296,7 +296,7 @@ static void set_tp_port(struct sk_buff *skb, __be16 *port,
 {
 	inet_proto_csum_replace2(check, skb, *port, new_port, 0);
 	*port = new_port;
-	skb->rxhash = 0;
+	skb_clear_rxhash(skb);
 }
 
 static void set_udp_port(struct sk_buff *skb, __be16 *port, __be16 new_port)
@@ -310,7 +310,7 @@ static void set_udp_port(struct sk_buff *skb, __be16 *port, __be16 new_port)
 			uh->check = CSUM_MANGLED_0;
 	} else {
 		*port = new_port;
-		skb->rxhash = 0;
+		skb_clear_rxhash(skb);
 	}
 }
 
@@ -381,7 +381,7 @@ static int set_sctp(struct sk_buff *skb,
 		/* Carry any checksum errors through. */
 		sh->checksum = old_csum ^ old_correct_csum ^ new_csum;
 
-		skb->rxhash = 0;
+		skb_clear_rxhash(skb);
 	}
 
 	return 0;
-- 
1.8.4.1
