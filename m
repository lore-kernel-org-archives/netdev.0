From: Vlastimil Setka <setka@vsis.cz>
Subject: Re: Altera TSE (altera_tse): fix NAPI polling (was: net_rx_action
 WARNING)
Date: Tue, 17 Feb 2015 01:02:53 +0100
Message-ID: <54E2852D.2080702@vsis.cz>
References: <54C63585.1010908@vsis.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
To: vbridger@opensource.altera.com, netdev@vger.kernel.org,
	rfi <rfi@lists.rocketboards.org>, rpisl@kky.zcu.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.spsostrov.cz ([217.117.209.230]:57119 "EHLO
	mail.spsostrov.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbbBQADB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 19:03:01 -0500
In-Reply-To: <54C63585.1010908@vsis.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Here is a patch which fixes incorrect NAPI polling in altera_tse driver.
It caused warnings I reported here some time before (attached below).

I extensively tested this patch and it also solved stability issues
I had with the driver under high load at socfpga platform.

I am not so familiar with NAPI infrastructure, so I got inspiration
in other drivers using NAPI. Comments are welcome.

Subject: [PATCH 1/1] Altera TSE: fix NAPI polling

Incorrect NAPI polling caused WARNING at net/core/dev.c net_rx_action.
Some stability issues were also seen at high throughput and system load
before this patch.

This patch contains several changes in altera_tse_main.c:

- tse_rx() is fixed to not process more than `limit` frames

- tse_poll() is refactored to match NAPI logic
  - only received frames are counted for return value
  - removed bogus condition `(rxcomplete >= budget || txcomplete > 0)`
  - replace by: if (rxcomplete < budget) -> call __napi_complete and enable irq

- altera_isr()
  - replace spin_lock_irqsave() by spin_lock() - we are in isr
  - use spinlocks just over irq manipulation, not over __napi_schedule
  - reset IRQ first, then disable and schedule napi

Signed-off-by: Vlastimil Setka <setka@vsis.cz>
Signed-off-by: Roman Pisl <rpisl@kky.zcu.cz>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 50 ++++++++++++++-------------
 1 file changed, 26 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index f3d784a..088a43f 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -376,7 +376,8 @@ static int tse_rx(struct altera_tse_private *priv, int limit)
 	u16 pktlength;
 	u16 pktstatus;
 
-	while ((rxstatus = priv->dmaops->get_rx_status(priv)) != 0) {
+	while (((rxstatus = priv->dmaops->get_rx_status(priv)) != 0) &&
+	       (count < limit)) {
 		pktstatus = rxstatus >> 16;
 		pktlength = rxstatus & 0xffff;
 
@@ -491,28 +492,29 @@ static int tse_poll(struct napi_struct *napi, int budget)
 	struct altera_tse_private *priv =
 			container_of(napi, struct altera_tse_private, napi);
 	int rxcomplete = 0;
-	int txcomplete = 0;
 	unsigned long int flags;
 
-	txcomplete = tse_tx_complete(priv);
+	tse_tx_complete(priv);
 
 	rxcomplete = tse_rx(priv, budget);
 
-	if (rxcomplete >= budget || txcomplete > 0)
-		return rxcomplete;
+	/* if we did not reach work limit, then we're done with polling */
+	if (rxcomplete < budget) {
 
-	napi_gro_flush(napi, false);
-	__napi_complete(napi);
+		napi_gro_flush(napi, false);
+		__napi_complete(napi);
 
-	netdev_dbg(priv->dev,
-		   "NAPI Complete, did %d packets with budget %d\n",
-		   txcomplete+rxcomplete, budget);
+		netdev_dbg(priv->dev,
+			   "NAPI Complete, did %d packets with budget %d\n",
+			   rxcomplete, budget);
 
-	spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
-	priv->dmaops->enable_rxirq(priv);
-	priv->dmaops->enable_txirq(priv);
-	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
-	return rxcomplete + txcomplete;
+		spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
+		priv->dmaops->enable_rxirq(priv);
+		priv->dmaops->enable_txirq(priv);
+		spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
+	}
+
+	return rxcomplete;
 }
 
 /* DMA TX & RX FIFO interrupt routing
@@ -521,7 +523,6 @@ static irqreturn_t altera_isr(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct altera_tse_private *priv;
-	unsigned long int flags;
 
 	if (unlikely(!dev)) {
 		pr_err("%s: invalid dev pointer\n", __func__);
@@ -529,21 +530,22 @@ static irqreturn_t altera_isr(int irq, void *dev_id)
 	}
 	priv = netdev_priv(dev);
 
-	/* turn off desc irqs and enable napi rx */
-	spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
+	/* reset IRQs */
+	spin_lock(&priv->rxdma_irq_lock);
+	priv->dmaops->clear_rxirq(priv);
+	priv->dmaops->clear_txirq(priv);
+	spin_unlock(&priv->rxdma_irq_lock);
 
 	if (likely(napi_schedule_prep(&priv->napi))) {
+		/* turn off desc irqs and enable napi rx */
+		spin_lock(&priv->rxdma_irq_lock);
 		priv->dmaops->disable_rxirq(priv);
 		priv->dmaops->disable_txirq(priv);
+		spin_unlock(&priv->rxdma_irq_lock);
+
 		__napi_schedule(&priv->napi);
 	}
 
-	/* reset IRQs */
-	priv->dmaops->clear_rxirq(priv);
-	priv->dmaops->clear_txirq(priv);
-
-	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
-
 	return IRQ_HANDLED;
 }
 
-- 
1.8.1.2

26.1.2015 13:39 Vlastimil Setka:

> Hello,
> I am using Altera TSE kernel driver (altera_tse module) on Altera 
> socfpga platform (Cyclone V SoC with ARM Cortex-A9) and I probably 
> discovered a bug in it. I have two TSE controllers instantiated in FPGA 
> - my FPGA HW design is based on this tutorial: 
> http://www.rocketboards.org/foswiki/Projects/AlteraSoCTripleSpeedEthernetDesignExample
> The kernel version is 3.10.37-ltsi with RT patch, from 
> http://rocketboards.org/gitweb/?p=linux-socfpga.git;a=commit;h=7ea94617cfae6a62ee963adc1ae340196dbe2b34
> with backported some altera_tse fixes from current 3.19-rc5.
> I was not able to get TSE ethernets working on vanilla 3.19-rc5, 
> probably because of some changes around interrupts and devicetree, but 
> it's another story.
> After some time (minutes to hours) of exhaustive traffic generated by 
> iperf through altera_tse ethernet, I can see a kernel warning on console 
> like this:
> ------------[ cut here ]------------
> WARNING: at net/core/dev.c:4255 net_rx_action+0x268/0x28c()
> Modules linked in: gpio_altera altera_sysid altera_tse
> CPU: 0 PID: 5885 Comm: irq/75-eth2 Not tainted 
> 3.10.37-ltsi-rt37-vs-2-1-00062-g861955e #1
> [<800166c4>] (unwind_backtrace+0x0/0x100) from [<80012edc>] 
> (show_stack+0x20/0x24)
> [<80012edc>] (show_stack+0x20/0x24) from [<80503404>] (dump_stack+0x24/0x28)
> [<80503404>] (dump_stack+0x24/0x28) from [<8002303c>] 
> (warn_slowpath_common+0x64/0x7c)
> [<8002303c>] (warn_slowpath_common+0x64/0x7c) from [<80023110>] 
> (warn_slowpath_null+0x2c/0x34)
> [<80023110>] (warn_slowpath_null+0x2c/0x34) from [<80404d48>] 
> (net_rx_action+0x268/0x28c)
> [<80404d48>] (net_rx_action+0x268/0x28c) from [<8002bd18>] 
> (do_current_softirqs+0x1e4/0x388)
> [<8002bd18>] (do_current_softirqs+0x1e4/0x388) from [<8002bf34>] 
> (local_bh_enable+0x78/0x90)
> [<8002bf34>] (local_bh_enable+0x78/0x90) from [<80086c9c>] 
> (irq_forced_thread_fn+0x50/0x74)
> [<80086c9c>] (irq_forced_thread_fn+0x50/0x74) from [<80086fbc>] 
> (irq_thread+0x16c/0x1c8)
> [<80086fbc>] (irq_thread+0x16c/0x1c8) from [<80048104>] (kthread+0xb4/0xb8)
> [<80048104>] (kthread+0xb4/0xb8) from [<8000e718>] (ret_from_fork+0x14/0x20)
> ---[ end trace 0000000000000002 ]---
> The warning point is:
>     WARN_ON_ONCE(work > weight);
> at 
> http://rocketboards.org/gitweb/?p=linux-socfpga.git;a=blob;f=net/core/dev.c;h=2193b5dc276ad6aa54adb1ee15ef3de625915fcd;hb=7ea94617cfae6a62ee963adc1ae340196dbe2b34#l4255
> After a warning, interface is still working without problems.
> I am not much familiar with Linux network stack and device drivers. But 
> I probably found a root cause in:
>    # drivers/net/ethernet/altera/altera_tse_main.c.
>    # 
> http://rocketboards.org/gitweb/?p=linux-socfpga.git;a=blob;f=drivers/net/ethernet/altera/altera_tse_main.c;h=07c0b193c55722d18ff2723f0a7e137671746ba1;hb=7ea94617cfae6a62ee963adc1ae340196dbe2b34#l368
>    static int tse_rx(struct altera_tse_private *priv, int limit)
> the `limit` parameter is not used anywhere in the function! When 
> `tse_rx` is called from `tse_poll` it can return more frames than limit, 
> which in the end triggers the kernel warning as I think:
>   # drivers/net/ethernet/altera/altera_tse_main.c
>   # 
> http://rocketboards.org/gitweb/?p=linux-socfpga.git;a=blob;f=drivers/net/ethernet/altera/altera_tse_main.c;h=07c0b193c55722d18ff2723f0a7e137671746ba1;hb=7ea94617cfae6a62ee963adc1ae340196dbe2b34#l488
>   static int tse_poll(struct napi_struct *napi, int budget)
>   {
>            ...
>            txcomplete = tse_tx_complete(priv);
>            rxcomplete = tse_rx(priv, budget);
>            if (rxcomplete >= budget || txcomplete > 0)
>                    return rxcomplete;
> Condition `if (rxcomplete >= budget || txcomplete > 0) return 
> rxcomplete;` is also very weird for me. I am not sure if it's buggy, but 
> I think it should be at least commented how it works.
> Vlastimil Setka
