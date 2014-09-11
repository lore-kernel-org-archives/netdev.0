From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 4/7] net: Changes to ip_tunnel to support foo-over-udp encapsulation
Date: Thu, 11 Sep 2014 13:07:33 -0700
Message-ID: <1410466056-30239-5-git-send-email-therbert@google.com>
References: <1410466056-30239-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:60840 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754735AbaIKUIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 16:08:14 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so13202212pad.35
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 13:08:13 -0700 (PDT)
In-Reply-To: <1410466056-30239-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes IP tunnel to support (secondary) encapsulation,
Foo-over-UDP. Changes include:

1) Adding tun_hlen as the tunnel header length, encap_hlen as the
   encapsulation header length, and hlen becomes the grand total
   of these.
2) Added generic function to handle IOCTLs
3) Added IOCTLs to setup or remove encapsulation. This includes
   uapi to configure encapsulation on a tunnel.
4) Support to perform FOU encapsulation in ip_tunnel_xmit.
   encap tunnel.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip_tunnels.h       |  25 +++++-
 include/uapi/linux/if_tunnel.h |  23 ++++++
 net/ipv4/ip_tunnel.c           | 177 ++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 223 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 8dd8cab..34f567d 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -10,6 +10,7 @@
 #include <net/gro_cells.h>
 #include <net/inet_ecn.h>
 #include <net/ip.h>
+#include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -56,13 +57,18 @@ struct ip_tunnel {
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
@@ -114,6 +120,21 @@ void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops);
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
@@ -131,6 +152,8 @@ int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 		      struct ip_tunnel_parm *p);
 void ip_tunnel_setup(struct net_device *dev, int net_id);
 void ip_tunnel_dst_reset_all(struct ip_tunnel *t);
+int ip_tunnel_encap_setup(struct ip_tunnel *t,
+			  struct ip_tunnel_encap *ipencap);
 
 /* Extract dsfield from inner protocol */
 static inline u8 ip_tunnel_get_dsfield(const struct iphdr *iph,
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 3bce9e9..4369b62 100644
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
@@ -53,10 +57,29 @@ enum {
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
+
+struct ip_tunnel_encap {
+	__u16			type;
+	__u16			flags;
+	__be16			sport;
+	__be16			dport;
+};
 /* SIT-mode i_flags */
 #define	SIT_ISATAP	0x0001
 
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index afed1aa..c12f9d7 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -55,6 +55,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
+#include <net/udp.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -487,6 +488,177 @@ drop:
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
+		t->encap.flags = e.flags;
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
 static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 			    struct rtable *rt, __be16 df)
 {
@@ -536,7 +708,7 @@ static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 }
 
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
-		    const struct iphdr *tnl_params, const u8 protocol)
+		    const struct iphdr *tnl_params, u8 protocol)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr *inner_iph;
@@ -617,6 +789,9 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	init_tunnel_flow(&fl4, protocol, dst, tnl_params->saddr,
 			 tunnel->parms.o_key, RT_TOS(tos), tunnel->parms.link);
 
+	if (ip_tunnel_encap(skb, tunnel, &protocol, &fl4) < 0)
+		goto tx_error;
+
 	rt = connected ? tunnel_rtable_get(tunnel, 0, &fl4.saddr) : NULL;
 
 	if (!rt) {
-- 
2.1.0.rc2.206.gedb03e5
