From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 1/7] net: Move fou_build_header into fou.c and refactor
Date: Tue,  4 Nov 2014 09:06:51 -0800
Message-ID: <1415120817-2105-2-git-send-email-therbert@google.com>
References: <1415120817-2105-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:49857 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261AbaKDRHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:07:24 -0500
Received: by mail-ie0-f173.google.com with SMTP id tr6so7943960ieb.32
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:07:23 -0800 (PST)
In-Reply-To: <1415120817-2105-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move fou_build_header out of ip_tunnel.c and into fou.c splitting
it up into fou_build_header, gue_build_header, and fou_build_udp.
This allows for other users for TX of FOU or GUE. Change ip_tunnel_encap
to call fou_build_header or gue_build_header based on the tunnel
encapsulation type. Similarly, added fou_encap_hlen and gue_encap_hlen
functions which are called by ip_encap_hlen. New net/fou.h has
prototypes and defines for this.

Added NET_FOU_IP_TUNNELS configuration. When this is set, IP tunnels
can use FOU/GUE and fou module is also selected.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/fou.h    | 26 +++++++++++++++++++
 net/ipv4/Kconfig     |  9 +++++++
 net/ipv4/fou.c       | 73 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ip_tunnel.c | 61 +++++++++----------------------------------
 4 files changed, 120 insertions(+), 49 deletions(-)
 create mode 100644 include/net/fou.h

diff --git a/include/net/fou.h b/include/net/fou.h
new file mode 100644
index 0000000..cf4ce88
--- /dev/null
+++ b/include/net/fou.h
@@ -0,0 +1,26 @@
+#ifndef __NET_FOU_H
+#define __NET_FOU_H
+
+#include <linux/skbuff.h>
+
+#include <net/flow.h>
+#include <net/gue.h>
+#include <net/ip_tunnels.h>
+#include <net/udp.h>
+
+int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+		     u8 *protocol, struct flowi4 *fl4);
+int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+		     u8 *protocol, struct flowi4 *fl4);
+
+static size_t fou_encap_hlen(struct ip_tunnel_encap *e)
+{
+	return sizeof(struct udphdr);
+}
+
+static size_t gue_encap_hlen(struct ip_tunnel_encap *e)
+{
+	return sizeof(struct udphdr) + sizeof(struct guehdr);
+}
+
+#endif
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index e682b48..bd29016 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -322,6 +322,15 @@ config NET_FOU
 	  network mechanisms and optimizations for UDP (such as ECMP
 	  and RSS) can be leveraged to provide better service.
 
+config NET_FOU_IP_TUNNELS
+	bool "IP: FOU encapsulation of IP tunnels"
+	depends on NET_IPIP || NET_IPGRE || IPV6_SIT
+	select NET_FOU
+	---help---
+	  Allow configuration of FOU or GUE encapsulation for IP tunnels.
+	  When this option is enabled IP tunnels can be configured to use
+	  FOU or GUE encapsulation.
+
 config GENEVE
 	tristate "Generic Network Virtualization Encapsulation (Geneve)"
 	depends on INET
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 32e7892..5446c1c 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -487,6 +487,79 @@ static const struct genl_ops fou_nl_ops[] = {
 	},
 };
 
+static void fou_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
+			  struct flowi4 *fl4, u8 *protocol, __be16 sport)
+{
+	struct udphdr *uh;
+
+	skb_push(skb, sizeof(struct udphdr));
+	skb_reset_transport_header(skb);
+
+	uh = udp_hdr(skb);
+
+	uh->dest = e->dport;
+	uh->source = sport;
+	uh->len = htons(skb->len);
+	uh->check = 0;
+	udp_set_csum(!(e->flags & TUNNEL_ENCAP_FLAG_CSUM), skb,
+		     fl4->saddr, fl4->daddr, skb->len);
+
+	*protocol = IPPROTO_UDP;
+}
+
+int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+		     u8 *protocol, struct flowi4 *fl4)
+{
+	bool csum = !!(e->flags & TUNNEL_ENCAP_FLAG_CSUM);
+	int type = csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+	__be16 sport;
+
+	skb = iptunnel_handle_offloads(skb, csum, type);
+
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
+
+	sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
+					       skb, 0, 0, false);
+	fou_build_udp(skb, e, fl4, protocol, sport);
+
+	return 0;
+}
+EXPORT_SYMBOL(fou_build_header);
+
+int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+		     u8 *protocol, struct flowi4 *fl4)
+{
+	bool csum = !!(e->flags & TUNNEL_ENCAP_FLAG_CSUM);
+	int type = csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+	struct guehdr *guehdr;
+	size_t hdr_len = sizeof(struct guehdr);
+	__be16 sport;
+
+	skb = iptunnel_handle_offloads(skb, csum, type);
+
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
+
+	/* Get source port (based on flow hash) before skb_push */
+	sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
+					       skb, 0, 0, false);
+
+	skb_push(skb, hdr_len);
+
+	guehdr = (struct guehdr *)skb->data;
+
+	guehdr->version = 0;
+	guehdr->hlen = 0;
+	guehdr->flags = 0;
+	guehdr->next_hdr = *protocol;
+
+	fou_build_udp(skb, e, fl4, protocol, sport);
+
+	return 0;
+}
+EXPORT_SYMBOL(gue_build_header);
+
 static int __init fou_init(void)
 {
 	int ret;
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 0bb8e14..c3587e1 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -56,7 +56,10 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/udp.h>
-#include <net/gue.h>
+
+#if IS_ENABLED(CONFIG_NET_FOU)
+#include <net/fou.h>
+#endif
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -494,10 +497,12 @@ static int ip_encap_hlen(struct ip_tunnel_encap *e)
 	switch (e->type) {
 	case TUNNEL_ENCAP_NONE:
 		return 0;
+#if IS_ENABLED(CONFIG_NET_FOU)
 	case TUNNEL_ENCAP_FOU:
-		return sizeof(struct udphdr);
+		return fou_encap_hlen(e);
 	case TUNNEL_ENCAP_GUE:
-		return sizeof(struct udphdr) + sizeof(struct guehdr);
+		return gue_encap_hlen(e);
+#endif
 	default:
 		return -EINVAL;
 	}
@@ -526,60 +531,18 @@ int ip_tunnel_encap_setup(struct ip_tunnel *t,
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_encap_setup);
 
-static int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-			    size_t hdr_len, u8 *protocol, struct flowi4 *fl4)
-{
-	struct udphdr *uh;
-	__be16 sport;
-	bool csum = !!(e->flags & TUNNEL_ENCAP_FLAG_CSUM);
-	int type = csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
-
-	skb = iptunnel_handle_offloads(skb, csum, type);
-
-	if (IS_ERR(skb))
-		return PTR_ERR(skb);
-
-	/* Get length and hash before making space in skb */
-
-	sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
-					       skb, 0, 0, false);
-
-	skb_push(skb, hdr_len);
-
-	skb_reset_transport_header(skb);
-	uh = udp_hdr(skb);
-
-	if (e->type == TUNNEL_ENCAP_GUE) {
-		struct guehdr *guehdr = (struct guehdr *)&uh[1];
-
-		guehdr->version = 0;
-		guehdr->hlen = 0;
-		guehdr->flags = 0;
-		guehdr->next_hdr = *protocol;
-	}
-
-	uh->dest = e->dport;
-	uh->source = sport;
-	uh->len = htons(skb->len);
-	uh->check = 0;
-	udp_set_csum(!(e->flags & TUNNEL_ENCAP_FLAG_CSUM), skb,
-		     fl4->saddr, fl4->daddr, skb->len);
-
-	*protocol = IPPROTO_UDP;
-
-	return 0;
-}
-
 int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
 		    u8 *protocol, struct flowi4 *fl4)
 {
 	switch (t->encap.type) {
 	case TUNNEL_ENCAP_NONE:
 		return 0;
+#if IS_ENABLED(CONFIG_NET_FOU)
 	case TUNNEL_ENCAP_FOU:
+		return fou_build_header(skb, &t->encap, protocol, fl4);
 	case TUNNEL_ENCAP_GUE:
-		return fou_build_header(skb, &t->encap, t->encap_hlen,
-					protocol, fl4);
+		return gue_build_header(skb, &t->encap, protocol, fl4);
+#endif
 	default:
 		return -EINVAL;
 	}
-- 
2.1.0.rc2.206.gedb03e5
