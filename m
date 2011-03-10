From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave
	instead of master
Date: Thu, 10 Mar 2011 07:48:30 +0100
Message-ID: <20110310064829.GA3261@psychotron.redhat.com>
References: <20110307224338.GU11864@gospo.rdu.redhat.com>
 <20110308071350.GA2826@psychotron.redhat.com>
 <20110308134247.GW11864@gospo.rdu.redhat.com>
 <4D76A345.9040200@gmail.com>
 <20110309074547.GA2808@psychotron.redhat.com>
 <4D77938D.3080408@gmail.com>
 <20110309150939.GA9013@psychotron.brq.redhat.com>
 <4D779CA2.1050302@gmail.com>
 <20110309171100.GA2842@psychotron.redhat.com>
 <4D77FCC1.5050904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44620 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752564Ab1CJGso (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 01:48:44 -0500
Content-Disposition: inline
In-Reply-To: <4D77FCC1.5050904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>But for all others setups, where there exist some net_devices before
>the "untagging" one, you would face some troubles. For example, with
>eth0+eth1 -> br0 -> br0.100, you cannot untag before entering
>__netif_receive_skb. If you do so, the bridge would receive untagged
>frame and if the frame is not for the local host, the bridge would
>forward an untagged frame while it is expected to forward a tagged
>one. Even if the bridge is in a position to know the frame *was*
>tagged, we cannot expect the bridge to do special processing to
>handle this situation. Doing so would break layering.

I disagree.
eth0 -> untag on early __netif_receive_skb (sets up skb->vlan_tci)
           ->rx_handler of bridge
->br0 -> tag is detected by vlan_tx_tag_present()
           -> reinject to __netif_receive_skb with skb->dev == br0.100

This way the flow would be very similar to vlan-hw-accel, am I right?


I have following patch in mind. Note it's raw DRAFT.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if_vlan.h |    5 ++
 net/8021q/vlan.c        |    8 --
 net/8021q/vlan_core.c   |  106 +++++++++++++++++++++++++++++
 net/8021q/vlan_dev.c    |  172 -----------------------------------------------
 net/core/dev.c          |   18 ++++-
 5 files changed, 125 insertions(+), 184 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 635e1fa..dd914e2 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -133,6 +133,7 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 			     u16 vlan_tci, int polling);
 extern bool vlan_hwaccel_do_receive(struct sk_buff **skb);
+extern void vlan_emulate_hwaccel(struct sk_buff **skbp);
 extern gro_result_t
 vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 		 unsigned int vlan_tci, struct sk_buff *skb);
@@ -173,6 +174,10 @@ static inline bool vlan_hwaccel_do_receive(struct sk_buff **skb)
 	return false;
 }
 
+void vlan_emulate_hwaccel(struct sk_buff **skbp)
+{
+}
+
 static inline gro_result_t
 vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 		 unsigned int vlan_tci, struct sk_buff *skb)
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 7850412..59f0a9d 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -49,11 +49,6 @@ const char vlan_version[] = DRV_VERSION;
 static const char vlan_copyright[] = "Ben Greear <greearb@candelatech.com>";
 static const char vlan_buggyright[] = "David S. Miller <davem@redhat.com>";
 
-static struct packet_type vlan_packet_type __read_mostly = {
-	.type = cpu_to_be16(ETH_P_8021Q),
-	.func = vlan_skb_recv, /* VLAN receive method */
-};
-
 /* End of global variables definitions. */
 
 static void vlan_group_free(struct vlan_group *grp)
@@ -688,7 +683,6 @@ static int __init vlan_proto_init(void)
 	if (err < 0)
 		goto err4;
 
-	dev_add_pack(&vlan_packet_type);
 	vlan_ioctl_set(vlan_ioctl_handler);
 	return 0;
 
@@ -709,8 +703,6 @@ static void __exit vlan_cleanup_module(void)
 
 	unregister_netdevice_notifier(&vlan_notifier_block);
 
-	dev_remove_pack(&vlan_packet_type);
-
 	unregister_pernet_subsys(&vlan_net_ops);
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index ce8e3ab..c324e4d 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -88,3 +88,109 @@ gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 	return napi_gro_frags(napi);
 }
 EXPORT_SYMBOL(vlan_gro_frags);
+
+static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
+{
+	if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
+		if (skb_cow(skb, skb_headroom(skb)) < 0)
+			skb = NULL;
+		if (skb) {
+			/* Lifted from Gleb's VLAN code... */
+			memmove(skb->data - ETH_HLEN,
+				skb->data - VLAN_ETH_HLEN, 12);
+			skb->mac_header += VLAN_HLEN;
+		}
+	}
+
+	return skb;
+}
+
+static inline void vlan_set_encap_proto(struct sk_buff *skb,
+		struct vlan_hdr *vhdr)
+{
+	__be16 proto;
+	unsigned char *rawp;
+
+	/*
+	 * Was a VLAN packet, grab the encapsulated protocol, which the layer
+	 * three protocols care about.
+	 */
+
+	proto = vhdr->h_vlan_encapsulated_proto;
+	if (ntohs(proto) >= 1536) {
+		skb->protocol = proto;
+		return;
+	}
+
+	rawp = skb->data;
+	if (*(unsigned short *)rawp == 0xFFFF)
+		/*
+		 * This is a magic hack to spot IPX packets. Older Novell
+		 * breaks the protocol design and runs IPX over 802.3 without
+		 * an 802.2 LLC layer. We look for FFFF which isn't a used
+		 * 802.2 SSAP/DSAP. This won't work for fault tolerant netware
+		 * but does for the rest.
+		 */
+		skb->protocol = htons(ETH_P_802_3);
+	else
+		/*
+		 * Real 802.2 LLC
+		 */
+		skb->protocol = htons(ETH_P_802_2);
+}
+
+/*
+ *	Determine the packet's protocol ID. The rule here is that we
+ *	assume 802.3 if the type field is short enough to be a length.
+ *	This is normal practice and works for any 'now in use' protocol.
+ *
+ *  Also, at this point we assume that we ARE dealing exclusively with
+ *  VLAN packets, or packets that should be made into VLAN packets based
+ *  on a default VLAN ID.
+ *
+ *  NOTE:  Should be similar to ethernet/eth.c.
+ *
+ *  SANITY NOTE:  This method is called when a packet is moving up the stack
+ *                towards userland.  To get here, it would have already passed
+ *                through the ethernet/eth.c eth_type_trans() method.
+ *  SANITY NOTE 2: We are referencing to the VLAN_HDR frields, which MAY be
+ *                 stored UNALIGNED in the memory.  RISC systems don't like
+ *                 such cases very much...
+ *  SANITY NOTE 2a: According to Dave Miller & Alexey, it will always be
+ *		    aligned, so there doesn't need to be any of the unaligned
+ *		    stuff.  It has been commented out now...  --Ben
+ *
+ */
+void vlan_emulate_hwaccel(struct sk_buff **skbp)
+{
+	struct sk_buff *skb = *skbp;
+	struct vlan_hdr *vhdr;
+	u16 vlan_tci;
+
+	*skbp = skb = skb_share_check(skb, GFP_ATOMIC);
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
+	skb = vlan_check_reorder_header(skb);
+	if (unlikely(!skb)) {
+		goto err_free;
+	}
+
+	return;
+
+err_free:
+	kfree_skb(skb);
+	*skbp = NULL;
+	return;
+}
+
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index ae610f0..57d2f40 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -65,178 +65,6 @@ static int vlan_dev_rebuild_header(struct sk_buff *skb)
 	return 0;
 }
 
-static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
-{
-	if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
-		if (skb_cow(skb, skb_headroom(skb)) < 0)
-			skb = NULL;
-		if (skb) {
-			/* Lifted from Gleb's VLAN code... */
-			memmove(skb->data - ETH_HLEN,
-				skb->data - VLAN_ETH_HLEN, 12);
-			skb->mac_header += VLAN_HLEN;
-		}
-	}
-
-	return skb;
-}
-
-static inline void vlan_set_encap_proto(struct sk_buff *skb,
-		struct vlan_hdr *vhdr)
-{
-	__be16 proto;
-	unsigned char *rawp;
-
-	/*
-	 * Was a VLAN packet, grab the encapsulated protocol, which the layer
-	 * three protocols care about.
-	 */
-
-	proto = vhdr->h_vlan_encapsulated_proto;
-	if (ntohs(proto) >= 1536) {
-		skb->protocol = proto;
-		return;
-	}
-
-	rawp = skb->data;
-	if (*(unsigned short *)rawp == 0xFFFF)
-		/*
-		 * This is a magic hack to spot IPX packets. Older Novell
-		 * breaks the protocol design and runs IPX over 802.3 without
-		 * an 802.2 LLC layer. We look for FFFF which isn't a used
-		 * 802.2 SSAP/DSAP. This won't work for fault tolerant netware
-		 * but does for the rest.
-		 */
-		skb->protocol = htons(ETH_P_802_3);
-	else
-		/*
-		 * Real 802.2 LLC
-		 */
-		skb->protocol = htons(ETH_P_802_2);
-}
-
-/*
- *	Determine the packet's protocol ID. The rule here is that we
- *	assume 802.3 if the type field is short enough to be a length.
- *	This is normal practice and works for any 'now in use' protocol.
- *
- *  Also, at this point we assume that we ARE dealing exclusively with
- *  VLAN packets, or packets that should be made into VLAN packets based
- *  on a default VLAN ID.
- *
- *  NOTE:  Should be similar to ethernet/eth.c.
- *
- *  SANITY NOTE:  This method is called when a packet is moving up the stack
- *                towards userland.  To get here, it would have already passed
- *                through the ethernet/eth.c eth_type_trans() method.
- *  SANITY NOTE 2: We are referencing to the VLAN_HDR frields, which MAY be
- *                 stored UNALIGNED in the memory.  RISC systems don't like
- *                 such cases very much...
- *  SANITY NOTE 2a: According to Dave Miller & Alexey, it will always be
- *  		    aligned, so there doesn't need to be any of the unaligned
- *  		    stuff.  It has been commented out now...  --Ben
- *
- */
-int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
-		  struct packet_type *ptype, struct net_device *orig_dev)
-{
-	struct vlan_hdr *vhdr;
-	struct vlan_pcpu_stats *rx_stats;
-	struct net_device *vlan_dev;
-	u16 vlan_id;
-	u16 vlan_tci;
-
-	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (skb == NULL)
-		goto err_free;
-
-	if (unlikely(!pskb_may_pull(skb, VLAN_HLEN)))
-		goto err_free;
-
-	vhdr = (struct vlan_hdr *)skb->data;
-	vlan_tci = ntohs(vhdr->h_vlan_TCI);
-	vlan_id = vlan_tci & VLAN_VID_MASK;
-
-	rcu_read_lock();
-	vlan_dev = vlan_find_dev(dev, vlan_id);
-
-	/* If the VLAN device is defined, we use it.
-	 * If not, and the VID is 0, it is a 802.1p packet (not
-	 * really a VLAN), so we will just netif_rx it later to the
-	 * original interface, but with the skb->proto set to the
-	 * wrapped proto: we do nothing here.
-	 */
-
-	if (!vlan_dev) {
-		if (vlan_id) {
-			pr_debug("%s: ERROR: No net_device for VID: %u on dev: %s\n",
-				 __func__, vlan_id, dev->name);
-			goto err_unlock;
-		}
-		rx_stats = NULL;
-	} else {
-		skb->dev = vlan_dev;
-
-		rx_stats = this_cpu_ptr(vlan_dev_info(skb->dev)->vlan_pcpu_stats);
-
-		u64_stats_update_begin(&rx_stats->syncp);
-		rx_stats->rx_packets++;
-		rx_stats->rx_bytes += skb->len;
-
-		skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tci);
-
-		pr_debug("%s: priority: %u for TCI: %hu\n",
-			 __func__, skb->priority, vlan_tci);
-
-		switch (skb->pkt_type) {
-		case PACKET_BROADCAST:
-			/* Yeah, stats collect these together.. */
-			/* stats->broadcast ++; // no such counter :-( */
-			break;
-
-		case PACKET_MULTICAST:
-			rx_stats->rx_multicast++;
-			break;
-
-		case PACKET_OTHERHOST:
-			/* Our lower layer thinks this is not local, let's make
-			 * sure.
-			 * This allows the VLAN to have a different MAC than the
-			 * underlying device, and still route correctly.
-			 */
-			if (!compare_ether_addr(eth_hdr(skb)->h_dest,
-						skb->dev->dev_addr))
-				skb->pkt_type = PACKET_HOST;
-			break;
-		default:
-			break;
-		}
-		u64_stats_update_end(&rx_stats->syncp);
-	}
-
-	skb_pull_rcsum(skb, VLAN_HLEN);
-	vlan_set_encap_proto(skb, vhdr);
-
-	if (vlan_dev) {
-		skb = vlan_check_reorder_header(skb);
-		if (!skb) {
-			rx_stats->rx_errors++;
-			goto err_unlock;
-		}
-	}
-
-	netif_rx(skb);
-
-	rcu_read_unlock();
-	return NET_RX_SUCCESS;
-
-err_unlock:
-	rcu_read_unlock();
-err_free:
-	atomic_long_inc(&dev->rx_dropped);
-	kfree_skb(skb);
-	return NET_RX_DROP;
-}
 
 static inline u16
 vlan_dev_get_egress_qos_mask(struct net_device *dev, struct sk_buff *skb)
diff --git a/net/core/dev.c b/net/core/dev.c
index 9f66de9..f3315ef 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3133,10 +3133,6 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	if (netpoll_receive_skb(skb))
 		return NET_RX_DROP;
 
-	if (!skb->skb_iif)
-		skb->skb_iif = skb->dev->ifindex;
-	orig_dev = skb->dev;
-
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
 	skb->mac_len = skb->network_header - skb->mac_header;
@@ -3145,6 +3141,20 @@ static int __netif_receive_skb(struct sk_buff *skb)
 
 	rcu_read_lock();
 
+	if (!skb->skb_iif) {
+		skb->skb_iif = skb->dev->ifindex;
+		/*
+		 * frame is here for the first time so lets check if it's vlan
+		 * one and emulate vlan hwaccel in that case
+		 */
+		if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
+			vlan_emulate_hwaccel(&skb);
+			if (!skb)
+				goto out;
+		}
+	}
+	orig_dev = skb->dev;
+
 another_round:
 
 	__this_cpu_inc(softnet_data.processed);
-- 
1.7.4

