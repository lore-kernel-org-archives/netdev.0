From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCHv4 net-next 08/12] ipv6: introduce neighbour discovery ops
Date: Wed, 15 Jun 2016 21:20:23 +0200
Message-ID: <20160615192027.4064-9-aar@pengutronix.de>
References: <20160615192027.4064-1-aar@pengutronix.de>
Cc: kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160615192027.4064-1-aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch introduces neighbour discovery ops callback structure. The
idea is to separate the handling for 6LoWPAN into the 6lowpan module.

These callback offers 6lowpan different handling, such as 802.15.4 short
address handling or RFC6775 (Neighbor Discovery Optimization for IPv6
over 6LoWPANs).

Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Acked-by: YOSHIFUJI Hideaki <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
Signed-off-by: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 include/linux/netdevice.h |   5 ++
 include/net/ndisc.h       | 197 +++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv6/addrconf.c       |  13 ++-
 net/ipv6/ndisc.c          | 101 ++++++++++++++++--------
 net/ipv6/route.c          |   8 +-
 5 files changed, 284 insertions(+), 40 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 36e43bd..890158e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1456,6 +1456,8 @@ enum netdev_priv_flags {
  *	@netdev_ops:	Includes several pointers to callbacks,
  *			if one wants to override the ndo_*() functions
  *	@ethtool_ops:	Management operations
+ *	@ndisc_ops:	Includes callbacks for different IPv6 neighbour
+ *			discovery handling. Necessary for e.g. 6LoWPAN.
  *	@header_ops:	Includes callbacks for creating,parsing,caching,etc
  *			of Layer 2 headers.
  *
@@ -1672,6 +1674,9 @@ struct net_device {
 #ifdef CONFIG_NET_L3_MASTER_DEV
 	const struct l3mdev_ops	*l3mdev_ops;
 #endif
+#if IS_ENABLED(CONFIG_IPV6)
+	const struct ndisc_ops *ndisc_ops;
+#endif
 
 	const struct header_ops *header_ops;
 
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index c8962ad..a5e2767 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -58,6 +58,7 @@ struct inet6_dev;
 struct net_device;
 struct net_proto_family;
 struct sk_buff;
+struct prefix_info;
 
 extern struct neigh_table nd_tbl;
 
@@ -110,9 +111,182 @@ struct ndisc_options {
 
 #define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)
 
-struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
+struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
+					  u8 *opt, int opt_len,
 					  struct ndisc_options *ndopts);
 
+#define NDISC_OPS_REDIRECT_DATA_SPACE	2
+
+/*
+ * This structure defines the hooks for IPv6 neighbour discovery.
+ * The following hooks can be defined; unless noted otherwise, they are
+ * optional and can be filled with a null pointer.
+ *
+ * int (*is_useropt)(u8 nd_opt_type):
+ *     This function is called when IPv6 decide RA userspace options. if
+ *     this function returns 1 then the option given by nd_opt_type will
+ *     be handled as userspace option additional to the IPv6 options.
+ *
+ * int (*parse_options)(const struct net_device *dev,
+ *			struct nd_opt_hdr *nd_opt,
+ *			struct ndisc_options *ndopts):
+ *     This function is called while parsing ndisc ops and put each position
+ *     as pointer into ndopts. If this function return unequal 0, then this
+ *     function took care about the ndisc option, if 0 then the IPv6 ndisc
+ *     option parser will take care about that option.
+ *
+ * void (*update)(const struct net_device *dev, struct neighbour *n,
+ *		  u32 flags, u8 icmp6_type,
+ *		  const struct ndisc_options *ndopts):
+ *     This function is called when IPv6 ndisc updates the neighbour cache
+ *     entry. Additional options which can be updated may be previously
+ *     parsed by parse_opts callback and accessible over ndopts parameter.
+ *
+ * int (*opt_addr_space)(const struct net_device *dev, u8 icmp6_type,
+ *			 struct neighbour *neigh, u8 *ha_buf,
+ *			 u8 **ha):
+ *     This function is called when the necessary option space will be
+ *     calculated before allocating a skb. The parameters neigh, ha_buf
+ *     abd ha are available on NDISC_REDIRECT messages only.
+ *
+ * void (*fill_addr_option)(const struct net_device *dev,
+ *			    struct sk_buff *skb, u8 icmp6_type,
+ *			    const u8 *ha):
+ *     This function is called when the skb will finally fill the option
+ *     fields inside skb. NOTE: this callback should fill the option
+ *     fields to the skb which are previously indicated by opt_space
+ *     parameter. That means the decision to add such option should
+ *     not lost between these two callbacks, e.g. protected by interface
+ *     up state.
+ *
+ * void (*prefix_rcv_add_addr)(struct net *net, struct net_device *dev,
+ *			       const struct prefix_info *pinfo,
+ *			       struct inet6_dev *in6_dev,
+ *			       struct in6_addr *addr,
+ *			       int addr_type, u32 addr_flags,
+ *			       bool sllao, bool tokenized,
+ *			       __u32 valid_lft, u32 prefered_lft,
+ *			       bool dev_addr_generated):
+ *     This function is called when a RA messages is received with valid
+ *     PIO option fields and an IPv6 address will be added to the interface
+ *     for autoconfiguration. The parameter dev_addr_generated reports about
+ *     if the address was based on dev->dev_addr or not. This can be used
+ *     to add a second address if link-layer operates with two link layer
+ *     addresses. E.g. 802.15.4 6LoWPAN.
+ */
+struct ndisc_ops {
+	int	(*is_useropt)(u8 nd_opt_type);
+	int	(*parse_options)(const struct net_device *dev,
+				 struct nd_opt_hdr *nd_opt,
+				 struct ndisc_options *ndopts);
+	void	(*update)(const struct net_device *dev, struct neighbour *n,
+			  u32 flags, u8 icmp6_type,
+			  const struct ndisc_options *ndopts);
+	int	(*opt_addr_space)(const struct net_device *dev, u8 icmp6_type,
+				  struct neighbour *neigh, u8 *ha_buf,
+				  u8 **ha);
+	void	(*fill_addr_option)(const struct net_device *dev,
+				    struct sk_buff *skb, u8 icmp6_type,
+				    const u8 *ha);
+	void	(*prefix_rcv_add_addr)(struct net *net, struct net_device *dev,
+				       const struct prefix_info *pinfo,
+				       struct inet6_dev *in6_dev,
+				       struct in6_addr *addr,
+				       int addr_type, u32 addr_flags,
+				       bool sllao, bool tokenized,
+				       __u32 valid_lft, u32 prefered_lft,
+				       bool dev_addr_generated);
+};
+
+#if IS_ENABLED(CONFIG_IPV6)
+static inline int ndisc_ops_is_useropt(const struct net_device *dev,
+				       u8 nd_opt_type)
+{
+	if (dev->ndisc_ops && dev->ndisc_ops->is_useropt)
+		return dev->ndisc_ops->is_useropt(nd_opt_type);
+	else
+		return 0;
+}
+
+static inline int ndisc_ops_parse_options(const struct net_device *dev,
+					  struct nd_opt_hdr *nd_opt,
+					  struct ndisc_options *ndopts)
+{
+	if (dev->ndisc_ops && dev->ndisc_ops->parse_options)
+		return dev->ndisc_ops->parse_options(dev, nd_opt, ndopts);
+	else
+		return 0;
+}
+
+static inline void ndisc_ops_update(const struct net_device *dev,
+					  struct neighbour *n, u32 flags,
+					  u8 icmp6_type,
+					  const struct ndisc_options *ndopts)
+{
+	if (dev->ndisc_ops && dev->ndisc_ops->update)
+		dev->ndisc_ops->update(dev, n, flags, icmp6_type, ndopts);
+}
+
+static inline int ndisc_ops_opt_addr_space(const struct net_device *dev,
+					   u8 icmp6_type)
+{
+	if (dev->ndisc_ops && dev->ndisc_ops->opt_addr_space &&
+	    icmp6_type != NDISC_REDIRECT)
+		return dev->ndisc_ops->opt_addr_space(dev, icmp6_type, NULL,
+						      NULL, NULL);
+	else
+		return 0;
+}
+
+static inline int ndisc_ops_redirect_opt_addr_space(const struct net_device *dev,
+						    struct neighbour *neigh,
+						    u8 *ha_buf, u8 **ha)
+{
+	if (dev->ndisc_ops && dev->ndisc_ops->opt_addr_space)
+		return dev->ndisc_ops->opt_addr_space(dev, NDISC_REDIRECT,
+						      neigh, ha_buf, ha);
+	else
+		return 0;
+}
+
+static inline void ndisc_ops_fill_addr_option(const struct net_device *dev,
+					      struct sk_buff *skb,
+					      u8 icmp6_type)
+{
+	if (dev->ndisc_ops && dev->ndisc_ops->fill_addr_option &&
+	    icmp6_type != NDISC_REDIRECT)
+		dev->ndisc_ops->fill_addr_option(dev, skb, icmp6_type, NULL);
+}
+
+static inline void ndisc_ops_fill_redirect_addr_option(const struct net_device *dev,
+						       struct sk_buff *skb,
+						       const u8 *ha)
+{
+	if (dev->ndisc_ops && dev->ndisc_ops->fill_addr_option)
+		dev->ndisc_ops->fill_addr_option(dev, skb, NDISC_REDIRECT, ha);
+}
+
+static inline void ndisc_ops_prefix_rcv_add_addr(struct net *net,
+						 struct net_device *dev,
+						 const struct prefix_info *pinfo,
+						 struct inet6_dev *in6_dev,
+						 struct in6_addr *addr,
+						 int addr_type, u32 addr_flags,
+						 bool sllao, bool tokenized,
+						 __u32 valid_lft,
+						 u32 prefered_lft,
+						 bool dev_addr_generated)
+{
+	if (dev->ndisc_ops && dev->ndisc_ops->prefix_rcv_add_addr)
+		dev->ndisc_ops->prefix_rcv_add_addr(net, dev, pinfo, in6_dev,
+						    addr, addr_type,
+						    addr_flags, sllao,
+						    tokenized, valid_lft,
+						    prefered_lft,
+						    dev_addr_generated);
+}
+#endif
+
 /*
  * Return the padding between the option length and the start of the
  * link addr.  Currently only IP-over-InfiniBand needs this, although
@@ -132,11 +306,25 @@ static inline int __ndisc_opt_addr_space(unsigned char addr_len, int pad)
 	return NDISC_OPT_SPACE(addr_len + pad);
 }
 
-static inline int ndisc_opt_addr_space(struct net_device *dev)
+#if IS_ENABLED(CONFIG_IPV6)
+static inline int ndisc_opt_addr_space(struct net_device *dev, u8 icmp6_type)
+{
+	return __ndisc_opt_addr_space(dev->addr_len,
+				      ndisc_addr_option_pad(dev->type)) +
+		ndisc_ops_opt_addr_space(dev, icmp6_type);
+}
+
+static inline int ndisc_redirect_opt_addr_space(struct net_device *dev,
+						struct neighbour *neigh,
+						u8 *ops_data_buf,
+						u8 **ops_data)
 {
 	return __ndisc_opt_addr_space(dev->addr_len,
-				      ndisc_addr_option_pad(dev->type));
+				      ndisc_addr_option_pad(dev->type)) +
+		ndisc_ops_redirect_opt_addr_space(dev, neigh, ops_data_buf,
+						  ops_data);
 }
+#endif
 
 static inline u8 *__ndisc_opt_addr_data(struct nd_opt_hdr *p,
 					unsigned char addr_len, int prepad)
@@ -205,6 +393,9 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target);
 int ndisc_mc_map(const struct in6_addr *addr, char *buf, struct net_device *dev,
 		 int dir);
 
+void ndisc_update(const struct net_device *dev, struct neighbour *neigh,
+		  const u8 *lladdr, u8 new, u32 flags, u8 icmp6_type,
+		  struct ndisc_options *ndopts);
 
 /*
  *	IGMP
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0ca31e1..2d678c0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2531,7 +2531,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 
 	if (pinfo->autoconf && in6_dev->cnf.autoconf) {
 		struct in6_addr addr;
-		bool tokenized = false;
+		bool tokenized = false, dev_addr_generated = false;
 
 		if (pinfo->prefix_len == 64) {
 			memcpy(&addr, &pinfo->prefix, 8);
@@ -2550,6 +2550,8 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 			} else if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
 				   ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
 				goto put;
+			} else {
+				dev_addr_generated = true;
 			}
 			goto ok;
 		}
@@ -2565,6 +2567,15 @@ ok:
 						   prefered_lft);
 		if (err)
 			goto put;
+
+		/* Ignore error case here because previous prefix add addr was
+		 * successful which will be notified.
+		 */
+		ndisc_ops_prefix_rcv_add_addr(net, dev, pinfo, in6_dev, &addr,
+					      addr_type, addr_flags, sllao,
+					      tokenized, valid_lft,
+					      prefered_lft,
+					      dev_addr_generated);
 	}
 	inet6_prefix_notify(RTM_NEWPREFIX, in6_dev, pinfo);
 put:
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index a7b9468..2f4afd1 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -172,10 +172,19 @@ static void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
 }
 
 static inline void ndisc_fill_addr_option(struct sk_buff *skb, int type,
-					  void *data)
+					  void *data, u8 icmp6_type)
 {
 	__ndisc_fill_addr_option(skb, type, data, skb->dev->addr_len,
 				 ndisc_addr_option_pad(skb->dev->type));
+	ndisc_ops_fill_addr_option(skb->dev, skb, icmp6_type);
+}
+
+static inline void ndisc_fill_redirect_addr_option(struct sk_buff *skb,
+						   void *ha,
+						   const u8 *ops_data)
+{
+	ndisc_fill_addr_option(skb, ND_OPT_TARGET_LL_ADDR, ha, NDISC_REDIRECT);
+	ndisc_ops_fill_redirect_addr_option(skb->dev, skb, ops_data);
 }
 
 static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
@@ -191,24 +200,28 @@ static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
 	return cur <= end && cur->nd_opt_type == type ? cur : NULL;
 }
 
-static inline int ndisc_is_useropt(struct nd_opt_hdr *opt)
+static inline int ndisc_is_useropt(const struct net_device *dev,
+				   struct nd_opt_hdr *opt)
 {
 	return opt->nd_opt_type == ND_OPT_RDNSS ||
-		opt->nd_opt_type == ND_OPT_DNSSL;
+		opt->nd_opt_type == ND_OPT_DNSSL ||
+		ndisc_ops_is_useropt(dev, opt->nd_opt_type);
 }
 
-static struct nd_opt_hdr *ndisc_next_useropt(struct nd_opt_hdr *cur,
+static struct nd_opt_hdr *ndisc_next_useropt(const struct net_device *dev,
+					     struct nd_opt_hdr *cur,
 					     struct nd_opt_hdr *end)
 {
 	if (!cur || !end || cur >= end)
 		return NULL;
 	do {
 		cur = ((void *)cur) + (cur->nd_opt_len << 3);
-	} while (cur < end && !ndisc_is_useropt(cur));
-	return cur <= end && ndisc_is_useropt(cur) ? cur : NULL;
+	} while (cur < end && !ndisc_is_useropt(dev, cur));
+	return cur <= end && ndisc_is_useropt(dev, cur) ? cur : NULL;
 }
 
-struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
+struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
+					  u8 *opt, int opt_len,
 					  struct ndisc_options *ndopts)
 {
 	struct nd_opt_hdr *nd_opt = (struct nd_opt_hdr *)opt;
@@ -223,6 +236,8 @@ struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
 		l = nd_opt->nd_opt_len << 3;
 		if (opt_len < l || l == 0)
 			return NULL;
+		if (ndisc_ops_parse_options(dev, nd_opt, ndopts))
+			goto next_opt;
 		switch (nd_opt->nd_opt_type) {
 		case ND_OPT_SOURCE_LL_ADDR:
 		case ND_OPT_TARGET_LL_ADDR:
@@ -249,7 +264,7 @@ struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
 			break;
 #endif
 		default:
-			if (ndisc_is_useropt(nd_opt)) {
+			if (ndisc_is_useropt(dev, nd_opt)) {
 				ndopts->nd_useropts_end = nd_opt;
 				if (!ndopts->nd_useropts)
 					ndopts->nd_useropts = nd_opt;
@@ -266,6 +281,7 @@ struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
 					  nd_opt->nd_opt_len);
 			}
 		}
+next_opt:
 		opt_len -= l;
 		nd_opt = ((void *)nd_opt) + l;
 	}
@@ -515,7 +531,8 @@ void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
 	if (!dev->addr_len)
 		inc_opt = 0;
 	if (inc_opt)
-		optlen += ndisc_opt_addr_space(dev);
+		optlen += ndisc_opt_addr_space(dev,
+					       NDISC_NEIGHBOUR_ADVERTISEMENT);
 
 	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
 	if (!skb)
@@ -534,8 +551,8 @@ void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
 
 	if (inc_opt)
 		ndisc_fill_addr_option(skb, ND_OPT_TARGET_LL_ADDR,
-				       dev->dev_addr);
-
+				       dev->dev_addr,
+				       NDISC_NEIGHBOUR_ADVERTISEMENT);
 
 	ndisc_send_skb(skb, daddr, src_addr);
 }
@@ -580,7 +597,8 @@ void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
 	if (ipv6_addr_any(saddr))
 		inc_opt = false;
 	if (inc_opt)
-		optlen += ndisc_opt_addr_space(dev);
+		optlen += ndisc_opt_addr_space(dev,
+					       NDISC_NEIGHBOUR_SOLICITATION);
 
 	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
 	if (!skb)
@@ -596,7 +614,8 @@ void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
 
 	if (inc_opt)
 		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
-				       dev->dev_addr);
+				       dev->dev_addr,
+				       NDISC_NEIGHBOUR_SOLICITATION);
 
 	ndisc_send_skb(skb, daddr, saddr);
 }
@@ -632,7 +651,7 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 	}
 #endif
 	if (send_sllao)
-		optlen += ndisc_opt_addr_space(dev);
+		optlen += ndisc_opt_addr_space(dev, NDISC_ROUTER_SOLICITATION);
 
 	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
 	if (!skb)
@@ -647,7 +666,8 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 
 	if (send_sllao)
 		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
-				       dev->dev_addr);
+				       dev->dev_addr,
+				       NDISC_ROUTER_SOLICITATION);
 
 	ndisc_send_skb(skb, daddr, saddr);
 }
@@ -708,6 +728,15 @@ static int pndisc_is_router(const void *pkey,
 	return ret;
 }
 
+void ndisc_update(const struct net_device *dev, struct neighbour *neigh,
+		  const u8 *lladdr, u8 new, u32 flags, u8 icmp6_type,
+		  struct ndisc_options *ndopts)
+{
+	neigh_update(neigh, lladdr, new, flags);
+	/* report ndisc ops about neighbour update */
+	ndisc_ops_update(dev, neigh, flags, icmp6_type, ndopts);
+}
+
 static void ndisc_recv_ns(struct sk_buff *skb)
 {
 	struct nd_msg *msg = (struct nd_msg *)skb_transport_header(skb);
@@ -744,7 +773,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 		return;
 	}
 
-	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
+	if (!ndisc_parse_options(dev, msg->opt, ndoptlen, &ndopts)) {
 		ND_PRINTK(2, warn, "NS: invalid ND options\n");
 		return;
 	}
@@ -862,9 +891,10 @@ have_ifp:
 	neigh = __neigh_lookup(&nd_tbl, saddr, dev,
 			       !inc || lladdr || !dev->addr_len);
 	if (neigh)
-		neigh_update(neigh, lladdr, NUD_STALE,
+		ndisc_update(dev, neigh, lladdr, NUD_STALE,
 			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
-			     NEIGH_UPDATE_F_OVERRIDE);
+			     NEIGH_UPDATE_F_OVERRIDE,
+			     NDISC_NEIGHBOUR_SOLICITATION, &ndopts);
 	if (neigh || !dev->header_ops) {
 		ndisc_send_na(dev, saddr, &msg->target, !!is_router,
 			      true, (ifp != NULL && inc), inc);
@@ -917,7 +947,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
 	    idev->cnf.drop_unsolicited_na)
 		return;
 
-	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
+	if (!ndisc_parse_options(dev, msg->opt, ndoptlen, &ndopts)) {
 		ND_PRINTK(2, warn, "NS: invalid ND option\n");
 		return;
 	}
@@ -973,12 +1003,13 @@ static void ndisc_recv_na(struct sk_buff *skb)
 			goto out;
 		}
 
-		neigh_update(neigh, lladdr,
+		ndisc_update(dev, neigh, lladdr,
 			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
 			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
 			     (msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0)|
 			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
-			     (msg->icmph.icmp6_router ? NEIGH_UPDATE_F_ISROUTER : 0));
+			     (msg->icmph.icmp6_router ? NEIGH_UPDATE_F_ISROUTER : 0),
+			     NDISC_NEIGHBOUR_ADVERTISEMENT, &ndopts);
 
 		if ((old_flags & ~neigh->flags) & NTF_ROUTER) {
 			/*
@@ -1023,7 +1054,7 @@ static void ndisc_recv_rs(struct sk_buff *skb)
 		goto out;
 
 	/* Parse ND options */
-	if (!ndisc_parse_options(rs_msg->opt, ndoptlen, &ndopts)) {
+	if (!ndisc_parse_options(skb->dev, rs_msg->opt, ndoptlen, &ndopts)) {
 		ND_PRINTK(2, notice, "NS: invalid ND option, ignored\n");
 		goto out;
 	}
@@ -1037,10 +1068,11 @@ static void ndisc_recv_rs(struct sk_buff *skb)
 
 	neigh = __neigh_lookup(&nd_tbl, saddr, skb->dev, 1);
 	if (neigh) {
-		neigh_update(neigh, lladdr, NUD_STALE,
+		ndisc_update(skb->dev, neigh, lladdr, NUD_STALE,
 			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
 			     NEIGH_UPDATE_F_OVERRIDE|
-			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER);
+			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER,
+			     NDISC_ROUTER_SOLICITATION, &ndopts);
 		neigh_release(neigh);
 	}
 out:
@@ -1141,7 +1173,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		return;
 	}
 
-	if (!ndisc_parse_options(opt, optlen, &ndopts)) {
+	if (!ndisc_parse_options(skb->dev, opt, optlen, &ndopts)) {
 		ND_PRINTK(2, warn, "RA: invalid ND options\n");
 		return;
 	}
@@ -1335,11 +1367,12 @@ skip_linkparms:
 				goto out;
 			}
 		}
-		neigh_update(neigh, lladdr, NUD_STALE,
+		ndisc_update(skb->dev, neigh, lladdr, NUD_STALE,
 			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
 			     NEIGH_UPDATE_F_OVERRIDE|
 			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
-			     NEIGH_UPDATE_F_ISROUTER);
+			     NEIGH_UPDATE_F_ISROUTER,
+			     NDISC_ROUTER_ADVERTISEMENT, &ndopts);
 	}
 
 	if (!ipv6_accept_ra(in6_dev)) {
@@ -1427,7 +1460,8 @@ skip_routeinfo:
 		struct nd_opt_hdr *p;
 		for (p = ndopts.nd_useropts;
 		     p;
-		     p = ndisc_next_useropt(p, ndopts.nd_useropts_end)) {
+		     p = ndisc_next_useropt(skb->dev, p,
+					    ndopts.nd_useropts_end)) {
 			ndisc_ra_useropt(skb, p);
 		}
 	}
@@ -1465,7 +1499,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 		return;
 	}
 
-	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts))
+	if (!ndisc_parse_options(skb->dev, msg->opt, ndoptlen, &ndopts))
 		return;
 
 	if (!ndopts.nd_opts_rh) {
@@ -1510,7 +1544,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	struct dst_entry *dst;
 	struct flowi6 fl6;
 	int rd_len;
-	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
+	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL,
+	   ops_data_buf[NDISC_OPS_REDIRECT_DATA_SPACE], *ops_data = NULL;
 	int oif = l3mdev_fib_oif(dev);
 	bool ret;
 
@@ -1569,7 +1604,9 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 			memcpy(ha_buf, neigh->ha, dev->addr_len);
 			read_unlock_bh(&neigh->lock);
 			ha = ha_buf;
-			optlen += ndisc_opt_addr_space(dev);
+			optlen += ndisc_redirect_opt_addr_space(dev, neigh,
+								ops_data_buf,
+								&ops_data);
 		} else
 			read_unlock_bh(&neigh->lock);
 
@@ -1600,7 +1637,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	 */
 
 	if (ha)
-		ndisc_fill_addr_option(buff, ND_OPT_TARGET_LL_ADDR, ha);
+		ndisc_fill_redirect_addr_option(buff, ha, ops_data);
 
 	/*
 	 *	build redirect option and copy skb over to the new packet.
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c6ae6f9..af6f711 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2200,7 +2200,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	 *	first-hop router for the specified ICMP Destination Address.
 	 */
 
-	if (!ndisc_parse_options(msg->opt, optlen, &ndopts)) {
+	if (!ndisc_parse_options(skb->dev, msg->opt, optlen, &ndopts)) {
 		net_dbg_ratelimited("rt6_redirect: invalid ND options\n");
 		return;
 	}
@@ -2235,12 +2235,12 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	 *	We have finally decided to accept it.
 	 */
 
-	neigh_update(neigh, lladdr, NUD_STALE,
+	ndisc_update(skb->dev, neigh, lladdr, NUD_STALE,
 		     NEIGH_UPDATE_F_WEAK_OVERRIDE|
 		     NEIGH_UPDATE_F_OVERRIDE|
 		     (on_link ? 0 : (NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
-				     NEIGH_UPDATE_F_ISROUTER))
-		     );
+				     NEIGH_UPDATE_F_ISROUTER)),
+		     NDISC_REDIRECT, &ndopts);
 
 	nrt = ip6_rt_cache_alloc(rt, &msg->dest, NULL);
 	if (!nrt)
-- 
2.8.3
