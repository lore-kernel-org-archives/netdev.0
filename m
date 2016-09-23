From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 09/11] xfrm: Add an IPsec hardware offloading API
Date: Fri, 23 Sep 2016 09:53:46 +0200
Message-ID: <1474617228-26103-10-git-send-email-steffen.klassert@secunet.com>
References: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>,
        "Boris Pismenny" <borisp@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>,
        "Hay, Joshua A" <joshua.a.hay@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46007 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758212AbcIWHyH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:54:07 -0400
In-Reply-To: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds all the bits that are needed to do
IPsec hardware offload for IPsec states and ESP packets.
We add xfrmdev_ops to the net_device. xfrmdev_ops has
function pointers that are needed to manage the xfrm
states in the hardware and to do a per packet offloading
decision.

Joint work with:
Ilan Tayari <ilant@mellanox.com>
Guy Shapiro <guysh@mellanox.com>

Signed-off-by: Guy Shapiro <guysh@mellanox.com>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/netdevice.h | 14 ++++++++
 include/net/xfrm.h        | 40 +++++++++++++++++++++
 include/uapi/linux/xfrm.h |  8 +++++
 net/ipv4/esp4.c           | 31 ++++++++++++++++-
 net/ipv4/xfrm4_output.c   |  3 +-
 net/ipv6/esp6.c           | 32 ++++++++++++++++-
 net/xfrm/xfrm_device.c    | 51 ++++++++++++++++++++++++++-
 net/xfrm/xfrm_input.c     | 41 +++++++++++++++++++++-
 net/xfrm/xfrm_output.c    | 61 ++++++++++++++++++++++++++++++--
 net/xfrm/xfrm_policy.c    | 11 +++---
 net/xfrm/xfrm_state.c     | 89 +++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_user.c      | 81 ++++++++++++++++++++++++++++++++++++++++++
 12 files changed, 449 insertions(+), 13 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c3ef027..b2a511e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -832,6 +832,16 @@ struct netdev_xdp {
 	};
 };
 
+#ifdef CONFIG_XFRM
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
@@ -1708,6 +1718,10 @@ struct net_device {
 	const struct ndisc_ops *ndisc_ops;
 #endif
 
+#ifdef CONFIG_XFRM
+	const struct xfrmdev_ops *xfrmdev_ops;
+#endif
+
 	const struct header_ops *header_ops;
 
 	unsigned int		flags;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index a700f29..13060ce 100644
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
 
@@ -373,6 +382,7 @@ struct xfrm_type {
 	void			(*destructor)(struct xfrm_state *);
 	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
 	void			(*encap)(struct xfrm_state *, struct sk_buff *pskb);
+	int			(*input_tail)(struct xfrm_state *x, struct sk_buff *skb);
 	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
 	int			(*reject)(struct xfrm_state *, struct sk_buff *,
 					  const struct flowi *);
@@ -977,6 +987,22 @@ static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
 
 void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev);
 
+struct xfrm_offload_state {
+	u32			flags;
+#define	SA_DELETE_REQ		1
+#define	CRYPTO_DONE		2
+#define	CRYPTO_NEXT_DONE	4
+	u32			status;
+#define CRYPTO_SUCCESS				1
+#define CRYPTO_GENERIC_ERROR			2
+#define CRYPTO_TRANSPORT_AH_AUTH_FAILED		4
+#define CRYPTO_TRANSPORT_ESP_AUTH_FAILED	8
+#define CRYPTO_TUNNEL_AH_AUTH_FAILED		16
+#define CRYPTO_TUNNEL_ESP_AUTH_FAILED		32
+#define CRYPTO_INVALID_PACKET_SYNTAX		64
+#define CRYPTO_INVALID_PROTOCOL			128
+};
+
 struct sec_path {
 	atomic_t		refcnt;
 	int			len;
@@ -988,6 +1014,7 @@ struct sec_path {
 	} seq;
 
 	struct xfrm_state		*xvec[XFRM_MAX_DEPTH];
+	struct xfrm_offload_state	ovec[XFRM_MAX_DEPTH];
 
 	__u8				proto;
 	__u8				flags;
@@ -1514,6 +1541,7 @@ struct xfrmk_spdinfo {
 struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 mark, u32 seq);
 int xfrm_state_delete(struct xfrm_state *x);
 int xfrm_state_flush(struct net *net, u8 proto, bool task_valid);
+int xfrm_dev_state_flush(struct net *net, struct net_device *dev, bool task_valid);
 void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si);
 void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si);
 u32 xfrm_replay_seqhi(struct xfrm_state *x, __be32 net_seq);
@@ -1593,6 +1621,11 @@ static inline int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
 }
 #endif
 
+struct dst_entry *__xfrm_dst_lookup(struct net *net, int tos, int oif,
+				    const xfrm_address_t *saddr,
+				    const xfrm_address_t *daddr,
+				    int family);
+
 struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp);
 
 void xfrm_policy_walk_init(struct xfrm_policy_walk *walk, u8 type);
@@ -1787,6 +1820,13 @@ static inline struct xfrm_state *xfrm_input_state(struct sk_buff *skb)
 {
 	return skb->sp->xvec[skb->sp->len - 1];
 }
+static inline struct xfrm_offload_state *xfrm_offload_input(struct sk_buff *skb)
+{
+	if (!skb->sp || !skb->sp->len)
+		return NULL;
+
+	return &skb->sp->ovec[skb->sp->len - 1];
+}
 #endif
 
 static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_mark *m)
diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index 1433389..8ceb753 100644
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
index f61ba3c2..3d2c749 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -361,6 +361,14 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 			esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
 			esph->spi = x->id.spi;
 
+			if (x->xso.offload_handle && skb->sp) {
+				if (skb->sp->flags & SKB_GSO_SEGMENT)
+					esph->seq_no = htonl(skb->sp->seq.low);
+
+				spin_unlock_bh(&x->lock);
+				return 0;
+			}
+
 			tmp = esp_alloc_tmp(aead, nfrags + 2, extralen);
 			if (!tmp) {
 				spin_unlock_bh(&x->lock);
@@ -435,6 +443,13 @@ skip_cow:
 	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
 	esph->spi = x->id.spi;
 
+	if (x->xso.offload_handle && skb->sp) {
+		if (skb->sp->flags & SKB_GSO_SEGMENT)
+			esph->seq_no = htonl(skb->sp->seq.low);
+
+		return 0;
+	}
+
 	tmp = esp_alloc_tmp(aead, nfrags, extralen);
 	if (!tmp) {
 		err = -ENOMEM;
@@ -498,6 +513,7 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 {
 	const struct iphdr *iph;
 	struct xfrm_state *x = xfrm_input_state(skb);
+	struct xfrm_offload_state *xo = xfrm_offload_input(skb);
 	struct crypto_aead *aead = x->data;
 	int alen = crypto_aead_authsize(aead);
 	int hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
@@ -506,7 +522,8 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 	u8 nexthdr[2];
 	int padlen;
 
-	kfree(ESP_SKB_CB(skb)->tmp);
+	if (!(xo->flags & CRYPTO_DONE))
+		kfree(ESP_SKB_CB(skb)->tmp);
 
 	if (unlikely(err))
 		goto out;
@@ -616,6 +633,17 @@ static void esp_input_done_esn(struct crypto_async_request *base, int err)
 	esp_input_done(base, err);
 }
 
+static int esp_input_tail(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct crypto_aead *aead = x->data;
+
+	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead)))
+		return -EINVAL;
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return esp_input_done2(skb, 0);
+}
 /*
  * Note: detecting truncated vs. non-truncated authentication data is very
  * expensive, so we only support truncated data, which is the recommended
@@ -964,6 +992,7 @@ static const struct xfrm_type esp_type =
 	.destructor	= esp_destroy,
 	.get_mtu	= esp4_get_mtu,
 	.input		= esp_input,
+	.input_tail	= esp_input_tail,
 	.output		= esp_output,
 	.encap		= esp4_gso_encap,
 };
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
index 9bcb32b..49ed382 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -341,6 +341,14 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 			esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
 			esph->spi = x->id.spi;
 
+			if (x->xso.offload_handle && skb->sp) {
+				if (skb->sp->flags & SKB_GSO_SEGMENT)
+					esph->seq_no = htonl(skb->sp->seq.low);
+
+				spin_unlock_bh(&x->lock);
+				return 0;
+			}
+
 			tmp = esp_alloc_tmp(aead, nfrags + 2, seqhilen);
 			if (!tmp) {
 				spin_unlock_bh(&x->lock);
@@ -416,6 +424,13 @@ skip_cow:
 	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
 	esph->spi = x->id.spi;
 
+	if (x->xso.offload_handle && skb->sp) {
+		if (skb->sp->flags & SKB_GSO_SEGMENT)
+			esph->seq_no = htonl(skb->sp->seq.low);
+
+		return 0;
+	}
+
 	tmp = esp_alloc_tmp(aead, nfrags, seqhilen);
 	if (!tmp) {
 		err = -ENOMEM;
@@ -478,6 +493,7 @@ error:
 static int esp_input_done2(struct sk_buff *skb, int err)
 {
 	struct xfrm_state *x = xfrm_input_state(skb);
+	struct xfrm_offload_state *xo = xfrm_offload_input(skb);
 	struct crypto_aead *aead = x->data;
 	int alen = crypto_aead_authsize(aead);
 	int hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
@@ -486,7 +502,8 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 	int padlen;
 	u8 nexthdr[2];
 
-	kfree(ESP_SKB_CB(skb)->tmp);
+	if (!(xo->flags & CRYPTO_DONE))
+		kfree(ESP_SKB_CB(skb)->tmp);
 
 	if (unlikely(err))
 		goto out;
@@ -559,6 +576,18 @@ static void esp_input_done_esn(struct crypto_async_request *base, int err)
 	esp_input_done(base, err);
 }
 
+static int esp6_input_tail(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct crypto_aead *aead = x->data;
+
+	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead)))
+		return -EINVAL;
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return esp_input_done2(skb, 0);
+}
+
 static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ip_esp_hdr *esph;
@@ -892,6 +921,7 @@ static const struct xfrm_type esp6_type = {
 	.destructor	= esp6_destroy,
 	.get_mtu	= esp6_get_mtu,
 	.input		= esp6_input,
+	.input_tail	= esp6_input_tail,
 	.output		= esp6_output,
 	.encap		= esp6_gso_encap,
 	.hdr_offset	= xfrm6_find_1stfragopt,
diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index 34a260a..7add72f 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -22,13 +22,62 @@
 #include <net/xfrm.h>
 #include <linux/notifier.h>
 
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
index b1c2d77..114f7f9 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -111,6 +111,8 @@ struct sec_path *secpath_dup(struct sec_path *src)
 		return NULL;
 
 	sp->len = 0;
+	sp->flags = 0;
+
 	if (src) {
 		int i;
 
@@ -192,6 +194,8 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	unsigned int family;
 	int decaps = 0;
 	int async = 0;
+	bool crypto_done = false;
+	struct xfrm_offload_state *xo = xfrm_offload_input(skb);
 
 	if (encap_type < 0) {
 		/* An encap_type of -1 indicates async resumption. */
@@ -206,6 +210,37 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		encap_type = 0;
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
@@ -257,6 +292,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		skb->sp->xvec[skb->sp->len++] = x;
 
+lock:
 		spin_lock(&x->lock);
 
 		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
@@ -298,7 +334,10 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		skb_dst_force(skb);
 		dev_hold(skb->dev);
 
-		nexthdr = x->type->input(x, skb);
+		if (crypto_done)
+			nexthdr = x->type->input_tail(x, skb);
+		else
+			nexthdr = x->type->input(x, skb);
 
 		if (nexthdr == -EINPROGRESS)
 			return 0;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 637387b..fdd5fa1 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -102,9 +102,13 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 		/* Inner headers are invalid now. */
 		skb->encapsulation = 0;
 
-		err = x->type->output(x, skb);
-		if (err == -EINPROGRESS)
-			goto out;
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_ESP) {
+			x->type->encap(x, skb);
+		} else {
+			err = x->type->output(x, skb);
+			if (err == -EINPROGRESS)
+				goto out;
+		}
 
 resume:
 		if (err) {
@@ -197,11 +201,61 @@ static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb
 	return 0;
 }
 
+static bool xfrm_offload_ok(struct sk_buff *skb, struct xfrm_state *x)
+{
+	int mtu;
+	struct dst_entry *dst = skb_dst(skb);
+	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+
+	if (x->xso.offload_handle && (x->xso.dev == dst->path->dev)
+	    && !dst->child->xfrm && x->type->get_mtu) {
+		mtu = x->type->get_mtu(x, xdst->child_mtu_cached);
+
+		if (skb->len <= mtu)
+			goto ok;
+
+		if (skb_is_gso(skb) && skb_gso_validate_mtu(skb, mtu))
+			goto ok;
+	}
+	return false;
+
+ok:
+	return x->xso.dev->xfrmdev_ops->xdo_dev_offload_ok(skb, x);
+}
+
 int xfrm_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
+	struct xfrm_state *x = skb_dst(skb)->xfrm;
 	int err;
 
+	secpath_reset(skb);
+
+	if (xfrm_offload_ok(skb, x)) {
+		struct sec_path *sp;
+
+		sp = secpath_dup(skb->sp);
+		if (!sp) {
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
+			err = -ENOMEM;
+			return err;
+		}
+		if (skb->sp)
+			secpath_put(skb->sp);
+		skb->sp = sp;
+
+		skb->sp->xvec[skb->sp->len++] = x;
+		xfrm_state_hold(x);
+
+		if (skb_is_gso(skb)) {
+			skb_shinfo(skb)->gso_type |= SKB_GSO_ESP;
+
+			return xfrm_output2(net, sk, skb);
+		}
+		if (x->xso.dev->features & NETIF_F_HW_ESP_TX_CSUM)
+			goto out;
+	}
+
 	if (skb_is_gso(skb))
 		return xfrm_output_gso(net, sk, skb);
 
@@ -214,6 +268,7 @@ int xfrm_output(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
+out:
 	return xfrm_output2(net, sk, skb);
 }
 EXPORT_SYMBOL_GPL(xfrm_output);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index dfa0d86..88e045f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -121,11 +121,11 @@ static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo)
 	rcu_read_unlock();
 }
 
-static inline struct dst_entry *__xfrm_dst_lookup(struct net *net,
-						  int tos, int oif,
-						  const xfrm_address_t *saddr,
-						  const xfrm_address_t *daddr,
-						  int family)
+struct dst_entry *__xfrm_dst_lookup(struct net *net,
+				    int tos, int oif,
+				    const xfrm_address_t *saddr,
+				    const xfrm_address_t *daddr,
+				    int family)
 {
 	struct xfrm_policy_afinfo *afinfo;
 	struct dst_entry *dst;
@@ -140,6 +140,7 @@ static inline struct dst_entry *__xfrm_dst_lookup(struct net *net,
 
 	return dst;
 }
+EXPORT_SYMBOL(__xfrm_dst_lookup);
 
 static inline struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x,
 						int tos, int oif,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index ba8bf51..486fc67 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -341,6 +341,19 @@ retry:
 	return mode;
 }
 
+static void xfrm_state_free_offload(struct xfrm_state *x)
+{
+	struct xfrm_state_offload *xso = &x->xso;
+
+	if (xso->dev) {
+		struct net_device *dev = xso->dev;
+
+		dev->xfrmdev_ops->xdo_dev_state_free(x);
+		xso->dev = NULL;
+		dev_put(dev);
+	}
+}
+
 static void xfrm_put_mode(struct xfrm_mode *mode)
 {
 	module_put(mode->owner);
@@ -367,6 +380,7 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
 		x->type->destructor(x);
 		xfrm_put_type(x->type);
 	}
+	xfrm_state_free_offload(x);
 	security_xfrm_state_free(x);
 	kfree(x);
 }
@@ -531,6 +545,7 @@ EXPORT_SYMBOL(__xfrm_state_destroy);
 int __xfrm_state_delete(struct xfrm_state *x)
 {
 	struct net *net = xs_net(x);
+	struct xfrm_state_offload *xso = &x->xso;
 	int err = -ESRCH;
 
 	if (x->km.state != XFRM_STATE_DEAD) {
@@ -544,6 +559,9 @@ int __xfrm_state_delete(struct xfrm_state *x)
 		net->xfrm.state_num--;
 		spin_unlock(&net->xfrm.xfrm_state_lock);
 
+		if (xso->dev)
+			xso->dev->xfrmdev_ops->xdo_dev_state_delete(x);
+
 		/* All xfrm_state objects are created by xfrm_state_alloc.
 		 * The xfrm_state_alloc call gives a reference, and that
 		 * is what we are dropping here.
@@ -588,12 +606,41 @@ xfrm_state_flush_secctx_check(struct net *net, u8 proto, bool task_valid)
 
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
@@ -636,6 +683,48 @@ out:
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
index cb65d91..edbdb1b 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -400,6 +400,59 @@ static int attach_aead(struct xfrm_state *x, struct nlattr *rta)
 	return 0;
 }
 
+static int xfrm_dev_state_add(struct net *net, struct xfrm_state *x, struct nlattr *rta)
+{
+	int err;
+	struct dst_entry *dst;
+	struct net_device *dev;
+	struct xfrm_user_offload *xuo;
+	struct xfrm_state_offload *xso = &x->xso;
+	xfrm_address_t *saddr;
+	xfrm_address_t *daddr;
+
+	if (!rta)
+		return 0;
+
+	xuo = nla_data(rta);
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
+
 static inline int xfrm_replay_verify_len(struct xfrm_replay_state_esn *replay_esn,
 					 struct nlattr *rp)
 {
@@ -585,6 +638,10 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 	    security_xfrm_state_alloc(x, nla_data(attrs[XFRMA_SEC_CTX])))
 		goto error;
 
+	if (attrs[XFRMA_OFFLOAD_DEV] &&
+	    xfrm_dev_state_add(net, x, attrs[XFRMA_OFFLOAD_DEV]))
+		goto error;
+
 	if ((err = xfrm_alloc_replay_state_esn(&x->replay_esn, &x->preplay_esn,
 					       attrs[XFRMA_REPLAY_ESN_VAL])))
 		goto error;
@@ -769,6 +826,23 @@ static int copy_sec_ctx(struct xfrm_sec_ctx *s, struct sk_buff *skb)
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
@@ -859,6 +933,10 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
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
@@ -2396,6 +2474,7 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_SA_EXTRA_FLAGS]	= { .type = NLA_U32 },
 	[XFRMA_PROTO]		= { .type = NLA_U8 },
 	[XFRMA_ADDRESS_FILTER]	= { .len = sizeof(struct xfrm_address_filter) },
+	[XFRMA_OFFLOAD_DEV]	= { .len = sizeof(struct xfrm_user_offload) },
 };
 
 static const struct nla_policy xfrma_spd_policy[XFRMA_SPD_MAX+1] = {
@@ -2612,6 +2691,8 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 		l += nla_total_size(sizeof(*x->coaddr));
 	if (x->props.extra_flags)
 		l += nla_total_size(sizeof(x->props.extra_flags));
+	if (x->xso.dev)
+		 l += nla_total_size(sizeof(x->xso));
 
 	/* Must count x->lastused as it may become non-zero behind our back. */
 	l += nla_total_size_64bit(sizeof(u64));
-- 
1.9.1
