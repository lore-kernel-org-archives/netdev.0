From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 08/29] ixgbe: fix ethtool register dump
Date: Thu, 11 Sep 2008 19:56:41 -0700
Message-ID: <20080912025630.6234.25973.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:46445 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754857AbYILC4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 22:56:44 -0400
Received: by wa-out-1112.google.com with SMTP id j37so392560waf.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 19:56:43 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

1) reading some of the registers in our hardware causes them to clear,
so don't read ICR in the ethtool register dump function.
2) several register iterators were not iterating

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   23 ++++++++++-------------
 drivers/net/ixgbe/ixgbe_type.h    |   10 ++--------
 2 files changed, 12 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 8f0e3f9..64460b4 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -315,7 +315,9 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[17] = IXGBE_READ_REG(hw, IXGBE_GRC);
 
 	/* Interrupt */
-	regs_buff[18] = IXGBE_READ_REG(hw, IXGBE_EICR);
+	/* don't read EICR because it can clear interrupt causes, instead
+	 * read EICS which is a shadow but doesn't clear EICR */
+	regs_buff[18] = IXGBE_READ_REG(hw, IXGBE_EICS);
 	regs_buff[19] = IXGBE_READ_REG(hw, IXGBE_EICS);
 	regs_buff[20] = IXGBE_READ_REG(hw, IXGBE_EIMS);
 	regs_buff[21] = IXGBE_READ_REG(hw, IXGBE_EIMC);
@@ -419,7 +421,6 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[827] = IXGBE_READ_REG(hw, IXGBE_WUPM);
 	regs_buff[828] = IXGBE_READ_REG(hw, IXGBE_FHFT);
 
-	/* DCE */
 	regs_buff[829] = IXGBE_READ_REG(hw, IXGBE_RMCS);
 	regs_buff[830] = IXGBE_READ_REG(hw, IXGBE_DPMCS);
 	regs_buff[831] = IXGBE_READ_REG(hw, IXGBE_PDPMCS);
@@ -539,21 +540,17 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	/* Diagnostic */
 	regs_buff[1071] = IXGBE_READ_REG(hw, IXGBE_RDSTATCTL);
 	for (i = 0; i < 8; i++)
-		regs_buff[1072] = IXGBE_READ_REG(hw, IXGBE_RDSTAT(i));
+		regs_buff[1072 + i] = IXGBE_READ_REG(hw, IXGBE_RDSTAT(i));
 	regs_buff[1080] = IXGBE_READ_REG(hw, IXGBE_RDHMPN);
-	regs_buff[1081] = IXGBE_READ_REG(hw, IXGBE_RIC_DW0);
-	regs_buff[1082] = IXGBE_READ_REG(hw, IXGBE_RIC_DW1);
-	regs_buff[1083] = IXGBE_READ_REG(hw, IXGBE_RIC_DW2);
-	regs_buff[1084] = IXGBE_READ_REG(hw, IXGBE_RIC_DW3);
+	for (i = 0; i < 4; i++)
+		regs_buff[1081 + i] = IXGBE_READ_REG(hw, IXGBE_RIC_DW(i));
 	regs_buff[1085] = IXGBE_READ_REG(hw, IXGBE_RDPROBE);
 	regs_buff[1086] = IXGBE_READ_REG(hw, IXGBE_TDSTATCTL);
 	for (i = 0; i < 8; i++)
-		regs_buff[1087] = IXGBE_READ_REG(hw, IXGBE_TDSTAT(i));
+		regs_buff[1087 + i] = IXGBE_READ_REG(hw, IXGBE_TDSTAT(i));
 	regs_buff[1095] = IXGBE_READ_REG(hw, IXGBE_TDHMPN);
-	regs_buff[1096] = IXGBE_READ_REG(hw, IXGBE_TIC_DW0);
-	regs_buff[1097] = IXGBE_READ_REG(hw, IXGBE_TIC_DW1);
-	regs_buff[1098] = IXGBE_READ_REG(hw, IXGBE_TIC_DW2);
-	regs_buff[1099] = IXGBE_READ_REG(hw, IXGBE_TIC_DW3);
+	for (i = 0; i < 4; i++)
+		regs_buff[1096 + i] = IXGBE_READ_REG(hw, IXGBE_TIC_DW(i));
 	regs_buff[1100] = IXGBE_READ_REG(hw, IXGBE_TDPROBE);
 	regs_buff[1101] = IXGBE_READ_REG(hw, IXGBE_TXBUFCTRL);
 	regs_buff[1102] = IXGBE_READ_REG(hw, IXGBE_TXBUFDATA0);
@@ -566,7 +563,7 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[1109] = IXGBE_READ_REG(hw, IXGBE_RXBUFDATA2);
 	regs_buff[1110] = IXGBE_READ_REG(hw, IXGBE_RXBUFDATA3);
 	for (i = 0; i < 8; i++)
-		regs_buff[1111] = IXGBE_READ_REG(hw, IXGBE_PCIE_DIAG(i));
+		regs_buff[1111 + i] = IXGBE_READ_REG(hw, IXGBE_PCIE_DIAG(i));
 	regs_buff[1119] = IXGBE_READ_REG(hw, IXGBE_RFVAL);
 	regs_buff[1120] = IXGBE_READ_REG(hw, IXGBE_MDFTC1);
 	regs_buff[1121] = IXGBE_READ_REG(hw, IXGBE_MDFTC2);
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 172f766..196841b 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -278,18 +278,12 @@
 #define IXGBE_RDSTATCTL 0x02C20
 #define IXGBE_RDSTAT(_i) (0x02C00 + ((_i) * 4)) /* 0x02C00-0x02C1C */
 #define IXGBE_RDHMPN    0x02F08
-#define IXGBE_RIC_DW0   0x02F10
-#define IXGBE_RIC_DW1   0x02F14
-#define IXGBE_RIC_DW2   0x02F18
-#define IXGBE_RIC_DW3   0x02F1C
+#define IXGBE_RIC_DW(_i)  (0x02F10 + ((_i) * 4))
 #define IXGBE_RDPROBE   0x02F20
 #define IXGBE_TDSTATCTL 0x07C20
 #define IXGBE_TDSTAT(_i) (0x07C00 + ((_i) * 4)) /* 0x07C00 - 0x07C1C */
 #define IXGBE_TDHMPN    0x07F08
-#define IXGBE_TIC_DW0   0x07F10
-#define IXGBE_TIC_DW1   0x07F14
-#define IXGBE_TIC_DW2   0x07F18
-#define IXGBE_TIC_DW3   0x07F1C
+#define IXGBE_TIC_DW(_i)  (0x07F10 + ((_i) * 4))
 #define IXGBE_TDPROBE   0x07F20
 #define IXGBE_TXBUFCTRL 0x0C600
 #define IXGBE_TXBUFDATA0  0x0C610

