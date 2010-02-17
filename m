From: Riccardo Ghetta <birrachiara@tin.it>
Subject: [PATCH] SiS190/191 half-duplex initialization fix
Date: Wed, 17 Feb 2010 20:28:58 +0100
Message-ID: <1266434938-11199-1-git-send-email-birrachiara@tin.it>
Cc: netdev@vger.kernel.org, Riccardo Ghetta <birrachiara@tin.it>
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsmtp21.tin.it ([212.216.176.109]:38733 "EHLO vsmtp21.tin.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754417Ab0BQTem (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 14:34:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds half-duplex specific setup code (taken from SiS own GPL driver).
Without those, half-duplex connections are very unreliable, often
working on small transfers and failing after a while.

Signed-off-by: Riccardo Ghetta <birrachiara@tin.it>
---
 drivers/net/sis190.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 8c4e38f..bf2ffbb 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -47,7 +47,7 @@
 #define PHY_ID_ANY		0x1f
 #define MII_REG_ANY		0x1f
 
-#define DRV_VERSION		"1.3"
+#define DRV_VERSION		"1.4"
 #define DRV_NAME		"sis190"
 #define SIS190_DRIVER_NAME	DRV_NAME " Gigabit Ethernet driver " DRV_VERSION
 #define PFX DRV_NAME ": "
@@ -294,6 +294,7 @@ struct sis190_private {
 	struct mii_if_info mii_if;
 	struct list_head first_phy;
 	u32 features;
+	u32 negotiated_lpa;
 };
 
 struct sis190_phy {
@@ -1004,6 +1005,8 @@ static void sis190_phy_task(struct work_struct *work)
 			SIS_W32(RGDelay, 0x0440);
 		}
 
+		tp->negotiated_lpa = p->val;
+
 		net_link(tp, KERN_INFO "%s: link on %s mode.\n", dev->name,
 			 p->msg);
 		netif_carrier_on(dev);
@@ -1211,6 +1214,12 @@ static netdev_tx_t sis190_start_xmit(struct sk_buff *skb,
 	wmb();
 
 	desc->status = cpu_to_le32(OWNbit | INTbit | DEFbit | CRCbit | PADbit);
+	if (tp->negotiated_lpa & (LPA_1000HALF | LPA_100HALF | LPA_10HALF)) {
+		/* Half Duplex */
+		desc->status |= cpu_to_le32(COLEN | CRSEN | BKFEN);
+		if (tp->negotiated_lpa & (LPA_1000HALF | LPA_1000FULL))
+			desc->status |= cpu_to_le32(EXTEN | BSTEN); /* gigabit HD */
+	}
 
 	tp->cur_tx++;
 
-- 
1.6.4.4

