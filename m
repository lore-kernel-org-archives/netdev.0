From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 02/12] can: cc770: Fix indirect access deadlock on ISA cards
Date: Tue, 31 Jan 2012 22:46:40 +0100
Message-ID: <1328046410-21392-3-git-send-email-mkl@pengutronix.de>
References: <1328046410-21392-1-git-send-email-mkl@pengutronix.de>
Cc: Wolfgang Zarre <lkdev@essax.com>, netdev@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1328046410-21392-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfgang Zarre <lkdev@essax.com>

This fix avoids a deadlock if an interrupt occurs
during consecutive port operations on ISA cards
utilising indirect access via address and data
port.

Tested on a B&R ISA card.

CC: linux-can@vger.kernel.org
CC: netdev@vger.kernel.org
Signed-off-by: Wolfgang Zarre <lkdev@essax.com>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/cc770/cc770_isa.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/cc770/cc770_isa.c b/drivers/net/can/cc770/cc770_isa.c
index 4be5fe2..9f3a25c 100644
--- a/drivers/net/can/cc770/cc770_isa.c
+++ b/drivers/net/can/cc770/cc770_isa.c
@@ -110,6 +110,11 @@ MODULE_PARM_DESC(bcr, "Bus configuration register (default=0x40 [CBY])");
 #define CC770_IOSIZE          0x20
 #define CC770_IOSIZE_INDIRECT 0x02
 
+/* Spinlock for cc770_isa_port_write_reg_indirect
+ * and cc770_isa_port_read_reg_indirect
+ */
+static DEFINE_SPINLOCK(cc770_isa_port_lock);
+
 static struct platform_device *cc770_isa_devs[MAXDEV];
 
 static u8 cc770_isa_mem_read_reg(const struct cc770_priv *priv, int reg)
@@ -138,18 +143,27 @@ static u8 cc770_isa_port_read_reg_indirect(const struct cc770_priv *priv,
 					     int reg)
 {
 	unsigned long base = (unsigned long)priv->reg_base;
+	unsigned long flags;
+	u8 val;
 
+	spin_lock_irqsave(&cc770_isa_port_lock, flags);
 	outb(reg, base);
-	return inb(base + 1);
+	val = inb(base + 1);
+	spin_unlock_irqrestore(&cc770_isa_port_lock, flags);
+
+	return val;
 }
 
 static void cc770_isa_port_write_reg_indirect(const struct cc770_priv *priv,
 						int reg, u8 val)
 {
 	unsigned long base = (unsigned long)priv->reg_base;
+	unsigned long flags;
 
+	spin_lock_irqsave(&cc770_isa_port_lock, flags);
 	outb(reg, base);
 	outb(val, base + 1);
+	spin_unlock_irqrestore(&cc770_isa_port_lock, flags);
 }
 
 static int __devinit cc770_isa_probe(struct platform_device *pdev)
-- 
1.7.4.1

