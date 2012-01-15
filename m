From: Wolfgang Zarre <lkdev@essax.com>
Subject: [PATCH wg-linux-can-next devel 1/1] can: cc770: Fix indirect access deadlock on ISA cards
Date: Sun, 15 Jan 2012 13:21:34 +0100
Message-ID: <1326630094-3126-1-git-send-email-lkdev@essax.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	socketcan-users@lists.berlios.de, Wolfgang Zarre <lkdev@essax.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fix avoids a deadlock if an interrupt occurs
during consecutive port operations on ISA cards
utilising indirect access via address and data
port.

Tested on a B&R ISA card.

CC: linux-can@vger.kernel.org
CC: netdev@vger.kernel.org
Signed-off-by: Wolfgang Zarre <lkdev@essax.com>
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
1.7.7.3

