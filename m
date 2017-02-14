From: Anssi Hannula <anssi.hannula@bitwise.fi>
Subject: [PATCH 2/2] net: xilinx_emaclite: fix freezes due to unordered I/O
Date: Tue, 14 Feb 2017 19:11:45 +0200
Message-ID: <20170214171145.26953-2-anssi.hannula@bitwise.fi>
References: <20170214171145.26953-1-anssi.hannula@bitwise.fi>
Cc: Michal Simek <michal.simek@xilinx.com>,
        =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bitwise.fi ([109.204.228.163]:40618 "EHLO mail.bitwise.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753767AbdBNRVE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 12:21:04 -0500
In-Reply-To: <20170214171145.26953-1-anssi.hannula@bitwise.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xilinx_emaclite uses __raw_writel and __raw_readl for register
accesses. Those functions do not imply any kind of memory barriers and
they may be reordered.

The driver does not seem to take that into account, though, and the
driver does not satisfy the ordering requirements of the hardware.
For clear examples, see xemaclite_mdio_write() and xemaclite_mdio_read()
which try to set MDIO address before initiating the transaction.

I'm seeing system freezes with the driver with GCC 5.4 and current
Linux kernels on Zynq-7000 SoC immediately when trying to use the
interface.

In commit 123c1407af87 ("net: emaclite: Do not use microblaze and ppc
IO functions") the driver was switched from non-generic
in_be32/out_be32 (memory barriers, big endian) to
__raw_readl/__raw_writel (no memory barriers, native endian), so
apparently the device follows system endianness and the driver was
originally written with the assumption of memory barriers.

Rather than try to hunt for each case of missing barrier, just switch
the driver to use iowrite32/ioread32/iowrite32be/ioread32be depending
on endianness instead.

Tested on little-endian Zynq-7000 ARM SoC FPGA.

Signed-off-by: Anssi Hannula <anssi.hannula@bitwise.fi>
Fixes: 123c1407af87 ("net: emaclite: Do not use microblaze and ppc IO
functions")

---

Not sure what would be the correct way to fix this. This way seems to
work, at least, but maybe something else would be better?

 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 116 ++++++++++++++------------
 1 file changed, 62 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index bd6470f..69e31ce 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -100,6 +100,14 @@
 /* BUFFER_ALIGN(adr) calculates the number of bytes to the next alignment. */
 #define BUFFER_ALIGN(adr) ((ALIGNMENT - ((u32) adr)) % ALIGNMENT)
 
+#ifdef __BIG_ENDIAN
+#define xemaclite_readl		ioread32be
+#define xemaclite_writel	iowrite32be
+#else
+#define xemaclite_readl		ioread32
+#define xemaclite_writel	iowrite32
+#endif
+
 /**
  * struct net_local - Our private per device data
  * @ndev:		instance of the network device
@@ -156,15 +164,15 @@ static void xemaclite_enable_interrupts(struct net_local *drvdata)
 	u32 reg_data;
 
 	/* Enable the Tx interrupts for the first Buffer */
-	reg_data = __raw_readl(drvdata->base_addr + XEL_TSR_OFFSET);
-	__raw_writel(reg_data | XEL_TSR_XMIT_IE_MASK,
-		     drvdata->base_addr + XEL_TSR_OFFSET);
+	reg_data = xemaclite_readl(drvdata->base_addr + XEL_TSR_OFFSET);
+	xemaclite_writel(reg_data | XEL_TSR_XMIT_IE_MASK,
+			 drvdata->base_addr + XEL_TSR_OFFSET);
 
 	/* Enable the Rx interrupts for the first buffer */
-	__raw_writel(XEL_RSR_RECV_IE_MASK, drvdata->base_addr + XEL_RSR_OFFSET);
+	xemaclite_writel(XEL_RSR_RECV_IE_MASK, drvdata->base_addr + XEL_RSR_OFFSET);
 
 	/* Enable the Global Interrupt Enable */
-	__raw_writel(XEL_GIER_GIE_MASK, drvdata->base_addr + XEL_GIER_OFFSET);
+	xemaclite_writel(XEL_GIER_GIE_MASK, drvdata->base_addr + XEL_GIER_OFFSET);
 }
 
 /**
@@ -179,17 +187,17 @@ static void xemaclite_disable_interrupts(struct net_local *drvdata)
 	u32 reg_data;
 
 	/* Disable the Global Interrupt Enable */
-	__raw_writel(XEL_GIER_GIE_MASK, drvdata->base_addr + XEL_GIER_OFFSET);
+	xemaclite_writel(XEL_GIER_GIE_MASK, drvdata->base_addr + XEL_GIER_OFFSET);
 
 	/* Disable the Tx interrupts for the first buffer */
-	reg_data = __raw_readl(drvdata->base_addr + XEL_TSR_OFFSET);
-	__raw_writel(reg_data & (~XEL_TSR_XMIT_IE_MASK),
-		     drvdata->base_addr + XEL_TSR_OFFSET);
+	reg_data = xemaclite_readl(drvdata->base_addr + XEL_TSR_OFFSET);
+	xemaclite_writel(reg_data & (~XEL_TSR_XMIT_IE_MASK),
+			 drvdata->base_addr + XEL_TSR_OFFSET);
 
 	/* Disable the Rx interrupts for the first buffer */
-	reg_data = __raw_readl(drvdata->base_addr + XEL_RSR_OFFSET);
-	__raw_writel(reg_data & (~XEL_RSR_RECV_IE_MASK),
-		     drvdata->base_addr + XEL_RSR_OFFSET);
+	reg_data = xemaclite_readl(drvdata->base_addr + XEL_RSR_OFFSET);
+	xemaclite_writel(reg_data & (~XEL_RSR_RECV_IE_MASK),
+			 drvdata->base_addr + XEL_RSR_OFFSET);
 }
 
 /**
@@ -321,7 +329,7 @@ static int xemaclite_send_data(struct net_local *drvdata, u8 *data,
 		byte_count = ETH_FRAME_LEN;
 
 	/* Check if the expected buffer is available */
-	reg_data = __raw_readl(addr + XEL_TSR_OFFSET);
+	reg_data = xemaclite_readl(addr + XEL_TSR_OFFSET);
 	if ((reg_data & (XEL_TSR_XMIT_BUSY_MASK |
 	     XEL_TSR_XMIT_ACTIVE_MASK)) == 0) {
 
@@ -334,7 +342,7 @@ static int xemaclite_send_data(struct net_local *drvdata, u8 *data,
 
 		addr = (void __iomem __force *)((u32 __force)addr ^
 						 XEL_BUFFER_OFFSET);
-		reg_data = __raw_readl(addr + XEL_TSR_OFFSET);
+		reg_data = xemaclite_readl(addr + XEL_TSR_OFFSET);
 
 		if ((reg_data & (XEL_TSR_XMIT_BUSY_MASK |
 		     XEL_TSR_XMIT_ACTIVE_MASK)) != 0)
@@ -345,16 +353,16 @@ static int xemaclite_send_data(struct net_local *drvdata, u8 *data,
 	/* Write the frame to the buffer */
 	xemaclite_aligned_write(data, (u32 __force *) addr, byte_count);
 
-	__raw_writel((byte_count & XEL_TPLR_LENGTH_MASK),
-		     addr + XEL_TPLR_OFFSET);
+	xemaclite_writel((byte_count & XEL_TPLR_LENGTH_MASK),
+			 addr + XEL_TPLR_OFFSET);
 
 	/* Update the Tx Status Register to indicate that there is a
 	 * frame to send. Set the XEL_TSR_XMIT_ACTIVE_MASK flag which
 	 * is used by the interrupt handler to check whether a frame
 	 * has been transmitted */
-	reg_data = __raw_readl(addr + XEL_TSR_OFFSET);
+	reg_data = xemaclite_readl(addr + XEL_TSR_OFFSET);
 	reg_data |= (XEL_TSR_XMIT_BUSY_MASK | XEL_TSR_XMIT_ACTIVE_MASK);
-	__raw_writel(reg_data, addr + XEL_TSR_OFFSET);
+	xemaclite_writel(reg_data, addr + XEL_TSR_OFFSET);
 
 	return 0;
 }
@@ -379,7 +387,7 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data, int maxlen)
 	addr = (drvdata->base_addr + drvdata->next_rx_buf_to_use);
 
 	/* Verify which buffer has valid data */
-	reg_data = __raw_readl(addr + XEL_RSR_OFFSET);
+	reg_data = xemaclite_readl(addr + XEL_RSR_OFFSET);
 
 	if ((reg_data & XEL_RSR_RECV_DONE_MASK) == XEL_RSR_RECV_DONE_MASK) {
 		if (drvdata->rx_ping_pong != 0)
@@ -396,14 +404,14 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data, int maxlen)
 			return 0;	/* No data was available */
 
 		/* Verify that buffer has valid data */
-		reg_data = __raw_readl(addr + XEL_RSR_OFFSET);
+		reg_data = xemaclite_readl(addr + XEL_RSR_OFFSET);
 		if ((reg_data & XEL_RSR_RECV_DONE_MASK) !=
 		     XEL_RSR_RECV_DONE_MASK)
 			return 0;	/* No data was available */
 	}
 
 	/* Get the protocol type of the ethernet frame that arrived */
-	proto_type = ((ntohl(__raw_readl(addr + XEL_HEADER_OFFSET +
+	proto_type = ((ntohl(xemaclite_readl(addr + XEL_HEADER_OFFSET +
 			XEL_RXBUFF_OFFSET)) >> XEL_HEADER_SHIFT) &
 			XEL_RPLR_LENGTH_MASK);
 
@@ -412,7 +420,7 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data, int maxlen)
 	if (proto_type > ETH_DATA_LEN) {
 
 		if (proto_type == ETH_P_IP) {
-			length = ((ntohl(__raw_readl(addr +
+			length = ((ntohl(xemaclite_readl(addr +
 					XEL_HEADER_IP_LENGTH_OFFSET +
 					XEL_RXBUFF_OFFSET)) >>
 					XEL_HEADER_SHIFT) &
@@ -438,9 +446,9 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data, int maxlen)
 				data, length);
 
 	/* Acknowledge the frame */
-	reg_data = __raw_readl(addr + XEL_RSR_OFFSET);
+	reg_data = xemaclite_readl(addr + XEL_RSR_OFFSET);
 	reg_data &= ~XEL_RSR_RECV_DONE_MASK;
-	__raw_writel(reg_data, addr + XEL_RSR_OFFSET);
+	xemaclite_writel(reg_data, addr + XEL_RSR_OFFSET);
 
 	return length;
 }
@@ -467,14 +475,14 @@ static void xemaclite_update_address(struct net_local *drvdata,
 
 	xemaclite_aligned_write(address_ptr, (u32 __force *) addr, ETH_ALEN);
 
-	__raw_writel(ETH_ALEN, addr + XEL_TPLR_OFFSET);
+	xemaclite_writel(ETH_ALEN, addr + XEL_TPLR_OFFSET);
 
 	/* Update the MAC address in the EmacLite */
-	reg_data = __raw_readl(addr + XEL_TSR_OFFSET);
-	__raw_writel(reg_data | XEL_TSR_PROG_MAC_ADDR, addr + XEL_TSR_OFFSET);
+	reg_data = xemaclite_readl(addr + XEL_TSR_OFFSET);
+	xemaclite_writel(reg_data | XEL_TSR_PROG_MAC_ADDR, addr + XEL_TSR_OFFSET);
 
 	/* Wait for EmacLite to finish with the MAC address update */
-	while ((__raw_readl(addr + XEL_TSR_OFFSET) &
+	while ((xemaclite_readl(addr + XEL_TSR_OFFSET) &
 		XEL_TSR_PROG_MAC_ADDR) != 0)
 		;
 }
@@ -644,32 +652,32 @@ static irqreturn_t xemaclite_interrupt(int irq, void *dev_id)
 	u32 tx_status;
 
 	/* Check if there is Rx Data available */
-	if ((__raw_readl(base_addr + XEL_RSR_OFFSET) &
+	if ((xemaclite_readl(base_addr + XEL_RSR_OFFSET) &
 			 XEL_RSR_RECV_DONE_MASK) ||
-	    (__raw_readl(base_addr + XEL_BUFFER_OFFSET + XEL_RSR_OFFSET)
+	    (xemaclite_readl(base_addr + XEL_BUFFER_OFFSET + XEL_RSR_OFFSET)
 			 & XEL_RSR_RECV_DONE_MASK))
 
 		xemaclite_rx_handler(dev);
 
 	/* Check if the Transmission for the first buffer is completed */
-	tx_status = __raw_readl(base_addr + XEL_TSR_OFFSET);
+	tx_status = xemaclite_readl(base_addr + XEL_TSR_OFFSET);
 	if (((tx_status & XEL_TSR_XMIT_BUSY_MASK) == 0) &&
 		(tx_status & XEL_TSR_XMIT_ACTIVE_MASK) != 0) {
 
 		tx_status &= ~XEL_TSR_XMIT_ACTIVE_MASK;
-		__raw_writel(tx_status, base_addr + XEL_TSR_OFFSET);
+		xemaclite_writel(tx_status, base_addr + XEL_TSR_OFFSET);
 
 		tx_complete = true;
 	}
 
 	/* Check if the Transmission for the second buffer is completed */
-	tx_status = __raw_readl(base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET);
+	tx_status = xemaclite_readl(base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET);
 	if (((tx_status & XEL_TSR_XMIT_BUSY_MASK) == 0) &&
 		(tx_status & XEL_TSR_XMIT_ACTIVE_MASK) != 0) {
 
 		tx_status &= ~XEL_TSR_XMIT_ACTIVE_MASK;
-		__raw_writel(tx_status, base_addr + XEL_BUFFER_OFFSET +
-			     XEL_TSR_OFFSET);
+		xemaclite_writel(tx_status, base_addr + XEL_BUFFER_OFFSET +
+				 XEL_TSR_OFFSET);
 
 		tx_complete = true;
 	}
@@ -702,7 +710,7 @@ static int xemaclite_mdio_wait(struct net_local *lp)
 	/* wait for the MDIO interface to not be busy or timeout
 	   after some time.
 	*/
-	while (__raw_readl(lp->base_addr + XEL_MDIOCTRL_OFFSET) &
+	while (xemaclite_readl(lp->base_addr + XEL_MDIOCTRL_OFFSET) &
 			XEL_MDIOCTRL_MDIOSTS_MASK) {
 		if (time_before_eq(end, jiffies)) {
 			WARN_ON(1);
@@ -738,17 +746,17 @@ static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 	 * MDIO Address register. Set the Status bit in the MDIO Control
 	 * register to start a MDIO read transaction.
 	 */
-	ctrl_reg = __raw_readl(lp->base_addr + XEL_MDIOCTRL_OFFSET);
-	__raw_writel(XEL_MDIOADDR_OP_MASK |
-		     ((phy_id << XEL_MDIOADDR_PHYADR_SHIFT) | reg),
-		     lp->base_addr + XEL_MDIOADDR_OFFSET);
-	__raw_writel(ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK,
-		     lp->base_addr + XEL_MDIOCTRL_OFFSET);
+	ctrl_reg = xemaclite_readl(lp->base_addr + XEL_MDIOCTRL_OFFSET);
+	xemaclite_writel(XEL_MDIOADDR_OP_MASK |
+			 ((phy_id << XEL_MDIOADDR_PHYADR_SHIFT) | reg),
+			 lp->base_addr + XEL_MDIOADDR_OFFSET);
+	xemaclite_writel(ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK,
+			 lp->base_addr + XEL_MDIOCTRL_OFFSET);
 
 	if (xemaclite_mdio_wait(lp))
 		return -ETIMEDOUT;
 
-	rc = __raw_readl(lp->base_addr + XEL_MDIORD_OFFSET);
+	rc = xemaclite_readl(lp->base_addr + XEL_MDIORD_OFFSET);
 
 	dev_dbg(&lp->ndev->dev,
 		"xemaclite_mdio_read(phy_id=%i, reg=%x) == %x\n",
@@ -785,13 +793,13 @@ static int xemaclite_mdio_write(struct mii_bus *bus, int phy_id, int reg,
 	 * Data register. Finally, set the Status bit in the MDIO Control
 	 * register to start a MDIO write transaction.
 	 */
-	ctrl_reg = __raw_readl(lp->base_addr + XEL_MDIOCTRL_OFFSET);
-	__raw_writel(~XEL_MDIOADDR_OP_MASK &
-		     ((phy_id << XEL_MDIOADDR_PHYADR_SHIFT) | reg),
-		     lp->base_addr + XEL_MDIOADDR_OFFSET);
-	__raw_writel(val, lp->base_addr + XEL_MDIOWR_OFFSET);
-	__raw_writel(ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK,
-		     lp->base_addr + XEL_MDIOCTRL_OFFSET);
+	ctrl_reg = xemaclite_readl(lp->base_addr + XEL_MDIOCTRL_OFFSET);
+	xemaclite_writel(~XEL_MDIOADDR_OP_MASK &
+			 ((phy_id << XEL_MDIOADDR_PHYADR_SHIFT) | reg),
+			 lp->base_addr + XEL_MDIOADDR_OFFSET);
+	xemaclite_writel(val, lp->base_addr + XEL_MDIOWR_OFFSET);
+	xemaclite_writel(ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK,
+			 lp->base_addr + XEL_MDIOCTRL_OFFSET);
 
 	return 0;
 }
@@ -838,8 +846,8 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
 	/* Enable the MDIO bus by asserting the enable bit in MDIO Control
 	 * register.
 	 */
-	__raw_writel(XEL_MDIOCTRL_MDIOEN_MASK,
-		     lp->base_addr + XEL_MDIOCTRL_OFFSET);
+	xemaclite_writel(XEL_MDIOCTRL_MDIOEN_MASK,
+			 lp->base_addr + XEL_MDIOCTRL_OFFSET);
 
 	bus = mdiobus_alloc();
 	if (!bus) {
@@ -1130,8 +1138,8 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
 	}
 
 	/* Clear the Tx CSR's in case this is a restart */
-	__raw_writel(0, lp->base_addr + XEL_TSR_OFFSET);
-	__raw_writel(0, lp->base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET);
+	xemaclite_writel(0, lp->base_addr + XEL_TSR_OFFSET);
+	xemaclite_writel(0, lp->base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET);
 
 	/* Set the MAC address in the EmacLite device */
 	xemaclite_update_address(lp, ndev->dev_addr);
-- 
2.8.3
