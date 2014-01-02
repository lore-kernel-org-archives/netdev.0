From: Tom Herbert <therbert@google.com>
Subject: [PATCH RFC 3/7] net: Changes to ip_tunnel for GUE
Date: Thu, 2 Jan 2014 14:12:59 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401021401520.32603@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hkchu@google.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:53184 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbaABWNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:13:00 -0500
Received: by mail-pd0-f201.google.com with SMTP id r10so2054889pdi.4
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 14:13:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes IP tunnel to support (secondary) encapsulation,
Generic UDP Encapsualtion. Changes include:

1) Adding tun_hlen as the tunnel header length, encap_hlen as the
encapsulation header length (GUE), and hlen becomes the grand total
of these.
2) Added generic function to handle IOCTLs
3) Added IOCTLs to setup or remove encapsulation. This includes
uapi to configure encapsulation on a tunnel.
4) Support to perform GUE encapsulation in ip_tunnel_xmit.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip_tunnels.h       |   8 +-
 include/uapi/linux/if_tunnel.h |  20 +++++
 net/ipv4/ip_tunnel.c           | 163 ++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 189 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 732f8c6..b5c4697 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -51,11 +51,16 @@ struct ip_tunnel {
 	/* These four fields used only by GRE */
 	__u32		i_seqno;	/* The last seen seqno	*/
 	__u32		o_seqno;	/* The last output seqno */
-	int		hlen;		/* Precalculated header length */
+	int		tun_hlen;	/* Precalculated header length */
 	int		mlink;
 
 	struct ip_tunnel_parm parms;
 
+	int encap_hlen;			/* Encap header length (GUE) */
+	struct ip_tunnel_encap encap;
+
+	int		hlen;		/* tun_hlen + encap_hlen */
+
 	/* for SIT */
 #ifdef CONFIG_IPV6_SIT_6RD
 	struct ip_tunnel_6rd_parm ip6rd;
@@ -107,6 +112,7 @@ void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops);
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		    const struct iphdr *tnl_params, const u8 protocol);
 int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd);
+int ip_tunnel_gen_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu);
 
 struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index aee73d0..f2bfdde 100644
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
+	TUNNEL_ENCAP_GUE_GUEHDR
+};
+
+#define TUNNEL_ENCAP_FLAG_DO_CHKSUM (1<<0)
+
+struct ip_tunnel_encap {
+	int			type;
+	__u16			sport;
+	__u16			dport;
+	__u16			flags;
+	__u16			__reserved;
+};
+
 /* SIT-mode i_flags */
 #define	SIT_ISATAP	0x0001
 
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 90ff957..7acb9f3 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -54,6 +54,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
+#include <net/gue.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -520,8 +521,165 @@ static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 	return 0;
 }
 
+
+static int ip_encap_hlen(struct ip_tunnel_encap *e)
+{
+	switch (e->type) {
+	case TUNNEL_ENCAP_NONE:
+		return 0;
+	case TUNNEL_ENCAP_GUE_DIRECT:
+		return sizeof(struct udphdr);
+	case TUNNEL_ENCAP_GUE_GUEHDR:
+		return sizeof(struct udphdr) + sizeof(struct guehdr);
+	default:
+		return -EINVAL;
+	}
+}
+
+static int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e, 
+		     size_t hdr_len, u8 *protocol)
+{
+	struct udphdr *uh;
+	size_t udplen = skb->len + sizeof(*uh);
+	__be16 sport;
+
+	/* Get length and hash before making space in skb */
+
+	if (e->sport)
+		sport = e->sport;
+	else {
+		u32 hash;
+
+		if (skb->sk && skb->sk->sk_hash)
+			hash = skb->sk->sk_hash;
+		else
+			hash = skb_get_hash(skb);
+		sport = htons((hash & 0x3fff) | 0xc000);;
+	}
+
+	skb_push(skb, hdr_len);
+
+	uh = (struct udphdr *)skb->data;
+
+	if (e->type == TUNNEL_ENCAP_GUE_GUEHDR) {
+		struct guehdr *guehdr = (struct guehdr *)&uh[1];
+
+		guehdr->version = 0;
+		guehdr->hlen = 0;
+		guehdr->flags = 0;
+		guehdr->next_hdr = *protocol;
+
+		udplen += sizeof(*guehdr);
+	}
+
+	uh->dest = e->dport;
+	uh->source = sport;
+	uh->len = htons(udplen);
+	uh->check = 0;
+
+	*protocol = IPPROTO_UDP;
+
+	return 0;
+	}
+
+static int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
+		    u8 *protocol)
+{
+	switch (t->encap.type) {
+	case TUNNEL_ENCAP_NONE:
+		return 0;
+	case TUNNEL_ENCAP_GUE_DIRECT:
+	case TUNNEL_ENCAP_GUE_GUEHDR:
+		return gue_build_header(skb, &t->encap, t->encap_hlen,
+					protocol);
+	default:
+		return -EINVAL;
+	}
+}
+
+int ip_tunnel_gen_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	int err = 0;
+	struct ip_tunnel *t;
+	struct net *net = dev_net(dev);
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct ip_tunnel_net *itn = net_generic(net, tunnel->ip_tnl_net_id);
+	size_t hlen;
+	struct ip_tunnel_encap e;
+
+	switch (cmd) {
+	case SIOCGETTUNENCAP:
+		if (dev == itn->fb_tunnel_dev)
+			return -EINVAL;
+		if (!(t = netdev_priv(dev)))
+			return -ENOENT;
+
+		if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->encap,
+				 sizeof(t->encap)))
+                       err = -EFAULT;
+		break;
+
+	case SIOCDELTUNENCAP:
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
+			return -EPERM;
+		if (dev == itn->fb_tunnel_dev)
+			return -EINVAL;
+		if (!(t = netdev_priv(dev)))
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
+		if (dev == itn->fb_tunnel_dev)
+			return -EINVAL;
+		if (!(t = netdev_priv(dev)))
+			return -ENOENT;
+
+		if (copy_from_user(&e, ifr->ifr_ifru.ifru_data, sizeof(e))) {
+                       err = -EFAULT;
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
+                       err = -EFAULT;
+			break;
+		}
+		break;
+
+	default:
+		err = -ENOIOCTLCMD;
+	}
+	return err;
+}
+EXPORT_SYMBOL_GPL(ip_tunnel_gen_ioctl);
+
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
-		    const struct iphdr *tnl_params, const u8 protocol)
+		    const struct iphdr *tnl_params, u8 protocol)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr *inner_iph;
@@ -533,6 +691,9 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	__be32 dst;
 	int err;
 
+	if (ip_tunnel_encap(skb, tunnel, &protocol) < 0)
+		goto tx_error;
+
 	inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
 
 	dst = tnl_params->daddr;
-- 
1.8.5.1
