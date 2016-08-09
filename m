From: Sylwester Nawrocki <s.nawrocki@samsung.com>
Subject: [PATCH] dm9000: Fix irq trigger type setup on non-dt platforms
Date: Tue, 09 Aug 2016 18:00:08 +0200
Message-ID: <1470758408-14248-1-git-send-email-s.nawrocki@samsung.com>
Cc: netdev@vger.kernel.org, robert.jarzmik@free.fr,
	linus.walleij@linaro.org, tglx@linutronix.de,
	b.zolnierkie@samsung.com, linux-kernel@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org,
	Sylwester Nawrocki <s.nawrocki@samsung.com>
To: davem@davemloft.net
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit b5a099c67a1c36b "net: ethernet: davicom: fix devicetree irq
resource" causes an interrupt storm after the ethernet interface
is activated on S3C24XX platform (ARM non-dt), due to the interrupt
trigger type not being set properly.

It seems, after adding parsing of IRQ flags in commit 7085a7401ba54e92b
"drivers: platform: parse IRQ flags from resources", there is no path
for non-dt platforms where irq_set_type callback could be invoked when
we don't pass the trigger type flags to the request_irq() call.

In case of a board where the regression is seen the interrupt trigger
type flags are passed through a platform device's resource and it is
not currently handled properly without passing the irq trigger type
flags to the request_irq() call.  In case of OF an of_irq_get() call
within platform_get_irq() function seems to be ensuring required irq_chip
setup, but there is no equivalent code for non OF/ACPI platforms.

This patch mostly restores irq trigger type setting code which has been
removed in commit ("net: ethernet: davicom: fix devicetree irq resource").

Fixes: b5a099c67a1c36b913 ("net: ethernet: davicom: fix devicetree irq resource")

Signed-off-by: Sylwester Nawrocki <s.nawrocki@samsung.com>
---

Perhaps instead the core could be configuring the irqchip automatically as it
is done for OF/ACPI cases. I had doubts though if trying to make such changes
for a bug fix patch was the right thing to do.
---
 drivers/net/ethernet/davicom/dm9000.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 1471e16..f45385f 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1299,6 +1299,7 @@ static int
 dm9000_open(struct net_device *dev)
 {
 	struct board_info *db = netdev_priv(dev);
+	unsigned int irq_flags = irq_get_trigger_type(dev->irq);
 
 	if (netif_msg_ifup(db))
 		dev_dbg(db->dev, "enabling %s\n", dev->name);
@@ -1306,9 +1307,11 @@ dm9000_open(struct net_device *dev)
 	/* If there is no IRQ type specified, tell the user that this is a
 	 * problem
 	 */
-	if (irq_get_trigger_type(dev->irq) == IRQF_TRIGGER_NONE)
+	if (irq_flags == IRQF_TRIGGER_NONE)
 		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
 
+	irq_flags |= IRQF_SHARED;
+
 	/* GPIO0 on pre-activate PHY, Reg 1F is not set by reset */
 	iow(db, DM9000_GPR, 0);	/* REG_1F bit0 activate phyxcer */
 	mdelay(1); /* delay needs by DM9000B */
@@ -1316,8 +1319,7 @@ dm9000_open(struct net_device *dev)
 	/* Initialize DM9000 board */
 	dm9000_init_dm9000(dev);
 
-	if (request_irq(dev->irq, dm9000_interrupt, IRQF_SHARED,
-			dev->name, dev))
+	if (request_irq(dev->irq, dm9000_interrupt, irq_flags, dev->name, dev))
 		return -EAGAIN;
 	/* Now that we have an interrupt handler hooked up we can unmask
 	 * our interrupts
-- 
1.9.1
