From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net v5 2/5] forcedeth: Acknowledge only interrupts that are being processed
Date: Sat,  5 Nov 2011 17:38:21 -0700
Message-ID: <15bc4a8d132782a42602cac8e77e8c10b6b450f9.1320539724.git.david.decotigny@google.com>
References: <cover.1320539724.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Mike Ditto <mditto@google.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1320539724.git.david.decotigny@google.com>
In-Reply-To: <cover.1320539724.git.david.decotigny@google.com>
References: <cover.1320539724.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Ditto <mditto@google.com>

This is to avoid a race, accidentally acknowledging an interrupt that
we didn't notice and won't immediately process.  This is based solely
on code inspection; it is not known if there was an actual bug here.



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 344cb5f..b7cf4b6 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3398,7 +3398,8 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 
 	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_TX_ALL;
-		writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
+		writel(events, base + NvRegMSIXIrqStatus);
+		netdev_dbg(dev, "tx irq events: %08x\n", events);
 		if (!(events & np->irqmask))
 			break;
 
@@ -3509,7 +3510,8 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 
 	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_RX_ALL;
-		writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
+		writel(events, base + NvRegMSIXIrqStatus);
+		netdev_dbg(dev, "rx irq events: %08x\n", events);
 		if (!(events & np->irqmask))
 			break;
 
@@ -3553,7 +3555,8 @@ static irqreturn_t nv_nic_irq_other(int foo, void *data)
 
 	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_OTHER;
-		writel(NVREG_IRQ_OTHER, base + NvRegMSIXIrqStatus);
+		writel(events, base + NvRegMSIXIrqStatus);
+		netdev_dbg(dev, "irq events: %08x\n", events);
 		if (!(events & np->irqmask))
 			break;
 
@@ -3617,10 +3620,10 @@ static irqreturn_t nv_nic_irq_test(int foo, void *data)
 
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
