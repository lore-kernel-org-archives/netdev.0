From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver updates #2
Date: Sun, 03 Feb 2008 04:21:24 -0800 (PST)
Message-ID: <20080203.042124.194900974.davem@davemloft.net>
References: <20080201210338.GA11084@havoc.gtf.org>
	<20080201.215210.247648606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46623
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761564AbYBCMU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 07:20:59 -0500
In-Reply-To: <20080201.215210.247648606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 01 Feb 2008 21:52:10 -0800 (PST)

> From: Jeff Garzik <jeff@garzik.org>
> Date: Fri, 1 Feb 2008 16:03:38 -0500
> 
> > Please pull from 'upstream2-davem' branch of
> 
> This is now pulled and pushed back out to net-2.6

The first S2io patch breaks the build so I'm removing it from the
net-2.6 tree.  I suspect you rejected an earlier patch that added the
tx_lock member to the S2IO device private.

If you do that Jeff, please at least do a quick sanity check of the
build.

If, instead, I messed things up somehow, my apologies in advance.

drivers/net/s2io.c: In function 's2io_vlan_rx_kill_vid':
drivers/net/s2io.c:395: error: 'struct s2io_nic' has no member named 'tx_lock'
drivers/net/s2io.c:399: error: 'struct s2io_nic' has no member named 'tx_lock'

S2io: Support for vlan_rx_kill_vid entry point

- Added s2io_vlan_rx_kill_vid entry point function for unregistering vlan.
- Fix to aggregate vlan packets. IP offset is incremented by
  4 bytes if the packet contains vlan header.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
Signed-off-by: Jeff Garzik <jeff@garzik.org>
---
 drivers/net/s2io.c |  108 +++++++++++++++++++++++++++++-----------------------
 drivers/net/s2io.h |    7 ++-
 2 files changed, 65 insertions(+), 50 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 5fab7d7..dcad502 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -386,6 +386,19 @@ static void s2io_vlan_rx_register(struct net_device *dev,
 /* A flag indicating whether 'RX_PA_CFG_STRIP_VLAN_TAG' bit is set or not */
 static int vlan_strip_flag;
 
+/* Unregister the vlan */
+static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned long vid)
+{
+	unsigned long flags;
+	struct s2io_nic *nic = dev->priv;
+
+	spin_lock_irqsave(&nic->tx_lock, flags);
+	if (nic->vlgrp)
+		vlan_group_set_device(nic->vlgrp, vid, NULL);
+
+	spin_unlock_irqrestore(&nic->tx_lock, flags);
+}
+
 /*
  * Constants to be programmed into the Xena's registers, to configure
  * the XAUI.
@@ -2948,7 +2961,7 @@ static void rx_intr_handler(struct ring_info *ring_data)
 			struct lro *lro = &nic->lro0_n[i];
 			if (lro->in_use) {
 				update_L3L4_header(nic, lro);
-				queue_rx_frame(lro->parent);
+				queue_rx_frame(lro->parent, lro->vlan_tag);
 				clear_lro_session(lro);
 			}
 		}
@@ -7371,7 +7384,8 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 					{
 						lro_append_pkt(sp, lro,
 							skb, tcp_len);
-						queue_rx_frame(lro->parent);
+						queue_rx_frame(lro->parent,
+							lro->vlan_tag);
 						clear_lro_session(lro);
 						sp->mac_control.stats_info->
 						    sw_stat.flush_max_pkts++;
@@ -7382,7 +7396,8 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 							lro->frags_len;
 						sp->mac_control.stats_info->
 						     sw_stat.sending_both++;
-						queue_rx_frame(lro->parent);
+						queue_rx_frame(lro->parent,
+							lro->vlan_tag);
 						clear_lro_session(lro);
 						goto send_up;
 					case 0: /* sessions exceeded */
@@ -7408,31 +7423,12 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 			 */
 			skb->ip_summed = CHECKSUM_NONE;
 		}
-	} else {
+	} else
 		skb->ip_summed = CHECKSUM_NONE;
-	}
+
 	sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
-	if (!sp->lro) {
-		skb->protocol = eth_type_trans(skb, dev);
-		if ((sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2) &&
-			vlan_strip_flag)) {
-			/* Queueing the vlan frame to the upper layer */
-			if (napi)
-				vlan_hwaccel_receive_skb(skb, sp->vlgrp,
-					RXD_GET_VLAN_TAG(rxdp->Control_2));
-			else
-				vlan_hwaccel_rx(skb, sp->vlgrp,
-					RXD_GET_VLAN_TAG(rxdp->Control_2));
-		} else {
-			if (napi)
-				netif_receive_skb(skb);
-			else
-				netif_rx(skb);
-		}
-	} else {
 send_up:
-		queue_rx_frame(skb);
-	}
+	queue_rx_frame(skb, RXD_GET_VLAN_TAG(rxdp->Control_2));
 	dev->last_rx = jiffies;
 aggregate:
 	atomic_dec(&sp->rx_bufs_left[ring_no]);
@@ -7790,6 +7786,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register = s2io_vlan_rx_register;
+	dev->vlan_rx_kill_vid = (void *)s2io_vlan_rx_kill_vid;
 
 	/*
 	 * will use eth_mac_addr() for  dev->set_mac_address
@@ -8061,7 +8058,8 @@ module_init(s2io_starter);
 module_exit(s2io_closer);
 
 static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
-		struct tcphdr **tcp, struct RxD_t *rxdp)
+		struct tcphdr **tcp, struct RxD_t *rxdp,
+		struct s2io_nic *sp)
 {
 	int ip_off;
 	u8 l2_type = (u8)((rxdp->Control_1 >> 37) & 0x7), ip_len;
@@ -8072,19 +8070,20 @@ static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
 		return -1;
 	}
 
-	/* TODO:
-	 * By default the VLAN field in the MAC is stripped by the card, if this
-	 * feature is turned off in rx_pa_cfg register, then the ip_off field
-	 * has to be shifted by a further 2 bytes
-	 */
-	switch (l2_type) {
-		case 0: /* DIX type */
-		case 4: /* DIX type with VLAN */
-			ip_off = HEADER_ETHERNET_II_802_3_SIZE;
-			break;
+	/* Checking for DIX type or DIX type with VLAN */
+	if ((l2_type == 0)
+		|| (l2_type == 4)) {
+		ip_off = HEADER_ETHERNET_II_802_3_SIZE;
+		/*
+		 * If vlan stripping is disabled and the frame is VLAN tagged,
+		 * shift the offset by the VLAN header size bytes.
+		 */
+		if ((!vlan_strip_flag) &&
+			(rxdp->Control_1 & RXD_FRAME_VLAN_TAG))
+			ip_off += HEADER_VLAN_SIZE;
+	} else {
 		/* LLC, SNAP etc are considered non-mergeable */
-		default:
-			return -1;
+		return -1;
 	}
 
 	*ip = (struct iphdr *)((u8 *)buffer + ip_off);
@@ -8111,7 +8110,7 @@ static inline int get_l4_pyld_length(struct iphdr *ip, struct tcphdr *tcp)
 }
 
 static void initiate_new_session(struct lro *lro, u8 *l2h,
-		     struct iphdr *ip, struct tcphdr *tcp, u32 tcp_pyld_len)
+	struct iphdr *ip, struct tcphdr *tcp, u32 tcp_pyld_len, u16 vlan_tag)
 {
 	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
 	lro->l2h = l2h;
@@ -8122,6 +8121,7 @@ static void initiate_new_session(struct lro *lro, u8 *l2h,
 	lro->sg_num = 1;
 	lro->total_len = ntohs(ip->tot_len);
 	lro->frags_len = 0;
+	lro->vlan_tag = vlan_tag;
 	/*
 	 * check if we saw TCP timestamp. Other consistency checks have
 	 * already been done.
@@ -8253,15 +8253,16 @@ s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
 	struct iphdr *ip;
 	struct tcphdr *tcph;
 	int ret = 0, i;
+	u16 vlan_tag = 0;
 
 	if (!(ret = check_L2_lro_capable(buffer, &ip, (struct tcphdr **)tcp,
-					 rxdp))) {
+					 rxdp, sp))) {
 		DBG_PRINT(INFO_DBG,"IP Saddr: %x Daddr: %x\n",
 			  ip->saddr, ip->daddr);
-	} else {
+	} else
 		return ret;
-	}
 
+	vlan_tag = RXD_GET_VLAN_TAG(rxdp->Control_2);
 	tcph = (struct tcphdr *)*tcp;
 	*tcp_len = get_l4_pyld_length(ip, tcph);
 	for (i=0; i<MAX_LRO_SESSIONS; i++) {
@@ -8321,7 +8322,8 @@ s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
 
 	switch (ret) {
 		case 3:
-			initiate_new_session(*lro, buffer, ip, tcph, *tcp_len);
+			initiate_new_session(*lro, buffer, ip, tcph, *tcp_len,
+								vlan_tag);
 			break;
 		case 2:
 			update_L3L4_header(sp, *lro);
@@ -8349,15 +8351,25 @@ static void clear_lro_session(struct lro *lro)
 	memset(lro, 0, lro_struct_size);
 }
 
-static void queue_rx_frame(struct sk_buff *skb)
+static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag)
 {
 	struct net_device *dev = skb->dev;
+	struct s2io_nic *sp = dev->priv;
 
 	skb->protocol = eth_type_trans(skb, dev);
-	if (napi)
-		netif_receive_skb(skb);
-	else
-		netif_rx(skb);
+	if (sp->vlgrp && vlan_tag
+		&& (vlan_strip_flag)) {
+		/* Queueing the vlan frame to the upper layer */
+		if (sp->config.napi)
+			vlan_hwaccel_receive_skb(skb, sp->vlgrp, vlan_tag);
+		else
+			vlan_hwaccel_rx(skb, sp->vlgrp, vlan_tag);
+	} else {
+		if (sp->config.napi)
+			netif_receive_skb(skb);
+		else
+			netif_rx(skb);
+	}
 }
 
 static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 9f6016c..2cbbb83 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -534,6 +534,7 @@ struct RxD_t {
 #define RXD_OWN_XENA            s2BIT(7)
 #define RXD_T_CODE              (s2BIT(12)|s2BIT(13)|s2BIT(14)|s2BIT(15))
 #define RXD_FRAME_PROTO         vBIT(0xFFFF,24,8)
+#define RXD_FRAME_VLAN_TAG      s2BIT(24)
 #define RXD_FRAME_PROTO_IPV4    s2BIT(27)
 #define RXD_FRAME_PROTO_IPV6    s2BIT(28)
 #define RXD_FRAME_IP_FRAG	s2BIT(29)
@@ -808,10 +809,12 @@ struct lro {
 	int		sg_num;
 	int		in_use;
 	__be16		window;
+	u16             vlan_tag;
 	u32		cur_tsval;
 	u32		cur_tsecr;
 	u8		saw_ts;
-};
+} ____cacheline_aligned;
+
 
 /* These flags represent the devices temporary state */
 enum s2io_device_state_t
@@ -1087,7 +1090,7 @@ static int
 s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
 		      struct RxD_t *rxdp, struct s2io_nic *sp);
 static void clear_lro_session(struct lro *lro);
-static void queue_rx_frame(struct sk_buff *skb);
+static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag);
 static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro);
 static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
 			   struct sk_buff *skb, u32 tcp_len);
-- 
1.5.4.rc5

