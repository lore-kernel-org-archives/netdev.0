From: Alexandre Cassen <acassen@freebox.fr>
Subject: [PATCH][RESEND] IPv6: 6rd tunnel mode
Date: Tue, 22 Sep 2009 02:39:56 +0200
Message-ID: <20090922003956.GA19947@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:54364 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbZIVAkB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 20:40:01 -0400
Received: from smtp2-g21.free.fr (localhost [127.0.0.1])
	by smtp2-g21.free.fr (Postfix) with ESMTP id CE56E4B0054
	for <netdev@vger.kernel.org>; Tue, 22 Sep 2009 02:39:59 +0200 (CEST)
Received: from mail.lnxos.net (lnxos.staff.proxad.net [213.228.1.83])
	by smtp2-g21.free.fr (Postfix) with ESMTP id C8B5B4B001B
	for <netdev@vger.kernel.org>; Tue, 22 Sep 2009 02:39:56 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add support to 6rd tunnel mode currently targetting
standard track at the IETF.

IPv6 rapid deployment (RFC5569) builds upon mechanisms of 6to4 (RFC3056)
to enable a service provider to rapidly deploy IPv6 unicast service
to IPv4 sites to which it provides customer premise equipment.  Like
6to4, it utilizes stateless IPv6 in IPv4 encapsulation in order to
transit IPv4-only network infrastructure. Unlike 6to4, a 6rd service
provider uses an IPv6 prefix of its own in place of the fixed 6to4
prefix.

Signed-off-by: Alexandre Cassen <acassen@freebox.fr>
---
 include/linux/if_tunnel.h |   10 +++++
 include/net/ipip.h        |    2 +
 net/ipv6/Kconfig          |   13 +++++++
 net/ipv6/sit.c            |   84 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 109 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 5eb9b0f..0d44376 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -15,6 +15,10 @@
 #define SIOCADDPRL      (SIOCDEVPRIVATE + 5)
 #define SIOCDELPRL      (SIOCDEVPRIVATE + 6)
 #define SIOCCHGPRL      (SIOCDEVPRIVATE + 7)
+#define SIOCGET6RD      (SIOCDEVPRIVATE + 8)
+#define SIOCADD6RD      (SIOCDEVPRIVATE + 9)
+#define SIOCDEL6RD      (SIOCDEVPRIVATE + 10)
+#define SIOCCHG6RD      (SIOCDEVPRIVATE + 11)
 
 #define GRE_CSUM	__cpu_to_be16(0x8000)
 #define GRE_ROUTING	__cpu_to_be16(0x4000)
@@ -51,6 +55,12 @@ struct ip_tunnel_prl {
 /* PRL flags */
 #define	PRL_DEFAULT		0x0001
 
+/* 6RD parms */
+struct ip_tunnel_6rd {
+	struct in6_addr		addr;
+	__u8			prefixlen;
+};
+
 enum
 {
 	IFLA_GRE_UNSPEC,
diff --git a/include/net/ipip.h b/include/net/ipip.h
index 5d3036f..fa92c41 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -26,6 +26,8 @@ struct ip_tunnel
 
 	struct ip_tunnel_prl_entry	*prl;		/* potential router list */
 	unsigned int			prl_count;	/* # of entries in PRL */
+
+	struct ip_tunnel_6rd	ip6rd_prefix;	/* 6RD SP prefix */
 };
 
 /* ISATAP: default interval between RS in secondy */
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index ead6c7a..78a565b 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -170,6 +170,19 @@ config IPV6_SIT
 
 	  Saying M here will produce a module called sit. If unsure, say Y.
 
+config IPV6_SIT_6RD
+	bool "IPv6: 6rd tunnel mode (EXPERIMENTAL)"
+	depends on IPV6_SIT && EXPERIMENTAL
+	default n
+	---help---
+	IPv6 rapid deployment (RFC5569) builds upon mechanisms of 6to4 (RFC3056)
+	to enable a service provider to rapidly deploy IPv6 unicast service
+	to IPv4 sites to which it provides customer premise equipment.  Like
+	6to4, it utilizes stateless IPv6 in IPv4 encapsulation in order to
+	transit IPv4-only network infrastructure. Unlike 6to4, a 6rd service
+	provider uses an IPv6 prefix of its own in place of the fixed 6to4
+	prefix.
+
 config IPV6_NDISC_NODETYPE
 	bool
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 0ae4f64..ff62e97 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -604,6 +604,30 @@ static inline __be32 try_6to4(struct in6_addr *v6dst)
 	return dst;
 }
 
+#ifdef CONFIG_IPV6_SIT_6RD
+/* Returns the embedded IPv4 address if the IPv6 address comes from
+   6rd rule */
+
+static inline __be32 try_6rd(struct in6_addr *addr, u8 prefix_len, struct in6_addr *v6dst)
+{
+	__be32 dst = 0;
+
+	/* isolate addr according to mask */
+	if (ipv6_prefix_equal(v6dst, addr, prefix_len)) {
+		unsigned int d32_off, bits;
+
+		d32_off = prefix_len >> 5;
+		bits = (prefix_len & 0x1f);
+
+		dst = (ntohl(v6dst->s6_addr32[d32_off]) << bits);
+		if (bits)
+			dst |= ntohl(v6dst->s6_addr32[d32_off + 1]) >> (32 - bits);
+		dst = htonl(dst);
+	}
+	return dst;
+}
+#endif
+
 /*
  *	This function assumes it is being called from dev_queue_xmit()
  *	and that skb is filled properly by that function.
@@ -657,6 +681,13 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			goto tx_error;
 	}
 
+#ifdef CONFIG_IPV6_SIT_6RD
+	if (!dst && tunnel->ip6rd_prefix.prefixlen)
+		dst = try_6rd(&tunnel->ip6rd_prefix.addr,
+			      tunnel->ip6rd_prefix.prefixlen,
+			      &iph6->daddr);
+	else
+#endif
 	if (!dst)
 		dst = try_6to4(&iph6->daddr);
 
@@ -848,6 +879,9 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	int err = 0;
 	struct ip_tunnel_parm p;
 	struct ip_tunnel_prl prl;
+#ifdef CONFIG_IPV6_SIT_6RD
+	struct ip_tunnel_6rd ip6rd;
+#endif
 	struct ip_tunnel *t;
 	struct net *net = dev_net(dev);
 	struct sit_net *sitn = net_generic(net, sit_net_id);
@@ -987,6 +1021,56 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		netdev_state_change(dev);
 		break;
 
+#ifdef CONFIG_IPV6_SIT_6RD
+	case SIOCGET6RD:
+		err = -EINVAL;
+		if (dev == sitn->fb_tunnel_dev)
+			goto done;
+		err = -ENOENT;
+		if (!(t = netdev_priv(dev)))
+			goto done;
+		memcpy(&ip6rd, &t->ip6rd_prefix, sizeof(ip6rd));
+		if (copy_to_user(ifr->ifr_ifru.ifru_data, &ip6rd, sizeof(ip6rd)))
+			err = -EFAULT;
+		else
+			err = 0;
+		break;
+
+	case SIOCADD6RD:
+	case SIOCDEL6RD:
+	case SIOCCHG6RD:
+		err = -EPERM;
+		if (!capable(CAP_NET_ADMIN))
+			goto done;
+		err = -EINVAL;
+		if (dev == sitn->fb_tunnel_dev)
+			goto done;
+		err = -EFAULT;
+		if (copy_from_user(&ip6rd, ifr->ifr_ifru.ifru_data, sizeof(ip6rd)))
+			goto done;
+		err = -ENOENT;
+		if (!(t = netdev_priv(dev)))
+			goto done;
+
+		err = 0;
+		switch (cmd) {
+		case SIOCDEL6RD:
+			memset(&t->ip6rd_prefix, 0, sizeof(ip6rd));
+			break;
+		case SIOCADD6RD:
+		case SIOCCHG6RD:
+			if (ip6rd.prefixlen >= 95) {
+				err = -EINVAL;
+				goto done;
+			}
+			t->ip6rd_prefix.addr = ip6rd.addr;
+			t->ip6rd_prefix.prefixlen = ip6rd.prefixlen;
+			break;
+		}
+		netdev_state_change(dev);
+		break;
+#endif
+
 	default:
 		err = -EINVAL;
 	}
-- 
1.6.0.4

