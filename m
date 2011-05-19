From: David Decotigny <decot@google.com>
Subject: [PATCH 4/6] forcedeth: Acknowledge only interrupts that are being processed
Date: Wed, 18 May 2011 17:14:38 -0700
Message-ID: <1305764080-24853-4-git-send-email-decot@google.com>
References: <1305764080-24853-1-git-send-email-decot@google.com>
Cc: kernel-net-upstream@google.com, Mike Ditto <mditto@google.com>,
	David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305764080-24853-1-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Ditto <mditto@google.com>

This is to avoid a race, accidentally acknowledging an interrupt that
we didn't notice and won't immediately process.  This is based solely
on code inspection; it is not known if there was an actual bug here.


Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/forcedeth.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 7a6aa08..17e79de 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3403,7 +3403,8 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 
 	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_TX_ALL;
-		writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
+		writel(events, base + NvRegMSIXIrqStatus);
+		netdev_dbg(dev, "%s: tx irq: %08x\n", dev->name, events);
 		if (!(events & np->irqmask))
 			break;
 
@@ -3514,7 +3515,8 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 
 	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_RX_ALL;
-		writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
+		writel(events, base + NvRegMSIXIrqStatus);
+		netdev_dbg(dev, "%s: rx irq: %08x\n", dev->name, events);
 		if (!(events & np->irqmask))
 			break;
 
@@ -3558,7 +3560,8 @@ static irqreturn_t nv_nic_irq_other(int foo, void *data)
 
 	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_OTHER;
-		writel(NVREG_IRQ_OTHER, base + NvRegMSIXIrqStatus);
+		writel(events, base + NvRegMSIXIrqStatus);
+		netdev_dbg(dev, "%s: irq: %08x\n", dev->name, events);
 		if (!(events & np->irqmask))
 			break;
 
@@ -3622,10 +3625,10 @@ static irqreturn_t nv_nic_irq_test(int foo, void *data)
 
 	if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
 		events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
-		writel(NVREG_IRQ_TIMER, base + NvRegIrqStatus);
+		writel(events & NVREG_IRQ_TIMER, base + NvRegIrqStatus);
 	} else {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
-		writel(NVREG_IRQ_TIMER, base + NvRegMSIXIrqStatus);
+		writel(events & NVREG_IRQ_TIMER, base + NvRegMSIXIrqStatus);
 	}
 	pci_push(base);
 	if (!(events & NVREG_IRQ_TIMER))
-- 
1.7.3.1
