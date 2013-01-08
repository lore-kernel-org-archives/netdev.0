From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/5] GRE: Add segmentation offload for GRE TAP
	device.
Date: Mon,  7 Jan 2013 18:31:36 -0800
Message-ID: <1357612296-1715-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
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

From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 include/linux/skbuff.h |   12 ++++++
 include/net/gre.h      |    6 +++
 net/ipv4/af_inet.c     |    1 +
 net/ipv4/gre.c         |  101 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp.c         |    1 +
 net/ipv4/udp.c         |    3 +-
 net/ipv6/ip6_offload.c |    1 +
 net/ipv6/udp_offload.c |    3 +-
 8 files changed, 126 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 320e976..43033f0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -307,6 +307,8 @@ enum {
 	SKB_GSO_TCPV6 = 1 << 4,
 
 	SKB_GSO_FCOE = 1 << 5,
+
+	SKB_GSO_GRE = 1 << 6,
 };
 
 #if BITS_PER_LONG > 32
@@ -797,6 +799,16 @@ static inline int skb_cloned(const struct sk_buff *skb)
 	       (atomic_read(&skb_shinfo(skb)->dataref) & SKB_DATAREF_MASK) != 1;
 }
 
+static inline int skb_unclone(struct sk_buff *skb, gfp_t pri)
+{
+	might_sleep_if(pri & __GFP_WAIT);
+
+	if (skb_cloned(skb))
+		return pskb_expand_head(skb, 0, 0, pri);
+
+	return 0;
+}
+
 /**
  *	skb_header_cloned - is the header a clone
  *	@skb: buffer to check
diff --git a/include/net/gre.h b/include/net/gre.h
index 8266547..f7d5bfb 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -15,4 +15,10 @@ struct gre_protocol {
 int gre_add_protocol(const struct gre_protocol *proto, u8 version);
 int gre_del_protocol(const struct gre_protocol *proto, u8 version);
 
+struct gre_base_hdr {
+	__be16 flags;
+	__be16 protocol;
+};
+#define GRE_HEADER_SECTION 4
+
 #endif
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 24b384b..9a3d5d2 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1306,6 +1306,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_UDP |
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
+		       SKB_GSO_GRE |
 		       0)))
 		goto out;
 
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index 42a4910..0eaaf44 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -19,6 +19,7 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/netdevice.h>
+#include <linux/if_tunnel.h>
 #include <linux/spinlock.h>
 #include <net/protocol.h>
 #include <net/gre.h>
@@ -112,12 +113,105 @@ static void gre_err(struct sk_buff *skb, u32 info)
 	rcu_read_unlock();
 }
 
+static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
+				       netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct gre_base_hdr *greh;
+	unsigned char *mac = skb_mac_header(skb);
+	int net_hlen = skb_network_header_len(skb);
+	int ghl = GRE_HEADER_SECTION;
+	int mac_len;
+	int doffset;
+
+	if (unlikely(skb_shinfo(skb)->gso_type &
+				~(SKB_GSO_TCPV4 |
+					SKB_GSO_UDP |
+					SKB_GSO_DODGY |
+					SKB_GSO_TCP_ECN |
+					SKB_GSO_GRE |
+					0)))
+		goto out;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(*greh))))
+		goto out;
+
+	greh = (struct gre_base_hdr *)skb_transport_header(skb);
+
+	if (greh->flags & GRE_KEY)
+		ghl += GRE_HEADER_SECTION;
+	if (greh->flags & GRE_CSUM)
+		ghl += GRE_HEADER_SECTION;
+
+	if (unlikely(!pskb_may_pull(skb, ghl)))
+		goto out;
+
+	__skb_pull(skb, ghl);
+	skb_reset_mac_header(skb);
+	skb_set_network_header(skb, skb->mac_len);
+	doffset = skb_mac_header(skb) - mac;
+	/* segment inner packet. */
+	segs = skb_gso_segment(skb, 0);
+	if (!segs || IS_ERR(segs))
+		goto out;
+
+	mac_len = skb_inner_network_header(skb) - ((unsigned char *)greh + ghl);
+	skb = segs;
+	do {
+		unsigned char *smac;
+
+		skb_push(skb, doffset);
+
+		skb_reset_mac_header(skb);
+		skb_set_network_header(skb, mac_len);
+		skb_set_transport_header(skb,
+					 skb_network_offset(skb) + net_hlen);
+		smac = skb_mac_header(skb);
+		skb->mac_len = mac_len;
+		/* Copy entire outer header from original skb. */
+		memcpy(smac, mac, doffset);
+
+		greh = (struct gre_base_hdr *)skb_transport_header(skb);
+		if (greh->flags & GRE_CSUM) {
+			__be32 *gre_csum = (__be32 *)(greh + 1);
+			*gre_csum = 0;
+			*(__sum16 *)gre_csum = csum_fold(skb_checksum(skb,
+						skb_transport_offset(skb),
+						skb->len - skb_transport_offset(skb),
+						0));
+		}
+	} while ((skb = skb->next));
+
+out:
+	return segs;
+}
+
+static int gre_gso_send_check(struct sk_buff *skb)
+{
+	struct gre_base_hdr *greh;
+
+	if (!skb->encapsulation)
+		return -EINVAL;
+
+	greh = (struct gre_base_hdr *)skb_transport_header(skb);
+	if (greh->flags & GRE_SEQ)
+		return -EINVAL;
+	return 0;
+}
+
 static const struct net_protocol net_gre_protocol = {
 	.handler     = gre_rcv,
 	.err_handler = gre_err,
 	.netns_ok    = 1,
 };
 
+static const struct net_offload gre_offload = {
+	.callbacks = {
+		.gso_send_check =	gre_gso_send_check,
+		.gso_segment    =	gre_gso_segment,
+	},
+};
+
 static int __init gre_init(void)
 {
 	pr_info("GRE over IPv4 demultiplexor driver\n");
@@ -127,11 +221,18 @@ static int __init gre_init(void)
 		return -EAGAIN;
 	}
 
+	if (inet_add_offload(&gre_offload, IPPROTO_GRE)) {
+		pr_err("can't add protocol offload\n");
+		inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
+		return -EAGAIN;
+	}
+
 	return 0;
 }
 
 static void __exit gre_exit(void)
 {
+	inet_del_offload(&gre_offload, IPPROTO_GRE);
 	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
 }
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1ca2536..08d22e3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3025,6 +3025,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 			       SKB_GSO_DODGY |
 			       SKB_GSO_TCP_ECN |
 			       SKB_GSO_TCPV6 |
+			       SKB_GSO_GRE |
 			       0) ||
 			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
 			goto out;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 79c8dbe..c256008 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2279,7 +2279,8 @@ struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 		/* Packet is from an untrusted source, reset gso_segs. */
 		int type = skb_shinfo(skb)->gso_type;
 
-		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY) ||
+		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
+				      SKB_GSO_GRE) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
 
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index f26f0da..8234c1d 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -99,6 +99,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		     ~(SKB_GSO_UDP |
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
+		       SKB_GSO_GRE |
 		       SKB_GSO_TCPV6 |
 		       0)))
 		goto out;
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 0c8934a..cf05cf0 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -56,7 +56,8 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 		/* Packet is from an untrusted source, reset gso_segs. */
 		int type = skb_shinfo(skb)->gso_type;
 
-		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY) ||
+		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
+				      SKB_GSO_GRE) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
 
-- 
1.7.1
