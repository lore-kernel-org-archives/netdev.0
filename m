From: Pedro Garcia <pedro.netdev@dondevamos.com>
Subject: Re: [PATCH] =?UTF-8?Q?vlan=5Fdev=3A=20VLAN=20=30=20should=20be=20treated?=
 =?UTF-8?Q?=20as=20=22no=20vlan=20tag=22=20=28=38=30=32=2E=31p=20packet=29?=
Date: Sun, 18 Jul 2010 18:43:25 +0200
Message-ID: <957a5becb6e742b6dc3255b68bef3ba8@dondevamos.com>
References: <311b59aee7d648c6124a84b5ca06ac60@dondevamos.com> <1276679284.2632.22.camel@edumazet-laptop> <c38a6e1add643eb78bd0d28ee3984cf4@dondevamos.com> <20100630.131616.233403329.davem@davemloft.net> <a372414c0d74e9ab599d095627353d94@dondevamos.com> <1278015554.2782.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Patrick McHardy <kaber@trash.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 13.Red-213-97-209.staticIP.rima-tde.net ([213.97.209.13]:43732
	"EHLO smtp1.dondevamos.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756643Ab0GRQnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 12:43:35 -0400
In-Reply-To: <1278015554.2782.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 01 Jul 2010 22:19:14 +0200, Eric Dumazet <eric.dumazet@gmail.com>
wrote:

> Seems fine but you need to respin your patch against latest net-next-2.6
> tree.
> 
> Check your tree got commit 9618e2ffd78aaa (vlan: 64 bit rx counters)
> 
> Thanks !

The patch applied to the lastest tree:

- Without the 8021q module loaded in the kernel, all 802.1p packets 
(VLAN 0 but QoS tagging) are silently discarded (as expected, as 
the protocol is not loaded).
 
- Without this patch in 8021q module, these packets are forwarded to 
the module, but they are discarded also if VLAN 0 is not configured,
which should not be the default behaviour, as VLAN 0 is not really
a VLANed packet but a 802.1p packet. Defining VLAN 0 makes it almost
impossible to communicate with mixed 802.1p and non 802.1p devices on
the same network due to arp table issues.

- Changed logic to skip vlan specific code in vlan_skb_recv if VLAN 
is 0 and we have not defined a VLAN with ID 0, but we accept the 
packet with the encapsulated proto and pass it later to netif_rx.

- In the vlan device event handler, added some logic to add VLAN 0 
to HW filter in devices that support it (this prevented any traffic
in VLAN 0 to reach the stack in e1000e with HW filter under 2.6.35,
and probably also with other HW filtered cards, so we fix it here).

- In the vlan unregister logic, prevent the elimination of VLAN 0 
in devices with HW filter.

- The default behaviour is to ignore the VLAN 0 tagging and accept
the packet as if it was not tagged, but we can still define a 
VLAN 0 if desired (so it is backwards compatible).

Signed-off-by: Pedro Garcia <pedro.netdev@dondevamos.com>
--
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 3c1c8c1..a2ad152 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -155,9 +155,10 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	BUG_ON(!grp);
 
 	/* Take it out of our own structures, but be sure to interlock with
-	 * HW accelerating devices or SW vlan input packet processing.
+	 * HW accelerating devices or SW vlan input packet processing if
+	 * VLAN is not 0 (leave it there for 802.1p).
 	 */
-	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
+	if (vlan_id && (real_dev->features & NETIF_F_HW_VLAN_FILTER))
 		ops->ndo_vlan_rx_kill_vid(real_dev, vlan_id);
 
 	grp->nr_vlans--;
@@ -419,6 +420,14 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	if (is_vlan_dev(dev))
 		__vlan_device_event(dev, event);
 
+	if ((event == NETDEV_UP) &&
+	    (dev->features & NETIF_F_HW_VLAN_FILTER) &&
+	    dev->netdev_ops->ndo_vlan_rx_add_vid) {
+		pr_info("8021q: adding VLAN 0 to HW filter on device %s\n",
+			dev->name);
+		dev->netdev_ops->ndo_vlan_rx_add_vid(dev, 0);
+	}
+
 	grp = __vlan_find_group(dev);
 	if (!grp)
 		goto out;
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 1b9406a..01ddb04 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -8,6 +8,9 @@
 int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		      u16 vlan_tci, int polling)
 {
+	struct net_device *vlan_dev;
+	u16 vlan_id;
+
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
 
@@ -16,9 +19,12 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 
 	skb->skb_iif = skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
-	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
+	vlan_id = vlan_tci & VLAN_VID_MASK;
+	vlan_dev = vlan_group_get_device(grp, vlan_id);
 
-	if (!skb->dev)
+	if (vlan_dev)
+		skb->dev = vlan_dev;
+	else if (vlan_id)
 		goto drop;
 
 	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
@@ -83,15 +89,20 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 		unsigned int vlan_tci, struct sk_buff *skb)
 {
 	struct sk_buff *p;
+	struct net_device *vlan_dev;
+	u16 vlan_id;
 
 	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
 		skb->deliver_no_wcard = 1;
 
 	skb->skb_iif = skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
-	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
+	vlan_id = vlan_tci & VLAN_VID_MASK;
+	vlan_dev = vlan_group_get_device(grp, vlan_id);
 
-	if (!skb->dev)
+	if (vlan_dev)
+		skb->dev = vlan_dev;
+	else if (vlan_id)
 		goto drop;
 
 	for (p = napi->gro_list; p; p = p->next) {
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 7cb285f..3d59c9b 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -142,6 +142,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 {
 	struct vlan_hdr *vhdr;
 	struct vlan_rx_stats *rx_stats;
+	struct net_device *vlan_dev;
 	u16 vlan_id;
 	u16 vlan_tci;
 
@@ -157,55 +158,71 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	vlan_id = vlan_tci & VLAN_VID_MASK;
 
 	rcu_read_lock();
-	skb->dev = __find_vlan_dev(dev, vlan_id);
-	if (!skb->dev) {
-		pr_debug("%s: ERROR: No net_device for VID: %u on dev: %s\n",
-			 __func__, vlan_id, dev->name);
-		goto err_unlock;
-	}
-
-	rx_stats = per_cpu_ptr(vlan_dev_info(skb->dev)->vlan_rx_stats,
-			       smp_processor_id());
-	u64_stats_update_begin(&rx_stats->syncp);
-	rx_stats->rx_packets++;
-	rx_stats->rx_bytes += skb->len;
-
-	skb_pull_rcsum(skb, VLAN_HLEN);
-
-	skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tci);
+	vlan_dev = __find_vlan_dev(dev, vlan_id);
 
-	pr_debug("%s: priority: %u for TCI: %hu\n",
-		 __func__, skb->priority, vlan_tci);
-
-	switch (skb->pkt_type) {
-	case PACKET_BROADCAST: /* Yeah, stats collect these together.. */
-		/* stats->broadcast ++; // no such counter :-( */
-		break;
-
-	case PACKET_MULTICAST:
-		rx_stats->rx_multicast++;
-		break;
+	/* If the VLAN device is defined, we use it.
+	 * If not, and the VID is 0, it is a 802.1p packet (not
+	 * really a VLAN), so we will just netif_rx it later to the
+	 * original interface, but with the skb->proto set to the
+	 * wrapped proto: we do nothing here.
+	 */
 
-	case PACKET_OTHERHOST:
-		/* Our lower layer thinks this is not local, let's make sure.
-		 * This allows the VLAN to have a different MAC than the
-		 * underlying device, and still route correctly.
-		 */
-		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
-					skb->dev->dev_addr))
-			skb->pkt_type = PACKET_HOST;
-		break;
-	default:
-		break;
+	if (!vlan_dev) {
+		if (vlan_id) {
+			pr_debug("%s: ERROR: No net_device for VID: %u on dev: %s\n",
+				 __func__, vlan_id, dev->name);
+			goto err_unlock;
+		}
+		rx_stats = NULL;
+	} else {
+		skb->dev = vlan_dev;
+
+		rx_stats = per_cpu_ptr(vlan_dev_info(skb->dev)->vlan_rx_stats,
+					smp_processor_id());
+		u64_stats_update_begin(&rx_stats->syncp);
+		rx_stats->rx_packets++;
+		rx_stats->rx_bytes += skb->len;
+
+		skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tci);
+
+		pr_debug("%s: priority: %u for TCI: %hu\n",
+			 __func__, skb->priority, vlan_tci);
+
+		switch (skb->pkt_type) {
+		case PACKET_BROADCAST:
+			/* Yeah, stats collect these together.. */
+			/* stats->broadcast ++; // no such counter :-( */
+			break;
+
+		case PACKET_MULTICAST:
+			rx_stats->rx_multicast++;
+			break;
+
+		case PACKET_OTHERHOST:
+			/* Our lower layer thinks this is not local, let's make
+			 * sure.
+			 * This allows the VLAN to have a different MAC than the
+			 * underlying device, and still route correctly.
+			 */
+			if (!compare_ether_addr(eth_hdr(skb)->h_dest,
+						skb->dev->dev_addr))
+				skb->pkt_type = PACKET_HOST;
+			break;
+		default:
+			break;
+		}
+		u64_stats_update_end(&rx_stats->syncp);
 	}
-	u64_stats_update_end(&rx_stats->syncp);
 
+	skb_pull_rcsum(skb, VLAN_HLEN);
 	vlan_set_encap_proto(skb, vhdr);
 
-	skb = vlan_check_reorder_header(skb);
-	if (!skb) {
-		rx_stats->rx_errors++;
-		goto err_unlock;
+	if (vlan_dev) {
+		skb = vlan_check_reorder_header(skb);
+		if (!skb) {
+			rx_stats->rx_errors++;
+			goto err_unlock;
+		}
 	}
 
 	netif_rx(skb);

