From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 5/7] tg3: Refine VAux decision process
Date: Wed, 9 Mar 2011 18:58:23 -0800
Message-ID: <1299725905-8498-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2483 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259Ab1CJC6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 21:58:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the near future, the VAux switching decision process is going to get
more complicated.  This patch refines and consolidates the existing
algorithm in anticipation of the new scheme.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   41 +++++++++++++++++++++--------------------
 1 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 73eacbd..159eb23 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2120,7 +2120,7 @@ out:
 
 static void tg3_frob_aux_power(struct tg3 *tp)
 {
-	struct tg3 *tp_peer = tp;
+	bool need_vaux = false;
 
 	/* The GPIOs do something completely different on 57765. */
 	if ((tp->tg3_flags2 & TG3_FLG2_IS_NIC) == 0 ||
@@ -2128,23 +2128,32 @@ static void tg3_frob_aux_power(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 		return;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
+	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714 ||
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) &&
+	    tp->pdev_peer != tp->pdev) {
 		struct net_device *dev_peer;
 
 		dev_peer = pci_get_drvdata(tp->pdev_peer);
+
 		/* remove_one() may have been run on the peer. */
-		if (!dev_peer)
-			tp_peer = tp;
-		else
-			tp_peer = netdev_priv(dev_peer);
+		if (dev_peer) {
+			struct tg3 *tp_peer = netdev_priv(dev_peer);
+
+			if (tp_peer->tg3_flags & TG3_FLAG_INIT_COMPLETE)
+				return;
+
+			if ((tp_peer->tg3_flags & TG3_FLAG_WOL_ENABLE) ||
+			    (tp_peer->tg3_flags & TG3_FLAG_ENABLE_ASF))
+				need_vaux = true;
+		}
 	}
 
-	if ((tp->tg3_flags & TG3_FLAG_WOL_ENABLE) != 0 ||
-	    (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) != 0 ||
-	    (tp_peer->tg3_flags & TG3_FLAG_WOL_ENABLE) != 0 ||
-	    (tp_peer->tg3_flags & TG3_FLAG_ENABLE_ASF) != 0) {
+	if ((tp->tg3_flags & TG3_FLAG_WOL_ENABLE) ||
+	    (tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
+		need_vaux = true;
+
+	if (need_vaux) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701) {
 			tw32_wait_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl |
@@ -2174,10 +2183,6 @@ static void tg3_frob_aux_power(struct tg3 *tp)
 			u32 no_gpio2;
 			u32 grc_local_ctrl = 0;
 
-			if (tp_peer != tp &&
-			    (tp_peer->tg3_flags & TG3_FLAG_INIT_COMPLETE) != 0)
-				return;
-
 			/* Workaround to prevent overdrawing Amps. */
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) ==
 			    ASIC_REV_5714) {
@@ -2216,10 +2221,6 @@ static void tg3_frob_aux_power(struct tg3 *tp)
 	} else {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700 &&
 		    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701) {
-			if (tp_peer != tp &&
-			    (tp_peer->tg3_flags & TG3_FLAG_INIT_COMPLETE) != 0)
-				return;
-
 			tw32_wait_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl |
 				    (GRC_LCLCTRL_GPIO_OE1 |
 				     GRC_LCLCTRL_GPIO_OUTPUT1), 100);
-- 
1.7.3.4


