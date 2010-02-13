From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 8/9] tg3: Fix AC131 loopback test errors for 5785
Date: Fri, 12 Feb 2010 16:47:12 -0800
Message-ID: <1266022033-3546-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2540 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756622Ab0BMArd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 19:47:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The AC131 does not enable the forced transmit clock settings
immediately.  The workaround is to read the register again to get the
setting to take effect.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    8 ++++++--
 drivers/net/tg3.h |    3 +++
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 74fa6d5..5b03231 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10822,8 +10822,12 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 
 		mac_mode = tp->mac_mode & ~MAC_MODE_PORT_MODE_MASK;
 		if (tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET) {
-			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
-				tg3_writephy(tp, MII_TG3_FET_PTEST, 0x1800);
+			tg3_writephy(tp, MII_TG3_FET_PTEST,
+				     MII_TG3_FET_PTEST_FRC_TX_LINK |
+				     MII_TG3_FET_PTEST_FRC_TX_LOCK);
+			/* The write needs to be flushed for the AC131 */
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+				tg3_readphy(tp, MII_TG3_FET_PTEST, &val);
 			mac_mode |= MAC_MODE_PORT_MODE_MII;
 		} else
 			mac_mode |= MAC_MODE_PORT_MODE_GMII;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index a8fb53a..b4fd596 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2112,6 +2112,9 @@
 
 /* Fast Ethernet Tranceiver definitions */
 #define MII_TG3_FET_PTEST		0x17
+#define  MII_TG3_FET_PTEST_FRC_TX_LINK	0x1000
+#define  MII_TG3_FET_PTEST_FRC_TX_LOCK	0x0800
+
 #define MII_TG3_FET_TEST		0x1f
 #define  MII_TG3_FET_SHADOW_EN		0x0080
 
-- 
1.6.4.4


