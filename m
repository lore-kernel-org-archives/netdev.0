From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next 2/6] sunvnet: add VIO v1.7 and v1.8 support
Date: Tue, 02 Dec 2014 15:31:04 -0500
Message-ID: <547E2188.3000502@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31133 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932844AbaLBUbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 15:31:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for VIO v1.7 (extended descriptor format)
and v1.8 (receive-side checksumming) to the sunvnet driver.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 arch/sparc/include/asm/vio.h       |   19 +++++++
 drivers/net/ethernet/sun/sunvnet.c |  102 ++++++++++++++++++++++++++++++++----
 2 files changed, 111 insertions(+), 10 deletions(-)

diff --git a/arch/sparc/include/asm/vio.h b/arch/sparc/include/asm/vio.h
index d758c8d..fb124fe 100644
--- a/arch/sparc/include/asm/vio.h
+++ b/arch/sparc/include/asm/vio.h
@@ -247,6 +247,25 @@ struct vio_net_desc {
 	struct ldc_trans_cookie	cookies[0];
 };
 
+struct vio_net_dext {
+	u8		flags;
+#define VNET_PKT_HASH			0x01
+#define	VNET_PKT_HCK_IPV4_HDRCKSUM	0x02
+#define	VNET_PKT_HCK_FULLCKSUM		0x04
+#define	VNET_PKT_IPV4_LSO		0x08
+#define	VNET_PKT_HCK_IPV4_HDRCKSUM_OK	0x10
+#define	VNET_PKT_HCK_FULLCKSUM_OK	0x20
+
+	u8		vnet_hashval;
+	u16		ipv4_lso_mss;
+	u32		resv3;
+};
+
+static inline struct vio_net_dext *vio_net_ext(struct vio_net_desc *desc)
+{
+	return (struct vio_net_dext *)&desc->cookies[2];
+}
+
 #define VIO_MAX_RING_COOKIES	24
 
 struct vio_dring_state {
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 62823fa..7a8da56 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -21,6 +21,7 @@
 #include <linux/icmpv6.h>
 #endif
 
+#include <net/ip.h>
 #include <net/icmp.h>
 #include <net/route.h>
 
@@ -51,6 +52,8 @@ static int __vnet_tx_trigger(struct vnet_port *port, u32 start);
 
 /* Ordered from largest major to lowest */
 static struct vio_version vnet_versions[] = {
+	{ .major = 1, .minor = 8 },
+	{ .major = 1, .minor = 7 },
 	{ .major = 1, .minor = 6 },
 	{ .major = 1, .minor = 0 },
 };
@@ -282,10 +285,42 @@ static struct sk_buff *alloc_and_align_skb(struct net_device *dev,
 	return skb;
 }
 
-static int vnet_rx_one(struct vnet_port *port, unsigned int len,
-		       struct ldc_trans_cookie *cookies, int ncookies)
+static inline void vnet_fullcsum(struct sk_buff *skb)
+{
+	struct iphdr *iph = ip_hdr(skb);
+	int offset = skb_transport_offset(skb);
+
+	if (skb->protocol != htons(ETH_P_IP))
+		return;
+	if (iph->protocol != IPPROTO_TCP &&
+	    iph->protocol != IPPROTO_UDP)
+		return;
+	skb->ip_summed = CHECKSUM_NONE;
+	skb->csum_level = 1;
+	skb->csum = 0;
+	if (iph->protocol == IPPROTO_TCP) {
+		struct tcphdr *ptcp = tcp_hdr(skb);
+
+		ptcp->check = 0;
+		skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
+		ptcp->check = csum_tcpudp_magic(iph->saddr, iph->daddr,
+						skb->len - offset, IPPROTO_TCP,
+						skb->csum);
+	} else if (iph->protocol == IPPROTO_UDP) {
+		struct udphdr *pudp = udp_hdr(skb);
+
+		pudp->check = 0;
+		skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
+		pudp->check = csum_tcpudp_magic(iph->saddr, iph->daddr,
+						skb->len - offset, IPPROTO_UDP,
+						skb->csum);
+	}
+}
+
+static int vnet_rx_one(struct vnet_port *port, struct vio_net_desc *desc)
 {
 	struct net_device *dev = port->vp->dev;
+	unsigned int len = desc->size;
 	unsigned int copy_len;
 	struct sk_buff *skb;
 	int err;
@@ -307,7 +342,7 @@ static int vnet_rx_one(struct vnet_port *port, unsigned int len,
 	skb_put(skb, copy_len);
 	err = ldc_copy(port->vio.lp, LDC_COPY_IN,
 		       skb->data, copy_len, 0,
-		       cookies, ncookies);
+		       desc->cookies, desc->ncookies);
 	if (unlikely(err < 0)) {
 		dev->stats.rx_frame_errors++;
 		goto out_free_skb;
@@ -317,6 +352,28 @@ static int vnet_rx_one(struct vnet_port *port, unsigned int len,
 	skb_trim(skb, len);
 	skb->protocol = eth_type_trans(skb, dev);
 
+	if (vio_version_after_eq(&port->vio, 1, 8)) {
+		struct vio_net_dext *dext = vio_net_ext(desc);
+
+		if (dext->flags & VNET_PKT_HCK_IPV4_HDRCKSUM) {
+			if (skb->protocol == ETH_P_IP) {
+				struct iphdr *iph = (struct iphdr *)skb->data;
+
+				iph->check = 0;
+				ip_send_check(iph);
+			}
+		}
+		if ((dext->flags & VNET_PKT_HCK_FULLCKSUM) &&
+		    skb->ip_summed == CHECKSUM_NONE)
+			vnet_fullcsum(skb);
+		if (dext->flags & VNET_PKT_HCK_IPV4_HDRCKSUM_OK) {
+			skb->ip_summed = CHECKSUM_PARTIAL;
+			skb->csum_level = 0;
+			if (dext->flags & VNET_PKT_HCK_FULLCKSUM_OK)
+				skb->csum_level = 1;
+		}
+	}
+
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += len;
 	napi_gro_receive(&port->napi, skb);
@@ -451,7 +508,7 @@ static int vnet_walk_rx_one(struct vnet_port *port,
 	       desc->cookies[0].cookie_addr,
 	       desc->cookies[0].cookie_size);
 
-	err = vnet_rx_one(port, desc->size, desc->cookies, desc->ncookies);
+	err = vnet_rx_one(port, desc);
 	if (err == -ECONNRESET)
 		return err;
 	desc->hdr.state = VIO_DESC_DONE;
@@ -940,8 +997,22 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, void **pstart,
 	if (((unsigned long)skb->data & 7) != VNET_PACKET_SKIP ||
 	    skb_tailroom(skb) < pad ||
 	    skb_headroom(skb) < VNET_PACKET_SKIP) {
+		int offset;
+
 		nskb = alloc_and_align_skb(skb->dev, skb->len);
 		skb_reserve(nskb, VNET_PACKET_SKIP);
+
+		nskb->protocol = skb->protocol;
+		offset = skb_mac_header(skb) - skb->data;
+		skb_set_mac_header(nskb, offset);
+		offset = skb_network_header(skb) - skb->data;
+		skb_set_network_header(nskb, offset);
+		offset = skb_transport_header(skb) - skb->data;
+		skb_set_transport_header(nskb, offset);
+
+		nskb->csum_offset = skb->csum_offset;
+		nskb->ip_summed = skb->ip_summed;
+
 		if (skb_copy_bits(skb, 0, nskb->data, skb->len)) {
 			dev_kfree_skb(nskb);
 			dev_kfree_skb(skb);
@@ -1078,6 +1149,16 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	d->ncookies = port->tx_bufs[txi].ncookies;
 	for (i = 0; i < d->ncookies; i++)
 		d->cookies[i] = port->tx_bufs[txi].cookies[i];
+	if (vio_version_after_eq(&port->vio, 1, 7)) {
+		struct vio_net_dext *dext = vio_net_ext(d);
+
+		memset(dext, 0, sizeof(*dext));
+		if (vio_version_after_eq(&port->vio, 1, 8) &&
+		    !port->switch_port) {
+			dext->flags |= VNET_PKT_HCK_IPV4_HDRCKSUM_OK;
+			dext->flags |= VNET_PKT_HCK_FULLCKSUM_OK;
+		}
+	}
 
 	/* This has to be a non-SMP write barrier because we are writing
 	 * to memory which is shared with the peer LDOM.
@@ -1370,15 +1451,17 @@ static void vnet_port_free_tx_bufs(struct vnet_port *port)
 static int vnet_port_alloc_tx_ring(struct vnet_port *port)
 {
 	struct vio_dring_state *dr;
-	unsigned long len;
+	unsigned long len, elen;
 	int i, err, ncookies;
 	void *dring;
 
 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
 
-	len = (VNET_TX_RING_SIZE *
-	       (sizeof(struct vio_net_desc) +
-		(sizeof(struct ldc_trans_cookie) * 2)));
+	elen = sizeof(struct vio_net_desc) +
+	       sizeof(struct ldc_trans_cookie) * 2;
+	if (vio_version_after_eq(&port->vio, 1, 7))
+		elen += sizeof(struct vio_net_dext);
+	len = VNET_TX_RING_SIZE * elen;
 
 	ncookies = VIO_MAX_RING_COOKIES;
 	dring = ldc_alloc_exp_dring(port->vio.lp, len,
@@ -1392,8 +1475,7 @@ static int vnet_port_alloc_tx_ring(struct vnet_port *port)
 	}
 
 	dr->base = dring;
-	dr->entry_size = (sizeof(struct vio_net_desc) +
-			  (sizeof(struct ldc_trans_cookie) * 2));
+	dr->entry_size = elen;
 	dr->num_entries = VNET_TX_RING_SIZE;
 	dr->prod = dr->cons = 0;
 	port->start_cons  = true; /* need an initial trigger */
-- 
1.7.1
