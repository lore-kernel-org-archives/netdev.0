From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 1/4] bnx2x: Receive traffic that maches management
 filtering rules
Date: Wed, 29 Jul 2009 13:20:04 +0300
Message-ID: <1248862804.27379.15.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4344 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753816AbZG2KUf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2009 06:20:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to lack of configuration, if the BMC configures the chip to pass all
broadcast/multicast traffic to it, the host will not receive it. On top of
fixing it, also make sure that in promiscuous mode, the host will receive the
management traffic as well.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   13 +++++++++++++
 drivers/net/bnx2x_reg.h  |    5 +++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index a2de0cd..5273988 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4831,7 +4831,14 @@ static void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 	int mode = bp->rx_mode;
 	int mask = (1 << BP_L_ID(bp));
 	int func = BP_FUNC(bp);
+	int port = BP_PORT(bp);
 	int i;
+	/* All but management unicast packets should pass to the host as well */
+	u32 llh_mask =
+		NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_BRCST |
+		NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_MLCST |
+		NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_VLAN |
+		NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_NO_VLAN;
 
 	DP(NETIF_MSG_IFUP, "rx mode %d  mask 0x%x\n", mode, mask);
 
@@ -4855,6 +4862,8 @@ static void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 		tstorm_mac_filter.ucast_accept_all = mask;
 		tstorm_mac_filter.mcast_accept_all = mask;
 		tstorm_mac_filter.bcast_accept_all = mask;
+		/* pass management unicast packets as well */
+		llh_mask |= NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_UNCST;
 		break;
 
 	default:
@@ -4862,6 +4871,10 @@ static void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 		break;
 	}
 
+	REG_WR(bp,
+	       (port ? NIG_REG_LLH1_BRB1_DRV_MASK : NIG_REG_LLH0_BRB1_DRV_MASK),
+	       llh_mask);
+
 	for (i = 0; i < sizeof(struct tstorm_eth_mac_filter_config)/4; i++) {
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
 		       TSTORM_MAC_FILTER_CONFIG_OFFSET(func) + i * 4,
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index d771168..8e9e7a2 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -1616,6 +1616,11 @@
 /* [RW 1] Set by the MCP to remember if one or more of the drivers is/are
    loaded; 0-prepare; -unprepare */
 #define MISC_REG_UNPREPARED					 0xa424
+#define NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_BRCST	 (0x1<<0)
+#define NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_MLCST	 (0x1<<1)
+#define NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_NO_VLAN	 (0x1<<4)
+#define NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_UNCST	 (0x1<<2)
+#define NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_VLAN	 (0x1<<3)
 #define NIG_MASK_INTERRUPT_PORT0_REG_MASK_EMAC0_MISC_MI_INT	 (0x1<<0)
 #define NIG_MASK_INTERRUPT_PORT0_REG_MASK_SERDES0_LINK_STATUS	 (0x1<<9)
 #define NIG_MASK_INTERRUPT_PORT0_REG_MASK_XGXS0_LINK10G 	 (0x1<<15)
-- 
1.5.4.3




