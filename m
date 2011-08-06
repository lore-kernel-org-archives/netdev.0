From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: [RFC 4/5] [flexcan] Add support for FLEXCAN_DEBUG
Date: Sat,  6 Aug 2011 09:34:29 -0500
Message-ID: <1312641270-6018-5-git-send-email-holt@sgi.com>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1312641270-6018-1-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a wrapper function for a register dump when a developer defines
FLEXCAN_DEBUG.

Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/net/can/flexcan.c |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index d4ac81b..c2fb829 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -215,6 +215,35 @@ static inline void flexcan_write(u32 val, void __iomem *addr)
 }
 #endif
 
+#if defined(FLEXCAN_DEBUG)
+void _flexcan_reg_dump(struct net_device *dev, const char *file, int line,
+		       const char *func)
+{
+	const struct flexcan_priv *priv = netdev_priv(dev);
+	struct flexcan_regs __iomem *regs = priv->base;
+
+	netdev_info("flexcan_reg_dump:%s:%d:%s()\n", file, line, func);
+	netdev_info("\t  mcr 0x%08x  ctrl 0x%08x timer 0x%08x   rxg 0x%08x",
+		flexcan_read(&regs->mcr),
+		flexcan_read(&regs->ctrl),
+		flexcan_read(&regs->timer),
+		flexcan_read(&regs->rxgmask));
+	netdev_info("\t rx14 0x%08x  rx15 0x%08x   ecr 0x%08x   esr 0x%08x",
+		flexcan_read(&regs->rx14mask),
+		flexcan_read(&regs->rx15mask),
+		flexcan_read(&regs->ecr),
+		flexcan_read(&regs->esr));
+	netdev_info("\timsk2 0x%08x imsk1 0x%08x iflg2 0x%08x iflg1 0x%08x",
+		flexcan_read(&regs->imask2),
+		flexcan_read(&regs->imask1),
+		flexcan_read(&regs->iflag2),
+		flexcan_read(&regs->iflag1));
+}
+#define flexcan_reg_dump(_d) _flexcan_reg_dump(_d, __FILE__, __LINE__, __func__)
+#else
+#define flexcan_reg_dump(_d)
+#endif
+
 /*
  * Swtich transceiver on or off
  */
@@ -275,6 +304,8 @@ static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 can_id;
 	u32 ctrl = FLEXCAN_MB_CNT_CODE(0xc) | (cf->can_dlc << 16);
 
+	flexcan_reg_dump(dev);
+
 	if (can_dropped_invalid_skb(dev, skb))
 		return NETDEV_TX_OK;
 
@@ -307,6 +338,8 @@ static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* tx_packets is incremented in flexcan_irq */
 	stats->tx_bytes += cf->can_dlc;
 
+	flexcan_reg_dump(dev);
+
 	return NETDEV_TX_OK;
 }
 
@@ -575,6 +608,8 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 	struct flexcan_regs __iomem *regs = priv->base;
 	u32 reg_iflag1, reg_esr;
 
+	flexcan_reg_dump(dev);
+
 	reg_iflag1 = flexcan_read(&regs->iflag1);
 	reg_esr = flexcan_read(&regs->esr);
 	flexcan_write(FLEXCAN_ESR_ERR_INT, &regs->esr);	/* ACK err IRQ */
@@ -615,6 +650,8 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 		netif_wake_queue(dev);
 	}
 
+	flexcan_reg_dump(dev);
+
 	return IRQ_HANDLED;
 }
 
-- 
1.7.2.1
