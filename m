From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 4/7] net: Changes to ip_tunnel to support foo-over-udp encapsulation
Date: Sun, 14 Sep 2014 20:08:00 -0700
Message-ID: <1410750483-3236-5-git-send-email-therbert@google.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:65227 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbaIODIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 23:08:30 -0400
Received: by mail-pd0-f181.google.com with SMTP id w10so5280204pde.12
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2014 20:08:30 -0700 (PDT)
In-Reply-To: <1410750483-3236-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes IP tunnel to support (secondary) encapsulation,
Foo-over-UDP. Changes include:

1) Adding tun_hlen as the tunnel header length, encap_hlen as the
   encapsulation header length, and hlen becomes the grand total
   of these.
2) Added common netlink define to support FOU encapsulation.
3) Routines to perform FOU encapsulation.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip_tunnels.h       | 19 ++++++++-
 include/uapi/linux/if_tunnel.h | 12 ++++++
 net/ipv4/ip_tunnel.c           | 91 +++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 120 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 8dd8cab..7f538ba 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -10,6 +10,7 @@
 #include <net/gro_cells.h>
 #include <net/inet_ecn.h>
 #include <net/ip.h>
+#include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -31,6 +32,13 @@ struct ip_tunnel_6rd_parm {
 };
 #endif
 
+struct ip_tunnel_encap {
+	__u16			type;
+	__u16			flags;
+	__be16			sport;
+	__be16			dport;
+};
+
 struct ip_tunnel_prl_entry {
 	struct ip_tunnel_prl_entry __rcu *next;
 	__be32				addr;
@@ -56,13 +64,18 @@ struct ip_tunnel {
 	/* These four fields used only by GRE */
 	__u32		i_seqno;	/* The last seen seqno	*/
 	__u32		o_seqno;	/* The last output seqno */
-	int		hlen;		/* Precalculated header length */
+	int		tun_hlen;	/* Precalculated header length */
 	int		mlink;
 
 	struct ip_tunnel_dst __percpu *dst_cache;
 
 	struct ip_tunnel_parm parms;
 
+	int		encap_hlen;	/* Encap header length (FOU,GUE) */
+	struct ip_tunnel_encap encap;
+
+	int		hlen;		/* tun_hlen + encap_hlen */
+
 	/* for SIT */
 #ifdef CONFIG_IPV6_SIT_6RD
 	struct ip_tunnel_6rd_parm ip6rd;
@@ -114,6 +127,8 @@ void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops);
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		    const struct iphdr *tnl_params, const u8 protocol);
 int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd);
+int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
+		    u8 *protocol, struct flowi4 *fl4);
 int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu);
 
 struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
@@ -131,6 +146,8 @@ int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 		      struct ip_tunnel_parm *p);
 void ip_tunnel_setup(struct net_device *dev, int net_id);
 void ip_tunnel_dst_reset_all(struct ip_tunnel *t);
+int ip_tunnel_encap_setup(struct ip_tunnel *t,
+			  struct ip_tunnel_encap *ipencap);
 
 /* Extract dsfield from inner protocol */
 static inline u8 ip_tunnel_get_dsfield(const struct iphdr *iph,
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 3bce9e9..9fedca7 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -53,10 +53,22 @@ enum {
 	IFLA_IPTUN_6RD_RELAY_PREFIX,
 	IFLA_IPTUN_6RD_PREFIXLEN,
 	IFLA_IPTUN_6RD_RELAY_PREFIXLEN,
+	IFLA_IPTUN_ENCAP_TYPE,
+	IFLA_IPTUN_ENCAP_FLAGS,
+	IFLA_IPTUN_ENCAP_SPORT,
+	IFLA_IPTUN_ENCAP_DPORT,
 	__IFLA_IPTUN_MAX,
 };
 #define IFLA_IPTUN_MAX	(__IFLA_IPTUN_MAX - 1)
 
+enum tunnel_encap_types {
+	TUNNEL_ENCAP_NONE,
+	TUNNEL_ENCAP_FOU,
+};
+
+#define TUNNEL_ENCAP_FLAG_CSUM		(1<<0)
+#define TUNNEL_ENCAP_FLAG_CSUM6		(1<<1)
+
 /* SIT-mode i_flags */
 #define	SIT_ISATAP	0x0001
 
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index afed1aa..e3a3dc9 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -55,6 +55,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
+#include <net/udp.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -487,6 +488,91 @@ drop:
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_rcv);
 
+static int ip_encap_hlen(struct ip_tunnel_encap *e)
+{
+	switch (e->type) {
+	case TUNNEL_ENCAP_NONE:
+		return 0;
+	case TUNNEL_ENCAP_FOU:
+		return sizeof(struct udphdr);
+	default:
+		return -EINVAL;
+	}
+}
+
+int ip_tunnel_encap_setup(struct ip_tunnel *t,
+			  struct ip_tunnel_encap *ipencap)
+{
+	int hlen;
+
+	memset(&t->encap, 0, sizeof(t->encap));
+
+	hlen = ip_encap_hlen(ipencap);
+	if (hlen < 0)
+		return hlen;
+
+	t->encap.type = ipencap->type;
+	t->encap.sport = ipencap->sport;
+	t->encap.dport = ipencap->dport;
+	t->encap.flags = ipencap->flags;
+
+	t->encap_hlen = hlen;
+	t->hlen = t->encap_hlen + t->tun_hlen;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ip_tunnel_encap_setup);
+
+static int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+			    size_t hdr_len, u8 *protocol, struct flowi4 *fl4)
+{
+	struct udphdr *uh;
+	__be16 sport;
+	bool csum = !!(e->flags & TUNNEL_ENCAP_FLAG_CSUM);
+	int type = csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+
+	skb = iptunnel_handle_offloads(skb, csum, type);
+
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
+
+	/* Get length and hash before making space in skb */
+
+	sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
+					       skb, 0, 0, false);
+
+	skb_push(skb, hdr_len);
+
+	skb_reset_transport_header(skb);
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
+
+	return 0;
+}
+
+int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
+		    u8 *protocol, struct flowi4 *fl4)
+{
+	switch (t->encap.type) {
+	case TUNNEL_ENCAP_NONE:
+		return 0;
+	case TUNNEL_ENCAP_FOU:
+		return fou_build_header(skb, &t->encap, t->encap_hlen,
+					protocol, fl4);
+	default:
+		return -EINVAL;
+	}
+}
+EXPORT_SYMBOL(ip_tunnel_encap);
+
 static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 			    struct rtable *rt, __be16 df)
 {
@@ -536,7 +622,7 @@ static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 }
 
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
-		    const struct iphdr *tnl_params, const u8 protocol)
+		    const struct iphdr *tnl_params, u8 protocol)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr *inner_iph;
@@ -617,6 +703,9 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	init_tunnel_flow(&fl4, protocol, dst, tnl_params->saddr,
 			 tunnel->parms.o_key, RT_TOS(tos), tunnel->parms.link);
 
+	if (ip_tunnel_encap(skb, tunnel, &protocol, &fl4) < 0)
+		goto tx_error;
+
 	rt = connected ? tunnel_rtable_get(tunnel, 0, &fl4.saddr) : NULL;
 
 	if (!rt) {
-- 
2.1.0.rc2.206.gedb03e5
