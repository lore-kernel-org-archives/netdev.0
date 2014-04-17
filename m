From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: in kernel 2.6.x, tun/tap nic supports vlan packets
Date: Thu, 17 Apr 2014 21:52:41 +0800
Message-ID: <534FDCA9.4080005@gmail.com>
References: <534F4C1E.1000006@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020500040601000703060900"
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	joe@perches.com, julia.lawall@lip6.fr, dingtianhong@huawei.com,
	linux-kernel@vger.kernel.org, jasowang@redhat.com, mst@redhat.com,
	Willy Tarreau <w@1wt.eu>,
	"Yang, Zhangle (Eric)" <Zhangle.Yang@windriver.com>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <534F4C1E.1000006@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020500040601000703060900
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Although the maintainer will not merge these 2 patches, I still fix the 
mistakes in these 2 patches. Now the latest patches are in attachment. 
Maybe these patches can help others.

The latest patches fix mistakes in rx stats.

Best Regards!
Zhu Yanjun
On 04/17/2014 11:35 AM, zhuyj wrote:
> Hi, all
>
> In kernel 2.6.x, linux depends on nic vlan hardware acceleration to 
> insert/extract
> vlan tag. In this scene, in kernel 2.6.x
>
>                  _____        ________
>     A           |     | B    |        | C
>  vlan packets-->| tap |----->|vlan nic|--->
>                 |_____|      |________|
>
> We hope vlan packets pass through tap and vlan nic from A to c.
> But in kernel 2.6.x, linux kernel can not extract vlan tag. It depends
> on nic vlan hardware acceleration. It is well known that tap nic has no
> vlan acceleration. So in the above scene, vlan packets can not be 
> handled by
> tap nic. These vlan packets will be discarded in B. They can not 
> arrive at C.
>
> In kernel 3.x, linux can handle vlan packets. It does not depend on 
> nic vlan
> hardware acceleration. So the above scene can work well in kernel 3.x.
>
> To resolve the above in kernel 2.6.x, we simulated vlan hardware 
> acceleration in
> tun/tap driver. Then followed the logic of commit commit 4fba4ca4
> [vlan: Centralize handling of hardware acceleration] to modify the 
> vlan packets
> process in kernel 2.6.x. In the end, the above scene can work well in 
> patched
> kernel 2.6.x.
>
> Please comment on it. Any reply is appreciated.
>
> Hi, Willy
>
> These 2 patches are for linux2.6.x. These can work well here. Please 
> help to merge
> linux 2.6.32.x. Thanks a lot.
>
> Best Regards!
> Zhu Yanjun
>


--------------020500040601000703060900
Content-Type: text/x-patch;
 name="0001-tun-tap-add-the-feature-of-vlan-rx-extraction.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-tun-tap-add-the-feature-of-vlan-rx-extraction.patch"

>From 66db0748fc0f932496100789eb319ca5884c0694 Mon Sep 17 00:00:00 2001
From: root <root@wind-OptiPlex-780.(none)>
Date: Wed, 16 Apr 2014 18:19:42 +0800
Subject: [PATCH 1/2] tun/tap: add the feature of vlan rx extraction

Tap is a virtual net device that has no vlan rx untag feature.
So this virtual device can not send/receive vlan packets in
kernel 2.6.x. To make this device support vlan send/receive vlan
packets in kernel 2.6.x, a vlan rx extraction feature is simulated
in its driver.

Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 drivers/net/tun.c         |  118 ++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   13 +++++
 3 files changed, 131 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 894ad84..029e6cf 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -69,6 +69,8 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
+#include <linux/if_vlan.h>
+
 /* Uncomment to enable debugging */
 /* #define TUN_DEBUG 1 */
 
@@ -426,6 +428,8 @@ static const struct net_device_ops tun_netdev_ops = {
 	.ndo_change_mtu		= tun_net_change_mtu,
 };
 
+static void tap_vlan_rx_register(struct net_device *dev, struct vlan_group *grp);
+
 static const struct net_device_ops tap_netdev_ops = {
 	.ndo_uninit		= tun_net_uninit,
 	.ndo_open		= tun_net_open,
@@ -435,6 +439,7 @@ static const struct net_device_ops tap_netdev_ops = {
 	.ndo_set_multicast_list	= tun_net_mclist,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_vlan_rx_register   = tap_vlan_rx_register,
 };
 
 /* Initialize net device. */
@@ -464,6 +469,8 @@ static void tun_net_init(struct net_device *dev)
 
 		random_ether_addr(dev->dev_addr);
 
+		dev->features |= NETIF_F_HW_VLAN_RX;
+
 		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 	}
@@ -530,6 +537,105 @@ static inline struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
 	return skb;
 }
 
+static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
+{
+	if (skb_cow(skb, skb_headroom(skb)) < 0)
+		return NULL;
+	memmove(skb->data - ETH_HLEN, skb->data - VLAN_ETH_HLEN, 2 * ETH_ALEN);
+	skb->mac_header += VLAN_HLEN;
+	return skb;
+}
+
+static void vlan_set_encap_proto(struct sk_buff *skb, struct vlan_hdr *vhdr)
+{
+	__be16 proto;
+	unsigned char *rawp;
+
+	/*
+ * 	 * Was a VLAN packet, grab the encapsulated protocol, which the layer
+ * 	 	 * three protocols care about.
+ * 	 	 	 */
+
+	proto = vhdr->h_vlan_encapsulated_proto;
+	if (ntohs(proto) >= 1536) {
+		skb->protocol = proto;
+		return;
+	}
+
+	rawp = skb->data;
+	if (*(unsigned short *) rawp == 0xFFFF)
+		/*
+ * 		 * This is a magic hack to spot IPX packets. Older Novell
+ * 		 		 * breaks the protocol design and runs IPX over 802.3 without
+ * 		 		 		 * an 802.2 LLC layer. We look for FFFF which isn't a used
+ * 		 		 		 		 * 802.2 SSAP/DSAP. This won't work for fault tolerant netware
+ * 		 		 		 		 		 * but does for the rest.
+ * 		 		 		 		 		 		 */
+		skb->protocol = htons(ETH_P_802_3);
+	else
+		/*
+ * 		 * Real 802.2 LLC
+ * 		 		 */
+		skb->protocol = htons(ETH_P_802_2);
+}
+
+static void skb_reset_mac_len(struct sk_buff *skb)
+{
+	skb->mac_len = skb->network_header - skb->mac_header;
+}
+
+static struct sk_buff *vlan_untag(struct sk_buff *skb)
+{
+	struct vlan_hdr *vhdr;
+	u16 vlan_tci;
+
+	if (unlikely(vlan_tx_tag_present(skb))) {
+		/* vlan_tci is already set-up so leave this for another time */
+		return skb;
+	}
+
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (unlikely(!skb))
+		goto err_free;
+
+	if (unlikely(!pskb_may_pull(skb, VLAN_HLEN)))
+		goto err_free;
+
+	vhdr = (struct vlan_hdr *) skb->data;
+	vlan_tci = ntohs(vhdr->h_vlan_TCI);
+	__vlan_hwaccel_put_tag(skb, vlan_tci);
+
+	skb_pull_rcsum(skb, VLAN_HLEN);
+	vlan_set_encap_proto(skb, vhdr);
+
+	skb = vlan_reorder_header(skb);
+	if (unlikely(!skb))
+		goto err_free;
+
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
+	skb_reset_mac_len(skb);
+
+	return skb;
+
+err_free:
+	kfree_skb(skb);
+	return NULL;
+}
+
+static struct vlan_group *g_vlgrp = NULL;
+static void tap_vlan_rx_register(struct net_device *dev,
+		struct vlan_group *grp)
+{
+	unsigned long flags;
+	local_irq_save(flags);
+
+	printk(KERN_DEBUG "zhuyj func:%s,line:%d\n", __FUNCTION__, __LINE__);
+	g_vlgrp = grp;
+	tun_net_change_mtu(dev, dev->mtu);
+	local_irq_restore(flags);
+}
+
 /* Get packet from user space buffer */
 static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
 				       const struct iovec *iv, size_t count,
@@ -655,7 +761,17 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
 		skb_shinfo(skb)->gso_segs = 0;
 	}
 
-	netif_rx_ni(skb);
+	if (g_vlgrp && (skb->protocol == cpu_to_be16(ETH_P_8021Q))){
+		struct vlan_hdr *vhdr;
+		u16 vlan_tci;
+		int ret;
+		vhdr = (struct vlan_hdr *) skb->data;
+		vlan_tci = ntohs(vhdr->h_vlan_TCI);
+		skb = vlan_untag(skb);
+		ret = vlan_netif_rx(skb, g_vlgrp, vlan_tci);
+	} else {
+		netif_rx_ni(skb);
+	}
 
 	tun->dev->stats.rx_packets++;
 	tun->dev->stats.rx_bytes += len;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9d7e8f7..04c659b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1467,6 +1467,7 @@ extern void dev_kfree_skb_any(struct sk_buff *skb);
 #define HAVE_NETIF_RX 1
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
+extern int		vlan_netif_rx(struct sk_buff *skb, struct vlan_group *grp, u16 vlan_tci);
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
 extern void		napi_gro_flush(struct napi_struct *napi);
diff --git a/net/core/dev.c b/net/core/dev.c
index d775563..a3802ca 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2067,6 +2067,19 @@ int netif_rx_ni(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(netif_rx_ni);
 
+int vlan_netif_rx(struct sk_buff *skb, struct vlan_group *grp, u16 vlan_tci)
+{
+	int ret;
+
+	preempt_disable();
+	ret = __vlan_hwaccel_rx(skb, grp, vlan_tci, 0);
+	if (local_softirq_pending())
+		do_softirq();
+	preempt_enable();
+	return ret;
+}
+EXPORT_SYMBOL(vlan_netif_rx);
+
 static void net_tx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
-- 
1.7.9.5


--------------020500040601000703060900
Content-Type: text/x-patch;
 name="0002-vlan-Centralize-handling-of-hardware-acceleration.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0002-vlan-Centralize-handling-of-hardware-acceleration.patch"

>From dbc18ad405cc68c4eabdc64f2afcca5c65d1b96a Mon Sep 17 00:00:00 2001
From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Date: Thu, 17 Apr 2014 15:58:02 +0800
Subject: [PATCH 2/2] vlan: Centralize handling of hardware acceleration

2.6.x kernels require a similar logic change as commit 4fba4ca4
[vlan: Centralize handling of hardware acceleration] introduces
for newer kernels.

Since there is something wrong with sending/receiving vlan packets
of tun/tap of kernel 2.6.x. In kernel(3.0+), sending/receiving
vlan packets is centralize handling in kernel. But in kernel 2.6.x,
inserting/extraction vlan tag is still based on nic hardware. Thus,
tun/tap nic driver can not support vlan packets. It is necessary
to centralize handling of hardware acceleration and simulate vlan
rx extraction in tun/tap nic driver to make tun/tap support vlan
packets sending/receiving in kernel 2.6.x.

Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 include/linux/if_vlan.h   |    4 +-
 include/linux/netdevice.h |    1 -
 net/8021q/vlan.c          |   47 +++++++++++++++++++
 net/8021q/vlan_core.c     |  110 +++++----------------------------------------
 net/core/dev.c            |   45 +++++++------------
 5 files changed, 74 insertions(+), 133 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 7ff9af1..5538dda 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -114,7 +114,7 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
 extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 			     u16 vlan_tci, int polling);
-extern int vlan_hwaccel_do_receive(struct sk_buff *skb);
+extern bool vlan_hwaccel_do_receive(struct sk_buff **skb);
 extern int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 			    unsigned int vlan_tci, struct sk_buff *skb);
 extern int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
@@ -140,7 +140,7 @@ static inline int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 	return NET_XMIT_SUCCESS;
 }
 
-static inline int vlan_hwaccel_do_receive(struct sk_buff *skb)
+static inline bool vlan_hwaccel_do_receive(struct sk_buff **skb)
 {
 	return 0;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 04c659b..bdb6b82 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1490,7 +1490,6 @@ static inline void napi_free_frags(struct napi_struct *napi)
 	napi->skb = NULL;
 }
 
-extern void		netif_nit_deliver(struct sk_buff *skb);
 extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
 extern int		dev_ethtool(struct net *net, struct ifreq *);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index a29c5ab..64c081b 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -92,6 +92,52 @@ struct net_device *__find_vlan_dev(struct net_device *real_dev, u16 vlan_id)
 	return NULL;
 }
 
+bool vlan_hwaccel_do_receive(struct sk_buff **skbp)
+{
+	struct sk_buff *skb = *skbp;
+	u16 vlan_id = skb->vlan_tci & VLAN_VID_MASK;
+	struct net_device *vlan_dev;
+	struct net_device_stats *stats;
+
+	vlan_dev = __find_vlan_dev(skb->dev, vlan_id);
+	if (!vlan_dev) {
+		if (vlan_id)
+			skb->pkt_type = PACKET_OTHERHOST;
+		return false;
+	}
+
+	skb = *skbp = skb_share_check(skb, GFP_ATOMIC);
+	if (unlikely(!skb))
+		return false;
+
+	skb->dev = vlan_dev;
+	skb->priority = vlan_get_ingress_priority(vlan_dev, skb->vlan_tci);
+	skb->vlan_tci = 0;
+
+	stats = &vlan_dev->stats;
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+
+	switch (skb->pkt_type) {
+	case PACKET_BROADCAST:
+		break;
+	case PACKET_MULTICAST:
+		stats->multicast++;
+		break;
+	case PACKET_OTHERHOST:
+		/* Our lower layer thinks this is not local, let's make sure.
+		 * This allows the VLAN to have a different MAC than the
+		 * underlying device, and still route correctly. */
+		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
+					vlan_dev->dev_addr))
+			skb->pkt_type = PACKET_HOST;
+			break;
+	};
+
+	return true;
+}
+extern bool (*__vlan_do_receive)(struct sk_buff **skbp);
+
 static void vlan_group_free(struct vlan_group *grp)
 {
 	int i;
@@ -744,6 +790,7 @@ static int __init vlan_proto_init(void)
 
 	dev_add_pack(&vlan_packet_type);
 	vlan_ioctl_set(vlan_ioctl_handler);
+	__vlan_do_receive = vlan_hwaccel_do_receive;
 	return 0;
 
 err4:
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 7f7de1a..c679535 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -4,64 +4,6 @@
 #include <linux/netpoll.h>
 #include "vlan.h"
 
-/* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
-int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
-		      u16 vlan_tci, int polling)
-{
-	if (netpoll_rx(skb))
-		return NET_RX_DROP;
-
-	if (skb_bond_should_drop(skb))
-		goto drop;
-
-	skb->vlan_tci = vlan_tci;
-	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
-
-	if (!skb->dev)
-		goto drop;
-
-	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
-
-drop:
-	dev_kfree_skb_any(skb);
-	return NET_RX_DROP;
-}
-EXPORT_SYMBOL(__vlan_hwaccel_rx);
-
-int vlan_hwaccel_do_receive(struct sk_buff *skb)
-{
-	struct net_device *dev = skb->dev;
-	struct net_device_stats *stats;
-
-	skb->dev = vlan_dev_info(dev)->real_dev;
-	netif_nit_deliver(skb);
-
-	skb->dev = dev;
-	skb->priority = vlan_get_ingress_priority(dev, skb->vlan_tci);
-	skb->vlan_tci = 0;
-
-	stats = &dev->stats;
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
-
-	switch (skb->pkt_type) {
-	case PACKET_BROADCAST:
-		break;
-	case PACKET_MULTICAST:
-		stats->multicast++;
-		break;
-	case PACKET_OTHERHOST:
-		/* Our lower layer thinks this is not local, let's make sure.
-		 * This allows the VLAN to have a different MAC than the
-		 * underlying device, and still route correctly. */
-		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
-					dev->dev_addr))
-			skb->pkt_type = PACKET_HOST;
-		break;
-	};
-	return 0;
-}
-
 struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
 	return vlan_dev_info(dev)->real_dev;
@@ -74,59 +16,27 @@ u16 vlan_dev_vlan_id(const struct net_device *dev)
 }
 EXPORT_SYMBOL(vlan_dev_vlan_id);
 
-static int vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
-			   unsigned int vlan_tci, struct sk_buff *skb)
+/* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
+int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
+			u16 vlan_tci, int polling)
 {
-	struct sk_buff *p;
-
-	if (skb_bond_should_drop(skb))
-		goto drop;
-
-	skb->vlan_tci = vlan_tci;
-	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
-
-	if (!skb->dev)
-		goto drop;
-
-	for (p = napi->gro_list; p; p = p->next) {
-		NAPI_GRO_CB(p)->same_flow =
-			p->dev == skb->dev && !compare_ether_header(
-				skb_mac_header(p), skb_gro_mac_header(skb));
-		NAPI_GRO_CB(p)->flush = 0;
-	}
-
-	return dev_gro_receive(napi, skb);
-
-drop:
-	return GRO_DROP;
+	__vlan_hwaccel_put_tag(skb, vlan_tci);
+	return polling ? netif_receive_skb(skb) : netif_rx(skb); 
 }
+EXPORT_SYMBOL(__vlan_hwaccel_rx);
 
 int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 		     unsigned int vlan_tci, struct sk_buff *skb)
 {
-	if (netpoll_rx_on(skb))
-		return vlan_hwaccel_receive_skb(skb, grp, vlan_tci);
-
-	skb_gro_reset_offset(skb);
-
-	return napi_skb_finish(vlan_gro_common(napi, grp, vlan_tci, skb), skb);
+	__vlan_hwaccel_put_tag(skb, vlan_tci);
+	return napi_gro_receive(napi, skb);
 }
 EXPORT_SYMBOL(vlan_gro_receive);
 
 int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 		   unsigned int vlan_tci)
 {
-	struct sk_buff *skb = napi_frags_skb(napi);
-
-	if (!skb)
-		return NET_RX_DROP;
-
-	if (netpoll_rx_on(skb)) {
-		skb->protocol = eth_type_trans(skb, skb->dev);
-		return vlan_hwaccel_receive_skb(skb, grp, vlan_tci);
-	}
-
-	return napi_frags_finish(napi, skb,
-				 vlan_gro_common(napi, grp, vlan_tci, skb));
+	__vlan_hwaccel_put_tag(napi->skb, vlan_tci);
+	return napi_gro_frags(napi);
 }
 EXPORT_SYMBOL(vlan_gro_frags);
diff --git a/net/core/dev.c b/net/core/dev.c
index a3802ca..c58520a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2272,33 +2272,8 @@ out:
 }
 #endif
 
-/*
- * 	netif_nit_deliver - deliver received packets to network taps
- * 	@skb: buffer
- *
- * 	This function is used to deliver incoming packets to network
- * 	taps. It should be used when the normal netif_receive_skb path
- * 	is bypassed, for example because of VLAN acceleration.
- */
-void netif_nit_deliver(struct sk_buff *skb)
-{
-	struct packet_type *ptype;
-
-	if (list_empty(&ptype_all))
-		return;
-
-	skb_reset_network_header(skb);
-	skb_reset_transport_header(skb);
-	skb->mac_len = skb->network_header - skb->mac_header;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (!ptype->dev || ptype->dev == skb->dev)
-			deliver_skb(skb, ptype, skb->dev);
-	}
-	rcu_read_unlock();
-}
-
+bool (*__vlan_do_receive)(struct sk_buff **skbp) = NULL;
+EXPORT_SYMBOL(__vlan_do_receive);
 /**
  *	netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process
@@ -2325,9 +2300,6 @@ int netif_receive_skb(struct sk_buff *skb)
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
 
-	if (skb->vlan_tci && vlan_hwaccel_do_receive(skb))
-		return NET_RX_SUCCESS;
-
 	/* if we've gotten here through NAPI, check netpoll */
 	if (netpoll_receive_skb(skb))
 		return NET_RX_DROP;
@@ -2354,6 +2326,8 @@ int netif_receive_skb(struct sk_buff *skb)
 
 	rcu_read_lock();
 
+another_round:
+
 #ifdef CONFIG_NET_CLS_ACT
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
@@ -2377,6 +2351,17 @@ int netif_receive_skb(struct sk_buff *skb)
 ncls:
 #endif
 
+	if (vlan_tx_tag_present(skb)) {
+		if (pt_prev) {
+			ret = deliver_skb(skb, pt_prev, orig_dev);
+			pt_prev = NULL;
+		}
+		if (__vlan_do_receive && __vlan_do_receive(&skb)) {
+			goto another_round;
+		} else if (unlikely(!skb))
+			goto out;
+	}
+
 	skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
 	if (!skb)
 		goto out;
-- 
1.7.9.5


--------------020500040601000703060900--
