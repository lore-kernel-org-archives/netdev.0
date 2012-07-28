From: Dmitry Kozlov <xeb@mail.ru>
Subject: [PATCH net-next v2] GRE over IPv6
Date: Sat, 28 Jul 2012 11:35:12 +0400
Message-ID: <20120728113512.3ffd8248@comp1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8.mail.ru ([94.100.176.53]:50938 "EHLO smtp8.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751915Ab2G1HjR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Jul 2012 03:39:17 -0400
Received: from [128.71.109.89] (port=34806 helo=comp1)
	by smtp8.mail.ru with esmtpa (envelope-from <xeb@mail.ru>)
	id 1Sv1cK-0002mt-4r
	for netdev@vger.kernel.org; Sat, 28 Jul 2012 11:39:16 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRE over IPv6 implementation.

Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
---
Changes:
Initialize nt->dev before calling ip6gre_tnl_link_config in
ip6gre_newlink.

 include/linux/if_arp.h     |    1 +
 include/linux/if_tunnel.h  |    3 ++
 include/linux/ip6_tunnel.h |   18 +++++++++
 include/net/ip6_tunnel.h   |   40 ++++++++++++++++++++-
 include/net/ipv6.h         |    1 +
 net/ipv6/Kconfig           |   16 ++++++++
 net/ipv6/Makefile          |    1 +
 net/ipv6/ip6_tunnel.c      |   86 +++++++++++++++++++++++++++++++------------
 8 files changed, 141 insertions(+), 25 deletions(-)

diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index f0e69c6..9adcc29 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -92,6 +92,7 @@
 #define ARPHRD_PHONET	820		/* PhoNet media type		*/
 #define ARPHRD_PHONET_PIPE 821		/* PhoNet pipe header		*/
 #define ARPHRD_CAIF	822		/* CAIF media type		*/
+#define ARPHRD_IP6GRE	823		/* GRE over IPv6		*/
 
 #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
 #define ARPHRD_NONE	  0xFFFE	/* zero header length */
diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 5efff60..8c5035a 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -75,6 +75,9 @@ enum {
 	IFLA_GRE_TTL,
 	IFLA_GRE_TOS,
 	IFLA_GRE_PMTUDISC,
+	IFLA_GRE_ENCAP_LIMIT,
+	IFLA_GRE_FLOWINFO,
+	IFLA_GRE_FLAGS,
 	__IFLA_GRE_MAX,
 };
 
diff --git a/include/linux/ip6_tunnel.h b/include/linux/ip6_tunnel.h
index bf22b03..1efe2e0 100644
--- a/include/linux/ip6_tunnel.h
+++ b/include/linux/ip6_tunnel.h
@@ -31,4 +31,22 @@ struct ip6_tnl_parm {
 	struct in6_addr raddr;	/* remote tunnel end-point address */
 };
 
+struct ip6_tnl_parm2 {
+	char name[IFNAMSIZ];	/* name of tunnel device */
+	int link;		/* ifindex of underlying L2 interface */
+	__u8 proto;		/* tunnel protocol */
+	__u8 encap_limit;	/* encapsulation limit for tunnel */
+	__u8 hop_limit;		/* hop limit for tunnel */
+	__be32 flowinfo;	/* traffic class and flowlabel for tunnel */
+	__u32 flags;		/* tunnel flags */
+	struct in6_addr laddr;	/* local tunnel end-point address */
+	struct in6_addr raddr;	/* remote tunnel end-point address */
+
+	__be16			i_flags;
+	__be16			o_flags;
+	__be32			i_key;
+	__be32			o_key;
+};
+
+
 #endif
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 358fb86..8400ba0 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -5,6 +5,8 @@
 #include <linux/netdevice.h>
 #include <linux/ip6_tunnel.h>
 
+#define IP6TUNNEL_ERR_TIMEO (30*HZ)
+
 /* capable of sending packets */
 #define IP6_TNL_F_CAP_XMIT 0x10000
 /* capable of receiving packets */
@@ -13,14 +15,40 @@
 #define IP6_TNL_F_CAP_PER_PACKET 0x40000
 
 /* IPv6 tunnel */
+struct __ip6_tnl_parm
+{
+	char name[IFNAMSIZ];	/* name of tunnel device */
+	int link;		/* ifindex of underlying L2 interface */
+	__u8 proto;		/* tunnel protocol */
+	__u8 encap_limit;	/* encapsulation limit for tunnel */
+	__u8 hop_limit;		/* hop limit for tunnel */
+	__be32 flowinfo;	/* traffic class and flowlabel for tunnel */
+	__u32 flags;		/* tunnel flags */
+	struct in6_addr laddr;	/* local tunnel end-point address */
+	struct in6_addr raddr;	/* remote tunnel end-point address */
+
+	__be16			i_flags;
+	__be16			o_flags;
+	__be32			i_key;
+	__be32			o_key;
+};
 
 struct ip6_tnl {
 	struct ip6_tnl __rcu *next;	/* next tunnel in list */
 	struct net_device *dev;	/* virtual device associated with tunnel */
-	struct ip6_tnl_parm parms;	/* tunnel configuration parameters */
+	struct __ip6_tnl_parm parms;	/* tunnel configuration parameters */
 	struct flowi fl;	/* flowi template for xmit */
 	struct dst_entry *dst_cache;    /* cached dst */
 	u32 dst_cookie;
+
+	int err_count;
+	unsigned long err_time;
+
+	/* These fields used only by GRE */
+	__u32			i_seqno;	/* The last seen seqno	*/
+	__u32			o_seqno;	/* The last output seqno */
+	int			hlen;		/* Precalculated GRE header length */
+	int mlink;
 };
 
 /* Tunnel encapsulation limit destination sub-option */
@@ -31,4 +59,14 @@ struct ipv6_tlv_tnl_enc_lim {
 	__u8 encap_limit;	/* tunnel encapsulation limit   */
 } __packed;
 
+struct dst_entry *ip6_tnl_dst_check(struct ip6_tnl *t);
+void ip6_tnl_dst_reset(struct ip6_tnl *t);
+void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst);
+int ip6_tnl_rcv_ctl(struct ip6_tnl *t, const struct in6_addr *laddr,
+		const struct in6_addr *raddr);
+int ip6_tnl_xmit_ctl(struct ip6_tnl *t);
+__u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 * raw);
+__u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
+			     const struct in6_addr *raddr);
+
 #endif
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 01c34b3..6d01fb0 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -34,6 +34,7 @@
 #define NEXTHDR_IPV6		41	/* IPv6 in IPv6 */
 #define NEXTHDR_ROUTING		43	/* Routing header. */
 #define NEXTHDR_FRAGMENT	44	/* Fragmentation/reassembly header. */
+#define NEXTHDR_GRE		47	/* GRE header. */
 #define NEXTHDR_ESP		50	/* Encapsulating security payload. */
 #define NEXTHDR_AUTH		51	/* Authentication header. */
 #define NEXTHDR_ICMP		58	/* ICMP for IPv6. */
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 5728695..4f7fe72 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -201,6 +201,22 @@ config IPV6_TUNNEL
 
 	  If unsure, say N.
 
+config IPV6_GRE
+	tristate "IPv6: GRE tunnel"
+	select IPV6_TUNNEL
+	---help---
+	  Tunneling means encapsulating data of one protocol type within
+	  another protocol and sending it over a channel that understands the
+	  encapsulating protocol. This particular tunneling driver implements
+	  GRE (Generic Routing Encapsulation) and at this time allows
+	  encapsulating of IPv4 or IPv6 over existing IPv6 infrastructure.
+	  This driver is useful if the other endpoint is a Cisco router: Cisco
+	  likes GRE much better than the other Linux tunneling driver ("IP
+	  tunneling" above). In addition, GRE allows multicast redistribution
+	  through the tunnel.
+
+	  Saying M here will produce a module called ip6_gre. If unsure, say N.
+
 config IPV6_MULTIPLE_TABLES
 	bool "IPv6: Multiple Routing Tables"
 	depends on EXPERIMENTAL
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 686934a..b6d3f79 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -36,6 +36,7 @@ obj-$(CONFIG_NETFILTER)	+= netfilter/
 
 obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
+obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
 
 obj-y += addrconf_core.o exthdrs_core.o
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9a1d5fe..fc24522 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -126,7 +126,7 @@ static struct net_device_stats *ip6_get_stats(struct net_device *dev)
  * Locking : hash tables are protected by RCU and RTNL
  */
 
-static inline struct dst_entry *ip6_tnl_dst_check(struct ip6_tnl *t)
+struct dst_entry *ip6_tnl_dst_check(struct ip6_tnl *t)
 {
 	struct dst_entry *dst = t->dst_cache;
 
@@ -139,20 +139,23 @@ static inline struct dst_entry *ip6_tnl_dst_check(struct ip6_tnl *t)
 
 	return dst;
 }
+EXPORT_SYMBOL_GPL(ip6_tnl_dst_check);
 
-static inline void ip6_tnl_dst_reset(struct ip6_tnl *t)
+void ip6_tnl_dst_reset(struct ip6_tnl *t)
 {
 	dst_release(t->dst_cache);
 	t->dst_cache = NULL;
 }
+EXPORT_SYMBOL_GPL(ip6_tnl_dst_reset);
 
-static inline void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst)
+void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst)
 {
 	struct rt6_info *rt = (struct rt6_info *) dst;
 	t->dst_cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
 	dst_release(t->dst_cache);
 	t->dst_cache = dst;
 }
+EXPORT_SYMBOL_GPL(ip6_tnl_dst_store);
 
 /**
  * ip6_tnl_lookup - fetch tunnel matching the end-point addresses
@@ -200,7 +203,7 @@ ip6_tnl_lookup(struct net *net, const struct in6_addr *remote, const struct in6_
  **/
 
 static struct ip6_tnl __rcu **
-ip6_tnl_bucket(struct ip6_tnl_net *ip6n, const struct ip6_tnl_parm *p)
+ip6_tnl_bucket(struct ip6_tnl_net *ip6n, const struct __ip6_tnl_parm *p)
 {
 	const struct in6_addr *remote = &p->raddr;
 	const struct in6_addr *local = &p->laddr;
@@ -267,7 +270,7 @@ static void ip6_dev_free(struct net_device *dev)
  *   created tunnel or NULL
  **/
 
-static struct ip6_tnl *ip6_tnl_create(struct net *net, struct ip6_tnl_parm *p)
+static struct ip6_tnl *ip6_tnl_create(struct net *net, struct __ip6_tnl_parm *p)
 {
 	struct net_device *dev;
 	struct ip6_tnl *t;
@@ -322,7 +325,7 @@ failed:
  **/
 
 static struct ip6_tnl *ip6_tnl_locate(struct net *net,
-		struct ip6_tnl_parm *p, int create)
+		struct __ip6_tnl_parm *p, int create)
 {
 	const struct in6_addr *remote = &p->raddr;
 	const struct in6_addr *local = &p->laddr;
@@ -374,8 +377,7 @@ ip6_tnl_dev_uninit(struct net_device *dev)
  *   else index to encapsulation limit
  **/
 
-static __u16
-parse_tlv_tnl_enc_lim(struct sk_buff *skb, __u8 * raw)
+__u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 * raw)
 {
 	const struct ipv6hdr *ipv6h = (const struct ipv6hdr *) raw;
 	__u8 nexthdr = ipv6h->nexthdr;
@@ -425,6 +427,7 @@ parse_tlv_tnl_enc_lim(struct sk_buff *skb, __u8 * raw)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(ip6_tnl_parse_tlv_enc_lim);
 
 /**
  * ip6_tnl_err - tunnel error handler
@@ -480,7 +483,7 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 	case ICMPV6_PARAMPROB:
 		teli = 0;
 		if ((*code) == ICMPV6_HDR_FIELD)
-			teli = parse_tlv_tnl_enc_lim(skb, skb->data);
+			teli = ip6_tnl_parse_tlv_enc_lim(skb, skb->data);
 
 		if (teli && teli == *info - 2) {
 			tel = (struct ipv6_tlv_tnl_enc_lim *) &skb->data[teli];
@@ -693,11 +696,11 @@ static void ip6ip6_dscp_ecn_decapsulate(const struct ip6_tnl *t,
 		IP6_ECN_set_ce(ipv6_hdr(skb));
 }
 
-static __u32 ip6_tnl_get_cap(struct ip6_tnl *t,
+__u32 ip6_tnl_get_cap(struct ip6_tnl *t,
 			     const struct in6_addr *laddr,
 			     const struct in6_addr *raddr)
 {
-	struct ip6_tnl_parm *p = &t->parms;
+	struct __ip6_tnl_parm *p = &t->parms;
 	int ltype = ipv6_addr_type(laddr);
 	int rtype = ipv6_addr_type(raddr);
 	__u32 flags = 0;
@@ -715,13 +718,14 @@ static __u32 ip6_tnl_get_cap(struct ip6_tnl *t,
 	}
 	return flags;
 }
+EXPORT_SYMBOL(ip6_tnl_get_cap);
 
 /* called with rcu_read_lock() */
-static inline int ip6_tnl_rcv_ctl(struct ip6_tnl *t,
+int ip6_tnl_rcv_ctl(struct ip6_tnl *t,
 				  const struct in6_addr *laddr,
 				  const struct in6_addr *raddr)
 {
-	struct ip6_tnl_parm *p = &t->parms;
+	struct __ip6_tnl_parm *p = &t->parms;
 	int ret = 0;
 	struct net *net = dev_net(t->dev);
 
@@ -740,6 +744,7 @@ static inline int ip6_tnl_rcv_ctl(struct ip6_tnl *t,
 	}
 	return ret;
 }
+EXPORT_SYMBOL_GPL(ip6_tnl_rcv_ctl);
 
 /**
  * ip6_tnl_rcv - decapsulate IPv6 packet and retransmit it locally
@@ -859,9 +864,9 @@ ip6_tnl_addr_conflict(const struct ip6_tnl *t, const struct ipv6hdr *hdr)
 	return ipv6_addr_equal(&t->parms.raddr, &hdr->saddr);
 }
 
-static inline int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
+int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
 {
-	struct ip6_tnl_parm *p = &t->parms;
+	struct __ip6_tnl_parm *p = &t->parms;
 	int ret = 0;
 	struct net *net = dev_net(t->dev);
 
@@ -885,6 +890,8 @@ static inline int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
 	}
 	return ret;
 }
+EXPORT_SYMBOL_GPL(ip6_tnl_xmit_ctl);
+
 /**
  * ip6_tnl_xmit2 - encapsulate packet and send
  *   @skb: the outgoing socket buffer
@@ -1085,7 +1092,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	    !ip6_tnl_xmit_ctl(t) || ip6_tnl_addr_conflict(t, ipv6h))
 		return -1;
 
-	offset = parse_tlv_tnl_enc_lim(skb, skb_network_header(skb));
+	offset = ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
 	if (offset > 0) {
 		struct ipv6_tlv_tnl_enc_lim *tel;
 		tel = (struct ipv6_tlv_tnl_enc_lim *)&skb_network_header(skb)[offset];
@@ -1152,7 +1159,7 @@ tx_err:
 static void ip6_tnl_link_config(struct ip6_tnl *t)
 {
 	struct net_device *dev = t->dev;
-	struct ip6_tnl_parm *p = &t->parms;
+	struct __ip6_tnl_parm *p = &t->parms;
 	struct flowi6 *fl6 = &t->fl.u.ip6;
 
 	memcpy(dev->dev_addr, &p->laddr, sizeof(struct in6_addr));
@@ -1215,7 +1222,7 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
  **/
 
 static int
-ip6_tnl_change(struct ip6_tnl *t, struct ip6_tnl_parm *p)
+ip6_tnl_change(struct ip6_tnl *t, const struct __ip6_tnl_parm *p)
 {
 	t->parms.laddr = p->laddr;
 	t->parms.raddr = p->raddr;
@@ -1230,6 +1237,32 @@ ip6_tnl_change(struct ip6_tnl *t, struct ip6_tnl_parm *p)
 	return 0;
 }
 
+static void ip6_tnl_parm_from_user(struct __ip6_tnl_parm *p, const struct ip6_tnl_parm *u)
+{
+	p->laddr = u->laddr;
+	p->raddr = u->raddr;
+	p->flags = u->flags;
+	p->hop_limit = u->hop_limit;
+	p->encap_limit = u->encap_limit;
+	p->flowinfo = u->flowinfo;
+	p->link = u->link;
+	p->proto = u->proto;
+	memcpy(p->name, u->name, sizeof(u->name));
+}
+
+static void ip6_tnl_parm_to_user(struct ip6_tnl_parm *u, const struct __ip6_tnl_parm *p)
+{
+	u->laddr = p->laddr;
+	u->raddr = p->raddr;
+	u->flags = p->flags;
+	u->hop_limit = p->hop_limit;
+	u->encap_limit = p->encap_limit;
+	u->flowinfo = p->flowinfo;
+	u->link = p->link;
+	u->proto = p->proto;
+	memcpy(u->name, p->name, sizeof(u->name));
+}
+
 /**
  * ip6_tnl_ioctl - configure ipv6 tunnels from userspace
  *   @dev: virtual device associated with tunnel
@@ -1263,6 +1296,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	int err = 0;
 	struct ip6_tnl_parm p;
+	struct __ip6_tnl_parm p1;
 	struct ip6_tnl *t = NULL;
 	struct net *net = dev_net(dev);
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
@@ -1274,11 +1308,12 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 				err = -EFAULT;
 				break;
 			}
-			t = ip6_tnl_locate(net, &p, 0);
+			ip6_tnl_parm_from_user(&p1, &p);
+			t = ip6_tnl_locate(net, &p1, 0);
 		}
 		if (t == NULL)
 			t = netdev_priv(dev);
-		memcpy(&p, &t->parms, sizeof (p));
+		ip6_tnl_parm_to_user(&p, &t->parms);
 		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof (p))) {
 			err = -EFAULT;
 		}
@@ -1295,7 +1330,8 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (p.proto != IPPROTO_IPV6 && p.proto != IPPROTO_IPIP &&
 		    p.proto != 0)
 			break;
-		t = ip6_tnl_locate(net, &p, cmd == SIOCADDTUNNEL);
+		ip6_tnl_parm_from_user(&p1, &p);
+		t = ip6_tnl_locate(net, &p1, cmd == SIOCADDTUNNEL);
 		if (dev != ip6n->fb_tnl_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
@@ -1307,13 +1343,14 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 			ip6_tnl_unlink(ip6n, t);
 			synchronize_net();
-			err = ip6_tnl_change(t, &p);
+			err = ip6_tnl_change(t, &p1);
 			ip6_tnl_link(ip6n, t);
 			netdev_state_change(dev);
 		}
 		if (t) {
 			err = 0;
-			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof (p)))
+			ip6_tnl_parm_to_user(&p, &t->parms);
+			if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof (p)))
 				err = -EFAULT;
 
 		} else
@@ -1329,7 +1366,8 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p)))
 				break;
 			err = -ENOENT;
-			if ((t = ip6_tnl_locate(net, &p, 0)) == NULL)
+			ip6_tnl_parm_from_user(&p1, &p);
+			if ((t = ip6_tnl_locate(net, &p1, 0)) == NULL)
 				break;
 			err = -EPERM;
 			if (t->dev == ip6n->fb_tnl_dev)
