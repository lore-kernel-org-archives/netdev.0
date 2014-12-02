From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next 6/6] sunvnet: add TSO support
Date: Tue, 02 Dec 2014 15:31:38 -0500
Message-ID: <547E21AA.6080603@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31335 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932711AbaLBUbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 15:31:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds TSO support for the sunvnet driver.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   95 +++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/sun/sunvnet.h |    9 +++-
 2 files changed, 95 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index d19b358..b883add 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -120,8 +120,15 @@ static int vnet_send_attr(struct vio_driver_state *vio)
 		pkt.mtu = framelen + VLAN_HLEN;
 	}
 
-	pkt.plnk_updt = PHYSLINK_UPDATE_NONE;
 	pkt.cflags = 0;
+	if (vio_version_after_eq(vio, 1, 7) && port->tso) {
+		pkt.cflags |= VNET_LSO_IPV4_CAPAB;
+		if (!port->tsolen)
+			port->tsolen = VNET_MAXTSO;
+		pkt.ipv4_lso_maxlen = port->tsolen;
+	}
+
+	pkt.plnk_updt = PHYSLINK_UPDATE_NONE;
 
 	viodbg(HS, "SEND NET ATTR xmode[0x%x] atype[0x%x] addr[%llx] "
 	       "ackfreq[%u] plnk_updt[0x%02x] opts[0x%02x] mtu[%llu] "
@@ -175,6 +182,26 @@ static int handle_attr_info(struct vio_driver_state *vio,
 	}
 	port->rmtu = localmtu;
 
+	/* LSO negotiation */
+	if (vio_version_after_eq(vio, 1, 7))
+		port->tso &= !!(pkt->cflags & VNET_LSO_IPV4_CAPAB);
+	else
+		port->tso = false;
+	if (port->tso) {
+		if (!port->tsolen)
+			port->tsolen = VNET_MAXTSO;
+		port->tsolen = min(port->tsolen, pkt->ipv4_lso_maxlen);
+		if (port->tsolen < VNET_MINTSO) {
+			port->tso = false;
+			port->tsolen = 0;
+			pkt->cflags &= ~VNET_LSO_IPV4_CAPAB;
+		}
+		pkt->ipv4_lso_maxlen = port->tsolen;
+	} else {
+		pkt->cflags &= ~VNET_LSO_IPV4_CAPAB;
+		pkt->ipv4_lso_maxlen = 0;
+	}
+
 	/* for version >= 1.6, ACK packet mode we support */
 	if (vio_version_after_eq(vio, 1, 6)) {
 		pkt->xfer_mode = VIO_NEW_DRING_MODE;
@@ -721,6 +748,8 @@ ldc_ctrl:
 
 		if (event == LDC_EVENT_RESET) {
 			port->rmtu = 0;
+			port->tso = true;
+			port->tsolen = 0;
 			vio_port_up(vio);
 		}
 		port->rx_event = 0;
@@ -1131,10 +1160,36 @@ static int vnet_handle_offloads(struct vnet_port *port, struct sk_buff *skb)
 	struct net_device *dev = port->vp->dev;
 	struct vio_dring_state *dr = &port->vio.drings[VIO_DRIVER_TX_RING];
 	struct sk_buff *segs;
-	int maclen;
+	int maclen, datalen;
 	int status;
+	int gso_size, gso_type, gso_segs;
+	int hlen = skb_transport_header(skb) - skb_mac_header(skb);
+	int proto = IPPROTO_IP;
+
+	if (skb->protocol == htons(ETH_P_IP))
+		proto = ip_hdr(skb)->protocol;
+	else if (skb->protocol == htons(ETH_P_IPV6))
+		proto = ipv6_hdr(skb)->nexthdr;
+
+	if (proto == IPPROTO_TCP)
+		hlen += tcp_hdr(skb)->doff * 4;
+	else if (proto == IPPROTO_UDP)
+		hlen += sizeof(struct udphdr);
+	else {
+		pr_err("vnet_handle_offloads GSO with unknown transport "
+		       "protocol %d tproto %d\n", skb->protocol, proto);
+		hlen = 128; /* XXX */
+	}
+	datalen = port->tsolen - hlen;
+
+	gso_size = skb_shinfo(skb)->gso_size;
+	gso_type = skb_shinfo(skb)->gso_type;
+	gso_segs = skb_shinfo(skb)->gso_segs;
+
+	if (port->tso && gso_size < datalen)
+		gso_segs = DIV_ROUND_UP(skb->len - hlen, datalen);
 
-	if (unlikely(vnet_tx_dring_avail(dr) < skb_shinfo(skb)->gso_segs)) {
+	if (unlikely(vnet_tx_dring_avail(dr) < gso_segs)) {
 		struct netdev_queue *txq;
 
 		txq  = netdev_get_tx_queue(dev, port->q_index);
@@ -1147,7 +1202,19 @@ static int vnet_handle_offloads(struct vnet_port *port, struct sk_buff *skb)
 	maclen = skb_network_header(skb) - skb_mac_header(skb);
 	skb_pull(skb, maclen);
 
-	segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO);
+	if (port->tso && gso_size < datalen) {
+		/* segment to TSO size */
+		skb_shinfo(skb)->gso_size = datalen;
+		skb_shinfo(skb)->gso_segs = gso_segs;
+
+		segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO);
+
+		/* restore gso_size & gso_segs */
+		skb_shinfo(skb)->gso_size = gso_size;
+		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len - hlen,
+							 gso_size);
+	} else
+		segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO);
 	if (IS_ERR(segs)) {
 		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
@@ -1162,6 +1229,13 @@ static int vnet_handle_offloads(struct vnet_port *port, struct sk_buff *skb)
 
 		segs = segs->next;
 		curr->next = NULL;
+		if (port->tso && curr->len > dev->mtu) {
+			skb_shinfo(curr)->gso_size = gso_size;
+			skb_shinfo(curr)->gso_type = gso_type;
+			skb_shinfo(curr)->gso_segs = 
+				DIV_ROUND_UP(curr->len - hlen, gso_size);
+		} else
+			skb_shinfo(curr)->gso_size = 0;
 
 		skb_push(curr, maclen);
 		skb_reset_mac_header(curr);
@@ -1203,13 +1277,13 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out_dropped;
 	}
 
-	if (skb_is_gso(skb)) {
+	if (skb_is_gso(skb) && skb->len > port->tsolen) {
 		err = vnet_handle_offloads(port, skb);
 		rcu_read_unlock();
 		return err;
 	}
 
-	if (skb->len > port->rmtu) {
+	if (!skb_is_gso(skb) && skb->len > port->rmtu) {
 		unsigned long localmtu = port->rmtu - ETH_HLEN;
 
 		if (vio_version_after_eq(&port->vio, 1, 3))
@@ -1306,6 +1380,11 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		struct vio_net_dext *dext = vio_net_ext(d);
 
 		memset(dext, 0, sizeof(*dext));
+		if (skb_is_gso(port->tx_bufs[txi].skb)) {
+			dext->ipv4_lso_mss = skb_shinfo(port->tx_bufs[txi].skb)
+					     ->gso_size;
+			dext->flags |= VNET_PKT_IPV4_LSO;
+		}
 		if (vio_version_after_eq(&port->vio, 1, 8) &&
 		    !port->switch_port) {
 			dext->flags |= VNET_PKT_HCK_IPV4_HDRCKSUM_OK;
@@ -1712,7 +1791,7 @@ static struct vnet *vnet_new(const u64 *local_mac)
 	dev->ethtool_ops = &vnet_ethtool_ops;
 	dev->watchdog_timeo = VNET_TX_TIMEOUT;
 
-	dev->hw_features = NETIF_F_GSO | NETIF_F_GSO_SOFTWARE |
+	dev->hw_features = NETIF_F_TSO | NETIF_F_GSO | NETIF_F_GSO_SOFTWARE |
 			   NETIF_F_HW_CSUM | NETIF_F_SG;
 	dev->features = dev->hw_features;
 
@@ -1892,6 +1971,8 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	if (mdesc_get_property(hp, vdev->mp, "switch-port", NULL) != NULL)
 		switch_port = 1;
 	port->switch_port = switch_port;
+	port->tso = true;
+	port->tsolen = 0;
 
 	spin_lock_irqsave(&vp->lock, flags);
 	if (switch_port)
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index cd5d343..01ca781 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -20,6 +20,9 @@
 #define VNET_TX_RING_SIZE		512
 #define VNET_TX_WAKEUP_THRESH(dr)	((dr)->pending / 4)
 
+#define	VNET_MINTSO	 2048	/* VIO protocol's minimum TSO len */
+#define	VNET_MAXTSO	65535	/* VIO protocol's maximum TSO len */
+
 /* VNET packets are sent in buffers with the first 6 bytes skipped
  * so that after the ethernet header the IPv4/IPv6 headers are aligned
  * properly.
@@ -40,8 +43,9 @@ struct vnet_port {
 
 	struct hlist_node	hash;
 	u8			raddr[ETH_ALEN];
-	u8			switch_port;
-	u8			__pad;
+	unsigned		switch_port:1;
+	unsigned		tso:1;
+	unsigned		__pad:14;
 
 	struct vnet		*vp;
 
@@ -56,6 +60,7 @@ struct vnet_port {
 	struct timer_list	clean_timer;
 
 	u64			rmtu;
+	u16			tsolen;
 
 	struct napi_struct	napi;
 	u32			napi_stop_idx;
-- 
1.7.1
