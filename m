From: Alexandre Cassen <acassen@freebox.fr>
Subject: [PATCH] IPv6: 6rd tunnel mode
Date: Tue, 5 May 2009 12:50:20 +0200
Message-ID: <20090505105020.GA2577@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:33676 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754727AbZEEKu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 06:50:29 -0400
Received: from smtp1-g21.free.fr (localhost [127.0.0.1])
	by smtp1-g21.free.fr (Postfix) with ESMTP id 51232940045
	for <netdev@vger.kernel.org>; Tue,  5 May 2009 12:50:22 +0200 (CEST)
Received: from mail.lnxos.net (lnxos.staff.proxad.net [213.228.1.83])
	by smtp1-g21.free.fr (Postfix) with ESMTP id 398A39400F3
	for <netdev@vger.kernel.org>; Tue,  5 May 2009 12:50:20 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is the code currently used into production by free.fr to run its native IPv6 connection to the user.
It is running 6rd piece of technology.

IPv6 rapid deployment (6rd) builds upon mechanisms of 6to4 (RFC3056)
to enable a service provider to rapidly deploy IPv6 unicast service
to IPv4 sites to which it provides customer premise equipment.  Like
6to4, it utilizes stateless IPv6 in IPv4 encapsulation in order to
transit IPv4-only network infrastructure.  Unlike 6to4, a 6rd service
provider uses an IPv6 prefix of its own in place of the fixed 6to4
prefix. more info at http://tools.ietf.org/html/draft-despres-6rd-03.

Signed-off-by: Alexandre Cassen <acassen@freebox.fr>
---
 include/linux/if_tunnel.h |    5 ++++
 net/ipv6/Kconfig          |   13 ++++++++++++
 net/ipv6/sit.c            |   48 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 5a9aae4..7a99a47 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -33,6 +33,11 @@ struct ip_tunnel_parm
 	__be16			o_flags;
 	__be32			i_key;
 	__be32			o_key;
+
+	/* 6rd matching params */
+	struct in6_addr		ip6rd_zone;
+	__u8			ip6rd_prefix;
+
 	struct iphdr		iph;
 };
 
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index ca8cb32..526758f 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -170,6 +170,19 @@ config IPV6_SIT
 
 	  Saying M here will produce a module called sit.ko. If unsure, say Y.
 
+config IPV6_SIT_6RD
+	bool "IPv6: 6rd tunnel mode (EXPERIMENTAL)"
+	depends on IPV6_SIT && EXPERIMENTAL
+	default n
+	---help---
+	  IPv6 rapid deployment (6rd) builds upon mechanisms of 6to4 (RFC3056)
+	  to enable a service provider to rapidly deploy IPv6 unicast service
+	  to IPv4 sites to which it provides customer premise equipment.  Like
+	  6to4, it utilizes stateless IPv6 in IPv4 encapsulation in order to
+	  transit IPv4-only network infrastructure.  Unlike 6to4, a 6rd service
+	  provider uses an IPv6 prefix of its own in place of the fixed 6to4
+	  prefix.
+
 config IPV6_NDISC_NODETYPE
 	bool
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 664ab82..b194df1 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -166,6 +166,12 @@ static struct ip_tunnel * ipip6_tunnel_locate(struct net *net,
 
 	for (tp = __ipip6_bucket(sitn, parms); (t = *tp) != NULL; tp = &t->next) {
 		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr)
+#ifdef CONFIG_IPV6_SIT_6RD
+			if (!memcmp(&parms->ip6rd_zone,
+				    &t->parms.ip6rd_zone,
+				    sizeof (parms->ip6rd_zone)) &&
+			    parms->ip6rd_prefix == t->parms.ip6rd_prefix)
+#endif
 			return t;
 	}
 	if (!create)
@@ -530,6 +536,29 @@ static inline __be32 try_6to4(struct in6_addr *v6dst)
 	return dst;
 }
 
+#ifdef CONFIG_IPV6_SIT_6RD
+/* Returns the embedded IPv4 address if the IPv6 address comes from
+   6rd rule */
+static inline __be32 try_6rd(struct in6_addr *ip6rd_zone, u8 ip6rd_prefix, struct in6_addr *v6dst)
+{
+ 	__be32 dst = 0;
+
+	/* isolate zone according to mask */
+	if (ipv6_prefix_equal(v6dst, ip6rd_zone, ip6rd_prefix)) {
+		unsigned int d32_off, bits;
+
+		d32_off = ip6rd_prefix >> 5;
+		bits = (ip6rd_prefix & 0x1f);
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
@@ -582,6 +611,13 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto tx_error;
 	}
 
+#ifdef CONFIG_IPV6_SIT_6RD
+	if (!dst && tunnel->parms.ip6rd_prefix)
+		dst = try_6rd(&tunnel->parms.ip6rd_zone,
+			      tunnel->parms.ip6rd_prefix,
+			      &iph6->daddr);
+	else
+#endif
 	if (!dst)
 		dst = try_6to4(&iph6->daddr);
 
@@ -811,6 +847,14 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (p.iph.ttl)
 			p.iph.frag_off |= htons(IP_DF);
 
+#ifdef CONFIG_IPV6_SIT_6RD
+		/* prefix must be smaller than 32 bits since we fetch
+		 * an IPv4 address after them. 6rd prefix length as
+		 * specified into draft-despres-6rd-XX must be less
+		 * or equal to 32, maybe it can be generalized to 96 bits... */
+		if (p.ip6rd_prefix > 32)
+			goto done;
+#endif
 		t = ipip6_tunnel_locate(net, &p, cmd == SIOCADDTUNNEL);
 
 		if (dev != sitn->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
@@ -829,6 +873,10 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 				ipip6_tunnel_unlink(sitn, t);
 				t->parms.iph.saddr = p.iph.saddr;
 				t->parms.iph.daddr = p.iph.daddr;
+#ifdef CONFIG_IPV6_SIT_6RD
+				t->parms.ip6rd_zone = p.ip6rd_zone;
+				t->parms.ip6rd_prefix = p.ip6rd_prefix;
+#endif
 				memcpy(dev->dev_addr, &p.iph.saddr, 4);
 				memcpy(dev->broadcast, &p.iph.daddr, 4);
 				ipip6_tunnel_link(sitn, t);
-- 
1.5.6.3

