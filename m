From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3]: Fix link problem on Dell's onboard 5906.
Date: Thu, 31 May 2007 15:03:39 -0700
Message-ID: <1180649019.20882.3.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3607 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753289AbXEaVOM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 17:14:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Fix link problem on Dell's onboard 5906.

The bug is caused by code that always set
(TG3_FLAG_USE_MI_INTERRUPT | TG3_FLAG_USE_LINKCHG_REG) on all Dell's
onboard devices.  With these 2 flags set, the link status is polled
by tg3_timer() and will only work when the PHY is set up to interrupt
the MAC on link changes.  This breaks 5906 because the 5906 PHY does
not support TG3_FLAG_USE_MI_INTERRUPT the same as other PHYs.

For correctness, only Dell's onboard 5701 needs these 2 flags to be
set.  This change will fix the 5906 problem and will change other
Dell devices except 5700 and 5701 to use the more efficient
interrupt-driven link changes.

Update version to 3.77.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 923b9c7..a16954c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.76"
-#define DRV_MODULE_RELDATE	"May 5, 2007"
+#define DRV_MODULE_VERSION	"3.77"
+#define DRV_MODULE_RELDATE	"May 31, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -10976,6 +10976,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 * upon subsystem IDs.
 	 */
 	if (tp->pdev->subsystem_vendor == PCI_VENDOR_ID_DELL &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
 	    !(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)) {
 		tp->tg3_flags |= (TG3_FLAG_USE_MI_INTERRUPT |
 				  TG3_FLAG_USE_LINKCHG_REG);


