From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][RESEND 3] IPv6: 6rd tunnel mode
Date: Wed, 23 Sep 2009 18:43:14 +0900
Message-ID: <20090923184314.a2a2701d.yoshfuji@linux-ipv6.org>
References: <20090922220251.GA22874@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Alexandre Cassen <acassen@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41060 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751210AbZIWJnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 05:43:12 -0400
In-Reply-To: <20090922220251.GA22874@lnxos.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

First of all, thank you for this work.

On Wed, 23 Sep 2009 00:02:51 +0200
Alexandre Cassen <acassen@freebox.fr> wrote:

> This patch add support to 6rd tunnel mode as described into
> draft-despres-6rd-03.
> 
> Patch history :
> * http://patchwork.ozlabs.org/patch/26870/
> * http://patchwork.ozlabs.org/patch/34026/
> * http://patchwork.ozlabs.org/patch/34045/
> 
> IPv6 rapid deployment (draft-despres-6rd-03) builds upon mechanisms

Well, I was confused.  I think draft-softwire-ipv6-6rd
is the latest one, no?

Another comment is that we should combine 6to4
and 6rd.

In fact, I've been taking care of it since I met
with Mark Townsley last week.  Here's my tentative
version for reference.

Several points:
 - based on latest version.
 - share code path with 6to4.

(If anyone can invent better bitops,
it will great help...)

Regards,

--yoshfuji

----
>From 7c82f67d361155a2e8ee831c66c9663617ae45bc Mon Sep 17 00:00:00 2001
From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 22 Sep 2009 16:29:54 +0900
Subject: [PATCH] ipv6 sit: 6rd (IPv6 Rapid Deployment) Support.

IPv6 Rapid Deployment (6rd; draft-ietf-softwire-ipv6-6rd) builds upon
mechanisms of 6to4 (RFC3056) to enable a service provider to rapidly
deploy IPv6 unicast service to IPv4 sites to which it provides
customer premise equipment.  Like 6to4, it utilizes stateless IPv6 in
IPv4 encapsulation in order to transit IPv4-only network
infrastructure.  Unlike 6to4, a 6rd service provider uses an IPv6
prefix of its own in place of the fixed 6to4 prefix.

With this option enabled, the SIT driver offers 6rd functionality by
providing additional ioctl API to configure the IPv6 Prefix for in
stead of static 2002::/16 for 6to4.

Original patch was done by Alexandre Cassen <acassen@freebox.fr>
based on old Internet-Draft.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/if_tunnel.h |   11 ++++
 include/net/ipip.h        |   13 +++++
 net/ipv6/Kconfig          |   19 +++++++
 net/ipv6/sit.c            |  124 ++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 159 insertions(+), 8 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 5eb9b0f..cab4938 100644
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
@@ -51,6 +55,13 @@ struct ip_tunnel_prl {
 /* PRL flags */
 #define	PRL_DEFAULT		0x0001
 
+struct ip_tunnel_6rd {
+	struct in6_addr		prefix;
+	__be32			relay_prefix;
+	__u16			prefixlen;
+	__u16			relay_prefixlen;
+};
+
 enum
 {
 	IFLA_GRE_UNSPEC,
diff --git a/include/net/ipip.h b/include/net/ipip.h
index 5d3036f..157be1c 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -7,6 +7,15 @@
 /* Keep error state on tunnel for 30 sec */
 #define IPTUNNEL_ERR_TIMEO	(30*HZ)
 
+/* 6rd prefix/relay information */
+struct ip_tunnel_6rd_parm
+{
+	struct in6_addr		prefix;
+	__be32			relay_prefix;
+	u16			prefixlen;
+	u16			relay_prefixlen;
+};
+
 struct ip_tunnel
 {
 	struct ip_tunnel	*next;
@@ -24,6 +33,10 @@ struct ip_tunnel
 
 	struct ip_tunnel_parm	parms;
 
+	/* for SIT */
+#ifdef CONFIG_IPV6_SIT_6RD
+	struct ip_tunnel_6rd_parm	ip6rd;
+#endif
 	struct ip_tunnel_prl_entry	*prl;		/* potential router list */
 	unsigned int			prl_count;	/* # of entries in PRL */
 };
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index ead6c7a..f561998 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -170,6 +170,25 @@ config IPV6_SIT
 
 	  Saying M here will produce a module called sit. If unsure, say Y.
 
+config IPV6_SIT_6RD
+	bool "IPv6: IPv6 Rapid Development (6RD) (EXPERIMENTAL)"
+	depends on IPV6_SIT && EXPERIMENTAL
+	default n
+	---help---
+	  IPv6 Rapid Deployment (6rd; draft-ietf-softwire-ipv6-6rd) builds upon
+	  mechanisms of 6to4 (RFC3056) to enable a service provider to rapidly
+	  deploy IPv6 unicast service to IPv4 sites to which it provides
+	  customer premise equipment.  Like 6to4, it utilizes stateless IPv6 in
+	  IPv4 encapsulation in order to transit IPv4-only network
+	  infrastructure.  Unlike 6to4, a 6rd service provider uses an IPv6
+	  prefix of its own in place of the fixed 6to4 prefix.
+
+	  With this option enabled, the SIT driver offers 6rd functionality by
+	  providing additional ioctl API to configure the IPv6 Prefix for in
+	  stead of static 2002::/16 for 6to4.
+
+	  If unsure, say N.
+
 config IPV6_NDISC_NODETYPE
 	bool
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 0ae4f64..14bd503 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -162,6 +162,21 @@ static void ipip6_tunnel_link(struct sit_net *sitn, struct ip_tunnel *t)
 	write_unlock_bh(&ipip6_lock);
 }
 
+static void ipip6_tunnel_clone_6rd(struct ip_tunnel *t, struct sit_net *sitn)
+{
+#ifdef CONFIG_IPV6_SIT_6RD
+	if (t->dev == sitn->fb_tunnel_dev) {
+		ipv6_addr_set(&t->ip6rd.prefix, htonl(0x20020000), 0, 0, 0);
+		t->ip6rd.relay_prefix = 0;
+		t->ip6rd.prefixlen = 16;
+		t->ip6rd.relay_prefixlen = 0;
+	} else {
+		struct ip_tunnel *t0 = netdev_priv(sitn->fb_tunnel_dev);
+		memcpy(&t->ip6rd, &t0->ip6rd, sizeof(t->ip6rd));
+	}
+#endif
+}
+
 static struct ip_tunnel * ipip6_tunnel_locate(struct net *net,
 		struct ip_tunnel_parm *parms, int create)
 {
@@ -214,6 +229,8 @@ static struct ip_tunnel * ipip6_tunnel_locate(struct net *net,
 
 	dev_hold(dev);
 
+	ipip6_tunnel_clone_6rd(t, sitn);
+
 	ipip6_tunnel_link(sitn, nt);
 	return nt;
 
@@ -590,17 +607,41 @@ out:
 	return 0;
 }
 
-/* Returns the embedded IPv4 address if the IPv6 address
-   comes from 6to4 (RFC 3056) addr space */
-
-static inline __be32 try_6to4(struct in6_addr *v6dst)
+/*
+ * Returns the embedded IPv4 address if the IPv6 address
+ * comes from 6rd / 6to4 (RFC 3056) addr space.
+ */
+static inline
+__be32 try_6rd(struct in6_addr *v6dst, struct ip_tunnel *tunnel)
 {
 	__be32 dst = 0;
 
+#ifdef CONFIG_IPV6_SIT_6RD
+	if (ipv6_prefix_equal(v6dst, &tunnel->ip6rd.prefix,
+			      tunnel->ip6rd.prefixlen)) {
+		unsigned pbw0, pbi0;
+		int pbi1;
+		u32 d;
+
+		pbw0 = tunnel->ip6rd.prefixlen >> 5;
+		pbi0 = tunnel->ip6rd.prefixlen & 0x1f;
+
+		d = (ntohl(tunnel->ip6rd.prefix.s6_addr32[pbw0]) << pbi0) >>
+		    tunnel->ip6rd.relay_prefixlen;
+
+		pbi1 = pbi0 - tunnel->ip6rd.relay_prefixlen;
+		if (pbi1 > 0)
+			d |= ntohl(tunnel->ip6rd.prefix.s6_addr32[pbw0 + 1]) >>
+			     (32 - pbi1);
+
+		dst = tunnel->ip6rd.relay_prefix | htonl(d);
+	}
+#else
 	if (v6dst->s6_addr16[0] == htons(0x2002)) {
 		/* 6to4 v6 addr has 16 bits prefix, 32 v4addr, 16 SLA, ... */
 		memcpy(&dst, &v6dst->s6_addr16[1], 4);
 	}
+#endif
 	return dst;
 }
 
@@ -658,7 +699,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	}
 
 	if (!dst)
-		dst = try_6to4(&iph6->daddr);
+		dst = try_6rd(&iph6->daddr, tunnel);
 
 	if (!dst) {
 		struct neighbour *neigh = NULL;
@@ -851,9 +892,15 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct ip_tunnel *t;
 	struct net *net = dev_net(dev);
 	struct sit_net *sitn = net_generic(net, sit_net_id);
+#ifdef CONFIG_IPV6_SIT_6RD
+	struct ip_tunnel_6rd ip6rd;
+#endif
 
 	switch (cmd) {
 	case SIOCGETTUNNEL:
+#ifdef CONFIG_IPV6_SIT_6RD
+	case SIOCGET6RD:
+#endif
 		t = NULL;
 		if (dev == sitn->fb_tunnel_dev) {
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
@@ -864,9 +911,25 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		}
 		if (t == NULL)
 			t = netdev_priv(dev);
-		memcpy(&p, &t->parms, sizeof(p));
-		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
-			err = -EFAULT;
+
+		err = -EFAULT;
+		if (cmd == SIOCGETTUNNEL) {
+			memcpy(&p, &t->parms, sizeof(p));
+			if (copy_to_user(ifr->ifr_ifru.ifru_data, &p,
+					 sizeof(p)))
+				goto done;
+#ifdef CONFIG_IPV6_SIT_6RD
+		} else {
+			ipv6_addr_copy(&ip6rd.prefix, &t->ip6rd.prefix);
+			ip6rd.relay_prefix = t->ip6rd.relay_prefix;
+			ip6rd.prefixlen = t->ip6rd.prefixlen;
+			ip6rd.relay_prefixlen = t->ip6rd.relay_prefixlen;
+			if (copy_to_user(ifr->ifr_ifru.ifru_data, &ip6rd,
+					 sizeof(ip6rd)))
+				goto done;
+#endif
+		}
+		err = 0;
 		break;
 
 	case SIOCADDTUNNEL:
@@ -987,6 +1050,51 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		netdev_state_change(dev);
 		break;
 
+#ifdef CONFIG_IPV6_SIT_6RD
+	case SIOCADD6RD:
+	case SIOCCHG6RD:
+	case SIOCDEL6RD:
+		err = -EPERM;
+		if (!capable(CAP_NET_ADMIN))
+			goto done;
+
+		err = -EFAULT;
+		if (copy_from_user(&ip6rd, ifr->ifr_ifru.ifru_data,
+				   sizeof(ip6rd)))
+			goto done;
+
+		t = netdev_priv(dev);
+
+		if (cmd != SIOCDEL6RD) {
+			struct in6_addr prefix;
+			__be32 relay_prefix;
+
+			err = -EINVAL;
+			if (ip6rd.relay_prefixlen > 32 ||
+			    ip6rd.prefixlen + (32 - ip6rd.relay_prefixlen) > 64)
+				goto done;
+
+			ipv6_addr_prefix(&prefix, &ip6rd.prefix,
+					 ip6rd.prefixlen);
+			if (!ipv6_addr_equal(&prefix, &ip6rd.prefix))
+				goto done;
+			relay_prefix = ip6rd.relay_prefix &
+				       htonl(0xffffffffUL <<
+					     (32 - ip6rd.relay_prefixlen));
+			if (relay_prefix != ip6rd.relay_prefix)
+				goto done;
+
+			ipv6_addr_copy(&t->ip6rd.prefix, &prefix);
+			t->ip6rd.relay_prefix = relay_prefix;
+			t->ip6rd.prefixlen = ip6rd.prefixlen;
+			t->ip6rd.relay_prefixlen = ip6rd.relay_prefixlen;
+		} else
+			ipip6_tunnel_clone_6rd(t, sitn);
+
+		err = 0;
+		break;
+#endif
+
 	default:
 		err = -EINVAL;
 	}
-- 
1.5.6.5


--yoshfuji
