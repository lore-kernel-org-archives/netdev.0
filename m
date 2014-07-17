From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 3/9] gue: Changes to ip_tunnel to support Generic
 UDP Encapsulation
Date: Wed, 16 Jul 2014 21:14:44 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407162055520.29792@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:45641 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686AbaGQEOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 00:14:45 -0400
Received: by mail-pa0-f73.google.com with SMTP id kx10so498239pab.2
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 21:14:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes IP tunnel to support (secondary) encapsulation,
Generic UDP Encapsulation. Changes include:

1) Adding tun_hlen as the tunnel header length, encap_hlen as the
encapsulation header length (GUE), and hlen becomes the grand total
of these.
2) Added generic function to handle IOCTLs
3) Added IOCTLs to setup or remove encapsulation. This includes
uapi to configure encapsulation on a tunnel.
4) Support to perform GUE encapsulation in ip_tunnel_xmit.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip_tunnels.h       |  23 ++++++-
 include/uapi/linux/if_tunnel.h |  20 ++++++
 net/ipv4/ip_tunnel.c           | 149 ++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 190 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index a4daf9e..e1a379c 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -10,6 +10,7 @@
 #include <net/gro_cells.h>
 #include <net/inet_ecn.h>
 #include <net/ip.h>
+#include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -55,13 +56,18 @@ struct ip_tunnel {
 	/* These four fields used only by GRE */
 	__u32		i_seqno;	/* The last seen seqno	*/
 	__u32		o_seqno;	/* The last output seqno */
-	int		hlen;		/* Precalculated header length */
+	int		tun_hlen;	/* Precalculated header length */
 	int		mlink;
 
 	struct ip_tunnel_dst __percpu *dst_cache;
 
 	struct ip_tunnel_parm parms;
 
+	int encap_hlen;			/* Encap header length (GUE) */
+	struct ip_tunnel_encap encap;
+
+	int		hlen;		/* tun_hlen + encap_hlen */
+
 	/* for SIT */
 #ifdef CONFIG_IPV6_SIT_6RD
 	struct ip_tunnel_6rd_parm ip6rd;
@@ -113,6 +119,21 @@ void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops);
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		    const struct iphdr *tnl_params, const u8 protocol);
 int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd);
+int __ip_tunnel_gen_ioctl(struct net_device *dev, struct net_device *tundev,
+			  struct ifreq *ifr, int cmd);
+int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
+		    u8 *protocol, struct flowi4 *fl4);
+
+static inline int ip_tunnel_gen_ioctl(struct net_device *dev,
+				      struct ifreq *ifr, int cmd)
+{
+	struct net *net = dev_net(dev);
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct ip_tunnel_net *itn = net_generic(net, tunnel->ip_tnl_net_id);
+
+	return __ip_tunnel_gen_ioctl(dev, itn->fb_tunnel_dev, ifr, cmd);
+}
+
 int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu);
 
 struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 3bce9e9..30a8495 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -17,6 +17,10 @@
 #define SIOCADD6RD      (SIOCDEVPRIVATE + 9)
 #define SIOCDEL6RD      (SIOCDEVPRIVATE + 10)
 #define SIOCCHG6RD      (SIOCDEVPRIVATE + 11)
+#define SIOCGETTUNENCAP (SIOCDEVPRIVATE + 12)
+#define SIOCADDTUNENCAP (SIOCDEVPRIVATE + 13)
+#define SIOCDELTUNENCAP (SIOCDEVPRIVATE + 14)
+#define SIOCCHGTUNENCAP (SIOCDEVPRIVATE + 15)
 
 #define GRE_CSUM	__cpu_to_be16(0x8000)
 #define GRE_ROUTING	__cpu_to_be16(0x4000)
@@ -57,6 +61,22 @@ enum {
 };
 #define IFLA_IPTUN_MAX	(__IFLA_IPTUN_MAX - 1)
 
+enum tunnel_encap_types {
+	TUNNEL_ENCAP_NONE,
+	TUNNEL_ENCAP_GUE_DIRECT,
+};
+
+#define TUNNEL_ENCAP_FLAG_CSUM	(1<<0)
+#define TUNNEL_ENCAP_FLAG_CSUM6	(1<<1)
+
+struct ip_tunnel_encap {
+	int			type;
+	__u16			sport;
+	__u16			dport;
+	__u16			i_flags;
+	__u16			o_flags;
+};
+
 /* SIT-mode i_flags */
 #define	SIT_ISATAP	0x0001
 
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index dd8c8c7..9dcce6b 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -55,6 +55,8 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
+#include <net/gue.h>
+#include <net/udp.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -528,8 +530,150 @@ static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 	return 0;
 }
 
+static int ip_encap_hlen(struct ip_tunnel_encap *e)
+{
+	switch (e->type) {
+	case TUNNEL_ENCAP_NONE:
+		return 0;
+	case TUNNEL_ENCAP_GUE_DIRECT:
+		return sizeof(struct udphdr);
+	default:
+		return -EINVAL;
+	}
+}
+
+static int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+			    size_t hdr_len, u8 *protocol, struct flowi4 *fl4)
+{
+	struct udphdr *uh;
+	__be16 sport;
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
+	udp_set_csum(!(e->o_flags & TUNNEL_ENCAP_FLAG_CSUM), skb,
+		     fl4->saddr, fl4->daddr, skb->len);
+
+	*protocol = IPPROTO_UDP;
+
+	return 0;
+	}
+
+int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
+		    u8 *protocol, struct flowi4 *fl4)
+{
+	switch (t->encap.type) {
+	case TUNNEL_ENCAP_NONE:
+		return 0;
+	case TUNNEL_ENCAP_GUE_DIRECT:
+		return gue_build_header(skb, &t->encap, t->encap_hlen,
+					protocol, fl4);
+	default:
+		return -EINVAL;
+	}
+}
+EXPORT_SYMBOL(ip_tunnel_encap);
+
+int __ip_tunnel_gen_ioctl(struct net_device *dev, struct net_device *tundev,
+			  struct ifreq *ifr, int cmd)
+{
+	int err = 0;
+	struct ip_tunnel *t;
+	struct net *net = dev_net(dev);
+	size_t hlen;
+	struct ip_tunnel_encap e;
+
+	switch (cmd) {
+	case SIOCGETTUNENCAP:
+		if (dev == tundev)
+			return -EINVAL;
+
+		t = netdev_priv(dev);
+		if (!t)
+			return -ENOENT;
+
+		if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->encap,
+				 sizeof(t->encap)))
+			err = -EFAULT;
+		break;
+
+	case SIOCDELTUNENCAP:
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
+			return -EPERM;
+		if (dev == tundev)
+			return -EINVAL;
+
+		t = netdev_priv(dev);
+		if (!t)
+			return -ENOENT;
+
+		memset(&t->encap, 0, sizeof(t->encap));
+		t->encap.type = TUNNEL_ENCAP_NONE;
+		t->encap_hlen = 0;
+		t->hlen = t->encap_hlen + t->tun_hlen;
+
+		dev->mtu = ip_tunnel_bind_dev(dev);
+
+		netdev_state_change(dev);
+		break;
+
+	case SIOCADDTUNENCAP:
+	case SIOCCHGTUNENCAP:
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
+			return -EPERM;
+		if (dev == tundev)
+			return -EINVAL;
+
+		t = netdev_priv(dev);
+		if (!t)
+			return -ENOENT;
+
+		if (copy_from_user(&e, ifr->ifr_ifru.ifru_data, sizeof(e))) {
+			err = -EFAULT;
+			break;
+		}
+		hlen = ip_encap_hlen(&e);
+		if (hlen < 0)
+			return hlen;
+
+		t->encap.type = e.type;
+		t->encap.sport = e.sport;
+		t->encap.dport = e.dport;
+		t->encap.i_flags = e.i_flags;
+		t->encap.o_flags = e.o_flags;
+		t->encap_hlen = hlen;
+		t->hlen = t->encap_hlen + t->tun_hlen;
+
+		dev->mtu = ip_tunnel_bind_dev(dev);
+
+		netdev_state_change(dev);
+		if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->encap,
+				 sizeof(t->encap))) {
+			err = -EFAULT;
+			break;
+		}
+		break;
+
+	default:
+		err = -ENOIOCTLCMD;
+	}
+	return err;
+}
+EXPORT_SYMBOL_GPL(__ip_tunnel_gen_ioctl);
+
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
-		    const struct iphdr *tnl_params, const u8 protocol)
+		    const struct iphdr *tnl_params, u8 protocol)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr *inner_iph;
@@ -610,6 +754,9 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	init_tunnel_flow(&fl4, protocol, dst, tnl_params->saddr,
 			 tunnel->parms.o_key, RT_TOS(tos), tunnel->parms.link);
 
+	if (ip_tunnel_encap(skb, tunnel, &protocol, &fl4) < 0)
+		goto tx_error;
+
 	rt = connected ? tunnel_rtable_get(tunnel, 0) : NULL;
 
 	if (!rt) {
-- 
2.0.0.526.g5318336
