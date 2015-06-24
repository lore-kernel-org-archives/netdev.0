From: <igal.liberman@freescale.com>
Subject: [v2,3/9] fsl/fman: Add the FMan MAC FLIB
Date: Wed, 24 Jun 2015 22:34:18 +0300
Message-ID: <1435174458-452-1-git-send-email-igal.liberman@freescale.com>
Reply-To: <igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <scottwood@freescale.com>,
	<madalin.bucur@freescale.com>, <pebolle@tiscali.nl>,
	Igal Liberman <Igal.Liberman@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0138.outbound.protection.outlook.com ([157.56.111.138]:28879
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752443AbbFXTec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 15:34:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igal Liberman <Igal.Liberman@freescale.com>

The FMan MAC FLib provides basic API used by the drivers to
configure and control the FMan MAC hardware.

Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/Makefile       |    1 +
 .../net/ethernet/freescale/fman/flib/fsl_enet.h    |  135 ++++
 .../ethernet/freescale/fman/flib/fsl_fman_dtsec.h  |  830 ++++++++++++++++++++
 .../freescale/fman/flib/fsl_fman_dtsec_mii_acc.h   |   93 +++
 .../ethernet/freescale/fman/flib/fsl_fman_memac.h  |  443 +++++++++++
 .../freescale/fman/flib/fsl_fman_memac_mii_acc.h   |   75 ++
 .../ethernet/freescale/fman/flib/fsl_fman_tgec.h   |  402 ++++++++++
 drivers/net/ethernet/freescale/fman/mac/Makefile   |    5 +
 .../net/ethernet/freescale/fman/mac/fman_dtsec.c   |  530 +++++++++++++
 .../freescale/fman/mac/fman_dtsec_mii_acc.c        |  168 ++++
 .../net/ethernet/freescale/fman/mac/fman_memac.c   |  365 +++++++++
 .../freescale/fman/mac/fman_memac_mii_acc.c        |  217 +++++
 .../net/ethernet/freescale/fman/mac/fman_tgec.c    |  215 +++++
 13 files changed, 3479 insertions(+)
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_enet.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_dtsec.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_dtsec_mii_acc.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac_mii_acc.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_tgec.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_memac.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_tgec.c

diff --git a/drivers/net/ethernet/freescale/fman/Makefile b/drivers/net/ethernet/freescale/fman/Makefile
index 50a4de2..1841b03 100644
--- a/drivers/net/ethernet/freescale/fman/Makefile
+++ b/drivers/net/ethernet/freescale/fman/Makefile
@@ -5,3 +5,4 @@ obj-y		+= fsl_fman.o
 fsl_fman-objs	:= fman.o
 
 obj-y	+= port/
+obj-y	+= mac/
diff --git a/drivers/net/ethernet/freescale/fman/flib/fsl_enet.h b/drivers/net/ethernet/freescale/fman/flib/fsl_enet.h
new file mode 100644
index 0000000..4b79e83
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/flib/fsl_enet.h
@@ -0,0 +1,135 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_ENET_H
+#define __FSL_ENET_H
+
+/* Ethernet MAC-PHY Interface */
+enum enet_interface {
+	E_ENET_IF_MII = 0x00010000,	      /* MII interface */
+	E_ENET_IF_RMII = 0x00020000,	      /* RMII interface */
+	E_ENET_IF_SMII = 0x00030000,	      /* SMII interface */
+	E_ENET_IF_GMII = 0x00040000,	      /* GMII interface */
+	E_ENET_IF_RGMII = 0x00050000,	      /* RGMII interface */
+	E_ENET_IF_TBI = 0x00060000,	      /* TBI interface */
+	E_ENET_IF_RTBI = 0x00070000,	      /* RTBI interface */
+	E_ENET_IF_SGMII = 0x00080000,	      /* SGMII interface */
+	E_ENET_IF_XGMII = 0x00090000,	      /* XGMII interface */
+	E_ENET_IF_QSGMII = 0x000a0000,	      /* QSGMII interface */
+	E_ENET_IF_XFI = 0x000b0000	      /* XFI interface */
+};
+
+/* Ethernet Speed (nominal data rate) */
+enum enet_speed {
+	E_ENET_SPEED_10 = 10,		/* 10 Mbps */
+	E_ENET_SPEED_100 = 100,		/* 100 Mbps */
+	E_ENET_SPEED_1000 = 1000,	/* 1000 Mbps = 1 Gbps */
+	E_ENET_SPEED_10000 = 10000	/* 10000 Mbps = 10 Gbps */
+};
+
+/* SGMII/QSGII interface with 1000BaseX auto-negotiation between MAC
+ * and phy or backplane;
+ * Note: 1000BaseX auto-negotiation relates only to interface between MAC
+ * and phy/backplane, SGMII phy can still synchronize with far-end phy at
+ * 10Mbps, 100Mbps or 1000Mbps
+ */
+#define ENET_IF_SGMII_BASEX 0x80000000
+
+enum enet_mode {
+	E_ENET_MODE_INVALID = 0,
+	/* Invalid Ethernet mode */
+	E_ENET_MODE_MII_10 = (E_ENET_IF_MII | E_ENET_SPEED_10),
+	/* 10 Mbps MII */
+	E_ENET_MODE_MII_100 = (E_ENET_IF_MII | E_ENET_SPEED_100),
+	/* 100 Mbps MII */
+	E_ENET_MODE_RMII_10 = (E_ENET_IF_RMII | E_ENET_SPEED_10),
+	/* 10 Mbps RMII */
+	E_ENET_MODE_RMII_100 = (E_ENET_IF_RMII | E_ENET_SPEED_100),
+	/* 100 Mbps RMII */
+	E_ENET_MODE_SMII_10 = (E_ENET_IF_SMII | E_ENET_SPEED_10),
+	/* 10 Mbps SMII */
+	E_ENET_MODE_SMII_100 = (E_ENET_IF_SMII | E_ENET_SPEED_100),
+	/* 100 Mbps SMII */
+	E_ENET_MODE_GMII_1000 = (E_ENET_IF_GMII | E_ENET_SPEED_1000),
+	/* 1000 Mbps GMII */
+	E_ENET_MODE_RGMII_10 = (E_ENET_IF_RGMII | E_ENET_SPEED_10),
+	/* 10 Mbps RGMII */
+	E_ENET_MODE_RGMII_100 = (E_ENET_IF_RGMII | E_ENET_SPEED_100),
+	/* 100 Mbps RGMII */
+	E_ENET_MODE_RGMII_1000 = (E_ENET_IF_RGMII | E_ENET_SPEED_1000),
+	/* 1000 Mbps RGMII */
+	E_ENET_MODE_TBI_1000 = (E_ENET_IF_TBI | E_ENET_SPEED_1000),
+	/* 1000 Mbps TBI */
+	E_ENET_MODE_RTBI_1000 = (E_ENET_IF_RTBI | E_ENET_SPEED_1000),
+	/* 1000 Mbps RTBI */
+	E_ENET_MODE_SGMII_10 = (E_ENET_IF_SGMII | E_ENET_SPEED_10),
+	/* 10 Mbps SGMII with auto-negotiation between MAC and
+	 * SGMII phy according to Cisco SGMII specification
+	 */
+	E_ENET_MODE_SGMII_100 = (E_ENET_IF_SGMII | E_ENET_SPEED_100),
+	/* 100 Mbps SGMII with auto-negotiation between MAC and
+	 * SGMII phy according to Cisco SGMII specification
+	 */
+	E_ENET_MODE_SGMII_1000 = (E_ENET_IF_SGMII | E_ENET_SPEED_1000),
+	/* 1000 Mbps SGMII with auto-negotiation between MAC and
+	 * SGMII phy according to Cisco SGMII specification
+	 */
+	E_ENET_MODE_SGMII_BASEX_10 = (ENET_IF_SGMII_BASEX | E_ENET_IF_SGMII
+				      | E_ENET_SPEED_10),
+	/* 10 Mbps SGMII with 1000BaseX auto-negotiation between
+	 * MAC and SGMII phy or backplane
+	 */
+	E_ENET_MODE_SGMII_BASEX_100 = (ENET_IF_SGMII_BASEX | E_ENET_IF_SGMII
+				       | E_ENET_SPEED_100),
+	/* 100 Mbps SGMII with 1000BaseX auto-negotiation between
+	 * MAC and SGMII phy or backplane
+	 */
+	E_ENET_MODE_SGMII_BASEX_1000 = (ENET_IF_SGMII_BASEX | E_ENET_IF_SGMII
+					| E_ENET_SPEED_1000),
+	/* 1000 Mbps SGMII with 1000BaseX auto-negotiation between
+	 * MAC and SGMII phy or backplane
+	 */
+	E_ENET_MODE_QSGMII_1000 = (E_ENET_IF_QSGMII | E_ENET_SPEED_1000),
+	/* 1000 Mbps QSGMII with auto-negotiation between MAC and
+	 * QSGMII phy according to Cisco QSGMII specification
+	 */
+	E_ENET_MODE_QSGMII_BASEX_1000 = (ENET_IF_SGMII_BASEX | E_ENET_IF_QSGMII
+					 | E_ENET_SPEED_1000),
+	/* 1000 Mbps QSGMII with 1000BaseX auto-negotiation between
+	 * MAC and QSGMII phy or backplane
+	 */
+	E_ENET_MODE_XGMII_10000 = (E_ENET_IF_XGMII | E_ENET_SPEED_10000),
+	/* 10000 Mbps XGMII */
+	E_ENET_MODE_XFI_10000 = (E_ENET_IF_XFI | E_ENET_SPEED_10000)
+	/* 10000 Mbps XFI */
+};
+
+#endif	/* __FSL_ENET_H */
diff --git a/drivers/net/ethernet/freescale/fman/flib/fsl_fman_dtsec.h b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_dtsec.h
new file mode 100644
index 0000000..128e2bf
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_dtsec.h
@@ -0,0 +1,830 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_DTSEC_H
+#define __FSL_FMAN_DTSEC_H
+
+#include <linux/io.h>
+
+#include "fsl_enet.h"
+
+/* dTSEC Init sequence
+ * To prepare dTSEC block for transfer use the following call sequence:
+ * - fman_dtsec_defconfig() - This step is optional and yet recommended. Its
+ * use is to obtain the default dTSEC configuration parameters.
+ * - Change dtsec configuration in &dtsec_cfg. This structure will be used
+ * to customize the dTSEC behavior.
+ * - fman_dtsec_init() - Applies the configuration on dTSEC hardware. Note that
+ * dTSEC is initialized while both Tx and Rx are disabled.
+ * - fman_dtsec_set_mac_address() - Set the station address (mac address).
+ * This is used by dTSEC to match against received packets.
+ *
+ * - fman_dtsec_adjust_link() - Set the link speed and duplex parameters
+ * after the PHY establishes the link.
+ * - dtsec_enable_tx() and dtsec_enable_rx() to enable transmission and
+ * reception.
+ */
+
+/*  dTSEC Graceful stop
+ * To temporary stop dTSEC activity use fman_dtsec_stop_tx() and
+ * fman_dtsec_stop_rx(). Note that these functions request dTSEC graceful stop
+ * but return before this stop is complete. To query for graceful stop
+ * completion use fman_dtsec_get_event() and check DTSEC_IEVENT_GTSC and
+ * DTSEC_IEVENT_GRSC bits. Alternatively the dTSEC interrupt mask can be set to
+ * enable graceful stop interrupts.
+ * To resume operation after graceful stop use fman_dtsec_start_tx() and
+ * fman_dtsec_start_rx().
+ */
+
+/* dTSEC interrupt handling
+ *
+ * This code does not provide an interrupt handler for dTSEC. Instead this
+ * handler should be implemented and registered to the operating system by the
+ * caller. Some primitives for accessing the event status and mask registers
+ * are provided.
+ * See "dTSEC Events" section for a list of events that dTSEC can generate.
+ */
+
+/* dTSEC Events
+ * Interrupt events cause dTSEC event bits to be set. Software may poll the
+ * event register at any time to check for pending interrupts. If an event
+ * occurs and its corresponding enable bit is set in the interrupt mask
+ * register, the event also causes a hardware interrupt at the PIC.
+ * To poll for event status use the fman_dtsec_get_event() function.
+ * To configure the interrupt mask use fman_dtsec_enable_interrupt() and
+ * fman_dtsec_disable_interrupt() functions.
+ * After servicing a dTSEC interrupt use fman_dtsec_ack_event to reset the
+ * serviced event bit.
+ * The following events may be signaled by dTSEC hardware:
+ * %DTSEC_IEVENT_BABR - Babbling receive error. This bit indicates that
+ * a frame was received with length in excess of the MAC's maximum frame length
+ * register.
+ * %DTSEC_IEVENT_RXC - Receive control (pause frame) interrupt. A pause
+ * control frame was received while Rx pause frame handling is enabled.
+ * Also see fman_dtsec_handle_rx_pause().
+ * %DTSEC_IEVENT_MSRO - MIB counter overflow. The count for one of the MIB
+ * counters has exceeded the size of its register.
+ * %DTSEC_IEVENT_GTSC - Graceful transmit stop complete. Graceful stop is now
+ * complete. The transmitter is in a stopped state, in which only pause frames
+ * can be transmitted.
+ * Also see fman_dtsec_stop_tx().
+ * %DTSEC_IEVENT_BABT - Babbling transmit error. The transmitted frame length
+ * has exceeded the value in the MAC's Maximum Frame Length register.
+ * %DTSEC_IEVENT_TXC - Transmit control (pause frame) interrupt. his bit
+ * indicates that a control frame was transmitted.
+ * %DTSEC_IEVENT_TXE - Transmit error. This bit indicates that an error
+ * occurred on the transmitted channel. This bit is set whenever any transmit
+ * error occurs which causes the dTSEC to discard all or part of a frame
+ * (LC, CRL, XFUN).
+ * %DTSEC_IEVENT_LC - Late collision. This bit indicates that a collision
+ * occurred beyond the collision window (slot time) in half-duplex mode.
+ * The frame is truncated with a bad CRC and the remainder of the frame
+ * is discarded.
+ * %DTSEC_IEVENT_CRL - Collision retry limit. is bit indicates that the number
+ * of successive transmission collisions has exceeded the MAC's half-duplex
+ * register's retransmission maximum count. The frame is discarded without
+ * being transmitted and transmission of the next frame commences. This only
+ * occurs while in half-duplex mode.
+ * The number of retransmit attempts can be set in
+ * &dtsec_halfdup_cfg.retransmit before calling fman_dtsec_init().
+ * %DTSEC_IEVENT_XFUN - Transmit FIFO underrun. This bit indicates that the
+ * transmit FIFO became empty before the complete frame was transmitted.
+ * The frame is truncated with a bad CRC and the remainder of the frame is
+ * discarded.
+ * %DTSEC_IEVENT_MAG - TBD
+ * %DTSEC_IEVENT_MMRD - MII management read completion.
+ * %DTSEC_IEVENT_MMWR - MII management write completion.
+ * %DTSEC_IEVENT_GRSC - Graceful receive stop complete. It allows the user to
+ * know if the system has completed the stop and it is safe to write to receive
+ * registers (status, control or configuration registers) that are used by the
+ * system during normal operation.
+ * %DTSEC_IEVENT_TDPE - Internal data error on transmit. This bit indicates
+ * that the dTSEC has detected a parity error on its stored transmit data, which
+ * is likely to compromise the validity of recently transferred frames.
+ * %DTSEC_IEVENT_RDPE - Internal data error on receive. This bit indicates that
+ * the dTSEC has detected a parity error on its stored receive data, which is
+ * likely to compromise the validity of recently transferred frames.
+ */
+/* Interrupt Mask Register (IMASK) */
+#define DTSEC_IMASK_BREN	0x80000000
+#define DTSEC_IMASK_RXCEN	0x40000000
+#define DTSEC_IMASK_MSROEN	0x04000000
+#define DTSEC_IMASK_GTSCEN	0x02000000
+#define DTSEC_IMASK_BTEN	0x01000000
+#define DTSEC_IMASK_TXCEN	0x00800000
+#define DTSEC_IMASK_TXEEN	0x00400000
+#define DTSEC_IMASK_LCEN	0x00040000
+#define DTSEC_IMASK_CRLEN	0x00020000
+#define DTSEC_IMASK_XFUNEN	0x00010000
+#define DTSEC_IMASK_ABRTEN	0x00008000
+#define DTSEC_IMASK_IFERREN	0x00004000
+#define DTSEC_IMASK_MAGEN	0x00000800
+#define DTSEC_IMASK_MMRDEN	0x00000400
+#define DTSEC_IMASK_MMWREN	0x00000200
+#define DTSEC_IMASK_GRSCEN	0x00000100
+#define DTSEC_IMASK_TDPEEN	0x00000002
+#define DTSEC_IMASK_RDPEEN	0x00000001
+
+#define DTSEC_EVENTS_MASK				\
+	((uint32_t)(DTSEC_IMASK_BREN	| \
+				DTSEC_IMASK_RXCEN   | \
+				DTSEC_IMASK_BTEN    | \
+				DTSEC_IMASK_TXCEN   | \
+				DTSEC_IMASK_TXEEN   | \
+				DTSEC_IMASK_ABRTEN  | \
+				DTSEC_IMASK_LCEN    | \
+				DTSEC_IMASK_CRLEN   | \
+				DTSEC_IMASK_XFUNEN  | \
+				DTSEC_IMASK_IFERREN | \
+				DTSEC_IMASK_MAGEN   | \
+				DTSEC_IMASK_TDPEEN  | \
+				DTSEC_IMASK_RDPEEN))
+
+/* dtsec timestamp event bits */
+#define TMR_PEMASK_TSREEN	0x00010000
+#define TMR_PEVENT_TSRE		0x00010000
+
+/* Group address bit indication */
+#define MAC_GROUP_ADDRESS	0x0000010000000000ULL
+/* size in bytes of L2 address */
+#define MAC_ADDRLEN		6
+
+#define DEFAULT_HALFDUP_ON		false
+#define DEFAULT_HALFDUP_RETRANSMIT	0xf
+#define DEFAULT_HALFDUP_COLL_WINDOW	0x37
+#define DEFAULT_HALFDUP_EXCESS_DEFER	true
+#define DEFAULT_HALFDUP_NO_BACKOFF	false
+#define DEFAULT_HALFDUP_BP_NO_BACKOFF	false
+#define DEFAULT_HALFDUP_ALT_BACKOFF_VAL	0x0A
+#define DEFAULT_HALFDUP_ALT_BACKOFF_EN	false
+#define DEFAULT_RX_DROP_BCAST		false
+#define DEFAULT_RX_SHORT_FRM		true
+#define DEFAULT_RX_LEN_CHECK		false
+#define DEFAULT_TX_PAD_CRC		true
+#define DEFAULT_TX_CRC			false
+#define DEFAULT_RX_CTRL_ACC		false
+#define DEFAULT_TX_PAUSE_TIME		0xf000
+#define DEFAULT_TBIPA			5
+#define DEFAULT_RX_PREPEND		0
+#define DEFAULT_PTP_TSU_EN		true
+#define DEFAULT_PTP_EXCEPTION_EN	true
+#define DEFAULT_PREAMBLE_LEN		7
+#define DEFAULT_RX_PREAMBLE		false
+#define DEFAULT_TX_PREAMBLE		false
+#define DEFAULT_LOOPBACK		false
+#define DEFAULT_RX_TIME_STAMP_EN	false
+#define DEFAULT_TX_TIME_STAMP_EN	false
+#define DEFAULT_RX_FLOW			true
+#define DEFAULT_TX_FLOW			true
+#define DEFAULT_RX_GROUP_HASH_EXD	false
+#define DEFAULT_TX_PAUSE_TIME_EXTD	0
+#define DEFAULT_RX_PROMISC		false
+#define DEFAULT_NON_BACK_TO_BACK_IPG1	0x40
+#define DEFAULT_NON_BACK_TO_BACK_IPG2	0x60
+#define DEFAULT_MIN_IFG_ENFORCEMENT	0x50
+#define DEFAULT_BACK_TO_BACK_IPG	0x60
+#define DEFAULT_MAXIMUM_FRAME		0x600
+#define DEFAULT_TBI_PHY_ADDR		5
+#define DEFAULT_WAKE_ON_LAN		false
+
+/* register related defines (bits, field offsets..) */
+#define DTSEC_ID1_ID			0xffff0000
+#define DTSEC_ID1_REV_MJ		0x0000FF00
+#define DTSEC_ID1_REV_MN		0x000000ff
+
+#define DTSEC_ID2_INT_REDUCED_OFF	0x00010000
+#define DTSEC_ID2_INT_NORMAL_OFF	0x00020000
+
+#define DTSEC_ECNTRL_CLRCNT		0x00004000
+#define DTSEC_ECNTRL_AUTOZ		0x00002000
+#define DTSEC_ECNTRL_STEN		0x00001000
+#define DTSEC_ECNTRL_CFG_RO		0x80000000
+#define DTSEC_ECNTRL_GMIIM		0x00000040
+#define DTSEC_ECNTRL_TBIM		0x00000020
+#define DTSEC_ECNTRL_SGMIIM		0x00000002
+#define DTSEC_ECNTRL_RPM		0x00000010
+#define DTSEC_ECNTRL_R100M		0x00000008
+#define DTSEC_ECNTRL_RMM		0x00000004
+#define DTSEC_ECNTRL_QSGMIIM		0x00000001
+
+#define DTSEC_TCTRL_THDF		0x00000800
+#define DTSEC_TCTRL_TTSE		0x00000040
+#define DTSEC_TCTRL_GTS			0x00000020
+#define DTSEC_TCTRL_TFC_PAUSE		0x00000010
+
+/* PTV offsets */
+#define PTV_PTE_OFST		16
+
+#define RCTRL_CFA		0x00008000
+#define RCTRL_GHTX		0x00000400
+#define RCTRL_RTSE		0x00000040
+#define RCTRL_GRS		0x00000020
+#define RCTRL_BC_REJ		0x00000010
+#define RCTRL_MPROM		0x00000008
+#define RCTRL_RSF		0x00000004
+#define RCTRL_UPROM		0x00000001
+#define RCTRL_PROM		(RCTRL_UPROM | RCTRL_MPROM)
+
+#define TMR_CTL_ESFDP		0x00000800
+#define TMR_CTL_ESFDE		0x00000400
+
+#define MACCFG1_SOFT_RESET	0x80000000
+#define MACCFG1_LOOPBACK	0x00000100
+#define MACCFG1_RX_FLOW		0x00000020
+#define MACCFG1_TX_FLOW		0x00000010
+#define MACCFG1_TX_EN		0x00000001
+#define MACCFG1_RX_EN		0x00000004
+
+#define MACCFG2_NIBBLE_MODE	0x00000100
+#define MACCFG2_BYTE_MODE	0x00000200
+#define MACCFG2_PRE_AM_RX_EN	0x00000080
+#define MACCFG2_PRE_AM_TX_EN	0x00000040
+#define MACCFG2_LENGTH_CHECK	0x00000010
+#define MACCFG2_MAGIC_PACKET_EN	0x00000008
+#define MACCFG2_PAD_CRC_EN	0x00000004
+#define MACCFG2_CRC_EN		0x00000002
+#define MACCFG2_FULL_DUPLEX	0x00000001
+
+#define PREAMBLE_LENGTH_SHIFT	12
+
+#define IPGIFG_NON_BACK_TO_BACK_IPG_1_SHIFT	24
+#define IPGIFG_NON_BACK_TO_BACK_IPG_2_SHIFT	16
+#define IPGIFG_MIN_IFG_ENFORCEMENT_SHIFT	8
+
+#define IPGIFG_NON_BACK_TO_BACK_IPG_1	0x7F000000
+#define IPGIFG_NON_BACK_TO_BACK_IPG_2	0x007F0000
+#define IPGIFG_MIN_IFG_ENFORCEMENT	0x0000FF00
+#define IPGIFG_BACK_TO_BACK_IPG		0x0000007F
+
+#define HAFDUP_ALT_BEB			0x00080000
+#define HAFDUP_BP_NO_BACKOFF		0x00040000
+#define HAFDUP_NO_BACKOFF		0x00020000
+#define HAFDUP_EXCESS_DEFER		0x00010000
+#define HAFDUP_COLLISION_WINDOW		0x000003ff
+
+#define HAFDUP_ALTERNATE_BEB_TRUNCATION_SHIFT	20
+#define HAFDUP_RETRANSMISSION_MAX_SHIFT		12
+#define HAFDUP_RETRANSMISSION_MAX		0x0000f000
+
+#define NUM_OF_HASH_REGS	8	/* Number of hash table registers */
+
+/* CAR1/2 bits */
+#define DTSEC_CAR1_TR64		0x80000000
+#define DTSEC_CAR1_TR127	0x40000000
+#define DTSEC_CAR1_TR255	0x20000000
+#define DTSEC_CAR1_TR511	0x10000000
+#define DTSEC_CAR1_TRK1		0x08000000
+#define DTSEC_CAR1_TRMAX	0x04000000
+#define DTSEC_CAR1_TRMGV	0x02000000
+
+#define DTSEC_CAR1_RBYT		0x00010000
+#define DTSEC_CAR1_RPKT		0x00008000
+#define DTSEC_CAR1_RFCS		0x00004000
+#define DTSEC_CAR1_RMCA		0x00002000
+#define DTSEC_CAR1_RBCA		0x00001000
+#define DTSEC_CAR1_RXCF		0x00000800
+#define DTSEC_CAR1_RXPF		0x00000400
+#define DTSEC_CAR1_RXUO		0x00000200
+#define DTSEC_CAR1_RALN		0x00000100
+#define DTSEC_CAR1_RFLR		0x00000080
+#define DTSEC_CAR1_RCDE		0x00000040
+#define DTSEC_CAR1_RCSE		0x00000020
+#define DTSEC_CAR1_RUND		0x00000010
+#define DTSEC_CAR1_ROVR		0x00000008
+#define DTSEC_CAR1_RFRG		0x00000004
+#define DTSEC_CAR1_RJBR		0x00000002
+#define DTSEC_CAR1_RDRP		0x00000001
+
+#define DTSEC_CAR2_TJBR		0x00080000
+#define DTSEC_CAR2_TFCS		0x00040000
+#define DTSEC_CAR2_TXCF		0x00020000
+#define DTSEC_CAR2_TOVR		0x00010000
+#define DTSEC_CAR2_TUND		0x00008000
+#define DTSEC_CAR2_TFRG		0x00004000
+#define DTSEC_CAR2_TBYT		0x00002000
+#define DTSEC_CAR2_TPKT		0x00001000
+#define DTSEC_CAR2_TMCA		0x00000800
+#define DTSEC_CAR2_TBCA		0x00000400
+#define DTSEC_CAR2_TXPF		0x00000200
+#define DTSEC_CAR2_TDFR		0x00000100
+#define DTSEC_CAR2_TEDF		0x00000080
+#define DTSEC_CAR2_TSCL		0x00000040
+#define DTSEC_CAR2_TMCL		0x00000020
+#define DTSEC_CAR2_TLCL		0x00000010
+#define DTSEC_CAR2_TXCL		0x00000008
+#define DTSEC_CAR2_TNCL		0x00000004
+#define DTSEC_CAR2_TDRP		0x00000001
+
+/* memory map */
+struct dtsec_regs {
+	/* dTSEC General Control and Status Registers */
+	uint32_t tsec_id;	/* 0x000 ETSEC_ID register */
+	uint32_t tsec_id2;	/* 0x004 ETSEC_ID2 register */
+	uint32_t ievent;	/* 0x008 Interrupt event register */
+	uint32_t imask;		/* 0x00C Interrupt mask register */
+	uint32_t reserved0010[1];
+	uint32_t ecntrl;	/* 0x014 E control register */
+	uint32_t ptv;		/* 0x018 Pause time value register */
+	uint32_t tbipa;		/* 0x01C TBI PHY address register */
+	uint32_t tmr_ctrl;	/* 0x020 Time-stamp Control register */
+	uint32_t tmr_pevent;	/* 0x024 Time-stamp event register */
+	uint32_t tmr_pemask;	/* 0x028 Timer event mask register */
+	uint32_t reserved002c[5];
+	uint32_t tctrl;		/* 0x040 Transmit control register */
+	uint32_t reserved0044[3];
+	uint32_t rctrl;		/* 0x050 Receive control register */
+	uint32_t reserved0054[11];
+	uint32_t igaddr[8];	/* 0x080-0x09C Individual/group address */
+	uint32_t gaddr[8];	/* 0x0A0-0x0BC Group address registers 0-7 */
+	uint32_t reserved00c0[16];
+	uint32_t maccfg1;	/* 0x100 MAC configuration #1 */
+	uint32_t maccfg2;	/* 0x104 MAC configuration #2 */
+	uint32_t ipgifg;	/* 0x108 IPG/IFG */
+	uint32_t hafdup;	/* 0x10C Half-duplex */
+	uint32_t maxfrm;	/* 0x110 Maximum frame */
+	uint32_t reserved0114[10];
+	uint32_t ifstat;	/* 0x13C Interface status */
+	uint32_t macstnaddr1;	/* 0x140 Station Address,part 1 */
+	uint32_t macstnaddr2;	/* 0x144 Station Address,part 2	 */
+	struct {
+		uint32_t exact_match1;	/* octets 1-4 */
+		uint32_t exact_match2;	/* octets 5-6 */
+	} macaddr[15];		/* 0x148-0x1BC mac exact match addresses 1-15 */
+	uint32_t reserved01c0[16];
+	/* 0x200 transmit and receive 64 byte frame counter */
+	uint32_t tr64;
+	/* 0x204 transmit and receive 65 to 127 byte frame counter */
+	uint32_t tr127;
+	/* 0x208 transmit and receive 128 to 255 byte frame counter */
+	uint32_t tr255;
+	/* 0x20C transmit and receive 256 to 511 byte frame counter */
+	uint32_t tr511;
+	/* 0x210 transmit and receive 512 to 1023 byte frame counter */
+	uint32_t tr1k;
+	/* 0x214 transmit and receive 1024 to 1518 byte frame counter */
+	uint32_t trmax;
+	/* 0x218 transmit and receive 1519 to 1522 byte good VLAN frame count */
+	uint32_t trmgv;
+	uint32_t rbyt;		/* 0x21C receive byte counter */
+	uint32_t rpkt;		/* 0x220 receive packet counter */
+	uint32_t rfcs;		/* 0x224 receive FCS error counter */
+	/* 0x228 RMCA receive multicast packet counter */
+	uint32_t rmca;
+	uint32_t rbca;		/* 0x22C receive broadcast packet counter */
+	uint32_t rxcf;		/* 0x230 receive control frame packet counter */
+	uint32_t rxpf;		/* 0x234 receive pause frame packet counter */
+	uint32_t rxuo;		/* 0x238 receive unknown OP code counter */
+	uint32_t raln;		/* 0x23C receive alignment error counter */
+	uint32_t rflr;		/* 0x240 receive frame length error counter */
+	uint32_t rcde;		/* 0x244 receive code error counter */
+	uint32_t rcse;		/* 0x248 receive carrier sense error counter */
+	uint32_t rund;		/* 0x24C receive undersize packet counter */
+	uint32_t rovr;		/* 0x250 receive oversize packet counter */
+	uint32_t rfrg;		/* 0x254 receive fragments counter */
+	uint32_t rjbr;		/* 0x258 receive jabber counter */
+	uint32_t rdrp;		/* 0x25C receive drop */
+	uint32_t tbyt;		/* 0x260 transmit byte counter */
+	uint32_t tpkt;		/* 0x264 transmit packet counter */
+	uint32_t tmca;		/* 0x268 transmit multicast packet counter */
+	uint32_t tbca;		/* 0x26C transmit broadcast packet counter */
+	uint32_t txpf;		/* 0x270 transmit pause control frame counter */
+	uint32_t tdfr;		/* 0x274 transmit deferral packet counter */
+	/* 0x278 transmit excessive deferral packet counter */
+	uint32_t tedf;
+	/* 0x27C transmit single collision packet counter */
+	uint32_t tscl;
+	/* 0x280 transmit multiple collision packet counter */
+	uint32_t tmcl;
+	/* 0x284 transmit late collision packet counter */
+	uint32_t tlcl;
+	/* 0x288 transmit excessive collision packet counter */
+	uint32_t txcl;
+	uint32_t tncl;		/* 0x28C transmit total collision counter */
+	uint32_t reserved0290[1];
+	uint32_t tdrp;		/* 0x294 transmit drop frame counter */
+	uint32_t tjbr;		/* 0x298 transmit jabber frame counter */
+	uint32_t tfcs;		/* 0x29C transmit FCS error counter */
+	uint32_t txcf;		/* 0x2A0 transmit control frame counter */
+	uint32_t tovr;		/* 0x2A4 transmit oversize frame counter */
+	uint32_t tund;		/* 0x2A8 transmit undersize frame counter */
+	uint32_t tfrg;		/* 0x2AC transmit fragments frame counter */
+	uint32_t car1;		/* 0x2B0 carry register one register* */
+	uint32_t car2;		/* 0x2B4 carry register two register* */
+	uint32_t cam1;		/* 0x2B8 carry register one mask register */
+	uint32_t cam2;		/* 0x2BC carry register two mask register */
+	uint32_t reserved02c0[848];
+};
+
+/* struct dtsec_cfg - dTSEC configuration
+ * Transmit half-duplex flow control, under software
+ * control for 10/100-Mbps half-duplex media. If set,
+ * back pressure is applied to media by raising carrier.
+ * halfdup_retransmit:
+ * Number of retransmission attempts following a collision.
+ * If this is exceeded dTSEC aborts transmission due to
+ * excessive collisions. The standard specifies the
+ * attempt limit to be 15.
+ * halfdup_coll_window:
+ * The number of bytes of the frame during which
+ * collisions may occur. The default value of 55
+ * corresponds to the frame byte at the end of the
+ * standard 512-bit slot time window. If collisions are
+ * detected after this byte, the late collision event is
+ * asserted and transmission of current frame is aborted.
+ * rx_drop_bcast:
+ * Discard broadcast frames. If set, all broadcast frames
+ * will be discarded by dTSEC.
+ * rx_short_frm:
+ * Accept short frames. If set, dTSEC will accept frames
+ * of length 14..63 bytes.
+ * rx_len_check:
+ * Length check for received frames. If set, the MAC
+ * checks the frame's length field on receive to ensure it
+ * matches the actual data field length. This only works
+ * for received frames with length field less than 1500.
+ * No check is performed for larger frames.
+ * tx_pad_crc:
+ * Pad and append CRC. If set, the MAC pads all
+ * transmitted short frames and appends a CRC to every
+ * frame regardless of padding requirement.
+ * tx_crc:
+ * Transmission CRC enable. If set, the MAC appends a CRC
+ * to all frames. If frames presented to the MAC have a
+ * valid length and contain a valid CRC, tx_crc should be
+ * reset.
+ * This field is ignored if tx_pad_crc is set.
+ * rx_ctrl_acc:
+ * Control frame accept. If set, this overrides 802.3
+ * standard control frame behavior, and all Ethernet frames
+ * that have an ethertype of 0x8808 are treated as normal
+ * Ethernet frames and passed up to the packet interface on
+ * a DA match. Received pause control frames are passed to
+ * the packet interface only if Rx flow control is also
+ * disabled. See fman_dtsec_handle_rx_pause() function.
+ * tx_pause_time:
+ * Transmit pause time value. This pause value is used as
+ * part of the pause frame to be sent when a transmit pause
+ * frame is initiated. If set to 0 this disables
+ * transmission of pause frames.
+ * rx_preamble:
+ * Receive preamble enable. If set, the MAC recovers the
+ * received Ethernet 7-byte preamble and passes it to the
+ * packet interface at the start of each received frame.
+ * This field should be reset for internal MAC loop-back
+ * mode.
+ * tx_preamble:	User defined preamble enable for transmitted frames.
+ * If set, a user-defined preamble must passed to the MAC
+ * and it is transmitted instead of the standard preamble.
+ * preamble_len:
+ * Length, in bytes, of the preamble field preceding each
+ * Ethernet start-of-frame delimiter byte. The default
+ * value of 0x7 should be used in order to guarantee
+ * reliable operation with IEEE 802.3 compliant hardware.
+ * rx_prepend:
+ * Packet alignment padding length. The specified number
+ * of bytes (1-31) of zero padding are inserted before the
+ * start of each received frame. For Ethernet, where
+ * optional preamble extraction is enabled, the padding
+ * appears before the preamble, otherwise the padding
+ * precedes the layer 2 header.
+ *
+ * This structure contains basic dTSEC configuration and must be passed to
+ * fman_dtsec_init() function. A default set of configuration values can be
+ * obtained by calling fman_dtsec_defconfig().
+ */
+struct dtsec_cfg {
+	bool halfdup_on;
+	bool halfdup_alt_backoff_en;
+	bool halfdup_excess_defer;
+	bool halfdup_no_backoff;
+	bool halfdup_bp_no_backoff;
+	uint8_t halfdup_alt_backoff_val;
+	uint16_t halfdup_retransmit;
+	uint16_t halfdup_coll_window;
+	bool rx_drop_bcast;
+	bool rx_short_frm;
+	bool rx_len_check;
+	bool tx_pad_crc;
+	bool tx_crc;
+	bool rx_ctrl_acc;
+	unsigned short tx_pause_time;
+	unsigned short tbipa;
+	bool ptp_tsu_en;
+	bool ptp_exception_en;
+	bool rx_preamble;
+	bool tx_preamble;
+	unsigned char preamble_len;
+	unsigned char rx_prepend;
+	bool loopback;
+	bool rx_time_stamp_en;
+	bool tx_time_stamp_en;
+	bool rx_flow;
+	bool tx_flow;
+	bool rx_group_hash_exd;
+	bool rx_promisc;
+	uint8_t tbi_phy_addr;
+	uint16_t tx_pause_time_extd;
+	uint16_t maximum_frame;
+	uint32_t non_back_to_back_ipg1;
+	uint32_t non_back_to_back_ipg2;
+	uint32_t min_ifg_enforcement;
+	uint32_t back_to_back_ipg;
+	bool wake_on_lan;
+};
+
+/**
+ * fman_dtsec_defconfig() - Get default dTSEC configuration
+ * @cfg:	pointer to configuration structure.
+ *
+ * Call this function to obtain a default set of configuration values for
+ * initializing dTSEC. The user can overwrite any of the values before calling
+ * fman_dtsec_init(), if specific configuration needs to be applied.
+ */
+void fman_dtsec_defconfig(struct dtsec_cfg *cfg);
+
+/**
+ * fman_dtsec_init() - Init dTSEC hardware block
+ * @regs:		Pointer to dTSEC register block
+ * @cfg:		dTSEC configuration data
+ * @iface_mode:		dTSEC interface mode, the type of MAC - PHY interface.
+ * @iface_speed:	1G or 10G
+ * @macaddr:		MAC station address to be assigned to the device
+ * @fm_rev_maj:		major rev number
+ * @fm_rev_min:		minor rev number
+ * @exceptions_mask:	initial exceptions mask
+ *
+ * This function initializes dTSEC and applies basic configuration.
+ *
+ * dTSEC initialization sequence:
+ * Before enabling Rx/Tx call dtsec_set_address() to set MAC address,
+ * fman_dtsec_adjust_link() to configure interface speed and duplex and finally
+ * dtsec_enable_tx()/dtsec_enable_rx() to start transmission and reception.
+ *
+ * Return: 0 if successful, an error code otherwise.
+ */
+int fman_dtsec_init(struct dtsec_regs __iomem *regs, struct dtsec_cfg *cfg,
+		    enum enet_interface iface_mode,
+		    enum enet_speed iface_speed,
+		    uint8_t *macaddr, uint8_t fm_rev_maj,
+		    uint8_t fm_rev_min, uint32_t exception_mask);
+
+/**
+ * fman_dtsec_enable() - Enable dTSEC Tx and Tx
+ * @regs:	Pointer to dTSEC register block
+ * @apply_rx:	enable rx side
+ * @apply_tx:	enable tx side
+ *
+ * This function resets Tx and Rx graceful stop bit and enables dTSEC Tx and Rx.
+ */
+void fman_dtsec_enable(struct dtsec_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx);
+
+/**
+ * fman_dtsec_disable() - Disable dTSEC Tx and Rx
+ * @regs:	Pointer to dTSEC register block
+ * @apply_rx:	disable rx side
+ * @apply_tx:	disable tx side
+ *
+ * This function disables Tx and Rx in dTSEC.
+ */
+void fman_dtsec_disable(struct dtsec_regs __iomem *regs, bool apply_rx,
+			bool apply_tx);
+
+/**
+ * fman_dtsec_get_revision() - Get dTSEC hardware revision
+ * @regs:	  Pointer to dTSEC register block
+ *
+ * Call this function to obtain the dTSEC hardware version.
+ * Return: dtsec_id content
+ */
+uint32_t fman_dtsec_get_revision(struct dtsec_regs __iomem *regs);
+
+/**
+ * fman_dtsec_set_mac_address() - Set MAC station address
+ * @regs:	  Pointer to dTSEC register block
+ * @macaddr:    MAC address array
+ *
+ * This function sets MAC station address. To enable unicast reception call
+ * this after fman_dtsec_init(). While promiscuous mode is disabled dTSEC will
+ * match the destination address of received unicast frames against this
+ * address.
+ */
+void fman_dtsec_set_mac_address(struct dtsec_regs __iomem *regs,
+				uint8_t *macaddr);
+
+/**
+ * fman_dtsec_get_mac_address() - Query MAC station address
+ * @regs:	  Pointer to dTSEC register block
+ * @macaddr:    MAC address array
+ */
+void fman_dtsec_get_mac_address(struct dtsec_regs __iomem *regs,
+				uint8_t *macaddr);
+
+/**
+ * fman_dtsec_set_uc_promisc() - Sets unicast promiscuous mode
+ * @regs:	Pointer to dTSEC register block
+ * @enable:	Enable unicast promiscuous mode
+ *
+ * Use this function to enable/disable dTSEC L2 address filtering. If the
+ * address filtering is disabled all unicast packets are accepted.
+ * To set dTSEC in promiscuous mode call both fman_dtsec_set_uc_promisc() and
+ * fman_dtsec_set_mc_promisc() to disable filtering for both unicast and
+ * multicast addresses.
+ */
+void fman_dtsec_set_uc_promisc(struct dtsec_regs __iomem *regs, bool enable);
+
+/**
+ * fman_dtsec_adjust_link() - Adjust dTSEC speed/duplex settings
+ * @regs:	Pointer to dTSEC register block
+ * @iface_mode: dTSEC interface mode
+ * @speed:	Link speed
+ * @full_dx:	True for full-duplex, false for half-duplex.
+ *
+ * This function configures the MAC to function and the desired rates. Use it
+ * to configure dTSEC after fman_dtsec_init() and whenever the link speed
+ * changes (for instance following PHY auto-negociation).
+ * Returns: 0 if successful, an error code otherwise.
+ */
+int fman_dtsec_adjust_link(struct dtsec_regs __iomem *regs,
+			   enum enet_interface iface_mode,
+			   enum enet_speed speed, bool full_dx);
+
+/**
+ * fman_dtsec_set_max_frame_len() - Set max frame length
+ * @regs:	Pointer to dTSEC register block
+ * @length:	Max frame length.
+ *
+ * Sets maximum frame length for received and transmitted frames. Frames that
+ * exceeds this length are truncated.
+ */
+void fman_dtsec_set_max_frame_len(struct dtsec_regs __iomem *regs,
+				  uint16_t length);
+
+/**
+ * fman_dtsec_get_max_frame_len() - Query max frame length
+ * @regs:	Pointer to dTSEC register block
+ *
+ * Return: the current value of the maximum frame length.
+ */
+uint16_t fman_dtsec_get_max_frame_len(struct dtsec_regs __iomem *regs);
+
+/**
+ * fman_dtsec_handle_rx_pause() - Configure pause frame handling
+ * @regs:	Pointer to dTSEC register block
+ * @en:		Enable pause frame handling in dTSEC
+ *
+ * If enabled, dTSEC will handle pause frames internally. This must be disabled
+ * if dTSEC is set in half-duplex mode.
+ * If pause frame handling is disabled and &dtsec_cfg.rx_ctrl_acc is set, pause
+ * frames will be transferred to the packet interface just like regular Ethernet
+ * frames.
+ */
+void fman_dtsec_handle_rx_pause(struct dtsec_regs __iomem *regs, bool en);
+
+/**
+ * fman_dtsec_set_tx_pause_frames() - Configure Tx pause time
+ * @regs:	Pointer to dTSEC register block
+ * @time:	Time value included in pause frames
+ *
+ * Call this function to set the time value used in transmitted pause frames.
+ * If time is 0, transmission of pause frames is disabled
+ */
+void fman_dtsec_set_tx_pause_frames(struct dtsec_regs __iomem *regs,
+				    uint16_t time);
+
+/**
+ * fman_dtsec_ack_event() - Acknowledge handled events
+ * @regs:	Pointer to dTSEC register block
+ * @ev_mask:	Events to acknowledge
+ *
+ * After handling events signaled by dTSEC in either polling or interrupt mode,
+ * call this function to reset the associated status bits in dTSEC event
+ * register.
+ */
+void fman_dtsec_ack_event(struct dtsec_regs __iomem *regs, uint32_t ev_mask);
+
+/**
+ * fman_dtsec_get_event() - Returns currently asserted events
+ * @regs:	Pointer to dTSEC register block
+ * @ev_mask:	Mask of relevant events
+ *
+ * Call this function to obtain a bit-mask of events that are currently asserted
+ * in dTSEC, taken from IEVENT register.
+ * Returns: a bit-mask of events asserted in dTSEC.
+ */
+uint32_t fman_dtsec_get_event(struct dtsec_regs __iomem *regs,
+			      uint32_t ev_mask);
+
+/**
+ * fman_dtsec_get_interrupt_mask() - Returns a bit-mask of enabled interrupts
+ * @regs:	  Pointer to dTSEC register block
+ *
+ * Call this function to obtain a bit-mask of enabled interrupts
+ * in dTSEC, taken from IMASK register.
+ * Returns: a bit-mask of enabled interrupts in dTSEC.
+ */
+uint32_t fman_dtsec_get_interrupt_mask(struct dtsec_regs __iomem *regs);
+
+void fman_dtsec_enable_tmr_interrupt(struct dtsec_regs __iomem *regs);
+
+void fman_dtsec_disable_tmr_interrupt(struct dtsec_regs __iomem *regs);
+
+/**
+ * fman_dtsec_disable_interrupt() - Disables interrupts for the specified events
+ * @regs:	Pointer to dTSEC register block
+ * @ev_mask:	Mask of relevant events
+ *
+ * Call this function to disable interrupts in dTSEC for the specified events.
+ * To enable interrupts use fman_dtsec_enable_interrupt().
+ */
+void fman_dtsec_disable_interrupt(struct dtsec_regs __iomem *regs,
+				  uint32_t ev_mask);
+
+/**
+ * fman_dtsec_enable_interrupt() - Enable interrupts for the specified events
+ * @regs:	Pointer to dTSEC register block
+ * @ev_mask:	Mask of relevant events
+ *
+ * Call this function to enable interrupts in dTSEC for the specified events.
+ * To disable interrupts use fman_dtsec_disable_interrupt().
+ */
+void fman_dtsec_enable_interrupt(struct dtsec_regs __iomem *regs,
+				 uint32_t ev_mask);
+
+/**
+ * fman_dtsec_set_bucket() - Enables/disables a filter bucket
+ * @regs:	Pointer to dTSEC register block
+ * @bucket:	Bucket index
+ * @enable:	true/false to enable/disable this bucket
+ *
+ * This function enables or disables the specified bucket. Enabling a bucket
+ * associated with an address configures dTSEC to accept received packets
+ * with that destination address.
+ * Multiple addresses may be associated with the same bucket. Disabling a
+ * bucket will affect all addresses associated with that bucket. A bucket that
+ * is enabled requires further filtering and verification in the upper layers
+ */
+void fman_dtsec_set_bucket(struct dtsec_regs __iomem *regs, int bucket,
+			   bool enable);
+
+/**
+ * fman_dtsec_set_mc_promisc() - Set multicast promiscuous mode
+ * @regs:	Pointer to dTSEC register block
+ * @enable:	Enable multicast promiscuous mode
+ *
+ * Call this to enable/disable L2 address filtering for multicast packets.
+ */
+void fman_dtsec_set_mc_promisc(struct dtsec_regs __iomem *regs, bool enable);
+
+/**
+ * fman_dtsec_get_clear_carry_regs() - Read and clear carry bits
+ * @regs:	Pointer to dTSEC register block
+ * @car1:	car1 register value
+ * @car2:	car2 register value
+ *
+ * When set, the carry bits signal that an overflow occurred on the
+ * corresponding counters.
+ * Note that the carry bits (CAR1-2 registers) will assert the
+ * %DTSEC_IEVENT_MSRO interrupt if unmasked (via CAM1-2 regs).
+ * Return: true if overflow occurred, otherwise - false
+ */
+bool fman_dtsec_get_clear_carry_regs(struct dtsec_regs __iomem *regs,
+				     uint32_t *car1, uint32_t *car2);
+
+uint32_t fman_dtsec_check_and_clear_tmr_event(struct dtsec_regs __iomem *regs);
+
+void fman_dtsec_start_tx(struct dtsec_regs __iomem *regs);
+void fman_dtsec_start_rx(struct dtsec_regs __iomem *regs);
+void fman_dtsec_stop_tx(struct dtsec_regs __iomem *regs);
+void fman_dtsec_stop_rx(struct dtsec_regs __iomem *regs);
+uint32_t fman_dtsec_get_rctrl(struct dtsec_regs __iomem *regs);
+
+#endif	/* __FSL_FMAN_DTSEC_H */
diff --git a/drivers/net/ethernet/freescale/fman/flib/fsl_fman_dtsec_mii_acc.h b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_dtsec_mii_acc.h
new file mode 100644
index 0000000..5d673da
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_dtsec_mii_acc.h
@@ -0,0 +1,93 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_DTSEC_MII_ACC_H
+#define __FSL_FMAN_DTSEC_MII_ACC_H
+
+#include <linux/io.h>
+
+/* MII Management Configuration Register */
+#define MIIMCFG_RESET_MGMT		0x80000000
+#define MIIMCFG_MGNTCLK_MASK		0x00000007
+#define MIIMCFG_MGNTCLK_SHIFT		0
+
+/* MII	Management Command Register */
+#define MIIMCOM_SCAN_CYCLE		0x00000002
+#define MIIMCOM_READ_CYCLE		0x00000001
+
+/* MII	Management Address Register */
+#define MIIMADD_PHY_ADDR_SHIFT		8
+#define MIIMADD_PHY_ADDR_MASK		0x00001f00
+
+#define MIIMADD_REG_ADDR_SHIFT		0
+#define MIIMADD_REG_ADDR_MASK		0x0000001f
+
+/* MII Management Indicator Register */
+#define MIIMIND_BUSY			0x00000001
+
+/* PHY Control Register */
+#define PHY_CR_PHY_RESET    0x8000
+#define PHY_CR_LOOPBACK	    0x4000
+#define PHY_CR_SPEED0	    0x2000
+#define PHY_CR_ANE	    0x1000
+#define PHY_CR_RESET_AN	    0x0200
+#define PHY_CR_FULLDUPLEX   0x0100
+#define PHY_CR_SPEED1	    0x0040
+
+#define PHY_TBICON_SRESET   0x8000
+#define PHY_TBICON_SPEED2   0x0020
+#define PHY_TBICON_CLK_SEL  0x0020
+#define PHY_TBIANA_SGMII    0x4001
+#define PHY_TBIANA_1000X    0x01a0
+/* register map */
+
+/* MII Configuration Control Memory Map Registers */
+struct dtsec_mii_reg {
+	uint32_t reserved1[72];
+	uint32_t miimcfg;	/* MII Mgmt:configuration */
+	uint32_t miimcom;	/* MII Mgmt:command	  */
+	uint32_t miimadd;	/* MII Mgmt:address	  */
+	uint32_t miimcon;	/* MII Mgmt:control 3	  */
+	uint32_t miimstat;	/* MII Mgmt:status	  */
+	uint32_t miimind;	/* MII Mgmt:indicators	  */
+};
+
+void fman_dtsec_mii_reset(struct dtsec_mii_reg __iomem *regs);
+void fman_dtsec_mii_init(struct dtsec_mii_reg __iomem *regs,
+			 uint16_t dtsec_freq);
+int fman_dtsec_mii_write_reg(struct dtsec_mii_reg __iomem *regs,
+			     uint8_t addr,
+			     uint8_t reg, uint16_t data, uint16_t dtsec_freq);
+int fman_dtsec_mii_read_reg(struct dtsec_mii_reg __iomem *regs,
+			    uint8_t addr,
+			    uint8_t reg, uint16_t *data, uint16_t dtsec_freq);
+
+#endif	/* __FSL_FMAN_DTSEC_MII_ACC_H */
diff --git a/drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac.h b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac.h
new file mode 100644
index 0000000..fe35477
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac.h
@@ -0,0 +1,443 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_MEMAC_H
+#define __FSL_FMAN_MEMAC_H
+
+#include <linux/io.h>
+
+#include "fsl_enet.h"
+/* Num of additional exact match MAC adr regs */
+#define MEMAC_NUM_OF_PADDRS 7
+
+/* Control and Configuration Register (COMMAND_CONFIG) */
+/* 00 Magic Packet detection */
+#define CMD_CFG_MG		0x80000000
+/* 07 Rx low power indication */
+#define CMD_CFG_REG_LOWP_RXETY	0x01000000
+/* 08 Tx Low Power Idle Enable */
+#define CMD_CFG_TX_LOWP_ENA	0x00800000
+/* 10 Disable SFD check */
+#define CMD_CFG_SFD_ANY		0x00200000
+/* 12 Enable PFC */
+#define CMD_CFG_PFC_MODE	0x00080000
+/* 14 Payload length check disable */
+#define CMD_CFG_NO_LEN_CHK	0x00020000
+/* 15 Force idle generation */
+#define CMD_CFG_SEND_IDLE	0x00010000
+/* 18 Control frame rx enable */
+#define CMD_CFG_CNT_FRM_EN	0x00002000
+/* 19 S/W Reset, self clearing bit */
+#define CMD_CFG_SW_RESET	0x00001000
+/* 20 Enable Tx padding of frames */
+#define CMD_CFG_TX_PAD_EN	0x00000800
+/* 21 XGMII/GMII loopback enable */
+#define CMD_CFG_LOOPBACK_EN	0x00000400
+/* 22 Tx source MAC addr insertion */
+#define CMD_CFG_TX_ADDR_INS	0x00000200
+/* 23 Ignore Pause frame quanta */
+#define CMD_CFG_PAUSE_IGNORE	0x00000100
+/* 24 Terminate/frwd Pause frames */
+#define CMD_CFG_PAUSE_FWD	0x00000080
+/* 25 Terminate/frwd CRC of frames */
+#define CMD_CFG_CRC_FWD		0x00000040
+/* 26 Frame padding removal */
+#define CMD_CFG_PAD_EN		0x00000020
+/* 27 Promiscuous operation enable */
+#define CMD_CFG_PROMIS_EN	0x00000010
+/* 28 WAN mode enable */
+#define CMD_CFG_WAN_MODE	0x00000008
+/* 30 MAC receive path enable */
+#define CMD_CFG_RX_EN		0x00000002
+/* 31 MAC transmit path enable */
+#define CMD_CFG_TX_EN		0x00000001
+
+/* Transmit FIFO Sections Register (TX_FIFO_SECTIONS) */
+#define TX_FIFO_SECTIONS_TX_EMPTY_MASK			0xFFFF0000
+#define TX_FIFO_SECTIONS_TX_AVAIL_MASK			0x0000FFFF
+#define TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_10G		0x00400000
+#define TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_1G		0x00100000
+#define TX_FIFO_SECTIONS_TX_EMPTY_PFC_10G		0x00360000
+#define TX_FIFO_SECTIONS_TX_EMPTY_PFC_1G		0x00040000
+#define TX_FIFO_SECTIONS_TX_AVAIL_10G			0x00000019
+#define TX_FIFO_SECTIONS_TX_AVAIL_1G			0x00000020
+#define TX_FIFO_SECTIONS_TX_AVAIL_SLOW_10G		0x00000060
+
+#define GET_TX_EMPTY_DEFAULT_VALUE(_val)				\
+do {									\
+	_val &= ~TX_FIFO_SECTIONS_TX_EMPTY_MASK;			\
+	((_val == TX_FIFO_SECTIONS_TX_AVAIL_10G) ?			\
+			(_val |= TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_10G) :\
+			(_val |= TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_1G));\
+} while (0)
+
+#define GET_TX_EMPTY_PFC_VALUE(_val)					\
+do {									\
+	_val &= ~TX_FIFO_SECTIONS_TX_EMPTY_MASK;			\
+	((_val == TX_FIFO_SECTIONS_TX_AVAIL_10G) ?			\
+			(_val |= TX_FIFO_SECTIONS_TX_EMPTY_PFC_10G) :	\
+			(_val |= TX_FIFO_SECTIONS_TX_EMPTY_PFC_1G));	\
+} while (0)
+
+/* Interface Mode Register (IF_MODE) */
+/* 30-31 Mask on i/f mode bits */
+#define IF_MODE_MASK		0x00000003
+/* 30-31 XGMII (10G) interface */
+#define IF_MODE_XGMII		0x00000000
+/* 30-31 GMII (1G) interface */
+#define IF_MODE_GMII		0x00000002
+#define IF_MODE_RGMII		0x00000004
+#define IF_MODE_RGMII_AUTO	0x00008000
+#define IF_MODE_RGMII_1000  0x00004000	/* 10 - 1000Mbps RGMII */
+#define IF_MODE_RGMII_100   0x00000000	/* 00 - 100Mbps RGMII */
+#define IF_MODE_RGMII_10    0x00002000	/* 01 - 10Mbps RGMII */
+#define IF_MODE_RGMII_SP_MASK 0x00006000	/* Setsp mask bits */
+#define IF_MODE_RGMII_FD    0x00001000	/* Full duplex RGMII */
+#define IF_MODE_HD	    0x00000040	/* Half duplex operation */
+
+/* Hash table Control Register (HASHTABLE_CTRL) */
+#define HASH_CTRL_MCAST_SHIFT	26
+/* 23 Mcast frame rx for hash */
+#define HASH_CTRL_MCAST_EN	0x00000100
+/* 26-31 Hash table address code */
+#define HASH_CTRL_ADDR_MASK	0x0000003F
+/* MAC mcast indication */
+#define GROUP_ADDRESS		0x0000010000000000LL
+#define HASH_TABLE_SIZE		64	/* Hash tbl size */
+
+/* Transmit Inter-Packet Gap Length Register (TX_IPG_LENGTH) */
+#define MEMAC_TX_IPG_LENGTH_MASK	0x0000003F
+
+/* Statistics Configuration Register (STATN_CONFIG) */
+#define STATS_CFG_CLR		0x00000004	/* 29 Reset all counters */
+#define STATS_CFG_CLR_ON_RD	0x00000002	/* 30 Clear on read */
+/* 31 Saturate at the maximum val */
+#define STATS_CFG_SATURATE	0x00000001
+
+/* Interrupt Mask Register (IMASK) */
+/* 1 Magic pkt detect indication */
+#define MEMAC_IMASK_MGI		0x40000000
+/* 2 Timestamp FIFO ECC error evnt */
+#define MEMAC_IMASK_TSECC_ER 0x20000000
+/* 6 Transmit frame ECC error evnt */
+#define MEMAC_IMASK_TECC_ER	0x02000000
+/* 7 Receive frame ECC error evnt */
+#define MEMAC_IMASK_RECC_ER	0x01000000
+
+#define MEMAC_ALL_ERRS_IMASK					\
+		((uint32_t)(MEMAC_IMASK_TSECC_ER	|	\
+			MEMAC_IMASK_TECC_ER		|	\
+			MEMAC_IMASK_RECC_ER		|	\
+			MEMAC_IMASK_MGI))
+
+/* PCS (XG). Link sync (G) */
+#define MEMAC_IEVNT_PCS			0x80000000
+/* Auto-negotiation */
+#define MEMAC_IEVNT_AN			0x40000000
+/* Link Training/New page */
+#define MEMAC_IEVNT_LT			0x20000000
+/* Magic pkt detection */
+#define MEMAC_IEVNT_MGI			0x00004000
+/* Timestamp FIFO ECC error */
+#define MEMAC_IEVNT_TS_ECC_ER		0x00002000
+/* Rx FIFO overflow */
+#define MEMAC_IEVNT_RX_FIFO_OVFL	0x00001000
+/* Tx FIFO underflow */
+#define MEMAC_IEVNT_TX_FIFO_UNFL	0x00000800
+/* Tx FIFO overflow */
+#define MEMAC_IEVNT_TX_FIFO_OVFL	0x00000400
+/* Tx frame ECC error */
+#define MEMAC_IEVNT_TX_ECC_ER		0x00000200
+/* Rx frame ECC error */
+#define MEMAC_IEVNT_RX_ECC_ER		0x00000100
+/* Link Interruption flt */
+#define MEMAC_IEVNT_LI_FAULT		0x00000080
+/* Rx FIFO empty */
+#define MEMAC_IEVNT_RX_EMPTY		0x00000040
+/* Tx FIFO empty */
+#define MEMAC_IEVNT_TX_EMPTY		0x00000020
+/* Low Power Idle */
+#define MEMAC_IEVNT_RX_LOWP		0x00000010
+/* Phy loss of signal */
+#define MEMAC_IEVNT_PHY_LOS		0x00000004
+/* Remote fault (XGMII) */
+#define MEMAC_IEVNT_REM_FAULT		0x00000002
+/* Local fault (XGMII) */
+#define MEMAC_IEVNT_LOC_FAULT		0x00000001
+
+#define DEFAULT_PAUSE_QUANTA	0xf000
+#define DEFAULT_FRAME_LENGTH	0x600
+#define DEFAULT_TX_IPG_LENGTH	12
+
+struct mac_addr {
+	/* Lower 32 bits of 48-bit MAC address */
+	uint32_t mac_addr_l;
+	/* Upper 16 bits of 48-bit MAC address */
+	uint32_t mac_addr_u;
+};
+
+/* memory map */
+struct memac_regs {
+	/* General Control and Status */
+	uint32_t res0000[2];
+	/* 0x008 Ctrl and cfg */
+	uint32_t command_config;
+	/* 0x00C-0x010 MAC_ADDR_0...1 */
+	struct mac_addr mac_addr0;
+	/* 0x014 Max frame length */
+	uint32_t maxfrm;
+	uint32_t res0018[1];
+	/* Receive FIFO configuration reg */
+	uint32_t rx_fifo_sections;
+	/* Transmit FIFO configuration reg */
+	uint32_t tx_fifo_sections;
+	uint32_t res0024[2];
+	/* 0x02C Hash table control */
+	uint32_t hashtable_ctrl;
+	uint32_t res0030[4];
+	/* 0x040 Interrupt event */
+	uint32_t ievent;
+	/* 0x044 Transmitter inter-packet-gap */
+	uint32_t tx_ipg_length;
+	uint32_t res0048;
+	/* 0x04C Interrupt mask */
+	uint32_t imask;
+	uint32_t res0050;
+	/* 0x054 Pause quanta */
+	uint32_t pause_quanta[4];
+	/* 0x064 Pause quanta threshold */
+	uint32_t pause_thresh[4];
+	/* 0x074 Receive pause status */
+	uint32_t rx_pause_status;
+	uint32_t res0078[2];
+	/* 0x80-0x0B4 mac padr */
+	struct mac_addr mac_addr[MEMAC_NUM_OF_PADDRS];
+	/* 0x0B8 Low Power Wakeup Timer */
+	uint32_t lpwake_timer;
+	/* 0x0BC Transmit EEE Low Power Timer */
+	uint32_t sleep_timer;
+	uint32_t res00c0[8];
+	/* 0x0E0 Statistics configuration */
+	uint32_t statn_config;
+	uint32_t res00e4[7];
+	/* Rx Statistics Counter */
+	uint32_t reoct_l;
+	uint32_t reoct_u;
+	uint32_t roct_l;
+	uint32_t roct_u;
+	uint32_t raln_l;
+	uint32_t raln_u;
+	uint32_t rxpf_l;
+	uint32_t rxpf_u;
+	uint32_t rfrm_l;
+	uint32_t rfrm_u;
+	uint32_t rfcs_l;
+	uint32_t rfcs_u;
+	uint32_t rvlan_l;
+	uint32_t rvlan_u;
+	uint32_t rerr_l;
+	uint32_t rerr_u;
+	uint32_t ruca_l;
+	uint32_t ruca_u;
+	uint32_t rmca_l;
+	uint32_t rmca_u;
+	uint32_t rbca_l;
+	uint32_t rbca_u;
+	uint32_t rdrp_l;
+	uint32_t rdrp_u;
+	uint32_t rpkt_l;
+	uint32_t rpkt_u;
+	uint32_t rund_l;
+	uint32_t rund_u;
+	uint32_t r64_l;
+	uint32_t r64_u;
+	uint32_t r127_l;
+	uint32_t r127_u;
+	uint32_t r255_l;
+	uint32_t r255_u;
+	uint32_t r511_l;
+	uint32_t r511_u;
+	uint32_t r1023_l;
+	uint32_t r1023_u;
+	uint32_t r1518_l;
+	uint32_t r1518_u;
+	uint32_t r1519x_l;
+	uint32_t r1519x_u;
+	uint32_t rovr_l;
+	uint32_t rovr_u;
+	uint32_t rjbr_l;
+	uint32_t rjbr_u;
+	uint32_t rfrg_l;
+	uint32_t rfrg_u;
+	uint32_t rcnp_l;
+	uint32_t rcnp_u;
+	uint32_t rdrntp_l;
+	uint32_t rdrntp_u;
+	uint32_t res01d0[12];
+	/* Tx Statistics Counter */
+	uint32_t teoct_l;
+	uint32_t teoct_u;
+	uint32_t toct_l;
+	uint32_t toct_u;
+	uint32_t res0210[2];
+	uint32_t txpf_l;
+	uint32_t txpf_u;
+	uint32_t tfrm_l;
+	uint32_t tfrm_u;
+	uint32_t tfcs_l;
+	uint32_t tfcs_u;
+	uint32_t tvlan_l;
+	uint32_t tvlan_u;
+	uint32_t terr_l;
+	uint32_t terr_u;
+	uint32_t tuca_l;
+	uint32_t tuca_u;
+	uint32_t tmca_l;
+	uint32_t tmca_u;
+	uint32_t tbca_l;
+	uint32_t tbca_u;
+	uint32_t res0258[2];
+	uint32_t tpkt_l;
+	uint32_t tpkt_u;
+	uint32_t tund_l;
+	uint32_t tund_u;
+	uint32_t t64_l;
+	uint32_t t64_u;
+	uint32_t t127_l;
+	uint32_t t127_u;
+	uint32_t t255_l;
+	uint32_t t255_u;
+	uint32_t t511_l;
+	uint32_t t511_u;
+	uint32_t t1023_l;
+	uint32_t t1023_u;
+	uint32_t t1518_l;
+	uint32_t t1518_u;
+	uint32_t t1519x_l;
+	uint32_t t1519x_u;
+	uint32_t res02a8[6];
+	uint32_t tcnp_l;
+	uint32_t tcnp_u;
+	uint32_t res02c8[14];
+	/* Line Interface Control */
+	uint32_t if_mode;	/* 0x300 Interface Mode Control */
+	uint32_t if_status;	/* 0x304 Interface Status */
+	uint32_t res0308[14];
+	/* HiGig/2 */
+	uint32_t hg_config;	/* 0x340 Control and cfg */
+	uint32_t res0344[3];
+	uint32_t hg_pause_quanta;	/* 0x350 Pause quanta */
+	uint32_t res0354[3];
+	uint32_t hg_pause_thresh;	/* 0x360 Pause quanta threshold */
+	uint32_t res0364[3];
+	uint32_t hgrx_pause_status;	/* 0x370 Receive pause status */
+	uint32_t hg_fifos_status;	/* 0x374 fifos status */
+	uint32_t rhm;		/* 0x378 rx messages counter */
+	uint32_t thm;		/* 0x37C tx messages counter */
+};
+
+struct memac_cfg {
+	bool reset_on_init;
+	bool rx_error_discard;
+	bool pause_ignore;
+	bool pause_forward_enable;
+	bool no_length_check_enable;
+	bool cmd_frame_enable;
+	bool send_idle_enable;
+	bool wan_mode_enable;
+	bool promiscuous_mode_enable;
+	bool tx_addr_ins_enable;
+	bool loopback_enable;
+	bool lgth_check_nostdr;
+	bool time_stamp_enable;
+	bool pad_enable;
+	bool phy_tx_ena_on;
+	bool rx_sfd_any;
+	bool rx_pbl_fwd;
+	bool tx_pbl_fwd;
+	bool debug_mode;
+	bool wake_on_lan;
+	uint16_t max_frame_length;
+	uint16_t pause_quanta;
+	uint32_t tx_ipg_length;
+};
+
+void fman_memac_defconfig(struct memac_cfg *cfg);
+
+int fman_memac_init(struct memac_regs __iomem *regs,
+		    struct memac_cfg *cfg,
+		    enum enet_interface enet_interface,
+		    enum enet_speed enet_speed,
+		    bool slow_10g_if,
+		    uint32_t exceptions);
+
+void fman_memac_enable(struct memac_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx);
+
+void fman_memac_disable(struct memac_regs __iomem *regs, bool apply_rx,
+			bool apply_tx);
+
+void fman_memac_set_promiscuous(struct memac_regs __iomem *regs, bool val);
+
+void fman_memac_add_addr_in_paddr(struct memac_regs __iomem *regs,
+				  uint8_t *adr, uint8_t paddr_num);
+
+void fman_memac_clear_addr_in_paddr(struct memac_regs __iomem *regs,
+				    uint8_t paddr_num);
+
+void fman_memac_set_tx_pause_frames(struct memac_regs __iomem *regs,
+				    uint8_t priority, uint16_t pause_time,
+				    uint16_t thresh_time);
+
+uint16_t fman_memac_get_max_frame_len(struct memac_regs __iomem *regs);
+
+void fman_memac_set_exception(struct memac_regs __iomem *regs, uint32_t val,
+			      bool enable);
+
+void fman_memac_reset(struct memac_regs __iomem *regs);
+
+void fman_memac_set_hash_table(struct memac_regs __iomem *regs, uint32_t val);
+
+void fman_memac_set_rx_ignore_pause_frames(struct memac_regs __iomem *regs,
+					   bool enable);
+
+uint32_t fman_memac_get_event(struct memac_regs __iomem *regs,
+			      uint32_t ev_mask);
+
+void fman_memac_ack_event(struct memac_regs __iomem *regs, uint32_t ev_mask);
+
+uint32_t fman_memac_get_interrupt_mask(struct memac_regs __iomem *regs);
+
+void fman_memac_adjust_link(struct memac_regs __iomem *regs,
+			    enum enet_interface iface_mode,
+			    enum enet_speed speed, bool full_dx);
+
+#endif	/* __FSL_FMAN_MEMAC_H */
diff --git a/drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac_mii_acc.h b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac_mii_acc.h
new file mode 100644
index 0000000..d86a1c4
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac_mii_acc.h
@@ -0,0 +1,75 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_MEMAC_MII_ACC_H
+#define __FSL_FMAN_MEMAC_MII_ACC_H
+
+#include <linux/io.h>
+
+#include "fsl_enet.h"
+/* MII Management Registers */
+#define MDIO_CFG_CLK_DIV_MASK	    0x0080ff80
+#define MDIO_CFG_HOLD_MASK	    0x0000001c
+#define MDIO_CFG_ENC45		    0x00000040
+#define MDIO_CFG_READ_ERR	    0x00000002
+#define MDIO_CFG_BSY		    0x00000001
+
+#define MDIO_CTL_PHY_ADDR_SHIFT	    5
+#define MDIO_CTL_READ		    0x00008000
+
+#define MDIO_DATA_BSY		    0x80000000
+
+/* MEMAC Internal PHY Registers - SGMII */
+#define PHY_SGMII_CR_PHY_RESET		0x8000
+#define PHY_SGMII_CR_RESET_AN		0x0200
+#define PHY_SGMII_CR_DEF_VAL		0x1140
+#define PHY_SGMII_DEV_ABILITY_SGMII	0x4001
+#define PHY_SGMII_DEV_ABILITY_1000X	0x01A0
+#define PHY_SGMII_IF_MODE_AN		0x0002
+#define PHY_SGMII_IF_MODE_SGMII		0x0001
+#define PHY_SGMII_IF_MODE_1000X		0x0000
+
+/* MII Configuration Control Memory Map Registers     */
+struct memac_mii_access_mem_map {
+	uint32_t mdio_cfg;	/* 0x030  */
+	uint32_t mdio_ctrl;	/* 0x034  */
+	uint32_t mdio_data;	/* 0x038  */
+	uint32_t mdio_addr;	/* 0x03c  */
+};
+
+int fman_memac_mii_read_phy_reg(struct memac_mii_access_mem_map __iomem
+				*mii_regs, uint8_t phy_addr, uint8_t reg,
+				uint16_t *data, enum enet_speed enet_speed);
+int fman_memac_mii_write_phy_reg(struct memac_mii_access_mem_map __iomem
+				 *mii_regs, uint8_t phy_addr, uint8_t reg,
+				 uint16_t data, enum enet_speed enet_speed);
+
+#endif	/* __MAC_API_MEMAC_MII_ACC_H */
diff --git a/drivers/net/ethernet/freescale/fman/flib/fsl_fman_tgec.h b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_tgec.h
new file mode 100644
index 0000000..fe62b10
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_tgec.h
@@ -0,0 +1,402 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_TGEC_H
+#define __FSL_FMAN_TGEC_H
+
+#include <linux/io.h>
+
+#include "fsl_enet.h"
+
+/* Transmit Inter-Packet Gap Length Register (TX_IPG_LENGTH) */
+#define TGEC_TX_IPG_LENGTH_MASK	0x000003ff
+
+/* Command and Configuration Register (COMMAND_CONFIG) */
+#define CMD_CFG_EN_TIMESTAMP	0x00100000
+#define CMD_CFG_TX_ADDR_INS_SEL	0x00080000
+#define CMD_CFG_NO_LEN_CHK	0x00020000
+#define CMD_CFG_SEND_IDLE	0x00010000
+#define CMD_CFG_RX_ER_DISC	0x00004000
+#define CMD_CFG_CMD_FRM_EN	0x00002000
+#define CMD_CFG_STAT_CLR	0x00001000
+#define CMD_CFG_LOOPBACK_EN	0x00000400
+#define CMD_CFG_TX_ADDR_INS	0x00000200
+#define CMD_CFG_PAUSE_IGNORE	0x00000100
+#define CMD_CFG_PAUSE_FWD	0x00000080
+#define CMD_CFG_PROMIS_EN	0x00000010
+#define CMD_CFG_WAN_MODE	0x00000008
+#define CMD_CFG_RX_EN		0x00000002
+#define CMD_CFG_TX_EN		0x00000001
+
+/* Interrupt Mask Register (IMASK) */
+#define TGEC_IMASK_MDIO_SCAN_EVENT	0x00010000
+#define TGEC_IMASK_MDIO_CMD_CMPL	0x00008000
+#define TGEC_IMASK_REM_FAULT		0x00004000
+#define TGEC_IMASK_LOC_FAULT		0x00002000
+#define TGEC_IMASK_TX_ECC_ER		0x00001000
+#define TGEC_IMASK_TX_FIFO_UNFL		0x00000800
+#define TGEC_IMASK_TX_FIFO_OVFL		0x00000400
+#define TGEC_IMASK_TX_ER			0x00000200
+#define TGEC_IMASK_RX_FIFO_OVFL		0x00000100
+#define TGEC_IMASK_RX_ECC_ER		0x00000080
+#define TGEC_IMASK_RX_JAB_FRM		0x00000040
+#define TGEC_IMASK_RX_OVRSZ_FRM		0x00000020
+#define TGEC_IMASK_RX_RUNT_FRM		0x00000010
+#define TGEC_IMASK_RX_FRAG_FRM		0x00000008
+#define TGEC_IMASK_RX_LEN_ER		0x00000004
+#define TGEC_IMASK_RX_CRC_ER		0x00000002
+#define TGEC_IMASK_RX_ALIGN_ER		0x00000001
+
+#define TGEC_EVENTS_MASK					\
+	((uint32_t)(TGEC_IMASK_MDIO_SCAN_EVENT			| \
+				TGEC_IMASK_MDIO_CMD_CMPL	| \
+				TGEC_IMASK_REM_FAULT		| \
+				TGEC_IMASK_LOC_FAULT		| \
+				TGEC_IMASK_TX_ECC_ER		| \
+				TGEC_IMASK_TX_FIFO_UNFL		| \
+				TGEC_IMASK_TX_FIFO_OVFL		| \
+				TGEC_IMASK_TX_ER		| \
+				TGEC_IMASK_RX_FIFO_OVFL		| \
+				TGEC_IMASK_RX_ECC_ER		| \
+				TGEC_IMASK_RX_JAB_FRM		| \
+				TGEC_IMASK_RX_OVRSZ_FRM		| \
+				TGEC_IMASK_RX_RUNT_FRM		| \
+				TGEC_IMASK_RX_FRAG_FRM		| \
+				TGEC_IMASK_RX_LEN_ER		| \
+				TGEC_IMASK_RX_CRC_ER		| \
+				TGEC_IMASK_RX_ALIGN_ER))
+
+/* Hashtable Control Register (HASHTABLE_CTRL) */
+#define TGEC_HASH_MCAST_SHIFT	23
+#define TGEC_HASH_MCAST_EN	0x00000200
+#define TGEC_HASH_ADR_MSK	0x000001ff
+
+#define DEFAULT_WAN_MODE_ENABLE		false
+#define DEFAULT_PROMISCUOUS_MODE_ENABLE	false
+#define DEFAULT_PAUSE_FORWARD_ENABLE	false
+#define DEFAULT_PAUSE_IGNORE		false
+#define DEFAULT_TX_ADDR_INS_ENABLE	false
+#define DEFAULT_LOOPBACK_ENABLE		false
+#define DEFAULT_CMD_FRAME_ENABLE	false
+#define DEFAULT_RX_ERROR_DISCARD	false
+#define DEFAULT_SEND_IDLE_ENABLE	false
+#define DEFAULT_NO_LENGTH_CHECK_ENABLE	true
+#define DEFAULT_LGTH_CHECK_NOSTDR	false
+#define DEFAULT_TIME_STAMP_ENABLE	false
+#define DEFAULT_TX_IPG_LENGTH		12
+#define DEFAULT_MAX_FRAME_LENGTH	0x600
+#define DEFAULT_PAUSE_QUANT		0xf000
+
+/* 10G memory map */
+struct tgec_regs {
+	uint32_t tgec_id;	/* 0x000 Controller ID */
+	uint32_t reserved001[1];	/* 0x004 */
+	uint32_t command_config;	/* 0x008 Control and configuration */
+	uint32_t mac_addr_0;	/* 0x00c Lower 32 bits of the MAC adr */
+	uint32_t mac_addr_1;	/* 0x010 Upper 16 bits of the MAC adr */
+	uint32_t maxfrm;	/* 0x014 Maximum frame length */
+	uint32_t pause_quant;	/* 0x018 Pause quanta */
+	uint32_t rx_fifo_sections;	/* 0x01c  */
+	uint32_t tx_fifo_sections;	/* 0x020  */
+	uint32_t rx_fifo_almost_f_e;	/* 0x024  */
+	uint32_t tx_fifo_almost_f_e;	/* 0x028  */
+	uint32_t hashtable_ctrl;	/* 0x02c Hash table control */
+	uint32_t mdio_cfg_status;	/* 0x030  */
+	uint32_t mdio_command;	/* 0x034  */
+	uint32_t mdio_data;	/* 0x038  */
+	uint32_t mdio_regaddr;	/* 0x03c  */
+	uint32_t status;	/* 0x040  */
+	uint32_t tx_ipg_len;	/* 0x044 Transmitter inter-packet-gap */
+	uint32_t mac_addr_2;	/* 0x048 Lower 32 bits of 2nd MAC adr */
+	uint32_t mac_addr_3;	/* 0x04c Upper 16 bits of 2nd MAC adr */
+	uint32_t rx_fifo_ptr_rd;	/* 0x050  */
+	uint32_t rx_fifo_ptr_wr;	/* 0x054  */
+	uint32_t tx_fifo_ptr_rd;	/* 0x058  */
+	uint32_t tx_fifo_ptr_wr;	/* 0x05c  */
+	uint32_t imask;		/* 0x060 Interrupt mask */
+	uint32_t ievent;	/* 0x064 Interrupt event */
+	uint32_t udp_port;	/* 0x068 Defines a UDP Port number */
+	uint32_t type_1588v2;	/* 0x06c Type field for 1588v2 */
+	uint32_t reserved070[4];	/* 0x070 */
+	/* 10Ge Statistics Counter */
+	uint32_t tfrm_u;	/* 80 aFramesTransmittedOK */
+	uint32_t tfrm_l;	/* 84 aFramesTransmittedOK */
+	uint32_t rfrm_u;	/* 88 aFramesReceivedOK */
+	uint32_t rfrm_l;	/* 8c aFramesReceivedOK */
+	uint32_t rfcs_u;	/* 90 aFrameCheckSequenceErrors */
+	uint32_t rfcs_l;	/* 94 aFrameCheckSequenceErrors */
+	uint32_t raln_u;	/* 98 aAlignmentErrors */
+	uint32_t raln_l;	/* 9c aAlignmentErrors */
+	uint32_t txpf_u;	/* A0 aPAUSEMACCtrlFramesTransmitted */
+	uint32_t txpf_l;	/* A4 aPAUSEMACCtrlFramesTransmitted */
+	uint32_t rxpf_u;	/* A8 aPAUSEMACCtrlFramesReceived */
+	uint32_t rxpf_l;	/* Ac aPAUSEMACCtrlFramesReceived */
+	uint32_t rlong_u;	/* B0 aFrameTooLongErrors */
+	uint32_t rlong_l;	/* B4 aFrameTooLongErrors */
+	uint32_t rflr_u;	/* B8 aInRangeLengthErrors */
+	uint32_t rflr_l;	/* Bc aInRangeLengthErrors */
+	uint32_t tvlan_u;	/* C0 VLANTransmittedOK */
+	uint32_t tvlan_l;	/* C4 VLANTransmittedOK */
+	uint32_t rvlan_u;	/* C8 VLANReceivedOK */
+	uint32_t rvlan_l;	/* Cc VLANReceivedOK */
+	uint32_t toct_u;	/* D0 if_out_octets */
+	uint32_t toct_l;	/* D4 if_out_octets */
+	uint32_t roct_u;	/* D8 if_in_octets */
+	uint32_t roct_l;	/* Dc if_in_octets */
+	uint32_t ruca_u;	/* E0 if_in_ucast_pkts */
+	uint32_t ruca_l;	/* E4 if_in_ucast_pkts */
+	uint32_t rmca_u;	/* E8 ifInMulticastPkts */
+	uint32_t rmca_l;	/* Ec ifInMulticastPkts */
+	uint32_t rbca_u;	/* F0 ifInBroadcastPkts */
+	uint32_t rbca_l;	/* F4 ifInBroadcastPkts */
+	uint32_t terr_u;	/* F8 if_out_errors */
+	uint32_t terr_l;	/* Fc if_out_errors */
+	uint32_t reserved100[2];	/* 100-108 */
+	uint32_t tuca_u;	/* 108 if_out_ucast_pkts */
+	uint32_t tuca_l;	/* 10c if_out_ucast_pkts */
+	uint32_t tmca_u;	/* 110 ifOutMulticastPkts */
+	uint32_t tmca_l;	/* 114 ifOutMulticastPkts */
+	uint32_t tbca_u;	/* 118 ifOutBroadcastPkts */
+	uint32_t tbca_l;	/* 11c ifOutBroadcastPkts */
+	uint32_t rdrp_u;	/* 120 etherStatsDropEvents */
+	uint32_t rdrp_l;	/* 124 etherStatsDropEvents */
+	uint32_t reoct_u;	/* 128 etherStatsOctets */
+	uint32_t reoct_l;	/* 12c etherStatsOctets */
+	uint32_t rpkt_u;	/* 130 etherStatsPkts */
+	uint32_t rpkt_l;	/* 134 etherStatsPkts */
+	uint32_t trund_u;	/* 138 etherStatsUndersizePkts */
+	uint32_t trund_l;	/* 13c etherStatsUndersizePkts */
+	uint32_t r64_u;		/* 140 etherStatsPkts64Octets */
+	uint32_t r64_l;		/* 144 etherStatsPkts64Octets */
+	uint32_t r127_u;	/* 148 etherStatsPkts65to127Octets */
+	uint32_t r127_l;	/* 14c etherStatsPkts65to127Octets */
+	uint32_t r255_u;	/* 150 etherStatsPkts128to255Octets */
+	uint32_t r255_l;	/* 154 etherStatsPkts128to255Octets */
+	uint32_t r511_u;	/* 158 etherStatsPkts256to511Octets */
+	uint32_t r511_l;	/* 15c etherStatsPkts256to511Octets */
+	uint32_t r1023_u;	/* 160 etherStatsPkts512to1023Octets */
+	uint32_t r1023_l;	/* 164 etherStatsPkts512to1023Octets */
+	uint32_t r1518_u;	/* 168 etherStatsPkts1024to1518Octets */
+	uint32_t r1518_l;	/* 16c etherStatsPkts1024to1518Octets */
+	uint32_t r1519x_u;	/* 170 etherStatsPkts1519toX */
+	uint32_t r1519x_l;	/* 174 etherStatsPkts1519toX */
+	uint32_t trovr_u;	/* 178 etherStatsOversizePkts */
+	uint32_t trovr_l;	/* 17c etherStatsOversizePkts */
+	uint32_t trjbr_u;	/* 180 etherStatsJabbers */
+	uint32_t trjbr_l;	/* 184 etherStatsJabbers */
+	uint32_t trfrg_u;	/* 188 etherStatsFragments */
+	uint32_t trfrg_l;	/* 18C etherStatsFragments */
+	uint32_t rerr_u;	/* 190 if_in_errors */
+	uint32_t rerr_l;	/* 194 if_in_errors */
+};
+
+/**
+ * struct tgec_cfg - TGEC configuration
+ *
+ * @rx_error_discard:    Receive Erroneous Frame Discard Enable. When set to 1
+ *	    any frame received with an error is discarded in the
+ *	    Core and not forwarded to the Client interface.
+ *	    When set to 0 (Reset value), erroneous Frames are
+ *	    forwarded to the Client interface with ff_rx_err
+ *	    asserted.
+ * @pause_ignore:	   Ignore Pause Frame Quanta. If set to 1 received pause
+ *	    frames are ignored by the MAC. When set to 0
+ *	    (Reset value) the transmit process is stopped for the
+ *	    amount of time specified in the pause quanta received
+ *	    within a pause frame.
+ * @pause_forward_enable:
+ *	    Terminate / Forward Pause Frames. If set to 1 pause
+ *	    frames are forwarded to the user application. When set
+ *	    to 0 (Reset value) pause frames are terminated and
+ *	    discarded within the MAC.
+ * @no_length_check_enable:
+ *	    Payload Length Check Disable. When set to 0
+ *	    (Reset value), the Core checks the frame's payload
+ *	    length with the Frame Length/Type field, when set to 1
+ *	    the payload length check is disabled.
+ * @cmd_frame_enable:    Enables reception of all command frames. When set to 1
+ *	    all Command Frames are accepted, when set to 0
+ *	    (Reset Value) only Pause Frames are accepted and all
+ *	    other Command Frames are rejected.
+ * @send_idle_enable:    Force Idle Generation. When set to 1, the MAC
+ *	    permanently sends XGMII Idle sequences even when faults
+ *	    are received.
+ * @wan_mode_enable:    WAN Mode Enable. Sets WAN mode (1) or LAN mode
+ *	    (0, default) of operation.
+ * @promiscuous_mode_enable:
+ *	    Enables MAC promiscuous operation. When set to 1, all
+ *	    frames are received without any MAC address filtering,
+ *	    when set to 0 (Reset value) Unicast Frames with a
+ *	    destination address not matching the Core MAC Address
+ *	    (MAC Address programmed in Registers MAC_ADDR_0 and
+ *	    MAC_ADDR_1 or the MAC address programmed in Registers
+ *	    MAC_ADDR_2 and MAC_ADDR_3) are rejected.
+ * @tx_addr_ins_enable:	 Set Source MAC Address on Transmit. If set to 1 the
+ *	    MAC overwrites the source MAC address received from the
+ *	    Client Interface with one of the MAC addresses. If set
+ *	    to 0 (Reset value), the source MAC address from the
+ *	    Client Interface is transmitted unmodified to the line.
+ * @loopback_enable:    PHY Interface Loopback. When set to 1, the signal
+ *	    loop_ena is set to '1', when set to 0 (Reset value)
+ *	    the signal loop_ena is set to 0.
+ * @lgth_check_nostdr:	The Core interprets the Length/Type field differently
+ *	    depending on the value of this Bit
+ * @time_stamp_enable:	This bit selects between enabling and disabling the
+ *	    IEEE 1588 functionality. 1: IEEE 1588 is enabled
+ *	    0: IEEE 1588 is disabled
+ * @max_frame_length:    Maximum supported received frame length.
+ *	    The 10GEC MAC supports reception of any frame size up
+ *	    to 16,352 bytes (0x3FE0). Typical settings are
+ *	    0x05EE (1,518 bytes) for standard frames.
+ *	    Default setting is 0x0600 (1,536 bytes).
+ *	    Received frames that exceed this stated maximum
+ *	    are truncated.
+ * @pause_quant:	  Pause quanta value used with transmitted pause frames.
+ *	    Each quanta represents a 512 bit-times.
+ * @tx_ipg_length:    Transmit Inter-Packet-Gap (IPG) value. A 6-bit value:
+ *	    Depending on LAN or WAN mode of operation the value has
+ *	    the following meaning: - LAN Mode: Number of octets in
+ *	    steps of 4. Valid values are 8, 12, 16, ... 100. DIC is
+ *	    fully supported (see 10.6.1 page 49) for any setting. A
+ *	    default of 12 (reset value) must be set to conform to
+ *	    IEEE802.3ae. Warning: When set to 8, PCS layers may not
+ *	    be able to perform clock rate compensation. - WAN Mode:
+ *	    Stretch factor. Valid values are 4..15. The stretch
+ *	    factor is calculated as (value+1)*8. A default of 12
+ *	    (reset value) must be set to conform to IEEE 802.3ae
+ *	    (i.e. 13*8=104). A larger value shrinks the IPG
+ *	    (increasing bandwidth).
+ *
+ * This structure contains basic TGEC configuration and must be passed to
+ * fman_tgec_init() function. A default set of configuration values can be
+ * obtained by calling fman_tgec_defconfig().
+ */
+struct tgec_cfg {
+	bool rx_error_discard;
+	bool pause_ignore;
+	bool pause_forward_enable;
+	bool no_length_check_enable;
+	bool cmd_frame_enable;
+	bool send_idle_enable;
+	bool wan_mode_enable;
+	bool promiscuous_mode_enable;
+	bool tx_addr_ins_enable;
+	bool loopback_enable;
+	bool lgth_check_nostdr;
+	bool time_stamp_enable;
+	uint16_t max_frame_length;
+	uint16_t pause_quant;
+	uint32_t tx_ipg_length;
+	bool skip_fman11_workaround;
+};
+
+void fman_tgec_defconfig(struct tgec_cfg *cfg);
+
+/**
+ * fman_tgec_init() - Init tgec hardware block
+ * @regs:		Pointer to tgec register block
+ * @cfg:		tgec configuration data
+ * @exceptions_mask:	initial exceptions mask
+ *
+ * This function initializes the tgec controller and applies its
+ * basic configuration.
+ *
+ * Return: 0 if successful, an error code otherwise.
+ */
+int fman_tgec_init(struct tgec_regs __iomem *regs, struct tgec_cfg *cfg,
+		   uint32_t exception_mask);
+
+void fman_tgec_enable(struct tgec_regs __iomem *regs, bool apply_rx,
+		      bool apply_tx);
+
+void fman_tgec_disable(struct tgec_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx);
+
+uint32_t fman_tgec_get_revision(struct tgec_regs __iomem *regs);
+
+void fman_tgec_set_mac_address(struct tgec_regs __iomem *regs,
+			       uint8_t *macaddr);
+
+void fman_tgec_set_promiscuous(struct tgec_regs __iomem *regs, bool val);
+
+/**
+ * fman_tgec_set_hash_table() - Sets the Hashtable Control Register
+ * @regs:	Pointer to TGEC register block
+ * @value:	Value to be written in Hashtable Control Register
+ */
+void fman_tgec_set_hash_table(struct tgec_regs __iomem *regs, uint32_t value);
+
+/**
+ * fman_tgec_set_tx_pause_frames() - Sets the Pause Quanta Register
+ * @regs:		Pointer to TGEC register block
+ * @pause_time:		Pause quanta value used with transmitted pause frames.
+ *
+ * Each quanta represents a 512 bit-times
+ */
+void fman_tgec_set_tx_pause_frames(struct tgec_regs __iomem *regs,
+				   uint16_t pause_time);
+
+/**
+ * fman_tgec_set_rx_ignore_pause_frames()
+ * @regs:	Pointer to TGEC register block
+ * @en:		Ignore/Respond to pause frame quanta
+ *
+ * Changes the policy WRT pause frames
+ * Sets the value of PAUSE_IGNORE field in the COMMAND_CONFIG Register
+ * 0 - MAC stops transmit process for the duration specified
+ * in the Pause frame quanta of a received Pause frame.
+ * 1 - MAC ignores received Pause frames.
+ */
+void fman_tgec_set_rx_ignore_pause_frames(struct tgec_regs __iomem *regs,
+					  bool en);
+
+uint32_t fman_tgec_get_event(struct tgec_regs __iomem *regs, uint32_t ev_mask);
+
+void fman_tgec_ack_event(struct tgec_regs __iomem *regs, uint32_t ev_mask);
+
+uint32_t fman_tgec_get_interrupt_mask(struct tgec_regs __iomem *regs);
+
+void fman_tgec_enable_interrupt(struct tgec_regs __iomem *regs,
+				uint32_t ev_mask);
+
+void fman_tgec_disable_interrupt(struct tgec_regs __iomem *regs,
+				 uint32_t ev_mask);
+
+/**
+ * fman_tgec_get_max_frame_len() - Returns the maximum frame length value
+ * @regs:	Pointer to TGEC register block
+ */
+uint16_t fman_tgec_get_max_frame_len(struct tgec_regs __iomem *regs);
+
+void fman_tgec_set_erratum_tx_fifo_corruption_10gmac_a007(struct tgec_regs
+							  __iomem *regs);
+
+#endif	/* __FSL_FMAN_TGEC_H */
diff --git a/drivers/net/ethernet/freescale/fman/mac/Makefile b/drivers/net/ethernet/freescale/fman/mac/Makefile
new file mode 100644
index 0000000..ce03e25
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/Makefile
@@ -0,0 +1,5 @@
+obj-y	+= fsl_fman_mac.o
+
+fsl_fman_mac-objs		:= fman_dtsec.o fman_dtsec_mii_acc.o	\
+				   fman_memac.o fman_memac_mii_acc.o	\
+				   fman_tgec.o
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c b/drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c
new file mode 100644
index 0000000..1949e76
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c
@@ -0,0 +1,530 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fsl_fman_dtsec.h"
+
+void fman_dtsec_stop_rx(struct dtsec_regs __iomem *regs)
+{
+	/* Assert the graceful stop bit */
+	iowrite32be(ioread32be(&regs->rctrl) | RCTRL_GRS, &regs->rctrl);
+}
+
+void fman_dtsec_stop_tx(struct dtsec_regs __iomem *regs)
+{
+	/* Assert the graceful stop bit */
+	iowrite32be(ioread32be(&regs->tctrl) | DTSEC_TCTRL_GTS, &regs->tctrl);
+}
+
+void fman_dtsec_start_tx(struct dtsec_regs __iomem *regs)
+{
+	/* clear the graceful stop bit */
+	iowrite32be(ioread32be(&regs->tctrl) & ~DTSEC_TCTRL_GTS, &regs->tctrl);
+}
+
+void fman_dtsec_start_rx(struct dtsec_regs __iomem *regs)
+{
+	/* clear the graceful stop bit */
+	iowrite32be(ioread32be(&regs->rctrl) & ~RCTRL_GRS, &regs->rctrl);
+}
+
+void fman_dtsec_defconfig(struct dtsec_cfg *cfg)
+{
+	cfg->halfdup_on = DEFAULT_HALFDUP_ON;
+	cfg->halfdup_retransmit = DEFAULT_HALFDUP_RETRANSMIT;
+	cfg->halfdup_coll_window = DEFAULT_HALFDUP_COLL_WINDOW;
+	cfg->halfdup_excess_defer = DEFAULT_HALFDUP_EXCESS_DEFER;
+	cfg->halfdup_no_backoff = DEFAULT_HALFDUP_NO_BACKOFF;
+	cfg->halfdup_bp_no_backoff = DEFAULT_HALFDUP_BP_NO_BACKOFF;
+	cfg->halfdup_alt_backoff_val = DEFAULT_HALFDUP_ALT_BACKOFF_VAL;
+	cfg->halfdup_alt_backoff_en = DEFAULT_HALFDUP_ALT_BACKOFF_EN;
+	cfg->rx_drop_bcast = DEFAULT_RX_DROP_BCAST;
+	cfg->rx_short_frm = DEFAULT_RX_SHORT_FRM;
+	cfg->rx_len_check = DEFAULT_RX_LEN_CHECK;
+	cfg->tx_pad_crc = DEFAULT_TX_PAD_CRC;
+	cfg->tx_crc = DEFAULT_TX_CRC;
+	cfg->rx_ctrl_acc = DEFAULT_RX_CTRL_ACC;
+	cfg->tx_pause_time = DEFAULT_TX_PAUSE_TIME;
+	/* PHY address 0 is reserved (DPAA RM) */
+	cfg->tbipa = DEFAULT_TBIPA;
+	cfg->rx_prepend = DEFAULT_RX_PREPEND;
+	cfg->ptp_tsu_en = DEFAULT_PTP_TSU_EN;
+	cfg->ptp_exception_en = DEFAULT_PTP_EXCEPTION_EN;
+	cfg->preamble_len = DEFAULT_PREAMBLE_LEN;
+	cfg->rx_preamble = DEFAULT_RX_PREAMBLE;
+	cfg->tx_preamble = DEFAULT_TX_PREAMBLE;
+	cfg->loopback = DEFAULT_LOOPBACK;
+	cfg->rx_time_stamp_en = DEFAULT_RX_TIME_STAMP_EN;
+	cfg->tx_time_stamp_en = DEFAULT_TX_TIME_STAMP_EN;
+	cfg->rx_flow = DEFAULT_RX_FLOW;
+	cfg->tx_flow = DEFAULT_TX_FLOW;
+	cfg->rx_group_hash_exd = DEFAULT_RX_GROUP_HASH_EXD;
+	cfg->tx_pause_time_extd = DEFAULT_TX_PAUSE_TIME_EXTD;
+	cfg->rx_promisc = DEFAULT_RX_PROMISC;
+	cfg->non_back_to_back_ipg1 = DEFAULT_NON_BACK_TO_BACK_IPG1;
+	cfg->non_back_to_back_ipg2 = DEFAULT_NON_BACK_TO_BACK_IPG2;
+	cfg->min_ifg_enforcement = DEFAULT_MIN_IFG_ENFORCEMENT;
+	cfg->back_to_back_ipg = DEFAULT_BACK_TO_BACK_IPG;
+	cfg->maximum_frame = DEFAULT_MAXIMUM_FRAME;
+	cfg->tbi_phy_addr = DEFAULT_TBI_PHY_ADDR;
+	cfg->wake_on_lan = DEFAULT_WAKE_ON_LAN;
+}
+
+int fman_dtsec_init(struct dtsec_regs __iomem *regs, struct dtsec_cfg *cfg,
+		    enum enet_interface iface_mode,
+		    enum enet_speed iface_speed,
+		    uint8_t *macaddr,
+		    uint8_t __maybe_unused fm_rev_maj,
+		    uint8_t __maybe_unused fm_rev_min, uint32_t exception_mask)
+{
+	bool is_rgmii, is_sgmii, is_qsgmii;
+	int i;
+	uint32_t tmp;
+
+	/* Soft reset */
+	iowrite32be(MACCFG1_SOFT_RESET, &regs->maccfg1);
+	iowrite32be(0, &regs->maccfg1);
+
+	/* dtsec_id2 */
+	tmp = ioread32be(&regs->tsec_id2);
+
+	/* check RGMII support */
+	if (iface_mode == E_ENET_IF_RGMII || iface_mode == E_ENET_IF_RMII)
+		if (tmp & DTSEC_ID2_INT_REDUCED_OFF)
+			return -EINVAL;
+
+	if (iface_mode == E_ENET_IF_SGMII || iface_mode == E_ENET_IF_MII)
+		if (tmp & DTSEC_ID2_INT_REDUCED_OFF)
+			return -EINVAL;
+
+	is_rgmii = (bool)((iface_mode == E_ENET_IF_RGMII) ? true : false);
+	is_sgmii = (bool)((iface_mode == E_ENET_IF_SGMII) ? true : false);
+	is_qsgmii = (bool)((iface_mode == E_ENET_IF_QSGMII) ? true : false);
+
+	tmp = 0;
+	if (is_rgmii || iface_mode == E_ENET_IF_GMII)
+		tmp |= DTSEC_ECNTRL_GMIIM;
+	if (is_sgmii)
+		tmp |= (DTSEC_ECNTRL_SGMIIM | DTSEC_ECNTRL_TBIM);
+	if (is_qsgmii)
+		tmp |= (DTSEC_ECNTRL_SGMIIM | DTSEC_ECNTRL_TBIM |
+			DTSEC_ECNTRL_QSGMIIM);
+	if (is_rgmii)
+		tmp |= DTSEC_ECNTRL_RPM;
+	if (iface_speed == E_ENET_SPEED_100)
+		tmp |= DTSEC_ECNTRL_R100M;
+
+	iowrite32be(tmp, &regs->ecntrl);
+
+	tmp = 0;
+	if (cfg->halfdup_on)
+		tmp |= DTSEC_TCTRL_THDF;
+	if (cfg->tx_time_stamp_en)
+		tmp |= DTSEC_TCTRL_TTSE;
+
+	iowrite32be(tmp, &regs->tctrl);
+
+	tmp = 0;
+
+	if (cfg->tx_pause_time)
+		tmp |= cfg->tx_pause_time;
+	if (cfg->tx_pause_time_extd)
+		tmp |= cfg->tx_pause_time_extd << PTV_PTE_OFST;
+	iowrite32be(tmp, &regs->ptv);
+
+	tmp = 0;
+	tmp |= ((uint32_t)(cfg->rx_prepend & 0x0000001f)) << 16;
+	if (cfg->rx_ctrl_acc)
+		tmp |= RCTRL_CFA;
+	if (cfg->rx_group_hash_exd)
+		tmp |= RCTRL_GHTX;
+	if (cfg->rx_time_stamp_en)
+		tmp |= RCTRL_RTSE;
+	if (cfg->rx_drop_bcast)
+		tmp |= RCTRL_BC_REJ;
+	if (cfg->rx_short_frm)
+		tmp |= RCTRL_RSF;
+	if (cfg->rx_promisc)
+		tmp |= RCTRL_PROM;
+
+	iowrite32be(tmp, &regs->rctrl);
+
+	/* Assign a Phy Address to the TBI (TBIPA).
+	 * Done also in cases where TBI is not selected to avoid conflict with
+	 * the external PHY's Physical address
+	 */
+	iowrite32be(cfg->tbipa, &regs->tbipa);
+
+	iowrite32be(0, &regs->tmr_ctrl);
+
+	if (cfg->ptp_tsu_en) {
+		tmp = 0;
+		tmp |= TMR_PEVENT_TSRE;
+		iowrite32be(tmp, &regs->tmr_pevent);
+
+		if (cfg->ptp_exception_en) {
+			tmp = 0;
+			tmp |= TMR_PEMASK_TSREEN;
+			iowrite32be(tmp, &regs->tmr_pemask);
+		}
+	}
+
+	tmp = 0;
+	if (cfg->loopback)
+		tmp |= MACCFG1_LOOPBACK;
+	if (cfg->rx_flow)
+		tmp |= MACCFG1_RX_FLOW;
+	if (cfg->tx_flow)
+		tmp |= MACCFG1_TX_FLOW;
+	iowrite32be(tmp, &regs->maccfg1);
+
+	tmp = 0;
+
+	if (iface_speed < E_ENET_SPEED_1000)
+		tmp |= MACCFG2_NIBBLE_MODE;
+	else if (iface_speed == E_ENET_SPEED_1000)
+		tmp |= MACCFG2_BYTE_MODE;
+
+	tmp |= ((uint32_t)cfg->preamble_len & 0x0000000f)
+	    << PREAMBLE_LENGTH_SHIFT;
+
+	if (cfg->rx_preamble)
+		tmp |= MACCFG2_PRE_AM_RX_EN;
+	if (cfg->tx_preamble)
+		tmp |= MACCFG2_PRE_AM_TX_EN;
+	if (cfg->rx_len_check)
+		tmp |= MACCFG2_LENGTH_CHECK;
+	if (cfg->tx_pad_crc)
+		tmp |= MACCFG2_PAD_CRC_EN;
+	if (cfg->tx_crc)
+		tmp |= MACCFG2_CRC_EN;
+	if (!cfg->halfdup_on)
+		tmp |= MACCFG2_FULL_DUPLEX;
+	iowrite32be(tmp, &regs->maccfg2);
+
+	tmp = (((cfg->non_back_to_back_ipg1 <<
+		 IPGIFG_NON_BACK_TO_BACK_IPG_1_SHIFT)
+		& IPGIFG_NON_BACK_TO_BACK_IPG_1)
+	       | ((cfg->non_back_to_back_ipg2 <<
+		   IPGIFG_NON_BACK_TO_BACK_IPG_2_SHIFT)
+		 & IPGIFG_NON_BACK_TO_BACK_IPG_2)
+	       | ((cfg->min_ifg_enforcement << IPGIFG_MIN_IFG_ENFORCEMENT_SHIFT)
+		 & IPGIFG_MIN_IFG_ENFORCEMENT)
+	       | (cfg->back_to_back_ipg & IPGIFG_BACK_TO_BACK_IPG));
+	iowrite32be(tmp, &regs->ipgifg);
+
+	tmp = 0;
+
+	if (cfg->halfdup_alt_backoff_en)
+		tmp = (uint32_t)(HAFDUP_ALT_BEB |
+				  ((cfg->halfdup_alt_backoff_val & 0x0000000f)
+				   << HAFDUP_ALTERNATE_BEB_TRUNCATION_SHIFT));
+	if (cfg->halfdup_bp_no_backoff)
+		tmp |= HAFDUP_BP_NO_BACKOFF;
+	if (cfg->halfdup_no_backoff)
+		tmp |= HAFDUP_NO_BACKOFF;
+	if (cfg->halfdup_excess_defer)
+		tmp |= HAFDUP_EXCESS_DEFER;
+	tmp |= ((cfg->halfdup_retransmit << HAFDUP_RETRANSMISSION_MAX_SHIFT)
+		& HAFDUP_RETRANSMISSION_MAX);
+	tmp |= (cfg->halfdup_coll_window & HAFDUP_COLLISION_WINDOW);
+
+	iowrite32be(tmp, &regs->hafdup);
+
+	/* Initialize Maximum frame length */
+	iowrite32be(cfg->maximum_frame, &regs->maxfrm);
+
+	iowrite32be(0xffffffff, &regs->cam1);
+	iowrite32be(0xffffffff, &regs->cam2);
+
+	iowrite32be(exception_mask, &regs->imask);
+
+	iowrite32be(0xffffffff, &regs->ievent);
+
+	tmp = (uint32_t)((macaddr[5] << 24) |
+			  (macaddr[4] << 16) | (macaddr[3] << 8) | macaddr[2]);
+	iowrite32be(tmp, &regs->macstnaddr1);
+
+	tmp = (uint32_t)((macaddr[1] << 24) | (macaddr[0] << 16));
+	iowrite32be(tmp, &regs->macstnaddr2);
+
+	/* HASH */
+	for (i = 0; i < NUM_OF_HASH_REGS; i++) {
+		/* Initialize IADDRx */
+		iowrite32be(0, &regs->igaddr[i]);
+		/* Initialize GADDRx */
+		iowrite32be(0, &regs->gaddr[i]);
+	}
+
+	return 0;
+}
+
+uint16_t fman_dtsec_get_max_frame_len(struct dtsec_regs __iomem *regs)
+{
+	return (uint16_t)ioread32be(&regs->maxfrm);
+}
+
+void fman_dtsec_set_max_frame_len(struct dtsec_regs __iomem *regs,
+				  uint16_t length)
+{
+	iowrite32be(length, &regs->maxfrm);
+}
+
+void fman_dtsec_set_mac_address(struct dtsec_regs __iomem *regs, uint8_t *adr)
+{
+	uint32_t tmp;
+
+	tmp = (uint32_t)((adr[5] << 24) |
+			  (adr[4] << 16) | (adr[3] << 8) | adr[2]);
+	iowrite32be(tmp, &regs->macstnaddr1);
+
+	tmp = (uint32_t)((adr[1] << 24) | (adr[0] << 16));
+	iowrite32be(tmp, &regs->macstnaddr2);
+}
+
+void fman_dtsec_get_mac_address(struct dtsec_regs __iomem *regs,
+				uint8_t *macaddr)
+{
+	uint32_t tmp1, tmp2;
+
+	tmp1 = ioread32be(&regs->macstnaddr1);
+	tmp2 = ioread32be(&regs->macstnaddr2);
+
+	macaddr[0] = (uint8_t)((tmp2 & 0x00ff0000) >> 16);
+	macaddr[1] = (uint8_t)((tmp2 & 0xff000000) >> 24);
+	macaddr[2] = (uint8_t)(tmp1 & 0x000000ff);
+	macaddr[3] = (uint8_t)((tmp1 & 0x0000ff00) >> 8);
+	macaddr[4] = (uint8_t)((tmp1 & 0x00ff0000) >> 16);
+	macaddr[5] = (uint8_t)((tmp1 & 0xff000000) >> 24);
+}
+
+void fman_dtsec_set_bucket(struct dtsec_regs __iomem *regs, int bucket,
+			   bool enable)
+{
+	int reg_idx = (bucket >> 5) & 0xf;
+	int bit_idx = bucket & 0x1f;
+	uint32_t bit_mask = 0x80000000 >> bit_idx;
+	uint32_t __iomem *reg;
+
+	if (reg_idx > 7)
+		reg = &regs->gaddr[reg_idx - 8];
+	else
+		reg = &regs->igaddr[reg_idx];
+
+	if (enable)
+		iowrite32be(ioread32be(reg) | bit_mask, reg);
+	else
+		iowrite32be(ioread32be(reg) & (~bit_mask), reg);
+}
+
+int fman_dtsec_adjust_link(struct dtsec_regs __iomem *regs,
+			   enum enet_interface __maybe_unused iface_mode,
+			   enum enet_speed speed, bool full_dx)
+{
+	uint32_t tmp;
+
+	if ((speed == E_ENET_SPEED_1000) && !full_dx)
+		return -EINVAL;
+
+	tmp = ioread32be(&regs->maccfg2);
+	if (!full_dx)
+		tmp &= ~MACCFG2_FULL_DUPLEX;
+	else
+		tmp |= MACCFG2_FULL_DUPLEX;
+
+	tmp &= ~(MACCFG2_NIBBLE_MODE | MACCFG2_BYTE_MODE);
+	if (speed < E_ENET_SPEED_1000)
+		tmp |= MACCFG2_NIBBLE_MODE;
+	else if (speed == E_ENET_SPEED_1000)
+		tmp |= MACCFG2_BYTE_MODE;
+	iowrite32be(tmp, &regs->maccfg2);
+
+	tmp = ioread32be(&regs->ecntrl);
+	if (speed == E_ENET_SPEED_100)
+		tmp |= DTSEC_ECNTRL_R100M;
+	else
+		tmp &= ~DTSEC_ECNTRL_R100M;
+	iowrite32be(tmp, &regs->ecntrl);
+
+	return 0;
+}
+
+void fman_dtsec_set_uc_promisc(struct dtsec_regs __iomem *regs, bool enable)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->rctrl);
+
+	if (enable)
+		tmp |= RCTRL_UPROM;
+	else
+		tmp &= ~RCTRL_UPROM;
+
+	iowrite32be(tmp, &regs->rctrl);
+}
+
+void fman_dtsec_set_mc_promisc(struct dtsec_regs __iomem *regs, bool enable)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->rctrl);
+
+	if (enable)
+		tmp |= RCTRL_MPROM;
+	else
+		tmp &= ~RCTRL_MPROM;
+
+	iowrite32be(tmp, &regs->rctrl);
+}
+
+void fman_dtsec_enable(struct dtsec_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->maccfg1);
+
+	if (apply_rx)
+		tmp |= MACCFG1_RX_EN;
+
+	if (apply_tx)
+		tmp |= MACCFG1_TX_EN;
+
+	iowrite32be(tmp, &regs->maccfg1);
+}
+
+void fman_dtsec_disable(struct dtsec_regs __iomem *regs, bool apply_rx,
+			bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->maccfg1);
+
+	if (apply_rx)
+		tmp &= ~MACCFG1_RX_EN;
+
+	if (apply_tx)
+		tmp &= ~MACCFG1_TX_EN;
+
+	iowrite32be(tmp, &regs->maccfg1);
+}
+
+void fman_dtsec_set_tx_pause_frames(struct dtsec_regs __iomem *regs,
+				    uint16_t time)
+{
+	uint32_t ptv = 0;
+
+	if (time) {
+		ptv = ioread32be(&regs->ptv);
+		ptv &= 0xffff0000;
+		ptv |= time & 0x0000ffff;
+		iowrite32be(ptv, &regs->ptv);
+
+		/* trigger the transmission of a flow-control pause frame */
+		iowrite32be(ioread32be(&regs->maccfg1) | MACCFG1_TX_FLOW,
+			    &regs->maccfg1);
+	} else
+		iowrite32be(ioread32be(&regs->maccfg1) & ~MACCFG1_TX_FLOW,
+			    &regs->maccfg1);
+}
+
+void fman_dtsec_handle_rx_pause(struct dtsec_regs __iomem *regs, bool en)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->maccfg1);
+	if (en)
+		tmp |= MACCFG1_RX_FLOW;
+	else
+		tmp &= ~MACCFG1_RX_FLOW;
+	iowrite32be(tmp, &regs->maccfg1);
+}
+
+uint32_t fman_dtsec_get_rctrl(struct dtsec_regs __iomem *regs)
+{
+	return ioread32be(&regs->rctrl);
+}
+
+uint32_t fman_dtsec_get_revision(struct dtsec_regs __iomem *regs)
+{
+	return ioread32be(&regs->tsec_id);
+}
+
+uint32_t fman_dtsec_get_event(struct dtsec_regs __iomem *regs,
+			      uint32_t ev_mask)
+{
+	return ioread32be(&regs->ievent) & ev_mask;
+}
+
+void fman_dtsec_ack_event(struct dtsec_regs __iomem *regs, uint32_t ev_mask)
+{
+	iowrite32be(ev_mask, &regs->ievent);
+}
+
+uint32_t fman_dtsec_get_interrupt_mask(struct dtsec_regs __iomem *regs)
+{
+	return ioread32be(&regs->imask);
+}
+
+uint32_t fman_dtsec_check_and_clear_tmr_event(struct dtsec_regs __iomem *regs)
+{
+	uint32_t event;
+
+	event = ioread32be(&regs->tmr_pevent);
+	event &= ioread32be(&regs->tmr_pemask);
+
+	if (event)
+		iowrite32be(event, &regs->tmr_pevent);
+	return event;
+}
+
+void fman_dtsec_enable_tmr_interrupt(struct dtsec_regs __iomem *regs)
+{
+	iowrite32be(ioread32be(&regs->tmr_pemask) | TMR_PEMASK_TSREEN,
+		    &regs->tmr_pemask);
+}
+
+void fman_dtsec_disable_tmr_interrupt(struct dtsec_regs __iomem *regs)
+{
+	iowrite32be(ioread32be(&regs->tmr_pemask) & ~TMR_PEMASK_TSREEN,
+		    &regs->tmr_pemask);
+}
+
+void fman_dtsec_enable_interrupt(struct dtsec_regs __iomem *regs,
+				 uint32_t ev_mask)
+{
+	iowrite32be(ioread32be(&regs->imask) | ev_mask, &regs->imask);
+}
+
+void fman_dtsec_disable_interrupt(struct dtsec_regs __iomem *regs,
+				  uint32_t ev_mask)
+{
+	iowrite32be(ioread32be(&regs->imask) & ~ev_mask, &regs->imask);
+}
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c b/drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c
new file mode 100644
index 0000000..226dd5d
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c
@@ -0,0 +1,168 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fsl_fman_dtsec_mii_acc.h"
+
+/**
+ * dtsec_mii_get_div() - calculates the value of the dtsec mii divider
+ * @dtsec_freq:		dtsec clock frequency (in Mhz)
+ *
+ * This function calculates the dtsec mii clock divider that determines
+ * the MII MDC clock. MII MDC clock will be set to work in the range
+ * of 1.5 to 2.5Mhz
+ * The output of this function is the value of MIIMCFG[MgmtClk] which
+ * implicitly determines the divider value.
+ * Note: the dTSEC system clock is equal to 1/2 of the FMan clock.
+ * The table below which reflects dtsec_mii_get_div() functionality
+ * shows the relations among dtsec_freq, MgmtClk, actual divider
+ * and the MII frequency:
+ * dtsec freq   MgmtClk	   div	      MII freq Mhz
+ * [0.....80]	 1	(1/4)(1/8)    [0   to 2.5]
+ * [81...120]	 2	(1/6)(1/8)    [1.6 to 2.5]
+ * [121..160]	 3	(1/8)(1/8)    [1.8 to 2.5]
+ * [161..200]	 4	(1/10)(1/8)   [2.0 to 2.5]
+ * [201..280]	 5	(1/14)(1/8)   [1.8 to 2.5]
+ * [281..400]	 6	(1/20)(1/8)   [1.1 to 2.5]
+ * [401..560]	 7	(1/28)(1/8)   [1.8 to 2.5]
+ * [560..frq]	 7	(1/28)(1/8)   [frq/224]
+ * Returns: the MIIMCFG[MgmtClk] appropriate value
+ */
+static uint8_t dtsec_mii_get_div(uint16_t dtsec_freq)
+{
+	uint16_t mgmt_clk;
+
+	if (dtsec_freq < 80)
+		mgmt_clk = 1;
+	else if (dtsec_freq < 120)
+		mgmt_clk = 2;
+	else if (dtsec_freq < 160)
+		mgmt_clk = 3;
+	else if (dtsec_freq < 200)
+		mgmt_clk = 4;
+	else if (dtsec_freq < 280)
+		mgmt_clk = 5;
+	else if (dtsec_freq < 400)
+		mgmt_clk = 6;
+	else
+		mgmt_clk = 7;
+
+	return (uint8_t)mgmt_clk;
+}
+
+void fman_dtsec_mii_reset(struct dtsec_mii_reg __iomem *regs)
+{
+	/* Reset the management interface */
+	iowrite32be(ioread32be(&regs->miimcfg) | MIIMCFG_RESET_MGMT,
+		    &regs->miimcfg);
+	iowrite32be(ioread32be(&regs->miimcfg) & ~MIIMCFG_RESET_MGMT,
+		    &regs->miimcfg);
+}
+
+int fman_dtsec_mii_write_reg(struct dtsec_mii_reg __iomem *regs, uint8_t addr,
+			     uint8_t reg, uint16_t data, uint16_t dtsec_freq)
+{
+	uint32_t tmp;
+
+	/* Setup the MII Mgmt clock speed */
+	iowrite32be((uint32_t)dtsec_mii_get_div(dtsec_freq), &regs->miimcfg);
+	/* Memory barrier */
+	wmb();
+
+	/* Stop the MII management read cycle */
+	iowrite32be(0, &regs->miimcom);
+	/* Dummy read to make sure MIIMCOM is written */
+	tmp = ioread32be(&regs->miimcom);
+	/* Memory barrier */
+	wmb();
+
+	/* Setting up MII Management Address Register */
+	tmp = (uint32_t)((addr << MIIMADD_PHY_ADDR_SHIFT) | reg);
+	iowrite32be(tmp, &regs->miimadd);
+	/* Memory barrier */
+	wmb();
+
+	/* Setting up MII Management Control Register with data */
+	iowrite32be((uint32_t)data, &regs->miimcon);
+	/* Dummy read to make sure MIIMCON is written */
+	tmp = ioread32be(&regs->miimcon);
+	/* Memory barrier */
+	wmb();
+
+	/* Wait until MII management write is complete */
+	/* todo: a timeout could be useful here */
+	while ((ioread32be(&regs->miimind)) & MIIMIND_BUSY)
+		; /* busy wait */
+
+	return 0;
+}
+
+int fman_dtsec_mii_read_reg(struct dtsec_mii_reg __iomem *regs, uint8_t addr,
+			    uint8_t reg, uint16_t *data, uint16_t dtsec_freq)
+{
+	uint32_t tmp;
+
+	/* Setup the MII Mgmt clock speed */
+	iowrite32be((uint32_t)dtsec_mii_get_div(dtsec_freq), &regs->miimcfg);
+	/* Memory barrier */
+	wmb();
+
+	/* Setting up the MII Management Address Register */
+	tmp = (uint32_t)((addr << MIIMADD_PHY_ADDR_SHIFT) | reg);
+	iowrite32be(tmp, &regs->miimadd);
+	/* Memory barrier */
+	wmb();
+
+	/* Perform an MII management read cycle */
+	iowrite32be(MIIMCOM_READ_CYCLE, &regs->miimcom);
+	/* Dummy read to make sure MIIMCOM is written */
+	tmp = ioread32be(&regs->miimcom);
+	/* Memory barrier */
+	wmb();
+
+	/* Wait until MII management read is complete */
+	/* todo: a timeout could be useful here */
+	while ((ioread32be(&regs->miimind)) & MIIMIND_BUSY)
+		; /* busy wait */
+
+	/* Read MII management status  */
+	*data = (uint16_t)ioread32be(&regs->miimstat);
+	/* Memory barrier */
+	wmb();
+
+	iowrite32be(0, &regs->miimcom);
+	/* Dummy read to make sure MIIMCOM is written */
+	tmp = ioread32be(&regs->miimcom);
+
+	if (*data == 0xffff)
+		return -ENXIO;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_memac.c b/drivers/net/ethernet/freescale/fman/mac/fman_memac.c
new file mode 100644
index 0000000..e0bac5a
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_memac.c
@@ -0,0 +1,365 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fsl_fman_memac.h"
+
+uint32_t fman_memac_get_event(struct memac_regs __iomem *regs, uint32_t ev_mask)
+{
+	return ioread32be(&regs->ievent) & ev_mask;
+}
+
+uint32_t fman_memac_get_interrupt_mask(struct memac_regs __iomem *regs)
+{
+	return ioread32be(&regs->imask);
+}
+
+void fman_memac_ack_event(struct memac_regs __iomem *regs, uint32_t ev_mask)
+{
+	iowrite32be(ev_mask, &regs->ievent);
+}
+
+void fman_memac_set_promiscuous(struct memac_regs __iomem *regs, bool val)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+
+	if (val)
+		tmp |= CMD_CFG_PROMIS_EN;
+	else
+		tmp &= ~CMD_CFG_PROMIS_EN;
+
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_memac_clear_addr_in_paddr(struct memac_regs __iomem *regs,
+				    uint8_t paddr_num)
+{
+	if (paddr_num == 0) {
+		iowrite32be(0, &regs->mac_addr0.mac_addr_l);
+		iowrite32be(0, &regs->mac_addr0.mac_addr_u);
+	} else {
+		iowrite32be(0x0, &regs->mac_addr[paddr_num - 1].mac_addr_l);
+		iowrite32be(0x0, &regs->mac_addr[paddr_num - 1].mac_addr_u);
+	}
+}
+
+void fman_memac_add_addr_in_paddr(struct memac_regs __iomem *regs,
+				  uint8_t *adr, uint8_t paddr_num)
+{
+	uint32_t tmp0, tmp1;
+
+	tmp0 = (uint32_t)(adr[0] | adr[1] << 8 | adr[2] << 16 | adr[3] << 24);
+	tmp1 = (uint32_t)(adr[4] | adr[5] << 8);
+
+	if (paddr_num == 0) {
+		iowrite32be(tmp0, &regs->mac_addr0.mac_addr_l);
+		iowrite32be(tmp1, &regs->mac_addr0.mac_addr_u);
+	} else {
+		iowrite32be(tmp0, &regs->mac_addr[paddr_num - 1].mac_addr_l);
+		iowrite32be(tmp1, &regs->mac_addr[paddr_num - 1].mac_addr_u);
+	}
+}
+
+void fman_memac_enable(struct memac_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+
+	if (apply_rx)
+		tmp |= CMD_CFG_RX_EN;
+
+	if (apply_tx)
+		tmp |= CMD_CFG_TX_EN;
+
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_memac_disable(struct memac_regs __iomem *regs, bool apply_rx,
+			bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+
+	if (apply_rx)
+		tmp &= ~CMD_CFG_RX_EN;
+
+	if (apply_tx)
+		tmp &= ~CMD_CFG_TX_EN;
+
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_memac_reset(struct memac_regs __iomem *regs)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+
+	tmp |= CMD_CFG_SW_RESET;
+
+	iowrite32be(tmp, &regs->command_config);
+
+	while (ioread32be(&regs->command_config) & CMD_CFG_SW_RESET)
+		;
+}
+
+int fman_memac_init(struct memac_regs __iomem *regs,
+		    struct memac_cfg *cfg,
+		    enum enet_interface enet_interface,
+		    enum enet_speed enet_speed,
+		    bool slow_10g_if,
+		    uint32_t exceptions)
+{
+	uint32_t tmp;
+
+	/* Config */
+	tmp = 0;
+	if (cfg->wan_mode_enable)
+		tmp |= CMD_CFG_WAN_MODE;
+	if (cfg->promiscuous_mode_enable)
+		tmp |= CMD_CFG_PROMIS_EN;
+	if (cfg->pause_forward_enable)
+		tmp |= CMD_CFG_PAUSE_FWD;
+	if (cfg->pause_ignore)
+		tmp |= CMD_CFG_PAUSE_IGNORE;
+	if (cfg->tx_addr_ins_enable)
+		tmp |= CMD_CFG_TX_ADDR_INS;
+	if (cfg->loopback_enable)
+		tmp |= CMD_CFG_LOOPBACK_EN;
+	if (cfg->cmd_frame_enable)
+		tmp |= CMD_CFG_CNT_FRM_EN;
+	if (cfg->send_idle_enable)
+		tmp |= CMD_CFG_SEND_IDLE;
+	if (cfg->no_length_check_enable)
+		tmp |= CMD_CFG_NO_LEN_CHK;
+	if (cfg->rx_sfd_any)
+		tmp |= CMD_CFG_SFD_ANY;
+	if (cfg->pad_enable)
+		tmp |= CMD_CFG_TX_PAD_EN;
+	if (cfg->wake_on_lan)
+		tmp |= CMD_CFG_MG;
+
+	tmp |= CMD_CFG_CRC_FWD;
+
+	iowrite32be(tmp, &regs->command_config);
+
+	/* Max Frame Length */
+	iowrite32be((uint32_t)cfg->max_frame_length, &regs->maxfrm);
+
+	/* Pause Time */
+	iowrite32be((uint32_t)cfg->pause_quanta, &regs->pause_quanta[0]);
+	iowrite32be((uint32_t)0, &regs->pause_thresh[0]);
+
+	/* IF_MODE */
+	tmp = 0;
+	switch (enet_interface) {
+	case E_ENET_IF_XGMII:
+	case E_ENET_IF_XFI:
+		tmp |= IF_MODE_XGMII;
+		break;
+	default:
+		tmp |= IF_MODE_GMII;
+		if (enet_interface == E_ENET_IF_RGMII && !cfg->loopback_enable)
+			tmp |= IF_MODE_RGMII | IF_MODE_RGMII_AUTO;
+	}
+	iowrite32be(tmp, &regs->if_mode);
+
+	/* TX_FIFO_SECTIONS */
+	tmp = 0;
+	if (enet_interface == E_ENET_IF_XGMII ||
+	    enet_interface == E_ENET_IF_XFI) {
+		if (slow_10g_if) {
+			tmp |= (TX_FIFO_SECTIONS_TX_AVAIL_SLOW_10G |
+				TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_10G);
+		} else {
+			tmp |= (TX_FIFO_SECTIONS_TX_AVAIL_10G |
+				TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_10G);
+		}
+	} else {
+		tmp |= (TX_FIFO_SECTIONS_TX_AVAIL_1G |
+			TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_1G);
+	}
+	iowrite32be(tmp, &regs->tx_fifo_sections);
+
+	/* clear all pending events and set-up interrupts */
+	fman_memac_ack_event(regs, 0xffffffff);
+	fman_memac_set_exception(regs, exceptions, true);
+
+	return 0;
+}
+
+void fman_memac_set_exception(struct memac_regs __iomem *regs, uint32_t val,
+			      bool enable)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->imask);
+	if (enable)
+		tmp |= val;
+	else
+		tmp &= ~val;
+
+	iowrite32be(tmp, &regs->imask);
+}
+
+void fman_memac_set_hash_table(struct memac_regs __iomem *regs, uint32_t val)
+{
+	iowrite32be(val, &regs->hashtable_ctrl);
+}
+
+uint16_t fman_memac_get_max_frame_len(struct memac_regs __iomem *regs)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->maxfrm);
+
+	return (uint16_t)tmp;
+}
+
+void fman_memac_set_tx_pause_frames(struct memac_regs __iomem *regs,
+				    uint8_t priority,
+				    uint16_t pause_time, uint16_t thresh_time)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->tx_fifo_sections);
+
+	GET_TX_EMPTY_DEFAULT_VALUE(tmp);
+	iowrite32be(tmp, &regs->tx_fifo_sections);
+
+	tmp = ioread32be(&regs->command_config);
+	tmp &= ~CMD_CFG_PFC_MODE;
+	priority = 0;
+
+	iowrite32be(tmp, &regs->command_config);
+
+	tmp = ioread32be(&regs->pause_quanta[priority / 2]);
+	if (priority % 2)
+		tmp &= 0x0000FFFF;
+	else
+		tmp &= 0xFFFF0000;
+	tmp |= ((uint32_t)pause_time << (16 * (priority % 2)));
+	iowrite32be(tmp, &regs->pause_quanta[priority / 2]);
+
+	tmp = ioread32be(&regs->pause_thresh[priority / 2]);
+	if (priority % 2)
+		tmp &= 0x0000FFFF;
+	else
+		tmp &= 0xFFFF0000;
+	tmp |= ((uint32_t)thresh_time << (16 * (priority % 2)));
+	iowrite32be(tmp, &regs->pause_thresh[priority / 2]);
+}
+
+void fman_memac_set_rx_ignore_pause_frames(struct memac_regs __iomem *regs,
+					   bool enable)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+	if (enable)
+		tmp |= CMD_CFG_PAUSE_IGNORE;
+	else
+		tmp &= ~CMD_CFG_PAUSE_IGNORE;
+
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_memac_adjust_link(struct memac_regs __iomem *regs,
+			    enum enet_interface iface_mode,
+			    enum enet_speed speed, bool full_dx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->if_mode);
+
+	if (full_dx)
+		tmp &= ~IF_MODE_HD;
+	else
+		tmp |= IF_MODE_HD;
+
+	if (iface_mode == E_ENET_IF_RGMII) {
+		/* Configure RGMII in manual mode */
+		tmp &= ~IF_MODE_RGMII_AUTO;
+		tmp &= ~IF_MODE_RGMII_SP_MASK;
+
+		if (full_dx)
+			tmp |= IF_MODE_RGMII_FD;
+		else
+			tmp &= ~IF_MODE_RGMII_FD;
+
+		switch (speed) {
+		case E_ENET_SPEED_1000:
+			tmp |= IF_MODE_RGMII_1000;
+			break;
+		case E_ENET_SPEED_100:
+			tmp |= IF_MODE_RGMII_100;
+			break;
+		case E_ENET_SPEED_10:
+			tmp |= IF_MODE_RGMII_10;
+			break;
+		default:
+			break;
+		}
+	}
+
+	iowrite32be(tmp, &regs->if_mode);
+}
+
+void fman_memac_defconfig(struct memac_cfg *cfg)
+{
+	cfg->reset_on_init = false;
+	cfg->wan_mode_enable = false;
+	cfg->promiscuous_mode_enable = false;
+	cfg->pause_forward_enable = false;
+	cfg->pause_ignore = false;
+	cfg->tx_addr_ins_enable = false;
+	cfg->loopback_enable = false;
+	cfg->cmd_frame_enable = false;
+	cfg->rx_error_discard = false;
+	cfg->send_idle_enable = false;
+	cfg->no_length_check_enable = true;
+	cfg->lgth_check_nostdr = false;
+	cfg->time_stamp_enable = false;
+	cfg->tx_ipg_length = DEFAULT_TX_IPG_LENGTH;
+	cfg->max_frame_length = DEFAULT_FRAME_LENGTH;
+	cfg->pause_quanta = DEFAULT_PAUSE_QUANTA;
+	cfg->pad_enable = true;
+	cfg->phy_tx_ena_on = false;
+	cfg->rx_sfd_any = false;
+	cfg->rx_pbl_fwd = false;
+	cfg->tx_pbl_fwd = false;
+	cfg->debug_mode = false;
+	cfg->wake_on_lan = false;
+}
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c b/drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c
new file mode 100644
index 0000000..c424c82
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c
@@ -0,0 +1,217 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fsl_fman_memac_mii_acc.h"
+
+static void write_phy_reg_10g(struct memac_mii_access_mem_map __iomem *mii_regs,
+			      uint8_t phy_addr, uint8_t reg, uint16_t data)
+{
+	uint32_t tmp_reg;
+
+	tmp_reg = ioread32be(&mii_regs->mdio_cfg);
+	/* Leave only MDIO_CLK_DIV bits set on */
+	tmp_reg &= MDIO_CFG_CLK_DIV_MASK;
+	/* Set maximum MDIO_HOLD value to allow phy to see
+	 * change of data signal
+	 */
+	tmp_reg |= MDIO_CFG_HOLD_MASK;
+	/* Add 10G interface mode */
+	tmp_reg |= MDIO_CFG_ENC45;
+	iowrite32be(tmp_reg, &mii_regs->mdio_cfg);
+
+	/* Wait for command completion */
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Specify phy and register to be accessed */
+	iowrite32be(phy_addr, &mii_regs->mdio_ctrl);
+	iowrite32be(reg, &mii_regs->mdio_addr);
+	/* memory barrier */
+	wmb();
+
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Write data */
+	iowrite32be(data, &mii_regs->mdio_data);
+	/* memory barrier */
+	wmb();
+
+	/* Wait for write transaction end */
+	while ((ioread32be(&mii_regs->mdio_data)) & MDIO_DATA_BSY)
+		udelay(1);
+}
+
+static uint32_t read_phy_reg_10g(struct memac_mii_access_mem_map __iomem
+				 *mii_regs, uint8_t phy_addr, uint8_t reg,
+				 uint16_t *data)
+{
+	uint32_t tmp_reg;
+
+	tmp_reg = ioread32be(&mii_regs->mdio_cfg);
+	/* Leave only MDIO_CLK_DIV bits set on */
+	tmp_reg &= MDIO_CFG_CLK_DIV_MASK;
+	/* Set maximum MDIO_HOLD value to allow phy to see
+	 * change of data signal
+	 */
+	tmp_reg |= MDIO_CFG_HOLD_MASK;
+	/* Add 10G interface mode */
+	tmp_reg |= MDIO_CFG_ENC45;
+	iowrite32be(tmp_reg, &mii_regs->mdio_cfg);
+
+	/* Wait for command completion */
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Specify phy and register to be accessed */
+	iowrite32be(phy_addr, &mii_regs->mdio_ctrl);
+	iowrite32be(reg, &mii_regs->mdio_addr);
+	/* memory barrier */
+	wmb();
+
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Read cycle */
+	tmp_reg = phy_addr;
+	tmp_reg |= MDIO_CTL_READ;
+	iowrite32be(tmp_reg, &mii_regs->mdio_ctrl);
+	/* memory barrier */
+	wmb();
+
+	/* Wait for data to be available */
+	while ((ioread32be(&mii_regs->mdio_data)) & MDIO_DATA_BSY)
+		udelay(1);
+
+	*data = (uint16_t)ioread32be(&mii_regs->mdio_data);
+
+	/* Check if there was an error */
+	return ioread32be(&mii_regs->mdio_cfg);
+}
+
+static void write_phy_reg_1g(struct memac_mii_access_mem_map __iomem *mii_regs,
+			     uint8_t phy_addr, uint8_t reg, uint16_t data)
+{
+	uint32_t tmp_reg;
+
+	/* Leave only MDIO_CLK_DIV and MDIO_HOLD bits set on */
+	tmp_reg = ioread32be(&mii_regs->mdio_cfg);
+	tmp_reg &= (MDIO_CFG_CLK_DIV_MASK | MDIO_CFG_HOLD_MASK);
+	iowrite32be(tmp_reg, &mii_regs->mdio_cfg);
+
+	/* Wait for command completion */
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Write transaction */
+	tmp_reg = (phy_addr << MDIO_CTL_PHY_ADDR_SHIFT);
+	tmp_reg |= reg;
+	iowrite32be(tmp_reg, &mii_regs->mdio_ctrl);
+
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	iowrite32be(data, &mii_regs->mdio_data);
+
+	/* memory barrier */
+	wmb();
+
+	/* Wait for write transaction to end */
+	while ((ioread32be(&mii_regs->mdio_data)) & MDIO_DATA_BSY)
+		udelay(1);
+}
+
+static uint32_t read_phy_reg_1g(struct memac_mii_access_mem_map __iomem
+				*mii_regs, uint8_t phy_addr, uint8_t reg,
+				uint16_t *data)
+{
+	uint32_t tmp_reg;
+
+	/* Leave only MDIO_CLK_DIV and MDIO_HOLD bits set on */
+	tmp_reg = ioread32be(&mii_regs->mdio_cfg);
+	tmp_reg &= (MDIO_CFG_CLK_DIV_MASK | MDIO_CFG_HOLD_MASK);
+	iowrite32be(tmp_reg, &mii_regs->mdio_cfg);
+
+	/* Wait for command completion */
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Read transaction */
+	tmp_reg = (phy_addr << MDIO_CTL_PHY_ADDR_SHIFT);
+	tmp_reg |= reg;
+	tmp_reg |= MDIO_CTL_READ;
+	iowrite32be(tmp_reg, &mii_regs->mdio_ctrl);
+
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Wait for data to be available */
+	while ((ioread32be(&mii_regs->mdio_data)) & MDIO_DATA_BSY)
+		udelay(1);
+
+	*data = (uint16_t)ioread32be(&mii_regs->mdio_data);
+
+	/* Check error */
+	return ioread32be(&mii_regs->mdio_cfg);
+}
+
+int fman_memac_mii_write_phy_reg(struct memac_mii_access_mem_map __iomem
+				 *mii_regs, uint8_t phy_addr, uint8_t reg,
+				 uint16_t data, enum enet_speed enet_speed)
+{
+	/* Figure out interface type - 10G vs 1G.
+	 * In 10G interface both phy_addr and devAddr present.
+	 */
+	if (enet_speed == E_ENET_SPEED_10000)
+		write_phy_reg_10g(mii_regs, phy_addr, reg, data);
+	else
+		write_phy_reg_1g(mii_regs, phy_addr, reg, data);
+
+	return 0;
+}
+
+int fman_memac_mii_read_phy_reg(struct memac_mii_access_mem_map __iomem
+				*mii_regs, uint8_t phy_addr, uint8_t reg,
+				uint16_t *data, enum enet_speed enet_speed)
+{
+	uint32_t ans;
+	/* Figure out interface type - 10G vs 1G.
+	 * In 10G interface both phy_addr and devAddr present.
+	 */
+	if (enet_speed == E_ENET_SPEED_10000)
+		ans = read_phy_reg_10g(mii_regs, phy_addr, reg, data);
+	else
+		ans = read_phy_reg_1g(mii_regs, phy_addr, reg, data);
+
+	if (ans & MDIO_CFG_READ_ERR)
+		return -EINVAL;
+	return 0;
+}
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_tgec.c b/drivers/net/ethernet/freescale/fman/mac/fman_tgec.c
new file mode 100644
index 0000000..b45e69d
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_tgec.c
@@ -0,0 +1,215 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fsl_fman_tgec.h"
+
+void fman_tgec_set_mac_address(struct tgec_regs __iomem *regs, uint8_t *adr)
+{
+	uint32_t tmp0, tmp1;
+
+	tmp0 = (uint32_t)(adr[0] | adr[1] << 8 | adr[2] << 16 | adr[3] << 24);
+	tmp1 = (uint32_t)(adr[4] | adr[5] << 8);
+	iowrite32be(tmp0, &regs->mac_addr_0);
+	iowrite32be(tmp1, &regs->mac_addr_1);
+}
+
+void fman_tgec_enable(struct tgec_regs __iomem *regs, bool apply_rx,
+		      bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+	if (apply_rx)
+		tmp |= CMD_CFG_RX_EN;
+	if (apply_tx)
+		tmp |= CMD_CFG_TX_EN;
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_tgec_disable(struct tgec_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx)
+{
+	uint32_t tmp_reg_32;
+
+	tmp_reg_32 = ioread32be(&regs->command_config);
+	if (apply_rx)
+		tmp_reg_32 &= ~CMD_CFG_RX_EN;
+	if (apply_tx)
+		tmp_reg_32 &= ~CMD_CFG_TX_EN;
+	iowrite32be(tmp_reg_32, &regs->command_config);
+}
+
+void fman_tgec_set_promiscuous(struct tgec_regs __iomem *regs, bool val)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+	if (val)
+		tmp |= CMD_CFG_PROMIS_EN;
+	else
+		tmp &= ~CMD_CFG_PROMIS_EN;
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_tgec_set_hash_table(struct tgec_regs __iomem *regs, uint32_t value)
+{
+	iowrite32be(value, &regs->hashtable_ctrl);
+}
+
+void fman_tgec_set_tx_pause_frames(struct tgec_regs __iomem *regs,
+				   uint16_t pause_time)
+{
+	iowrite32be((uint32_t)pause_time, &regs->pause_quant);
+}
+
+void fman_tgec_set_rx_ignore_pause_frames(struct tgec_regs __iomem *regs,
+					  bool en)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+	if (en)
+		tmp |= CMD_CFG_PAUSE_IGNORE;
+	else
+		tmp &= ~CMD_CFG_PAUSE_IGNORE;
+	iowrite32be(tmp, &regs->command_config);
+}
+
+uint32_t fman_tgec_get_event(struct tgec_regs __iomem *regs, uint32_t ev_mask)
+{
+	return ioread32be(&regs->ievent) & ev_mask;
+}
+
+void fman_tgec_ack_event(struct tgec_regs __iomem *regs, uint32_t ev_mask)
+{
+	iowrite32be(ev_mask, &regs->ievent);
+}
+
+uint32_t fman_tgec_get_interrupt_mask(struct tgec_regs __iomem *regs)
+{
+	return ioread32be(&regs->imask);
+}
+
+uint32_t fman_tgec_get_revision(struct tgec_regs __iomem *regs)
+{
+	return ioread32be(&regs->tgec_id);
+}
+
+void fman_tgec_enable_interrupt(struct tgec_regs __iomem *regs,
+				uint32_t ev_mask)
+{
+	iowrite32be(ioread32be(&regs->imask) | ev_mask, &regs->imask);
+}
+
+void fman_tgec_disable_interrupt(struct tgec_regs __iomem *regs,
+				 uint32_t ev_mask)
+{
+	iowrite32be(ioread32be(&regs->imask) & ~ev_mask, &regs->imask);
+}
+
+uint16_t fman_tgec_get_max_frame_len(struct tgec_regs __iomem *regs)
+{
+	return (uint16_t)ioread32be(&regs->maxfrm);
+}
+
+void fman_tgec_defconfig(struct tgec_cfg *cfg)
+{
+	cfg->wan_mode_enable = DEFAULT_WAN_MODE_ENABLE;
+	cfg->promiscuous_mode_enable = DEFAULT_PROMISCUOUS_MODE_ENABLE;
+	cfg->pause_forward_enable = DEFAULT_PAUSE_FORWARD_ENABLE;
+	cfg->pause_ignore = DEFAULT_PAUSE_IGNORE;
+	cfg->tx_addr_ins_enable = DEFAULT_TX_ADDR_INS_ENABLE;
+	cfg->loopback_enable = DEFAULT_LOOPBACK_ENABLE;
+	cfg->cmd_frame_enable = DEFAULT_CMD_FRAME_ENABLE;
+	cfg->rx_error_discard = DEFAULT_RX_ERROR_DISCARD;
+	cfg->send_idle_enable = DEFAULT_SEND_IDLE_ENABLE;
+	cfg->no_length_check_enable = DEFAULT_NO_LENGTH_CHECK_ENABLE;
+	cfg->lgth_check_nostdr = DEFAULT_LGTH_CHECK_NOSTDR;
+	cfg->time_stamp_enable = DEFAULT_TIME_STAMP_ENABLE;
+	cfg->tx_ipg_length = DEFAULT_TX_IPG_LENGTH;
+	cfg->max_frame_length = DEFAULT_MAX_FRAME_LENGTH;
+	cfg->pause_quant = DEFAULT_PAUSE_QUANT;
+	cfg->skip_fman11_workaround = false;
+}
+
+int fman_tgec_init(struct tgec_regs __iomem *regs, struct tgec_cfg *cfg,
+		   uint32_t exception_mask)
+{
+	uint32_t tmp;
+
+	/* Config */
+	tmp = 0x40;		/* CRC forward */
+	if (cfg->wan_mode_enable)
+		tmp |= CMD_CFG_WAN_MODE;
+	if (cfg->promiscuous_mode_enable)
+		tmp |= CMD_CFG_PROMIS_EN;
+	if (cfg->pause_forward_enable)
+		tmp |= CMD_CFG_PAUSE_FWD;
+	if (cfg->pause_ignore)
+		tmp |= CMD_CFG_PAUSE_IGNORE;
+	if (cfg->tx_addr_ins_enable)
+		tmp |= CMD_CFG_TX_ADDR_INS;
+	if (cfg->loopback_enable)
+		tmp |= CMD_CFG_LOOPBACK_EN;
+	if (cfg->cmd_frame_enable)
+		tmp |= CMD_CFG_CMD_FRM_EN;
+	if (cfg->rx_error_discard)
+		tmp |= CMD_CFG_RX_ER_DISC;
+	if (cfg->send_idle_enable)
+		tmp |= CMD_CFG_SEND_IDLE;
+	if (cfg->no_length_check_enable)
+		tmp |= CMD_CFG_NO_LEN_CHK;
+	if (cfg->time_stamp_enable)
+		tmp |= CMD_CFG_EN_TIMESTAMP;
+	iowrite32be(tmp, &regs->command_config);
+
+	/* Max Frame Length */
+	iowrite32be((uint32_t)cfg->max_frame_length, &regs->maxfrm);
+	/* Pause Time */
+	iowrite32be(cfg->pause_quant, &regs->pause_quant);
+
+	/* clear all pending events and set-up interrupts */
+	fman_tgec_ack_event(regs, 0xffffffff);
+	fman_tgec_enable_interrupt(regs, exception_mask);
+
+	return 0;
+}
+
+void fman_tgec_set_erratum_tx_fifo_corruption_10gmac_a007(struct tgec_regs
+							  __iomem *regs)
+{
+	uint32_t tmp;
+
+	/* restore the default tx ipg Length */
+	tmp = (ioread32be(&regs->tx_ipg_len) & ~TGEC_TX_IPG_LENGTH_MASK) | 12;
+
+	iowrite32be(tmp, &regs->tx_ipg_len);
+}
-- 
1.7.9.5
