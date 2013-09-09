From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 10/16] c_can: add 16bit align 32bit access functions
Date: Mon,  9 Sep 2013 09:25:07 +0200
Message-ID: <1378711513-2548-11-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:38031 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847Ab3IIHn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:43:29 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FlexCard only allows 32bit access to DCAN registers, otherwise the
register value can be wraped up. Add a new helper function to access
registers 16bit aligned but 32bit access.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.c          |  1 +
 drivers/net/can/c_can/c_can.h          |  1 +
 drivers/net/can/c_can/c_can_platform.c | 38 ++++++++++++++++++++++++++++++++--
 3 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index c573399..46d741d 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -1305,6 +1305,7 @@ struct net_device *alloc_c_can_dev(void)
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_LOOPBACK |
 					CAN_CTRLMODE_LISTENONLY |
 					CAN_CTRLMODE_BERR_REPORTING;
+	spin_lock_init(&priv->lock);
 
 	return dev;
 }
diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index 9f0eda8..beea437 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -175,6 +175,7 @@ struct c_can_priv {
 	u32 __iomem *raminit_ctrlreg;
 	unsigned int instance;
 	void (*raminit) (const struct c_can_priv *priv, bool enable);
+	spinlock_t lock;
 };
 
 struct net_device *alloc_c_can_dev(void);
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 43a3e3f..c6c1eb4 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -58,6 +58,40 @@ static void c_can_plat_write_reg_aligned_to_16bit(struct c_can_priv *priv,
 	writew(val, priv->base + priv->regs[index]);
 }
 
+#define ALIGN_DOWN(p, a)	((typeof(p))round_down((unsigned long)(p), (a)))
+
+static u16 c_can_plat_read_16bit_align_32bit_access(struct c_can_priv *priv,
+						    enum reg index)
+{
+	void *addr = priv->base + priv->regs[index];
+	u32 reg;
+	reg = readl(ALIGN_DOWN(addr, 4));
+
+	return IS_ALIGNED((unsigned long)addr, 4) ?
+			reg & 0xffff :
+			reg >> 16;
+}
+
+static void c_can_plat_write_16bit_align_32bit_access(struct c_can_priv *priv,
+						      enum reg index, u16 val)
+{
+	unsigned long flags;
+	void *addr = priv->base + priv->regs[index];
+	u32 reg;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	reg = readl(ALIGN_DOWN(addr, 4));
+	if (IS_ALIGNED((unsigned long)addr, 4)) {
+		reg &= 0xffff0000;
+		reg |= val;
+	} else {
+		reg &= 0xffff;
+		reg |= val << 16;
+	}
+	writel(reg, ALIGN_DOWN(addr, 4));
+	spin_unlock_irqrestore(&priv->lock, flags);
+}
+
 static u16 c_can_plat_read_reg_aligned_to_32bit(struct c_can_priv *priv,
 						enum reg index)
 {
@@ -317,8 +351,8 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	case BOSCH_D_CAN_FLEXCARD:
 		priv->regs = reg_map_d_can;
 		priv->can.ctrlmode_supported |= CAN_CTRLMODE_3_SAMPLES;
-		priv->read_reg = c_can_plat_read_reg_aligned_to_16bit;
-		priv->write_reg = c_can_plat_write_reg_aligned_to_16bit;
+		priv->read_reg = c_can_plat_read_16bit_align_32bit_access;
+		priv->write_reg = c_can_plat_write_16bit_align_32bit_access;
 		priv->instance = pdev->id;
 
 		res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-- 
1.8.4.rc3
