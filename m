From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  5/9] ixgbe: ethtool DCB registers dump for 82599 and x540
Date: Tue,  1 Oct 2013 04:33:52 -0700
Message-ID: <1380627236-3190-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Leonardo Potenza <leonardo.potenza@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Maryam Tahhan <maryam.tahhan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46701 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837Ab3JALeC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 07:34:02 -0400
In-Reply-To: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leonardo Potenza <leonardo.potenza@intel.com>

Added support for DCB registers dump using ethtool -d option both for
82599 and x540 ethernet controllers

Signed-off-by: Leonardo Potenza <leonardo.potenza@intel.com>
Signed-off-by: Maryam Tahhan <maryam.tahhan@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Jack Morgan <jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 75 +++++++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |  5 ++
 2 files changed, 65 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index e8649ab..27c2032 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -442,7 +442,7 @@ static void ixgbe_set_msglevel(struct net_device *netdev, u32 data)
 
 static int ixgbe_get_regs_len(struct net_device *netdev)
 {
-#define IXGBE_REGS_LEN  1129
+#define IXGBE_REGS_LEN  1139
 	return IXGBE_REGS_LEN * sizeof(u32);
 }
 
@@ -602,22 +602,53 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[828] = IXGBE_READ_REG(hw, IXGBE_FHFT(0));
 
 	/* DCB */
-	regs_buff[829] = IXGBE_READ_REG(hw, IXGBE_RMCS);
-	regs_buff[830] = IXGBE_READ_REG(hw, IXGBE_DPMCS);
-	regs_buff[831] = IXGBE_READ_REG(hw, IXGBE_PDPMCS);
-	regs_buff[832] = IXGBE_READ_REG(hw, IXGBE_RUPPBMR);
-	for (i = 0; i < 8; i++)
-		regs_buff[833 + i] = IXGBE_READ_REG(hw, IXGBE_RT2CR(i));
-	for (i = 0; i < 8; i++)
-		regs_buff[841 + i] = IXGBE_READ_REG(hw, IXGBE_RT2SR(i));
-	for (i = 0; i < 8; i++)
-		regs_buff[849 + i] = IXGBE_READ_REG(hw, IXGBE_TDTQ2TCCR(i));
-	for (i = 0; i < 8; i++)
-		regs_buff[857 + i] = IXGBE_READ_REG(hw, IXGBE_TDTQ2TCSR(i));
+	regs_buff[829] = IXGBE_READ_REG(hw, IXGBE_RMCS);   /* same as FCCFG  */
+	regs_buff[831] = IXGBE_READ_REG(hw, IXGBE_PDPMCS); /* same as RTTPCS */
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		regs_buff[830] = IXGBE_READ_REG(hw, IXGBE_DPMCS);
+		regs_buff[832] = IXGBE_READ_REG(hw, IXGBE_RUPPBMR);
+		for (i = 0; i < 8; i++)
+			regs_buff[833 + i] =
+				IXGBE_READ_REG(hw, IXGBE_RT2CR(i));
+		for (i = 0; i < 8; i++)
+			regs_buff[841 + i] =
+				IXGBE_READ_REG(hw, IXGBE_RT2SR(i));
+		for (i = 0; i < 8; i++)
+			regs_buff[849 + i] =
+				IXGBE_READ_REG(hw, IXGBE_TDTQ2TCCR(i));
+		for (i = 0; i < 8; i++)
+			regs_buff[857 + i] =
+				IXGBE_READ_REG(hw, IXGBE_TDTQ2TCSR(i));
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		regs_buff[830] = IXGBE_READ_REG(hw, IXGBE_RTTDCS);
+		regs_buff[832] = IXGBE_READ_REG(hw, IXGBE_RTRPCS);
+		for (i = 0; i < 8; i++)
+			regs_buff[833 + i] =
+				IXGBE_READ_REG(hw, IXGBE_RTRPT4C(i));
+		for (i = 0; i < 8; i++)
+			regs_buff[841 + i] =
+				IXGBE_READ_REG(hw, IXGBE_RTRPT4S(i));
+		for (i = 0; i < 8; i++)
+			regs_buff[849 + i] =
+				IXGBE_READ_REG(hw, IXGBE_RTTDT2C(i));
+		for (i = 0; i < 8; i++)
+			regs_buff[857 + i] =
+				IXGBE_READ_REG(hw, IXGBE_RTTDT2S(i));
+		break;
+	default:
+		break;
+	}
+
 	for (i = 0; i < 8; i++)
-		regs_buff[865 + i] = IXGBE_READ_REG(hw, IXGBE_TDPT2TCCR(i));
+		regs_buff[865 + i] =
+		IXGBE_READ_REG(hw, IXGBE_TDPT2TCCR(i)); /* same as RTTPT2C */
 	for (i = 0; i < 8; i++)
-		regs_buff[873 + i] = IXGBE_READ_REG(hw, IXGBE_TDPT2TCSR(i));
+		regs_buff[873 + i] =
+		IXGBE_READ_REG(hw, IXGBE_TDPT2TCSR(i)); /* same as RTTPT2S */
 
 	/* Statistics */
 	regs_buff[881] = IXGBE_GET_STAT(adapter, crcerrs);
@@ -757,6 +788,20 @@ static void ixgbe_get_regs(struct net_device *netdev,
 
 	/* 82599 X540 specific registers  */
 	regs_buff[1128] = IXGBE_READ_REG(hw, IXGBE_MFLCN);
+
+	/* 82599 X540 specific DCB registers  */
+	regs_buff[1129] = IXGBE_READ_REG(hw, IXGBE_RTRUP2TC);
+	regs_buff[1130] = IXGBE_READ_REG(hw, IXGBE_RTTUP2TC);
+	for (i = 0; i < 4; i++)
+		regs_buff[1131 + i] = IXGBE_READ_REG(hw, IXGBE_TXLLQ(i));
+	regs_buff[1135] = IXGBE_READ_REG(hw, IXGBE_RTTBCNRM);
+					/* same as RTTQCNRM */
+	regs_buff[1136] = IXGBE_READ_REG(hw, IXGBE_RTTBCNRD);
+					/* same as RTTQCNRR */
+
+	/* X540 specific DCB registers  */
+	regs_buff[1137] = IXGBE_READ_REG(hw, IXGBE_RTTQCNCR);
+	regs_buff[1138] = IXGBE_READ_REG(hw, IXGBE_RTTQCNTG);
 }
 
 static int ixgbe_get_eeprom_len(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 10775cb..7c19e96 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -561,6 +561,10 @@ struct ixgbe_thermal_sensor_data {
 #define IXGBE_RTTDQSEL    0x04904
 #define IXGBE_RTTDT1C     0x04908
 #define IXGBE_RTTDT1S     0x0490C
+#define IXGBE_RTTQCNCR    0x08B00
+#define IXGBE_RTTQCNTG    0x04A90
+#define IXGBE_RTTBCNRD    0x0498C
+#define IXGBE_RTTQCNRR    0x0498C
 #define IXGBE_RTTDTECC    0x04990
 #define IXGBE_RTTDTECC_NO_BCN   0x00000100
 #define IXGBE_RTTBCNRC    0x04984
@@ -570,6 +574,7 @@ struct ixgbe_thermal_sensor_data {
 #define IXGBE_RTTBCNRC_RF_INT_MASK	\
 	(IXGBE_RTTBCNRC_RF_DEC_MASK << IXGBE_RTTBCNRC_RF_INT_SHIFT)
 #define IXGBE_RTTBCNRM    0x04980
+#define IXGBE_RTTQCNRM    0x04980
 
 /* FCoE DMA Context Registers */
 #define IXGBE_FCPTRL    0x02410 /* FC User Desc. PTR Low */
-- 
1.8.3.1
