From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3]: Fix 2nd ifup failure on 5752M.
Date: Thu, 02 Nov 2006 13:02:29 -0800
Message-ID: <1162501349.3700.3.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:34827 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1752487AbWKBUI0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 15:08:26 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Fix 2nd ifup failure on 5752M.

This fixes a bug reported in:

http://bugzilla.kernel.org/show_bug.cgi?id=7438

tg3_close() turns off the PHY if WoL and ASF are both disabled.  On
the next tg3_open(), some devices such as the 5752M will not be
brought up correctly without a PHY reset early in the reset sequence.
The PHY clock is needed for some internal MAC blocks to function
correctly.

This problem is fixed by always resetting the PHY early in
tg3_reset_hw() when it is called from tg3_open() or tg3_resume().
tg3_setup_phy() can then be called later in the sequence without the
reset_phy parameter set to 1, since the PHY reset is already done.

Update version to 3.68.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8e39849..8f059b7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -68,8 +68,8 @@ #include "tg3.h"
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.67"
-#define DRV_MODULE_RELDATE	"October 18, 2006"
+#define DRV_MODULE_VERSION	"3.68"
+#define DRV_MODULE_RELDATE	"November 02, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -6014,7 +6014,7 @@ static int tg3_reset_hw(struct tg3 *tp, 
 		tg3_abort_hw(tp, 1);
 	}
 
-	if ((tp->tg3_flags2 & TG3_FLG2_MII_SERDES) && reset_phy)
+	if (reset_phy)
 		tg3_phy_reset(tp);
 
 	err = tg3_chip_reset(tp);
@@ -6574,7 +6574,7 @@ #endif
 		tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl);
 	}
 
-	err = tg3_setup_phy(tp, reset_phy);
+	err = tg3_setup_phy(tp, 0);
 	if (err)
 		return err;
 


