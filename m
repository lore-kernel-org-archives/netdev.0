From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 hard-freezes the system on big network loads
Date: Tue, 13 Sep 2011 10:11:26 +0200
Message-ID: <20110913081126.GA20022@electric-eye.fr.zoreil.com>
References: <201108141308.28140.kjun-chen@sambodha.org> <20110821221140.GA20696@electric-eye.fr.zoreil.com> <20110823131726.GA21092@electric-eye.fr.zoreil.com> <201109112216.33579.brade@informatik.uni-muenchen.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="jI8keyz6grp/JLjh"
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Hayes <hayeswang@realtek.com>
To: Michael Brade <brade@informatik.uni-muenchen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52087 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753914Ab1IMILr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 04:11:47 -0400
Content-Disposition: inline
In-Reply-To: <201109112216.33579.brade@informatik.uni-muenchen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Michael Brade <brade@informatik.uni-muenchen.de> :
[...]
> Does it have to be 3.1.0-rc3 or is 3.0.1 ok as well ?

:o(

Almost any release may exhibit the bug. The attached patch (#0003)
should be a better candidate as an official fix though.

> If so, I have another bad news: 3.0.1 still crashes with this patch.
> It took me a lot longer to crash it but eventually it did happen.
> Not sure why it took longer, I guess I didn't generate enough throughput.

It sure sucks from a user experience viewpoint but it is not _that_ bad.

Are the symptoms in any way different or do you still notice more-or-less
periodic link-up messages and no real network traffic ?

> If you want me to use 3.1.0 then we'll have to wait until git.kernel.org is 
> back...

https://github.com/torvalds/linux.git is available in the meantime.

You will want the patch below as well if you try 3.1-rc6.

[PATCH] r8169: don't reset software ring indexes after disabling hardware Rx.

Bad things happen when the driver resets ring indexes after disabling
hardware Rx (and Tx) in the RxFIFOOver event recovery path of the irq
handler while it races with the NAPI Rx processing method.

Ring indexes init is now done before enabling hardware Rx / Tx.

NB: this is not a straight candidate for -stable since it is coupled
with commit 92fc43b4159b518f5baae57301f26d770b0834c9 (July 11).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 05566b1..22b9c7a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -717,7 +717,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev);
 static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance);
 static int rtl8169_init_ring(struct net_device *dev);
-static void rtl_hw_start(struct net_device *dev);
+static void rtl_start(struct net_device *dev);
 static int rtl8169_close(struct net_device *dev);
 static void rtl_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
@@ -3589,8 +3589,6 @@ static void rtl_hw_reset(struct rtl8169_private *tp)
 			break;
 		udelay(100);
 	}
-
-	rtl8169_init_ring_indexes(tp);
 }
 
 static int __devinit
@@ -3948,7 +3946,7 @@ static int rtl8169_open(struct net_device *dev)
 
 	rtl_pll_power_up(tp);
 
-	rtl_hw_start(dev);
+	rtl_start(dev);
 
 	tp->saved_wolopts = 0;
 	pm_runtime_put_noidle(&pdev->dev);
@@ -4014,10 +4012,14 @@ static void rtl_set_rx_tx_config_registers(struct rtl8169_private *tp)
 		(InterFrameGap << TxInterFrameGapShift));
 }
 
-static void rtl_hw_start(struct net_device *dev)
+static void rtl_start(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
+	rtl8169_init_ring_indexes(tp);
+
+	smp_mb();
+
 	tp->hw_start(dev);
 
 	netif_start_queue(dev);
@@ -4997,7 +4999,7 @@ static void rtl8169_reset_task(struct work_struct *work)
 	rtl8169_tx_clear(tp);
 
 	rtl8169_hw_reset(tp);
-	rtl_hw_start(dev);
+	rtl_start(dev);
 	netif_wake_queue(dev);
 	rtl8169_check_link_status(dev, tp, tp->mmio_addr);
 
-- 
1.7.6


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0003-r8169-remove-erroneous-processing-of-always-set-bit.patch"

>From 44071c614418d9cae2faab8307307578d104065b Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 25 Aug 2011 18:47:24 +0200
Subject: [PATCH 3/3] r8169: remove erroneous processing of always set bit.

When set, RxFOVF (resp. RxBOVF) is always 1 (resp. 0).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes <hayeswang@realtek.com>
---
 drivers/net/r8169.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 22b9c7a..19b91a8 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -407,6 +407,7 @@ enum rtl_register_content {
 	RxOK		= 0x0001,
 
 	/* RxStatusDesc */
+	RxBOVF	= (1 << 24),
 	RxFOVF	= (1 << 23),
 	RxRWT	= (1 << 22),
 	RxRES	= (1 << 21),
@@ -682,6 +683,7 @@ struct rtl8169_private {
 	struct mii_if_info mii;
 	struct rtl8169_counters counters;
 	u32 saved_wolopts;
+	u32 opts1_mask;
 
 	struct rtl_fw {
 		const struct firmware *fw;
@@ -3782,6 +3784,9 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->intr_event = cfg->intr_event;
 	tp->napi_event = cfg->napi_event;
 
+	tp->opts1_mask = (tp->mac_version != RTL_GIGA_MAC_VER_01) ?
+		~(RxBOVF | RxFOVF) : ~0;
+
 	init_timer(&tp->timer);
 	tp->timer.data = (unsigned long) dev;
 	tp->timer.function = rtl8169_phy_timer;
@@ -5323,7 +5328,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 		u32 status;
 
 		rmb();
-		status = le32_to_cpu(desc->opts1);
+		status = le32_to_cpu(desc->opts1) & tp->opts1_mask;
 
 		if (status & DescOwn)
 			break;
-- 
1.7.6


--jI8keyz6grp/JLjh--
