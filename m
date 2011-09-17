From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/5] r8169: remove erroneous processing of always set bit.
Date: Sat, 17 Sep 2011 11:58:40 +0200
Message-ID: <20110917095840.GE21630@electric-eye.fr.zoreil.com>
References: <20110917095617.GA21630@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54300 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289Ab1IQJ7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 05:59:17 -0400
Content-Disposition: inline
In-Reply-To: <20110917095617.GA21630@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When set, RxFOVF (resp. RxBOVF) is always 1 (resp. 0).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes <hayeswang@realtek.com>
---
 drivers/net/r8169.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 78c1d58..dff0bf0 100644
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
@@ -3786,6 +3788,9 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->intr_event = cfg->intr_event;
 	tp->napi_event = cfg->napi_event;
 
+	tp->opts1_mask = (tp->mac_version != RTL_GIGA_MAC_VER_01) ?
+		~(RxBOVF | RxFOVF) : ~0;
+
 	init_timer(&tp->timer);
 	tp->timer.data = (unsigned long) dev;
 	tp->timer.function = rtl8169_phy_timer;
@@ -5324,7 +5329,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 		u32 status;
 
 		rmb();
-		status = le32_to_cpu(desc->opts1);
+		status = le32_to_cpu(desc->opts1) & tp->opts1_mask;
 
 		if (status & DescOwn)
 			break;
-- 
1.7.6
