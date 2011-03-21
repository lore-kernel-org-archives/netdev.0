From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] vlan: Fix duplicate delivery of vlan 0 packets to ETH_P_ALL packet sockets
Date: Mon, 21 Mar 2011 14:35:07 -0700
Message-ID: <m1sjugi2d0.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	=?utf-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Gross <jesse@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:44407 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632Ab1CUVfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 17:35:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For vlan data coming in from nics without vlan hardware accelleration we
get two copies of vlan packets with vlan id 0 on pf_packet sockets, causing
userspace to break.  This is caused by delivering the same packet to the same
networking device more than once.

The cleanest and simplist fix I can find is to make the vlan accellerated path
the common path for vlan tagged packets.   Moving the classification of vlan
tagged packets sooner and removes the need for vlan 0 packets to be double
delivered.  This has a small impact on the fast path.

The penalty on the fast path for the non-vlan tagged case should be a single
forward branch that is always predicted as not taken.  With some clean up
to the routines for vlan accelleration and non-vlan accelleration we should
be able to even remove that branch if it is a problem.

Once the classification is moved sooner the traditional vlan reception path
can be removed entirely.  Reducing duplicate maintenance for the vlan code.

Receiving non vlan accellerated packets into vlan_accel_do_receive only requires
adding the special case for hiding the vlan header from pf_packet sockets on
vlan headers.

While moving the code to hide the packet sockets I have fixed two bugs.  I moved
the rx_error case inside the proper stats collection bracket, and I have reduced
the received packet size by the number of bytes we are hiding.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 include/linux/if_vlan.h |    5 ++
 net/8021q/vlan.c        |    8 --
 net/8021q/vlan.h        |    2 -
 net/8021q/vlan_core.c   |   49 +++++++++++++-
 net/8021q/vlan_dev.c    |  173 -----------------------------------------------
 net/core/dev.c          |    9 +++
 6 files changed, 62 insertions(+), 184 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 635e1fa..7259fca 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -133,6 +133,7 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 			     u16 vlan_tci, int polling);
 extern bool vlan_hwaccel_do_receive(struct sk_buff **skb);
+extern void emulate_vlan_hwaccel(struct sk_buff *skb);
 extern gro_result_t
 vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 		 unsigned int vlan_tci, struct sk_buff *skb);
@@ -173,6 +174,10 @@ static inline bool vlan_hwaccel_do_receive(struct sk_buff **skb)
 	return false;
 }
 
+static void emulate_vlan_hwaccel(struct sk_buff *skb)
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
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 5687c9b..c3408de 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -75,8 +75,6 @@ static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
 }
 
 /* found in vlan_dev.c */
-int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
-		  struct packet_type *ptype, struct net_device *orig_dev);
 void vlan_dev_set_ingress_priority(const struct net_device *dev,
 				   u32 skb_prio, u16 vlan_prio);
 int vlan_dev_set_egress_priority(const struct net_device *dev,
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index ce8e3ab..a0849b9 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -4,6 +4,35 @@
 #include <linux/netpoll.h>
 #include "vlan.h"
 
+void emulate_vlan_hwaccel(struct sk_buff *skb)
+{
+	struct vlan_hdr *vhdr = (struct vlan_hdr *)skb->data;
+	__be16 proto;
+
+	if (!pskb_may_pull(skb, VLAN_HLEN))
+		return;
+
+	__vlan_hwaccel_put_tag(skb, vhdr->h_vlan_TCI);
+	skb_pull_rcsum(skb, VLAN_HLEN);
+
+	proto = vhdr->h_vlan_encapsulated_proto;
+	if (ntohs(proto) >= 1536)
+		skb->protocol = proto;
+	/*
+	 *      This is a magic hack to spot IPX packets. Older Novell breaks
+	 *      the protocol design and runs IPX over 802.3 without an 802.2 LLC
+	 *      layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
+	 *      won't work for fault tolerant netware but does for the rest.
+	 */
+	else if (skb->len >= 2 && *(unsigned short *)(skb->data) == 0xFFFF)
+		skb->protocol = htons(ETH_P_802_3);
+	/*
+	 *      Real 802.2 LLC
+	 */
+	else
+		skb->protocol = htons(ETH_P_802_2);
+}
+
 bool vlan_hwaccel_do_receive(struct sk_buff **skbp)
 {
 	struct sk_buff *skb = *skbp;
@@ -47,9 +76,27 @@ bool vlan_hwaccel_do_receive(struct sk_buff **skbp)
 			skb->pkt_type = PACKET_HOST;
 		break;
 	}
+
+	/* Hide the vlan header if it is present but we don't want to see it.
+	 */
+	if ((skb->mac_len == VLAN_ETH_HLEN) &&
+	    (vlan_dev_info(vlan_dev)->flags & VLAN_FLAG_REORDER_HDR)) {
+		if (skb_cow(skb, skb_headroom(skb)) < 0)
+			skb = NULL;
+		if (skb) {
+			/* Move up the mac addresses to hide the vlan header */
+			memmove(skb->data - ETH_HLEN,
+				skb->data - VLAN_ETH_HLEN, 12);
+			skb->mac_header += VLAN_HLEN;
+			rx_stats->rx_bytes -= VLAN_HLEN;
+		}
+		else
+			rx_stats->rx_errors++;
+	}
+
 	u64_stats_update_end(&rx_stats->syncp);
 
-	return true;
+	return skb != NULL;
 }
 
 struct net_device *vlan_dev_real_dev(const struct net_device *dev)
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index ae610f0..f37b1d5 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -65,179 +65,6 @@ static int vlan_dev_rebuild_header(struct sk_buff *skb)
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
-
 static inline u16
 vlan_dev_get_egress_qos_mask(struct net_device *dev, struct sk_buff *skb)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 2e26606..53d17f1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3152,6 +3152,15 @@ static int __netif_receive_skb(struct sk_buff *skb)
 		skb->skb_iif = skb->dev->ifindex;
 	orig_dev = skb->dev;
 
+	/* If a vlan header is present pretend to be hardware accelerated
+	 * to remove special cases and to prevent duplicate delivery to
+	 * ETH_P_ALL sockets in the case vlan id == 0, where the vlan
+	 * header is only used to set the packets priority.
+	 */
+	if (unlikely(skb->protocol == htons(ETH_P_8021Q) &&
+		     !vlan_tx_tag_present(skb)))
+		emulate_vlan_hwaccel(skb);
+
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
 	skb->mac_len = skb->network_header - skb->mac_header;
-- 
1.7.4

