From: <Woojung.Huh@microchip.com>
Subject: [PATCH v5 net-next 3/5] dsa: add DSA switch driver for Microchip
 KSZ9477
Date: Wed, 31 May 2017 00:00:37 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40AA4D69@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:15988 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751058AbdEaAAt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:00:49 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <Woojung.Huh@microchip.com>

The KSZ9477 is a fully integrated layer 2, managed, 7 ports GigE switch
with numerous advanced features. 5 ports incorporate 10/100/1000 Mbps PHYs.
The other 2 ports have interfaces that can be configured as SGMII, RGMII, MII
or RMII. Either of these may connect directly to a host processor or
to an external PHY. The SGMII port may interface to a fiber optic transceiver.

This driver currently supports vlan, fdb, mdb & mirror dsa switch operations.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Woojung Huh <Woojung.Huh@microchip.com>
---
 drivers/net/dsa/Kconfig                     |    2 +
 drivers/net/dsa/Makefile                    |    1 +
 drivers/net/dsa/microchip/Kconfig           |   12 +
 drivers/net/dsa/microchip/Makefile          |    2 +
 drivers/net/dsa/microchip/ksz_9477_reg.h    | 1676 +++++++++++++++++++++++++++
 drivers/net/dsa/microchip/ksz_common.c      | 1278 ++++++++++++++++++++
 drivers/net/dsa/microchip/ksz_priv.h        |  210 ++++
 drivers/net/dsa/microchip/ksz_spi.c         |  215 ++++
 include/linux/platform_data/microchip-ksz.h |   29 +
 9 files changed, 3425 insertions(+)
 create mode 100644 drivers/net/dsa/microchip/Kconfig
 create mode 100644 drivers/net/dsa/microchip/Makefile
 create mode 100644 drivers/net/dsa/microchip/ksz_9477_reg.h
 create mode 100644 drivers/net/dsa/microchip/ksz_common.c
 create mode 100644 drivers/net/dsa/microchip/ksz_priv.h
 create mode 100644 drivers/net/dsa/microchip/ksz_spi.c
 create mode 100644 include/linux/platform_data/microchip-ksz.h

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 68131a4..83a9bc8 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -39,6 +39,8 @@ config NET_DSA_MV88E6060
 	  This enables support for the Marvell 88E6060 ethernet switch
 	  chip.
 
+source "drivers/net/dsa/microchip/Kconfig"
+
 source "drivers/net/dsa/mv88e6xxx/Kconfig"
 
 config NET_DSA_QCA8K
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index 9613f36..4a5b5bd 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -8,4 +8,5 @@ obj-$(CONFIG_NET_DSA_SMSC_LAN9303) += lan9303-core.o
 obj-$(CONFIG_NET_DSA_SMSC_LAN9303_I2C) += lan9303_i2c.o
 obj-$(CONFIG_NET_DSA_SMSC_LAN9303_MDIO) += lan9303_mdio.o
 obj-y				+= b53/
+obj-y				+= microchip/
 obj-y				+= mv88e6xxx/
diff --git a/drivers/net/dsa/microchip/Kconfig b/drivers/net/dsa/microchip/Kconfig
new file mode 100644
index 0000000..a8b8f59
--- /dev/null
+++ b/drivers/net/dsa/microchip/Kconfig
@@ -0,0 +1,12 @@
+menuconfig MICROCHIP_KSZ
+	tristate "Microchip KSZ series switch support"
+	depends on NET_DSA
+	select NET_DSA_TAG_KSZ
+	help
+	  This driver adds support for Microchip KSZ switch chips.
+
+config MICROCHIP_KSZ_SPI_DRIVER
+	tristate "KSZ series SPI connected switch driver"
+	depends on MICROCHIP_KSZ && SPI
+	help
+	  Select to enable support for registering switches configured through SPI.
diff --git a/drivers/net/dsa/microchip/Makefile b/drivers/net/dsa/microchip/Makefile
new file mode 100644
index 0000000..ed335e2
--- /dev/null
+++ b/drivers/net/dsa/microchip/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_MICROCHIP_KSZ)	        += ksz_common.o
+obj-$(CONFIG_MICROCHIP_KSZ_SPI_DRIVER)	+= ksz_spi.o
diff --git a/drivers/net/dsa/microchip/ksz_9477_reg.h b/drivers/net/dsa/microchip/ksz_9477_reg.h
new file mode 100644
index 0000000..6aa6752
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz_9477_reg.h
@@ -0,0 +1,1676 @@
+/*
+ * Microchip KSZ9477 register definitions
+ *
+ * Copyright (C) 2017
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef __KSZ9477_REGS_H
+#define __KSZ9477_REGS_H
+
+#define KS_PRIO_M			0x7
+#define KS_PRIO_S			4
+
+/* 0 - Operation */
+#define REG_CHIP_ID0__1			0x0000
+
+#define REG_CHIP_ID1__1			0x0001
+
+#define FAMILY_ID			0x95
+#define FAMILY_ID_94			0x94
+#define FAMILY_ID_95			0x95
+#define FAMILY_ID_85			0x85
+#define FAMILY_ID_98			0x98
+#define FAMILY_ID_88			0x88
+
+#define REG_CHIP_ID2__1			0x0002
+
+#define CHIP_ID_63			0x63
+#define CHIP_ID_66			0x66
+#define CHIP_ID_67			0x67
+#define CHIP_ID_77			0x77
+#define CHIP_ID_93			0x93
+#define CHIP_ID_96			0x96
+#define CHIP_ID_97			0x97
+
+#define REG_CHIP_ID3__1			0x0003
+
+#define SWITCH_REVISION_M		0x0F
+#define SWITCH_REVISION_S		4
+#define SWITCH_RESET			0x01
+
+#define REG_SW_PME_CTRL			0x0006
+
+#define PME_ENABLE			BIT(1)
+#define PME_POLARITY			BIT(0)
+
+#define REG_GLOBAL_OPTIONS		0x000F
+
+#define SW_GIGABIT_ABLE			BIT(6)
+#define SW_REDUNDANCY_ABLE		BIT(5)
+#define SW_AVB_ABLE			BIT(4)
+#define SW_9567_RL_5_2			0xC
+#define SW_9477_SL_5_2			0xD
+
+#define SW_9896_GL_5_1			0xB
+#define SW_9896_RL_5_1			0x8
+#define SW_9896_SL_5_1			0x9
+
+#define SW_9895_GL_4_1			0x7
+#define SW_9895_RL_4_1			0x4
+#define SW_9895_SL_4_1			0x5
+
+#define SW_9896_RL_4_2			0x6
+
+#define SW_9893_RL_2_1			0x0
+#define SW_9893_SL_2_1			0x1
+#define SW_9893_GL_2_1			0x3
+
+#define SW_QW_ABLE			BIT(5)
+#define SW_9893_RN_2_1			0xC
+
+#define REG_SW_INT_STATUS__4		0x0010
+#define REG_SW_INT_MASK__4		0x0014
+
+#define LUE_INT				BIT(31)
+#define TRIG_TS_INT			BIT(30)
+#define APB_TIMEOUT_INT			BIT(29)
+
+#define SWITCH_INT_MASK			(TRIG_TS_INT | APB_TIMEOUT_INT)
+
+#define REG_SW_PORT_INT_STATUS__4	0x0018
+#define REG_SW_PORT_INT_MASK__4		0x001C
+#define REG_SW_PHY_INT_STATUS		0x0020
+#define REG_SW_PHY_INT_ENABLE		0x0024
+
+/* 1 - Global */
+#define REG_SW_GLOBAL_SERIAL_CTRL_0	0x0100
+#define SW_SPARE_REG_2			BIT(7)
+#define SW_SPARE_REG_1			BIT(6)
+#define SW_SPARE_REG_0			BIT(5)
+#define SW_BIG_ENDIAN			BIT(4)
+#define SPI_AUTO_EDGE_DETECTION		BIT(1)
+#define SPI_CLOCK_OUT_RISING_EDGE	BIT(0)
+
+#define REG_SW_GLOBAL_OUTPUT_CTRL__1	0x0103
+#define SW_ENABLE_REFCLKO		BIT(1)
+#define SW_REFCLKO_IS_125MHZ		BIT(0)
+
+#define REG_SW_IBA__4			0x0104
+
+#define SW_IBA_ENABLE			BIT(31)
+#define SW_IBA_DA_MATCH			BIT(30)
+#define SW_IBA_INIT			BIT(29)
+#define SW_IBA_QID_M			0xF
+#define SW_IBA_QID_S			22
+#define SW_IBA_PORT_M			0x2F
+#define SW_IBA_PORT_S			16
+#define SW_IBA_FRAME_TPID_M		0xFFFF
+
+#define REG_SW_APB_TIMEOUT_ADDR__4	0x0108
+
+#define APB_TIMEOUT_ACKNOWLEDGE		BIT(31)
+
+#define REG_SW_IBA_SYNC__1		0x010C
+
+#define REG_SW_IO_STRENGTH__1		0x010D
+#define SW_DRIVE_STRENGTH_M		0x7
+#define SW_DRIVE_STRENGTH_2MA		0
+#define SW_DRIVE_STRENGTH_4MA		1
+#define SW_DRIVE_STRENGTH_8MA		2
+#define SW_DRIVE_STRENGTH_12MA		3
+#define SW_DRIVE_STRENGTH_16MA		4
+#define SW_DRIVE_STRENGTH_20MA		5
+#define SW_DRIVE_STRENGTH_24MA		6
+#define SW_DRIVE_STRENGTH_28MA		7
+#define SW_HI_SPEED_DRIVE_STRENGTH_S	4
+#define SW_LO_SPEED_DRIVE_STRENGTH_S	0
+
+#define REG_SW_IBA_STATUS__4		0x0110
+
+#define SW_IBA_REQ			BIT(31)
+#define SW_IBA_RESP			BIT(30)
+#define SW_IBA_DA_MISMATCH		BIT(14)
+#define SW_IBA_FMT_MISMATCH		BIT(13)
+#define SW_IBA_CODE_ERROR		BIT(12)
+#define SW_IBA_CMD_ERROR		BIT(11)
+#define SW_IBA_CMD_LOC_M		(BIT(6) - 1)
+
+#define REG_SW_IBA_STATES__4		0x0114
+
+#define SW_IBA_BUF_STATE_S		30
+#define SW_IBA_CMD_STATE_S		28
+#define SW_IBA_RESP_STATE_S		26
+#define SW_IBA_STATE_M			0x3
+#define SW_IBA_PACKET_SIZE_M		0x7F
+#define SW_IBA_PACKET_SIZE_S		16
+#define SW_IBA_FMT_ID_M			0xFFFF
+
+#define REG_SW_IBA_RESULT__4		0x0118
+
+#define SW_IBA_SIZE_S			24
+
+#define SW_IBA_RETRY_CNT_M		(BIT(5) - 1)
+
+/* 2 - PHY */
+#define REG_SW_POWER_MANAGEMENT_CTRL	0x0201
+
+#define SW_PLL_POWER_DOWN		BIT(5)
+#define SW_POWER_DOWN_MODE		0x3
+#define SW_ENERGY_DETECTION		1
+#define SW_SOFT_POWER_DOWN		2
+#define SW_POWER_SAVING			3
+
+/* 3 - Operation Control */
+#define REG_SW_OPERATION		0x0300
+
+#define SW_DOUBLE_TAG			BIT(7)
+#define SW_RESET			BIT(1)
+#define SW_START			BIT(0)
+
+#define REG_SW_MAC_ADDR_0		0x0302
+#define REG_SW_MAC_ADDR_1		0x0303
+#define REG_SW_MAC_ADDR_2		0x0304
+#define REG_SW_MAC_ADDR_3		0x0305
+#define REG_SW_MAC_ADDR_4		0x0306
+#define REG_SW_MAC_ADDR_5		0x0307
+
+#define REG_SW_MTU__2			0x0308
+
+#define REG_SW_ISP_TPID__2		0x030A
+
+#define REG_SW_HSR_TPID__2		0x030C
+
+#define REG_AVB_STRATEGY__2		0x030E
+
+#define SW_SHAPING_CREDIT_ACCT		BIT(1)
+#define SW_POLICING_CREDIT_ACCT		BIT(0)
+
+#define REG_SW_LUE_CTRL_0		0x0310
+
+#define SW_VLAN_ENABLE			BIT(7)
+#define SW_DROP_INVALID_VID		BIT(6)
+#define SW_AGE_CNT_M			0x7
+#define SW_AGE_CNT_S			3
+#define SW_RESV_MCAST_ENABLE		BIT(2)
+#define SW_HASH_OPTION_M		0x03
+#define SW_HASH_OPTION_CRC		1
+#define SW_HASH_OPTION_XOR		2
+#define SW_HASH_OPTION_DIRECT		3
+
+#define REG_SW_LUE_CTRL_1		0x0311
+
+#define UNICAST_LEARN_DISABLE		BIT(7)
+#define SW_SRC_ADDR_FILTER		BIT(6)
+#define SW_FLUSH_STP_TABLE		BIT(5)
+#define SW_FLUSH_MSTP_TABLE		BIT(4)
+#define SW_FWD_MCAST_SRC_ADDR		BIT(3)
+#define SW_AGING_ENABLE			BIT(2)
+#define SW_FAST_AGING			BIT(1)
+#define SW_LINK_AUTO_AGING		BIT(0)
+
+#define REG_SW_LUE_CTRL_2		0x0312
+
+#define SW_TRAP_DOUBLE_TAG		BIT(6)
+#define SW_EGRESS_VLAN_FILTER_DYN	BIT(5)
+#define SW_EGRESS_VLAN_FILTER_STA	BIT(4)
+#define SW_FLUSH_OPTION_M		0x3
+#define SW_FLUSH_OPTION_S		2
+#define SW_FLUSH_OPTION_DYN_MAC		1
+#define SW_FLUSH_OPTION_STA_MAC		2
+#define SW_FLUSH_OPTION_BOTH		3
+#define SW_PRIO_M			0x3
+#define SW_PRIO_DA			0
+#define SW_PRIO_SA			1
+#define SW_PRIO_HIGHEST_DA_SA		2
+#define SW_PRIO_LOWEST_DA_SA		3
+
+#define REG_SW_LUE_CTRL_3		0x0313
+
+#define REG_SW_LUE_INT_STATUS		0x0314
+#define REG_SW_LUE_INT_ENABLE		0x0315
+
+#define LEARN_FAIL_INT			BIT(2)
+#define ALMOST_FULL_INT			BIT(1)
+#define WRITE_FAIL_INT			BIT(0)
+
+#define REG_SW_LUE_INDEX_0__2		0x0316
+
+#define ENTRY_INDEX_M			0x0FFF
+
+#define REG_SW_LUE_INDEX_1__2		0x0318
+
+#define FAIL_INDEX_M			0x03FF
+
+#define REG_SW_LUE_INDEX_2__2		0x031A
+
+#define REG_SW_LUE_UNK_UCAST_CTRL__4	0x0320
+
+#define SW_UNK_UCAST_ENABLE		BIT(31)
+
+#define REG_SW_LUE_UNK_MCAST_CTRL__4	0x0324
+
+#define SW_UNK_MCAST_ENABLE		BIT(31)
+
+#define REG_SW_LUE_UNK_VID_CTRL__4	0x0328
+
+#define SW_UNK_VID_ENABLE		BIT(31)
+
+#define REG_SW_MAC_CTRL_0		0x0330
+
+#define SW_NEW_BACKOFF			BIT(7)
+#define SW_CHECK_LENGTH			BIT(3)
+#define SW_PAUSE_UNH_MODE		BIT(1)
+#define SW_AGGR_BACKOFF			BIT(0)
+
+#define REG_SW_MAC_CTRL_1		0x0331
+
+#define MULTICAST_STORM_DISABLE		BIT(6)
+#define SW_BACK_PRESSURE		BIT(5)
+#define FAIR_FLOW_CTRL			BIT(4)
+#define NO_EXC_COLLISION_DROP		BIT(3)
+#define SW_JUMBO_PACKET			BIT(2)
+#define SW_LEGAL_PACKET_DISABLE		BIT(1)
+#define SW_PASS_SHORT_FRAME		BIT(0)
+
+#define REG_SW_MAC_CTRL_2		0x0332
+
+#define SW_REPLACE_VID			BIT(3)
+#define BROADCAST_STORM_RATE_HI		0x07
+
+#define REG_SW_MAC_CTRL_3		0x0333
+
+#define BROADCAST_STORM_RATE_LO		0xFF
+#define BROADCAST_STORM_RATE		0x07FF
+
+#define REG_SW_MAC_CTRL_4		0x0334
+
+#define SW_PASS_PAUSE			BIT(3)
+
+#define REG_SW_MAC_CTRL_5		0x0335
+
+#define SW_OUT_RATE_LIMIT_QUEUE_BASED	BIT(3)
+
+#define REG_SW_MAC_CTRL_6		0x0336
+
+#define SW_MIB_COUNTER_FLUSH		BIT(7)
+#define SW_MIB_COUNTER_FREEZE		BIT(6)
+
+#define REG_SW_MAC_802_1P_MAP_0		0x0338
+#define REG_SW_MAC_802_1P_MAP_1		0x0339
+#define REG_SW_MAC_802_1P_MAP_2		0x033A
+#define REG_SW_MAC_802_1P_MAP_3		0x033B
+
+#define SW_802_1P_MAP_M			KS_PRIO_M
+#define SW_802_1P_MAP_S			KS_PRIO_S
+
+#define REG_SW_MAC_ISP_CTRL		0x033C
+
+#define REG_SW_MAC_TOS_CTRL		0x033E
+
+#define SW_TOS_DSCP_REMARK		BIT(1)
+#define SW_TOS_DSCP_REMAP		BIT(0)
+
+#define REG_SW_MAC_TOS_PRIO_0		0x0340
+#define REG_SW_MAC_TOS_PRIO_1		0x0341
+#define REG_SW_MAC_TOS_PRIO_2		0x0342
+#define REG_SW_MAC_TOS_PRIO_3		0x0343
+#define REG_SW_MAC_TOS_PRIO_4		0x0344
+#define REG_SW_MAC_TOS_PRIO_5		0x0345
+#define REG_SW_MAC_TOS_PRIO_6		0x0346
+#define REG_SW_MAC_TOS_PRIO_7		0x0347
+#define REG_SW_MAC_TOS_PRIO_8		0x0348
+#define REG_SW_MAC_TOS_PRIO_9		0x0349
+#define REG_SW_MAC_TOS_PRIO_10		0x034A
+#define REG_SW_MAC_TOS_PRIO_11		0x034B
+#define REG_SW_MAC_TOS_PRIO_12		0x034C
+#define REG_SW_MAC_TOS_PRIO_13		0x034D
+#define REG_SW_MAC_TOS_PRIO_14		0x034E
+#define REG_SW_MAC_TOS_PRIO_15		0x034F
+#define REG_SW_MAC_TOS_PRIO_16		0x0350
+#define REG_SW_MAC_TOS_PRIO_17		0x0351
+#define REG_SW_MAC_TOS_PRIO_18		0x0352
+#define REG_SW_MAC_TOS_PRIO_19		0x0353
+#define REG_SW_MAC_TOS_PRIO_20		0x0354
+#define REG_SW_MAC_TOS_PRIO_21		0x0355
+#define REG_SW_MAC_TOS_PRIO_22		0x0356
+#define REG_SW_MAC_TOS_PRIO_23		0x0357
+#define REG_SW_MAC_TOS_PRIO_24		0x0358
+#define REG_SW_MAC_TOS_PRIO_25		0x0359
+#define REG_SW_MAC_TOS_PRIO_26		0x035A
+#define REG_SW_MAC_TOS_PRIO_27		0x035B
+#define REG_SW_MAC_TOS_PRIO_28		0x035C
+#define REG_SW_MAC_TOS_PRIO_29		0x035D
+#define REG_SW_MAC_TOS_PRIO_30		0x035E
+#define REG_SW_MAC_TOS_PRIO_31		0x035F
+
+#define REG_SW_MRI_CTRL_0		0x0370
+
+#define SW_IGMP_SNOOP			BIT(6)
+#define SW_IPV6_MLD_OPTION		BIT(3)
+#define SW_IPV6_MLD_SNOOP		BIT(2)
+#define SW_MIRROR_RX_TX			BIT(0)
+
+#define REG_SW_CLASS_D_IP_CTRL__4	0x0374
+
+#define SW_CLASS_D_IP_ENABLE		BIT(31)
+
+#define REG_SW_MRI_CTRL_8		0x0378
+
+#define SW_NO_COLOR_S			6
+#define SW_RED_COLOR_S			4
+#define SW_YELLOW_COLOR_S		2
+#define SW_GREEN_COLOR_S		0
+#define SW_COLOR_M			0x3
+
+#define REG_SW_QM_CTRL__4		0x0390
+
+#define PRIO_SCHEME_SELECT_M		KS_PRIO_M
+#define PRIO_SCHEME_SELECT_S		6
+#define PRIO_MAP_3_HI			0
+#define PRIO_MAP_2_HI			2
+#define PRIO_MAP_0_LO			3
+#define UNICAST_VLAN_BOUNDARY		BIT(1)
+
+#define REG_SW_EEE_QM_CTRL__2		0x03C0
+
+#define REG_SW_EEE_TXQ_WAIT_TIME__2	0x03C2
+
+/* 4 - */
+#define REG_SW_VLAN_ENTRY__4		0x0400
+
+#define VLAN_VALID			BIT(31)
+#define VLAN_FORWARD_OPTION		BIT(27)
+#define VLAN_PRIO_M			KS_PRIO_M
+#define VLAN_PRIO_S			24
+#define VLAN_MSTP_M			0x7
+#define VLAN_MSTP_S			12
+#define VLAN_FID_M			0x7F
+
+#define REG_SW_VLAN_ENTRY_UNTAG__4	0x0404
+#define REG_SW_VLAN_ENTRY_PORTS__4	0x0408
+
+#define REG_SW_VLAN_ENTRY_INDEX__2	0x040C
+
+#define VLAN_INDEX_M			0x0FFF
+
+#define REG_SW_VLAN_CTRL		0x040E
+
+#define VLAN_START			BIT(7)
+#define VLAN_ACTION			0x3
+#define VLAN_WRITE			1
+#define VLAN_READ			2
+#define VLAN_CLEAR			3
+
+#define REG_SW_ALU_INDEX_0		0x0410
+
+#define ALU_FID_INDEX_S			16
+#define ALU_MAC_ADDR_HI			0xFFFF
+
+#define REG_SW_ALU_INDEX_1		0x0414
+
+#define ALU_DIRECT_INDEX_M		(BIT(12) - 1)
+
+#define REG_SW_ALU_CTRL__4		0x0418
+
+#define ALU_VALID_CNT_M			(BIT(14) - 1)
+#define ALU_VALID_CNT_S			16
+#define ALU_START			BIT(7)
+#define ALU_VALID			BIT(6)
+#define ALU_DIRECT			BIT(2)
+#define ALU_ACTION			0x3
+#define ALU_WRITE			1
+#define ALU_READ			2
+#define ALU_SEARCH			3
+
+#define REG_SW_ALU_STAT_CTRL__4		0x041C
+
+#define ALU_STAT_INDEX_M		(BIT(4) - 1)
+#define ALU_STAT_INDEX_S		16
+#define ALU_RESV_MCAST_INDEX_M		(BIT(6) - 1)
+#define ALU_STAT_START			BIT(7)
+#define ALU_RESV_MCAST_ADDR		BIT(1)
+#define ALU_STAT_READ			BIT(0)
+
+#define REG_SW_ALU_VAL_A		0x0420
+
+#define ALU_V_STATIC_VALID		BIT(31)
+#define ALU_V_SRC_FILTER		BIT(30)
+#define ALU_V_DST_FILTER		BIT(29)
+#define ALU_V_PRIO_AGE_CNT_M		(BIT(3) - 1)
+#define ALU_V_PRIO_AGE_CNT_S		26
+#define ALU_V_MSTP_M			0x7
+
+#define REG_SW_ALU_VAL_B		0x0424
+
+#define ALU_V_OVERRIDE			BIT(31)
+#define ALU_V_USE_FID			BIT(30)
+#define ALU_V_PORT_MAP			(BIT(24) - 1)
+
+#define REG_SW_ALU_VAL_C		0x0428
+
+#define ALU_V_FID_M			(BIT(16) - 1)
+#define ALU_V_FID_S			16
+#define ALU_V_MAC_ADDR_HI		0xFFFF
+
+#define REG_SW_ALU_VAL_D		0x042C
+
+#define REG_HSR_ALU_INDEX_0		0x0440
+
+#define REG_HSR_ALU_INDEX_1		0x0444
+
+#define HSR_DST_MAC_INDEX_LO_S		16
+#define HSR_SRC_MAC_INDEX_HI		0xFFFF
+
+#define REG_HSR_ALU_INDEX_2		0x0448
+
+#define HSR_INDEX_MAX			BIT(9)
+#define HSR_DIRECT_INDEX_M		(HSR_INDEX_MAX - 1)
+
+#define REG_HSR_ALU_INDEX_3		0x044C
+
+#define HSR_PATH_INDEX_M		(BIT(4) - 1)
+
+#define REG_HSR_ALU_CTRL__4		0x0450
+
+#define HSR_VALID_CNT_M			(BIT(14) - 1)
+#define HSR_VALID_CNT_S			16
+#define HSR_START			BIT(7)
+#define HSR_VALID			BIT(6)
+#define HSR_SEARCH_END			BIT(5)
+#define HSR_DIRECT			BIT(2)
+#define HSR_ACTION			0x3
+#define HSR_WRITE			1
+#define HSR_READ			2
+#define HSR_SEARCH			3
+
+#define REG_HSR_ALU_VAL_A		0x0454
+
+#define HSR_V_STATIC_VALID		BIT(31)
+#define HSR_V_AGE_CNT_M			(BIT(3) - 1)
+#define HSR_V_AGE_CNT_S			26
+#define HSR_V_PATH_ID_M			(BIT(4) - 1)
+
+#define REG_HSR_ALU_VAL_B		0x0458
+
+#define REG_HSR_ALU_VAL_C		0x045C
+
+#define HSR_V_DST_MAC_ADDR_LO_S		16
+#define HSR_V_SRC_MAC_ADDR_HI		0xFFFF
+
+#define REG_HSR_ALU_VAL_D		0x0460
+
+#define REG_HSR_ALU_VAL_E		0x0464
+
+#define HSR_V_START_SEQ_1_S		16
+#define HSR_V_START_SEQ_2_S		0
+
+#define REG_HSR_ALU_VAL_F		0x0468
+
+#define HSR_V_EXP_SEQ_1_S		16
+#define HSR_V_EXP_SEQ_2_S		0
+
+#define REG_HSR_ALU_VAL_G		0x046C
+
+#define HSR_V_SEQ_CNT_1_S		16
+#define HSR_V_SEQ_CNT_2_S		0
+
+#define HSR_V_SEQ_M			(BIT(16) - 1)
+
+/* 5 - PTP Clock */
+#define REG_PTP_CLK_CTRL		0x0500
+
+#define PTP_STEP_ADJ			BIT(6)
+#define PTP_STEP_DIR			BIT(5)
+#define PTP_READ_TIME			BIT(4)
+#define PTP_LOAD_TIME			BIT(3)
+#define PTP_CLK_ADJ_ENABLE		BIT(2)
+#define PTP_CLK_ENABLE			BIT(1)
+#define PTP_CLK_RESET			BIT(0)
+
+#define REG_PTP_RTC_SUB_NANOSEC__2	0x0502
+
+#define PTP_RTC_SUB_NANOSEC_M		0x0007
+
+#define REG_PTP_RTC_NANOSEC		0x0504
+#define REG_PTP_RTC_NANOSEC_H		0x0504
+#define REG_PTP_RTC_NANOSEC_L		0x0506
+
+#define REG_PTP_RTC_SEC			0x0508
+#define REG_PTP_RTC_SEC_H		0x0508
+#define REG_PTP_RTC_SEC_L		0x050A
+
+#define REG_PTP_SUBNANOSEC_RATE		0x050C
+#define REG_PTP_SUBNANOSEC_RATE_H	0x050C
+
+#define PTP_RATE_DIR			BIT(31)
+#define PTP_TMP_RATE_ENABLE		BIT(30)
+
+#define REG_PTP_SUBNANOSEC_RATE_L	0x050E
+
+#define REG_PTP_RATE_DURATION		0x0510
+#define REG_PTP_RATE_DURATION_H		0x0510
+#define REG_PTP_RATE_DURATION_L		0x0512
+
+#define REG_PTP_MSG_CONF1		0x0514
+
+#define PTP_802_1AS			BIT(7)
+#define PTP_ENABLE			BIT(6)
+#define PTP_ETH_ENABLE			BIT(5)
+#define PTP_IPV4_UDP_ENABLE		BIT(4)
+#define PTP_IPV6_UDP_ENABLE		BIT(3)
+#define PTP_TC_P2P			BIT(2)
+#define PTP_MASTER			BIT(1)
+#define PTP_1STEP			BIT(0)
+
+#define REG_PTP_MSG_CONF2		0x0516
+
+#define PTP_UNICAST_ENABLE		BIT(12)
+#define PTP_ALTERNATE_MASTER		BIT(11)
+#define PTP_ALL_HIGH_PRIO		BIT(10)
+#define PTP_SYNC_CHECK			BIT(9)
+#define PTP_DELAY_CHECK			BIT(8)
+#define PTP_PDELAY_CHECK		BIT(7)
+#define PTP_DROP_SYNC_DELAY_REQ		BIT(5)
+#define PTP_DOMAIN_CHECK		BIT(4)
+#define PTP_UDP_CHECKSUM		BIT(2)
+
+#define REG_PTP_DOMAIN_VERSION		0x0518
+#define PTP_VERSION_M			0xFF00
+#define PTP_DOMAIN_M			0x00FF
+
+#define REG_PTP_UNIT_INDEX__4		0x0520
+
+#define PTP_UNIT_M			0xF
+
+#define PTP_GPIO_INDEX_S		16
+#define PTP_TSI_INDEX_S			8
+#define PTP_TOU_INDEX_S			0
+
+#define REG_PTP_TRIG_STATUS__4		0x0524
+
+#define TRIG_ERROR_S			16
+#define TRIG_DONE_S			0
+
+#define REG_PTP_INT_STATUS__4		0x0528
+
+#define TRIG_INT_S			16
+#define TS_INT_S			0
+
+#define TRIG_UNIT_M			0x7
+#define TS_UNIT_M			0x3
+
+#define REG_PTP_CTRL_STAT__4		0x052C
+
+#define GPIO_IN				BIT(7)
+#define GPIO_OUT			BIT(6)
+#define TS_INT_ENABLE			BIT(5)
+#define TRIG_ACTIVE			BIT(4)
+#define TRIG_ENABLE			BIT(3)
+#define TRIG_RESET			BIT(2)
+#define TS_ENABLE			BIT(1)
+#define TS_RESET			BIT(0)
+
+#define GPIO_CTRL_M			(GPIO_IN | GPIO_OUT)
+
+#define TRIG_CTRL_M			\
+	(TRIG_ACTIVE | TRIG_ENABLE | TRIG_RESET)
+
+#define TS_CTRL_M			\
+	(TS_INT_ENABLE | TS_ENABLE | TS_RESET)
+
+#define REG_TRIG_TARGET_NANOSEC		0x0530
+#define REG_TRIG_TARGET_SEC		0x0534
+
+#define REG_TRIG_CTRL__4		0x0538
+
+#define TRIG_CASCADE_ENABLE		BIT(31)
+#define TRIG_CASCADE_TAIL		BIT(30)
+#define TRIG_CASCADE_UPS_M		0xF
+#define TRIG_CASCADE_UPS_S		26
+#define TRIG_NOW			BIT(25)
+#define TRIG_NOTIFY			BIT(24)
+#define TRIG_EDGE			BIT(23)
+#define TRIG_PATTERN_S			20
+#define TRIG_PATTERN_M			0x7
+#define TRIG_NEG_EDGE			0
+#define TRIG_POS_EDGE			1
+#define TRIG_NEG_PULSE			2
+#define TRIG_POS_PULSE			3
+#define TRIG_NEG_PERIOD			4
+#define TRIG_POS_PERIOD			5
+#define TRIG_REG_OUTPUT			6
+#define TRIG_GPO_S			16
+#define TRIG_GPO_M			0xF
+#define TRIG_CASCADE_ITERATE_CNT_M	0xFFFF
+
+#define REG_TRIG_CYCLE_WIDTH		0x053C
+
+#define REG_TRIG_CYCLE_CNT		0x0540
+
+#define TRIG_CYCLE_CNT_M		0xFFFF
+#define TRIG_CYCLE_CNT_S		16
+#define TRIG_BIT_PATTERN_M		0xFFFF
+
+#define REG_TRIG_ITERATE_TIME		0x0544
+
+#define REG_TRIG_PULSE_WIDTH__4		0x0548
+
+#define TRIG_PULSE_WIDTH_M		0x00FFFFFF
+
+#define REG_TS_CTRL_STAT__4		0x0550
+
+#define TS_EVENT_DETECT_M		0xF
+#define TS_EVENT_DETECT_S		17
+#define TS_EVENT_OVERFLOW		BIT(16)
+#define TS_GPI_M			0xF
+#define TS_GPI_S			8
+#define TS_DETECT_RISE			BIT(7)
+#define TS_DETECT_FALL			BIT(6)
+#define TS_DETECT_S			6
+#define TS_CASCADE_TAIL			BIT(5)
+#define TS_CASCADE_UPS_M		0xF
+#define TS_CASCADE_UPS_S		1
+#define TS_CASCADE_ENABLE		BIT(0)
+
+#define DETECT_RISE			(TS_DETECT_RISE >> TS_DETECT_S)
+#define DETECT_FALL			(TS_DETECT_FALL >> TS_DETECT_S)
+
+#define REG_TS_EVENT_0_NANOSEC		0x0554
+#define REG_TS_EVENT_0_SEC		0x0558
+#define REG_TS_EVENT_0_SUB_NANOSEC	0x055C
+
+#define REG_TS_EVENT_1_NANOSEC		0x0560
+#define REG_TS_EVENT_1_SEC		0x0564
+#define REG_TS_EVENT_1_SUB_NANOSEC	0x0568
+
+#define REG_TS_EVENT_2_NANOSEC		0x056C
+#define REG_TS_EVENT_2_SEC		0x0570
+#define REG_TS_EVENT_2_SUB_NANOSEC	0x0574
+
+#define REG_TS_EVENT_3_NANOSEC		0x0578
+#define REG_TS_EVENT_3_SEC		0x057C
+#define REG_TS_EVENT_3_SUB_NANOSEC	0x0580
+
+#define REG_TS_EVENT_4_NANOSEC		0x0584
+#define REG_TS_EVENT_4_SEC		0x0588
+#define REG_TS_EVENT_4_SUB_NANOSEC	0x058C
+
+#define REG_TS_EVENT_5_NANOSEC		0x0590
+#define REG_TS_EVENT_5_SEC		0x0594
+#define REG_TS_EVENT_5_SUB_NANOSEC	0x0598
+
+#define REG_TS_EVENT_6_NANOSEC		0x059C
+#define REG_TS_EVENT_6_SEC		0x05A0
+#define REG_TS_EVENT_6_SUB_NANOSEC	0x05A4
+
+#define REG_TS_EVENT_7_NANOSEC		0x05A8
+#define REG_TS_EVENT_7_SEC		0x05AC
+#define REG_TS_EVENT_7_SUB_NANOSEC	0x05B0
+
+#define TS_EVENT_EDGE_M			0x1
+#define TS_EVENT_EDGE_S			30
+#define TS_EVENT_NANOSEC_M		(BIT(30) - 1)
+
+#define TS_EVENT_SUB_NANOSEC_M		0x7
+
+#define TS_EVENT_SAMPLE			\
+	(REG_TS_EVENT_1_NANOSEC - REG_TS_EVENT_0_NANOSEC)
+
+#define PORT_CTRL_ADDR(port, addr)	((addr) | (((port) + 1) << 12))
+
+#define REG_GLOBAL_RR_INDEX__1		0x0600
+
+/* DLR */
+#define REG_DLR_SRC_PORT__4		0x0604
+
+#define DLR_SRC_PORT_UNICAST		BIT(31)
+#define DLR_SRC_PORT_M			0x3
+#define DLR_SRC_PORT_BOTH		0
+#define DLR_SRC_PORT_EACH		1
+
+#define REG_DLR_IP_ADDR__4		0x0608
+
+#define REG_DLR_CTRL__1			0x0610
+
+#define DLR_RESET_SEQ_ID		BIT(3)
+#define DLR_BACKUP_AUTO_ON		BIT(2)
+#define DLR_BEACON_TX_ENABLE		BIT(1)
+#define DLR_ASSIST_ENABLE		BIT(0)
+
+#define REG_DLR_STATE__1		0x0611
+
+#define DLR_NODE_STATE_M		0x3
+#define DLR_NODE_STATE_S		1
+#define DLR_NODE_STATE_IDLE		0
+#define DLR_NODE_STATE_FAULT		1
+#define DLR_NODE_STATE_NORMAL		2
+#define DLR_RING_STATE_FAULT		0
+#define DLR_RING_STATE_NORMAL		1
+
+#define REG_DLR_PRECEDENCE__1		0x0612
+
+#define REG_DLR_BEACON_INTERVAL__4	0x0614
+
+#define REG_DLR_BEACON_TIMEOUT__4	0x0618
+
+#define REG_DLR_TIMEOUT_WINDOW__4	0x061C
+
+#define DLR_TIMEOUT_WINDOW_M		(BIT(22) - 1)
+
+#define REG_DLR_VLAN_ID__2		0x0620
+
+#define DLR_VLAN_ID_M			(BIT(12) - 1)
+
+#define REG_DLR_DEST_ADDR_0		0x0622
+#define REG_DLR_DEST_ADDR_1		0x0623
+#define REG_DLR_DEST_ADDR_2		0x0624
+#define REG_DLR_DEST_ADDR_3		0x0625
+#define REG_DLR_DEST_ADDR_4		0x0626
+#define REG_DLR_DEST_ADDR_5		0x0627
+
+#define REG_DLR_PORT_MAP__4		0x0628
+
+#define REG_DLR_CLASS__1		0x062C
+
+#define DLR_FRAME_QID_M			0x3
+
+/* HSR */
+#define REG_HSR_PORT_MAP__4		0x0640
+
+#define REG_HSR_ALU_CTRL_0__1		0x0644
+
+#define HSR_DUPLICATE_DISCARD		BIT(7)
+#define HSR_NODE_UNICAST		BIT(6)
+#define HSR_AGE_CNT_DEFAULT_M		0x7
+#define HSR_AGE_CNT_DEFAULT_S		3
+#define HSR_LEARN_MCAST_DISABLE		BIT(2)
+#define HSR_HASH_OPTION_M		0x3
+#define HSR_HASH_DISABLE		0
+#define HSR_HASH_UPPER_BITS		1
+#define HSR_HASH_LOWER_BITS		2
+#define HSR_HASH_XOR_BOTH_BITS		3
+
+#define REG_HSR_ALU_CTRL_1__1		0x0645
+
+#define HSR_LEARN_UCAST_DISABLE		BIT(7)
+#define HSR_FLUSH_TABLE			BIT(5)
+#define HSR_PROC_MCAST_SRC		BIT(3)
+#define HSR_AGING_ENABLE		BIT(2)
+
+#define REG_HSR_ALU_CTRL_2__2		0x0646
+
+#define REG_HSR_ALU_AGE_PERIOD__4	0x0648
+
+#define REG_HSR_ALU_INT_STATUS__1	0x064C
+#define REG_HSR_ALU_INT_MASK__1		0x064D
+
+#define HSR_WINDOW_OVERFLOW_INT		BIT(3)
+#define HSR_LEARN_FAIL_INT		BIT(2)
+#define HSR_ALMOST_FULL_INT		BIT(1)
+#define HSR_WRITE_FAIL_INT		BIT(0)
+
+#define REG_HSR_ALU_ENTRY_0__2		0x0650
+
+#define HSR_ENTRY_INDEX_M		(BIT(10) - 1)
+#define HSR_FAIL_INDEX_M		(BIT(8) - 1)
+
+#define REG_HSR_ALU_ENTRY_1__2		0x0652
+
+#define HSR_FAIL_LEARN_INDEX_M		(BIT(8) - 1)
+
+#define REG_HSR_ALU_ENTRY_3__2		0x0654
+
+#define HSR_CPU_ACCESS_ENTRY_INDEX_M	(BIT(8) - 1)
+
+/* 0 - Operation */
+#define REG_PORT_DEFAULT_VID		0x0000
+
+#define REG_PORT_CUSTOM_VID		0x0002
+#define REG_PORT_AVB_SR_1_VID		0x0004
+#define REG_PORT_AVB_SR_2_VID		0x0006
+
+#define REG_PORT_AVB_SR_1_TYPE		0x0008
+#define REG_PORT_AVB_SR_2_TYPE		0x000A
+
+#define REG_PORT_PME_STATUS		0x0013
+#define REG_PORT_PME_CTRL		0x0017
+
+#define PME_WOL_MAGICPKT		BIT(2)
+#define PME_WOL_LINKUP			BIT(1)
+#define PME_WOL_ENERGY			BIT(0)
+
+#define REG_PORT_INT_STATUS		0x001B
+#define REG_PORT_INT_MASK		0x001F
+
+#define PORT_SGMII_INT			BIT(3)
+#define PORT_PTP_INT			BIT(2)
+#define PORT_PHY_INT			BIT(1)
+#define PORT_ACL_INT			BIT(0)
+
+#define PORT_INT_MASK			\
+	(PORT_SGMII_INT | PORT_PTP_INT | PORT_PHY_INT | PORT_ACL_INT)
+
+#define REG_PORT_CTRL_0			0x0020
+
+#define PORT_MAC_LOOPBACK		BIT(7)
+#define PORT_FORCE_TX_FLOW_CTRL		BIT(4)
+#define PORT_FORCE_RX_FLOW_CTRL		BIT(3)
+#define PORT_TAIL_TAG_ENABLE		BIT(2)
+#define PORT_QUEUE_SPLIT_ENABLE		0x3
+
+#define REG_PORT_CTRL_1			0x0021
+
+#define PORT_SRP_ENABLE			0x3
+
+#define REG_PORT_STATUS_0		0x0030
+
+#define PORT_INTF_SPEED_M		0x3
+#define PORT_INTF_SPEED_S		3
+#define PORT_INTF_FULL_DUPLEX		BIT(2)
+#define PORT_TX_FLOW_CTRL		BIT(1)
+#define PORT_RX_FLOW_CTRL		BIT(0)
+
+#define REG_PORT_STATUS_1		0x0034
+
+/* 1 - PHY */
+#define REG_PORT_PHY_CTRL		0x0100
+
+#define PORT_PHY_RESET			BIT(15)
+#define PORT_PHY_LOOPBACK		BIT(14)
+#define PORT_SPEED_100MBIT		BIT(13)
+#define PORT_AUTO_NEG_ENABLE		BIT(12)
+#define PORT_POWER_DOWN			BIT(11)
+#define PORT_ISOLATE			BIT(10)
+#define PORT_AUTO_NEG_RESTART		BIT(9)
+#define PORT_FULL_DUPLEX		BIT(8)
+#define PORT_COLLISION_TEST		BIT(7)
+#define PORT_SPEED_1000MBIT		BIT(6)
+
+#define REG_PORT_PHY_STATUS		0x0102
+
+#define PORT_100BT4_CAPABLE		BIT(15)
+#define PORT_100BTX_FD_CAPABLE		BIT(14)
+#define PORT_100BTX_CAPABLE		BIT(13)
+#define PORT_10BT_FD_CAPABLE		BIT(12)
+#define PORT_10BT_CAPABLE		BIT(11)
+#define PORT_EXTENDED_STATUS		BIT(8)
+#define PORT_MII_SUPPRESS_CAPABLE	BIT(6)
+#define PORT_AUTO_NEG_ACKNOWLEDGE	BIT(5)
+#define PORT_REMOTE_FAULT		BIT(4)
+#define PORT_AUTO_NEG_CAPABLE		BIT(3)
+#define PORT_LINK_STATUS		BIT(2)
+#define PORT_JABBER_DETECT		BIT(1)
+#define PORT_EXTENDED_CAPABILITY	BIT(0)
+
+#define REG_PORT_PHY_ID_HI		0x0104
+#define REG_PORT_PHY_ID_LO		0x0106
+
+#define KSZ9477_ID_HI			0x0022
+#define KSZ9477_ID_LO			0x1622
+
+#define REG_PORT_PHY_AUTO_NEGOTIATION	0x0108
+
+#define PORT_AUTO_NEG_NEXT_PAGE		BIT(15)
+#define PORT_AUTO_NEG_REMOTE_FAULT	BIT(13)
+#define PORT_AUTO_NEG_ASYM_PAUSE	BIT(11)
+#define PORT_AUTO_NEG_SYM_PAUSE		BIT(10)
+#define PORT_AUTO_NEG_100BT4		BIT(9)
+#define PORT_AUTO_NEG_100BTX_FD		BIT(8)
+#define PORT_AUTO_NEG_100BTX		BIT(7)
+#define PORT_AUTO_NEG_10BT_FD		BIT(6)
+#define PORT_AUTO_NEG_10BT		BIT(5)
+#define PORT_AUTO_NEG_SELECTOR		0x001F
+#define PORT_AUTO_NEG_802_3		0x0001
+
+#define PORT_AUTO_NEG_PAUSE		\
+	(PORT_AUTO_NEG_ASYM_PAUSE | PORT_AUTO_NEG_SYM_PAUSE)
+
+#define REG_PORT_PHY_REMOTE_CAPABILITY	0x010A
+
+#define PORT_REMOTE_NEXT_PAGE		BIT(15)
+#define PORT_REMOTE_ACKNOWLEDGE		BIT(14)
+#define PORT_REMOTE_REMOTE_FAULT	BIT(13)
+#define PORT_REMOTE_ASYM_PAUSE		BIT(11)
+#define PORT_REMOTE_SYM_PAUSE		BIT(10)
+#define PORT_REMOTE_100BTX_FD		BIT(8)
+#define PORT_REMOTE_100BTX		BIT(7)
+#define PORT_REMOTE_10BT_FD		BIT(6)
+#define PORT_REMOTE_10BT		BIT(5)
+
+#define REG_PORT_PHY_1000_CTRL		0x0112
+
+#define PORT_AUTO_NEG_MANUAL		BIT(12)
+#define PORT_AUTO_NEG_MASTER		BIT(11)
+#define PORT_AUTO_NEG_MASTER_PREFERRED	BIT(10)
+#define PORT_AUTO_NEG_1000BT_FD		BIT(9)
+#define PORT_AUTO_NEG_1000BT		BIT(8)
+
+#define REG_PORT_PHY_1000_STATUS	0x0114
+
+#define PORT_MASTER_FAULT		BIT(15)
+#define PORT_LOCAL_MASTER		BIT(14)
+#define PORT_LOCAL_RX_OK		BIT(13)
+#define PORT_REMOTE_RX_OK		BIT(12)
+#define PORT_REMOTE_1000BT_FD		BIT(11)
+#define PORT_REMOTE_1000BT		BIT(10)
+#define PORT_REMOTE_IDLE_CNT_M		0x0F
+
+#define PORT_PHY_1000_STATIC_STATUS	\
+	(PORT_LOCAL_RX_OK |		\
+	PORT_REMOTE_RX_OK |		\
+	PORT_REMOTE_1000BT_FD |		\
+	PORT_REMOTE_1000BT)
+
+#define REG_PORT_PHY_MMD_SETUP		0x011A
+
+#define PORT_MMD_OP_MODE_M		0x3
+#define PORT_MMD_OP_MODE_S		14
+#define PORT_MMD_OP_INDEX		0
+#define PORT_MMD_OP_DATA_NO_INCR	1
+#define PORT_MMD_OP_DATA_INCR_RW	2
+#define PORT_MMD_OP_DATA_INCR_W		3
+#define PORT_MMD_DEVICE_ID_M		0x1F
+
+#define MMD_SETUP(mode, dev)		\
+	(((u16)(mode) << PORT_MMD_OP_MODE_S) | (dev))
+
+#define REG_PORT_PHY_MMD_INDEX_DATA	0x011C
+
+#define MMD_DEVICE_ID_DSP		1
+
+#define MMD_DSP_SQI_CHAN_A		0xAC
+#define MMD_DSP_SQI_CHAN_B		0xAD
+#define MMD_DSP_SQI_CHAN_C		0xAE
+#define MMD_DSP_SQI_CHAN_D		0xAF
+
+#define DSP_SQI_ERR_DETECTED		BIT(15)
+#define DSP_SQI_AVG_ERR			0x7FFF
+
+#define MMD_DEVICE_ID_COMMON		2
+
+#define MMD_DEVICE_ID_EEE_ADV		7
+
+#define MMD_EEE_ADV			0x3C
+#define EEE_ADV_100MBIT			BIT(1)
+#define EEE_ADV_1GBIT			BIT(2)
+
+#define MMD_EEE_LP_ADV			0x3D
+#define MMD_EEE_MSG_CODE		0x3F
+
+#define MMD_DEVICE_ID_AFED		0x1C
+
+#define REG_PORT_PHY_EXTENDED_STATUS	0x011E
+
+#define PORT_100BTX_FD_ABLE		BIT(15)
+#define PORT_100BTX_ABLE		BIT(14)
+#define PORT_10BT_FD_ABLE		BIT(13)
+#define PORT_10BT_ABLE			BIT(12)
+
+#define REG_PORT_SGMII_ADDR__4		0x0200
+#define PORT_SGMII_AUTO_INCR		BIT(23)
+#define PORT_SGMII_DEVICE_ID_M		0x1F
+#define PORT_SGMII_DEVICE_ID_S		16
+#define PORT_SGMII_ADDR_M		(BIT(21) - 1)
+
+#define REG_PORT_SGMII_DATA__4		0x0204
+#define PORT_SGMII_DATA_M		(BIT(16) - 1)
+
+#define MMD_DEVICE_ID_PMA		0x01
+#define MMD_DEVICE_ID_PCS		0x03
+#define MMD_DEVICE_ID_PHY_XS		0x04
+#define MMD_DEVICE_ID_DTE_XS		0x05
+#define MMD_DEVICE_ID_AN		0x07
+#define MMD_DEVICE_ID_VENDOR_CTRL	0x1E
+#define MMD_DEVICE_ID_VENDOR_MII	0x1F
+
+#define SR_MII				MMD_DEVICE_ID_VENDOR_MII
+
+#define MMD_SR_MII_CTRL			0x0000
+
+#define SR_MII_RESET			BIT(15)
+#define SR_MII_LOOPBACK			BIT(14)
+#define SR_MII_SPEED_100MBIT		BIT(13)
+#define SR_MII_AUTO_NEG_ENABLE		BIT(12)
+#define SR_MII_POWER_DOWN		BIT(11)
+#define SR_MII_AUTO_NEG_RESTART		BIT(9)
+#define SR_MII_FULL_DUPLEX		BIT(8)
+#define SR_MII_SPEED_1000MBIT		BIT(6)
+
+#define MMD_SR_MII_STATUS		0x0001
+#define MMD_SR_MII_ID_1			0x0002
+#define MMD_SR_MII_ID_2			0x0003
+#define MMD_SR_MII_AUTO_NEGOTIATION	0x0004
+
+#define SR_MII_AUTO_NEG_NEXT_PAGE	BIT(15)
+#define SR_MII_AUTO_NEG_REMOTE_FAULT_M	0x3
+#define SR_MII_AUTO_NEG_REMOTE_FAULT_S	12
+#define SR_MII_AUTO_NEG_NO_ERROR	0
+#define SR_MII_AUTO_NEG_OFFLINE		1
+#define SR_MII_AUTO_NEG_LINK_FAILURE	2
+#define SR_MII_AUTO_NEG_ERROR		3
+#define SR_MII_AUTO_NEG_PAUSE_M		0x3
+#define SR_MII_AUTO_NEG_PAUSE_S		7
+#define SR_MII_AUTO_NEG_NO_PAUSE	0
+#define SR_MII_AUTO_NEG_ASYM_PAUSE_TX	1
+#define SR_MII_AUTO_NEG_SYM_PAUSE	2
+#define SR_MII_AUTO_NEG_ASYM_PAUSE_RX	3
+#define SR_MII_AUTO_NEG_HALF_DUPLEX	BIT(6)
+#define SR_MII_AUTO_NEG_FULL_DUPLEX	BIT(5)
+
+#define MMD_SR_MII_REMOTE_CAPABILITY	0x0005
+#define MMD_SR_MII_AUTO_NEG_EXP		0x0006
+#define MMD_SR_MII_AUTO_NEG_EXT		0x000F
+
+#define MMD_SR_MII_DIGITAL_CTRL_1	0x8000
+
+#define MMD_SR_MII_AUTO_NEG_CTRL	0x8001
+
+#define SR_MII_8_BIT			BIT(8)
+#define SR_MII_SGMII_LINK_UP		BIT(4)
+#define SR_MII_TX_CFG_PHY_MASTER	BIT(3)
+#define SR_MII_PCS_MODE_M		0x3
+#define SR_MII_PCS_MODE_S		1
+#define SR_MII_PCS_SGMII		2
+#define SR_MII_AUTO_NEG_COMPLETE_INTR	BIT(0)
+
+#define MMD_SR_MII_AUTO_NEG_STATUS	0x8002
+
+#define SR_MII_STAT_LINK_UP		BIT(4)
+#define SR_MII_STAT_M			0x3
+#define SR_MII_STAT_S			2
+#define SR_MII_STAT_10_MBPS		0
+#define SR_MII_STAT_100_MBPS		1
+#define SR_MII_STAT_1000_MBPS		2
+#define SR_MII_STAT_FULL_DUPLEX		BIT(1)
+
+#define MMD_SR_MII_PHY_CTRL		0x80A0
+
+#define SR_MII_PHY_LANE_SEL_M		0xF
+#define SR_MII_PHY_LANE_SEL_S		8
+#define SR_MII_PHY_WRITE		BIT(1)
+#define SR_MII_PHY_START_BUSY		BIT(0)
+
+#define MMD_SR_MII_PHY_ADDR		0x80A1
+
+#define SR_MII_PHY_ADDR_M		(BIT(16) - 1)
+
+#define MMD_SR_MII_PHY_DATA		0x80A2
+
+#define SR_MII_PHY_DATA_M		(BIT(16) - 1)
+
+#define SR_MII_PHY_JTAG_CHIP_ID_HI	0x000C
+#define SR_MII_PHY_JTAG_CHIP_ID_LO	0x000D
+
+#define REG_PORT_PHY_REMOTE_LB_LED	0x0122
+
+#define PORT_REMOTE_LOOPBACK		BIT(8)
+#define PORT_LED_SELECT			(3 << 6)
+#define PORT_LED_CTRL			(3 << 4)
+#define PORT_LED_CTRL_TEST		BIT(3)
+#define PORT_10BT_PREAMBLE		BIT(2)
+#define PORT_LINK_MD_10BT_ENABLE	BIT(1)
+#define PORT_LINK_MD_PASS		BIT(0)
+
+#define REG_PORT_PHY_LINK_MD		0x0124
+
+#define PORT_START_CABLE_DIAG		BIT(15)
+#define PORT_TX_DISABLE			BIT(14)
+#define PORT_CABLE_DIAG_PAIR_M		0x3
+#define PORT_CABLE_DIAG_PAIR_S		12
+#define PORT_CABLE_DIAG_SELECT_M	0x3
+#define PORT_CABLE_DIAG_SELECT_S	10
+#define PORT_CABLE_DIAG_RESULT_M	0x3
+#define PORT_CABLE_DIAG_RESULT_S	8
+#define PORT_CABLE_STAT_NORMAL		0
+#define PORT_CABLE_STAT_OPEN		1
+#define PORT_CABLE_STAT_SHORT		2
+#define PORT_CABLE_STAT_FAILED		3
+#define PORT_CABLE_FAULT_COUNTER	0x00FF
+
+#define REG_PORT_PHY_PMA_STATUS		0x0126
+
+#define PORT_1000_LINK_GOOD		BIT(1)
+#define PORT_100_LINK_GOOD		BIT(0)
+
+#define REG_PORT_PHY_DIGITAL_STATUS	0x0128
+
+#define PORT_LINK_DETECT		BIT(14)
+#define PORT_SIGNAL_DETECT		BIT(13)
+#define PORT_PHY_STAT_MDI		BIT(12)
+#define PORT_PHY_STAT_MASTER		BIT(11)
+
+#define REG_PORT_PHY_RXER_COUNTER	0x012A
+
+#define REG_PORT_PHY_INT_ENABLE		0x0136
+#define REG_PORT_PHY_INT_STATUS		0x0137
+
+#define JABBER_INT			BIT(7)
+#define RX_ERR_INT			BIT(6)
+#define PAGE_RX_INT			BIT(5)
+#define PARALLEL_DETECT_FAULT_INT	BIT(4)
+#define LINK_PARTNER_ACK_INT		BIT(3)
+#define LINK_DOWN_INT			BIT(2)
+#define REMOTE_FAULT_INT		BIT(1)
+#define LINK_UP_INT			BIT(0)
+
+#define REG_PORT_PHY_DIGITAL_DEBUG_1	0x0138
+
+#define PORT_REG_CLK_SPEED_25_MHZ	BIT(14)
+#define PORT_PHY_FORCE_MDI		BIT(7)
+#define PORT_PHY_AUTO_MDIX_DISABLE	BIT(6)
+
+/* Same as PORT_PHY_LOOPBACK */
+#define PORT_PHY_PCS_LOOPBACK		BIT(0)
+
+#define REG_PORT_PHY_DIGITAL_DEBUG_2	0x013A
+
+#define REG_PORT_PHY_DIGITAL_DEBUG_3	0x013C
+
+#define PORT_100BT_FIXED_LATENCY	BIT(15)
+
+#define REG_PORT_PHY_PHY_CTRL		0x013E
+
+#define PORT_INT_PIN_HIGH		BIT(14)
+#define PORT_ENABLE_JABBER		BIT(9)
+#define PORT_STAT_SPEED_1000MBIT	BIT(6)
+#define PORT_STAT_SPEED_100MBIT		BIT(5)
+#define PORT_STAT_SPEED_10MBIT		BIT(4)
+#define PORT_STAT_FULL_DUPLEX		BIT(3)
+
+/* Same as PORT_PHY_STAT_MASTER */
+#define PORT_STAT_MASTER		BIT(2)
+#define PORT_RESET			BIT(1)
+#define PORT_LINK_STATUS_FAIL		BIT(0)
+
+/* 3 - xMII */
+#define REG_PORT_XMII_CTRL_0		0x0300
+
+#define PORT_SGMII_SEL			BIT(7)
+#define PORT_MII_FULL_DUPLEX		BIT(6)
+#define PORT_MII_100MBIT		BIT(4)
+#define PORT_GRXC_ENABLE		BIT(0)
+
+#define REG_PORT_XMII_CTRL_1		0x0301
+
+#define PORT_RMII_CLK_SEL		BIT(7)
+/* S1 */
+#define PORT_MII_1000MBIT_S1		BIT(6)
+/* S2 */
+#define PORT_MII_NOT_1GBIT		BIT(6)
+#define PORT_MII_SEL_EDGE		BIT(5)
+#define PORT_RGMII_ID_IG_ENABLE		BIT(4)
+#define PORT_RGMII_ID_EG_ENABLE		BIT(3)
+#define PORT_MII_MAC_MODE		BIT(2)
+#define PORT_MII_SEL_M			0x3
+/* S1 */
+#define PORT_MII_SEL_S1			0x0
+#define PORT_RMII_SEL_S1		0x1
+#define PORT_GMII_SEL_S1		0x2
+#define PORT_RGMII_SEL_S1		0x3
+/* S2 */
+#define PORT_RGMII_SEL			0x0
+#define PORT_RMII_SEL			0x1
+#define PORT_GMII_SEL			0x2
+#define PORT_MII_SEL			0x3
+
+/* 4 - MAC */
+#define REG_PORT_MAC_CTRL_0		0x0400
+
+#define PORT_BROADCAST_STORM		BIT(1)
+#define PORT_JUMBO_FRAME		BIT(0)
+
+#define REG_PORT_MAC_CTRL_1		0x0401
+
+#define PORT_BACK_PRESSURE		BIT(3)
+#define PORT_PASS_ALL			BIT(0)
+
+#define REG_PORT_MAC_CTRL_2		0x0402
+
+#define PORT_100BT_EEE_DISABLE		BIT(7)
+#define PORT_1000BT_EEE_DISABLE		BIT(6)
+
+#define REG_PORT_MAC_IN_RATE_LIMIT	0x0403
+
+#define PORT_IN_PORT_BASED_S		6
+#define PORT_RATE_PACKET_BASED_S	5
+#define PORT_IN_FLOW_CTRL_S		4
+#define PORT_COUNT_IFG_S		1
+#define PORT_COUNT_PREAMBLE_S		0
+#define PORT_IN_PORT_BASED		BIT(6)
+#define PORT_IN_PACKET_BASED		BIT(5)
+#define PORT_IN_FLOW_CTRL		BIT(4)
+#define PORT_IN_LIMIT_MODE_M		0x3
+#define PORT_IN_LIMIT_MODE_S		2
+#define PORT_IN_ALL			0
+#define PORT_IN_UNICAST			1
+#define PORT_IN_MULTICAST		2
+#define PORT_IN_BROADCAST		3
+#define PORT_COUNT_IFG			BIT(1)
+#define PORT_COUNT_PREAMBLE		BIT(0)
+
+#define REG_PORT_IN_RATE_0		0x0410
+#define REG_PORT_IN_RATE_1		0x0411
+#define REG_PORT_IN_RATE_2		0x0412
+#define REG_PORT_IN_RATE_3		0x0413
+#define REG_PORT_IN_RATE_4		0x0414
+#define REG_PORT_IN_RATE_5		0x0415
+#define REG_PORT_IN_RATE_6		0x0416
+#define REG_PORT_IN_RATE_7		0x0417
+
+#define REG_PORT_OUT_RATE_0		0x0420
+#define REG_PORT_OUT_RATE_1		0x0421
+#define REG_PORT_OUT_RATE_2		0x0422
+#define REG_PORT_OUT_RATE_3		0x0423
+
+#define PORT_RATE_LIMIT_M		(BIT(7) - 1)
+
+/* 5 - MIB Counters */
+#define REG_PORT_MIB_CTRL_STAT__4	0x0500
+
+#define MIB_COUNTER_OVERFLOW		BIT(31)
+#define MIB_COUNTER_VALID		BIT(30)
+#define MIB_COUNTER_READ		BIT(25)
+#define MIB_COUNTER_FLUSH_FREEZE	BIT(24)
+#define MIB_COUNTER_INDEX_M		(BIT(8) - 1)
+#define MIB_COUNTER_INDEX_S		16
+#define MIB_COUNTER_DATA_HI_M		0xF
+
+#define REG_PORT_MIB_DATA		0x0504
+
+/* 6 - ACL */
+#define REG_PORT_ACL_0			0x0600
+
+#define ACL_FIRST_RULE_M		0xF
+
+#define REG_PORT_ACL_1			0x0601
+
+#define ACL_MODE_M			0x3
+#define ACL_MODE_S			4
+#define ACL_MODE_DISABLE		0
+#define ACL_MODE_LAYER_2		1
+#define ACL_MODE_LAYER_3		2
+#define ACL_MODE_LAYER_4		3
+#define ACL_ENABLE_M			0x3
+#define ACL_ENABLE_S			2
+#define ACL_ENABLE_2_COUNT		0
+#define ACL_ENABLE_2_TYPE		1
+#define ACL_ENABLE_2_MAC		2
+#define ACL_ENABLE_2_BOTH		3
+#define ACL_ENABLE_3_IP			1
+#define ACL_ENABLE_3_SRC_DST_COMP	2
+#define ACL_ENABLE_4_PROTOCOL		0
+#define ACL_ENABLE_4_TCP_PORT_COMP	1
+#define ACL_ENABLE_4_UDP_PORT_COMP	2
+#define ACL_ENABLE_4_TCP_SEQN_COMP	3
+#define ACL_SRC				BIT(1)
+#define ACL_EQUAL			BIT(0)
+
+#define REG_PORT_ACL_2			0x0602
+#define REG_PORT_ACL_3			0x0603
+
+#define ACL_MAX_PORT			0xFFFF
+
+#define REG_PORT_ACL_4			0x0604
+#define REG_PORT_ACL_5			0x0605
+
+#define ACL_MIN_PORT			0xFFFF
+#define ACL_IP_ADDR			0xFFFFFFFF
+#define ACL_TCP_SEQNUM			0xFFFFFFFF
+
+#define REG_PORT_ACL_6			0x0606
+
+#define ACL_RESERVED			0xF8
+#define ACL_PORT_MODE_M			0x3
+#define ACL_PORT_MODE_S			1
+#define ACL_PORT_MODE_DISABLE		0
+#define ACL_PORT_MODE_EITHER		1
+#define ACL_PORT_MODE_IN_RANGE		2
+#define ACL_PORT_MODE_OUT_OF_RANGE	3
+
+#define REG_PORT_ACL_7			0x0607
+
+#define ACL_TCP_FLAG_ENABLE		BIT(0)
+
+#define REG_PORT_ACL_8			0x0608
+
+#define ACL_TCP_FLAG_M			0xFF
+
+#define REG_PORT_ACL_9			0x0609
+
+#define ACL_TCP_FLAG			0xFF
+#define ACL_ETH_TYPE			0xFFFF
+#define ACL_IP_M			0xFFFFFFFF
+
+#define REG_PORT_ACL_A			0x060A
+
+#define ACL_PRIO_MODE_M			0x3
+#define ACL_PRIO_MODE_S			6
+#define ACL_PRIO_MODE_DISABLE		0
+#define ACL_PRIO_MODE_HIGHER		1
+#define ACL_PRIO_MODE_LOWER		2
+#define ACL_PRIO_MODE_REPLACE		3
+#define ACL_PRIO_M			KS_PRIO_M
+#define ACL_PRIO_S			3
+#define ACL_VLAN_PRIO_REPLACE		BIT(2)
+#define ACL_VLAN_PRIO_M			KS_PRIO_M
+#define ACL_VLAN_PRIO_HI_M		0x3
+
+#define REG_PORT_ACL_B			0x060B
+
+#define ACL_VLAN_PRIO_LO_M		0x8
+#define ACL_VLAN_PRIO_S			7
+#define ACL_MAP_MODE_M			0x3
+#define ACL_MAP_MODE_S			5
+#define ACL_MAP_MODE_DISABLE		0
+#define ACL_MAP_MODE_OR			1
+#define ACL_MAP_MODE_AND		2
+#define ACL_MAP_MODE_REPLACE		3
+
+#define ACL_CNT_M			(BIT(11) - 1)
+#define ACL_CNT_S			5
+
+#define REG_PORT_ACL_C			0x060C
+
+#define REG_PORT_ACL_D			0x060D
+#define ACL_MSEC_UNIT			BIT(6)
+#define ACL_INTR_MODE			BIT(5)
+#define ACL_PORT_MAP			0x7F
+
+#define REG_PORT_ACL_E			0x060E
+#define REG_PORT_ACL_F			0x060F
+
+#define REG_PORT_ACL_BYTE_EN_MSB	0x0610
+#define REG_PORT_ACL_BYTE_EN_LSB	0x0611
+
+#define ACL_ACTION_START		0xA
+#define ACL_ACTION_LEN			4
+#define ACL_INTR_CNT_START		0xD
+#define ACL_RULESET_START		0xE
+#define ACL_RULESET_LEN			2
+#define ACL_TABLE_LEN			16
+
+#define ACL_ACTION_ENABLE		0x003C
+#define ACL_MATCH_ENABLE		0x7FC3
+#define ACL_RULESET_ENABLE		0x8003
+#define ACL_BYTE_ENABLE			0xFFFF
+
+#define REG_PORT_ACL_CTRL_0		0x0612
+
+#define PORT_ACL_WRITE_DONE		BIT(6)
+#define PORT_ACL_READ_DONE		BIT(5)
+#define PORT_ACL_WRITE			BIT(4)
+#define PORT_ACL_INDEX_M		0xF
+
+#define REG_PORT_ACL_CTRL_1		0x0613
+
+/* 8 - Classification and Policing */
+#define REG_PORT_MRI_MIRROR_CTRL	0x0800
+
+#define PORT_MIRROR_RX			BIT(6)
+#define PORT_MIRROR_TX			BIT(5)
+#define PORT_MIRROR_SNIFFER		BIT(1)
+
+#define REG_PORT_MRI_PRIO_CTRL		0x0801
+
+#define PORT_HIGHEST_PRIO		BIT(7)
+#define PORT_OR_PRIO			BIT(6)
+#define PORT_MAC_PRIO_ENABLE		BIT(4)
+#define PORT_VLAN_PRIO_ENABLE		BIT(3)
+#define PORT_802_1P_PRIO_ENABLE		BIT(2)
+#define PORT_DIFFSERV_PRIO_ENABLE	BIT(1)
+#define PORT_ACL_PRIO_ENABLE		BIT(0)
+
+#define REG_PORT_MRI_MAC_CTRL		0x0802
+
+#define PORT_USER_PRIO_CEILING		BIT(7)
+#define PORT_DROP_NON_VLAN		BIT(4)
+#define PORT_DROP_TAG			BIT(3)
+#define PORT_BASED_PRIO_M		KS_PRIO_M
+#define PORT_BASED_PRIO_S		0
+
+#define REG_PORT_MRI_AUTHEN_CTRL	0x0803
+
+#define PORT_ACL_ENABLE			BIT(2)
+#define PORT_AUTHEN_MODE		0x3
+#define PORT_AUTHEN_PASS		0
+#define PORT_AUTHEN_BLOCK		1
+#define PORT_AUTHEN_TRAP		2
+
+#define REG_PORT_MRI_INDEX__4		0x0804
+
+#define MRI_INDEX_P_M			0x7
+#define MRI_INDEX_P_S			16
+#define MRI_INDEX_Q_M			0x3
+#define MRI_INDEX_Q_S			0
+
+#define REG_PORT_MRI_TC_MAP__4		0x0808
+
+#define PORT_TC_MAP_M			0xf
+#define PORT_TC_MAP_S			4
+
+#define REG_PORT_MRI_POLICE_CTRL__4	0x080C
+
+#define POLICE_DROP_ALL			BIT(10)
+#define POLICE_PACKET_TYPE_M		0x3
+#define POLICE_PACKET_TYPE_S		8
+#define POLICE_PACKET_DROPPED		0
+#define POLICE_PACKET_GREEN		1
+#define POLICE_PACKET_YELLOW		2
+#define POLICE_PACKET_RED		3
+#define PORT_BASED_POLICING		BIT(7)
+#define NON_DSCP_COLOR_M		0x3
+#define NON_DSCP_COLOR_S		5
+#define COLOR_MARK_ENABLE		BIT(4)
+#define COLOR_REMAP_ENABLE		BIT(3)
+#define POLICE_DROP_SRP			BIT(2)
+#define POLICE_COLOR_NOT_AWARE		BIT(1)
+#define POLICE_ENABLE			BIT(0)
+
+#define REG_PORT_POLICE_COLOR_0__4	0x0810
+#define REG_PORT_POLICE_COLOR_1__4	0x0814
+#define REG_PORT_POLICE_COLOR_2__4	0x0818
+#define REG_PORT_POLICE_COLOR_3__4	0x081C
+
+#define POLICE_COLOR_MAP_S		2
+#define POLICE_COLOR_MAP_M		(BIT(POLICE_COLOR_MAP_S) - 1)
+
+#define REG_PORT_POLICE_RATE__4		0x0820
+
+#define POLICE_CIR_S			16
+#define POLICE_PIR_S			0
+
+#define REG_PORT_POLICE_BURST_SIZE__4	0x0824
+
+#define POLICE_BURST_SIZE_M		0x3FFF
+#define POLICE_CBS_S			16
+#define POLICE_PBS_S			0
+
+#define REG_PORT_WRED_PM_CTRL_0__4	0x0830
+
+#define WRED_PM_CTRL_M			(BIT(11) - 1)
+
+#define WRED_PM_MAX_THRESHOLD_S		16
+#define WRED_PM_MIN_THRESHOLD_S		0
+
+#define REG_PORT_WRED_PM_CTRL_1__4	0x0834
+
+#define WRED_PM_MULTIPLIER_S		16
+#define WRED_PM_AVG_QUEUE_SIZE_S	0
+
+#define REG_PORT_WRED_QUEUE_CTRL_0__4	0x0840
+#define REG_PORT_WRED_QUEUE_CTRL_1__4	0x0844
+
+#define REG_PORT_WRED_QUEUE_PMON__4	0x0848
+
+#define WRED_RANDOM_DROP_ENABLE		BIT(31)
+#define WRED_PMON_FLUSH			BIT(30)
+#define WRED_DROP_GYR_DISABLE		BIT(29)
+#define WRED_DROP_YR_DISABLE		BIT(28)
+#define WRED_DROP_R_DISABLE		BIT(27)
+#define WRED_DROP_ALL			BIT(26)
+#define WRED_PMON_M			(BIT(24) - 1)
+
+/* 9 - Shaping */
+
+#define REG_PORT_MTI_QUEUE_INDEX__4	0x0900
+
+#define REG_PORT_MTI_QUEUE_CTRL_0__4	0x0904
+
+#define MTI_PVID_REPLACE		BIT(0)
+
+#define REG_PORT_MTI_QUEUE_CTRL_0	0x0914
+
+#define MTI_SCHEDULE_MODE_M		0x3
+#define MTI_SCHEDULE_MODE_S		6
+#define MTI_SCHEDULE_STRICT_PRIO	0
+#define MTI_SCHEDULE_WRR		2
+#define MTI_SHAPING_M			0x3
+#define MTI_SHAPING_S			4
+#define MTI_SHAPING_OFF			0
+#define MTI_SHAPING_SRP			1
+#define MTI_SHAPING_TIME_AWARE		2
+
+#define REG_PORT_MTI_QUEUE_CTRL_1	0x0915
+
+#define MTI_TX_RATIO_M			(BIT(7) - 1)
+
+#define REG_PORT_MTI_QUEUE_CTRL_2__2	0x0916
+#define REG_PORT_MTI_HI_WATER_MARK	0x0916
+#define REG_PORT_MTI_QUEUE_CTRL_3__2	0x0918
+#define REG_PORT_MTI_LO_WATER_MARK	0x0918
+#define REG_PORT_MTI_QUEUE_CTRL_4__2	0x091A
+#define REG_PORT_MTI_CREDIT_INCREMENT	0x091A
+
+/* A - QM */
+
+#define REG_PORT_QM_CTRL__4		0x0A00
+
+#define PORT_QM_DROP_PRIO_M		0x3
+
+#define REG_PORT_VLAN_MEMBERSHIP__4	0x0A04
+
+#define REG_PORT_QM_QUEUE_INDEX__4	0x0A08
+
+#define PORT_QM_QUEUE_INDEX_S		24
+#define PORT_QM_BURST_SIZE_S		16
+#define PORT_QM_MIN_RESV_SPACE_M	(BIT(11) - 1)
+
+#define REG_PORT_QM_WATER_MARK__4	0x0A0C
+
+#define PORT_QM_HI_WATER_MARK_S		16
+#define PORT_QM_LO_WATER_MARK_S		0
+#define PORT_QM_WATER_MARK_M		(BIT(11) - 1)
+
+#define REG_PORT_QM_TX_CNT_0__4		0x0A10
+
+#define PORT_QM_TX_CNT_USED_S		0
+#define PORT_QM_TX_CNT_M		(BIT(11) - 1)
+
+#define REG_PORT_QM_TX_CNT_1__4		0x0A14
+
+#define PORT_QM_TX_CNT_CALCULATED_S	16
+#define PORT_QM_TX_CNT_AVAIL_S		0
+
+/* B - LUE */
+#define REG_PORT_LUE_CTRL		0x0B00
+
+#define PORT_VLAN_LOOKUP_VID_0		BIT(7)
+#define PORT_INGRESS_FILTER		BIT(6)
+#define PORT_DISCARD_NON_VID		BIT(5)
+#define PORT_MAC_BASED_802_1X		BIT(4)
+#define PORT_SRC_ADDR_FILTER		BIT(3)
+
+#define REG_PORT_LUE_MSTP_INDEX		0x0B01
+
+#define REG_PORT_LUE_MSTP_STATE		0x0B04
+
+#define PORT_TX_ENABLE			BIT(2)
+#define PORT_RX_ENABLE			BIT(1)
+#define PORT_LEARN_DISABLE		BIT(0)
+
+/* C - PTP */
+
+#define REG_PTP_PORT_RX_DELAY__2	0x0C00
+#define REG_PTP_PORT_TX_DELAY__2	0x0C02
+#define REG_PTP_PORT_ASYM_DELAY__2	0x0C04
+
+#define REG_PTP_PORT_XDELAY_TS		0x0C08
+#define REG_PTP_PORT_XDELAY_TS_H	0x0C08
+#define REG_PTP_PORT_XDELAY_TS_L	0x0C0A
+
+#define REG_PTP_PORT_SYNC_TS		0x0C0C
+#define REG_PTP_PORT_SYNC_TS_H		0x0C0C
+#define REG_PTP_PORT_SYNC_TS_L		0x0C0E
+
+#define REG_PTP_PORT_PDRESP_TS		0x0C10
+#define REG_PTP_PORT_PDRESP_TS_H	0x0C10
+#define REG_PTP_PORT_PDRESP_TS_L	0x0C12
+
+#define REG_PTP_PORT_TX_INT_STATUS__2	0x0C14
+#define REG_PTP_PORT_TX_INT_ENABLE__2	0x0C16
+
+#define PTP_PORT_SYNC_INT		BIT(15)
+#define PTP_PORT_XDELAY_REQ_INT		BIT(14)
+#define PTP_PORT_PDELAY_RESP_INT	BIT(13)
+
+#define REG_PTP_PORT_LINK_DELAY__4	0x0C18
+
+#define PRIO_QUEUES			4
+#define RX_PRIO_QUEUES			8
+
+#define KS_PRIO_IN_REG			2
+
+#define TOTAL_PORT_NUM			7
+
+#define KSZ9477_COUNTER_NUM		0x20
+#define TOTAL_KSZ9477_COUNTER_NUM	(KSZ9477_COUNTER_NUM + 2 + 2)
+
+#define SWITCH_COUNTER_NUM		KSZ9477_COUNTER_NUM
+#define TOTAL_SWITCH_COUNTER_NUM	TOTAL_KSZ9477_COUNTER_NUM
+
+#define P_BCAST_STORM_CTRL		REG_PORT_MAC_CTRL_0
+#define P_PRIO_CTRL			REG_PORT_MRI_PRIO_CTRL
+#define P_MIRROR_CTRL			REG_PORT_MRI_MIRROR_CTRL
+#define P_STP_CTRL			REG_PORT_LUE_MSTP_STATE
+#define P_PHY_CTRL			REG_PORT_PHY_CTRL
+#define P_NEG_RESTART_CTRL		REG_PORT_PHY_CTRL
+#define P_LINK_STATUS			REG_PORT_PHY_STATUS
+#define P_SPEED_STATUS			REG_PORT_PHY_PHY_CTRL
+#define P_RATE_LIMIT_CTRL		REG_PORT_MAC_IN_RATE_LIMIT
+
+#define S_LINK_AGING_CTRL		REG_SW_LUE_CTRL_1
+#define S_MIRROR_CTRL			REG_SW_MRI_CTRL_0
+#define S_REPLACE_VID_CTRL		REG_SW_MAC_CTRL_2
+#define S_802_1P_PRIO_CTRL		REG_SW_MAC_802_1P_MAP_0
+#define S_TOS_PRIO_CTRL			REG_SW_MAC_TOS_PRIO_0
+#define S_FLUSH_TABLE_CTRL		REG_SW_LUE_CTRL_1
+
+#define SW_FLUSH_DYN_MAC_TABLE		SW_FLUSH_MSTP_TABLE
+
+#define MAX_TIMESTAMP_UNIT		2
+#define MAX_TRIG_UNIT			3
+#define MAX_TIMESTAMP_EVENT_UNIT	8
+#define MAX_GPIO			4
+
+#define PTP_TRIG_UNIT_M			(BIT(MAX_TRIG_UNIT) - 1)
+#define PTP_TS_UNIT_M			(BIT(MAX_TIMESTAMP_UNIT) - 1)
+
+/* Driver set switch broadcast storm protection at 10% rate. */
+#define BROADCAST_STORM_PROT_RATE	10
+
+/* 148,800 frames * 67 ms / 100 */
+#define BROADCAST_STORM_VALUE		9969
+
+#endif /* KSZ9477_REGS_H */
diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
new file mode 100644
index 0000000..488c313
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -0,0 +1,1278 @@
+/*
+ * Microchip switch driver main logic
+ *
+ * Copyright (C) 2017
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include <linux/delay.h>
+#include <linux/export.h>
+#include <linux/gpio.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/platform_data/microchip-ksz.h>
+#include <linux/phy.h>
+#include <linux/etherdevice.h>
+#include <linux/if_bridge.h>
+#include <net/dsa.h>
+#include <net/switchdev.h>
+
+#include "ksz_priv.h"
+
+static const struct {
+	int index;
+	char string[ETH_GSTRING_LEN];
+} mib_names[TOTAL_SWITCH_COUNTER_NUM] = {
+	{ 0x00, "rx_hi" },
+	{ 0x01, "rx_undersize" },
+	{ 0x02, "rx_fragments" },
+	{ 0x03, "rx_oversize" },
+	{ 0x04, "rx_jabbers" },
+	{ 0x05, "rx_symbol_err" },
+	{ 0x06, "rx_crc_err" },
+	{ 0x07, "rx_align_err" },
+	{ 0x08, "rx_mac_ctrl" },
+	{ 0x09, "rx_pause" },
+	{ 0x0A, "rx_bcast" },
+	{ 0x0B, "rx_mcast" },
+	{ 0x0C, "rx_ucast" },
+	{ 0x0D, "rx_64_or_less" },
+	{ 0x0E, "rx_65_127" },
+	{ 0x0F, "rx_128_255" },
+	{ 0x10, "rx_256_511" },
+	{ 0x11, "rx_512_1023" },
+	{ 0x12, "rx_1024_1522" },
+	{ 0x13, "rx_1523_2000" },
+	{ 0x14, "rx_2001" },
+	{ 0x15, "tx_hi" },
+	{ 0x16, "tx_late_col" },
+	{ 0x17, "tx_pause" },
+	{ 0x18, "tx_bcast" },
+	{ 0x19, "tx_mcast" },
+	{ 0x1A, "tx_ucast" },
+	{ 0x1B, "tx_deferred" },
+	{ 0x1C, "tx_total_col" },
+	{ 0x1D, "tx_exc_col" },
+	{ 0x1E, "tx_single_col" },
+	{ 0x1F, "tx_mult_col" },
+	{ 0x80, "rx_total" },
+	{ 0x81, "tx_total" },
+	{ 0x82, "rx_discards" },
+	{ 0x83, "tx_discards" },
+};
+
+static void ksz_cfg(struct ksz_device *dev, u32 addr, u8 bits, bool set)
+{
+	u8 data;
+
+	ksz_read8(dev, addr, &data);
+	if (set)
+		data |= bits;
+	else
+		data &= ~bits;
+	ksz_write8(dev, addr, data);
+}
+
+static void ksz_cfg32(struct ksz_device *dev, u32 addr, u32 bits, bool set)
+{
+	u32 data;
+
+	ksz_read32(dev, addr, &data);
+	if (set)
+		data |= bits;
+	else
+		data &= ~bits;
+	ksz_write32(dev, addr, data);
+}
+
+static void ksz_port_cfg(struct ksz_device *dev, int port, int offset, u8 bits,
+			 bool set)
+{
+	u32 addr;
+	u8 data;
+
+	addr = PORT_CTRL_ADDR(port, offset);
+	ksz_read8(dev, addr, &data);
+
+	if (set)
+		data |= bits;
+	else
+		data &= ~bits;
+
+	ksz_write8(dev, addr, data);
+}
+
+static void ksz_port_cfg32(struct ksz_device *dev, int port, int offset,
+			   u32 bits, bool set)
+{
+	u32 addr;
+	u32 data;
+
+	addr = PORT_CTRL_ADDR(port, offset);
+	ksz_read32(dev, addr, &data);
+
+	if (set)
+		data |= bits;
+	else
+		data &= ~bits;
+
+	ksz_write32(dev, addr, data);
+}
+
+static int wait_vlan_ctrl_ready(struct ksz_device *dev, u32 waiton, int timeout)
+{
+	u8 data;
+
+	do {
+		ksz_read8(dev, REG_SW_VLAN_CTRL, &data);
+		if (!(data & waiton))
+			break;
+		usleep_range(1, 10);
+	} while (timeout-- > 0);
+
+	if (timeout <= 0)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int get_vlan_table(struct dsa_switch *ds, u16 vid, u32 *vlan_table)
+{
+	struct ksz_device *dev = ds->priv;
+	int ret;
+
+	mutex_lock(&dev->vlan_mutex);
+
+	ksz_write16(dev, REG_SW_VLAN_ENTRY_INDEX__2, vid & VLAN_INDEX_M);
+	ksz_write8(dev, REG_SW_VLAN_CTRL, VLAN_READ | VLAN_START);
+
+	/* wait to be cleared */
+	ret = wait_vlan_ctrl_ready(dev, VLAN_START, 1000);
+	if (ret < 0) {
+		dev_dbg(dev->dev, "Failed to read vlan table\n");
+		goto exit;
+	}
+
+	ksz_read32(dev, REG_SW_VLAN_ENTRY__4, &vlan_table[0]);
+	ksz_read32(dev, REG_SW_VLAN_ENTRY_UNTAG__4, &vlan_table[1]);
+	ksz_read32(dev, REG_SW_VLAN_ENTRY_PORTS__4, &vlan_table[2]);
+
+	ksz_write8(dev, REG_SW_VLAN_CTRL, 0);
+
+exit:
+	mutex_unlock(&dev->vlan_mutex);
+
+	return ret;
+}
+
+static int set_vlan_table(struct dsa_switch *ds, u16 vid, u32 *vlan_table)
+{
+	struct ksz_device *dev = ds->priv;
+	int ret;
+
+	mutex_lock(&dev->vlan_mutex);
+
+	ksz_write32(dev, REG_SW_VLAN_ENTRY__4, vlan_table[0]);
+	ksz_write32(dev, REG_SW_VLAN_ENTRY_UNTAG__4, vlan_table[1]);
+	ksz_write32(dev, REG_SW_VLAN_ENTRY_PORTS__4, vlan_table[2]);
+
+	ksz_write16(dev, REG_SW_VLAN_ENTRY_INDEX__2, vid & VLAN_INDEX_M);
+	ksz_write8(dev, REG_SW_VLAN_CTRL, VLAN_START | VLAN_WRITE);
+
+	/* wait to be cleared */
+	ret = wait_vlan_ctrl_ready(dev, VLAN_START, 1000);
+	if (ret < 0) {
+		dev_dbg(dev->dev, "Failed to write vlan table\n");
+		goto exit;
+	}
+
+	ksz_write8(dev, REG_SW_VLAN_CTRL, 0);
+
+	/* update vlan cache table */
+	dev->vlan_cache[vid].table[0] = vlan_table[0];
+	dev->vlan_cache[vid].table[1] = vlan_table[1];
+	dev->vlan_cache[vid].table[2] = vlan_table[2];
+
+exit:
+	mutex_unlock(&dev->vlan_mutex);
+
+	return ret;
+}
+
+static void read_table(struct dsa_switch *ds, u32 *table)
+{
+	struct ksz_device *dev = ds->priv;
+
+	ksz_read32(dev, REG_SW_ALU_VAL_A, &table[0]);
+	ksz_read32(dev, REG_SW_ALU_VAL_B, &table[1]);
+	ksz_read32(dev, REG_SW_ALU_VAL_C, &table[2]);
+	ksz_read32(dev, REG_SW_ALU_VAL_D, &table[3]);
+}
+
+static void write_table(struct dsa_switch *ds, u32 *table)
+{
+	struct ksz_device *dev = ds->priv;
+
+	ksz_write32(dev, REG_SW_ALU_VAL_A, table[0]);
+	ksz_write32(dev, REG_SW_ALU_VAL_B, table[1]);
+	ksz_write32(dev, REG_SW_ALU_VAL_C, table[2]);
+	ksz_write32(dev, REG_SW_ALU_VAL_D, table[3]);
+}
+
+static int wait_alu_ready(struct ksz_device *dev, u32 waiton, int timeout)
+{
+	u32 data;
+
+	do {
+		ksz_read32(dev, REG_SW_ALU_CTRL__4, &data);
+		if (!(data & waiton))
+			break;
+		usleep_range(1, 10);
+	} while (timeout-- > 0);
+
+	if (timeout <= 0)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int wait_alu_sta_ready(struct ksz_device *dev, u32 waiton, int timeout)
+{
+	u32 data;
+
+	do {
+		ksz_read32(dev, REG_SW_ALU_STAT_CTRL__4, &data);
+		if (!(data & waiton))
+			break;
+		usleep_range(1, 10);
+	} while (timeout-- > 0);
+
+	if (timeout <= 0)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int ksz_reset_switch(struct dsa_switch *ds)
+{
+	struct ksz_device *dev = ds->priv;
+	u8 data8;
+	u16 data16;
+	u32 data32;
+
+	/* reset switch */
+	ksz_cfg(dev, REG_SW_OPERATION, SW_RESET, true);
+
+	/* turn off SPI DO Edge select */
+	ksz_read8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, &data8);
+	data8 &= ~SPI_AUTO_EDGE_DETECTION;
+	ksz_write8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, data8);
+
+	/* default configuration */
+	ksz_read8(dev, REG_SW_LUE_CTRL_1, &data8);
+	data8 = SW_AGING_ENABLE | SW_LINK_AUTO_AGING |
+	      SW_SRC_ADDR_FILTER | SW_FLUSH_STP_TABLE | SW_FLUSH_MSTP_TABLE;
+	ksz_write8(dev, REG_SW_LUE_CTRL_1, data8);
+
+	/* disable interrupts */
+	ksz_write32(dev, REG_SW_INT_MASK__4, SWITCH_INT_MASK);
+	ksz_write32(dev, REG_SW_PORT_INT_MASK__4, 0x7F);
+	ksz_read32(dev, REG_SW_PORT_INT_STATUS__4, &data32);
+
+	/* set broadcast storm protection 10% rate */
+	ksz_read16(dev, REG_SW_MAC_CTRL_2, &data16);
+	data16 &= ~BROADCAST_STORM_RATE;
+	data16 |= (BROADCAST_STORM_VALUE * BROADCAST_STORM_PROT_RATE) / 100;
+	ksz_write16(dev, REG_SW_MAC_CTRL_2, data16);
+
+	return 0;
+}
+
+static void port_setup(struct ksz_device *dev, int port, bool cpu_port)
+{
+	u8 data8;
+	u16 data16;
+
+	/* enable tag tail for host port */
+	if (cpu_port)
+		ksz_port_cfg(dev, port, REG_PORT_CTRL_0, PORT_TAIL_TAG_ENABLE,
+			     true);
+
+	ksz_port_cfg(dev, port, REG_PORT_CTRL_0, PORT_MAC_LOOPBACK, false);
+
+	/* set back pressure */
+	ksz_port_cfg(dev, port, REG_PORT_MAC_CTRL_1, PORT_BACK_PRESSURE, true);
+
+	/* set flow control */
+	ksz_port_cfg(dev, port, REG_PORT_CTRL_0,
+		     PORT_FORCE_TX_FLOW_CTRL | PORT_FORCE_RX_FLOW_CTRL, true);
+
+	/* enable broadcast storm limit */
+	ksz_port_cfg(dev, port, P_BCAST_STORM_CTRL, PORT_BROADCAST_STORM, true);
+
+	/* disable DiffServ priority */
+	ksz_port_cfg(dev, port, P_PRIO_CTRL, PORT_DIFFSERV_PRIO_ENABLE, false);
+
+	/* replace priority */
+	ksz_port_cfg(dev, port, REG_PORT_MRI_MAC_CTRL, PORT_USER_PRIO_CEILING,
+		     false);
+	ksz_port_cfg32(dev, port, REG_PORT_MTI_QUEUE_CTRL_0__4,
+		       MTI_PVID_REPLACE, false);
+
+	/* enable 802.1p priority */
+	ksz_port_cfg(dev, port, P_PRIO_CTRL, PORT_802_1P_PRIO_ENABLE, true);
+
+	/* configure MAC to 1G & RGMII mode */
+	ksz_pread8(dev, port, REG_PORT_XMII_CTRL_1, &data8);
+	data8 |= PORT_RGMII_ID_EG_ENABLE;
+	data8 &= ~PORT_MII_NOT_1GBIT;
+	data8 &= ~PORT_MII_SEL_M;
+	data8 |= PORT_RGMII_SEL;
+	ksz_pwrite8(dev, port, REG_PORT_XMII_CTRL_1, data8);
+
+	/* clear pending interrupts */
+	ksz_pread16(dev, port, REG_PORT_PHY_INT_ENABLE, &data16);
+}
+
+static void ksz_config_cpu_port(struct dsa_switch *ds)
+{
+	struct ksz_device *dev = ds->priv;
+	int i;
+
+	ds->num_ports = dev->port_cnt;
+
+	for (i = 0; i < ds->num_ports; i++) {
+		if (dsa_is_cpu_port(ds, i) && (dev->cpu_ports & (1 << i))) {
+			dev->cpu_port = i;
+
+			/* enable cpu port */
+			port_setup(dev, i, true);
+		}
+	}
+}
+
+static int ksz_setup(struct dsa_switch *ds)
+{
+	struct ksz_device *dev = ds->priv;
+	int ret = 0;
+
+	dev->vlan_cache = devm_kcalloc(dev->dev, sizeof(struct vlan_table),
+				       dev->num_vlans, GFP_KERNEL);
+	if (!dev->vlan_cache)
+		return -ENOMEM;
+
+	ret = ksz_reset_switch(ds);
+	if (ret) {
+		dev_err(ds->dev, "failed to reset switch\n");
+		return ret;
+	}
+
+	/* accept packet up to 2000bytes */
+	ksz_cfg(dev, REG_SW_MAC_CTRL_1, SW_LEGAL_PACKET_DISABLE, true);
+
+	ksz_config_cpu_port(ds);
+
+	ksz_cfg(dev, REG_SW_MAC_CTRL_1, MULTICAST_STORM_DISABLE, true);
+
+	/* queue based egress rate limit */
+	ksz_cfg(dev, REG_SW_MAC_CTRL_5, SW_OUT_RATE_LIMIT_QUEUE_BASED, true);
+
+	/* start switch */
+	ksz_cfg(dev, REG_SW_OPERATION, SW_START, true);
+
+	return 0;
+}
+
+static enum dsa_tag_protocol ksz_get_tag_protocol(struct dsa_switch *ds)
+{
+	return DSA_TAG_PROTO_KSZ;
+}
+
+static int ksz_phy_read16(struct dsa_switch *ds, int addr, int reg)
+{
+	struct ksz_device *dev = ds->priv;
+	u16 val = 0;
+
+	ksz_pread16(dev, addr, 0x100 + (reg << 1), &val);
+
+	return val;
+}
+
+static int ksz_phy_write16(struct dsa_switch *ds, int addr, int reg, u16 val)
+{
+	struct ksz_device *dev = ds->priv;
+
+	ksz_pwrite16(dev, addr, 0x100 + (reg << 1), val);
+
+	return 0;
+}
+
+static int ksz_enable_port(struct dsa_switch *ds, int port,
+			   struct phy_device *phy)
+{
+	struct ksz_device *dev = ds->priv;
+
+	/* setup slave port */
+	port_setup(dev, port, false);
+
+	return 0;
+}
+
+static void ksz_disable_port(struct dsa_switch *ds, int port,
+			     struct phy_device *phy)
+{
+	struct ksz_device *dev = ds->priv;
+
+	/* there is no port disable */
+	ksz_port_cfg(dev, port, REG_PORT_CTRL_0, PORT_MAC_LOOPBACK, true);
+}
+
+static int ksz_sset_count(struct dsa_switch *ds)
+{
+	return TOTAL_SWITCH_COUNTER_NUM;
+}
+
+static void ksz_get_strings(struct dsa_switch *ds, int port, uint8_t *buf)
+{
+	int i;
+
+	for (i = 0; i < TOTAL_SWITCH_COUNTER_NUM; i++) {
+		memcpy(buf + i * ETH_GSTRING_LEN, mib_names[i].string,
+		       ETH_GSTRING_LEN);
+	}
+}
+
+static void ksz_get_ethtool_stats(struct dsa_switch *ds, int port,
+				  uint64_t *buf)
+{
+	struct ksz_device *dev = ds->priv;
+	int i;
+	u32 data;
+	int timeout;
+
+	mutex_lock(&dev->stats_mutex);
+
+	for (i = 0; i < TOTAL_SWITCH_COUNTER_NUM; i++) {
+		data = MIB_COUNTER_READ;
+		data |= ((mib_names[i].index & 0xFF) << MIB_COUNTER_INDEX_S);
+		ksz_pwrite32(dev, port, REG_PORT_MIB_CTRL_STAT__4, data);
+
+		timeout = 1000;
+		do {
+			ksz_pread32(dev, port, REG_PORT_MIB_CTRL_STAT__4,
+				    &data);
+			usleep_range(1, 10);
+			if (!(data & MIB_COUNTER_READ))
+				break;
+		} while (timeout-- > 0);
+
+		/* failed to read MIB. get out of loop */
+		if (!timeout) {
+			dev_dbg(dev->dev, "Failed to get MIB\n");
+			break;
+		}
+
+		/* count resets upon read */
+		ksz_pread32(dev, port, REG_PORT_MIB_DATA, &data);
+
+		dev->mib_value[i] += (uint64_t)data;
+		buf[i] = dev->mib_value[i];
+	}
+
+	mutex_unlock(&dev->stats_mutex);
+}
+
+static void ksz_port_stp_state_set(struct dsa_switch *ds, int port, u8 state)
+{
+	struct ksz_device *dev = ds->priv;
+	u8 data;
+
+	ksz_pread8(dev, port, P_STP_CTRL, &data);
+	data &= ~(PORT_TX_ENABLE | PORT_RX_ENABLE | PORT_LEARN_DISABLE);
+
+	switch (state) {
+	case BR_STATE_DISABLED:
+		data |= PORT_LEARN_DISABLE;
+		break;
+	case BR_STATE_LISTENING:
+		data |= (PORT_RX_ENABLE | PORT_LEARN_DISABLE);
+		break;
+	case BR_STATE_LEARNING:
+		data |= PORT_RX_ENABLE;
+		break;
+	case BR_STATE_FORWARDING:
+		data |= (PORT_TX_ENABLE | PORT_RX_ENABLE);
+		break;
+	case BR_STATE_BLOCKING:
+		data |= PORT_LEARN_DISABLE;
+		break;
+	default:
+		dev_err(ds->dev, "invalid STP state: %d\n", state);
+		return;
+	}
+
+	ksz_pwrite8(dev, port, P_STP_CTRL, data);
+}
+
+static void ksz_port_fast_age(struct dsa_switch *ds, int port)
+{
+	struct ksz_device *dev = ds->priv;
+	u8 data8;
+
+	ksz_read8(dev, REG_SW_LUE_CTRL_1, &data8);
+	data8 |= SW_FAST_AGING;
+	ksz_write8(dev, REG_SW_LUE_CTRL_1, data8);
+
+	data8 &= ~SW_FAST_AGING;
+	ksz_write8(dev, REG_SW_LUE_CTRL_1, data8);
+}
+
+static int ksz_port_vlan_filtering(struct dsa_switch *ds, int port, bool flag)
+{
+	struct ksz_device *dev = ds->priv;
+
+	if (flag) {
+		ksz_port_cfg(dev, port, REG_PORT_LUE_CTRL,
+			     PORT_VLAN_LOOKUP_VID_0, true);
+		ksz_cfg32(dev, REG_SW_QM_CTRL__4, UNICAST_VLAN_BOUNDARY, true);
+		ksz_cfg(dev, REG_SW_LUE_CTRL_0, SW_VLAN_ENABLE, true);
+	} else {
+		ksz_cfg(dev, REG_SW_LUE_CTRL_0, SW_VLAN_ENABLE, false);
+		ksz_cfg32(dev, REG_SW_QM_CTRL__4, UNICAST_VLAN_BOUNDARY, false);
+		ksz_port_cfg(dev, port, REG_PORT_LUE_CTRL,
+			     PORT_VLAN_LOOKUP_VID_0, false);
+	}
+
+	return 0;
+}
+
+static int ksz_port_vlan_prepare(struct dsa_switch *ds, int port,
+				 const struct switchdev_obj_port_vlan *vlan,
+				 struct switchdev_trans *trans)
+{
+	/* nothing needed */
+
+	return 0;
+}
+
+static void ksz_port_vlan_add(struct dsa_switch *ds, int port,
+			      const struct switchdev_obj_port_vlan *vlan,
+			      struct switchdev_trans *trans)
+{
+	struct ksz_device *dev = ds->priv;
+	u32 vlan_table[3];
+	u16 vid;
+	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
+		if (get_vlan_table(ds, vid, vlan_table)) {
+			dev_dbg(dev->dev, "Failed to get vlan table\n");
+			return;
+		}
+
+		vlan_table[0] = VLAN_VALID | (vid & VLAN_FID_M);
+		if (untagged)
+			vlan_table[1] |= BIT(port);
+		else
+			vlan_table[1] &= ~BIT(port);
+		vlan_table[1] &= ~(BIT(dev->cpu_port));
+
+		vlan_table[2] |= BIT(port) | BIT(dev->cpu_port);
+
+		if (set_vlan_table(ds, vid, vlan_table)) {
+			dev_dbg(dev->dev, "Failed to set vlan table\n");
+			return;
+		}
+
+		/* change PVID */
+		if (vlan->flags & BRIDGE_VLAN_INFO_PVID)
+			ksz_pwrite16(dev, port, REG_PORT_DEFAULT_VID, vid);
+	}
+}
+
+static int ksz_port_vlan_del(struct dsa_switch *ds, int port,
+			     const struct switchdev_obj_port_vlan *vlan)
+{
+	struct ksz_device *dev = ds->priv;
+	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+	u32 vlan_table[3];
+	u16 vid;
+	u16 pvid;
+
+	ksz_pread16(dev, port, REG_PORT_DEFAULT_VID, &pvid);
+	pvid = pvid & 0xFFF;
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
+		if (get_vlan_table(ds, vid, vlan_table)) {
+			dev_dbg(dev->dev, "Failed to get vlan table\n");
+			return -ETIMEDOUT;
+		}
+
+		vlan_table[2] &= ~BIT(port);
+
+		if (pvid == vid)
+			pvid = 1;
+
+		if (untagged)
+			vlan_table[1] &= ~BIT(port);
+
+		if (set_vlan_table(ds, vid, vlan_table)) {
+			dev_dbg(dev->dev, "Failed to set vlan table\n");
+			return -ETIMEDOUT;
+		}
+	}
+
+	ksz_pwrite16(dev, port, REG_PORT_DEFAULT_VID, pvid);
+
+	return 0;
+}
+
+static int ksz_port_vlan_dump(struct dsa_switch *ds, int port,
+			      struct switchdev_obj_port_vlan *vlan,
+			      switchdev_obj_dump_cb_t *cb)
+{
+	struct ksz_device *dev = ds->priv;
+	u16 vid;
+	u16 data;
+	struct vlan_table *vlan_cache;
+	int err = 0;
+
+	mutex_lock(&dev->vlan_mutex);
+
+	/* use dev->vlan_cache due to lack of searching valid vlan entry */
+	for (vid = vlan->vid_begin; vid < dev->num_vlans; vid++) {
+		vlan_cache = &dev->vlan_cache[vid];
+
+		if (!(vlan_cache->table[0] & VLAN_VALID))
+			continue;
+
+		vlan->vid_begin = vid;
+		vlan->vid_end = vid;
+		vlan->flags = 0;
+		if (vlan_cache->table[2] & BIT(port)) {
+			if (vlan_cache->table[1] & BIT(port))
+				vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
+			ksz_pread16(dev, port, REG_PORT_DEFAULT_VID, &data);
+			if (vid == (data & 0xFFFFF))
+				vlan->flags |= BRIDGE_VLAN_INFO_PVID;
+
+			err = cb(&vlan->obj);
+			if (err)
+				break;
+		}
+	}
+
+	mutex_unlock(&dev->vlan_mutex);
+
+	return err;
+}
+
+static int ksz_port_fdb_prepare(struct dsa_switch *ds, int port,
+				const struct switchdev_obj_port_fdb *fdb,
+				struct switchdev_trans *trans)
+{
+	/* nothing needed */
+
+	return 0;
+}
+
+struct alu_struct {
+	/* entry 1 */
+	u8	is_static:1;
+	u8	is_src_filter:1;
+	u8	is_dst_filter:1;
+	u8	prio_age:3;
+	u32	_reserv_0_1:23;
+	u8	mstp:3;
+	/* entry 2 */
+	u8	is_override:1;
+	u8	is_use_fid:1;
+	u32	_reserv_1_1:23;
+	u8	port_forward:7;
+	/* entry 3 & 4*/
+	u32	_reserv_2_1:9;
+	u8	fid:7;
+	u8	mac[ETH_ALEN];
+};
+
+static void ksz_port_fdb_add(struct dsa_switch *ds, int port,
+			     const struct switchdev_obj_port_fdb *fdb,
+			     struct switchdev_trans *trans)
+{
+	struct ksz_device *dev = ds->priv;
+	u32 alu_table[4];
+	u32 data;
+
+	mutex_lock(&dev->alu_mutex);
+
+	/* find any entry with mac & vid */
+	data = fdb->vid << ALU_FID_INDEX_S;
+	data |= ((fdb->addr[0] << 8) | fdb->addr[1]);
+	ksz_write32(dev, REG_SW_ALU_INDEX_0, data);
+
+	data = ((fdb->addr[2] << 24) | (fdb->addr[3] << 16));
+	data |= ((fdb->addr[4] << 8) | fdb->addr[5]);
+	ksz_write32(dev, REG_SW_ALU_INDEX_1, data);
+
+	/* start read operation */
+	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_READ | ALU_START);
+
+	/* wait to be finished */
+	if (wait_alu_ready(dev, ALU_START, 1000) < 0) {
+		dev_dbg(dev->dev, "Failed to read ALU\n");
+		goto exit;
+	}
+
+	/* read ALU entry */
+	read_table(ds, alu_table);
+
+	/* update ALU entry */
+	alu_table[0] = ALU_V_STATIC_VALID;
+	alu_table[1] |= BIT(port);
+	if (fdb->vid)
+		alu_table[1] |= ALU_V_USE_FID;
+	alu_table[2] = (fdb->vid << ALU_V_FID_S);
+	alu_table[2] |= ((fdb->addr[0] << 8) | fdb->addr[1]);
+	alu_table[3] = ((fdb->addr[2] << 24) | (fdb->addr[3] << 16));
+	alu_table[3] |= ((fdb->addr[4] << 8) | fdb->addr[5]);
+
+	write_table(ds, alu_table);
+
+	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_WRITE | ALU_START);
+
+	/* wait to be finished */
+	if (wait_alu_ready(dev, ALU_START, 1000) < 0)
+		dev_dbg(dev->dev, "Failed to read ALU\n");
+
+exit:
+	mutex_unlock(&dev->alu_mutex);
+}
+
+static int ksz_port_fdb_del(struct dsa_switch *ds, int port,
+			    const struct switchdev_obj_port_fdb *fdb)
+{
+	struct ksz_device *dev = ds->priv;
+	u32 alu_table[4];
+	u32 data;
+	int ret = 0;
+
+	mutex_lock(&dev->alu_mutex);
+
+	/* read any entry with mac & vid */
+	data = fdb->vid << ALU_FID_INDEX_S;
+	data |= ((fdb->addr[0] << 8) | fdb->addr[1]);
+	ksz_write32(dev, REG_SW_ALU_INDEX_0, data);
+
+	data = ((fdb->addr[2] << 24) | (fdb->addr[3] << 16));
+	data |= ((fdb->addr[4] << 8) | fdb->addr[5]);
+	ksz_write32(dev, REG_SW_ALU_INDEX_1, data);
+
+	/* start read operation */
+	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_READ | ALU_START);
+
+	/* wait to be finished */
+	ret = wait_alu_ready(dev, ALU_START, 1000);
+	if (ret < 0) {
+		dev_dbg(dev->dev, "Failed to read ALU\n");
+		goto exit;
+	}
+
+	ksz_read32(dev, REG_SW_ALU_VAL_A, &alu_table[0]);
+	if (alu_table[0] & ALU_V_STATIC_VALID) {
+		ksz_read32(dev, REG_SW_ALU_VAL_B, &alu_table[1]);
+		ksz_read32(dev, REG_SW_ALU_VAL_C, &alu_table[2]);
+		ksz_read32(dev, REG_SW_ALU_VAL_D, &alu_table[3]);
+
+		/* clear forwarding port */
+		alu_table[2] &= ~BIT(port);
+
+		/* if there is no port to forward, clear table */
+		if ((alu_table[2] & ALU_V_PORT_MAP) == 0) {
+			alu_table[0] = 0;
+			alu_table[1] = 0;
+			alu_table[2] = 0;
+			alu_table[3] = 0;
+		}
+	} else {
+		alu_table[0] = 0;
+		alu_table[1] = 0;
+		alu_table[2] = 0;
+		alu_table[3] = 0;
+	}
+
+	write_table(ds, alu_table);
+
+	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_WRITE | ALU_START);
+
+	/* wait to be finished */
+	ret = wait_alu_ready(dev, ALU_START, 1000);
+	if (ret < 0)
+		dev_dbg(dev->dev, "Failed to write ALU\n");
+
+exit:
+	mutex_unlock(&dev->alu_mutex);
+
+	return ret;
+}
+
+static void convert_alu(struct alu_struct *alu, u32 *alu_table)
+{
+	alu->is_static = !!(alu_table[0] & ALU_V_STATIC_VALID);
+	alu->is_src_filter = !!(alu_table[0] & ALU_V_SRC_FILTER);
+	alu->is_dst_filter = !!(alu_table[0] & ALU_V_DST_FILTER);
+	alu->prio_age = (alu_table[0] >> ALU_V_PRIO_AGE_CNT_S) &
+			ALU_V_PRIO_AGE_CNT_M;
+	alu->mstp = alu_table[0] & ALU_V_MSTP_M;
+
+	alu->is_override = !!(alu_table[1] & ALU_V_OVERRIDE);
+	alu->is_use_fid = !!(alu_table[1] & ALU_V_USE_FID);
+	alu->port_forward = alu_table[1] & ALU_V_PORT_MAP;
+
+	alu->fid = (alu_table[2] >> ALU_V_FID_S) & ALU_V_FID_M;
+
+	alu->mac[0] = (alu_table[2] >> 8) & 0xFF;
+	alu->mac[1] = alu_table[2] & 0xFF;
+	alu->mac[2] = (alu_table[3] >> 24) & 0xFF;
+	alu->mac[3] = (alu_table[3] >> 16) & 0xFF;
+	alu->mac[4] = (alu_table[3] >> 8) & 0xFF;
+	alu->mac[5] = alu_table[3] & 0xFF;
+}
+
+static int ksz_port_fdb_dump(struct dsa_switch *ds, int port,
+			     struct switchdev_obj_port_fdb *fdb,
+			     switchdev_obj_dump_cb_t *cb)
+{
+	struct ksz_device *dev = ds->priv;
+	int ret = 0;
+	u32 data;
+	u32 alu_table[4];
+	struct alu_struct alu;
+	int timeout;
+
+	mutex_lock(&dev->alu_mutex);
+
+	/* start ALU search */
+	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_START | ALU_SEARCH);
+
+	do {
+		timeout = 1000;
+		do {
+			ksz_read32(dev, REG_SW_ALU_CTRL__4, &data);
+			if ((data & ALU_VALID) || !(data & ALU_START))
+				break;
+			usleep_range(1, 10);
+		} while (timeout-- > 0);
+
+		if (!timeout) {
+			dev_dbg(dev->dev, "Failed to search ALU\n");
+			ret = -ETIMEDOUT;
+			goto exit;
+		}
+
+		/* read ALU table */
+		read_table(ds, alu_table);
+
+		convert_alu(&alu, alu_table);
+
+		if (alu.port_forward & BIT(port)) {
+			fdb->vid = alu.fid;
+			if (alu.is_static)
+				fdb->ndm_state = NUD_NOARP;
+			else
+				fdb->ndm_state = NUD_REACHABLE;
+			ether_addr_copy(fdb->addr, alu.mac);
+
+			ret = cb(&fdb->obj);
+			if (ret)
+				goto exit;
+		}
+	} while (data & ALU_START);
+
+exit:
+
+	/* stop ALU search */
+	ksz_write32(dev, REG_SW_ALU_CTRL__4, 0);
+
+	mutex_unlock(&dev->alu_mutex);
+
+	return ret;
+}
+
+static int ksz_port_mdb_prepare(struct dsa_switch *ds, int port,
+				const struct switchdev_obj_port_mdb *mdb,
+				struct switchdev_trans *trans)
+{
+	/* nothing to do */
+	return 0;
+}
+
+static void ksz_port_mdb_add(struct dsa_switch *ds, int port,
+			     const struct switchdev_obj_port_mdb *mdb,
+			     struct switchdev_trans *trans)
+{
+	struct ksz_device *dev = ds->priv;
+	u32 static_table[4];
+	u32 data;
+	int index;
+	u32 mac_hi, mac_lo;
+
+	mac_hi = ((mdb->addr[0] << 8) | mdb->addr[1]);
+	mac_lo = ((mdb->addr[2] << 24) | (mdb->addr[3] << 16));
+	mac_lo |= ((mdb->addr[4] << 8) | mdb->addr[5]);
+
+	mutex_lock(&dev->alu_mutex);
+
+	for (index = 0; index < dev->num_statics; index++) {
+		/* find empty slot first */
+		data = (index << ALU_STAT_INDEX_S) |
+			ALU_STAT_READ | ALU_STAT_START;
+		ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
+
+		/* wait to be finished */
+		if (wait_alu_sta_ready(dev, ALU_STAT_START, 1000) < 0) {
+			dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
+			goto exit;
+		}
+
+		/* read ALU static table */
+		read_table(ds, static_table);
+
+		if (static_table[0] & ALU_V_STATIC_VALID) {
+			/* check this has same vid & mac address */
+			if (((static_table[2] >> ALU_V_FID_S) == (mdb->vid)) &&
+			    ((static_table[2] & ALU_V_MAC_ADDR_HI) == mac_hi) &&
+			    (static_table[3] == mac_lo)) {
+				/* found matching one */
+				break;
+			}
+		} else {
+			/* found empty one */
+			break;
+		}
+	}
+
+	/* no available entry */
+	if (index == dev->num_statics)
+		goto exit;
+
+	/* add entry */
+	static_table[0] = ALU_V_STATIC_VALID;
+	static_table[1] |= BIT(port);
+	if (mdb->vid)
+		static_table[1] |= ALU_V_USE_FID;
+	static_table[2] = (mdb->vid << ALU_V_FID_S);
+	static_table[2] |= mac_hi;
+	static_table[3] = mac_lo;
+
+	write_table(ds, static_table);
+
+	data = (index << ALU_STAT_INDEX_S) | ALU_STAT_START;
+	ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
+
+	/* wait to be finished */
+	if (wait_alu_sta_ready(dev, ALU_STAT_START, 1000) < 0)
+		dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
+
+exit:
+	mutex_unlock(&dev->alu_mutex);
+}
+
+static int ksz_port_mdb_del(struct dsa_switch *ds, int port,
+			    const struct switchdev_obj_port_mdb *mdb)
+{
+	struct ksz_device *dev = ds->priv;
+	u32 static_table[4];
+	u32 data;
+	int index;
+	int ret = 0;
+	u32 mac_hi, mac_lo;
+
+	mac_hi = ((mdb->addr[0] << 8) | mdb->addr[1]);
+	mac_lo = ((mdb->addr[2] << 24) | (mdb->addr[3] << 16));
+	mac_lo |= ((mdb->addr[4] << 8) | mdb->addr[5]);
+
+	mutex_lock(&dev->alu_mutex);
+
+	for (index = 0; index < dev->num_statics; index++) {
+		/* find empty slot first */
+		data = (index << ALU_STAT_INDEX_S) |
+			ALU_STAT_READ | ALU_STAT_START;
+		ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
+
+		/* wait to be finished */
+		ret = wait_alu_sta_ready(dev, ALU_STAT_START, 1000);
+		if (ret < 0) {
+			dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
+			goto exit;
+		}
+
+		/* read ALU static table */
+		read_table(ds, static_table);
+
+		if (static_table[0] & ALU_V_STATIC_VALID) {
+			/* check this has same vid & mac address */
+
+			if (((static_table[2] >> ALU_V_FID_S) == (mdb->vid)) &&
+			    ((static_table[2] & ALU_V_MAC_ADDR_HI) == mac_hi) &&
+			    (static_table[3] == mac_lo)) {
+				/* found matching one */
+				break;
+			}
+		}
+	}
+
+	/* no available entry */
+	if (index == dev->num_statics) {
+		ret = -EINVAL;
+		goto exit;
+	}
+
+	/* clear port */
+	static_table[1] &= ~BIT(port);
+
+	if ((static_table[1] & ALU_V_PORT_MAP) == 0) {
+		/* delete entry */
+		static_table[0] = 0;
+		static_table[1] = 0;
+		static_table[2] = 0;
+		static_table[3] = 0;
+	}
+
+	write_table(ds, static_table);
+
+	data = (index << ALU_STAT_INDEX_S) | ALU_STAT_START;
+	ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
+
+	/* wait to be finished */
+	ret = wait_alu_sta_ready(dev, ALU_STAT_START, 1000);
+	if (ret < 0)
+		dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
+
+exit:
+	mutex_unlock(&dev->alu_mutex);
+
+	return ret;
+}
+
+static int ksz_port_mdb_dump(struct dsa_switch *ds, int port,
+			     struct switchdev_obj_port_mdb *mdb,
+			     switchdev_obj_dump_cb_t *cb)
+{
+	/* this is not called by switch layer */
+	return 0;
+}
+
+static int ksz_port_mirror_add(struct dsa_switch *ds, int port,
+			       struct dsa_mall_mirror_tc_entry *mirror,
+			       bool ingress)
+{
+	struct ksz_device *dev = ds->priv;
+
+	if (ingress)
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_RX, true);
+	else
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_TX, true);
+
+	ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_SNIFFER, false);
+
+	/* configure mirror port */
+	ksz_port_cfg(dev, mirror->to_local_port, P_MIRROR_CTRL,
+		     PORT_MIRROR_SNIFFER, true);
+
+	ksz_cfg(dev, S_MIRROR_CTRL, SW_MIRROR_RX_TX, false);
+
+	return 0;
+}
+
+static void ksz_port_mirror_del(struct dsa_switch *ds, int port,
+				struct dsa_mall_mirror_tc_entry *mirror)
+{
+	struct ksz_device *dev = ds->priv;
+	u8 data;
+
+	if (mirror->ingress)
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_RX, false);
+	else
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_TX, false);
+
+	ksz_pread8(dev, port, P_MIRROR_CTRL, &data);
+
+	if (!(data & (PORT_MIRROR_RX | PORT_MIRROR_TX)))
+		ksz_port_cfg(dev, mirror->to_local_port, P_MIRROR_CTRL,
+			     PORT_MIRROR_SNIFFER, false);
+}
+
+static const struct dsa_switch_ops ksz_switch_ops = {
+	.get_tag_protocol	= ksz_get_tag_protocol,
+	.setup			= ksz_setup,
+	.phy_read		= ksz_phy_read16,
+	.phy_write		= ksz_phy_write16,
+	.port_enable		= ksz_enable_port,
+	.port_disable		= ksz_disable_port,
+	.get_strings		= ksz_get_strings,
+	.get_ethtool_stats	= ksz_get_ethtool_stats,
+	.get_sset_count		= ksz_sset_count,
+	.port_stp_state_set	= ksz_port_stp_state_set,
+	.port_fast_age		= ksz_port_fast_age,
+	.port_vlan_filtering	= ksz_port_vlan_filtering,
+	.port_vlan_prepare	= ksz_port_vlan_prepare,
+	.port_vlan_add		= ksz_port_vlan_add,
+	.port_vlan_del		= ksz_port_vlan_del,
+	.port_vlan_dump		= ksz_port_vlan_dump,
+	.port_fdb_prepare	= ksz_port_fdb_prepare,
+	.port_fdb_dump		= ksz_port_fdb_dump,
+	.port_fdb_add		= ksz_port_fdb_add,
+	.port_fdb_del		= ksz_port_fdb_del,
+	.port_mdb_prepare       = ksz_port_mdb_prepare,
+	.port_mdb_add           = ksz_port_mdb_add,
+	.port_mdb_del           = ksz_port_mdb_del,
+	.port_mdb_dump          = ksz_port_mdb_dump,
+	.port_mirror_add	= ksz_port_mirror_add,
+	.port_mirror_del	= ksz_port_mirror_del,
+};
+
+struct ksz_chip_data {
+	u32 chip_id;
+	const char *dev_name;
+	int num_vlans;
+	int num_alus;
+	int num_statics;
+	int cpu_ports;
+	int port_cnt;
+};
+
+static const struct ksz_chip_data ksz_switch_chips[] = {
+	{
+		.chip_id = 0x00947700,
+		.dev_name = "KSZ9477",
+		.num_vlans = 4096,
+		.num_alus = 4096,
+		.num_statics = 16,
+		.cpu_ports = 0x7F,	/* can be configured as cpu port */
+		.port_cnt = 7,		/* total physical port count */
+	},
+};
+
+static int ksz_switch_init(struct ksz_device *dev)
+{
+	int i;
+
+	mutex_init(&dev->reg_mutex);
+	mutex_init(&dev->stats_mutex);
+	mutex_init(&dev->alu_mutex);
+	mutex_init(&dev->vlan_mutex);
+
+	dev->ds->ops = &ksz_switch_ops;
+
+	for (i = 0; i < ARRAY_SIZE(ksz_switch_chips); i++) {
+		const struct ksz_chip_data *chip = &ksz_switch_chips[i];
+
+		if (dev->chip_id == chip->chip_id) {
+			dev->name = chip->dev_name;
+			dev->num_vlans = chip->num_vlans;
+			dev->num_alus = chip->num_alus;
+			dev->num_statics = chip->num_statics;
+			dev->port_cnt = chip->port_cnt;
+			dev->cpu_ports = chip->cpu_ports;
+
+			break;
+		}
+	}
+
+	/* no switch found */
+	if (!dev->port_cnt)
+		return -ENODEV;
+
+	return 0;
+}
+
+struct ksz_device *ksz_switch_alloc(struct device *base,
+				    const struct ksz_io_ops *ops,
+				    void *priv)
+{
+	struct dsa_switch *ds;
+	struct ksz_device *swdev;
+
+	ds = dsa_switch_alloc(base, DSA_MAX_PORTS);
+	if (!ds)
+		return NULL;
+
+	swdev = devm_kzalloc(base, sizeof(*swdev), GFP_KERNEL);
+	if (!swdev)
+		return NULL;
+
+	ds->priv = swdev;
+	swdev->dev = base;
+
+	swdev->ds = ds;
+	swdev->priv = priv;
+	swdev->ops = ops;
+
+	return swdev;
+}
+EXPORT_SYMBOL(ksz_switch_alloc);
+
+int ksz_switch_detect(struct ksz_device *dev)
+{
+	u8 data8;
+	u32 id32;
+	int ret;
+
+	/* turn off SPI DO Edge select */
+	ret = ksz_read8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, &data8);
+	if (ret)
+		return ret;
+
+	data8 &= ~SPI_AUTO_EDGE_DETECTION;
+	ret = ksz_write8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, data8);
+	if (ret)
+		return ret;
+
+	/* read chip id */
+	ret = ksz_read32(dev, REG_CHIP_ID0__1, &id32);
+	if (ret)
+		return ret;
+
+	dev->chip_id = id32;
+
+	return 0;
+}
+EXPORT_SYMBOL(ksz_switch_detect);
+
+int ksz_switch_register(struct ksz_device *dev)
+{
+	int ret;
+
+	if (dev->pdata)
+		dev->chip_id = dev->pdata->chip_id;
+
+	if (ksz_switch_detect(dev))
+		return -EINVAL;
+
+	ret = ksz_switch_init(dev);
+	if (ret)
+		return ret;
+
+	return dsa_register_switch(dev->ds, dev->ds->dev);
+}
+EXPORT_SYMBOL(ksz_switch_register);
+
+void ksz_switch_remove(struct ksz_device *dev)
+{
+	dsa_unregister_switch(dev->ds);
+}
+EXPORT_SYMBOL(ksz_switch_remove);
+
+MODULE_AUTHOR("Woojung Huh <Woojung.Huh@microchip.com>");
+MODULE_DESCRIPTION("Microchip KSZ Series Switch DSA Driver");
diff --git a/drivers/net/dsa/microchip/ksz_priv.h b/drivers/net/dsa/microchip/ksz_priv.h
new file mode 100644
index 0000000..2a98dbd
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz_priv.h
@@ -0,0 +1,210 @@
+/*
+ * Microchip KSZ series switch common definitions
+ *
+ * Copyright (C) 2017
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef __KSZ_PRIV_H
+#define __KSZ_PRIV_H
+
+#include <linux/kernel.h>
+#include <linux/mutex.h>
+#include <linux/phy.h>
+#include <linux/etherdevice.h>
+#include <net/dsa.h>
+
+#include "ksz_9477_reg.h"
+
+struct ksz_io_ops;
+
+struct vlan_table {
+	u32 table[3];
+};
+
+struct ksz_device {
+	struct dsa_switch *ds;
+	struct ksz_platform_data *pdata;
+	const char *name;
+
+	struct mutex reg_mutex;		/* register access */
+	struct mutex stats_mutex;	/* status access */
+	struct mutex alu_mutex;		/* ALU access */
+	struct mutex vlan_mutex;	/* vlan access */
+	const struct ksz_io_ops *ops;
+
+	struct device *dev;
+
+	void *priv;
+
+	/* chip specific data */
+	u32 chip_id;
+	int num_vlans;
+	int num_alus;
+	int num_statics;
+	int cpu_port;			/* port connected to CPU */
+	int cpu_ports;			/* port bitmap can be cpu port */
+	int port_cnt;
+
+	struct vlan_table *vlan_cache;
+
+	u64 mib_value[TOTAL_SWITCH_COUNTER_NUM];
+};
+
+struct ksz_io_ops {
+	int (*read8)(struct ksz_device *dev, u32 reg, u8 *value);
+	int (*read16)(struct ksz_device *dev, u32 reg, u16 *value);
+	int (*read24)(struct ksz_device *dev, u32 reg, u32 *value);
+	int (*read32)(struct ksz_device *dev, u32 reg, u32 *value);
+	int (*write8)(struct ksz_device *dev, u32 reg, u8 value);
+	int (*write16)(struct ksz_device *dev, u32 reg, u16 value);
+	int (*write24)(struct ksz_device *dev, u32 reg, u32 value);
+	int (*write32)(struct ksz_device *dev, u32 reg, u32 value);
+	int (*phy_read16)(struct ksz_device *dev, int addr, int reg,
+			  u16 *value);
+	int (*phy_write16)(struct ksz_device *dev, int addr, int reg,
+			   u16 value);
+};
+
+struct ksz_device *ksz_switch_alloc(struct device *base,
+				    const struct ksz_io_ops *ops, void *priv);
+int ksz_switch_detect(struct ksz_device *dev);
+int ksz_switch_register(struct ksz_device *dev);
+void ksz_switch_remove(struct ksz_device *dev);
+
+static inline int ksz_read8(struct ksz_device *dev, u32 reg, u8 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->read8(dev, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_read16(struct ksz_device *dev, u32 reg, u16 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->read16(dev, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_read24(struct ksz_device *dev, u32 reg, u32 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->read24(dev, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_read32(struct ksz_device *dev, u32 reg, u32 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->read32(dev, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_write8(struct ksz_device *dev, u32 reg, u8 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->write8(dev, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_write16(struct ksz_device *dev, u32 reg, u16 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->write16(dev, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_write24(struct ksz_device *dev, u32 reg, u32 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->write24(dev, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_write32(struct ksz_device *dev, u32 reg, u32 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->write32(dev, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline void ksz_pread8(struct ksz_device *dev, int port, int offset,
+			      u8 *data)
+{
+	ksz_read8(dev, PORT_CTRL_ADDR(port, offset), data);
+}
+
+static inline void ksz_pread16(struct ksz_device *dev, int port, int offset,
+			       u16 *data)
+{
+	ksz_read16(dev, PORT_CTRL_ADDR(port, offset), data);
+}
+
+static inline void ksz_pread32(struct ksz_device *dev, int port, int offset,
+			       u32 *data)
+{
+	ksz_read32(dev, PORT_CTRL_ADDR(port, offset), data);
+}
+
+static inline void ksz_pwrite8(struct ksz_device *dev, int port, int offset,
+			       u8 data)
+{
+	ksz_write8(dev, PORT_CTRL_ADDR(port, offset), data);
+}
+
+static inline void ksz_pwrite16(struct ksz_device *dev, int port, int offset,
+				u16 data)
+{
+	ksz_write16(dev, PORT_CTRL_ADDR(port, offset), data);
+}
+
+static inline void ksz_pwrite32(struct ksz_device *dev, int port, int offset,
+				u32 data)
+{
+	ksz_write32(dev, PORT_CTRL_ADDR(port, offset), data);
+}
+
+#endif
diff --git a/drivers/net/dsa/microchip/ksz_spi.c b/drivers/net/dsa/microchip/ksz_spi.c
new file mode 100644
index 0000000..8a47dea
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz_spi.c
@@ -0,0 +1,215 @@
+/*
+ * Microchip KSZ series register access through SPI
+ *
+ * Copyright (C) 2017
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include <asm/unaligned.h>
+
+#include <linux/delay.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/spi/spi.h>
+
+#include "ksz_priv.h"
+
+/* SPI frame opcodes */
+#define KS_SPIOP_RD			3
+#define KS_SPIOP_WR			2
+
+#define SPI_ADDR_SHIFT			24
+#define SPI_ADDR_MASK			(BIT(SPI_ADDR_SHIFT) - 1)
+#define SPI_TURNAROUND_SHIFT		5
+
+static int ksz_spi_read_reg(struct spi_device *spi, u32 reg, u8 *val,
+			    unsigned int len)
+{
+	u32 txbuf;
+	int ret;
+
+	txbuf = reg & SPI_ADDR_MASK;
+	txbuf |= KS_SPIOP_RD << SPI_ADDR_SHIFT;
+	txbuf <<= SPI_TURNAROUND_SHIFT;
+	txbuf = cpu_to_be32(txbuf);
+
+	ret = spi_write_then_read(spi, &txbuf, 4, val, len);
+	return ret;
+}
+
+static int ksz_spi_read(struct ksz_device *dev, u32 reg, u8 *data,
+			unsigned int len)
+{
+	struct spi_device *spi = dev->priv;
+
+	return ksz_spi_read_reg(spi, reg, data, len);
+}
+
+static int ksz_spi_read8(struct ksz_device *dev, u32 reg, u8 *val)
+{
+	return ksz_spi_read(dev, reg, val, 1);
+}
+
+static int ksz_spi_read16(struct ksz_device *dev, u32 reg, u16 *val)
+{
+	int ret = ksz_spi_read(dev, reg, (u8 *)val, 2);
+
+	if (!ret)
+		*val = be16_to_cpu(*val);
+
+	return ret;
+}
+
+static int ksz_spi_read24(struct ksz_device *dev, u32 reg, u32 *val)
+{
+	int ret;
+
+	*val = 0;
+	ret = ksz_spi_read(dev, reg, (u8 *)val, 3);
+	if (!ret) {
+		*val = be32_to_cpu(*val);
+		/* convert to 24bit */
+		*val >>= 8;
+	}
+
+	return ret;
+}
+
+static int ksz_spi_read32(struct ksz_device *dev, u32 reg, u32 *val)
+{
+	int ret = ksz_spi_read(dev, reg, (u8 *)val, 4);
+
+	if (!ret)
+		*val = be32_to_cpu(*val);
+
+	return ret;
+}
+
+static int ksz_spi_write_reg(struct spi_device *spi, u32 reg, u8 *val,
+			     unsigned int len)
+{
+	u32 txbuf;
+	u8 data[12];
+	int i;
+
+	txbuf = reg & SPI_ADDR_MASK;
+	txbuf |= (KS_SPIOP_WR << SPI_ADDR_SHIFT);
+	txbuf <<= SPI_TURNAROUND_SHIFT;
+	txbuf = cpu_to_be32(txbuf);
+
+	data[0] = txbuf & 0xFF;
+	data[1] = (txbuf & 0xFF00) >> 8;
+	data[2] = (txbuf & 0xFF0000) >> 16;
+	data[3] = (txbuf & 0xFF000000) >> 24;
+	for (i = 0; i < len; i++)
+		data[i + 4] = val[i];
+
+	return spi_write(spi, &data, 4 + len);
+}
+
+static int ksz_spi_write8(struct ksz_device *dev, u32 reg, u8 value)
+{
+	struct spi_device *spi = dev->priv;
+
+	return ksz_spi_write_reg(spi, reg, &value, 1);
+}
+
+static int ksz_spi_write16(struct ksz_device *dev, u32 reg, u16 value)
+{
+	struct spi_device *spi = dev->priv;
+
+	value = cpu_to_be16(value);
+	return ksz_spi_write_reg(spi, reg, (u8 *)&value, 2);
+}
+
+static int ksz_spi_write24(struct ksz_device *dev, u32 reg, u32 value)
+{
+	struct spi_device *spi = dev->priv;
+
+	/* make it to big endian 24bit from MSB */
+	value <<= 8;
+	value = cpu_to_be32(value);
+	return ksz_spi_write_reg(spi, reg, (u8 *)&value, 3);
+}
+
+static int ksz_spi_write32(struct ksz_device *dev, u32 reg, u32 value)
+{
+	struct spi_device *spi = dev->priv;
+
+	value = cpu_to_be32(value);
+	return ksz_spi_write_reg(spi, reg, (u8 *)&value, 4);
+}
+
+static const struct ksz_io_ops ksz_spi_ops = {
+	.read8 = ksz_spi_read8,
+	.read16 = ksz_spi_read16,
+	.read24 = ksz_spi_read24,
+	.read32 = ksz_spi_read32,
+	.write8 = ksz_spi_write8,
+	.write16 = ksz_spi_write16,
+	.write24 = ksz_spi_write24,
+	.write32 = ksz_spi_write32,
+};
+
+static int ksz_spi_probe(struct spi_device *spi)
+{
+	struct ksz_device *dev;
+	int ret;
+
+	dev = ksz_switch_alloc(&spi->dev, &ksz_spi_ops, spi);
+	if (!dev)
+		return -ENOMEM;
+
+	if (spi->dev.platform_data)
+		dev->pdata = spi->dev.platform_data;
+
+	ret = ksz_switch_register(dev);
+	if (ret)
+		return ret;
+
+	spi_set_drvdata(spi, dev);
+
+	return 0;
+}
+
+static int ksz_spi_remove(struct spi_device *spi)
+{
+	struct ksz_device *dev = spi_get_drvdata(spi);
+
+	if (dev)
+		ksz_switch_remove(dev);
+
+	return 0;
+}
+
+static const struct of_device_id ksz_dt_ids[] = {
+	{ .compatible = "microchip,ksz9477" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, ksz_dt_ids);
+
+static struct spi_driver ksz_spi_driver = {
+	.driver = {
+		.name	= "ksz9477-switch",
+		.owner	= THIS_MODULE,
+		.of_match_table = of_match_ptr(ksz_dt_ids),
+	},
+	.probe	= ksz_spi_probe,
+	.remove	= ksz_spi_remove,
+};
+
+module_spi_driver(ksz_spi_driver);
+
+MODULE_AUTHOR("Woojung Huh <Woojung.Huh@microchip.com>");
+MODULE_DESCRIPTION("Microchip KSZ Series Switch SPI access Driver");
diff --git a/include/linux/platform_data/microchip-ksz.h b/include/linux/platform_data/microchip-ksz.h
new file mode 100644
index 0000000..84789ca
--- /dev/null
+++ b/include/linux/platform_data/microchip-ksz.h
@@ -0,0 +1,29 @@
+/*
+ * Microchip KSZ series switch platform data
+ *
+ * Copyright (C) 2017
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef __MICROCHIP_KSZ_H
+#define __MICROCHIP_KSZ_H
+
+#include <linux/kernel.h>
+
+struct ksz_platform_data {
+	u32 chip_id;
+	u16 enabled_ports;
+};
+
+#endif
-- 
2.7.4
