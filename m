From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCHv8 net-next 1/4] sunvnet: upgrade to VIO protocol version 1.6
Date: Mon, 29 Sep 2014 15:53:56 -0400
Message-ID: <5429B8D4.4050907@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Raghuram Kothahota <raghuram.kothakota@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46475 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507AbaI2TxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 15:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch upgrades the sunvnet driver to support VIO protocol version 1.6.
In particular, it adds per-port MTU negotiation, allowing MTUs other than
ETH_FRAMELEN with ports using newer VIO protocol versions.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 arch/sparc/include/asm/vio.h       |   44 ++++++++++++++-
 arch/sparc/kernel/viohs.c          |   14 ++++-
 drivers/net/ethernet/sun/sunvnet.c |  104 +++++++++++++++++++++++++++++------
 drivers/net/ethernet/sun/sunvnet.h |    3 +
 4 files changed, 143 insertions(+), 22 deletions(-)

diff --git a/arch/sparc/include/asm/vio.h b/arch/sparc/include/asm/vio.h
index 5c0ebe7..107d4a4 100644
--- a/arch/sparc/include/asm/vio.h
+++ b/arch/sparc/include/asm/vio.h
@@ -65,6 +65,7 @@ struct vio_dring_register {
 	u16			options;
 #define VIO_TX_DRING		0x0001
 #define VIO_RX_DRING		0x0002
+#define VIO_RX_DRING_DATA	0x0004
 	u16			resv;
 	u32			num_cookies;
 	struct ldc_trans_cookie	cookies[0];
@@ -80,6 +81,8 @@ struct vio_dring_unregister {
 #define VIO_PKT_MODE		0x01 /* Packet based transfer	*/
 #define VIO_DESC_MODE		0x02 /* In-band descriptors	*/
 #define VIO_DRING_MODE		0x03 /* Descriptor rings	*/
+/* in vers >= 1.2, VIO_DRING_MODE is 0x04 and transfer mode is a bitmask */
+#define VIO_NEW_DRING_MODE	0x04
 
 struct vio_dring_data {
 	struct vio_msg_tag	tag;
@@ -209,10 +212,20 @@ struct vio_net_attr_info {
 	u8			addr_type;
 #define VNET_ADDR_ETHERMAC	0x01
 	u16			ack_freq;
-	u32			resv1;
+	u8			plnk_updt;
+#define PHYSLINK_UPDATE_NONE		0x00
+#define PHYSLINK_UPDATE_STATE		0x01
+#define PHYSLINK_UPDATE_STATE_ACK	0x02
+#define PHYSLINK_UPDATE_STATE_NACK	0x03
+	u8			options;
+	u16			resv1;
 	u64			addr;
 	u64			mtu;
-	u64			resv2[3];
+	u16			cflags;
+#define VNET_LSO_IPV4_CAPAB		0x0001
+	u16			ipv4_lso_maxlen;
+	u32			resv2;
+	u64			resv3[2];
 };
 
 #define VNET_NUM_MCAST		7
@@ -370,6 +383,33 @@ struct vio_driver_state {
 	struct vio_driver_ops	*ops;
 };
 
+static inline bool vio_version_before(struct vio_driver_state *vio,
+				      u16 major, u16 minor)
+{
+	u32 have = (u32)vio->ver.major << 16 | vio->ver.minor;
+	u32 want = (u32)major << 16 | minor;
+
+	return have < want;
+}
+
+static inline bool vio_version_after(struct vio_driver_state *vio,
+				      u16 major, u16 minor)
+{
+	u32 have = (u32)vio->ver.major << 16 | vio->ver.minor;
+	u32 want = (u32)major << 16 | minor;
+
+	return have > want;
+}
+
+static inline bool vio_version_after_eq(struct vio_driver_state *vio,
+					u16 major, u16 minor)
+{
+	u32 have = (u32)vio->ver.major << 16 | vio->ver.minor;
+	u32 want = (u32)major << 16 | minor;
+
+	return have >= want;
+}
+
 #define viodbg(TYPE, f, a...) \
 do {	if (vio->debug & VIO_DEBUG_##TYPE) \
 		printk(KERN_INFO "vio: ID[%lu] " f, \
diff --git a/arch/sparc/kernel/viohs.c b/arch/sparc/kernel/viohs.c
index f8e7dd5..7ef081a 100644
--- a/arch/sparc/kernel/viohs.c
+++ b/arch/sparc/kernel/viohs.c
@@ -426,6 +426,13 @@ static int process_dreg_info(struct vio_driver_state *vio,
 	if (vio->dr_state & VIO_DR_STATE_RXREG)
 		goto send_nack;
 
+	/* v1.6 and higher, ACK with desired, supported mode, or NACK */
+	if (vio_version_after_eq(vio, 1, 6)) {
+		if (!(pkt->options & VIO_TX_DRING))
+			goto send_nack;
+		pkt->options = VIO_TX_DRING;
+	}
+
 	BUG_ON(vio->desc_buf);
 
 	vio->desc_buf = kzalloc(pkt->descr_size, GFP_ATOMIC);
@@ -453,8 +460,11 @@ static int process_dreg_info(struct vio_driver_state *vio,
 	pkt->tag.stype = VIO_SUBTYPE_ACK;
 	pkt->dring_ident = ++dr->ident;
 
-	viodbg(HS, "SEND DRING_REG ACK ident[%llx]\n",
-	       (unsigned long long) pkt->dring_ident);
+	viodbg(HS, "SEND DRING_REG ACK ident[%llx] "
+	       "ndesc[%u] dsz[%u] opt[0x%x] ncookies[%u]\n",
+	       (unsigned long long) pkt->dring_ident,
+	       pkt->num_descr, pkt->descr_size, pkt->options,
+	       pkt->num_cookies);
 
 	len = (sizeof(*pkt) +
 	       (dr->ncookies * sizeof(struct ldc_trans_cookie)));
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index edb8609..b1abcad 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -15,6 +15,7 @@
 #include <linux/ethtool.h>
 #include <linux/etherdevice.h>
 #include <linux/mutex.h>
+#include <linux/if_vlan.h>
 
 #include <asm/vio.h>
 #include <asm/ldc.h>
@@ -41,6 +42,7 @@ static int __vnet_tx_trigger(struct vnet_port *port, u32 start);
 
 /* Ordered from largest major to lowest */
 static struct vio_version vnet_versions[] = {
+	{ .major = 1, .minor = 6 },
 	{ .major = 1, .minor = 0 },
 };
 
@@ -67,6 +69,7 @@ static int vnet_send_attr(struct vio_driver_state *vio)
 	struct vnet_port *port = to_vnet_port(vio);
 	struct net_device *dev = port->vp->dev;
 	struct vio_net_attr_info pkt;
+	int framelen = ETH_FRAME_LEN;
 	int i;
 
 	memset(&pkt, 0, sizeof(pkt));
@@ -74,19 +77,41 @@ static int vnet_send_attr(struct vio_driver_state *vio)
 	pkt.tag.stype = VIO_SUBTYPE_INFO;
 	pkt.tag.stype_env = VIO_ATTR_INFO;
 	pkt.tag.sid = vio_send_sid(vio);
-	pkt.xfer_mode = VIO_DRING_MODE;
+	if (vio_version_before(vio, 1, 2))
+		pkt.xfer_mode = VIO_DRING_MODE;
+	else
+		pkt.xfer_mode = VIO_NEW_DRING_MODE;
 	pkt.addr_type = VNET_ADDR_ETHERMAC;
 	pkt.ack_freq = 0;
 	for (i = 0; i < 6; i++)
 		pkt.addr |= (u64)dev->dev_addr[i] << ((5 - i) * 8);
-	pkt.mtu = ETH_FRAME_LEN;
+	if (vio_version_after(vio, 1, 3)) {
+		if (port->rmtu) {
+			port->rmtu = min(VNET_MAXPACKET, port->rmtu);
+			pkt.mtu = port->rmtu;
+		} else {
+			port->rmtu = VNET_MAXPACKET;
+			pkt.mtu = port->rmtu;
+		}
+		if (vio_version_after_eq(vio, 1, 6))
+			pkt.options = VIO_TX_DRING;
+	} else if (vio_version_before(vio, 1, 3)) {
+		pkt.mtu = framelen;
+	} else { /* v1.3 */
+		pkt.mtu = framelen + VLAN_HLEN;
+	}
+
+	pkt.plnk_updt = PHYSLINK_UPDATE_NONE;
+	pkt.cflags = 0;
 
 	viodbg(HS, "SEND NET ATTR xmode[0x%x] atype[0x%x] addr[%llx] "
-	       "ackfreq[%u] mtu[%llu]\n",
+	       "ackfreq[%u] plnk_updt[0x%02x] opts[0x%02x] mtu[%llu] "
+	       "cflags[0x%04x] lso_max[%u]\n",
 	       pkt.xfer_mode, pkt.addr_type,
-	       (unsigned long long) pkt.addr,
-	       pkt.ack_freq,
-	       (unsigned long long) pkt.mtu);
+	       (unsigned long long)pkt.addr,
+	       pkt.ack_freq, pkt.plnk_updt, pkt.options,
+	       (unsigned long long)pkt.mtu, pkt.cflags, pkt.ipv4_lso_maxlen);
+
 
 	return vio_ldc_send(vio, &pkt, sizeof(pkt));
 }
@@ -94,18 +119,52 @@ static int vnet_send_attr(struct vio_driver_state *vio)
 static int handle_attr_info(struct vio_driver_state *vio,
 			    struct vio_net_attr_info *pkt)
 {
-	viodbg(HS, "GOT NET ATTR INFO xmode[0x%x] atype[0x%x] addr[%llx] "
-	       "ackfreq[%u] mtu[%llu]\n",
+	struct vnet_port *port = to_vnet_port(vio);
+	u64	localmtu;
+	u8	xfer_mode;
+
+	viodbg(HS, "GOT NET ATTR xmode[0x%x] atype[0x%x] addr[%llx] "
+	       "ackfreq[%u] plnk_updt[0x%02x] opts[0x%02x] mtu[%llu] "
+	       " (rmtu[%llu]) cflags[0x%04x] lso_max[%u]\n",
 	       pkt->xfer_mode, pkt->addr_type,
-	       (unsigned long long) pkt->addr,
-	       pkt->ack_freq,
-	       (unsigned long long) pkt->mtu);
+	       (unsigned long long)pkt->addr,
+	       pkt->ack_freq, pkt->plnk_updt, pkt->options,
+	       (unsigned long long)pkt->mtu, port->rmtu, pkt->cflags,
+	       pkt->ipv4_lso_maxlen);
 
 	pkt->tag.sid = vio_send_sid(vio);
 
-	if (pkt->xfer_mode != VIO_DRING_MODE ||
+	xfer_mode = pkt->xfer_mode;
+	/* for version < 1.2, VIO_DRING_MODE = 0x3 and no bitmask */
+	if (vio_version_before(vio, 1, 2) && xfer_mode == VIO_DRING_MODE)
+		xfer_mode = VIO_NEW_DRING_MODE;
+
+	/* MTU negotiation:
+	 *	< v1.3 - ETH_FRAME_LEN exactly
+	 *	> v1.3 - MIN(pkt.mtu, VNET_MAXPACKET, port->rmtu) and change
+	 *			pkt->mtu for ACK
+	 *	= v1.3 - ETH_FRAME_LEN + VLAN_HLEN exactly
+	 */
+	if (vio_version_before(vio, 1, 3)) {
+		localmtu = ETH_FRAME_LEN;
+	} else if (vio_version_after(vio, 1, 3)) {
+		localmtu = port->rmtu ? port->rmtu : VNET_MAXPACKET;
+		localmtu = min(pkt->mtu, localmtu);
+		pkt->mtu = localmtu;
+	} else { /* v1.3 */
+		localmtu = ETH_FRAME_LEN + VLAN_HLEN;
+	}
+	port->rmtu = localmtu;
+
+	/* for version >= 1.6, ACK packet mode we support */
+	if (vio_version_after_eq(vio, 1, 6)) {
+		pkt->xfer_mode = VIO_NEW_DRING_MODE;
+		pkt->options = VIO_TX_DRING;
+	}
+
+	if (!(xfer_mode | VIO_NEW_DRING_MODE) ||
 	    pkt->addr_type != VNET_ADDR_ETHERMAC ||
-	    pkt->mtu != ETH_FRAME_LEN) {
+	    pkt->mtu != localmtu) {
 		viodbg(HS, "SEND NET ATTR NACK\n");
 
 		pkt->tag.stype = VIO_SUBTYPE_NACK;
@@ -114,7 +173,14 @@ static int handle_attr_info(struct vio_driver_state *vio,
 
 		return -ECONNRESET;
 	} else {
-		viodbg(HS, "SEND NET ATTR ACK\n");
+		viodbg(HS, "SEND NET ATTR ACK xmode[0x%x] atype[0x%x] "
+		       "addr[%llx] ackfreq[%u] plnk_updt[0x%02x] opts[0x%02x] "
+		       "mtu[%llu] (rmtu[%llu]) cflags[0x%04x] lso_max[%u]\n",
+		       pkt->xfer_mode, pkt->addr_type,
+		       (unsigned long long)pkt->addr,
+		       pkt->ack_freq, pkt->plnk_updt, pkt->options,
+		       (unsigned long long)pkt->mtu, port->rmtu, pkt->cflags,
+		       pkt->ipv4_lso_maxlen);
 
 		pkt->tag.stype = VIO_SUBTYPE_ACK;
 
@@ -210,7 +276,7 @@ static int vnet_rx_one(struct vnet_port *port, unsigned int len,
 	int err;
 
 	err = -EMSGSIZE;
-	if (unlikely(len < ETH_ZLEN || len > ETH_FRAME_LEN)) {
+	if (unlikely(len < ETH_ZLEN || len > port->rmtu)) {
 		dev->stats.rx_length_errors++;
 		goto out_dropped;
 	}
@@ -558,8 +624,10 @@ static void vnet_event(void *arg, int event)
 		vio_link_state_change(vio, event);
 		spin_unlock_irqrestore(&vio->lock, flags);
 
-		if (event == LDC_EVENT_RESET)
+		if (event == LDC_EVENT_RESET) {
+			port->rmtu = 0;
 			vio_port_up(vio);
+		}
 		return;
 	}
 
@@ -1051,8 +1119,8 @@ static int vnet_port_alloc_tx_bufs(struct vnet_port *port)
 	void *dring;
 
 	for (i = 0; i < VNET_TX_RING_SIZE; i++) {
-		void *buf = kzalloc(ETH_FRAME_LEN + 8, GFP_KERNEL);
-		int map_len = (ETH_FRAME_LEN + 7) & ~7;
+		void *buf = kzalloc(VNET_MAXPACKET + 8, GFP_KERNEL);
+		int map_len = (VNET_MAXPACKET + 7) & ~7;
 
 		err = -ENOMEM;
 		if (!buf)
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index da49337..986e04b 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -11,6 +11,7 @@
  */
 #define VNET_TX_TIMEOUT			(5 * HZ)
 
+#define VNET_MAXPACKET			1518ULL /* ETH_FRAMELEN + VLAN_HDR */
 #define VNET_TX_RING_SIZE		512
 #define VNET_TX_WAKEUP_THRESH(dr)	((dr)->pending / 4)
 
@@ -44,6 +45,8 @@ struct vnet_port {
 	u32			stop_rx_idx;
 	bool			stop_rx;
 	bool			start_cons;
+
+	u64			rmtu;
 };
 
 static inline struct vnet_port *to_vnet_port(struct vio_driver_state *vio)
-- 
1.7.1
