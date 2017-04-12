From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next 05/14] xfrm: Add an IPsec hardware offloading API
Date: Wed, 12 Apr 2017 08:26:44 +0200
Message-ID: <1491978413-5700-6-git-send-email-steffen.klassert@secunet.com>
References: <1491978413-5700-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:57574 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751159AbdDLG2q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 02:28:46 -0400
In-Reply-To: <1491978413-5700-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds all the bits that are needed to do
IPsec hardware offload for IPsec states and ESP packets.
We add xfrmdev_ops to the net_device. xfrmdev_ops has
function pointers that are needed to manage the xfrm
states in the hardware and to do a per packet
offloading decision.

Joint work with:
Ilan Tayari <ilant@mellanox.com>
Guy Shapiro <guysh@mellanox.com>
Yossi Kuperman <yossiku@mellanox.com>

Signed-off-by: Guy Shapiro <guysh@mellanox.com>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Yossi Kuperman <yossiku@mellanox.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/netdevice.h |  14 +++++
 include/net/xfrm.h        |  65 +++++++++++++++++++++-
 include/uapi/linux/xfrm.h |   8 +++
 net/ipv4/esp4.c           |   7 +--
 net/ipv4/xfrm4_output.c   |   3 +-
 net/ipv6/esp6.c           |   4 +-
 net/ipv6/xfrm6_output.c   |   9 ++-
 net/xfrm/Makefile         |   3 +-
 net/xfrm/xfrm_device.c    | 138 +++++++++++++++++++++++++++++++++++++++++++++-
 net/xfrm/xfrm_input.c     |  41 +++++++++++++-
 net/xfrm/xfrm_output.c    |  44 +++++++++++++--
 net/xfrm/xfrm_policy.c    |  10 ++--
 net/xfrm/xfrm_state.c     |  74 +++++++++++++++++++++++++
 net/xfrm/xfrm_user.c      |  28 ++++++++++
 14 files changed, 424 insertions(+), 24 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5bb03d1..b3eb83d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -824,6 +824,16 @@ struct netdev_xdp {
 	};
 };
 
+#ifdef CONFIG_XFRM_OFFLOAD
+struct xfrmdev_ops {
+	int	(*xdo_dev_state_add) (struct xfrm_state *x);
+	void	(*xdo_dev_state_delete) (struct xfrm_state *x);
+	void	(*xdo_dev_state_free) (struct xfrm_state *x);
+	bool	(*xdo_dev_offload_ok) (struct sk_buff *skb,
+				       struct xfrm_state *x);
+};
+#endif
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1697,6 +1707,10 @@ struct net_device {
 	const struct ndisc_ops *ndisc_ops;
 #endif
 
+#ifdef CONFIG_XFRM
+	const struct xfrmdev_ops *xfrmdev_ops;
+#endif
+
 	const struct header_ops *header_ops;
 
 	unsigned int		flags;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 54515d9..17603bf 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -120,6 +120,13 @@ struct xfrm_state_walk {
 	struct xfrm_address_filter *filter;
 };
 
+struct xfrm_state_offload {
+	struct net_device	*dev;
+	unsigned long		offload_handle;
+	unsigned int		num_exthdrs;
+	u8			flags;
+};
+
 /* Full description of state of transformer. */
 struct xfrm_state {
 	possible_net_t		xs_net;
@@ -207,6 +214,8 @@ struct xfrm_state {
 	struct xfrm_lifetime_cur curlft;
 	struct tasklet_hrtimer	mtimer;
 
+	struct xfrm_state_offload xso;
+
 	/* used to fix curlft->add_time when changing date */
 	long		saved_tmo;
 
@@ -1453,7 +1462,6 @@ struct xfrm6_tunnel {
 void xfrm_init(void);
 void xfrm4_init(void);
 int xfrm_state_init(struct net *net);
-void xfrm_dev_init(void);
 void xfrm_state_fini(struct net *net);
 void xfrm4_state_init(void);
 void xfrm4_protocol_init(void);
@@ -1559,6 +1567,7 @@ struct xfrmk_spdinfo {
 struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 mark, u32 seq);
 int xfrm_state_delete(struct xfrm_state *x);
 int xfrm_state_flush(struct net *net, u8 proto, bool task_valid);
+int xfrm_dev_state_flush(struct net *net, struct net_device *dev, bool task_valid);
 void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si);
 void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si);
 u32 xfrm_replay_seqhi(struct xfrm_state *x, __be32 net_seq);
@@ -1641,6 +1650,11 @@ static inline int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
 }
 #endif
 
+struct dst_entry *__xfrm_dst_lookup(struct net *net, int tos, int oif,
+				    const xfrm_address_t *saddr,
+				    const xfrm_address_t *daddr,
+				    int family);
+
 struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp);
 
 void xfrm_policy_walk_init(struct xfrm_policy_walk *walk, u8 type);
@@ -1846,6 +1860,55 @@ static inline struct xfrm_offload *xfrm_offload(struct sk_buff *skb)
 }
 #endif
 
+#ifdef CONFIG_XFRM_OFFLOAD
+void __net_init xfrm_dev_init(void);
+int xfrm_dev_state_add(struct net *net, struct xfrm_state *x,
+		       struct xfrm_user_offload *xuo);
+bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x);
+
+static inline void xfrm_dev_state_delete(struct xfrm_state *x)
+{
+	struct xfrm_state_offload *xso = &x->xso;
+
+	if (xso->dev)
+		xso->dev->xfrmdev_ops->xdo_dev_state_delete(x);
+}
+
+static inline void xfrm_dev_state_free(struct xfrm_state *x)
+{
+	struct xfrm_state_offload *xso = &x->xso;
+	 struct net_device *dev = xso->dev;
+
+	if (dev && dev->xfrmdev_ops) {
+		dev->xfrmdev_ops->xdo_dev_state_free(x);
+		xso->dev = NULL;
+		dev_put(dev);
+	}
+}
+#else
+static inline void __net_init xfrm_dev_init(void)
+{
+}
+
+static inline int xfrm_dev_state_add(struct net *net, struct xfrm_state *x, struct xfrm_user_offload *xuo)
+{
+	return 0;
+}
+
+static inline void xfrm_dev_state_delete(struct xfrm_state *x)
+{
+}
+
+static inline void xfrm_dev_state_free(struct xfrm_state *x)
+{
+}
+
+static inline bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x)
+{
+	return false;
+}
+#endif
+
 static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_mark *m)
 {
 	if (attrs[XFRMA_MARK])
diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index 1fc62b2..2b384ff 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -303,6 +303,7 @@ enum xfrm_attr_type_t {
 	XFRMA_PROTO,		/* __u8 */
 	XFRMA_ADDRESS_FILTER,	/* struct xfrm_address_filter */
 	XFRMA_PAD,
+	XFRMA_OFFLOAD_DEV,	/* struct xfrm_state_offload */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -494,6 +495,13 @@ struct xfrm_address_filter {
 	__u8				dplen;
 };
 
+struct xfrm_user_offload {
+	int				ifindex;
+	__u8				flags;
+};
+#define XFRM_OFFLOAD_IPV6	1
+#define XFRM_OFFLOAD_INBOUND	2
+
 #ifndef __KERNEL__
 /* backwards compatibility for userspace */
 #define XFRMGRP_ACQUIRE		1
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index b1e2444..c6aba23 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -435,9 +435,6 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	aead_request_set_crypt(req, sg, dsg, ivlen + clen, iv);
 	aead_request_set_ad(req, assoclen);
 
-	seqno = cpu_to_be64(XFRM_SKB_CB(skb)->seq.output.low +
-			    ((u64)XFRM_SKB_CB(skb)->seq.output.hi << 32));
-
 	memset(iv, 0, ivlen);
 	memcpy(iv + ivlen - min(ivlen, 8), (u8 *)&seqno + 8 - min(ivlen, 8),
 	       min(ivlen, 8));
@@ -470,6 +467,7 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 {
 	const struct iphdr *iph;
 	struct xfrm_state *x = xfrm_input_state(skb);
+	struct xfrm_offload *xo = xfrm_offload(skb);
 	struct crypto_aead *aead = x->data;
 	int alen = crypto_aead_authsize(aead);
 	int hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
@@ -478,7 +476,8 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 	u8 nexthdr[2];
 	int padlen;
 
-	kfree(ESP_SKB_CB(skb)->tmp);
+	if (!xo || (xo && !(xo->flags & CRYPTO_DONE)))
+		kfree(ESP_SKB_CB(skb)->tmp);
 
 	if (unlikely(err))
 		goto out;
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 7ee6518..94b8702 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -29,7 +29,8 @@ static int xfrm4_tunnel_check_size(struct sk_buff *skb)
 		goto out;
 
 	mtu = dst_mtu(skb_dst(skb));
-	if (skb->len > mtu) {
+	if ((!skb_is_gso(skb) && skb->len > mtu) ||
+	    (skb_is_gso(skb) && skb_gso_network_seglen(skb) > ip_skb_dst_mtu(skb->sk, skb))) {
 		skb->protocol = htons(ETH_P_IP);
 
 		if (skb->sk)
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index ff54faa..3d3757d 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -450,6 +450,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 static int esp_input_done2(struct sk_buff *skb, int err)
 {
 	struct xfrm_state *x = xfrm_input_state(skb);
+	struct xfrm_offload *xo = xfrm_offload(skb);
 	struct crypto_aead *aead = x->data;
 	int alen = crypto_aead_authsize(aead);
 	int hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
@@ -458,7 +459,8 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 	int padlen;
 	u8 nexthdr[2];
 
-	kfree(ESP_SKB_CB(skb)->tmp);
+	if (!xo || (xo && !(xo->flags & CRYPTO_DONE)))
+		kfree(ESP_SKB_CB(skb)->tmp);
 
 	if (unlikely(err))
 		goto out;
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 4d09ce6..8ae87d4 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -73,11 +73,16 @@ static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 	int mtu, ret = 0;
 	struct dst_entry *dst = skb_dst(skb);
 
+	if (skb->ignore_df)
+		goto out;
+
 	mtu = dst_mtu(dst);
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
 
-	if (!skb->ignore_df && skb->len > mtu) {
+	if ((!skb_is_gso(skb) && skb->len > mtu) ||
+	    (skb_is_gso(skb) &&
+	     skb_gso_network_seglen(skb) > ip6_skb_dst_mtu(skb))) {
 		skb->dev = dst->dev;
 		skb->protocol = htons(ETH_P_IPV6);
 
@@ -89,7 +94,7 @@ static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		ret = -EMSGSIZE;
 	}
-
+out:
 	return ret;
 }
 
diff --git a/net/xfrm/Makefile b/net/xfrm/Makefile
index 55b2ac3..abf81b3 100644
--- a/net/xfrm/Makefile
+++ b/net/xfrm/Makefile
@@ -4,7 +4,8 @@
 
 obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_hash.o \
 		      xfrm_input.o xfrm_output.o \
-		      xfrm_sysctl.o xfrm_replay.o xfrm_device.o
+		      xfrm_sysctl.o xfrm_replay.o
+obj-$(CONFIG_XFRM_OFFLOAD) += xfrm_device.o
 obj-$(CONFIG_XFRM_STATISTICS) += xfrm_proc.o
 obj-$(CONFIG_XFRM_ALGO) += xfrm_algo.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index 34a260a..9bac2ba 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -22,13 +22,149 @@
 #include <net/xfrm.h>
 #include <linux/notifier.h>
 
+int xfrm_dev_state_add(struct net *net, struct xfrm_state *x,
+		       struct xfrm_user_offload *xuo)
+{
+	int err;
+	struct dst_entry *dst;
+	struct net_device *dev;
+	struct xfrm_state_offload *xso = &x->xso;
+	xfrm_address_t *saddr;
+	xfrm_address_t *daddr;
+
+	if (!x->type_offload)
+		return 0;
+
+	/* We don't yet support UDP encapsulation, TFC padding and ESN. */
+	if (x->encap || x->tfcpad || (x->props.flags & XFRM_STATE_ESN))
+		return 0;
+
+	dev = dev_get_by_index(net, xuo->ifindex);
+	if (!dev) {
+		if (!(xuo->flags & XFRM_OFFLOAD_INBOUND)) {
+			saddr = &x->props.saddr;
+			daddr = &x->id.daddr;
+		} else {
+			saddr = &x->id.daddr;
+			daddr = &x->props.saddr;
+		}
+
+		dst = __xfrm_dst_lookup(net, 0, 0, saddr, daddr, x->props.family);
+		if (IS_ERR(dst))
+			return 0;
+
+		dev = dst->dev;
+
+		dev_hold(dev);
+		dst_release(dst);
+	}
+
+	if (!dev->xfrmdev_ops || !dev->xfrmdev_ops->xdo_dev_state_add) {
+		dev_put(dev);
+		return 0;
+	}
+
+	xso->dev = dev;
+	xso->num_exthdrs = 1;
+	xso->flags = xuo->flags;
+
+	err = dev->xfrmdev_ops->xdo_dev_state_add(x);
+	if (err) {
+		dev_put(dev);
+		return err;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(xfrm_dev_state_add);
+
+bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x)
+{
+	int mtu;
+	struct dst_entry *dst = skb_dst(skb);
+	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+	struct net_device *dev = x->xso.dev;
+
+	if (!x->type_offload || x->encap)
+		return false;
+
+	if ((x->xso.offload_handle && (dev == dst->path->dev)) &&
+	     !dst->child->xfrm && x->type->get_mtu) {
+		mtu = x->type->get_mtu(x, xdst->child_mtu_cached);
+
+		if (skb->len <= mtu)
+			goto ok;
+
+		if (skb_is_gso(skb) && skb_gso_validate_mtu(skb, mtu))
+			goto ok;
+	}
+
+	return false;
+
+ok:
+	if (dev && dev->xfrmdev_ops && dev->xfrmdev_ops->xdo_dev_offload_ok)
+		return x->xso.dev->xfrmdev_ops->xdo_dev_offload_ok(skb, x);
+
+	return true;
+}
+EXPORT_SYMBOL_GPL(xfrm_dev_offload_ok);
+
+int xfrm_dev_register(struct net_device *dev)
+{
+	if ((dev->features & NETIF_F_HW_ESP) && !dev->xfrmdev_ops)
+		return NOTIFY_BAD;
+	if ((dev->features & NETIF_F_HW_ESP_TX_CSUM) &&
+	    !(dev->features & NETIF_F_HW_ESP))
+		return NOTIFY_BAD;
+
+	return NOTIFY_DONE;
+}
+
+static int xfrm_dev_unregister(struct net_device *dev)
+{
+	return NOTIFY_DONE;
+}
+
+static int xfrm_dev_feat_change(struct net_device *dev)
+{
+	if ((dev->features & NETIF_F_HW_ESP) && !dev->xfrmdev_ops)
+		return NOTIFY_BAD;
+	else if (!(dev->features & NETIF_F_HW_ESP))
+		dev->xfrmdev_ops = NULL;
+
+	if ((dev->features & NETIF_F_HW_ESP_TX_CSUM) &&
+	    !(dev->features & NETIF_F_HW_ESP))
+		return NOTIFY_BAD;
+
+	return NOTIFY_DONE;
+}
+
+static int xfrm_dev_down(struct net_device *dev)
+{
+	if (dev->hw_features & NETIF_F_HW_ESP)
+		xfrm_dev_state_flush(dev_net(dev), dev, true);
+
+	xfrm_garbage_collect(dev_net(dev));
+
+	return NOTIFY_DONE;
+}
+
 static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 
 	switch (event) {
+	case NETDEV_REGISTER:
+		return xfrm_dev_register(dev);
+
+	case NETDEV_UNREGISTER:
+		return xfrm_dev_unregister(dev);
+
+	case NETDEV_FEAT_CHANGE:
+		return xfrm_dev_feat_change(dev);
+
 	case NETDEV_DOWN:
-		xfrm_garbage_collect(dev_net(dev));
+		return xfrm_dev_down(dev);
 	}
 	return NOTIFY_DONE;
 }
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 46bdb4f..362d655 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -107,6 +107,8 @@ struct sec_path *secpath_dup(struct sec_path *src)
 	sp->len = 0;
 	sp->olen = 0;
 
+	memset(sp->ovec, 0, sizeof(sp->ovec[XFRM_MAX_OFFLOAD_DEPTH]));
+
 	if (src) {
 		int i;
 
@@ -207,8 +209,9 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	unsigned int family;
 	int decaps = 0;
 	int async = 0;
-	struct xfrm_offload *xo;
 	bool xfrm_gro = false;
+	bool crypto_done = false;
+	struct xfrm_offload *xo = xfrm_offload(skb);
 
 	if (encap_type < 0) {
 		x = xfrm_input_state(skb);
@@ -226,6 +229,37 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		goto lock;
 	}
 
+	if (xo && (xo->flags & CRYPTO_DONE)) {
+		crypto_done = true;
+		x = xfrm_input_state(skb);
+		family = XFRM_SPI_SKB_CB(skb)->family;
+
+		if (!(xo->status & CRYPTO_SUCCESS)) {
+			if (xo->status &
+			    (CRYPTO_TRANSPORT_AH_AUTH_FAILED |
+			     CRYPTO_TRANSPORT_ESP_AUTH_FAILED |
+			     CRYPTO_TUNNEL_AH_AUTH_FAILED |
+			     CRYPTO_TUNNEL_ESP_AUTH_FAILED)) {
+
+				xfrm_audit_state_icvfail(x, skb,
+							 x->type->proto);
+				x->stats.integrity_failed++;
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEPROTOERROR);
+				goto drop;
+			}
+
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINBUFFERERROR);
+			goto drop;
+		}
+
+		if ((err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0) {
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINHDRERROR);
+			goto drop;
+		}
+
+		goto lock;
+	}
+
 	daddr = (xfrm_address_t *)(skb_network_header(skb) +
 				   XFRM_SPI_SKB_CB(skb)->daddroff);
 	family = XFRM_SPI_SKB_CB(skb)->family;
@@ -311,7 +345,10 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		skb_dst_force(skb);
 		dev_hold(skb->dev);
 
-		nexthdr = x->type->input(x, skb);
+		if (crypto_done)
+			nexthdr = x->type_offload->input_tail(x, skb);
+		else
+			nexthdr = x->type->input(x, skb);
 
 		if (nexthdr == -EINPROGRESS)
 			return 0;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 8ba29fe..a150886 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -99,12 +99,13 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 
 		skb_dst_force(skb);
 
-		/* Inner headers are invalid now. */
-		skb->encapsulation = 0;
-
-		err = x->type->output(x, skb);
-		if (err == -EINPROGRESS)
-			goto out;
+		if (xfrm_offload(skb)) {
+			x->type_offload->encap(x, skb);
+		} else {
+			err = x->type->output(x, skb);
+			if (err == -EINPROGRESS)
+				goto out;
+		}
 
 resume:
 		if (err) {
@@ -200,8 +201,38 @@ static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb
 int xfrm_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
+	struct xfrm_state *x = skb_dst(skb)->xfrm;
 	int err;
 
+	secpath_reset(skb);
+
+	if (xfrm_dev_offload_ok(skb, x)) {
+		struct sec_path *sp;
+
+		sp = secpath_dup(skb->sp);
+		if (!sp) {
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
+			kfree_skb(skb);
+			return -ENOMEM;
+		}
+		if (skb->sp)
+			secpath_put(skb->sp);
+		skb->sp = sp;
+
+		sp->olen++;
+		sp->xvec[skb->sp->len++] = x;
+		xfrm_state_hold(x);
+
+		if (skb_is_gso(skb)) {
+			skb_shinfo(skb)->gso_type |= SKB_GSO_ESP;
+
+			return xfrm_output2(net, sk, skb);
+		}
+
+		if (x->xso.dev && x->xso.dev->features & NETIF_F_HW_ESP_TX_CSUM)
+			goto out;
+	}
+
 	if (skb_is_gso(skb))
 		return xfrm_output_gso(net, sk, skb);
 
@@ -214,6 +245,7 @@ int xfrm_output(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
+out:
 	return xfrm_output2(net, sk, skb);
 }
 EXPORT_SYMBOL_GPL(xfrm_output);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7befca2..dd44ddc 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -116,11 +116,10 @@ static const struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short fa
 	return afinfo;
 }
 
-static inline struct dst_entry *__xfrm_dst_lookup(struct net *net,
-						  int tos, int oif,
-						  const xfrm_address_t *saddr,
-						  const xfrm_address_t *daddr,
-						  int family)
+struct dst_entry *__xfrm_dst_lookup(struct net *net, int tos, int oif,
+				    const xfrm_address_t *saddr,
+				    const xfrm_address_t *daddr,
+				    int family)
 {
 	const struct xfrm_policy_afinfo *afinfo;
 	struct dst_entry *dst;
@@ -135,6 +134,7 @@ static inline struct dst_entry *__xfrm_dst_lookup(struct net *net,
 
 	return dst;
 }
+EXPORT_SYMBOL(__xfrm_dst_lookup);
 
 static inline struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x,
 						int tos, int oif,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 47fefe9..fc3c5aa 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -440,6 +440,7 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
 		x->type->destructor(x);
 		xfrm_put_type(x->type);
 	}
+	xfrm_dev_state_free(x);
 	security_xfrm_state_free(x);
 	kfree(x);
 }
@@ -609,6 +610,8 @@ int __xfrm_state_delete(struct xfrm_state *x)
 		net->xfrm.state_num--;
 		spin_unlock(&net->xfrm.xfrm_state_lock);
 
+		xfrm_dev_state_delete(x);
+
 		/* All xfrm_state objects are created by xfrm_state_alloc.
 		 * The xfrm_state_alloc call gives a reference, and that
 		 * is what we are dropping here.
@@ -653,12 +656,41 @@ xfrm_state_flush_secctx_check(struct net *net, u8 proto, bool task_valid)
 
 	return err;
 }
+
+static inline int
+xfrm_dev_state_flush_secctx_check(struct net *net, struct net_device *dev, bool task_valid)
+{
+	int i, err = 0;
+
+	for (i = 0; i <= net->xfrm.state_hmask; i++) {
+		struct xfrm_state *x;
+		struct xfrm_state_offload *xso;
+
+		hlist_for_each_entry(x, net->xfrm.state_bydst+i, bydst) {
+			xso = &x->xso;
+
+			if (xso->dev == dev &&
+			   (err = security_xfrm_state_delete(x)) != 0) {
+				xfrm_audit_state_delete(x, 0, task_valid);
+				return err;
+			}
+		}
+	}
+
+	return err;
+}
 #else
 static inline int
 xfrm_state_flush_secctx_check(struct net *net, u8 proto, bool task_valid)
 {
 	return 0;
 }
+
+static inline int
+xfrm_dev_state_flush_secctx_check(struct net *net, struct net_device *dev, bool task_valid)
+{
+	return 0;
+}
 #endif
 
 int xfrm_state_flush(struct net *net, u8 proto, bool task_valid)
@@ -701,6 +733,48 @@ int xfrm_state_flush(struct net *net, u8 proto, bool task_valid)
 }
 EXPORT_SYMBOL(xfrm_state_flush);
 
+int xfrm_dev_state_flush(struct net *net, struct net_device *dev, bool task_valid)
+{
+	int i, err = 0, cnt = 0;
+
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
+	err = xfrm_dev_state_flush_secctx_check(net, dev, task_valid);
+	if (err)
+		goto out;
+
+	err = -ESRCH;
+	for (i = 0; i <= net->xfrm.state_hmask; i++) {
+		struct xfrm_state *x;
+		struct xfrm_state_offload *xso;
+restart:
+		hlist_for_each_entry(x, net->xfrm.state_bydst+i, bydst) {
+			xso = &x->xso;
+
+			if (!xfrm_state_kern(x) && xso->dev == dev) {
+				xfrm_state_hold(x);
+				spin_unlock_bh(&net->xfrm.xfrm_state_lock);
+
+				err = xfrm_state_delete(x);
+				xfrm_audit_state_delete(x, err ? 0 : 1,
+							task_valid);
+				xfrm_state_put(x);
+				if (!err)
+					cnt++;
+
+				spin_lock_bh(&net->xfrm.xfrm_state_lock);
+				goto restart;
+			}
+		}
+	}
+	if (cnt)
+		err = 0;
+
+out:
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
+	return err;
+}
+EXPORT_SYMBOL(xfrm_dev_state_flush);
+
 void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si)
 {
 	spin_lock_bh(&net->xfrm.xfrm_state_lock);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 4f7e62d..de3332e 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -595,6 +595,10 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 			goto error;
 	}
 
+	if (attrs[XFRMA_OFFLOAD_DEV] &&
+	    xfrm_dev_state_add(net, x, nla_data(attrs[XFRMA_OFFLOAD_DEV])))
+		goto error;
+
 	if ((err = xfrm_alloc_replay_state_esn(&x->replay_esn, &x->preplay_esn,
 					       attrs[XFRMA_REPLAY_ESN_VAL])))
 		goto error;
@@ -779,6 +783,23 @@ static int copy_sec_ctx(struct xfrm_sec_ctx *s, struct sk_buff *skb)
 	return 0;
 }
 
+static int copy_user_offload(struct xfrm_state_offload *xso, struct sk_buff *skb)
+{
+	struct xfrm_user_offload *xuo;
+	struct nlattr *attr;
+
+	attr = nla_reserve(skb, XFRMA_OFFLOAD_DEV, sizeof(*xuo));
+	if (attr == NULL)
+		return -EMSGSIZE;
+
+	xuo = nla_data(attr);
+
+	xuo->ifindex = xso->dev->ifindex;
+	xuo->flags = xso->flags;
+
+	return 0;
+}
+
 static int copy_to_user_auth(struct xfrm_algo_auth *auth, struct sk_buff *skb)
 {
 	struct xfrm_algo *algo;
@@ -869,6 +890,10 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 			      &x->replay);
 	if (ret)
 		goto out;
+	if(x->xso.dev)
+		ret = copy_user_offload(&x->xso, skb);
+	if (ret)
+		goto out;
 	if (x->security)
 		ret = copy_sec_ctx(x->security, skb);
 out:
@@ -2406,6 +2431,7 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_SA_EXTRA_FLAGS]	= { .type = NLA_U32 },
 	[XFRMA_PROTO]		= { .type = NLA_U8 },
 	[XFRMA_ADDRESS_FILTER]	= { .len = sizeof(struct xfrm_address_filter) },
+	[XFRMA_OFFLOAD_DEV]	= { .len = sizeof(struct xfrm_user_offload) },
 };
 
 static const struct nla_policy xfrma_spd_policy[XFRMA_SPD_MAX+1] = {
@@ -2622,6 +2648,8 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 		l += nla_total_size(sizeof(*x->coaddr));
 	if (x->props.extra_flags)
 		l += nla_total_size(sizeof(x->props.extra_flags));
+	if (x->xso.dev)
+		 l += nla_total_size(sizeof(x->xso));
 
 	/* Must count x->lastused as it may become non-zero behind our back. */
 	l += nla_total_size_64bit(sizeof(u64));
-- 
2.7.4
