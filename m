From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCHv2 net-next 1/3] sunvnet: upgrade to VIO protocol version 1.6
Date: Fri, 12 Sep 2014 19:18:03 -0400
Message-ID: <54137F2B.4060302@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18663 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbaILXSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 19:18:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch upgrades the sunvnet driver to support VIO protocol version 1.6.
In particular, it adds per-port MTU negotiation, allowing MTUs other than
ETH_FRAMELEN with ports using newer VIO protocol versions.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 arch/sparc/include/asm/vio.h       |   19 ++++++-
 arch/sparc/kernel/viohs.c          |   14 +++++-
 drivers/net/ethernet/sun/sunvnet.c |   96 ++++++++++++++++++++++++++++++------
 drivers/net/ethernet/sun/sunvnet.h |    1 +
 4 files changed, 110 insertions(+), 20 deletions(-)

diff --git a/arch/sparc/include/asm/vio.h b/arch/sparc/include/asm/vio.h
index 5c0ebe7..da13e3b 100644
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
@@ -368,6 +381,8 @@ struct vio_driver_state {
 	char			*name;

 	struct vio_driver_ops	*ops;
+
+	u64			rmtu;	/* remote MTU */
 };

 #define viodbg(TYPE, f, a...) \
diff --git a/arch/sparc/kernel/viohs.c b/arch/sparc/kernel/viohs.c
index f8e7dd5..446438b 100644
--- a/arch/sparc/kernel/viohs.c
+++ b/arch/sparc/kernel/viohs.c
@@ -426,6 +426,13 @@ static int process_dreg_info(struct vio_driver_state *vio,
 	if (vio->dr_state & VIO_DR_STATE_RXREG)
 		goto send_nack;

+	/* v1.6 and higher, ACK with desired, supported mode, or NACK */
+	if (vio->ver.major <= 1 && vio->ver.minor >= 6) {
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
index a4657a4..a6418bb 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -15,6 +15,7 @@
 #include <linux/ethtool.h>
 #include <linux/etherdevice.h>
 #include <linux/mutex.h>
+#include <linux/if_vlan.h>

 #include <asm/vio.h>
 #include <asm/ldc.h>
@@ -39,6 +40,7 @@ MODULE_VERSION(DRV_MODULE_VERSION);

 /* Ordered from largest major to lowest */
 static struct vio_version vnet_versions[] = {
+	{ .major = 1, .minor = 6 },
 	{ .major = 1, .minor = 0 },
 };

@@ -65,6 +67,7 @@ static int vnet_send_attr(struct vio_driver_state *vio)
 	struct vnet_port *port = to_vnet_port(vio);
 	struct net_device *dev = port->vp->dev;
 	struct vio_net_attr_info pkt;
+	int framelen = ETH_FRAME_LEN;
 	int i;

 	memset(&pkt, 0, sizeof(pkt));
@@ -72,19 +75,37 @@ static int vnet_send_attr(struct vio_driver_state *vio)
 	pkt.tag.stype = VIO_SUBTYPE_INFO;
 	pkt.tag.stype_env = VIO_ATTR_INFO;
 	pkt.tag.sid = vio_send_sid(vio);
-	pkt.xfer_mode = VIO_DRING_MODE;
+	if (vio->ver.major <= 1 && vio->ver.minor < 2)
+		pkt.xfer_mode = VIO_DRING_MODE;
+	else
+		pkt.xfer_mode = VIO_NEW_DRING_MODE;
 	pkt.addr_type = VNET_ADDR_ETHERMAC;
 	pkt.ack_freq = 0;
 	for (i = 0; i < 6; i++)
 		pkt.addr |= (u64)dev->dev_addr[i] << ((5 - i) * 8);
-	pkt.mtu = ETH_FRAME_LEN;
+	if (vio->ver.major == 1) {
+		if (vio->ver.minor > 3) {
+			if (vio->rmtu)
+				vio->rmtu = pkt.mtu = min(VNET_MAXPACKET,
+							  vio->rmtu);
+			else
+				vio->rmtu = pkt.mtu = VNET_MAXPACKET;
+		} else if (vio->ver.minor == 3)
+			pkt.mtu = framelen + VLAN_HLEN;
+		else
+			pkt.mtu = framelen;
+		if (vio->ver.minor >= 6)
+			pkt.options = VIO_TX_DRING;
+	}

 	viodbg(HS, "SEND NET ATTR xmode[0x%x] atype[0x%x] addr[%llx] "
-	       "ackfreq[%u] mtu[%llu]\n",
+	       "ackfreq[%u] plnk_updt[0x%02x] opts[0x%02x] mtu[%llu] "
+	       "cflags[0x%04x] lso_max[%u]\n",
 	       pkt.xfer_mode, pkt.addr_type,
 	       (unsigned long long) pkt.addr,
-	       pkt.ack_freq,
-	       (unsigned long long) pkt.mtu);
+	       pkt.ack_freq, pkt.plnk_updt, pkt.options,
+	       (unsigned long long) pkt.mtu, pkt.cflags, pkt.ipv4_lso_maxlen);
+

 	return vio_ldc_send(vio, &pkt, sizeof(pkt));
 }
@@ -92,18 +113,52 @@ static int vnet_send_attr(struct vio_driver_state *vio)
 static int handle_attr_info(struct vio_driver_state *vio,
 			    struct vio_net_attr_info *pkt)
 {
-	viodbg(HS, "GOT NET ATTR INFO xmode[0x%x] atype[0x%x] addr[%llx] "
-	       "ackfreq[%u] mtu[%llu]\n",
+	u64	localmtu;
+	u8	xfer_mode;
+
+	viodbg(HS, "GOT NET ATTR xmode[0x%x] atype[0x%x] addr[%llx] "
+	       "ackfreq[%u] plnk_updt[0x%02x] opts[0x%02x] mtu[%llu] "
+	       " (rmtu[%llu]) cflags[0x%04x] lso_max[%u]\n",
 	       pkt->xfer_mode, pkt->addr_type,
 	       (unsigned long long) pkt->addr,
-	       pkt->ack_freq,
-	       (unsigned long long) pkt->mtu);
+	       pkt->ack_freq, pkt->plnk_updt, pkt->options,
+	       (unsigned long long) pkt->mtu, vio->rmtu, pkt->cflags,
+	       pkt->ipv4_lso_maxlen);

 	pkt->tag.sid = vio_send_sid(vio);

-	if (pkt->xfer_mode != VIO_DRING_MODE ||
+	xfer_mode = pkt->xfer_mode;
+	/* for version < 1.2, VIO_DRING_MODE = 0x3 and no bitmask */
+	if ((vio->ver.major <= 1 &&  vio->ver.minor < 2) &&
+	    xfer_mode == VIO_DRING_MODE)
+		xfer_mode = VIO_NEW_DRING_MODE;
+
+	/* MTU negotiation:
+	 *	< v1.3 - ETH_FRAME_LEN exactly
+	 *	= v1.3 - ETH_FRAME_LEN + VLAN_HLEN exactly
+	 *	> v1.4 - MIN(pkt.mtu, VNET_MAX_PACKET, vio->rmtu) and change
+	 *			pkt->mtu for ACK
+	 */
+	if (vio->ver.major == 1 && vio->ver.minor < 3) {
+		localmtu = ETH_FRAME_LEN;
+	} else if (vio->ver.major == 1 && vio->ver.minor == 3) {
+		localmtu = ETH_FRAME_LEN + VLAN_HLEN;
+	} else {
+		localmtu = vio->rmtu ? vio->rmtu : VNET_MAXPACKET;
+		localmtu = pkt->mtu = min(pkt->mtu, localmtu);
+	}
+	vio->rmtu = localmtu;
+
+
+	/* for version >= 1.6, ACK packet mode we support */
+	if (vio->ver.major <= 1 && vio->ver.minor >= 6) {
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
@@ -112,7 +167,14 @@ static int handle_attr_info(struct vio_driver_state *vio,

 		return -ECONNRESET;
 	} else {
-		viodbg(HS, "SEND NET ATTR ACK\n");
+		viodbg(HS, "SEND NET ATTR ACK xmode[0x%x] atype[0x%x] "
+		       "addr[%llx] ackfreq[%u] plnk_updt[0x%02x] opts[0x%02x] "
+		       "mtu[%llu] (rmtu[%llu]) cflags[0x%04x] lso_max[%u]\n",
+		       pkt->xfer_mode, pkt->addr_type,
+		       (unsigned long long) pkt->addr,
+		       pkt->ack_freq, pkt->plnk_updt, pkt->options,
+		       (unsigned long long) pkt->mtu, vio->rmtu, pkt->cflags,
+		       pkt->ipv4_lso_maxlen);

 		pkt->tag.stype = VIO_SUBTYPE_ACK;

@@ -208,7 +270,7 @@ static int vnet_rx_one(struct vnet_port *port, unsigned int len,
 	int err;

 	err = -EMSGSIZE;
-	if (unlikely(len < ETH_ZLEN || len > ETH_FRAME_LEN)) {
+	if (unlikely(len < ETH_ZLEN || len > port->vio.rmtu)) {
 		dev->stats.rx_length_errors++;
 		goto out_dropped;
 	}
@@ -528,8 +590,10 @@ static void vnet_event(void *arg, int event)
 		vio_link_state_change(vio, event);
 		spin_unlock_irqrestore(&vio->lock, flags);

-		if (event == LDC_EVENT_RESET)
+		if (event == LDC_EVENT_RESET) {
+			vio->rmtu = 0;
 			vio_port_up(vio);
+		}
 		return;
 	}

@@ -986,8 +1050,8 @@ static int vnet_port_alloc_tx_bufs(struct vnet_port *port)
 	void *dring;

 	for (i = 0; i < VNET_TX_RING_SIZE; i++) {
-		void *buf = kzalloc(ETH_FRAME_LEN + 8, GFP_KERNEL);
-		int map_len = (ETH_FRAME_LEN + 7) & ~7;
+		void *buf = kzalloc(VNET_MAXPACKET + 8, GFP_KERNEL);
+		int map_len = (VNET_MAXPACKET + 7) & ~7;

 		err = -ENOMEM;
 		if (!buf)
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index de5c2c6..243ae69 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -11,6 +11,7 @@
  */
 #define VNET_TX_TIMEOUT			(5 * HZ)

+#define VNET_MAXPACKET			1518ULL /* ETH_FRAMELEN + VLAN_HDR */
 #define VNET_TX_RING_SIZE		512
 #define VNET_TX_WAKEUP_THRESH(dr)	((dr)->pending / 4)

-- 
1.7.1
