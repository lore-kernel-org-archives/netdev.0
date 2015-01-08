From: Stephen Wang <wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: [PATCH] ethernet: atheros: Add nss-gmac driver
Date: Thu,  8 Jan 2015 14:03:46 -0800
Message-ID: <1420754626-30121-1-git-send-email-wstephen@codeaurora.org>
References: <y>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stephen Wang <wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: jcliburn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <y>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This driver adds support for the internal GMACs on IPQ806x SoCs.
It supports the device-tree and will register up to 4 ethernet
interfaces.

Signed-off-by: Stephen Wang <wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
---
 drivers/net/ethernet/atheros/Kconfig               |   10 +
 drivers/net/ethernet/atheros/Makefile              |    1 +
 drivers/net/ethernet/atheros/nss-gmac/LICENSE.txt  |   14 +
 drivers/net/ethernet/atheros/nss-gmac/Makefile     |   19 +
 .../atheros/nss-gmac/exports/nss_gmac_api_if.h     |  126 ++
 .../atheros/nss-gmac/include/msm_nss_gmac.h        |  338 ++++
 .../atheros/nss-gmac/include/msm_nss_macsec.h      |   73 +
 .../atheros/nss-gmac/include/nss_gmac_clocks.h     |  100 +
 .../atheros/nss-gmac/include/nss_gmac_dev.h        | 2136 ++++++++++++++++++++
 .../nss-gmac/include/nss_gmac_network_interface.h  |   63 +
 .../net/ethernet/atheros/nss-gmac/nss_gmac_ctrl.c  | 1210 +++++++++++
 .../net/ethernet/atheros/nss-gmac/nss_gmac_dev.c   | 1963 ++++++++++++++++++
 .../ethernet/atheros/nss-gmac/nss_gmac_ethtool.c   |  526 +++++
 .../net/ethernet/atheros/nss-gmac/nss_gmac_init.c  | 1131 +++++++++++
 .../ethernet/atheros/nss-gmac/nss_gmac_mdiobus.c   |  187 ++
 .../atheros/nss-gmac/nss_gmac_tx_rx_offload.c      | 1175 +++++++++++
 16 files changed, 9072 insertions(+)
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/LICENSE.txt
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/Makefile
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/exports/nss_gmac_api_if.h
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/include/msm_nss_gmac.h
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/include/msm_nss_macsec.h
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/include/nss_gmac_clocks.h
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/include/nss_gmac_dev.h
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/include/nss_gmac_network_interface.h
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/nss_gmac_ctrl.c
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/nss_gmac_dev.c
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/nss_gmac_ethtool.c
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/nss_gmac_init.c
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/nss_gmac_mdiobus.c
 create mode 100644 drivers/net/ethernet/atheros/nss-gmac/nss_gmac_tx_rx_offload.c

diff --git a/drivers/net/ethernet/atheros/Kconfig b/drivers/net/ethernet/atheros/Kconfig
index 58ad37c..43b5843 100644
--- a/drivers/net/ethernet/atheros/Kconfig
+++ b/drivers/net/ethernet/atheros/Kconfig
@@ -80,4 +80,14 @@ config ALX
 	  To compile this driver as a module, choose M here.  The module
 	  will be called alx.
 
+config QCA_NSS_GMAC
+	tristate "Qualcomm/Atheros IPQ806x GMAC Ethernet support (EXPERIMENTAL)"
+	select NET_CORE
+	select MII
+	---help---
+	  This driver supports the Qualcomm/Atheros GMAC ports in IPQ806x
+	  chipset. Presents an ethernet interface to user space.
+
+	  The module will be called qca-nss-gmac.
+
 endif # NET_VENDOR_ATHEROS
diff --git a/drivers/net/ethernet/atheros/Makefile b/drivers/net/ethernet/atheros/Makefile
index 5cf1c65..aaa205e 100644
--- a/drivers/net/ethernet/atheros/Makefile
+++ b/drivers/net/ethernet/atheros/Makefile
@@ -7,3 +7,4 @@ obj-$(CONFIG_ATL2) += atlx/
 obj-$(CONFIG_ATL1E) += atl1e/
 obj-$(CONFIG_ATL1C) += atl1c/
 obj-$(CONFIG_ALX) += alx/
+obj-$(CONFIG_QCA_NSS_GMAC) += nss-gmac/
diff --git a/drivers/net/ethernet/atheros/nss-gmac/LICENSE.txt b/drivers/net/ethernet/atheros/nss-gmac/LICENSE.txt
new file mode 100644
index 0000000..806f2e6
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/LICENSE.txt
@@ -0,0 +1,14 @@
+Linux Driver for 3504 DWC Ether MAC 10/100/1000 Universal
+Linux Driver for 3507 DWC Ether MAC 10/100 Universal
+
+IMPORTANT: Synopsys Ethernet MAC Linux Software Drivers and documentation (hereinafter, "Software") are unsupported proprietary works of Synopsys, Inc. unless otherwise expressly agreed to in writing between Synopsys and you.
+
+The Software uses certain Linux kernel functionality and may therefore be subject to the GNU Public License which is available at:
+http://www.gnu.org/licenses/gpl.html
+
+The Software IS NOT an item of Licensed Software or Licensed Product under any End User Software License Agreement or Agreement for Licensed Product with Synopsys or any supplement thereto. Synopsys permits you to use and redistribute this Software in source and binary forms, with or without modification, provided that redistributions of source code must retain this notice.  Synopsys does not permit you to view, use, disclose, copy or distribute this file or any information contained herein except pursuant to this license grant from Synopsys, or to the extent it applies, the GNU Public License.  If you do not agree with this notice, including the disclaimer below, then you are not authorized by Synopsys to use the Software.
+
+THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS" BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+
+
+
diff --git a/drivers/net/ethernet/atheros/nss-gmac/Makefile b/drivers/net/ethernet/atheros/nss-gmac/Makefile
new file mode 100644
index 0000000..376775e
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/Makefile
@@ -0,0 +1,19 @@
+###################################################
+# Makefile for the NSS GMAC driver
+###################################################
+
+obj ?= .
+
+obj-m += qca-nss-gmac.o
+
+qca-nss-gmac-objs +=	nss_gmac_dev.o \
+			nss_gmac_ctrl.o \
+			nss_gmac_init.o \
+			nss_gmac_ethtool.o \
+			nss_gmac_tx_rx_offload.o \
+			nss_gmac_mdiobus.o
+
+GMAC_INCLUDE = -I$(obj)/include -I$(obj)/exports
+
+ccflags-y += $(GMAC_INCLUDE)
+
diff --git a/drivers/net/ethernet/atheros/nss-gmac/exports/nss_gmac_api_if.h b/drivers/net/ethernet/atheros/nss-gmac/exports/nss_gmac_api_if.h
new file mode 100644
index 0000000..ab600fd
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/exports/nss_gmac_api_if.h
@@ -0,0 +1,126 @@
+/*
+ **************************************************************************
+ * Copyright (c) 2014-2015, The Linux Foundation. All rights reserved.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for
+ * any purpose with or without fee is hereby granted, provided that the
+ * above copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
+ * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ **************************************************************************
+ */
+/*
+ * nss_gmac_api_if.h
+ *	nss-gmac exported structure/apis.
+ */
+
+#ifndef __GMAC_API_IF_H
+#define __GMAC_API_IF_H
+
+#define NSS_GMAC_NORMAL_FRAME_MTU 1500
+#define NSS_GMAC_MINI_JUMBO_FRAME_MTU 1978
+#define NSS_GMAC_FULL_JUMBO_FRAME_MTU 9600
+
+/*
+ * NSS GMAC event type
+ */
+#define NSS_GMAC_EVENT_STATS	0
+#define NSS_GMAC_EVENT_OTHER	1
+
+/*
+ * NSS GMAC status
+ */
+#define NSS_GMAC_SUCCESS	0	/* Success */
+#define NSS_GMAC_FAILURE	1	/* Failure */
+
+/*
+ * NSS GMAC mode
+ */
+#define NSS_GMAC_MODE0	0	/* gmac mode 0 */
+#define NSS_GMAC_MODE1	1	/* gmac mode 1 */
+
+/*
+ * NSS GMAC data plane ops, default would be slowpath and can be override by
+ * nss-drv
+ */
+struct nss_gmac_data_plane_ops {
+	int (*open)(void *ctx, uint32_t tx_desc_ring, uint32_t rx_desc_ring,
+							uint32_t mode);
+	int (*close)(void *ctx);
+	int (*link_state)(void *ctx, uint32_t link_state);
+	int (*mac_addr)(void *ctx, uint8_t *addr);
+	int (*change_mtu)(void *ctx, uint32_t mtu);
+	int (*xmit)(void *ctx, struct sk_buff *os_buf);
+};
+
+/*
+ * struct nss_gmac_stats
+ * The NA per-GMAC statistics statistics structure.
+ */
+struct nss_gmac_stats {
+	int32_t interface;		/**< Interface number */
+	uint32_t rx_bytes;		/**< Number of RX bytes */
+	uint32_t rx_packets;		/**< Number of RX packets */
+	uint32_t rx_errors;		/**< Number of RX errors */
+	uint32_t rx_receive_errors;	/**< Number of RX receive errors */
+	uint32_t rx_overflow_errors;	/**< Number of RX overflow errors */
+	uint32_t rx_descriptor_errors;	/**< Number of RX descriptor errors */
+	uint32_t rx_watchdog_timeout_errors;
+					/**< Number of RX watchdog timeout errors */
+	uint32_t rx_crc_errors;		/**< Number of RX CRC errors */
+	uint32_t rx_late_collision_errors;
+					/**< Number of RX late collision errors */
+	uint32_t rx_dribble_bit_errors;	/**< Number of RX dribble bit errors */
+	uint32_t rx_length_errors;	/**< Number of RX length errors */
+	uint32_t rx_ip_header_errors;	/**< Number of RX IP header errors */
+	uint32_t rx_ip_payload_errors;	/**< Number of RX IP payload errors */
+	uint32_t rx_no_buffer_errors;	/**< Number of RX no-buffer errors */
+	uint32_t rx_transport_csum_bypassed;
+					/**< Number of RX packets where the transport checksum was bypassed */
+	uint32_t tx_bytes;		/**< Number of TX bytes */
+	uint32_t tx_packets;		/**< Number of TX packets */
+	uint32_t tx_collisions;		/**< Number of TX collisions */
+	uint32_t tx_errors;		/**< Number of TX errors */
+	uint32_t tx_jabber_timeout_errors;
+					/**< Number of TX jabber timeout errors */
+	uint32_t tx_frame_flushed_errors;
+					/**< Number of TX frame flushed errors */
+	uint32_t tx_loss_of_carrier_errors;
+					/**< Number of TX loss of carrier errors */
+	uint32_t tx_no_carrier_errors;	/**< Number of TX no carrier errors */
+	uint32_t tx_late_collision_errors;
+					/**< Number of TX late collision errors */
+	uint32_t tx_excessive_collision_errors;
+					/**< Number of TX excessive collision errors */
+	uint32_t tx_excessive_deferral_errors;
+					/**< Number of TX excessive deferral errors */
+	uint32_t tx_underflow_errors;	/**< Number of TX underflow errors */
+	uint32_t tx_ip_header_errors;	/**< Number of TX IP header errors */
+	uint32_t tx_ip_payload_errors;	/**< Number of TX IP payload errors */
+	uint32_t tx_dropped;		/**< Number of TX dropped packets */
+	uint32_t hw_errs[10];		/**< GMAC DMA error counters */
+	uint32_t rx_missed;		/**< Number of RX packets missed by the DMA */
+	uint32_t fifo_overflows;	/**< Number of RX FIFO overflows signalled by the DMA */
+	uint32_t rx_scatter_errors;	/**< Number of scattered frames received by the DMA */
+	uint32_t gmac_total_ticks;	/**< Total clock ticks spend inside the GMAC */
+	uint32_t gmac_worst_case_ticks;	/**< Worst case iteration of the GMAC in ticks */
+	uint32_t gmac_iterations;	/**< Number of iterations around the GMAC */
+};
+
+extern void nss_gmac_receive(struct net_device *netdev, struct sk_buff *skb,
+						struct napi_struct *napi);
+extern void nss_gmac_event_receive(void *if_ctx, int ev_type,
+						void *os_buf, uint32_t len);
+void nss_gmac_start_data_plane(struct net_device *netdev, void *ctx);
+extern int nss_gmac_override_data_plane(struct net_device *netdev,
+			struct nss_gmac_data_plane_ops *dp_ops, void *ctx);
+extern void nss_gmac_restore_data_plane(struct net_device *netdev);
+extern struct net_device *nss_gmac_get_netdev_by_macid(int macid);
+extern bool nss_gmac_is_in_open_state(struct net_device *netdev);
+#endif
diff --git a/drivers/net/ethernet/atheros/nss-gmac/include/msm_nss_gmac.h b/drivers/net/ethernet/atheros/nss-gmac/include/msm_nss_gmac.h
new file mode 100644
index 0000000..375a1a7
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/include/msm_nss_gmac.h
@@ -0,0 +1,338 @@
+/*
+ **************************************************************************
+ * Copyright (c) 2014-2015, The Linux Foundation. All rights reserved.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for
+ * any purpose with or without fee is hereby granted, provided that the
+ * above copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
+ * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ **************************************************************************
+ */
+
+#ifndef __MSM_NSS_GMAC_H
+#define __MSM_NSS_GMAC_H
+
+#include <linux/phy.h>
+
+#include <msm_nss_macsec.h>
+
+/* NSS GMAC Base Addresses */
+#define NSS_GMAC0_BASE			0x37000000
+#define NSS_GMAC1_BASE			0x37200000
+#define NSS_GMAC2_BASE			0x37400000
+#define NSS_GMAC3_BASE			0x37600000
+#define NSS_GMAC_REG_LEN		0x00200000
+
+/* NSS GMAC Specific defines */
+#define NSS_REG_BASE			0x03000000
+#define NSS_REG_LEN			0x0000FFFF
+
+
+/* Offsets of NSS config and status registers within NSS_REG_BASE */
+/* We start the GMAC numbering from 0 */
+#define NSS_CSR_REV			0x0000
+#define NSS_CSR_CFG			0x0004
+#define NSS_ETH_CLK_GATE_CTL		0x0008
+#define NSS_ETH_CLK_DIV0		0x000C
+#define NSS_ETH_CLK_DIV1		0x0010
+#define NSS_ETH_CLK_SRC_CTL		0x0014
+#define NSS_ETH_CLK_INV_CTL		0x0018
+#define NSS_MACSEC_CTL			0x0028
+#define NSS_QSGMII_CLK_CTL		0x002C
+#define NSS_GMAC0_CTL			0x0030
+#define NSS_GMAC1_CTL			0x0034
+#define NSS_GMAC2_CTL			0x0038
+#define NSS_GMAC3_CTL			0x003C
+#define NSS_ETH_CLK_ROOT_STAT		0x0040
+#define NSS_QSGMII_STAT			0x0044
+#define NSS_ETH_SPARE_CTL		0x0088
+#define NSS_ETH_SPARE_STAT		0x008C
+
+
+/* Macros to calculate register offsets */
+#define NSS_GMACn_CTL(n)		(NSS_GMAC0_CTL +  (n * 4))
+#define NSS_ETH_CLK_CTLn(x)		(NSS_ETH_CLK_CTL0 +  (x * 4))
+
+
+/* NSS_ETH_CLK_GATE_CTL bits */
+#define MACSEC3_CORE_CLK		(1 << 30)
+#define MACSEC2_CORE_CLK		(1 << 29)
+#define MACSEC1_CORE_CLK		(1 << 28)
+#define MACSEC_CORE_CLKEN_VAL		(0x7 << 28)
+#define MACSEC_GMII_RX_CLKEN_VAL	(0x7 << 24)
+#define MACSEC_GMII_TX_CLKEN_VAL	(0x7 << 20)
+#define GMAC0_PTP_CLK			(1 << 16)
+#define GMAC0_RGMII_RX_CLK		(1 << 9)
+#define GMAC0_RGMII_TX_CLK		(1 << 8)
+#define GMAC0_GMII_RX_CLK		(1 << 4)
+#define GMAC0_GMII_TX_CLK		(1 << 0)
+
+#define GMAC0_RGMII_TX_CLK_SHIFT		8
+#define GMAC0_RGMII_RX_CLK_SHIFT		9
+#define GMAC0_GMII_RX_CLK_SHIFT			4
+#define GMAC0_GMII_TX_CLK_SHIFT			0
+#define GMAC0_PTP_CLK_SHIFT			16
+
+/* Macros to calculate bit offsets in NSS_ETH_CLK_GATE_CTL register
+ * MACSEC_CORE_CLK: x = 1,2,3
+ * GMII_xx_CLK: x = 0,1,2,3
+ * RGMII_xx_CLK: x = 0,1
+ * PTP_CLK: x = 0,1,2,3
+*/
+#define MACSECn_CORE_CLK(x)	(1 << (MACSEC1_CORE_CLK + x))
+#define GMACn_GMII_TX_CLK(x)	(1 << (GMAC0_GMII_TX_CLK_SHIFT + x))
+#define GMACn_GMII_RX_CLK(x)	(1 << (GMAC0_GMII_RX_CLK_SHIFT + x))
+#define GMACn_RGMII_TX_CLK(x)	(1 << (GMAC0_RGMII_TX_CLK_SHIFT + (x * 2)))
+#define GMACn_RGMII_RX_CLK(x)	(1 << (GMAC0_RGMII_RX_CLK_SHIFT + (x * 2)))
+#define GMACn_PTP_CLK(x)	(1 << (GMAC0_PTP_CLK_SHIFT + x))
+
+/* NSS_ETH_CLK_DIV0 bits ; n = 0,1,2,3 */
+/* PHY increments divider values by 1. Hence the values here are (x - 1) */
+#define RGMII_CLK_DIV_1000			1
+#define RGMII_CLK_DIV_100			9
+#define RGMII_CLK_DIV_10			99
+#define SGMII_CLK_DIV_1000			0
+#define SGMII_CLK_DIV_100			4
+#define SGMII_CLK_DIV_10			49
+#define QSGMII_CLK_DIV_1000			1
+#define QSGMII_CLK_DIV_100			9
+#define QSGMII_CLK_DIV_10			99
+#define GMACn_CLK_DIV_SIZE			0x7F
+#define GMACn_CLK_DIV(n, val)			(val << (n * 8))
+
+/* NSS_ETH_CLK_SRC_CTL bits */
+#define GMAC0_GMII_CLK_RGMII			(1 << 0)
+#define GMAC1_GMII_CLK_RGMII			(1 << 1)
+
+/* NSS_MACSEC_CTL bits */
+#define GMAC1_MACSEC_BYPASS		0x1
+#define GMACn_MACSEC_BYPASS(n)		(GMAC1_MACSEC_BYPASS << (n - 1))
+					/* n = 1,2,3 */
+#define MACSEC_EXT_BYPASS_EN_MASK	0x7
+#define MACSEC_DP_RST_VAL		(0x7 << 4)
+
+/* Macros to calculate bit offsets in NSS_ETH_CLK_CTL3 register */
+#define GMACn_GMII_CLK_RGMII(x)			(1 << x)
+
+/* NSS_QSGMII_CLK_CTL bits */
+#define GMAC0_TX_CLK_HALT			(1 << 7)
+#define GMAC0_RX_CLK_HALT			(1 << 8)
+#define GMAC1_TX_CLK_HALT			(1 << 9)
+#define GMAC1_RX_CLK_HALT			(1 << 10)
+#define GMAC2_TX_CLK_HALT			(1 << 11)
+#define GMAC2_RX_CLK_HALT			(1 << 12)
+#define GMAC3_TX_CLK_HALT			(1 << 13)
+#define GMAC3_RX_CLK_HALT			(1 << 14)
+
+#define GMAC0_QSGMII_TX_CLK_SHIFT		7
+#define GMAC0_QSGMII_RX_CLK_SHIFT		8
+
+/* Macros to calculate bit offsets in NSS_QSGMII_CLK_CTL register */
+#define GMACn_QSGMII_TX_CLK(n)	(1 << (GMAC0_QSGMII_TX_CLK_SHIFT + (n * 2)))
+#define GMACn_QSGMII_RX_CLK(n)	(1 << (GMAC0_QSGMII_RX_CLK_SHIFT + (n * 2)))
+
+/* NSS_GMACn_CTL bits */
+#define GMAC_IFG_CTL(x)				(x)
+#define GMAC_IFG_LIMIT(x)			(x << 8)
+#define GMAC_PHY_RGMII				(1 << 16)
+#define GMAC_PHY_QSGMII				(0 << 16)
+#define GMAC_FLOW_CTL				(1 << 18)
+#define GMAC_CSYS_REQ				(1 << 19)
+#define GMAC_PTP_TRIG				(1 << 20)
+
+/* GMAC min Inter Frame Gap values */
+#define GMAC_IFG				12
+#define MACSEC_IFG				(0x2D)
+#define IFG_MASK				(0x3F)
+#define GMAC_IFG_MIN_1000			10
+#define GMAC_IFG_MIN_HALF_DUPLEX		8
+
+/*
+ * GMAC min Inter Frame Gap Limits.
+ * In full duplex mode set to same value as IFG
+*/
+#define GMAC_IFG_LIMIT_HALF			12
+
+/* QSGMII Specific defines */
+#define QSGMII_REG_BASE				0x1bb00000
+#define QSGMII_REG_LEN				0x0000FFFF
+
+/* QSGMII Register offsets */
+#define PCS_QSGMII_CTL				0x020
+#define PCS_QSGMII_SGMII_MODE			0x064
+#define PCS_MODE_CTL				0x068
+#define PCS_QSGMII_MAC_STAT			0x074
+#define PCS_ALL_CH_CTL				0x080
+#define PCS_ALL_CH_STAT				0x084
+#define PCS_CAL_LCKDT_CTL			0x120
+#define PCS_CAL_LCKDT_CTL_STATUS		0x124
+#define QSGMII_PHY_MODE_CTL			0x128
+#define QSGMII_PHY_QSGMII_CTL			0x134
+#define QSGMII_PHY_SGMII_1_CTL			0x13C
+#define QSGMII_PHY_SGMII_2_CTL			0x140
+#define QSGMII_PHY_SERDES_CTL			0x144
+
+/* Bit definitions for PCS_QSGMII_CTL register */
+#define PCS_CH0_SERDES_SN_DETECT	0x800
+#define PCS_CHn_SERDES_SN_DETECT(n)	(PCS_CH0_SERDES_SN_DETECT << n)
+#define PCS_CH0_SERDES_SN_DETECT_2	0x10000
+#define PCS_CHn_SERDES_SN_DETECT_2(n)	(PCS_CH0_SERDES_SN_DETECT_2 << n)
+#define PCS_QSGMII_DEPTH_THRESH_MASK	0x300
+#define PCS_QSGMII_DEPTH_THRESH(n)	(n << 8)
+					/* Threshold for depth control */
+#define PCS_QSGMII_SHORT_LATENCY	0x20
+#define PCS_QSGMII_SHORT_THRESH		0x10
+#define PCS_QSGMII_CUTTHROUGH_RX	0x8
+#define PCS_QSGMII_CUTTHROUGH_TX	0x4
+#define PCS_QSGMII_SW_VER_1_7		0x2
+#define PCS_QSGMII_ATHR_CSCO_AUTONEG	0x1
+
+
+/* Bit definitions for PCS_QSGMII_SGMII_MODE */
+#define PCS_QSGMII_MODE_SGMII			(0x0 << 0)
+#define PCS_QSGMII_MODE_QSGMII			(0x1 << 0)
+
+/* Bit definitions for QSGMII_PHY_MODE_CTL */
+#define QSGMII_PHY_MODE_SGMII			(0x0 << 0)
+#define QSGMII_PHY_MODE_QSGMII			(0x1 << 0)
+
+/* Bit definitions for PCS_MODE_CTL register */
+#define PCS_MODE_CTL_BASE_X			0x00
+#define PCS_MODE_CTL_SGMII_PHY			0x01
+#define PCS_MODE_CTL_SGMII_MAC			0x02
+#define PCS_MODE_CTL_CH0_PHY_RESET		0x10
+#define PCS_MODE_CTL_CH0_PHY_LOOPBACK		0x20
+#define PCS_MODE_CTL_CH0_AUTONEG_RESTART	0x40
+#define PCS_MODE_CTL_CH0_AUTONEG_EN		0x80
+#define PCS_MODE_CTL_CHn_PHY_RESET(n)		(PCS_MODE_CTL_CH0_PHY_RESET << (n * 8))
+#define PCS_MODE_CTL_CHn_PHY_LOOPBACK(n)	(PCS_MODE_CTL_CH0_PHY_LOOPBACK << (n * 8))
+#define PCS_MODE_CTL_CHn_AUTONEG_EN(n)		(PCS_MODE_CTL_CH0_AUTONEG_EN << (n * 8))
+#define PCS_MODE_CTL_CHn_AUTONEG_RESTART(n)	(PCS_MODE_CTL_CH0_AUTONEG_RESTART << (n * 8))
+
+/* Bit definitions for PCS_QSGMII_MAC_STAT register */
+#define PCS_MAC_STAT_CH0_LINK		0x0001
+#define PCS_MAC_STAT_CH0_DUPLEX		0x0002
+#define PCS_MAC_STAT_CH0_SPEED_MASK	0x000C
+#define PCS_MAC_STAT_CH0_PAUSE		0x0010
+#define PCS_MAC_STAT_CH0_ASYM_PAUSE	0x0020
+#define PCS_MAC_STAT_CH0_TX_PAUSE	0x0040
+#define PCS_MAC_STAT_CH0_RX_PAUSE	0x0080
+#define PCS_MAC_STAT_CHn_LINK(n)	(PCS_MAC_STAT_CH0_LINK << (n * 8))
+#define PCS_MAC_STAT_CHn_DUPLEX(n)	(PCS_MAC_STAT_CH0_DUPLEX << (n * 8))
+#define PCS_MAC_STAT_CHn_SPEED_MASK(n)	(PCS_MAC_STAT_CH0_SPEED_MASK << (n * 8))
+#define PCS_MAC_STAT_CHn_SPEED(n, reg)	((reg & PCS_MAC_STAT_CHn_SPEED_MASK(n)) >> ((n * 8) + 2))
+#define PCS_MAC_STAT_CHn_PAUSE		(PCS_MAC_STAT_CH0_PAUSE << (n * 8))
+#define PCS_MAC_STAT_CHn_ASYM_PAUSE	(PCS_MAC_STAT_CH0_ASYM_PAUSE << (n * 8))
+#define PCS_MAC_STAT_CHn_TX_PAUSE	(PCS_MAC_STAT_CH0_TX_PAUSE << (n * 8))
+#define PCS_MAC_STAT_CHn_RX_PAUSE	(PCS_MAC_STAT_CH0_RX_PAUSE << (n * 8))
+
+/* Bit definitions for PCS_ALL_CH_CTL register */
+#define PCS_CH0_FORCE_SPEED			0x2
+#define PCS_CHn_FORCE_SPEED(n)			(PCS_CH0_FORCE_SPEED << (n * 4))
+#define PCS_CH0_SPEED_MASK			0xC
+#define PCS_CHn_SPEED_MASK(n)			(PCS_CH0_SPEED_MASK << (n * 4))
+#define PCS_CH_SPEED_10				0x0
+#define PCS_CH_SPEED_100			0x4
+#define PCS_CH_SPEED_1000			0x8
+#define PCS_CHn_SPEED(ch, speed)		(speed << (ch * 4))
+
+/* Bit definitions for PCS_ALL_CH_STAT register */
+#define PCS_CH0_AUTONEG_COMPLETE	0x0040
+#define PCS_CHn_AUTONEG_COMPLETE(n)	(PCS_CH0_AUTONEG_COMPLETE << (n * 8))
+
+
+/* Bit definitions for PCS_CAL_LCKDT_CTL register */
+#define PCS_LCKDT_RST				0x80000
+
+/* Bit definitions for QSGMII_PHY_QSGMII_CTL register */
+#define QSGMII_PHY_CDR_EN			0x00000001
+#define QSGMII_PHY_RX_FRONT_EN			0x00000002
+#define QSGMII_PHY_RX_SIGNAL_DETECT_EN		0x00000004
+#define QSGMII_PHY_TX_DRIVER_EN			0x00000008
+#define QSGMII_PHY_NEAR_END_LOOPBACK		0x00000020
+#define QSGMII_PHY_FAR_END_LOOPBACK		0x00000040
+#define QSGMII_PHY_QSGMII_EN			0x00000080
+#define QSGMII_PHY_SLEW_RATE_CTL_MASK		0x00000300
+#define QSGMII_PHY_SLEW_RATE_CTL(x)		(x << 8)
+#define QSGMII_PHY_DEEMPHASIS_LVL_MASK		0x00000C00
+#define QSGMII_PHY_DEEMPHASIS_LVL(x)		(x << 10)
+#define QSGMII_PHY_PHASE_LOOP_GAIN_MASK		0x00007000
+#define QSGMII_PHY_PHASE_LOOP_GAIN(x)		(x << 12)
+#define QSGMII_PHY_RX_DC_BIAS_MASK		0x000C0000
+#define QSGMII_PHY_RX_DC_BIAS(x)		(x << 18)
+#define QSGMII_PHY_RX_INPUT_EQU_MASK		0x00300000
+#define QSGMII_PHY_RX_INPUT_EQU(x)		(x << 20)
+#define QSGMII_PHY_CDR_PI_SLEW_MASK		0x00C00000
+#define QSGMII_PHY_CDR_PI_SLEW(x)		(x << 22)
+#define QSGMII_PHY_SIG_DETECT_THRESH_MASK	0x03000000
+#define QSGMII_PHY_SIG_DETECT_THRESH(x)		(x << 24)
+#define QSGMII_PHY_TX_SLEW_MASK			0x0C000000
+#define QSGMII_PHY_TX_SLEW(x)			(x << 26)
+#define QSGMII_PHY_TX_DRV_AMP_MASK		0xF0000000
+#define QSGMII_PHY_TX_DRV_AMP(x)		(x << 28)
+
+
+/* Bit definitions for QSGMII_PHY_SERDES_CTL register */
+#define SERDES_100MHZ_OSC_CLK			0x00000001
+#define SERDES_LOCK_DETECT_EN			0x00000002
+#define SERDES_PLL_EN				0x00000004
+#define SERDES_VCO_MANUAL_CAL			0x00000008
+#define SERDES_PLL_LOOP_FILTER_MASK		0x00000070
+#define SERDES_PLL_LOOP_FILTER(x)		(x << 4)
+#define SERDES_RSV_MASK				0x00FF0000
+#define SERDES_RSV(x)				(x << 16)
+#define SERDES_PLL_AMP_MASK			0x07000000
+#define SERDES_PLL_AMP(x)			(x << 24)
+#define SERDES_PLL_ICP_MASK			0x70000000
+#define SERDES_PLL_ICP(x)			(x << 28)
+
+/* Interface between GMAC and PHY */
+#define GMAC_INTF_RGMII				0
+#define GMAC_INTF_SGMII				1
+#define GMAC_INTF_QSGMII			2
+
+/* For MII<->MII Interfaces that do not use an Ethernet PHY */
+#define NSS_GMAC_NO_MDIO_PHY			PHY_MAX_ADDR
+
+/* GMAC phy interface profiles */
+#define NSS_GMAC_PHY_PROFILE_2R_2S	0	/* 2 RGMII, 2 SGMII */
+#define NSS_GMAC_PHY_PROFILE_1R_3S	1	/* 1 RGMII, 3 SGMII*/
+#define NSS_GMAC_PHY_PROFILE_QS		2	/* 4 QSGMII */
+
+extern int32_t nss_gmac_get_phy_profile(void);
+
+struct msm_nss_gmac_platform_data {
+	uint32_t phy_mdio_addr;		/* MDIO address of the connected PHY */
+	uint32_t poll_required;		/* [0/1] Link status poll? */
+	uint32_t rgmii_delay;
+	uint32_t phy_mii_type;
+	uint32_t emulation;		/* Running on emulation platform */
+	uint8_t  mac_addr[6];
+	int32_t forced_speed;		/* Forced speed. Values used from
+					   ethtool.h. 0 = Speed not forced */
+	int32_t forced_duplex;		/* Forced duplex. Values used from
+					   ethtool.h. 0 = Duplex not forced. */
+	uint32_t socver;
+};
+
+#define NSS_MAX_GMACS				4
+#define IPQ806X_MDIO_BUS_NAME			"mdio-gpio"
+#define IPQ806X_MDIO_BUS_NUM			0
+#define IPQ806X_MDIO_BUS_MAX			1
+
+#define IPQ806X_CLK_CTL_PHYS			0x00900000
+#define IPQ806X_CLK_CTL_SIZE			SZ_16K
+#define IPQ806X_TCSR_BASE			0x1A400000
+#define IPQ806X_TCSR_SIZE			0xFFFF
+
+#endif /*__ASM_NSS_GMAC_H */
+
+
+
diff --git a/drivers/net/ethernet/atheros/nss-gmac/include/msm_nss_macsec.h b/drivers/net/ethernet/atheros/nss-gmac/include/msm_nss_macsec.h
new file mode 100644
index 0000000..a3e7a91
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/include/msm_nss_macsec.h
@@ -0,0 +1,73 @@
+/*
+ **************************************************************************
+ * Copyright (c) 2014, The Linux Foundation. All rights reserved.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for
+ * any purpose with or without fee is hereby granted, provided that the
+ * above copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
+ * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ **************************************************************************
+ */
+
+#ifndef __MSM_NSS_MACSEC_H
+#define __MSM_NSS_MACSEC_H
+
+/* NSS MACSEC Base Addresses */
+#define NSS_MACSEC1_BASE			0x37800000
+#define NSS_MACSEC2_BASE			0x37A00000
+#define NSS_MACSEC3_BASE			0x37C00000
+#define NSS_MACSEC_REG_LEN			0x00200000
+
+/* MACSEC REGS Offsets of NSS_CSR_REG_BASE */
+#define NSS_MACSEC1_CORE_CLK_FS_CTL		0x001C
+#define NSS_MACSEC2_CORE_CLK_FS_CTL		0x0020
+#define NSS_MACSEC3_CORE_CLK_FS_CTL		0x0024
+#define NSS_ETH_MACSEC_TEST_BUS_EN		0x0078
+#define NSS_ETH_MACSEC_TEST_BUS_1		0x007c
+
+/* MACSEC REG Offset of CLK_CTL_BASE */
+#define MACSEC_CORE1_RESET			0x3E28
+#define MACSEC_CORE2_RESET			0x3E2C
+#define MACSEC_CORE3_RESET			0x3E30
+
+/* NSSFB1 */
+#define NSSFB1_CLK_CTL_ACR			0x1380
+#define NSSFB1_PLL_ENA_APCS		0x34C0
+#define NSSFB1_PLL14_MODE		0x31C0
+#define NSSFB1_PLL14_L_VAL		0x31C4
+#define NSSFB1_PLL14_M_VAL		0x31C8
+#define NSSFB1_PLL14_N_VAL		0x31CC
+#define NSSFB1_PLL14_TEST_CTL		0x31D0
+#define NSSFB1_PLL14_CONFIG		0x31D4
+#define NSSFB1_PLL14_STATUS		0x31D8
+#define NSSFB1_PLL18_MODE		0x31A0
+#define NSSFB1_PLL18_L_VAL		0x31A4
+#define NSSFB1_PLL18_M_VAL		0x31A8
+#define NSSFB1_PLL18_N_VAL		0x31AC
+#define NSSFB1_PLL18_TEST_CTL		0x31B0
+#define NSSFB1_PLL18_CONFIG		0x31B4
+#define NSSFB1_PLL18_STATUS		0x31B8
+#define NSSFB1_CLK_CTL_SRC_CTL		0x3BE0
+#define NSSFB1_CLK_CTL_SRC0_NS		0x3BE4
+#define NSSFB1_CLK_CTL_SRC1_NS		0x3BE8
+#define NSSFB1_CLK_CTL			0x3C00
+
+/* S_W_VAL in MACSEC_CORE_CLK_FS_CTL S_W_VAL */
+#define MACSEC_CLK_FS_CTL_S_W_VAL		0x5
+#define MACSEC_CLK_FS_CTL_S_W_VAL_MASK		0xF
+
+/* MACSEC_CORE_RESET bit */
+#define MACSEC_CORE_RESET_BIT			(1 << 0)
+
+/* MACSEC COMMAND_CONFIG bit */
+#define MACSEC_CMDCFG_ETH_SPEED_BIT		(1 << 3)
+#define MACSEC_CMDCFG_ENA_10_BIT		(1 << 25)
+#endif /*__ASM_NSS_MACSEC_H */
+
diff --git a/drivers/net/ethernet/atheros/nss-gmac/include/nss_gmac_clocks.h b/drivers/net/ethernet/atheros/nss-gmac/include/nss_gmac_clocks.h
new file mode 100644
index 0000000..960049b
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/include/nss_gmac_clocks.h
@@ -0,0 +1,100 @@
+/*
+ * Copyright (c) 2013-2015, The Linux Foundation. All rights reserved.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
+ * SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
+ * RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT
+ * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
+ * USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef __NSS_GMAC_CLOCKS_H
+#define __NSS_GMAC_CLOCKS_H
+
+#include <asm/io.h>
+
+#ifndef CONFIG_OF
+#include <mach/msm_iomap.h>
+#endif
+
+/* Peripheral clock registers. */
+#define NSS_ACC_REG				(0x28EC)
+#define NSS_RESET_SPARE				(0x3B60)
+#define CLK_HALT_NSSFAB0_NSSFAB1_STATEA		(0x3C20)
+#define GMAC_COREn_CLK_SRC_CTL(n)		(0x3CA0+(32*n))
+#define GMAC_COREn_CLK_SRC0_MD(n)		(0x3CA4+(32*n))
+#define GMAC_COREn_CLK_SRC1_MD(n)		(0x3CA8+(32*n))
+#define GMAC_COREn_CLK_SRC0_NS(n)		(0x3CAC+(32*n))
+#define GMAC_COREn_CLK_SRC1_NS(n)		(0x3CB0+(32*n))
+#define GMAC_COREn_CLK_CTL(n)			(0x3CB4+(32*n))
+#define GMAC_COREn_CLK_FS(n)			(0x3CB8+(32*n))
+#define GMAC_COREn_RESET(n)			(0x3CBC+(32*n))
+#define GMAC_AHB_RESET				(0x3E24)
+
+
+#define GMAC_ACC_CUST_MASK	0xFF000000	/* Custom ACC fields for GMAC
+						   memories		      */
+#define GMAC_FS_S_W_VAL		8		/* Wake and sleep counter value
+						   of memory footswitch control.
+						   Assuming max core frequency
+						   is 266MHz		      */
+
+/* NSS_RESET_SPARE register bits */
+#define CAL_PBRS_RST_N_RESET		0x04000000
+#define LCKDT_RST_N_RESET		0x08000000
+#define SRDS_N_RESET			0x10000000
+
+
+/* GMAC_COREn_CLK_SRC_CTL register bits */
+#define GMAC_DUAL_MN8_SEL		0x00000001
+#define GMAC_CLK_ROOT_ENA		0x00000002
+#define GMAC_CLK_LOW_PWR_ENA		0x00000004
+
+/* GMAC_COREn_CLK_SRC[0,1]_MD register bits (Assuming 133MHz) */
+#define GMAC_CORE_CLK_M		0x32
+#define GMAC_CORE_CLK_D		0		/* NOT(2*D) value */
+#define GMAC_CORE_CLK_M_SHIFT	16
+#define GMAC_CORE_CLK_D_SHIFT	0
+#define GMAC_CORE_CLK_M_VAL	(GMAC_CORE_CLK_M << GMAC_CORE_CLK_M_SHIFT)
+#define GMAC_CORE_CLK_D_VAL	(GMAC_CORE_CLK_D << GMAC_CORE_CLK_D_SHIFT)
+
+/* GMAC_COREn_CLK_SRC[0,1]_NS register bits (Assuming 133MHz) */
+#define GMAC_CORE_CLK_N		0x4		/* NOT(N-M) value N=301	      */
+#define GMAC_CORE_CLK_N_SHIFT	16
+#define GMAC_CORE_CLK_N_VAL	(GMAC_CORE_CLK_N << GMAC_CORE_CLK_N_SHIFT)
+#define GMAC_CORE_CLK_MNCNTR_EN		0x00000100	/* Enable M/N counter */
+#define GMAC_CORE_CLK_MNCNTR_RST	0x00000080	/* Activate reset for
+							   M/N counter	      */
+#define GMAC_CORE_CLK_MNCNTR_MODE_MASK	0x00000060	/* M/N counter mode
+							   mask		      */
+#define GMAC_CORE_CLK_MNCNTR_MODE_SHIFT	5
+#define GMAC_CORE_CLK_MNCNTR_MODE_DUAL	(2 << GMAC_CORE_CLK_MNCNTR_MODE_SHIFT)
+							/* M/N counter mode
+							   dual-edge	      */
+#define GMAC_CORE_CLK_PRE_DIV_SEL_MASK	0x00000018	/* Pre divider select
+							   mask		      */
+#define GMAC_CORE_CLK_PRE_DIV_SEL_SHIFT	3
+#define GMAC_CORE_CLK_PRE_DIV_SEL_BYP	(0 << GMAC_CORE_CLK_PRE_DIV_SEL_SHIFT)
+							/* Pre divider bypass */
+#define GMAC_CORE_CLK_SRC_SEL_MASK	0x00000007	/* clk source Mux select
+							   mask		      */
+#define GMAC_CORE_CLK_SRC_SEL_SHIFT	0
+#define GMAC_CORE_CLK_SRC_SEL_PLL0	(2 << GMAC_CORE_CLK_SRC_SEL_SHIFT)
+							/* output of clk source
+							   Mux is PLL0	      */
+
+/* CLK_HALT_NSSFAB0_NSSFAB1_STATEA register bits */
+#define GMACn_CORE_CLK_HALT(x)		(0x0010 << x)
+
+/* GMAC_COREn_CLK_CTL register bits */
+#define GMAC_CLK_BRANCH_EN		0x0010
+#define GMAC_CLK_INV			0x0020
+#define GMAC_CLK_FABRIC_GATE_EN		0x0040
+
+#endif /* __NSS_GMAC_CLOCKS_H */
diff --git a/drivers/net/ethernet/atheros/nss-gmac/include/nss_gmac_dev.h b/drivers/net/ethernet/atheros/nss-gmac/include/nss_gmac_dev.h
new file mode 100644
index 0000000..0f304cc
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/include/nss_gmac_dev.h
@@ -0,0 +1,2136 @@
+/*
+ **************************************************************************
+ * Copyright (c) 2013-2015, The Linux Foundation. All rights reserved.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for
+ * any purpose with or without fee is hereby granted, provided that the
+ * above copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
+ * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ **************************************************************************
+ */
+/*
+ * @file
+ * This file defines the function prototypes for the NSS GMAC device.
+ * Since the phy register mapping are standardised, the phy register map and the
+ * bit definitions remain the same for other phy as well.
+ * This also defines some of the Ethernet related parmeters.
+ *  ---------------------------REVISION HISTORY---------------------------------
+ * Qualcomm Atheros		01/Mar/2013		Modified for QCA NSS
+ * Synopsys			01/Aug/2007			Created
+ */
+
+#ifndef __NSS_GMAC_DEV_H__
+#define __NSS_GMAC_DEV_H__
+
+#include <linux/if_vlan.h>
+#include <linux/platform_device.h>
+#include <linux/ethtool.h>
+#include <linux/dma-mapping.h>
+#include <asm/cacheflush.h>
+#include <asm/io.h>
+
+#ifdef CONFIG_OF
+#include <msm_nss_gmac.h>
+#else
+#include <mach/msm_nss_gmac.h>
+#endif
+#include <nss_gmac_api_if.h>
+
+
+#define NSS_GMAC_IPC_OFFLOAD
+
+#define NSS_GMAC_MACBASE	0x0000	/* Offset of Mac registers within
+					   GMAC register space                */
+#define NSS_GMAC_DMABASE	0x1000	/* Offset of Dma registers within
+					   GMAC register space                */
+#define NSS_GMAC_REG_BLOCK_LEN	0x4000	/* Length of the register block to map*/
+
+#define NSS_GMAC_TX_DESC_SIZE	128	/* Tx Descriptors needed in the
+					   Descriptor pool/queue              */
+#define NSS_GMAC_RX_DESC_SIZE	128	/* Rx Descriptors needed in the
+					   Descriptor pool/queue              */
+#define DEFAULT_DELAY_VARIABLE  10
+#define DEFAULT_LOOP_VARIABLE   10
+#define MDC_CLK_DIV             (gmii_csr_clk0)
+
+#define NSS_GMAC_EXTRA			NET_IP_ALIGN
+#define NSS_GMAC_JUMBO_MTU		9600	/* Max jumbo frame size	*/
+
+/* Max size of buffer that can be programed into one field of desc */
+#define NSS_GMAC_MAX_DESC_BUFF		0x1FFF
+#define NSS_GMAC_RTL_VER		"(3.72a)"
+
+/* Ethtool specific list of GMAC supported features */
+#define NSS_GMAC_SUPPORTED_FEATURES	(SUPPORTED_10baseT_Half		\
+					| SUPPORTED_10baseT_Full	\
+					| SUPPORTED_100baseT_Half	\
+					| SUPPORTED_100baseT_Full	\
+					| SUPPORTED_1000baseT_Full	\
+					| SUPPORTED_Autoneg		\
+					| SUPPORTED_TP			\
+					| SUPPORTED_Pause		\
+					| SUPPORTED_Asym_Pause)
+
+/* Ethtool specific list of GMAC advertised features */
+#define NSS_GMAC_ADVERTISED_FEATURES	(ADVERTISED_10baseT_Half	\
+					| ADVERTISED_10baseT_Full	\
+					| ADVERTISED_100baseT_Half	\
+					| ADVERTISED_100baseT_Full	\
+					| ADVERTISED_1000baseT_Full	\
+					| ADVERTISED_Autoneg		\
+					| ADVERTISED_TP			\
+					| ADVERTISED_Pause		\
+					| ADVERTISED_Asym_Pause)
+
+/* MDIO address space register offsets */
+#define ATH_MII_MMD_ACCESS_CTRL				0xD
+#define ATH_MII_MMD_ACCESS_ADDR_DATA			0xE
+
+/* MMD device addresses */
+#define ATH_MMD_DEVADDR_3				3
+#define ATH_MMD_DEVADDR_7				7
+
+static const uint8_t nss_gmac_driver_string[] =
+	"NSS GMAC Driver for RTL v" NSS_GMAC_RTL_VER;
+static const uint8_t nss_gmac_driver_version[] = "1.0";
+static const uint8_t nss_gmac_copyright[] =
+	"Copyright (c) 2013-2014 The Linux Foundation. All rights reserved.";
+
+/**
+ * @brief DMA Descriptor Structure
+ * The structure is common for both receive and transmit descriptors
+ * The descriptor is of 4 words, but our structrue contains 6 words where last
+ * two words are to hold the virtual address of the network buffer pointers for
+ * driver's use.From the GMAC core release 3.50a onwards, the Enhanced
+ * Descriptor structure got changed. The descriptor (both transmit and receive)
+ * are of 8 words each rather the 4 words of normal descriptor structure.
+ * Whenever IEEE 1588 Timestamping is enabled TX/RX DESC6 provides the lower 32
+ * bits of Timestamp value and TX/RX DESC7 provides the upper 32 bits of
+ * Timestamp value.
+ * In addition to this whenever extended status bit is set (RX DESC0 bit 0),
+ * RX DESC4 contains the extended status information.
+ */
+struct dma_desc {
+	uint32_t status;	/* Status                             */
+	uint32_t length;	/* Buffer 1  and Buffer 2 length      */
+	uint32_t buffer1;	/* Network Buffer 1 pointer (Dma-able)*/
+	uint32_t data1;		/* This holds virtual address of
+				   buffer1, not used by DMA	      */
+
+	/* This data below is used only by driver */
+	uint32_t extstatus;	/* Extended status of a Rx Descriptor */
+	uint32_t reserved1;	/* Reserved word                      */
+	uint32_t timestamplow;	/* Lower 32 bits of the 64
+				   bit timestamp value                */
+	uint32_t timestamphigh;	/* Higher 32 bits of the 64
+					   bit timestamp value        */
+};
+
+enum desc_mode {
+	RINGMODE = 0x00000001,
+	CHAINMODE = 0x00000002,
+};
+
+#define NSS_GMAC_WORKQUEUE_NAME		"gmac_workqueue"
+struct nss_gmac_global_ctx;
+
+/**
+ * @brief NSS GMAC device data
+ */
+struct nss_gmac_dev {
+	uint32_t mac_base;	/* base address of MAC registers              */
+	uint32_t dma_base;	/* base address of DMA registers              */
+	uint32_t phy_base;	/* PHY device address on MII interface        */
+	uint32_t macid;		/* Sequence number of Mac on the platform     */
+	uint32_t version;	/* Gmac Revision version                      */
+	uint32_t emulation;	/* Running on emulation platform	      */
+	unsigned long int flags;/* status flags				      */
+
+	dma_addr_t tx_desc_dma;	/* Dma-able address of first tx descriptor
+				   either in ring or chain mode, this is used
+				   by the GMAC device                         */
+
+	dma_addr_t rx_desc_dma;	/* Dma-albe address of first rx descriptor
+				   either in ring or chain mode, this is
+				   used by the GMAC device                    */
+
+	struct dma_desc *tx_desc;/* start address of TX descriptors ring or
+				   chain, this is used by the driver          */
+
+	struct dma_desc *rx_desc;/* start address of RX descriptors ring or
+				   chain, this is used by the driver          */
+
+	uint32_t busy_tx_desc;	/* Number of Tx Descriptors owned by
+				   DMA at any given time                      */
+	uint32_t busy_rx_desc;	/* Number of Rx Descriptors owned by
+				   DMA at any given time                      */
+
+	uint32_t rx_desc_count;	/* number of rx descriptors in the
+				   tx descriptor queue/pool                   */
+	uint32_t tx_desc_count;	/* number of tx descriptors in the
+				   rx descriptor queue/pool                   */
+
+	uint32_t tx_busy;	/* index of the tx descriptor owned by DMA,
+				   is obtained by nss_gmac_get_tx_qptr()      */
+
+	uint32_t tx_next;	/* index of the tx descriptor next available
+				   with driver, given to DMA by
+				   nss_gmac_set_tx_qptr()                     */
+
+	uint32_t rx_busy;	/* index of the rx descriptor owned by DMA,
+				   obtained by nss_gmac_get_rx_qptr()         */
+
+	uint32_t rx_next;	/* index of the rx descriptor next available
+				   with driver, given to DMA by
+				   nss_gmac_set_rx_qptr()                     */
+
+	struct dma_desc *tx_busy_desc;	/* Tx Descriptor address corresponding
+				   to the index tx_busy                       */
+	struct dma_desc *tx_next_desc;	/* Tx Descriptor address corresponding
+				   to the index tx_next                       */
+	struct dma_desc *rx_busy_desc;	/* Rx Descriptor address corresponding
+				   to the index tx_busy                       */
+	struct dma_desc *rx_next_desc;	/* Rx Descriptor address corresponding
+				   to the index rx_next                       */
+
+	/*
+	 * Phy related stuff
+	 */
+	uint32_t mdc_clk_div;	/* Clock divider value programmed in the
+				   hardware				      */
+	uint32_t link_state;	/* Link status as reported by the Phy         */
+	uint32_t duplex_mode;	/* Duplex mode of the Phy                     */
+	uint32_t speed;		/* Speed of the Phy                           */
+	uint32_t loop_back_mode;/* Loopback status of the Phy                 */
+	uint32_t phy_mii_type;	/* RGMII/SGMII/QSGMII                         */
+	uint32_t rgmii_delay;	/* RGMII delay settings                       */
+	uint32_t pause;		/* Current flow control settings              */
+	uint32_t first_linkup_done;	/* when set, it indicates that first
+					   link up detection after interface
+					   bring up has been done             */
+	int32_t forced_speed;		/* Forced Speed */
+	int32_t forced_duplex;		/* Forced Duplex */
+
+	struct net_device *netdev;
+	struct platform_device *pdev;
+	struct delayed_work gmacwork;
+	struct napi_struct napi;
+	struct rtnl_link_stats64 stats;	/* statistics counters                */
+	spinlock_t stats_lock;		/* Lock to retrieve stats atomically  */
+	spinlock_t slock;		/* Lock to protect datapath	      */
+	struct mutex link_mutex;	/* Lock to protect link status change */
+	uint32_t gmac_power_down;	/* indicate to ISR whether the
+					   interrupts occurred in the process
+					   of powering down                   */
+
+	struct nss_gmac_global_ctx *ctx;/* Global NSS GMAC context            */
+	struct resource *memres;	/* memory resource                    */
+
+	void *data_plane_ctx;		/* context when NSS owns GMACs        */
+	struct phy_device *phydev;	/* Phy device			      */
+	struct nss_gmac_stats nss_stats;/* Stats synced from NSS	      */
+	struct mii_bus *miibus;		/* MDIO bus associated with this GMAC */
+	struct nss_gmac_data_plane_ops *data_plane_ops;
+					/* ops to send messages to nss-drv    */
+};
+
+
+/**
+ * @brief Events from the NSS GMAC
+ */
+#define NSS_GMAC_SPEED_SET		0x0001
+
+/**
+ * @brief GMAC speed context
+ */
+struct nss_gmac_speed_ctx {
+	uint32_t mac_id;
+	uint32_t speed;
+};
+
+extern struct nss_gmac_global_ctx ctx;
+
+/**
+ * @brief GMAC driver context
+ */
+struct nss_gmac_global_ctx {
+	struct workqueue_struct *gmac_workqueue;
+	char *gmac_workqueue_name;
+	uint8_t *nss_base;	/* Base address of NSS GMACs'
+				   global interface registers */
+	uint32_t *qsgmii_base;
+	uint32_t *clk_ctl_base;	/* Base address of platform
+				   clock control registers */
+	spinlock_t reg_lock;	/* Lock to protect NSS register	*/
+	uint32_t socver;	/* SOC version */
+	struct nss_gmac_dev *nss_gmac[NSS_MAX_GMACS];
+	bool common_init_done;	/* Flag to hold common init done state */
+};
+
+
+enum nss_gmac_state {
+	__NSS_GMAC_UP,		/* set to indicate the interface is UP	      */
+	__NSS_GMAC_CLOSING,	/* set to indicate the interface is closing   */
+	__NSS_GMAC_RXCSUM,	/* Rx checksum enabled			      */
+	__NSS_GMAC_AUTONEG,	/* Autonegotiation Enabled		      */
+	__NSS_GMAC_RXPAUSE,
+	__NSS_GMAC_TXPAUSE,
+	__NSS_GMAC_LINKPOLL,	/* Poll link status			      */
+};
+
+enum mii_link_status {
+	LINKDOWN = 0,
+	LINKUP = 1,
+};
+
+enum mii_duplex_mode {
+	HALFDUPLEX = 1,
+	FULLDUPLEX = 2,
+};
+
+enum mii_link_speed {
+	SPEED10 = 1,
+	SPEED100 = 2,
+	SPEED1000 = 3,
+};
+
+enum mii_loop_back {
+	NOLOOPBACK = 0,
+	LOOPBACK = 1,
+};
+
+
+/*
+ * PHY Registers
+ */
+/* MDIO Managebale Device (MMD) register offsets */
+enum ath_mmd_register {
+	ath_mmd_smart_eee_ctrl_3 = 0x805d,	/* MMD smart EEE control 3 */
+	ath_mmd_eee_adv = 0x003c,		/* MMD EEE Advertisment */
+};
+
+/* MMD Access Control function bits */
+enum ath_mmd_access_ctrl_function_bit_descriptions {
+	ath_mmd_acc_ctrl_addr = 0x0000,		/* address */
+	ath_mmd_acc_ctrl_data_no_incr = 0x4000,	/* data, no post incr */
+	ath_mmd_acc_ctrl_data_incr_rw = 0x8000,	/* data, post incr on r/w */
+	ath_mmd_acc_ctrl_data_incr_w = 0xc000,	/* data, post incr on write
+						   only			  */
+};
+
+/* MMD Smart EEE control 3 register bits */
+enum ath_mmd_smart_eee_ctrl_bit_descriptions {
+	ath_mmd_smart_eee_ctrl3_lpi_en = 0x0100,
+};
+
+/* MMD EEE Advertisment register bits */
+enum ath_mmd_eee_adv_bit_descriptions {
+	ath_mmd_eee_adv_100BT = 0x0002,
+	ath_mmd_eee_adv_1000BT = 0x0004,
+};
+
+/**********************************************************
+ * GMAC registers Map
+ * For Pci based system address is BARx + gmac_register_base
+ * For any other system translation is done accordingly
+ **********************************************************/
+enum gmac_registers {
+	gmac_config = 0x0000,		/* Mac config Register                */
+	gmac_frame_filter = 0x0004,	/* Mac frame filtering controls       */
+	gmac_hash_high = 0x0008,	/* Multi-cast hash table high         */
+	gmac_hash_low = 0x000c,		/* Multi-cast hash table low          */
+	gmac_gmii_addr = 0x0010,	/* GMII address Register(ext. Phy)    */
+	gmac_gmii_data = 0x0014,	/* GMII data Register(ext. Phy)       */
+	gmac_flow_control = 0x0018,	/* Flow control Register              */
+	gmac_vlan = 0x001c,		/* VLAN tag Register (IEEE 802.1Q)    */
+	gmac_version = 0x0020,		/* GMAC Core Version Register         */
+	gmac_wakeup_addr = 0x0028,	/* GMAC wake-up frame filter adrress
+					   reg				      */
+	gmac_pmt_ctrl_status = 0x002c,	/* PMT control and status register    */
+	gmac_interrupt_status = 0x0038,	/* Mac Interrupt ststus register      */
+	gmac_interrupt_mask = 0x003C,	/* Mac Interrupt Mask register        */
+	gmac_addr0_high = 0x0040,	/* Mac address0 high Register         */
+	gmac_addr0_low = 0x0044,	/* Mac address0 low Register          */
+	gmac_addr1_high = 0x0048,	/* Mac address1 high Register         */
+	gmac_addr1_low = 0x004C,	/* Mac address1 low Register          */
+	gmac_addr2_high = 0x0050,	/* Mac address2 high Register         */
+	gmac_addr2_low = 0x0054,	/* Mac address2 low Register          */
+	gmac_addr3_high = 0x0058,	/* Mac address3 high Register         */
+	gmac_addr3_low = 0x005C,	/* Mac address3 low Register          */
+	gmac_addr4_high = 0x0060,	/* Mac address4 high Register         */
+	gmac_addr4_low = 0x0064,	/* Mac address4 low Register          */
+	gmac_addr5_high = 0x0068,	/* Mac address5 high Register         */
+	gmac_addr5_low = 0x006C,	/* Mac address5 low Register          */
+	gmac_addr6_high = 0x0070,	/* Mac address6 high Register         */
+	gmac_addr6_low = 0x0074,	/* Mac address6 low Register          */
+	gmac_addr7_high = 0x0078,	/* Mac address7 high Register         */
+	gmac_addr7_low = 0x007C,	/* Mac address7 low Register          */
+	gmac_addr8_high = 0x0080,	/* Mac address8 high Register         */
+	gmac_addr8_low = 0x0084,	/* Mac address8 low Register          */
+	gmac_addr9_high = 0x0088,	/* Mac address9 high Register         */
+	gmac_addr9_low = 0x008C,	/* Mac address9 low Register          */
+	gmac_addr10_high = 0x0090,	/* Mac address10 high Register        */
+	gmac_addr10_low = 0x0094,	/* Mac address10 low Register         */
+	gmac_addr11_high = 0x0098,	/* Mac address11 high Register        */
+	gmac_addr11_low = 0x009C,	/* Mac address11 low Register         */
+	gmac_addr12_high = 0x00A0,	/* Mac address12 high Register        */
+	gmac_addr12_low = 0x00A4,	/* Mac address12 low Register         */
+	gmac_addr13_high = 0x00A8,	/* Mac address13 high Register        */
+	gmac_addr13_low = 0x00AC,	/* Mac address13 low Register         */
+	gmac_addr14_high = 0x00B0,	/* Mac address14 high Register        */
+	gmac_addr14_low = 0x00B4,	/* Mac address14 low Register         */
+	gmac_addr15_high = 0x00B8,	/* Mac address15 high Register        */
+	gmac_addr15_low = 0x00BC,	/* Mac address15 low Register         */
+	gmac_mii_status = 0x00D8,	/* SGMII/RGMII/SMII Status Register   */
+
+	/* Time Stamp Register Map */
+	gmac_ts_control = 0x0700,	/* Controls the Timestamp update logic:
+					   only when IEEE 1588 time stamping is
+					   enabled in corekit                 */
+
+	gmac_ts_sub_sec_incr = 0x0704,	/* 8 bit value by which sub second
+					   register is incremented : only when
+					   IEEE 1588 time stamping without
+					   external timestamp input           */
+
+	gmac_ts_high = 0x0708,		/* 32 bit seconds(MS): only when
+					   IEEE 1588 time stamping without
+					   external timestamp input           */
+
+	gmac_ts_low = 0x070C,		/* 32 bit nano seconds(MS): only when
+					   IEEE 1588 time stamping without
+					   external timestamp input           */
+
+	gmac_ts_high_update = 0x0710,	/* 32bit seconds(MS) to be written/added
+					   /subtracted: only when IEEE 1588 time
+					   stamping without external timestamp*/
+
+	gmac_ts_low_update = 0x0714,	/* 32 bit nano seconds(MS) to be
+					   writeen/added/subtracted: only when
+					   IEEE 1588 time stamping without
+					   external timestamp input           */
+
+	gmac_ts_addend = 0x0718,	/* Used by Software to readjust the
+					   clock frequency linearly: only when
+					   IEEE 1588 time stamping without
+					   external timestamp input           */
+
+	gmac_ts_target_time_high = 0x071C,/* 32 bit seconds(MS) to be compared
+					   with system time: only when IEEE 1588
+					   time stamping without external
+					   timestamp input                    */
+
+	gmac_ts_target_time_low = 0x0720,	/* 32 bit nano seconds(MS) to be
+					   compared with system time: only when
+					   IEEE 1588 time stamping without
+					   external timestamp input	      */
+
+	gmac_ts_high_word = 0x0724,	/* Time Stamp Higher Word Register(Ver.
+					   2 only); only lower 16 bits are
+					   valid			      */
+
+	/*gmac_ts_high_word_update    = 0x072C, */
+					/* Time Stamp Higher Word Update
+					   Register(Version 2 only); only lower
+					   16 bits are valid                  */
+
+	gmac_ts_status = 0x0728,	/* Time Stamp Status Register         */
+};
+
+/**********************************************************
+ * GMAC Network interface registers
+ * This explains the Register's Layout
+
+ * FES is Read only by default and is enabled only when Tx
+ * Config Parameter is enabled for RGMII/SGMII interface
+ * during core_kit Config.
+
+ * DM is Read only with value 1'b1 in Full duplex only Config
+ **********************************************************/
+
+/* gmac_config              = 0x0000,    Mac config Register  Layout */
+enum gmac_config_reg {
+	gmac_twokpe = 0x08000000,
+	gmac_twokpe_enable = 0x08000000,
+	gmac_twokpe_disable = 0x00000000,
+	gmac_tc_enable = 0x01000000,
+	gmac_watchdog = 0x00800000,
+	gmac_watchdog_disable = 0x00800000,	/* (WD)Disable watchdog timer
+						   on Rx		      */
+	gmac_watchdog_enable = 0x00000000,	/* Enable watchdog timer      */
+	gmac_jabber = 0x00400000,
+	gmac_jabber_disable = 0x00400000,	/* (JD)Disable jabber timer
+						   on Tx		      */
+	gmac_jabber_enable = 0x00000000,	/* Enable jabber timer        */
+	gmac_frame_burst = 0x00200000,
+	gmac_frame_burst_enable = 0x00200000,	/* (BE)Enable frame bursting
+						    during Tx		      */
+	gmac_frame_burst_disable = 0x00000000,	/* Disable frame bursting     */
+	gmac_jumbo_frame = 0x00100000,
+	gmac_jumbo_frame_enable = 0x00100000,	/* (JE)Enable jumbo frame for
+						   Tx			      */
+	gmac_jumbo_frame_disable = 0x00000000,	/* Disable jumbo frame        */
+	gmac_inter_frame_gap7 = 0x000E0000,	/* (IFG) Config7 - 40bit times*/
+	gmac_inter_frame_gap6 = 0x000C0000,	/* (IFG) Config6 - 48bit times*/
+	gmac_inter_frame_gap5 = 0x000A0000,	/* (IFG) Config5 - 56bit times*/
+	gmac_inter_frame_gap4 = 0x00080000,	/* (IFG) Config4 - 64bit times*/
+	gmac_inter_frame_gap3 = 0x00040000,	/* (IFG) Config3 - 72bit times*/
+	gmac_inter_frame_gap2 = 0x00020000,	/* (IFG) Config2 - 80bit times*/
+	gmac_inter_frame_gap1 = 0x00010000,	/* (IFG) Config1 - 88bit times*/
+	gmac_inter_frame_gap0 = 0x00000000,	/* (IFG) Config0 - 96bit times*/
+	gmac_disable_crs = 0x00010000,
+	gmac_mii_gmii = 0x00008000,
+	gmac_select_mii = 0x00008000,		/* (PS)Port Select-MII mode   */
+	gmac_select_gmii = 0x00000000,		/* GMII mode                  */
+	gmac_fe_speed100 = 0x00004000,		/*(FES)Fast Ethernet speed
+						   100Mbps		      */
+	gmac_fe_speed10 = 0x00000000,		/* 10Mbps                     */
+	gmac_rx_own = 0x00002000,
+	gmac_disable_rx_own = 0x00002000,	/* (DO)Disable receive own
+						   packets		      */
+	gmac_enable_rx_own = 0x00000000,	/* Enable receive own packets */
+	gmac_loopback = 0x00001000,
+	gmac_loopback_on = 0x00001000,		/* (LM)Loopback mode for
+						   GMII/MII		      */
+	gmac_loopback_off = 0x00000000,		/* Normal mode                */
+	gmac_duplex = 0x00000800,
+	gmac_full_duplex = 0x00000800,		/* (DM)Full duplex mode       */
+	gmac_half_duplex = 0x00000000,		/* Half duplex mode           */
+	gmac_rx_ipc_offload = 0x00000400,	/* IPC checksum offload       */
+	gmac_retry = 0x00000200,
+	gmac_retry_disable = 0x00000200,	/* (DR)Disable Retry          */
+	gmac_retry_enable = 0x00000000,		/* Enable retransmission as per
+						   BL			      */
+	gmac_link_up = 0x00000100,		/* (LUD)Link UP               */
+	gmac_link_down = 0x00000100,		/* Link Down                  */
+	gmac_pad_crc_strip = 0x00000080,
+	gmac_pad_crc_strip_enable = 0x00000080,	/* (ACS) Automatic Pad/Crc
+						   strip enable		      */
+	gmac_pad_crc_strip_disable = 0x00000000,/* Automatic Pad/Crc stripping
+						   disable		      */
+	gmac_backoff_limit = 0x00000060,
+	gmac_backoff_limit3 = 0x00000060,	/* (BL)Back-off limit in HD
+						   mode			      */
+	gmac_backoff_limit2 = 0x00000040,
+	gmac_backoff_limit1 = 0x00000020,
+	gmac_backoff_limit0 = 0x00000000,
+	gmac_deferral_check = 0x00000010,
+	gmac_deferral_check_enable = 0x00000010,/* (DC)Deferral check enable in
+						   HD mode		      */
+	gmac_deferral_check_disable = 0x00000000,/* Deferral check disable    */
+	gmac_tx = 0x00000008,
+	gmac_tx_enable = 0x00000008,		/* (TE)Transmitter enable     */
+	gmac_tx_disable = 0x00000000,		/* Transmitter disable        */
+	gmac_rx = 0x00000004,
+	gmac_rx_enable = 0x00000004,		/* (RE)Receiver enable        */
+	gmac_rx_disable = 0x00000000,		/* Receiver disable           */
+};
+
+/* gmac_frame_filter = 0x0004,	Mac frame filtering controls Register Layout */
+enum gmac_frame_filter_reg {
+	gmac_filter = 0x80000000,
+	gmac_filter_off = 0x80000000,		/* (RA)Receive all incoming
+						   packets		      */
+	gmac_filter_on = 0x00000000,		/* Receive filtered pkts only */
+	gmac_hash_perfect_filter = 0x00000400,	/* Hash or Perfect Filter
+						   enable		      */
+	gmac_src_addr_filter = 0x00000200,
+	gmac_src_addr_filter_enable = 0x00000200,	/* (SAF)Source Address
+							   Filter enable      */
+	gmac_src_addr_filter_disable = 0x00000000,
+	gmac_src_inva_addr_filter = 0x00000100,
+	gmac_src_inv_addr_filter_en = 0x00000100,	/* (SAIF)Inv Src Addr
+							   Filter enable      */
+	gmac_src_inv_addr_filter_dis = 0x00000000,
+	gmac_pass_control = 0x000000C0,
+	gmac_pass_control3 = 0x000000C0,	/* (PCS)Forwards ctrl frms that
+						   pass AF		      */
+	gmac_pass_control2 = 0x00000080,	/* Forwards all control frames*/
+	gmac_pass_control1 = 0x00000040,	/* Don't pass control frames  */
+	gmac_pass_control0 = 0x00000000,	/* Don't pass control frames  */
+	gmac_broadcast = 0x00000020,
+	gmac_broadcast_disable = 0x00000020,	/* (DBF)Disable Rx of broadcast
+						   frames		      */
+	gmac_broadcast_enable = 0x00000000,	/* Enable broadcast frames    */
+	gmac_multicast_filter = 0x00000010,
+	gmac_multicast_filter_off = 0x00000010,	/* (PM) Pass all multicast
+						   packets		      */
+	gmac_multicast_filter_on = 0x00000000,	/* Pass filtered multicast
+						   packets		      */
+	gmac_dest_addr_filter = 0x00000008,
+	gmac_dest_addr_filter_inv = 0x00000008,	/* (DAIF)Inverse filtering for
+						   DA			      */
+	gmac_dest_addr_filter_nor = 0x00000000,	/* Normal filtering for DA    */
+	gmac_mcast_hash_filter = 0x00000004,
+	gmac_mcast_hash_filter_on = 0x00000004,	/* (HMC)perfom multicast hash
+						   filtering		      */
+	gmac_mcast_hash_filter_off = 0x00000000,/* perfect filtering only     */
+	gmac_ucast_hash_filter = 0x00000002,
+	gmac_ucast_hash_filter_on = 0x00000002,	/* (HUC)Unicast Hash filtering
+						   only			      */
+	gmac_ucast_hash_filter_off = 0x00000000,/* perfect filtering only     */
+	gmac_promiscuous_mode = 0x00000001,
+	gmac_promiscuous_mode_on = 0x00000001,	/* Receive all frames         */
+	gmac_promiscuous_mode_off = 0x00000000,	/* Receive filtered packets
+						   only			      */
+};
+
+/* gmac_gmii_addr = 0x0010,	GMII address Register(ext. Phy) Layout	*/
+enum gmac_gmii_addr_reg {
+	gmii_dev_mask = 0x0000F800,	/* (PA)GMII device address            */
+	gmii_dev_shift = 11,
+	gmii_reg_mask = 0x000007C0,	/* (GR)GMII register in selected Phy  */
+	gmii_reg_shift = 6,
+	gmii_csr_clk_shift = 2,		/* CSR Clock bit Shift                */
+	gmii_csr_clk_mask = 0x0000003C,	/* CSR Clock bit Mask                 */
+	gmii_csr_clk5 = 0x00000014,	/* (CR)CSR Clock Range  250-300 MHz   */
+	gmii_csr_clk4 = 0x00000010,	/*                      150-250 MHz   */
+	gmii_csr_clk3 = 0x0000000C,	/*                      35-60 MHz     */
+	gmii_csr_clk2 = 0x00000008,	/*                      20-35 MHz     */
+	gmii_csr_clk1 = 0x00000004,	/*                      100-150 MHz   */
+	gmii_csr_clk0 = 0x00000000,	/*                      60-100 MHz    */
+	gmii_write = 0x00000002,		/* (GW)Write to register      */
+	gmii_read = 0x00000000,		/* Read from register                 */
+	gmii_busy = 0x00000001,		/* (GB)GMII interface is busy         */
+};
+
+/* gmac_gmii_data = 0x0014,	GMII data Register(ext. Phy) Layout	*/
+enum gmac_gmii_data_reg {
+	gmii_data_mask = 0x0000FFFF,		/* (GD)GMII Data              */
+};
+
+/* gmac_flow_control = 0x0018,	Flow control Register Layout		*/
+enum gmac_flow_control_reg {
+	gmac_pause_time_mask = 0xFFFF0000,	/* (PT) PAUSE TIME field
+						   in the control frame       */
+	gmac_pause_time_shift = 16,
+	gmac_pause_low_thresh = 0x00000030,
+	gmac_pause_low_thresh3 = 0x00000030,	/* (PLT)thresh for pause
+						   tmr 256 slot time          */
+	gmac_pause_low_thresh2 = 0x00000020,	/*      144 slot time         */
+	gmac_pause_low_thresh1 = 0x00000010,	/*      28 slot time          */
+	gmac_pause_low_thresh0 = 0x00000000,	/*      4 slot time           */
+	gmac_unicast_pause_frame = 0x00000008,
+	gmac_unicast_pause_frame_on = 0x00000008,/* (UP)Detect pause frame
+						   with unicast addr.         */
+	gmac_unicast_pause_frame_off = 0x00000000,/* Detect only pause frame
+						   with multicast addr.       */
+	gmac_rx_flow_control = 0x00000004,
+	gmac_rx_flow_control_enable = 0x00000004,	/* (RFE)Enable Rx flow
+							   control	      */
+	gmac_rx_flow_control_disable = 0x00000000,	/* Disable Rx flow
+							   control	      */
+	gmac_tx_flow_control = 0x00000002,
+	gmac_tx_flow_control_enable = 0x00000002,	/* (TFE)Enable Tx flow
+							   control	      */
+	gmac_tx_flow_control_disable = 0x00000000,	/* Disable flow
+							   control	      */
+	gmac_flow_control_back_pressure = 0x00000001,
+	gmac_send_pause_frame = 0x00000001,	/* (FCB/PBA)send pause
+						   frm/Apply back pressure    */
+};
+
+/* gmac_interrupt_statusi = 0x0038,	Mac Interrupt ststus register*/
+enum gmac_interrupt_status_bit_definition {
+	gmac_ts_int_sts = 0x00000200,	/* set if int generated due to TS (Read
+					   Time Stamp Status Register to know
+					    details)			      */
+	gmac_mmc_rx_chksum_offload = 0x00000080,/* set if int generated in MMC
+						   RX CHECKSUM OFFLOAD int
+						   register		      */
+	gmac_mmc_tx_int_sts = 0x00000040,	/* set if int generated in MMC
+						   TX Int register	      */
+	gmac_mmc_rx_int_sts = 0x00000020,	/* set if int generated in MMC
+						   RX Int register	      */
+	gmac_mmc_int_sts = 0x00000010,	/* set if any of the above bit [7:5] is
+					   set				      */
+	gmac_pmt_int_sts = 0x00000008,	/* set whenever magic pkt/wake-on-lan
+					   frame is received                  */
+	gmac_pcs_an_complete = 0x00000004,	/* set when AN is complete in
+						   TBI/RTBI/SGMIII phy interface
+						*/
+	gmac_pcs_lnk_sts_change = 0x00000002,	/* set if any lnk status change
+						   in TBI/RTBI/SGMII interface*/
+	gmac_rgmii_int_sts = 0x00000001,	/* set if any change in lnk
+						   status of RGMII interface  */
+};
+
+/* gmac_interrupt_mask	= 0x003C,	Mac Interrupt Mask register	*/
+enum gmac_interrupt_mask_bit_definition {
+	gmac_tSInt_mask = 0x00000200,		/* when set disables the time
+						   stamp interrupt generation */
+	gmac_pmt_int_mask = 0x00000008,		/* when set Disables the
+						   assertion of PMT interrupt */
+	gmac_pcs_an_int_mask = 0x00000004,	/* When set disables the
+						   assertion of PCS AN complete
+						    interrupt		      */
+	gmac_pcs_lnk_sts_int_mask = 0x00000002,	/* when set disables the
+						   assertion of PCS lnk status
+						   change interrupt	      */
+	gmac_rgmii_int_mask = 0x00000001,	/* when set disables the
+						   assertion of RGMII
+						   interrupt		      */
+};
+
+/**********************************************************
+ * GMAC DMA registers
+ * For Pci based system address is BARx + gma_dma_base
+ * For any other system translation is done accordingly
+ **********************************************************/
+
+enum dma_registers {
+	dma_bus_mode = 0x0000,		/* CSR0 - Bus Mode Register	      */
+	dma_tx_poll_demand = 0x0004,	/* CSR1 - TX Poll Demand Register*/
+	dma_rx_poll_demand = 0x0008,	/* CSR2 - RX Poll Demand Register */
+	dma_rx_base_addr = 0x000C,	/* CSR3 - RX Descriptor list base addr*/
+	dma_tx_base_addr = 0x0010,	/* CSR4 - TX Descriptor list base addr*/
+	dma_status = 0x0014,		/* CSR5 - Dma status Register         */
+	dma_control = 0x0018,		/* CSR6 - Dma Operation Mode Register */
+	dma_interrupt = 0x001C,		/* CSR7 - Interrupt enable            */
+	dma_missed_fr = 0x0020,		/* CSR8 - Missed Frame & Buffer
+					   overflow Counter		      */
+	dma_axi_bus_mode = 0x0028,	/* AXI Bus Mode Settings	      */
+	dma_tx_curr_desc = 0x0048,	/* Current host Tx Desc Register      */
+	dma_rx_curr_desc = 0x004C,	/* Current host Rx Desc Register      */
+	dma_tx_curr_addr = 0x0050,	/* CSR20 - Current host TX buffer addr*/
+	dma_rx_curr_addr = 0x0054,	/* CSR21 - Current host RX buffer addr*/
+};
+
+/**********************************************************
+ * DMA Engine registers Layout
+ **********************************************************/
+
+/* dma_bus_mode	= 0x0000,	CSR0 - Bus Mode				*/
+enum dma_bus_mode_reg {
+	dma_fixed_burst_enable = 0x00010000,	/* (FB)Fixed Burst SINGLE, INCR4
+						   , INCR8 or INCR16          */
+	dma_fixed_burst_disable = 0x00000000,	/* SINGLE, INCR               */
+	dma_tx_priority_ratio11 = 0x00000000,	/* (PR)TX:RX DMA priority ratio
+						   1:1			      */
+	dma_tx_priority_ratio21 = 0x00004000,	/* (PR)TX:RX DMA priority ratio
+						   2:1			      */
+	dma_tx_priority_ratio31 = 0x00008000,	/* (PR)TX:RX DMA priority ratio
+						   3:1			      */
+	dma_tx_priority_ratio41 = 0x0000C000,	/* (PR)TX:RX DMA priority ratio
+						   4:1			      */
+	dma_address_aligned_beats = 0x02000000,	/* Address Aligned beats      */
+	dma_burst_lengthx8 = 0x01000000,	/* When set mutiplies the PBL by
+						   8			      */
+	dma_burst_length256 = 0x01002000,	/*(dma_burst_lengthx8
+						   | dma_burst_length32) = 256*/
+	dma_burst_length128 = 0x01001000,	/*(dma_burst_lengthx8
+						   | dma_burst_length16) = 128*/
+	dma_burst_length64 = 0x01000800,	/*(dma_burst_lengthx8
+						   | dma_burst_length8) = 64  */
+	dma_burst_length32 = 0x00002000,	/* (PBL) programmable
+						   Dma burst length = 32      */
+	dma_burst_length16 = 0x00001000,	/* Dma burst length = 16      */
+	dma_burst_length8 = 0x00000800,		/* Dma burst length = 8       */
+	dma_burst_length4 = 0x00000400,		/* Dma burst length = 4       */
+	dma_burst_length2 = 0x00000200,		/* Dma burst length = 2       */
+	dma_burst_length1 = 0x00000100,		/* Dma burst length = 1       */
+	dma_burst_length0 = 0x00000000,		/* Dma burst length = 0       */
+	dma_descriptor8_words = 0x00000080,	/* Enh Descriptor works  1=>
+						   8 word descriptor          */
+	dma_descriptor4_words = 0x00000000,	/* Enh Descriptor works  0=>
+						   4 word descriptor          */
+	dma_descriptor_skip16 = 0x00000040,	/* (DSL)Descriptor skip
+						   length (no.of dwords)      */
+	dma_descriptor_skip8 = 0x00000020,	/* between two unchained
+						   descriptors		      */
+	dma_descriptor_skip4 = 0x00000010,
+	dma_descriptor_skip2 = 0x00000008,
+	dma_descriptor_skip1 = 0x00000004,
+	dma_descriptor_skip0 = 0x00000000,
+	dma_arbit_rr = 0x00000000,		/* (DA) DMA RR arbitration    */
+	dma_arbit_pr = 0x00000002,		/* Rx has priority over Tx    */
+	dma_reset_on = 0x00000001,		/* (SWR)Software Reset DMA
+						   engine		      */
+	dma_reset_off = 0x00000000,
+};
+
+/* dma_status	= 0x0014,	CSR5 - Dma status Register		*/
+enum dma_status_reg {
+	gmac_pmt_intr = 0x10000000,	/* (GPI)Gmac subsystem interrupt      */
+	gmac_mmc_intr = 0x08000000,	/* (GMI)Gmac MMC subsystem interrupt  */
+	gmac_line_intf_intr = 0x04000000,	/* Line interface interrupt   */
+	dma_error_bit2 = 0x02000000,	/* (EB)Error bits 0-data buffer,
+					   1-desc. access                     */
+	dma_error_bit1 = 0x01000000,	/* (EB)Error bits 0-write trnsf,
+					   1-read transfr                     */
+	dma_error_bit0 = 0x00800000,	/* (EB)Error bits 0-Rx DMA, 1-Tx DMA  */
+	dma_tx_state = 0x00700000,	/* (TS)Transmit process state         */
+	dma_tx_stopped = 0x00000000,	/* Stopped - Reset or Stop Tx
+					   Command issued                     */
+	dma_tx_fetching = 0x00100000,	/* Running - fetching the Tx
+					   descriptor			      */
+	dma_tx_waiting = 0x00200000,	/* Running - waiting for status       */
+	dma_tx_reading = 0x00300000,	/* Running - reading the data
+					   from host memory                   */
+	dma_tx_suspended = 0x00600000,	/* Suspended - Tx Descriptor
+					   unavailabe			      */
+	dma_tx_closing = 0x00700000,	/* Running - closing Rx descriptor    */
+	dma_rx_state = 0x000E0000,	/* (RS)Receive process state          */
+	dma_rx_stopped = 0x00000000,	/* Stopped - Reset or Stop
+					   Rx Command issued                  */
+	dma_rx_fetching = 0x00020000,	/* Running - fetching the Rx
+					   descriptor			      */
+	dma_rx_waiting = 0x00060000,	/* Running - waiting for packet       */
+	dma_rx_suspended = 0x00080000,	/* Suspended - Rx Descriptor
+					   unavailable			      */
+	dma_rx_closing = 0x000A0000,	/* Running - closing descriptor       */
+	dma_rx_queuing = 0x000E0000,	/* Running - queuing the receive
+					   frame into host memory             */
+	dma_int_normal = 0x00010000,	/* (NIS)Normal interrupt summary      */
+	dma_int_abnormal = 0x00008000,	/* (AIS)Abnormal interrupt summary    */
+
+	dma_int_early_rx = 0x00004000,	/* Early receive interrupt (Normal)   */
+	dma_int_bus_error = 0x00002000,	/* Fatal bus error (Abnormal)         */
+	dma_int_early_tx = 0x00000400,	/* Early transmit interrupt (Abnormal)*/
+	dma_int_rx_wdog_to = 0x00000200,/* Receive Watchdog Timeout (Abnormal)*/
+	dma_int_rx_stopped = 0x00000100,/* Receive process stopped (Abnormal) */
+	dma_int_rx_no_buffer = 0x00000080,/* RX buffer unavailable (Abnormal) */
+	dma_int_rx_completed = 0x00000040,/* Completion of frame RX (Normal)  */
+	dma_int_tx_underflow = 0x00000020,/* Transmit underflow (Abnormal)    */
+	dma_int_rcv_overflow = 0x00000010,/* RX Buffer overflow interrupt     */
+	dma_int_tx_jabber_to = 0x00000008,/* TX Jabber Timeout (Abnormal)     */
+	dma_int_tx_no_buffer = 0x00000004,/* TX buffer unavailable (Normal)   */
+	dma_int_tx_stopped = 0x00000002,/* TX process stopped (Abnormal)      */
+	dma_int_tx_completed = 0x00000001,/* Transmit completed (Normal)      */
+};
+
+/* dma_control	= 0x0018,	CSR6 - Dma Operation Mode Register	*/
+enum dma_control_reg {
+	dma_disable_drop_tcp_cs = 0x04000000,	/* (DT) Dis. drop. of tcp/ip
+						   CS error frames            */
+	dma_rx_store_and_forward = 0x02000000,	/* Rx (SF)Store and forward   */
+	dma_rx_frame_flush = 0x01000000,	/* Disable Receive Frame Flush*/
+	dma_store_and_forward = 0x00200000,	/* (SF)Store and forward      */
+	dma_flush_tx_fifo = 0x00100000,		/* (FTF)Tx FIFO controller
+						   is reset to default        */
+	dma_tx_thresh_ctrl = 0x0001C000,	/* (TTC)Controls thre Threh of
+						   MTL tx Fifo                */
+	dma_tx_thresh_ctrl16 = 0x0001C000,	/* (TTC)Controls thre Threh of
+						   MTL tx Fifo 16             */
+	dma_tx_thresh_ctrl24 = 0x00018000,	/* (TTC)Controls thre Threh of
+						   MTL tx Fifo 24             */
+	dma_tx_thresh_ctrl32 = 0x00014000,	/* (TTC)Controls thre Threh of
+						   MTL tx Fifo 32             */
+	dma_tx_thresh_ctrl40 = 0x00010000,	/* (TTC)Controls thre Threh of
+						   MTL tx Fifo 40             */
+	dma_tx_thresh_ctrl256 = 0x0000c000,	/* (TTC)Controls thre Threh of
+						   MTL tx Fifo 256            */
+	dma_tx_thresh_ctrl192 = 0x00008000,	/* (TTC)Controls thre Threh of
+						   MTL tx Fifo 192            */
+	dma_tx_thresh_ctrl128 = 0x00004000,	/* (TTC)Controls thre Threh of
+						   MTL tx Fifo 128            */
+	dma_tx_thresh_ctrl64 = 0x00000000,	/* (TTC)Controls thre Threh of
+						   MTL tx Fifo 64             */
+	dma_tx_start = 0x00002000,		/* (ST)Start/Stop transmission*/
+	dma_rx_flow_ctrl_deact = 0x00401800,	/* (RFD)Rx flow control
+						   deact. threhold            */
+	dma_rx_flow_ctrl_deact1K = 0x00000000,	/* (RFD)Rx flow control
+						   deact. threhold (1kbytes)  */
+	dma_rx_flow_ctrl_deact2K = 0x00000800,	/* (RFD)Rx flow control
+						   deact. threhold (2kbytes)  */
+	dma_rx_flow_ctrl_deact3K = 0x00001000,	/* (RFD)Rx flow control
+						   deact. threhold (3kbytes)  */
+	dma_rx_flow_ctrl_deact4K = 0x00001800,	/* (RFD)Rx flow control
+						   deact. threhold (4kbytes)  */
+	dma_rx_flow_ctrl_deact5K = 0x00400000,	/* (RFD)Rx flow control
+						   deact. threhold (4kbytes)  */
+	dma_rx_flow_ctrl_deact6K = 0x00400800,	/* (RFD)Rx flow control
+						   deact. threhold (4kbytes)  */
+	dma_rx_flow_ctrl_deact7K = 0x00401000,	/* (RFD)Rx flow control
+						   deact. threhold (4kbytes)  */
+	dma_rx_flow_ctrl_act = 0x00800600,	/* (RFA)Rx flow control
+						   Act. threhold              */
+	dma_rx_flow_ctrl_act1K = 0x00000000,	/* (RFA)Rx flow control
+						   Act. threhold (1kbytes)    */
+	dma_rx_flow_ctrl_act2K = 0x00000200,	/* (RFA)Rx flow control
+						   Act. threhold (2kbytes)    */
+	dma_rx_flow_ctrl_act3K = 0x00000400,	/* (RFA)Rx flow control
+						   Act. threhold (3kbytes)    */
+	dma_rx_flow_ctrl_act4K = 0x00000600,	/* (RFA)Rx flow control
+						   Act. threhold (4kbytes)    */
+	dma_rx_flow_ctrl_act5K = 0x00800000,	/* (RFA)Rx flow control
+						   Act. threhold (5kbytes)    */
+	dma_rx_flow_ctrl_act6K = 0x00800200,	/* (RFA)Rx flow control
+						   Act. threhold (6kbytes)    */
+	dma_rx_flow_ctrl_act7K = 0x00800400,	/* (RFA)Rx flow control
+						   Act. threhold (7kbytes)    */
+	dma_rx_thresh_ctrl = 0x00000018,	/* (RTC)Controls thre
+						   Threh of MTL rx Fifo       */
+	dma_rx_thresh_ctrl64 = 0x00000000,	/* (RTC)Controls thre
+						   Threh of MTL tx Fifo 64    */
+	dma_rx_thresh_ctrl32 = 0x00000008,	/* (RTC)Controls thre
+						   Threh of MTL tx Fifo 32    */
+	dma_rx_thresh_ctrl96 = 0x00000010,	/* (RTC)Controls thre
+						   Threh of MTL tx Fifo 96    */
+	dma_rx_thresh_ctrl128 = 0x00000018,	/* (RTC)Controls thre
+						   Threh of MTL tx Fifo 128   */
+	dma_en_hw_flow_ctrl = 0x00000100,	/* (EFC)Enable HW flow control*/
+	dma_dis_hw_flow_ctrl = 0x00000000,	/* Disable HW flow control    */
+	dma_fwd_error_frames = 0x00000080,	/* (FEF)Forward error frames  */
+	dma_fwd_under_sz_frames = 0x00000040,	/* (FUF)Forward undersize
+						   frames		      */
+	dma_tx_second_frame = 0x00000004,	/* (OSF)Operate on 2nd frame  */
+	dma_rx_start = 0x00000002,		/* (SR)Start/Stop reception   */
+};
+
+/* dma_interrupt = 0x001C,	CSR7 - Interrupt enable Register Layout	*/
+enum dma_interrupt_reg {
+	dma_ie_normal = dma_int_normal,		/* Normal interrupt enable    */
+	dma_ie_abnormal = dma_int_abnormal,	/* Abnormal interrupt enable  */
+	dma_ie_early_rx = dma_int_early_rx,	/* Early RX interrupt enable  */
+	dma_ie_bus_error = dma_int_bus_error,	/* Fatal bus error enable     */
+	dma_ie_early_tx = dma_int_early_tx,	/* Early TX interrupt enable  */
+	dma_ie_rx_wdog_to = dma_int_rx_wdog_to,	/* RX Watchdog Timeout enable */
+	dma_ie_rx_stopped = dma_int_rx_stopped,	/* RX process stopped enable  */
+	dma_ie_rx_no_buffer = dma_int_rx_no_buffer,	/* Receive buffer
+							   unavailable enable */
+	dma_ie_rx_completed = dma_int_rx_completed,	/* Completion of frame
+							   reception enable   */
+	dma_ie_tx_underflow = dma_int_tx_underflow,	/* TX underflow enable*/
+	dma_ie_rx_overflow = dma_int_rcv_overflow,	/* RX Buffer overflow
+							   interrupt	      */
+	dma_ie_tx_jabber_to = dma_int_tx_jabber_to,	/* TX Jabber Timeout
+							   enable	      */
+	dma_ie_tx_no_buffer = dma_int_tx_no_buffer,	/* TX buffer unavailable
+							   enable	      */
+	dma_ie_tx_stopped = dma_int_tx_stopped,		/* TX process stopped
+							   enable	      */
+	dma_ie_tx_completed = dma_int_tx_completed,	/* TX completed enable*/
+};
+
+/* dma_axi_bus_mod	= 0x,0028 */
+enum dma_axi_bus_mode_reg {
+	dma_en_lpi = 0x80000000,
+	dma_lpi_xit_frm = 0x40000000,
+	dma_wr_osr_num_reqs16 = 0x00F00000,
+	dma_wr_osr_num_reqs8 = 0x00700000,
+	dma_wr_osr_num_reqs4 = 0x00300000,
+	dma_wr_osr_num_reqs2 = 0x00100000,
+	dma_wr_osr_num_reqs1 = 0x00000000,
+	dma_rd_osr_num_reqs16 = 0x000F0000,
+	dma_rd_osr_num_reqs8 = 0x00070000,
+	dma_rd_osr_num_reqs4 = 0x00030000,
+	dma_rd_osr_num_reqs2 = 0x00010000,
+	dma_rd_osr_num_reqs1 = 0x00000000,
+	dma_onekbbe = 0x00002000,
+	dma_axi_aal = 0x00001000,
+	dma_axi_blen256 = 0x00000080,
+	dma_axi_blen128 = 0x00000040,
+	dma_axi_blen64 = 0x00000020,
+	dma_axi_blen32 = 0x00000010,
+	dma_axi_blen16 = 0x00000008,
+	dma_axi_blen8 = 0x00000004,
+	dma_axi_blen4 = 0x00000002,
+	dma_undefined = 0x00000001,
+};
+
+/**********************************************************
+ * DMA Engine descriptors
+ **********************************************************/
+/*
+******Enhanced Descritpor structure to support 8K buffer per buffer *******
+
+dma_rx_base_addr = 0x000C,	CSR3 - Receive Descriptor list base address
+dma_rx_base_addr is the pointer to the first Rx Descriptors.
+The Descriptor format in Little endian with a 32 bit Data bus is as shown below.
+
+Similarly
+dma_tx_base_addr     = 0x0010,  CSR4 - Transmit Descriptor list base address
+dma_tx_base_addr is the pointer to the first Rx Descriptors.
+The Descriptor format in Little endian with a 32 bit Data bus is as shown below.
+	------------------------------------------------------------------------
+ RDES0	|OWN (31)| Status						       |
+	------------------------------------------------------------------------
+ RDES1	| Ctrl | Res | Byte Count Buffer 2 | Ctrl | Res | Byte Count Buffer 1  |
+	------------------------------------------------------------------------
+ RDES2	|  Buffer 1 Address                                                    |
+	------------------------------------------------------------------------
+ RDES3	|  Buffer 2 Address / Next Descriptor Address                          |
+	------------------------------------------------------------------------
+
+	------------------------------------------------------------------------
+ TDES0	|OWN (31)| Ctrl | Res | Ctrl | Res | Status                            |
+	------------------------------------------------------------------------
+ TDES1	| Res | Byte Count Buffer 2 | Res |         Byte Count Buffer 1        |
+	------------------------------------------------------------------------
+ TDES2	|  Buffer 1 Address                                                    |
+	------------------------------------------------------------------------
+ TDES3	|  Buffer 2 Address / Next Descriptor Address                          |
+	------------------------------------------------------------------------
+
+*/
+
+/* status word of DMA descriptor */
+enum dma_descriptor_status {
+	desc_own_by_dma = 0x80000000,		/* (OWN)Descriptor is
+						   owned by DMA engine        */
+	desc_da_filter_fail = 0x40000000,	/* (AFM)Rx - DA Filter
+						   Fail for the rx frame      */
+	desc_frame_length_mask = 0x3FFF0000,	/* (FL)Receive descriptor
+						   frame length               */
+	desc_frame_length_shift = 16,
+	desc_error = 0x00008000,		/* (ES)Error summary bit
+						   - OR of the  following bits:
+						   DE || OE || IPC || LC  || RWT
+						   || RE || CE                */
+	desc_rx_truncated = 0x00004000,		/* (DE)Rx - no more descriptors
+						   for receive frame          */
+	desc_sa_filter_fail = 0x00002000,	/* (SAF)Rx - SA Filter Fail for
+						   the received frame         */
+	desc_rx_length_error = 0x00001000,	/* (LE)Rx - frm size not
+						   matching with len field    */
+	desc_rx_damaged = 0x00000800,		/* (OE)Rx - frm was damaged due
+						   to buffer overflow         */
+	desc_rx_vlan_tag = 0x00000400,		/* (VLAN)Rx - received frame
+						   is a VLAN frame            */
+	desc_rx_first = 0x00000200,		/* (FS)Rx - first
+						   descriptor of the frame    */
+	desc_rx_last = 0x00000100,		/* (LS)Rx - last
+						   descriptor of the frame    */
+	desc_rx_long_frame = 0x00000080,	/* (Giant Frame)Rx - frame is
+						   longer than 1518/1522      */
+	desc_rx_collision = 0x00000040,		/* (LC)Rx - late collision
+						   occurred during reception  */
+	desc_rx_frame_ether = 0x00000020,	/* (FT)Rx - Frame type - Ether,
+						   otherwise 802.3            */
+	desc_rx_watchdog = 0x00000010,		/* (RWT)Rx - watchdog timer
+						   expired during reception   */
+	desc_rx_mii_error = 0x00000008,		/* (RE)Rx - error reported
+						   by MII interface           */
+	desc_rx_dribbling = 0x00000004,		/* (DE)Rx - frame contains non
+						   int multiple of 8 bits     */
+	desc_rx_crc = 0x00000002,		/* (CE)Rx - CRC error         */
+	/*desc_rx_mac_match = 0x00000001,*/	/* (RX MAC Addr) Rx mac addr
+						   reg(1 to 15)match   0     */
+	desc_rx_ext_sts = 0x00000001,		/* Extended Status Available
+						   in RDES4		      */
+	desc_tx_int_enable = 0x40000000,	/* (IC)Tx - interrupt on
+						   completion		      */
+	desc_tx_last = 0x20000000,		/* (LS)Tx - Last segment of the
+						   frame		      */
+	desc_tx_first = 0x10000000,		/* (FS)Tx - First segment of the
+						    frame		      */
+	desc_tx_disable_crc = 0x08000000,	/* (DC)Tx - Add CRC disabled
+						   (first segment only)       */
+	desc_tx_disable_padd = 0x04000000,	/* (DP)disable padding,
+						   added by - reyaz           */
+	desc_tx_cis_mask = 0x00c00000,		/* Tx checksum offloading
+						   control mask               */
+	desc_tx_cis_bypass = 0x00000000,	/* Checksum bypass            */
+	desc_tx_cis_ipv4_hdr_cs = 0x00400000,	/* IPv4 header checksum       */
+	desc_tx_cis_tcp_only_cs = 0x00800000,	/* TCP/UDP/ICMP checksum.
+						   Pseudo header  checksum
+						   is assumed to be present   */
+	desc_tx_cis_tcp_pseudo_cs = 0x00c00000,	/* TCP/UDP/ICMP checksum fully
+						   in hardware  including
+						   pseudo header              */
+	tx_desc_end_of_ring = 0x00200000,	/* (TER)End of descriptor ring*/
+	tx_desc_chain = 0x00100000,		/* (TCH)Second buffer address
+						   is chain address           */
+	desc_rx_chk_bit0 = 0x00000001,		/* Rx Payload Checksum Error  */
+	desc_rx_chk_bit7 = 0x00000080,		/* (IPC CS ERROR)Rx - Ipv4
+						   header checksum error      */
+	desc_rx_chk_bit5 = 0x00000020,		/* (FT)Rx - Frame type - Ether,
+						   otherwise 802.3            */
+	desc_rx_ts_avail = 0x00000080,		/* Time stamp available       */
+	desc_rx_frame_type = 0x00000020,	/* (FT)Rx - Frame type - Ether,
+						   otherwise 802.3            */
+	desc_tx_ipv4_chk_error = 0x00010000,	/* (IHE) Tx Ip header error   */
+	desc_tx_timeout = 0x00004000,		/* (JT)Tx - Transmit
+						   jabber timeout             */
+	desc_tx_frame_flushed = 0x00002000,	/* (FF)Tx - DMA/MTL flushed
+						   the frame  due to SW flush */
+	desc_tx_pay_chk_error = 0x00001000,	/* (PCE) Tx Payload checksum
+						   Error		      */
+	desc_tx_lost_carrier = 0x00000800,	/* (LC)Tx - carrier lost
+						   during tramsmission        */
+	desc_tx_no_carrier = 0x00000400,	/* (NC)Tx - no carrier signal
+						   from the tranceiver        */
+	desc_tx_late_collision = 0x00000200,	/* (LC)Tx - transmission aborted
+						   due to collision           */
+	desc_tx_exc_collisions = 0x00000100,	/* (EC)Tx - transmission aborted
+						   after 16 collisions        */
+	desc_tx_vlan_frame = 0x00000080,	/* (VF)Tx - VLAN-type frame   */
+	desc_tx_coll_mask = 0x00000078,		/* (CC)Tx - Collision count   */
+	desc_tx_coll_shift = 3,
+	desc_tx_exc_deferral = 0x00000004,	/* (ED)Tx - excessive deferral*/
+	desc_tx_underflow = 0x00000002,		/* (UF)Tx - late data arrival
+						   from the memory            */
+	desc_tx_deferred = 0x00000001,		/* (DB)Tx - frame
+						   transmision deferred       */
+
+	/*
+	 * This explains the RDES1/TDES1 bits layout
+	 *             ------------------------------------------------------
+	 * RDES1/TDES1 | Control Bits | Byte Count Buf 2 | Byte Count Buf 1 |
+	 *             ------------------------------------------------------
+	 */
+
+	/*dma_descriptor_length *//* length word of DMA descriptor */
+	rx_dis_int_compl = 0x80000000,	/* (Disable Rx int on completion)     */
+	rx_desc_end_of_ring = 0x00008000,	/* (TER)End of descriptor ring*/
+	rx_desc_chain = 0x00004000,	/* (TCH)Second buffer address
+					   is chain address                   */
+	desc_size2_mask = 0x1FFF0000,	/* (TBS2) Buffer 2 size               */
+	desc_size2_shift = 16,
+	desc_size1_mask = 0x00001FFF,	/* (TBS1) Buffer 1 size               */
+	desc_size1_shift = 0,
+
+	/*
+	 * This explains the RDES4 Extended Status bits layout
+	 *              --------------------------------------------------------
+	 *   RDES4      |                 Extended Status                      |
+	 *              --------------------------------------------------------
+	 */
+	desc_rx_ptp_avail = 0x00004000,		/* PTP snapshot available     */
+	desc_rx_ptp_ver = 0x00002000,		/* When set indicates IEEE1584
+						   Version 2 (else Ver1)      */
+	desc_rx_ptp_frame_type = 0x00001000,	/* PTP frame type Indicates PTP
+						   sent over ethernet         */
+	desc_rx_ptp_message_type = 0x00000F00,	/* Message Type               */
+	desc_rx_ptp_no = 0x00000000,		/* 0000 => No PTP message rcvd*/
+	desc_rx_ptp_sync = 0x00000100,		/* 0001 => Sync (all clock
+						   types) received            */
+	desc_rx_ptp_follow_up = 0x00000200,	/* 0010 => Follow_Up (all clock
+						   types) received            */
+	desc_rx_ptp_delay_req = 0x00000300,	/* 0011 => Delay_Req (all clock
+						   types) received            */
+	desc_rx_ptp_delay_resp = 0x00000400,	/* 0100 => Delay_Resp (all clock
+						   types) received            */
+	desc_rx_ptp_pdelay_req = 0x00000500,	/* 0101 => Pdelay_Req (in P
+						   to P tras clk)  or Announce
+						   in Ord and Bound clk       */
+	desc_rx_ptp_pdelay_resp = 0x00000600,	/* 0110 => Pdealy_Resp(in P to
+						   P trans clk) or Management in
+						   Ord and Bound clk          */
+	desc_rx_ptp_pdelay_resp_fP = 0x00000700,/* 0111 => Pdealy_Resp_Follow_Up
+						   (in P to P trans clk) or
+						   Signaling in Ord and Bound
+						   clk			      */
+	desc_rx_ptp_ipv6 = 0x00000080,		/* Received Packet is in IPV6 */
+	desc_rx_ptp_ipv4 = 0x00000040,		/* Received Packet is in IPV4 */
+	desc_rx_chk_sum_bypass = 0x00000020,	/* When set indicates checksum
+						   offload engine is bypassed */
+	desc_rx_ip_payload_error = 0x00000010,	/* When set indicates 16bit IP
+						   payload CS is in error     */
+	desc_rx_ip_header_error = 0x00000008,	/* When set indicates 16bit IPV4
+						   hdr CS is err or IP datagram
+						   version is not consistent
+						   with Ethernet type value   */
+	desc_rx_ip_payload_type = 0x00000007,	/* Indicate the type of payload
+						   encapsulated in IPdatagram
+						   processed by COE (Rx)      */
+	desc_rx_ip_payload_unknown = 0x00000000,/* Unknown or didnot process
+						   IP payload                 */
+	desc_rx_ip_payload_udp = 0x00000001,	/* UDP                        */
+	desc_rx_ip_payload_tcp = 0x00000002,	/* TCP                        */
+	desc_rx_ip_payload_icmp = 0x00000003,	/* ICMP                       */
+};
+
+/**********************************************************
+ * Initial register values
+ **********************************************************/
+enum initial_registers {
+	/* Full-duplex mode with perfect filter on */
+	gmac_config_init_fdx1000 = gmac_watchdog_enable | gmac_jabber_enable
+	    | gmac_frame_burst_enable | gmac_jumbo_frame_disable
+	    | gmac_select_gmii | gmac_enable_rx_own
+	    | gmac_loopback_off | gmac_full_duplex | gmac_retry_enable
+	    | gmac_pad_crc_strip_disable | gmac_backoff_limit0
+	    | gmac_deferral_check_disable | gmac_tx_enable | gmac_rx_enable,
+
+	/* Full-duplex mode with perfect filter on */
+	gmac_config_init_fdx110 = gmac_watchdog_enable | gmac_jabber_enable
+	    | gmac_frame_burst_enable
+	    | gmac_jumbo_frame_disable | gmac_select_mii | gmac_enable_rx_own
+	    | gmac_loopback_off | gmac_full_duplex | gmac_retry_enable
+	    | gmac_pad_crc_strip_disable | gmac_backoff_limit0
+	    | gmac_deferral_check_disable | gmac_tx_enable | gmac_rx_enable,
+
+	/* Full-duplex mode */
+	/*      CHANGED: Pass control config, dest addr filter normal,
+	   added source address filter, multicast & unicast
+	 */
+
+	/* Hash filter. */
+	/* = gmac_filter_off | gmac_pass_control_off | gmac_broadcast_enable */
+	gmac_frame_filter_init_fdx =
+	    gmac_filter_on | gmac_pass_control0 | gmac_broadcast_enable |
+	    gmac_src_addr_filter_disable | gmac_multicast_filter_on |
+	    gmac_dest_addr_filter_nor | gmac_mcast_hash_filter_off |
+	    gmac_promiscuous_mode_off | gmac_ucast_hash_filter_off,
+
+	/* Full-duplex mode */
+	gmac_flow_control_init_fdx =
+	    gmac_unicast_pause_frame_off | gmac_rx_flow_control_enable |
+	    gmac_tx_flow_control_enable,
+
+	/* Full-duplex mode */
+	gmac_gmii_addr_init_fdx = gmii_csr_clk2,
+
+	/* Half-duplex mode with perfect filter on */
+	/* CHANGED: Removed Endian configuration, added single bit
+	 *config for PAD/CRC strip,
+	 */
+
+	gmac_config_init_hdx1000 = gmac_watchdog_enable | gmac_jabber_enable
+	    | gmac_frame_burst_enable | gmac_jumbo_frame_disable
+	    | gmac_select_gmii | gmac_disable_rx_own
+	    | gmac_loopback_off | gmac_half_duplex | gmac_retry_enable
+	    | gmac_pad_crc_strip_disable | gmac_backoff_limit0
+	    | gmac_deferral_check_disable | gmac_tx_enable | gmac_rx_enable,
+
+	/* Half-duplex mode with perfect filter on */
+	gmac_config_init_hdx110 = gmac_watchdog_enable | gmac_jabber_enable
+	    | gmac_frame_burst_enable | gmac_jumbo_frame_disable
+	    | gmac_select_mii | gmac_disable_rx_own | gmac_loopback_off
+	    | gmac_half_duplex | gmac_retry_enable
+	    | gmac_pad_crc_strip_disable | gmac_backoff_limit0
+	    | gmac_deferral_check_disable | gmac_tx_enable | gmac_rx_enable,
+
+	/* Half-duplex mode */
+	gmac_frame_filter_init_hdx = gmac_filter_on | gmac_pass_control0
+	    | gmac_broadcast_enable | gmac_src_addr_filter_disable
+	    | gmac_multicast_filter_on | gmac_dest_addr_filter_nor
+	    | gmac_mcast_hash_filter_off | gmac_ucast_hash_filter_off
+	    | gmac_promiscuous_mode_off,
+
+	/* Half-duplex mode */
+	gmac_flow_control_init_hdx = gmac_unicast_pause_frame_off
+	    | gmac_rx_flow_control_disable | gmac_tx_flow_control_disable,
+
+	/* Half-duplex mode */
+	gmac_gmii_addr_init_hdx = gmii_csr_clk2,
+
+/*********************************************
+* DMA configurations
+**********************************************/
+
+	dma_bus_mode_init = dma_fixed_burst_enable | dma_burst_length8
+	    | dma_descriptor_skip2 | dma_reset_off,
+
+	dma_bus_mode_val = dma_burst_length32
+	    | dma_burst_lengthx8 | dma_descriptor_skip0
+	    | dma_descriptor8_words | dma_arbit_pr | dma_address_aligned_beats,
+
+	/* 1000 Mb/s mode */
+	dma_control_init1000 = dma_store_and_forward,
+
+	/* 100 Mb/s mode */
+	dma_control_init100 = dma_store_and_forward,
+
+	/* 10 Mb/s mode */
+	dma_control_init10 = dma_store_and_forward,
+
+	dma_omr = dma_store_and_forward | dma_rx_store_and_forward
+	    | dma_rx_thresh_ctrl128 | dma_tx_second_frame,
+
+	/* Interrupt groups */
+	dma_int_error_mask = dma_int_bus_error,		/* Error              */
+	dma_int_rx_abn_mask = dma_int_rx_no_buffer,	/* RX abnormal intr   */
+	dma_int_rx_norm_mask = dma_int_rx_completed,	/* RXnormal intr      */
+	dma_int_rx_stopped_mask = dma_int_rx_stopped,	/* RXstopped          */
+	dma_int_tx_abn_mask = dma_int_tx_underflow,	/* TX abnormal intr   */
+	dma_int_tx_norm_mask = dma_int_tx_completed,	/* TX normal intr     */
+	dma_int_tx_stopped_mask = dma_int_tx_stopped,	/* TX stopped         */
+
+	dma_int_enable = dma_ie_normal | dma_ie_abnormal | dma_int_error_mask
+	    | dma_int_rx_abn_mask | dma_int_rx_norm_mask
+	    | dma_int_rx_stopped_mask | dma_int_tx_abn_mask
+	    | dma_int_tx_norm_mask | dma_int_tx_stopped_mask,
+	dma_int_disable = 0,
+	dma_axi_bus_mode_val = dma_axi_blen16 | dma_rd_osr_num_reqs8 |
+							dma_wr_osr_num_reqs8,
+};
+/**********************************************************
+ * Mac Management Counters (MMC)
+ **********************************************************/
+enum mmc_enable {
+	gmac_mmc_cntrl = 0x0100,		/* mmc control for operating
+					   mode of MMC                  */
+	gmac_mmc_intr_rx = 0x0104,		/* maintains interrupts
+					   generated by rx counters     */
+	gmac_mmc_intr_tx = 0x0108,		/* maintains interrupts
+					   generated by tx counters     */
+	gmac_mmc_intr_mask_rx = 0x010C,	/* mask for interrupts
+					   generated from rx counters   */
+	gmac_mmc_intr_mask_tx = 0x0110,	/* mask for interrupts
+					   generated from tx counters   */
+};
+
+enum mmc_ip_related {
+	gmac_mmc_rx_ipc_intr_mask = 0x0200,
+/*Maintains the mask for interrupt generated from rx IPC statistic counters   */
+};
+
+/*******************Ip checksum offloading APIs********************************/
+void nss_gmac_enable_rx_chksum_offload(struct nss_gmac_dev *gmacdev);
+void nss_gmac_disable_rx_chksum_offload(struct nss_gmac_dev *gmacdev);
+void nss_gmac_rx_tcpip_chksum_drop_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_rx_tcpip_chksum_drop_disable(struct nss_gmac_dev *gmacdev);
+
+/**
+ * The check summ offload engine is enabled to do complete checksum computation.
+ * Hardware computes the tcp ip checksum including the pseudo header checksum.
+ * Here the tcp payload checksum field should be set to 0000.
+ * Ipv4 header checksum is also inserted.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] Pointer to tx descriptor for which pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+static inline void nss_gmac_tx_checksum_offload_tcp_pseudo(struct nss_gmac_dev *
+						   gmacdev,
+						   struct dma_desc *desc)
+{
+	desc->status =
+	    ((desc->status & (~desc_tx_cis_mask)) | desc_tx_cis_tcp_pseudo_cs);
+}
+
+/**********************************************************
+ * Common functions
+ **********************************************************/
+/**
+ * @brief Low level function to read register contents from Hardware.
+ * @param[in] pointer containing address of register base
+ * @param[in] register offset
+ * @return contents of register
+ */
+static inline uint32_t nss_gmac_read_reg(uint32_t *regbase,
+					     uint32_t regoffset)
+{
+	uint32_t addr = 0;
+	uint32_t data;
+
+	spin_lock(&ctx.reg_lock);
+	addr = (uint32_t)regbase + regoffset;
+	data = readl_relaxed((unsigned char *)addr);
+	spin_unlock(&ctx.reg_lock);
+
+	return data;
+}
+
+
+/**
+ * @brief Low level function to write to a register in Hardware.
+ * @param[in] pointer containing address of register base
+ * @param[in] register offset
+ * @param[in] data to be written
+ * @return void
+ */
+static inline void nss_gmac_write_reg(uint32_t *regbase,
+					  uint32_t regoffset,
+					  uint32_t regdata)
+{
+	uint32_t addr = 0;
+
+	spin_lock(&ctx.reg_lock);
+	addr = (uint32_t)regbase + regoffset;
+	writel_relaxed(regdata, (unsigned char *)addr);
+	spin_unlock(&ctx.reg_lock);
+}
+
+
+/**
+ * @brief Low level function to set bits of a register in Hardware.
+ * @param[in] pointer containing address of register base
+ * @param[in] register offset
+ * @param[in] bit mask of bits to be set
+ * @return void
+ */
+static inline void nss_gmac_set_reg_bits(uint32_t *regbase,
+					     uint32_t regoffset,
+					     uint32_t bitpos)
+{
+	uint32_t data = 0;
+
+	data = bitpos | nss_gmac_read_reg(regbase, regoffset);
+	nss_gmac_write_reg(regbase, regoffset, data);
+}
+
+
+/**
+ * @brief Low level function to clear bits of a register in Hardware.
+ * @param[in] pointer containing address of register base
+ * @param[in] register offset
+ * @param[in] bit mask of bits to be cleared
+ * @return void
+ */
+static inline void nss_gmac_clear_reg_bits(uint32_t *regbase,
+					       uint32_t regoffset,
+					       uint32_t bitpos)
+{
+	uint32_t data = 0;
+
+	data = ~bitpos & nss_gmac_read_reg(regbase, regoffset);
+	nss_gmac_write_reg(regbase, regoffset, data);
+}
+
+
+/**
+ * @brief Low level function to Check the setting of the bits.
+ * @param[in] pointer containing address of register base
+ * @param[in] register offset
+ * @param[in] bit mask of bits to be checked
+ * @return True if bits corresponding to the given bitmask are set.
+ */
+static inline bool nss_gmac_check_reg_bits(uint32_t *regbase,
+					       uint32_t regoffset,
+					       uint32_t bitpos)
+{
+	uint32_t data;
+
+	data = bitpos & nss_gmac_read_reg(regbase, regoffset);
+
+	return data != 0;
+}
+
+uint16_t nss_gmac_mii_rd_reg(struct nss_gmac_dev *gmacdev, uint32_t phy,
+			     uint32_t reg);
+void nss_gmac_mii_wr_reg(struct nss_gmac_dev *gmacdev, uint32_t phy,
+			 uint32_t reg, uint16_t data);
+int32_t nss_gmac_read_version(struct nss_gmac_dev *gmacdev);
+void nss_gmac_reset(struct nss_gmac_dev *gmacdev);
+int32_t nss_gmac_dma_bus_mode_init(struct nss_gmac_dev *gmacdev,
+						uint32_t init_value);
+int32_t nss_gmac_dma_axi_bus_mode_init(struct nss_gmac_dev *gmacdev,
+						uint32_t init_value);
+int32_t nss_gmac_dma_control_init(struct nss_gmac_dev *gmacdev,
+						uint32_t init_value);
+void nss_gmac_wd_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_jab_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_frame_burst_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_jumbo_frame_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_jumbo_frame_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_twokpe_frame_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_twokpe_frame_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_select_gmii(struct nss_gmac_dev *gmacdev);
+void nss_gmac_select_mii(struct nss_gmac_dev *gmacdev);
+void nss_gmac_rx_own_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_rx_own_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_loopback_off(struct nss_gmac_dev *gmacdev);
+void nss_gmac_set_full_duplex(struct nss_gmac_dev *gmacdev);
+void nss_gmac_set_half_duplex(struct nss_gmac_dev *gmacdev);
+void nss_gmac_retry_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_retry_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_pad_crc_strip_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_back_off_limit(struct nss_gmac_dev *gmacdev, uint32_t value);
+void nss_gmac_deferral_check_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_rx_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_rx_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_tx_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_tx_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_frame_filter_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_src_addr_filter_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_dst_addr_filter_normal(struct nss_gmac_dev *gmacdev);
+void nss_gmac_set_pass_control(struct nss_gmac_dev *gmacdev,
+				uint32_t passcontrol);
+void nss_gmac_broadcast_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_multicast_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_multicast_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_multicast_hash_filter_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_promisc_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_promisc_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_unicast_hash_filter_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_unicast_pause_frame_detect_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_rx_flow_control_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_tx_flow_control_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_tx_pause_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_tx_pause_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_rx_pause_enable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_rx_pause_disable(struct nss_gmac_dev *gmacdev);
+void nss_gmac_flush_tx_fifo(struct nss_gmac_dev *gmacdev);
+void nss_gmac_mac_init(struct nss_gmac_dev *gmacdev);
+int32_t nss_gmac_check_phy_init(struct nss_gmac_dev *gmacdev);
+int32_t nss_gmac_ath_phy_mmd_wr(struct phy_device *phydev,
+		uint32_t mmd_dev_addr, uint32_t reg, uint16_t val);
+int32_t nss_gmac_ath_phy_mmd_rd(struct phy_device *phydev,
+			uint32_t mmd_dev_addr, uint32_t reg);
+int32_t nss_gmac_ath_phy_disable_smart_802az(struct phy_device *phydev);
+int32_t nss_gmac_ath_phy_disable_802az(struct phy_device *phydev);
+void nss_gmac_set_mac_addr(struct nss_gmac_dev *gmacdev,
+			uint32_t mac_high, uint32_t mac_low, uint8_t *mac_addr);
+void nss_gmac_get_mac_addr(struct nss_gmac_dev *gmacdev,
+			uint32_t mac_high, uint32_t mac_low, uint8_t *mac_addr);
+int32_t nss_gmac_attach(struct nss_gmac_dev *gmacdev, uint32_t reg_base,
+			uint32_t reglen);
+void nss_gmac_detach(struct nss_gmac_dev *gmacdev);
+int32_t nss_gmac_check_link(struct nss_gmac_dev *gmacdev);
+void nss_gmac_ipc_offload_init(struct nss_gmac_dev *gmacdev);
+void nss_gmac_tx_rx_desc_init(struct nss_gmac_dev *gmacdev);
+int32_t nss_gmac_init_mdiobus(struct nss_gmac_dev *gmacdev);
+void nss_gmac_deinit_mdiobus(struct nss_gmac_dev *gmacdev);
+void nss_gmac_reset_phy(struct nss_gmac_dev *gmacdev, uint32_t phyid);
+int32_t nss_gmac_write_phy_reg(uint32_t *reg_base, uint32_t phy_base,
+			       uint32_t reg_offset, uint16_t data,
+			       uint32_t mdc_clk_div);
+int32_t nss_gmac_read_phy_reg(uint32_t *reg_base, uint32_t phy_base,
+			      uint32_t reg_offset, uint16_t *data,
+			      uint32_t mdc_clk_div);
+
+/*
+ * nss_gmac_common_init()
+ *	Init commom to all GMACs.
+ */
+int32_t nss_gmac_common_init(struct nss_gmac_global_ctx *ctx);
+
+/*
+ * nss_gmac_common_deinit()
+ *	Global common deinit.
+ */
+void nss_gmac_common_deinit(struct nss_gmac_global_ctx *ctx);
+
+/*
+ * nss_gmac_dev_init()
+ *	GMAC device initializaton.
+ */
+void nss_gmac_dev_init(struct nss_gmac_dev *gmacdev);
+
+/*
+ * nss_gmac_dev_set_speed()
+ *	Set GMAC speed.
+ */
+int32_t nss_gmac_dev_set_speed(struct nss_gmac_dev *gmacdev);
+
+/*
+ * nss_gmac_spare_ctl()
+ *	Spare Control reset. Required only for emulation.
+ */
+void nss_gmac_spare_ctl(struct nss_gmac_dev *gmacdev);
+
+/**
+ * Initialize the rx descriptors for ring or chain mode operation.
+ *	- Status field is initialized to 0.
+ *	- end_of_ring set for the last descriptor.
+ *	- buffer1 and buffer2 set to 0 for ring mode of operation. (note)
+ *	- data1 and data2 set to 0. (note)
+ * @param[in] pointer to dma_desc structure.
+ * @param[in] whether end of ring
+ * @return void.
+ * @note Initialization of the buffer1, buffer2, data1,data2 and status are not
+ * done here. This only initializes whether one wants to use this descriptor
+ * in chain mode or ring mode. For chain mode of operation the buffer2 and data2
+ * are programmed before calling this function.
+ */
+static inline void nss_gmac_rx_desc_init_ring(struct dma_desc *desc,
+					      bool last_ring_desc)
+{
+	desc->status = 0;
+	desc->length = last_ring_desc ? rx_desc_end_of_ring : 0;
+	desc->buffer1 = 0;
+	desc->data1 = 0;
+}
+
+/**
+ * Initialize the tx descriptors for ring or chain mode operation.
+ *	- Status field is initialized to 0.
+ *	- end_of_ring set for the last descriptor.
+ *	- buffer1 and buffer2 set to 0 for ring mode of operation. (note)
+ *	- data1 and data2 set to 0. (note)
+ * @param[in] pointer to dma_desc structure.
+ * @param[in] whether end of ring
+ * @return void.
+ * @note Initialization of the buffer1, buffer2, data1,data2 and status are not
+ * done here. This only initializes whether one wants to use this descriptor
+ * in chain mode or ring mode. For chain mode of operation the buffer2 and data2
+ * are programmed before calling this function.
+ */
+static inline void nss_gmac_tx_desc_init_ring(struct dma_desc *desc,
+					      bool last_ring_desc)
+{
+	desc->status = last_ring_desc ? tx_desc_end_of_ring : 0;
+	desc->length = 0;
+	desc->buffer1 = 0;
+	desc->data1 = 0;
+}
+
+void nss_gmac_init_rx_desc_base(struct nss_gmac_dev *gmacdev);
+void nss_gmac_init_tx_desc_base(struct nss_gmac_dev *gmacdev);
+void nss_gmac_set_owner_dma(struct dma_desc *desc);
+void nss_gmac_set_desc_sof(struct dma_desc *desc);
+void nss_gmac_set_desc_eof(struct dma_desc *desc);
+bool nss_gmac_is_sof_in_rx_desc(struct dma_desc *desc);
+bool nss_gmac_is_eof_in_rx_desc(struct dma_desc *desc);
+bool nss_gmac_is_da_filter_failed(struct dma_desc *desc);
+bool nss_gmac_is_sa_filter_failed(struct dma_desc *desc);
+
+/**
+ * Checks whether the descriptor is owned by DMA.
+ * If descriptor is owned by DMA then the OWN bit is set to 1.
+ * This API is same for both ring and chain mode.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if Dma owns descriptor and false if not.
+ */
+static inline bool nss_gmac_is_desc_owned_by_dma(struct dma_desc *desc)
+{
+	return (desc->status & desc_own_by_dma) == desc_own_by_dma;
+}
+
+
+/**
+ * returns the byte length of received frame including CRC.
+ * This returns the no of bytes received in the received ethernet frame
+ * including CRC(FCS).
+ * @param[in] pointer to dma_desc structure.
+ * @return returns the length of received frame lengths in bytes.
+ */
+static inline uint32_t nss_gmac_get_rx_desc_frame_length(uint32_t status)
+{
+	return (status & desc_frame_length_mask) >> desc_frame_length_shift;
+}
+
+
+/**
+ * Checks whether the descriptor is valid
+ * if no errors such as CRC/Receive Error/Watchdog Timeout/Late collision/
+ * Giant Frame/Overflow/Descriptor error the descritpor is said to be a valid
+ * descriptor.
+ * @param[in] pointer to dma_desc structure.
+ * @return True if desc valid. false if error.
+ */
+static inline bool nss_gmac_is_desc_valid(uint32_t status)
+{
+	return (status & desc_error) == 0;
+}
+
+
+/**
+ * Checks whether the descriptor is empty.
+ * If the buffer1 and buffer2 lengths are zero in ring mode descriptor is empty.
+ * In chain mode buffer2 length is 0 but buffer2 itself contains the next
+ * descriptor address.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if descriptor is empty, false if not empty.
+ */
+static inline bool nss_gmac_is_desc_empty(struct dma_desc *desc)
+{
+	/* if length of both buffer1 & buffer2 are zero then desc is empty */
+	return (desc->length & desc_size1_mask) == 0;
+}
+
+
+/**
+ * Checks whether the rx descriptor is valid.
+ * if rx descripor is not in error and complete frame is available in the same
+ * descriptor
+ * @param[in] status
+ * @return returns true if no error and first and last desc bits are set,
+ * otherwise it returns false.
+ */
+static inline bool nss_gmac_is_rx_desc_valid(uint32_t status)
+{
+	return (status & (desc_error | desc_rx_first | desc_rx_last)) ==
+		(desc_rx_first | desc_rx_last);
+}
+
+bool nss_gmac_is_tx_aborted(uint32_t status);
+bool nss_gmac_is_tx_carrier_error(uint32_t status);
+bool nss_gmac_is_tx_underflow_error(uint32_t status);
+bool nss_gmac_is_tx_lc_error(uint32_t status);
+
+
+/**
+ * Gives the transmission collision count.
+ * returns the transmission collision count indicating number of
+ * collisions occurred before the frame was transmitted.
+ * Make sure to check excessive collision didnot happen to ensure the count is
+ * valid.
+ * @param[in] status
+ * @return returns the count value of collision.
+ */
+static inline uint32_t nss_gmac_get_tx_collision_count(uint32_t status)
+{
+	return (status & desc_tx_coll_mask) >> desc_tx_coll_shift;
+}
+
+static inline uint32_t nss_gmac_is_exc_tx_collisions(uint32_t status)
+{
+	return (status & desc_tx_exc_collisions) == desc_tx_exc_collisions;
+}
+
+bool nss_gmac_is_rx_frame_damaged(uint32_t status);
+bool nss_gmac_is_rx_frame_collision(uint32_t status);
+bool nss_gmac_is_rx_crc(uint32_t status);
+bool nss_gmac_is_frame_dribbling_errors(uint32_t status);
+bool nss_gmac_is_rx_frame_length_errors(uint32_t status);
+
+
+/**
+ * Checks whether this rx descriptor is last rx descriptor.
+ * This returns true if it is last descriptor either in ring mode or chain mode.
+ * @param[in] pointer to devic structure.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if it is last descriptor, false if not.
+ */
+static inline bool nss_gmac_is_last_rx_desc(struct nss_gmac_dev *gmacdev,
+					    struct dma_desc *desc)
+{
+	return unlikely((desc->length & rx_desc_end_of_ring) != 0);
+}
+
+
+/**
+ * Checks whether this tx descriptor is last tx descriptor.
+ * This returns true if it is last descriptor either in ring mode or chain mode.
+ * @param[in] pointer to devic structure.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if it is last descriptor, false if not.
+ */
+static inline bool nss_gmac_is_last_tx_desc(struct nss_gmac_dev *gmacdev,
+					    struct dma_desc *desc)
+{
+	return unlikely((desc->status & tx_desc_end_of_ring) != 0);
+}
+
+
+/**
+ * Checks whether this rx descriptor is in chain mode.
+ * This returns true if it is this descriptor is in chain mode.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if chain mode is set, false if not.
+ */
+static inline bool nss_gmac_is_rx_desc_chained(struct dma_desc *desc)
+{
+	/*
+	 * Use ring mode only.
+	 * This is also the only way to support jumbo in the future.
+	 */
+	return 0;
+}
+
+
+/**
+ * Checks whether this tx descriptor is in chain mode.
+ * This returns true if it is this descriptor is in chain mode.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if chain mode is set, false if not.
+ */
+static inline bool nss_gmac_is_tx_desc_chained(struct dma_desc *desc)
+{
+	/*
+	 * Use ring mode only.
+	 * This is also the only way to support jumbo in the future.
+	 */
+	return 0;
+}
+
+void nss_gmac_get_desc_data(struct dma_desc *desc, uint32_t *Status,
+			    uint32_t *buffer1, uint32_t *length1,
+			    uint32_t *data1);
+
+/**
+ * Get the index and address of Tx desc.
+ * This api is same for both ring mode and chain mode.
+ * This function tracks the tx descriptor the DMA just closed after the
+ * transmission of data from this descriptor is over. This returns the
+ * descriptor fields to the caller.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns present tx descriptor index on success. Negative value if
+ * error.
+ */
+static inline struct dma_desc *nss_gmac_get_tx_qptr(struct nss_gmac_dev *gmacdev)
+{
+	struct dma_desc *txdesc = gmacdev->tx_busy_desc;
+
+	if (unlikely(gmacdev->busy_tx_desc == 0))
+		return NULL;
+
+	if (nss_gmac_is_desc_owned_by_dma(txdesc))
+		return NULL;
+
+	BUG_ON(nss_gmac_is_desc_empty(txdesc));
+
+	return txdesc;
+}
+
+
+/**
+ * Reset the descriptor after Tx is over.
+ * Update descriptor pointers.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return Returns void
+ */
+static inline void nss_gmac_reset_tx_qptr(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t txover = gmacdev->tx_busy;
+	struct dma_desc *txdesc = gmacdev->tx_busy_desc;
+
+	BUG_ON(txdesc != (gmacdev->tx_desc + txover));
+	gmacdev->tx_busy = (txover + 1) & (gmacdev->tx_desc_count - 1);
+	gmacdev->tx_busy_desc = gmacdev->tx_desc + gmacdev->tx_busy;
+
+	txdesc->status &= tx_desc_end_of_ring;
+	txdesc->length = 0;
+	txdesc->buffer1 = 0;
+	txdesc->data1 = 0;
+	txdesc->reserved1 = 0;
+
+	/*
+	 * Busy tx descriptor is reduced by one as
+	 * it will be handed over to Processor now.
+	 */
+	(gmacdev->busy_tx_desc)--;
+}
+
+
+/**
+ * Populate the tx desc structure with the buffer address.
+ * Once the driver has a packet ready to be transmitted, this function is called
+ * with the valid dma-able buffer addresses and their lengths. This function
+ * populates the descriptor and make the DMA the owner for the descriptor. This
+ * function also controls whetther Checksum offloading to be done in hardware or
+ * not.
+ * This api is same for both ring mode and chain mode.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] Dma-able buffer1 pointer.
+ * @param[in] length of buffer1 (Max is 2048).
+ * @param[in] virtual pointer for buffer1.
+ * @param[in] uint32_t indicating whether the checksum offloading in HW/SW.
+ * @param[in] uint32_t indicating TX control flag - the first, last segment and
+ * interrupt state.
+ * @param[in] uint32_t indicating descriptor DMA flag state.
+ * @return returns present tx descriptor pointer.
+ */
+static inline struct dma_desc *nss_gmac_set_tx_qptr(struct nss_gmac_dev *gmacdev,
+					   uint32_t Buffer1, uint32_t Length1,
+					   uint32_t Data1,
+					   uint32_t offload_needed,
+					   uint32_t tx_cntl, uint32_t set_dma)
+{
+	uint32_t txnext = gmacdev->tx_next;
+	struct dma_desc *txdesc = gmacdev->tx_next_desc;
+
+	BUG_ON(gmacdev->busy_tx_desc > gmacdev->tx_desc_count);
+	BUG_ON(txdesc != (gmacdev->tx_desc + txnext));
+	BUG_ON(!nss_gmac_is_desc_empty(txdesc));
+	BUG_ON(nss_gmac_is_desc_owned_by_dma(txdesc));
+
+	if (Length1 > NSS_GMAC_MAX_DESC_BUFF) {
+		txdesc->length |=
+		    (NSS_GMAC_MAX_DESC_BUFF << desc_size1_shift) & desc_size1_mask;
+		txdesc->length |=
+		    ((Length1 -
+		      NSS_GMAC_MAX_DESC_BUFF) << desc_size2_shift) & desc_size2_mask;
+	} else {
+		txdesc->length |= ((Length1 << desc_size1_shift) & desc_size1_mask);
+	}
+
+	txdesc->status |= tx_cntl;
+
+	txdesc->buffer1 = Buffer1;
+	txdesc->reserved1 = Data1;
+
+	/* Program second buffer address if using two buffers. */
+	if (Length1 > NSS_GMAC_MAX_DESC_BUFF)
+		txdesc->data1 = Buffer1 + NSS_GMAC_MAX_DESC_BUFF;
+	else
+		txdesc->data1 = 0;
+
+	if (likely(offload_needed))
+		nss_gmac_tx_checksum_offload_tcp_pseudo(gmacdev, txdesc);
+
+	/*
+	 * Ensure all write completed before setting own by dma bit so when gmac
+	 * HW takeover this descriptor, all the fields are filled correctly
+	 */
+	wmb();
+	txdesc->status |= set_dma;
+
+	gmacdev->tx_next = (txnext + 1) & (gmacdev->tx_desc_count - 1);
+	gmacdev->tx_next_desc = gmacdev->tx_desc + gmacdev->tx_next;
+
+	return txdesc;
+}
+
+
+/**
+ * Prepares the descriptor to receive packets.
+ * The descriptor is allocated with the valid buffer addresses (sk_buff address)
+ * and the length fields and handed over to DMA by setting the ownership. After
+ * successful return from this function the descriptor is added to the receive
+ * descriptor pool/queue.
+ * This api is same for both ring mode and chain mode.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] Dma-able buffer1 pointer.
+ * @param[in] length of buffer1 (Max is 2048).
+ * @param[in] pointer to buffer context.
+ * @return returns present rx descriptor index on success. Negative value if
+ * error.
+ */
+static inline int32_t nss_gmac_set_rx_qptr(struct nss_gmac_dev *gmacdev,
+					   uint32_t Buffer1, uint32_t Length1,
+					   uint32_t Data1)
+{
+	uint32_t rxnext = gmacdev->rx_next;
+	struct dma_desc *rxdesc = gmacdev->rx_next_desc;
+
+	BUG_ON(gmacdev->busy_rx_desc >= gmacdev->rx_desc_count);
+	BUG_ON(rxdesc != (gmacdev->rx_desc + rxnext));
+	BUG_ON(!nss_gmac_is_desc_empty(rxdesc));
+	BUG_ON(nss_gmac_is_desc_owned_by_dma(rxdesc));
+
+	if (Length1 > NSS_GMAC_MAX_DESC_BUFF) {
+		rxdesc->length |=
+		    (NSS_GMAC_MAX_DESC_BUFF << desc_size1_shift) & desc_size1_mask;
+		rxdesc->length |=
+		    ((Length1 -
+		      NSS_GMAC_MAX_DESC_BUFF) << desc_size2_shift) & desc_size2_mask;
+	} else {
+		rxdesc->length |= ((Length1 << desc_size1_shift) & desc_size1_mask);
+	}
+
+	rxdesc->buffer1 = Buffer1;
+	rxdesc->reserved1 = Data1;
+
+	/* Program second buffer address if using two buffers. */
+	if (Length1 > NSS_GMAC_MAX_DESC_BUFF)
+		rxdesc->data1 = Buffer1 + NSS_GMAC_MAX_DESC_BUFF;
+	else
+		rxdesc->data1 = 0;
+
+	rxdesc->extstatus = 0;
+	rxdesc->timestamplow = 0;
+	rxdesc->timestamphigh = 0;
+
+	/*
+	 * Ensure all write completed before setting own by dma bit so when gmac
+	 * HW takeover this descriptor, all the fields are filled correctly
+	 */
+	wmb();
+	rxdesc->status = desc_own_by_dma;
+
+	gmacdev->rx_next = (rxnext + 1) & (gmacdev->rx_desc_count - 1);
+	gmacdev->rx_next_desc = gmacdev->rx_desc + gmacdev->rx_next;
+
+	/*
+	 * 1 descriptor will be given to HW. So busy count incremented by 1.
+	 */
+	(gmacdev->busy_rx_desc)++;
+
+	return rxnext;
+}
+
+
+/**
+ * Get back the descriptor from DMA after data has been received.
+ * When the DMA indicates that the data is received (interrupt is generated),
+ * this function should be called to get the descriptor and hence the data
+ * buffers received. With successful return from this function caller gets the
+ * descriptor fields for processing. check the parameters to understand the
+ * fields returned.`
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns pointer to dma_desc on success. Negative value if error.
+ */
+static inline struct dma_desc *nss_gmac_get_rx_qptr(struct nss_gmac_dev *gmacdev)
+{
+	struct dma_desc *rxdesc = gmacdev->rx_busy_desc;
+
+	if (unlikely(gmacdev->busy_rx_desc == 0))
+		return NULL;
+
+	if (nss_gmac_is_desc_owned_by_dma(rxdesc))
+		return NULL;
+
+	BUG_ON(nss_gmac_is_desc_empty(rxdesc));
+
+	return rxdesc;
+}
+
+
+/**
+ * Reset the descriptor after Rx is over.
+ * Update descriptor pointers.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return Returns void
+ */
+static inline void nss_gmac_reset_rx_qptr(struct nss_gmac_dev *gmacdev)
+{
+
+	/* Index of descriptor the DMA just completed.
+	 * May be useful when data is spread over multiple buffers/descriptors
+	 */
+	uint32_t rxnext = gmacdev->rx_busy;
+	struct dma_desc *rxdesc = gmacdev->rx_busy_desc;
+
+	BUG_ON(rxdesc != (gmacdev->rx_desc + rxnext));
+	gmacdev->rx_busy = (rxnext + 1) & (gmacdev->rx_desc_count - 1);
+	gmacdev->rx_busy_desc = gmacdev->rx_desc + gmacdev->rx_busy;
+
+	rxdesc->status = 0;
+	rxdesc->length &= rx_desc_end_of_ring;
+	rxdesc->buffer1 = 0;
+	rxdesc->data1 = 0;
+	rxdesc->reserved1 = 0;
+
+	/* This returns one descriptor to processor.
+	 * So busy count will be decremented by one
+	 */
+	(gmacdev->busy_rx_desc)--;
+}
+
+
+/**
+ * Clears all the pending interrupts.
+ * If the Dma status register is read then all the interrupts gets cleared
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+static inline void nss_gmac_clear_interrupt(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t data;
+
+	data = readl_relaxed((unsigned char *)gmacdev->dma_base + dma_status);
+	writel_relaxed(data, (unsigned char *)gmacdev->dma_base + dma_status);
+}
+
+
+/**
+ * Returns the all unmasked interrupt status after reading the dma_status
+ * register.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return 0 upon success. Error code upon failure.
+ */
+static inline uint32_t nss_gmac_get_interrupt_type(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t interrupts = 0;
+
+	interrupts =
+	    nss_gmac_read_reg((uint32_t *)gmacdev->dma_base, dma_status);
+
+	/* Clear interrupt here */
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base, dma_status,
+			   interrupts);
+
+	return interrupts;
+}
+
+
+/**
+ * Returns the interrupt mask.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return 0 upon success. Error code upon failure.
+ */
+static inline uint32_t nss_gmac_get_interrupt_mask(struct nss_gmac_dev *gmacdev)
+{
+	return nss_gmac_read_reg((uint32_t *)gmacdev->dma_base, dma_interrupt);
+}
+
+
+/**
+ * @brief Enables the DMA interrupt as specified by the bit mask.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] bit mask of interrupts to be enabled.
+ * @return returns void.
+ */
+static inline void nss_gmac_enable_interrupt(struct nss_gmac_dev *gmacdev,
+					     uint32_t interrupts)
+{
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base, dma_interrupt,
+			   interrupts);
+}
+
+
+/**
+ * @brief Disable all the interrupts.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+static inline void nss_gmac_disable_mac_interrupt(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_write_reg((uint32_t *)gmacdev->mac_base, gmac_interrupt_mask,
+			   0xffffffff);
+}
+
+
+/**
+ * Disable all the interrupts.
+ * Disables all DMA interrupts.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ * @note This function disabled all the interrupts, if you want to disable a
+ * particular interrupt then use nss_gmac_disable_interrupt().
+ */
+static inline void nss_gmac_disable_interrupt_all(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base, dma_interrupt,
+			   dma_int_disable);
+	nss_gmac_disable_mac_interrupt(gmacdev);
+}
+
+
+/**
+ * Disable interrupt according to the bitfield supplied.
+ * Disables only those interrupts specified in the bit mask in second argument.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] bit mask for interrupts to be disabled.
+ * @return returns void.
+ */
+static inline void nss_gmac_disable_interrupt(struct nss_gmac_dev *gmacdev,
+					      uint32_t interrupts)
+{
+	uint32_t data = 0;
+
+	data = ~interrupts & readl_relaxed((unsigned char *)gmacdev->dma_base
+							+ dma_interrupt);
+	writel_relaxed(data, (unsigned char *)gmacdev->dma_base
+							+ dma_interrupt);
+}
+
+
+void nss_gmac_enable_dma_rx(struct nss_gmac_dev *gmacdev);
+void nss_gmac_enable_dma_tx(struct nss_gmac_dev *gmacdev);
+
+
+/**
+ * Resumes the DMA Transmission.
+ * the dma_tx_poll_demand is written. (the data writeen could be anything).
+ * This forces the DMA to resume transmission.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+static inline void nss_gmac_resume_dma_tx(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base,
+							dma_tx_poll_demand, 0);
+}
+
+
+/**
+ * Resumes the DMA Reception.
+ * the dma_rx_poll_demand is written. (the data writeen could be anything).
+ * This forces the DMA to resume reception.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+static inline void nss_gmac_resume_dma_rx(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base,
+							dma_rx_poll_demand, 0);
+}
+
+void nss_gmac_take_desc_ownership(struct dma_desc *desc);
+void nss_gmac_take_desc_ownership_rx(struct nss_gmac_dev *gmacdev);
+void nss_gmac_take_desc_ownership_tx(struct nss_gmac_dev *gmacdev);
+void nss_gmac_disable_dma_tx(struct nss_gmac_dev *gmacdev);
+void nss_gmac_disable_dma_rx(struct nss_gmac_dev *gmacdev);
+
+/*******************MMC APIs***************************************/
+void nss_gmac_disable_mmc_tx_interrupt(struct nss_gmac_dev *gmacdev,
+							uint32_t mask);
+void nss_gmac_disable_mmc_rx_interrupt(struct nss_gmac_dev *gmacdev,
+							uint32_t mask);
+void nss_gmac_disable_mmc_ipc_rx_interrupt(struct nss_gmac_dev *gmacdev,
+					   uint32_t mask);
+
+#endif /* End of file */
diff --git a/drivers/net/ethernet/atheros/nss-gmac/include/nss_gmac_network_interface.h b/drivers/net/ethernet/atheros/nss-gmac/include/nss_gmac_network_interface.h
new file mode 100644
index 0000000..b86a32b
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/include/nss_gmac_network_interface.h
@@ -0,0 +1,63 @@
+/*
+ **************************************************************************
+ * Copyright (c) 2013-2014, The Linux Foundation. All rights reserved.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for
+ * any purpose with or without fee is hereby granted, provided that the
+ * above copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
+ * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ **************************************************************************
+ */
+/*
+ * @file
+ * Header file for the nework dependent functionality.
+ * The function prototype listed here are linux dependent.
+ * ---------------------------REVISION HISTORY-------------------
+ * Qualcomm Atheros	01/Mar/2013		Modified for QCA NSS
+ * Ubicom		01/Mar/2010		Modified for Ubicom32
+ * Synopsys		01/Aug/2007		Created
+ */
+
+#ifndef __NSS_GMAC_NETWORK_INTERFACE_H__
+#define __NSS_GMAC_NETWORK_INTERFACE_H__
+
+#include <linux/ethtool.h>
+
+#include <nss_gmac_dev.h>
+
+#define NET_IF_TIMEOUT (10*HZ)
+#define NSS_GMAC_LINK_CHECK_TIME (HZ)
+
+/* Private ioctls supported by GMACs */
+#define IOCTL_READ_REGISTER	(SIOCDEVPRIVATE + 1)
+#define IOCTL_WRITE_REGISTER	(SIOCDEVPRIVATE + 2)
+
+/* Linux network interface APIs */
+int32_t nss_gmac_linux_xmit_frames(struct sk_buff *skb,
+				   struct net_device *netdev);
+int32_t nss_gmac_linux_close(struct net_device *netdev);
+int32_t nss_gmac_linux_open(struct net_device *netdev);
+int32_t nss_gmac_linux_change_mtu(struct net_device *netdev, int32_t newmtu);
+void nss_gmac_linux_tx_timeout(struct net_device *netdev);
+
+/* NSS driver interface APIs */
+void nss_gmac_receive(struct net_device *netdev, struct sk_buff *skb,
+						struct napi_struct *napi);
+void nss_gmac_event_receive(void *if_ctx, int ev_type,
+			    void *os_buf, uint32_t len);
+void nss_gmac_open_work(struct work_struct *work);
+void nss_gmac_ethtool_register(struct net_device *netdev);
+void __exit nss_gmac_deregister_driver(void);
+int32_t __init nss_gmac_register_driver(void);
+void nss_gmac_linkdown(struct nss_gmac_dev *gmacdev);
+void nss_gmac_linkup(struct nss_gmac_dev *gmacdev);
+void nss_gmac_adjust_link(struct net_device *netdev);
+
+#endif /* End of file */
diff --git a/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_ctrl.c b/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_ctrl.c
new file mode 100644
index 0000000..ea24525
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_ctrl.c
@@ -0,0 +1,1210 @@
+/*
+ **************************************************************************
+ * Copyright (c) 2013-2015, The Linux Foundation. All rights reserved.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for
+ * any purpose with or without fee is hereby granted, provided that the
+ * above copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
+ * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ **************************************************************************
+ */
+/*
+ * @file
+ * This is the network dependent layer to handle network related functionality.
+ * This file is tightly coupled to neworking frame work of linux 2.6.xx kernel.
+ * The functionality carried out in this file should be treated as an example
+ * only if the underlying operating system is not Linux.
+ *
+ * @note Many of the functions other than the device specific functions
+ * changes for operating system other than Linux 2.6.xx
+ *----------------------REVISION HISTORY-----------------------------------
+ * Qualcomm Atheros     01/Mar/2013			Modified for QCA NSS
+ * Ubicom		01/Mar/2010			Modified for Ubicom32
+ * Synopsys		01/Aug/2007			Created
+ */
+
+#include <linux/version.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/platform_device.h>
+#include <linux/workqueue.h>
+#include <linux/phy.h>
+
+#ifdef CONFIG_OF
+#include <linux/of.h>
+#include <linux/of_net.h>
+#include <linux/of_irq.h>
+#include <linux/of_platform.h>
+#include <linux/of_address.h>
+
+#include <msm_nss_gmac.h>
+#else
+#include <mach/msm_iomap.h>
+#include <mach/msm_nss_gmac.h>
+#endif
+
+#include <nss_gmac_dev.h>
+#include <nss_gmac_network_interface.h>
+
+
+#define NSS_GMAC_PHY_FIXUP_UID		0x004D0000
+#define NSS_GMAC_PHY_FIXUP_MASK		0xFFFF0000
+#define NSS_GMAC_COMMON_DEVICE_NODE	"nss-gmac-common"
+
+/* Prototypes */
+
+/* Global data */
+struct nss_gmac_global_ctx ctx;
+
+/**
+ * Sample Wake-up frame filter configurations
+ */
+uint32_t nss_gmac_wakeup_filter_config0[] = {
+	0x00000000,	/* For Filter0 CRC is not computed may be it is 0x0000*/
+	0x00000000,	/* For Filter1 CRC is not computed may be it is 0x0000*/
+	0x00000000,	/* For Filter2 CRC is not computed may be it is 0x0000*/
+	0x5F5F5F5F,	/* For Filter3 CRC is based on 0,1,2,3,4,6,8,9,10,11,12,
+			   14,16,17,18,19,20,22,24,25,26,27,28,30
+			   bytes from offset                                  */
+	0x09000000,	/* Filter 0,1,2 are disabled, Filter3 is enabled and
+			   filtering applies to only multicast packets        */
+	0x1C000000,	/* Filter 0,1,2 (no significance), filter 3 offset is 28
+			   bytes from start of Destination MAC address        */
+	0x00000000,	/* No significance of CRC for Filter0 and Filter1     */
+	0xBDCC0000	/* No significance of CRC for Filter2,
+			   Filter3 CRC is 0xBDCC                              */
+};
+
+uint32_t nss_gmac_wakeup_filter_config1[] = {
+	0x00000000,	/* For Filter0 CRC is not computed may be it is 0x0000*/
+	0x00000000,	/* For Filter1 CRC is not computed may be it is 0x0000*/
+	0x7A7A7A7A,	/* For Filter2 CRC is based on 1,3,4,5,6,9,11,12,13,14,
+			   17,19,20,21,25,27,28,29,30 bytes from offset       */
+	0x00000000,	/* For Filter3 CRC is not computed may be it is 0x0000*/
+	0x00010000,	/* Filter 0,1,3 are disabled, Filter2 is enabled and
+			   filtering applies to only unicast packets          */
+	0x00100000,	/* Filter 0,1,3 (no significance), filter 2 offset is 16
+			   bytes from start of Destination MAC address        */
+	0x00000000,	/* No significance of CRC for Filter0 and Filter1     */
+	0x0000A0FE	/* No significance of CRC for Filter3,
+			   Filter2 CRC is 0xA0FE                              */
+};
+
+uint32_t nss_gmac_wakeup_filter_config2[] = {
+	0x00000000,	/* For Filter0 CRC is not computed may be it is 0x0000*/
+	0x000000FF,	/* For Filter1 CRC is computed on 0,1,2,3,4,5,6,7
+			   bytes from offset                                  */
+	0x00000000,	/* For Filter2 CRC is not computed may be it is 0x0000*/
+	0x00000000,	/* For Filter3 CRC is not computed may be it is 0x0000*/
+	0x00000100,	/* Filter 0,2,3 are disabled, Filter 1 is enabled and
+			   filtering applies to only unicast packets          */
+	0x0000DF00,	/* Filter 0,2,3 (no significance), filter 1 offset is
+			   223 bytes from start of Destination MAC address    */
+	0xDB9E0000,	/* No significance of CRC for Filter0,
+			   Filter1 CRC is 0xDB9E                              */
+	0x00000000	/* No significance of CRC for Filter2 and Filter3     */
+};
+
+/**
+ * The nss_gmac_wakeup_filter_config3[] is a sample configuration for wake up
+ * filter.
+ * Filter1 is used here
+ * Filter1 offset is programmed to 50 (0x32)
+ * Filter1 mask is set to 0x000000FF, indicating First 8 bytes are used by the
+ * filter
+ * Filter1 CRC= 0x7EED this is the CRC computed on data 0x55 0x55 0x55 0x55 0x55
+ *  0x55 0x55 0x55
+ *
+ * Refer accompanied software DWC_gmac_crc_example.c for CRC16 generation and
+ * how to use the same.
+ */
+uint32_t nss_gmac_wakeup_filter_config3[] = {
+	0x00000000,	/* For Filter0 CRC is not computed may be it is 0x0000*/
+	0x000000FF,	/* For Filter1 CRC is computed on 0,1,2,3,4,5,6,7
+			   bytes from offset                                  */
+	0x00000000,	/* For Filter2 CRC is not computed may be it is 0x0000*/
+	0x00000000,	/* For Filter3 CRC is not computed may be it is 0x0000*/
+	0x00000100,	/* Filter 0,2,3 are disabled, Filter 1 is enabled and
+			   filtering applies to only unicast packets          */
+	0x00003200,	/* Filter 0,2,3 (no significance), filter 1 offset is 50
+			   bytes from start of Destination MAC address        */
+	0x7eED0000,	/* No significance of CRC for Filter0,
+			   Filter1 CRC is 0x7EED,                             */
+	0x00000000	/* No significance of CRC for Filter2 and Filter3     */
+};
+
+/**
+ * This gives up the receive Descriptor queue in ring or chain mode.
+ * This function is tightly coupled to the platform and operating system
+ * Once device's Dma is stopped the memory descriptor memory and the buffer
+ * memory deallocation, is completely handled by the operating system,
+ * this call is kept outside the device driver Api. This function should be
+ * treated as an example code to de-allocate the descriptor structures in ring
+ * mode or chain mode and network buffer deallocation. This function depends on
+ * the device structure for dma-able memory deallocation for both descriptor
+ * memory and the network buffer memory under linux.
+ * The responsibility of this function is to
+ *  - Free the network buffer memory if any.
+ *	- Fee the memory allocated for the descriptors.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] pointer to device structure.
+ * @param[in] number of descriptor expected in rx descriptor queue.
+ * @param[in] whether descriptors to be created in RING mode or CHAIN mode.
+ * @return 0 upon success. Error code upon failure.
+ * @note No referece should be made to descriptors once this function is called.
+ * This function is invoked when the device is closed.
+ */
+static void nss_gmac_giveup_rx_desc_queue(struct nss_gmac_dev *gmacdev,
+				struct device *dev,
+				uint32_t desc_mode) __attribute__((unused));
+static void nss_gmac_giveup_rx_desc_queue(struct nss_gmac_dev *gmacdev,
+				struct device *dev,
+				uint32_t desc_mode)
+{
+	int32_t i;
+	uint32_t status;
+	dma_addr_t dma_addr1;
+	uint32_t length1;
+	uint32_t data1;
+
+	for (i = 0; i < gmacdev->rx_desc_count; i++) {
+		nss_gmac_get_desc_data(gmacdev->rx_desc + i, &status,
+				       &dma_addr1, &length1, &data1);
+
+		if ((length1 != 0) && (data1 != 0)) {
+			dma_unmap_single(dev, (dma_addr_t)dma_addr1,
+					 length1, DMA_FROM_DEVICE);
+			dev_kfree_skb_any((struct sk_buff *)data1);
+		}
+	}
+
+	dma_free_coherent(dev, (sizeof(struct dma_desc) * gmacdev->rx_desc_count)
+			 , gmacdev->rx_desc, gmacdev->rx_desc_dma);
+
+	netdev_dbg(gmacdev->netdev, "Memory allocated %08x for Rx Descriptors (ring) is given back"
+						, (uint32_t)gmacdev->rx_desc);
+
+	gmacdev->rx_desc = NULL;
+	gmacdev->rx_desc_dma = 0;
+}
+
+
+/**
+ * This gives up the transmit Descriptor queue in ring or chain mode.
+ * This function is tightly coupled to the platform and operating system
+ * Once device's Dma is stopped the memory descriptor memory and the buffer
+ * memory deallocation, is completely handled by the operating system, this
+ * call is kept outside the device driver Api. This function should be treated
+ * as an example code to de-allocate the descriptor structures in ring mode or
+ * chain mode and network buffer deallocation. This function depends on the
+ * device structure for dma-able memory deallocation for both descriptor memory
+ * and the network buffer memory under linux.
+ * The responsibility of this function is to
+ *  - Free the network buffer memory if any.
+ *	- Fee the memory allocated for the descriptors.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] pointer to device structure.
+ * @param[in] number of descriptor expected in tx descriptor queue.
+ * @param[in] whether descriptors to be created in RING mode or CHAIN mode.
+ * @return 0 upon success. Error code upon failure.
+ * @note No reference should be made to descriptors once this function is called
+ * This function is invoked when the device is closed.
+ */
+static void nss_gmac_giveup_tx_desc_queue(struct nss_gmac_dev *gmacdev,
+				  struct device *dev,
+				  uint32_t desc_mode) __attribute__((unused));
+static void nss_gmac_giveup_tx_desc_queue(struct nss_gmac_dev *gmacdev,
+				  struct device *dev,
+				  uint32_t desc_mode)
+{
+	int32_t i;
+	uint32_t status;
+	dma_addr_t dma_addr1;
+	uint32_t length1;
+	uint32_t data1;
+
+	for (i = 0; i < gmacdev->tx_desc_count; i++) {
+		nss_gmac_get_desc_data(gmacdev->tx_desc + i, &status,
+				       &dma_addr1, &length1, &data1);
+
+		if ((length1 != 0) && (data1 != 0)) {
+			dma_unmap_single(dev, (dma_addr_t)dma_addr1, length1,
+					 DMA_TO_DEVICE);
+			dev_kfree_skb_any((struct sk_buff *)data1);
+		}
+	}
+
+	dma_free_coherent(dev, (sizeof(struct dma_desc) * gmacdev->tx_desc_count),
+			  gmacdev->tx_desc, gmacdev->tx_desc_dma);
+
+	netdev_dbg(gmacdev->netdev, "Memory allocated %08x for Tx Descriptors (ring) is given back"
+						, (uint32_t)gmacdev->tx_desc);
+
+	gmacdev->tx_desc = NULL;
+	gmacdev->tx_desc_dma = 0;
+}
+
+
+/**
+ * @brief Initialize tx/rx descriptors
+ * @param[in] pointer to nss_gmac_dev
+ * @return void
+ */
+void nss_gmac_tx_rx_desc_init(struct nss_gmac_dev *gmacdev)
+{
+	int32_t i;
+
+	/* Init Tx/Rx descriptor rings */
+	for (i = 0; i < gmacdev->tx_desc_count; i++) {
+		nss_gmac_tx_desc_init_ring(gmacdev->tx_desc + i,
+					   i == (gmacdev->tx_desc_count - 1));
+	}
+
+	for (i = 0; i < gmacdev->rx_desc_count; i++) {
+		nss_gmac_rx_desc_init_ring(gmacdev->rx_desc + i,
+					   i == (gmacdev->rx_desc_count - 1));
+	}
+
+	/* Init Tx/Rx counters in device private structure */
+	gmacdev->tx_next = 0;
+	gmacdev->tx_busy = 0;
+	gmacdev->tx_next_desc = gmacdev->tx_desc;
+	gmacdev->tx_busy_desc = gmacdev->tx_desc;
+	gmacdev->busy_tx_desc = 0;
+	gmacdev->rx_next = 0;
+	gmacdev->rx_busy = 0;
+	gmacdev->rx_next_desc = gmacdev->rx_desc;
+	gmacdev->rx_busy_desc = gmacdev->rx_desc;
+	gmacdev->busy_rx_desc = 0;
+
+	/* take Tx/Rx desc ownership */
+	nss_gmac_take_desc_ownership_rx(gmacdev);
+	nss_gmac_take_desc_ownership_tx(gmacdev);
+}
+
+
+/**
+ * @brief Function provides the network interface statistics.
+ * Function is registered to linux get_stats() function. This function is
+ * called whenever ifconfig (in Linux) asks for networkig statistics
+ * (for example "ifconfig eth0").
+ * @param[in] pointer to net_device structure.
+ * @param[in] pointer to net_device_stats64 structure.
+ * @return Returns pointer to net_device_stats64 structure.
+ */
+struct rtnl_link_stats64 *nss_gmac_linux_get_stats64(struct net_device *netdev,
+						struct rtnl_link_stats64 *stats)
+{
+	struct nss_gmac_dev *gmacdev = NULL;
+
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	BUG_ON(gmacdev == NULL);
+
+	spin_lock_bh(&gmacdev->stats_lock);
+	memcpy(stats, &gmacdev->stats, sizeof(*stats));
+	spin_unlock_bh(&gmacdev->stats_lock);
+
+	return stats;
+}
+
+
+/**
+ * @brief Function to set ethernet address of the NIC.
+ * @param[in] pointer to net_device structure.
+ * @param[in] pointer to an address structure.
+ * @return Returns 0 on success Error code on failure.
+ */
+static int32_t nss_gmac_linux_set_mac_address(struct net_device *netdev,
+					      void *macaddr)
+{
+	struct nss_gmac_dev *gmacdev = NULL;
+	struct sockaddr *addr = (struct sockaddr *)macaddr;
+
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	BUG_ON(gmacdev == NULL);
+	BUG_ON(gmacdev->netdev != netdev);
+
+	netdev_dbg(netdev, "%s: AddrFamily: %d, %0x:%0x:%0x:%0x:%0x:%0x",
+		      __func__, addr->sa_family, addr->sa_data[0],
+		      addr->sa_data[1], addr->sa_data[2], addr->sa_data[3],
+		      addr->sa_data[4], addr->sa_data[5]);
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	nss_gmac_set_mac_addr(gmacdev, gmac_addr0_high, gmac_addr0_low,
+			      addr->sa_data);
+	nss_gmac_get_mac_addr(gmacdev, gmac_addr0_high, gmac_addr0_low,
+			      netdev->dev_addr);
+
+	return 0;
+}
+
+
+/**
+ * @brief IOCTL interface.
+ * This function is mainly for debugging purpose.
+ * This provides hooks for Register read write, Retrieve descriptor status
+ * and Retreiving Device structure information.
+ * @param[in] pointer to net_device structure.
+ * @param[in] pointer to ifreq structure.
+ * @param[in] ioctl command.
+ * @return Returns 0 on success Error code on failure.
+ */
+static int32_t nss_gmac_linux_do_ioctl(struct net_device *netdev,
+				       struct ifreq *ifr, int32_t cmd)
+{
+	int32_t retval;
+	struct nss_gmac_dev *gmacdev = NULL;
+	struct mii_ioctl_data *mii_data = if_mii(ifr);
+
+	struct ifr_data_struct {
+		uint32_t unit;
+		uint32_t addr;
+		uint32_t data;
+	} *req;
+
+	if (netdev == NULL)
+		return -EINVAL;
+	if (ifr == NULL)
+		return -EINVAL;
+
+	req = (struct ifr_data_struct *)ifr->ifr_data;
+
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	BUG_ON(gmacdev == NULL);
+	BUG_ON(gmacdev->netdev != netdev);
+
+	netdev_dbg(netdev, "%s :: on device %s req->unit = %08x req->addr = %08x req->data = %08x cmd = %08x"
+		, __func__, netdev->name, req->unit, req->addr, req->data, cmd);
+
+	retval = 0;
+	switch (cmd) {
+	case SIOCGMIIPHY:
+		netdev_dbg(netdev, "SIOCGMIIPHY: ");
+		mii_data->phy_id = gmacdev->phy_base;
+		break;
+
+	case SIOCSMIIREG:
+		netdev_dbg(netdev, "SIOCSMIIREG: ");
+		nss_gmac_mii_wr_reg(gmacdev, gmacdev->phy_base,
+			      (mii_data->reg_num & 0x1F), mii_data->val_in);
+		break;
+
+	case SIOCGMIIREG:
+		netdev_dbg(netdev, "SIOCGMIIREG: ");
+		mii_data->val_out = nss_gmac_mii_rd_reg(gmacdev,
+						 gmacdev->phy_base,
+						 (mii_data->reg_num & 0x1F));
+		break;
+
+	default:
+		retval = -EINVAL;
+		netdev_dbg(netdev, "Unsupported ioctl");
+		break;
+	}
+
+	return retval;
+}
+
+
+/**
+ * The set_rx_mode entry point is called whenever the unicast or multicast
+ * address lists or the network interface flags are updated. This routine is
+ * responsible for configuring the hardware for proper unicast, multicast,
+ * promiscuous mode, and all-multi behavior.
+ * @param[in] pointer to net_device structure.
+ * @return Returns void.
+ */
+static void nss_gmac_linux_set_rx_mode(struct net_device *netdev)
+{
+	struct nss_gmac_dev *gmacdev = NULL;
+
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	BUG_ON(gmacdev == NULL);
+
+	netdev_dbg(netdev, "%s: flags - 0x%x", __func__, netdev->flags);
+
+	/* Check for Promiscuous and All Multicast modes */
+	if (netdev->flags & IFF_PROMISC) {
+		nss_gmac_promisc_enable(gmacdev);
+	} else {
+		nss_gmac_promisc_disable(gmacdev);
+
+		if (netdev->flags & IFF_ALLMULTI)
+			nss_gmac_multicast_enable(gmacdev);
+		else
+			nss_gmac_multicast_disable(gmacdev);
+	}
+}
+
+
+/**
+ * @brief Enable/Disable the requested features.
+ * @param[in] pointer to net_device structure.
+ * @param[in] net_device features
+ * @return Returns 0 on success Error code on failure.
+ */
+static int32_t nss_gmac_set_features(struct net_device *netdev,
+					       netdev_features_t features)
+{
+	struct nss_gmac_dev *gmacdev = NULL;
+	netdev_features_t changed;
+
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	BUG_ON(gmacdev == NULL);
+
+	changed = features ^ netdev->features;
+	if (!(changed & (NETIF_F_RXCSUM | NETIF_F_HW_CSUM | NETIF_F_GRO)))
+		return 0;
+
+	if (changed & NETIF_F_RXCSUM) {
+		if (features & NETIF_F_RXCSUM)
+			test_and_set_bit(__NSS_GMAC_RXCSUM, &gmacdev->flags);
+		else
+			test_and_clear_bit(__NSS_GMAC_RXCSUM, &gmacdev->flags);
+		nss_gmac_ipc_offload_init(gmacdev);
+	}
+
+	if (changed & NETIF_F_GRO) {
+		if (!(features & NETIF_F_GRO)) {
+#if (LINUX_VERSION_CODE <= KERNEL_VERSION(3, 6, 0))
+			napi_gro_flush(&gmacdev->napi);
+#else
+			napi_gro_flush(&gmacdev->napi, false);
+#endif
+		}
+	}
+
+	return 0;
+}
+
+
+/**
+ * Netdevice operations
+ */
+static const struct net_device_ops nss_gmac_netdev_ops = {
+	.ndo_open = &nss_gmac_linux_open,
+	.ndo_stop = &nss_gmac_linux_close,
+	.ndo_start_xmit = &nss_gmac_linux_xmit_frames,
+	.ndo_get_stats64 = &nss_gmac_linux_get_stats64,
+	.ndo_set_mac_address = &nss_gmac_linux_set_mac_address,
+	.ndo_validate_addr = &eth_validate_addr,
+	.ndo_change_mtu = &nss_gmac_linux_change_mtu,
+	.ndo_do_ioctl = &nss_gmac_linux_do_ioctl,
+	.ndo_tx_timeout = &nss_gmac_linux_tx_timeout,
+	.ndo_set_rx_mode = &nss_gmac_linux_set_rx_mode,
+	.ndo_set_features = &nss_gmac_set_features,
+};
+
+/**
+ * @brief Update list of supported, advertised features
+ * @param[in] pointer to supported features
+ * @param[in] pointer to advertised features
+ * @return void
+ */
+static void nss_gmac_update_features(uint32_t *supp, uint32_t *adv)
+{
+	*supp &= NSS_GMAC_SUPPORTED_FEATURES;
+	*adv &= NSS_GMAC_ADVERTISED_FEATURES;
+}
+
+
+/**
+ * @brief PHY fixup
+ * @param[in] pointer to PHY device
+ * @return 0 on Success
+ */
+static int32_t nss_gmac_phy_fixup(struct phy_device *phydev)
+{
+	int32_t ret = 0;
+
+	/* Disable QCA Smart 802.3az in PHY */
+	if (nss_gmac_ath_phy_disable_smart_802az(phydev) != 0)
+		ret = -EFAULT;
+
+	/* Disable IEEE 802.3az in PHY */
+	if (nss_gmac_ath_phy_disable_802az(phydev) != 0)
+		ret = -EFAULT;
+
+	return ret;
+}
+
+#ifdef CONFIG_OF
+/**
+ * @brief Get device data via device tree node
+ * @param[in] np pointer to device tree node
+ * @param[in] netdev pointer to net_device
+ * @param[out] netdev pointer to gmac configuration data
+ * @return 0 on Success
+ */
+static int32_t nss_gmac_of_get_pdata(struct device_node *np,
+				     struct net_device *netdev,
+				     struct msm_nss_gmac_platform_data *gmaccfg)
+{
+	uint8_t *maddr = NULL;
+	struct nss_gmac_dev *gmacdev = NULL;
+	struct resource memres_devtree = {0};
+
+	gmacdev = netdev_priv(netdev);
+
+	if (of_property_read_u32(np, "qcom,id", &gmacdev->macid)
+		|| of_property_read_u32(np, "qcom,emulation", &gmaccfg->emulation)
+		|| of_property_read_u32(np, "qcom,phy_mii_type", &gmaccfg->phy_mii_type)
+		|| of_property_read_u32(np, "qcom,phy_mdio_addr", &gmaccfg->phy_mdio_addr)
+		|| of_property_read_u32(np, "qcom,rgmii_delay", &gmaccfg->rgmii_delay)
+		|| of_property_read_u32(np, "qcom,poll_required", &gmaccfg->poll_required)
+		|| of_property_read_u32(np, "qcom,forced_speed", &gmaccfg->forced_speed)
+		|| of_property_read_u32(np, "qcom,forced_duplex", &gmaccfg->forced_duplex)
+		|| of_property_read_u32(np, "qcom,irq", &netdev->irq)
+		|| of_property_read_u32(np, "qcom,socver", &gmaccfg->socver)) {
+		pr_err("%s: error reading critical device node properties\n", np->name);
+		return -EFAULT;
+	}
+
+	maddr = (uint8_t *)of_get_mac_address(np);
+	if (maddr)
+		memcpy(gmaccfg->mac_addr, maddr, ETH_ALEN);
+
+	if (of_address_to_resource(np, 0, &memres_devtree) != 0)
+		return -EFAULT;
+
+	netdev->base_addr = memres_devtree.start;
+
+	return 0;
+}
+#endif
+
+/**
+ * @brief Do GMAC driver common initialization.
+ * @param[in] pdev pointer to platform_device
+ * @return 0 on Success
+ */
+static int32_t nss_gmac_do_common_init(struct platform_device *pdev)
+{
+	int32_t ret = -EFAULT;
+	struct resource res_nss_base = {0};
+	struct resource res_qsgmii_base = {0};
+	struct resource res_clk_ctl_base = {0};
+
+#ifdef CONFIG_OF
+	struct device_node *common_device_node = NULL;
+	/*
+	 * Device tree based common init.
+	 */
+	common_device_node = of_find_node_by_name(NULL, NSS_GMAC_COMMON_DEVICE_NODE);
+	if (!common_device_node) {
+		pr_info("Cannot find device tree node "NSS_GMAC_COMMON_DEVICE_NODE);
+		ret = -EFAULT;
+		goto nss_gmac_cmn_init_fail;
+	}
+	if (of_address_to_resource(common_device_node, 0, &res_nss_base) != 0) {
+		ret = -EFAULT;
+		goto nss_gmac_cmn_init_fail;
+	}
+	if (of_address_to_resource(common_device_node, 1, &res_qsgmii_base) != 0) {
+		ret = -EFAULT;
+		goto nss_gmac_cmn_init_fail;
+	}
+	if (of_address_to_resource(common_device_node, 2, &res_clk_ctl_base) != 0) {
+		ret = -EFAULT;
+		goto nss_gmac_cmn_init_fail;
+	}
+#else
+	res_nss_base.start = NSS_REG_BASE;
+	res_nss_base.end = NSS_REG_BASE + NSS_REG_LEN - 1;
+	res_nss_base.flags = IORESOURCE_MEM;
+
+	res_qsgmii_base.start = QSGMII_REG_BASE;
+	res_qsgmii_base.end =  QSGMII_REG_BASE + QSGMII_REG_LEN - 1;
+	res_qsgmii_base.flags = IORESOURCE_MEM;
+
+	res_clk_ctl_base.start = IPQ806X_CLK_CTL_PHYS;
+	res_clk_ctl_base.end = IPQ806X_CLK_CTL_PHYS + IPQ806X_CLK_CTL_SIZE - 1;
+	res_clk_ctl_base.flags = IORESOURCE_MEM;
+#endif
+
+	ctx.nss_base = (uint8_t *)ioremap_nocache(res_nss_base.start,
+						  resource_size(&res_nss_base));
+	if (!ctx.nss_base) {
+		pr_info("Error mapping NSS GMAC registers");
+		ret = -EIO;
+		goto nss_gmac_cmn_init_fail;
+	}
+	pr_debug("%s: NSS base ioremap OK.", __func__);
+
+	ctx.qsgmii_base = (uint32_t *)ioremap_nocache(res_qsgmii_base.start,
+					      resource_size(&res_qsgmii_base));
+	if (!ctx.qsgmii_base) {
+		pr_info("Error mapping QSGMII registers");
+		ret = -EIO;
+		goto nss_gmac_qsgmii_map_err;
+	}
+	pr_debug("%s: QSGMII base ioremap OK, vaddr = 0x%p",
+						__func__, ctx.qsgmii_base);
+
+	ctx.clk_ctl_base = (uint32_t *)ioremap_nocache(res_clk_ctl_base.start,
+				       resource_size(&res_clk_ctl_base));
+	if (!ctx.clk_ctl_base) {
+		pr_info("Error mapping Clk control registers");
+		ret = -EIO;
+		goto nss_gmac_clkctl_map_err;
+	}
+	pr_debug("%s: Clk control base ioremap OK, vaddr = 0x%p", __func__,
+							ctx.clk_ctl_base);
+
+	if (nss_gmac_common_init(&ctx) == 0) {
+		ret = 0;
+		ctx.common_init_done = true;
+		goto nss_gmac_cmn_init_ok;
+	}
+
+nss_gmac_clkctl_map_err:
+	iounmap(ctx.qsgmii_base);
+	ctx.qsgmii_base = NULL;
+
+nss_gmac_qsgmii_map_err:
+	iounmap(ctx.nss_base);
+	ctx.nss_base = NULL;
+
+nss_gmac_cmn_init_fail:
+	pr_info("%s: platform init fail\n", __func__);
+
+nss_gmac_cmn_init_ok:
+#ifdef CONFIG_OF
+	if (common_device_node) {
+		of_node_put(common_device_node);
+		common_device_node = NULL;
+	}
+#endif
+	return ret;
+}
+
+
+/**
+ * @brief Function to initialize the Linux network interface.
+ * Linux dependent Network interface is setup here. This provides
+ * an example to handle the network dependent functionality.
+ * @param[in] pointer to struct platform_device
+ * @return Returns 0 on success and Error code on failure.
+ */
+static int32_t nss_gmac_probe(struct platform_device *pdev)
+{
+	struct net_device *netdev = NULL;
+	struct msm_nss_gmac_platform_data *gmaccfg = NULL;
+	struct nss_gmac_dev *gmacdev = NULL;
+	int32_t ret = 0;
+	phy_interface_t phyif = 0;
+	uint8_t phy_id[MII_BUS_ID_SIZE + 3];
+
+	if (ctx.common_init_done == false) {
+		ret = nss_gmac_do_common_init(pdev);
+		if (ret != 0)
+			return ret;
+	}
+
+	/*
+	 * Lets allocate and set up an ethernet device, it takes the sizeof
+	 * the private structure. This is mandatory as a 32 byte allignment
+	 * is required for the private data structure.
+	 */
+	netdev = alloc_etherdev(sizeof(struct nss_gmac_dev));
+	if (!netdev) {
+		pr_info("%s: alloc_etherdev() failed", __func__);
+		return -ENOMEM;
+	}
+
+	gmacdev = netdev_priv(netdev);
+	memset((void *)gmacdev, 0, sizeof(struct nss_gmac_dev));
+
+	spin_lock_init(&gmacdev->stats_lock);
+	spin_lock_init(&gmacdev->slock);
+	mutex_init(&gmacdev->link_mutex);
+
+	gmacdev->pdev = pdev;
+	gmacdev->netdev = netdev;
+	gmacdev->loop_back_mode = NOLOOPBACK;
+
+#ifdef CONFIG_OF
+	struct msm_nss_gmac_platform_data gmaccfg_devicetree;
+	struct device_node *np = NULL;
+
+	np = of_node_get(pdev->dev.of_node);
+	ret = nss_gmac_of_get_pdata(np, netdev, &gmaccfg_devicetree);
+	if (ret != 0) {
+		free_netdev(netdev);
+		return ret;
+	}
+
+	gmaccfg = &gmaccfg_devicetree;
+#else
+	gmaccfg = (struct msm_nss_gmac_platform_data *)((pdev->dev).platform_data);
+
+	netdev->base_addr = pdev->resource[0].start;
+	netdev->irq = pdev->resource[1].start;
+	gmacdev->macid = pdev->id;
+#endif
+	gmacdev->emulation = gmaccfg->emulation;
+	gmacdev->phy_mii_type = gmaccfg->phy_mii_type;
+	gmacdev->phy_base = gmaccfg->phy_mdio_addr;
+	gmacdev->rgmii_delay = gmaccfg->rgmii_delay;
+
+	if (ctx.socver == 0)
+		ctx.socver = gmaccfg->socver;
+
+	if (gmaccfg->poll_required)
+		test_and_set_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags);
+
+	switch (gmaccfg->forced_speed) {
+	case SPEED_10:
+		gmacdev->forced_speed = SPEED10;
+		break;
+
+	case SPEED_100:
+		gmacdev->forced_speed = SPEED100;
+		break;
+
+	case SPEED_1000:
+		gmacdev->forced_speed = SPEED1000;
+		break;
+
+	default:
+		gmacdev->forced_speed = SPEED_UNKNOWN;
+		break;
+	}
+
+	switch (gmaccfg->forced_duplex) {
+	case DUPLEX_HALF:
+		gmacdev->forced_duplex = HALFDUPLEX;
+		break;
+
+	case DUPLEX_FULL:
+		gmacdev->forced_duplex = FULLDUPLEX;
+		break;
+
+	default:
+		gmacdev->forced_duplex = DUPLEX_UNKNOWN;
+		break;
+	}
+
+	/* save global context within each GMAC context */
+	gmacdev->ctx = &ctx;
+
+	ctx.nss_gmac[gmacdev->macid] = gmacdev;
+
+	/* Init for individual GMACs */
+	nss_gmac_dev_init(gmacdev);
+
+	if (nss_gmac_attach(gmacdev, netdev->base_addr,
+			    pdev->resource[0].end - pdev->resource[0].start +
+			    1) < 0) {
+		netdev_dbg(netdev, "attach failed for %s", netdev->name);
+		ret = -EIO;
+		goto nss_gmac_attach_fail;
+	}
+
+	if (gmacdev->emulation == 0) {
+#ifdef CONFIG_OF
+		const __be32 *prop = NULL;
+		struct device_node *mdio_node = NULL;
+		struct platform_device *mdio_plat = NULL;
+
+		prop = of_get_property(np, "mdiobus", NULL);
+		if (!prop) {
+			netdev_dbg(netdev, "cannot get 'mdiobus' property");
+			ret = -EIO;
+			goto mdiobus_init_fail;
+		}
+
+		mdio_node = of_find_node_by_phandle(be32_to_cpup(prop));
+		if (!mdio_node) {
+			netdev_dbg(netdev, "cannot find mdio node by phandle");
+			ret = -EIO;
+			goto mdiobus_init_fail;
+		}
+
+		mdio_plat = of_find_device_by_node(mdio_node);
+		if (!mdio_plat) {
+			netdev_dbg(netdev, "cannot find platform device from mdio node");
+			of_node_put(mdio_node);
+			ret = -EIO;
+			goto mdiobus_init_fail;
+		}
+
+		gmacdev->miibus = dev_get_drvdata(&mdio_plat->dev);
+		if (!gmacdev->miibus) {
+			netdev_dbg(netdev, "cannot get mii bus reference from device data");
+			of_node_put(mdio_node);
+			ret = -EIO;
+			goto mdiobus_init_fail;
+		}
+#else
+		struct device *miidev;
+		uint8_t busid[MII_BUS_ID_SIZE];
+
+		snprintf(busid, MII_BUS_ID_SIZE, "%s.%d", IPQ806X_MDIO_BUS_NAME,
+							IPQ806X_MDIO_BUS_NUM);
+
+		miidev = bus_find_device_by_name(&platform_bus_type, NULL, busid);
+		if (!miidev) {
+			netdev_dbg(netdev, "mdio bus '%s' get FAIL.", busid);
+			ret = -EIO;
+			goto mdiobus_init_fail;
+		}
+
+		gmacdev->miibus = dev_get_drvdata(miidev);
+		if (!gmacdev->miibus) {
+			netdev_dbg(netdev, "mdio bus '%s' get FAIL.", busid);
+			ret = -EIO;
+			goto mdiobus_init_fail;
+		}
+#endif
+
+		netdev_dbg(netdev, "mdio bus '%s' OK.", gmacdev->miibus->id);
+
+	} else if (gmacdev->emulation && (gmacdev->phy_mii_type == GMAC_INTF_RGMII)) {
+		if (nss_gmac_init_mdiobus(gmacdev) != 0) {
+			netdev_dbg(netdev, "mdio bus register FAIL for emulation.");
+			ret = -EIO;
+			goto mdiobus_init_fail;
+		}
+		netdev_dbg(netdev, "mdio bus '%s' register OK for emulation.",
+							gmacdev->miibus->id);
+	}
+
+	/*
+	 * This just fill in some default MAC address
+	 */
+	if (is_valid_ether_addr(gmaccfg->mac_addr)) {
+		memcpy(netdev->dev_addr, &gmaccfg->mac_addr, ETH_ALEN);
+	} else {
+		random_ether_addr(netdev->dev_addr);
+		pr_info("GMAC%d(%p) Invalid MAC@ - using %02x:%02x:%02x:%02x:%02x:%02x",
+			gmacdev->macid, gmacdev,
+			*netdev->dev_addr, *netdev->dev_addr+1,
+			*netdev->dev_addr+2, *netdev->dev_addr+3,
+			*netdev->dev_addr+4, *netdev->dev_addr+5);
+	}
+
+	netdev->watchdog_timeo = 5 * HZ;
+	netdev->netdev_ops = &nss_gmac_netdev_ops;
+	nss_gmac_ethtool_register(netdev);
+
+	/* Initialize workqueue */
+	INIT_DELAYED_WORK(&gmacdev->gmacwork, nss_gmac_open_work);
+
+	switch (gmacdev->phy_mii_type) {
+	case GMAC_INTF_RGMII:
+		phyif = PHY_INTERFACE_MODE_RGMII;
+		break;
+
+	case GMAC_INTF_SGMII:
+		phyif = PHY_INTERFACE_MODE_SGMII;
+		break;
+
+	case GMAC_INTF_QSGMII:
+		phyif = PHY_INTERFACE_MODE_SGMII;
+		break;
+	}
+
+	/* create a phyid using MDIO bus id and MDIO bus address of phy */
+	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT,
+		 gmacdev->miibus->id, gmacdev->phy_base);
+
+	/* register PHY fixup */
+	if (gmacdev->phy_base != NSS_GMAC_NO_MDIO_PHY) {
+		ret = phy_register_fixup((const char *)phy_id,
+				NSS_GMAC_PHY_FIXUP_UID,
+				NSS_GMAC_PHY_FIXUP_MASK,
+				&nss_gmac_phy_fixup);
+		if (ret	!= 0) {
+			netdev_dbg(netdev, "PHY fixup register Error.");
+			goto nss_gmac_phy_attach_fail;
+		}
+	}
+
+	/* connect PHY */
+	if (test_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags)) {
+#if (LINUX_VERSION_CODE <= KERNEL_VERSION(3, 8, 0))
+		gmacdev->phydev = phy_connect(netdev, (const char *)phy_id,
+					      &nss_gmac_adjust_link, 0, phyif);
+#else
+		gmacdev->phydev = phy_connect(netdev, (const char *)phy_id,
+					      &nss_gmac_adjust_link, phyif);
+#endif
+
+		if (IS_ERR_OR_NULL(gmacdev->phydev)) {
+			netdev_dbg(netdev, "PHY %s attach FAIL", phy_id);
+			ret = -EIO;
+			goto nss_gmac_phy_attach_fail;
+		}
+
+		nss_gmac_update_features(&(gmacdev->phydev->supported),
+					&(gmacdev->phydev->advertising));
+		gmacdev->phydev->irq = PHY_POLL;
+		netdev_dbg(netdev, "PHY %s attach OK", phy_id);
+
+		/* reset corresponding Phy */
+		nss_gmac_reset_phy(gmacdev, gmacdev->phy_base);
+
+		if (gmacdev->phy_mii_type == GMAC_INTF_RGMII) {
+			/* RGMII Tx delay */
+			netdev_dbg(netdev, "%s: Program RGMII Tx delay..... ", __func__);
+			mdiobus_write(gmacdev->miibus, gmacdev->phy_base, 0x1D, 0x05);
+			mdiobus_write(gmacdev->miibus, gmacdev->phy_base, 0x1E, 0x100);
+			mdiobus_write(gmacdev->miibus, gmacdev->phy_base, 0x1D, 0x0B);
+			mdiobus_write(gmacdev->miibus, gmacdev->phy_base, 0x1E, 0xBC20);
+		}
+
+		/* XXX: Test code to verify if MDIO access is OK. Remove after
+		 * bringup. */
+		netdev_dbg(netdev, "%s MII_PHYSID1 - 0x%04x", netdev->name,
+		      nss_gmac_mii_rd_reg(gmacdev, gmacdev->phy_base, MII_PHYSID1));
+		netdev_dbg(netdev, "%s MII_PHYSID2 - 0x%04x", netdev->name,
+		      nss_gmac_mii_rd_reg(gmacdev, gmacdev->phy_base, MII_PHYSID2));
+	} else if (gmacdev->phy_base != NSS_GMAC_NO_MDIO_PHY) {
+		/*
+		 * Issue a phy_attach for the interface connected to a switch
+		 */
+#if (LINUX_VERSION_CODE <= KERNEL_VERSION(3, 8, 0))
+		gmacdev->phydev = phy_attach(netdev,
+						(const char *)phy_id, 0, phyif);
+#else
+		gmacdev->phydev = phy_attach(netdev,
+						(const char *)phy_id, phyif);
+#endif
+		if (IS_ERR_OR_NULL(gmacdev->phydev)) {
+			netdev_dbg(netdev, "PHY %s attach FAIL", phy_id);
+			ret = -EIO;
+			goto nss_gmac_phy_attach_fail;
+		}
+	}
+
+	test_and_set_bit(__NSS_GMAC_RXCSUM, &gmacdev->flags);
+	nss_gmac_ipc_offload_init(gmacdev);
+
+	/* Register the network interface */
+	if (register_netdev(netdev)) {
+		netdev_dbg(netdev, "Error registering netdevice %s",
+			      netdev->name);
+		ret = -EFAULT;
+		goto nss_gmac_reg_fail;
+	}
+
+	/* GRO disabled by default */
+	rtnl_lock();
+	netdev->features &= ~NETIF_F_GRO;
+	netdev->wanted_features &= ~NETIF_F_GRO;
+	netdev_change_features(netdev);
+	rtnl_unlock();
+
+	netdev_dbg(netdev, "Initialized NSS GMAC%d interface %s: (base = 0x%lx, irq = %d, PhyId = %d, PollLink = %d)"
+			, gmacdev->macid, netdev->name, netdev->base_addr
+			, netdev->irq, gmacdev->phy_base
+			, test_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags));
+
+#ifdef CONFIG_OF
+	if (pdev->dev.of_node) {
+		of_node_put(np);
+		np = NULL;
+	}
+#endif
+	return 0;
+
+nss_gmac_reg_fail:
+	unregister_netdev(gmacdev->netdev);
+
+	if (!IS_ERR_OR_NULL(gmacdev->phydev)) {
+		phy_disconnect(gmacdev->phydev);
+		gmacdev->phydev = NULL;
+	}
+
+nss_gmac_phy_attach_fail:
+	if (gmacdev->emulation)
+		nss_gmac_deinit_mdiobus(gmacdev);
+
+mdiobus_init_fail:
+	nss_gmac_detach(gmacdev);
+
+nss_gmac_attach_fail:
+	free_netdev(netdev);
+
+#ifdef CONFIG_OF
+	if (pdev->dev.of_node) {
+		of_node_put(np);
+		np = NULL;
+	}
+#endif
+	return ret;
+}
+
+
+/**
+ * @brief Remove Linux dependent Network interface.
+ * @param[in] pointer to struct platform_device
+ * @return Returns 0 on success and Error code on failure.
+ */
+static int nss_gmac_remove(struct platform_device *pdev)
+{
+	struct net_device *netdev = NULL;
+	struct nss_gmac_dev *gmacdev = NULL;
+
+	gmacdev = ctx.nss_gmac[pdev->id];
+	if (!gmacdev) {
+		pr_info("Invalid GMAC");
+		return -EINVAL;
+	}
+
+	netdev = gmacdev->netdev;
+
+	if (!IS_ERR_OR_NULL(gmacdev->phydev)) {
+		phy_disconnect(gmacdev->phydev);
+		gmacdev->phydev = NULL;
+	}
+
+	if (gmacdev->emulation)
+		nss_gmac_deinit_mdiobus(gmacdev);
+
+	nss_gmac_detach(gmacdev);
+	unregister_netdev(gmacdev->netdev);
+	free_netdev(gmacdev->netdev);
+	ctx.nss_gmac[pdev->id] = NULL;
+
+	return 0;
+}
+
+static struct of_device_id nss_gmac_dt_ids[] = {
+	{ .compatible =  "qcom,nss-gmac0" },
+	{ .compatible =  "qcom,nss-gmac1" },
+	{ .compatible =  "qcom,nss-gmac2" },
+	{ .compatible =  "qcom,nss-gmac3" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, nss_gmac_dt_ids);
+
+/**
+ * @brief Linux Platform driver for GMACs
+ */
+static struct platform_driver nss_gmac_drv = {
+	.probe = nss_gmac_probe,
+	.remove = nss_gmac_remove,
+	.driver = {
+		   .name = "nss-gmac",
+		   .owner = THIS_MODULE,
+#ifdef CONFIG_OF
+		   .of_match_table = of_match_ptr(nss_gmac_dt_ids),
+#endif
+		  },
+};
+
+
+/**
+ * @brief Register Linux platform driver.
+ * @return Returns 0 on success and -ve on failure.
+ */
+int32_t __init nss_gmac_register_driver(void)
+{
+	ctx.common_init_done = false;
+
+	ctx.gmac_workqueue =
+			create_singlethread_workqueue(NSS_GMAC_WORKQUEUE_NAME);
+	if (!ctx.gmac_workqueue) {
+		pr_info("%s: cannot create workqueue.\n",
+			     __func__);
+		goto link_state_wq_fail;
+	}
+
+	if (platform_driver_register(&nss_gmac_drv) != 0) {
+		pr_info("platform drv reg failure\n");
+		goto drv_register_fail;
+	}
+
+	return 0;
+
+drv_register_fail:
+	destroy_workqueue(ctx.gmac_workqueue);
+
+link_state_wq_fail:
+	return -EIO;
+}
+
+
+/**
+ * @brief De-register network interfaces.
+ * @return void
+ */
+void nss_gmac_exit_network_interfaces(void)
+{
+	uint32_t i;
+	struct nss_gmac_dev *gmacdev;
+
+	for (i = 0; i < NSS_MAX_GMACS; i++) {
+		gmacdev = ctx.nss_gmac[i];
+		if (gmacdev) {
+			unregister_netdev(gmacdev->netdev);
+			free_netdev(gmacdev->netdev);
+			nss_gmac_detach(gmacdev);
+			ctx.nss_gmac[i] = NULL;
+		}
+	}
+}
+
+
+/**
+ * @brief Deregister Linux platform driver.
+ */
+void __exit nss_gmac_deregister_driver(void)
+{
+	nss_gmac_exit_network_interfaces();
+	platform_driver_unregister(&nss_gmac_drv);
+
+	if (ctx.gmac_workqueue) {
+		destroy_workqueue(ctx.gmac_workqueue);
+		ctx.gmac_workqueue = NULL;
+	}
+
+	nss_gmac_common_deinit(&ctx);
+}
+
+
+/**
+ * @brief Module Init
+ */
+int __init nss_gmac_host_interface_init(void)
+{
+	pr_info("**********************************************************");
+	pr_info("* Driver    :%s", nss_gmac_driver_string);
+	pr_info("* Version   :%s", nss_gmac_driver_version);
+	pr_info("* Copyright :%s", nss_gmac_copyright);
+	pr_info("**********************************************************");
+
+	/* Initialize the Network dependent services */
+	if (nss_gmac_register_driver() != 0)
+		return -EFAULT;
+
+	return 0;
+}
+
+
+/**
+ * @brief Module Exit
+ */
+void __exit nss_gmac_host_interface_exit(void)
+{
+	nss_gmac_deregister_driver();
+}
+
+module_init(nss_gmac_host_interface_init);
+module_exit(nss_gmac_host_interface_exit);
+
+MODULE_AUTHOR("Qualcomm Atheros");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("NSS GMAC Network Driver");
+
diff --git a/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_dev.c b/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_dev.c
new file mode 100644
index 0000000..0b3ad77
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_dev.c
@@ -0,0 +1,1963 @@
+/*
+ **************************************************************************
+ * Copyright (c) 2013-2015, The Linux Foundation. All rights reserved.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for
+ * any purpose with or without fee is hereby granted, provided that the
+ * above copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
+ * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ **************************************************************************
+ */
+/*
+ * @file
+ * This file defines the NSS GMAC device dependent functions.
+ * Most of the operations on the GMAC device are available in this file.
+ * Functions for initiliasing and accessing MAC/DMA/PHY registers and
+ * the DMA descriptors are encapsulated in this file. The functions are
+ * platform/host/OS independent.
+ * These functions in turn use the low level device dependent (HAL) functions
+ * to access the register space.
+ * ------------------------REVISION HISTORY---------------------------------
+ * Qualcomm Atheros         01/Mar/2013                 Modified for QCA NSS
+ * Synopsys                 01/Aug/2007                 Created
+ */
+
+#include <linux/mii.h>
+#include <linux/phy.h>
+
+#ifndef CONFIG_OF
+#include <mach/msm_iomap.h>
+#endif
+
+#include <nss_gmac_dev.h>
+#include <nss_gmac_network_interface.h>
+
+/*
+ * Function to check the current link status
+ * @param[in] pointer to device structure.
+ * @return Returns LINKUP or LINKDOWN
+ */
+int32_t nss_gmac_check_link(struct nss_gmac_dev *gmacdev)
+{
+	struct phy_device *phydev = gmacdev->phydev;
+
+	if (!test_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags))
+		return LINKUP;
+
+	if (gmacdev->emulation && (gmacdev->phy_mii_type == GMAC_INTF_SGMII
+			|| gmacdev->phy_mii_type == GMAC_INTF_QSGMII)) {
+		return LINKUP;
+	}
+
+	genphy_read_status(phydev);
+
+	if (phydev->link)
+		return LINKUP;
+
+	return LINKDOWN;
+}
+
+/*
+ * Function to read the Phy register. The access to phy register
+ * is a slow process as the data is moved accross MDI/MDO interface
+ * Caller is required to call this function in an SMP safe manner.
+ * @param[in] pointer to Register Base (It is the mac base in our case).
+ * @param[in] phy_base register is the index of one of supported 32 PHY devices.
+ * @param[in] Register offset is the index of one of the 32 phy register.
+ * @param[out] uint16_t data read from the respective phy register
+ * (only valid iff return value is 0).
+ * @param[in] MDC clock divider value.
+ * @return Returns 0 on success else return the error status.
+ */
+int32_t nss_gmac_read_phy_reg(uint32_t *reg_base, uint32_t phy_base,
+			      uint32_t reg_offset, uint16_t *data,
+			      uint32_t mdc_clk_div)
+{
+	uint32_t addr = 0;
+	uint32_t loop_variable;
+	uint32_t temp;
+
+	addr = ((phy_base << gmii_dev_shift) & gmii_dev_mask)
+	    | (((uint32_t)reg_offset << gmii_reg_shift) & gmii_reg_mask)
+	    | mdc_clk_div;
+
+	/* Gmii busy bit */
+	addr = addr | gmii_busy;
+
+	/* write the address from where the data to be read in
+	 * gmii_gmii_addr register of NSS GMAC ip
+	 */
+	nss_gmac_write_reg(reg_base, gmac_gmii_addr, addr);
+
+	/* Wait till the busy bit gets cleared */
+	for (loop_variable = 0; loop_variable
+	     < DEFAULT_LOOP_VARIABLE; loop_variable++) {
+		temp = nss_gmac_read_reg(reg_base, gmac_gmii_addr);
+		if (!(temp & gmii_busy)) {
+			*data =
+				(uint16_t)(nss_gmac_read_reg(reg_base,
+							 gmac_gmii_data) &
+							 0xFFFF);
+			return 0;
+
+		}
+		msleep(100);
+	}
+
+	pr_debug("Error::: PHY not responding; Busy bit not cleared!! addr:%x, data:%x\n",
+	     temp, *data);
+
+	return -EIO;
+}
+
+/*
+ * Function to write to the Phy register. The access to phy register
+ * is a slow process as the data is moved accross MDI/MDO interface
+ * Caller is required to call this function in an SMP safe manner.
+ * @param[in] pointer to Register Base (It is the mac base in our case).
+ * @param[in] phy_base register is the index of one of supported 32 PHY devices.
+ * @param[in] Register offset is the index of one of the 32 phy register.
+ * @param[in] data to be written to the respective phy register.
+ * @param[in] MDC clock divider value.
+ * @return Returns 0 on success else return the error status.
+ */
+int32_t nss_gmac_write_phy_reg(uint32_t *reg_base, uint32_t phy_base,
+			       uint32_t reg_offset, uint16_t data,
+			       uint32_t mdc_clk_div)
+{
+	uint32_t addr = 0;
+	uint32_t loop_variable;
+	uint32_t temp;
+
+	/* write the data in to gmac_gmii_data register of GMAC ip */
+	nss_gmac_write_reg(reg_base, gmac_gmii_data, data);
+
+	addr = ((phy_base << gmii_dev_shift) & gmii_dev_mask)
+	    | ((reg_offset << gmii_reg_shift) & gmii_reg_mask)
+	    | gmii_write | mdc_clk_div;
+
+	addr = addr | gmii_busy;
+
+	nss_gmac_write_reg(reg_base, gmac_gmii_addr, addr);
+
+	for (loop_variable = 0; loop_variable
+	     < DEFAULT_LOOP_VARIABLE; loop_variable++) {
+		temp = nss_gmac_read_reg(reg_base, gmac_gmii_addr);
+		if (!(temp & gmii_busy))
+			return 0;
+		msleep(100);
+	}
+
+	pr_debug("Error::: PHY not responding; Busy bit not cleared!! addr:data %x:%x",
+	     temp, data);
+
+	return -EIO;
+}
+
+
+/**
+ * @brief Read a register from an external PHY
+ * @param[in] pointer to gmac context
+ * @param[in] phy id
+ * @param[in] register id
+ * @return Returns value read from phy register on success, 0 otherwise.
+ */
+uint16_t nss_gmac_mii_rd_reg(struct nss_gmac_dev *gmacdev, uint32_t phy,
+			     uint32_t reg)
+{
+	uint16_t data = 0;
+
+	if (IS_ERR_OR_NULL(gmacdev->phydev)) {
+		netdev_dbg(gmacdev->netdev, "Error: Reading uninitialized PHY...");
+		return 0;
+	}
+
+	data = (uint16_t)phy_read(gmacdev->phydev, reg);
+
+	return data;
+}
+
+
+/**
+ * @brief Write a register of an external PHY
+ * @param[in] pointer to gmac context
+ * @param[in] phy id
+ * @param[in] register id
+ * @param[in] register id
+ * @return void
+ */
+void nss_gmac_mii_wr_reg(struct nss_gmac_dev *gmacdev, uint32_t phy,
+			 uint32_t reg, uint16_t data)
+{
+	if (IS_ERR_OR_NULL(gmacdev->phydev))
+		netdev_dbg(gmacdev->netdev, "Error: Writing uninitialized PHY...");
+	else
+		phy_write(gmacdev->phydev, reg, data);
+}
+
+/**
+ * @brief Reset the Phy specified by phyid
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] phy id
+ * @return void
+ */
+void nss_gmac_reset_phy(struct nss_gmac_dev *gmacdev, uint32_t phyid)
+{
+	if (gmacdev->emulation && (gmacdev->phy_mii_type != GMAC_INTF_RGMII))
+		return;
+
+	nss_gmac_mii_wr_reg(gmacdev, phyid, MII_BMCR, BMCR_RESET);
+	nss_gmac_mii_wr_reg(gmacdev, phyid, MII_BMCR,
+			    nss_gmac_mii_rd_reg(gmacdev, phyid, MII_BMCR)
+			    | BMCR_ANENABLE);
+
+	test_and_set_bit(__NSS_GMAC_AUTONEG, &gmacdev->flags);
+	netdev_dbg(gmacdev->netdev, "Phy %u reset OK", phyid);
+}
+
+
+/*
+ * Function to read the GMAC IP Version and populates the
+ * same in device data structure.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return Always return 0.
+ */
+int32_t nss_gmac_read_version(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t data = 0;
+
+	data = nss_gmac_read_reg((uint32_t *)gmacdev->mac_base, gmac_version);
+	gmacdev->version = data;
+	return 0;
+}
+
+/*
+ * Function to reset the GMAC core.
+ * This reests the DMA and GMAC core. After reset all the
+ * registers holds their respective reset value.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return 0 on success else return the error status.
+ */
+void nss_gmac_reset(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t data = 0;
+	uint32_t reset_time __attribute__ ((unused)) = jiffies;
+	struct nss_gmac_global_ctx *ctx;
+	struct net_device *netdev = NULL;
+
+	netdev = gmacdev->netdev;
+	ctx = gmacdev->ctx;
+
+	netdev_dbg(netdev, "%s: %s resetting...",
+		      __func__, netdev->name);
+
+	reset_time = jiffies;
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base,
+			   dma_bus_mode, dma_reset_on);
+	do {
+		msleep(DEFAULT_LOOP_VARIABLE);
+		data =
+		    nss_gmac_read_reg((uint32_t *)gmacdev->dma_base,
+				      dma_bus_mode);
+	} while (data & dma_reset_on);
+
+	msleep(1000);
+	data = nss_gmac_read_reg((uint32_t *)gmacdev->dma_base, dma_bus_mode);
+
+	netdev_dbg(netdev, "GMAC reset completed in %d jiffies; dma_bus_mode - 0x%x", (int)(jiffies - reset_time), data);
+}
+
+/*
+ * Function to program DMA bus mode register.
+ * The Bus Mode register is programmed with the value given.
+ * The bits to be set are bit wise or'ed and sent as the second
+ * argument to this function.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] the data to be programmed.
+ * @return 0 on success else return the error status.
+ */
+int32_t nss_gmac_dma_bus_mode_init(struct nss_gmac_dev *gmacdev,
+							uint32_t init_value)
+{
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base, dma_bus_mode,
+			   init_value);
+	return 0;
+}
+
+/*
+ * Function to program DMA AXI bus mode register.
+ * The Bus Mode register is programmed with the value given.
+ * The bits to be set are bit wise or'ed and sent as the second
+ * argument to this function.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] the data to be programmed.
+ * @return 0 on success else return the error status.
+ */
+int32_t nss_gmac_dma_axi_bus_mode_init(struct nss_gmac_dev *gmacdev,
+						uint32_t init_value)
+{
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base, dma_axi_bus_mode,
+			   init_value);
+	return 0;
+}
+
+/*
+ * Function to program DMA Control register.
+ * The Dma Control register is programmed with the value given.
+ * The bits to be set are bit wise or'ed and sent as the second
+ * argument to this function.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] the data to be programmed.
+ * @return 0 on success else return the error status.
+ */
+int32_t nss_gmac_dma_control_init(struct nss_gmac_dev *gmacdev,
+						uint32_t init_value)
+{
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base, dma_control,
+			   init_value);
+	return 0;
+}
+
+/* Gmac configuration functions */
+
+/*
+ * Enable the watchdog timer on the receiver.
+ * When enabled, Gmac enables Watchdog timer, and GMAC allows no more than
+ * 2048 bytes of data (10,240 if Jumbo frame enabled).
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_wd_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_watchdog);
+}
+
+/*
+ * Enables the Jabber frame support.
+ * When enabled, GMAC disabled the jabber timer, and can transfer
+ * 16,384 byte frames.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_jab_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_config, gmac_jabber);
+}
+
+/*
+ * Enables Frame bursting (Only in Half Duplex Mode).
+ * When enabled, GMAC allows frame bursting in GMII Half Duplex mode.
+ * Reserved in 10/100 and Full-Duplex configurations.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_frame_burst_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_config, gmac_frame_burst);
+}
+
+/*
+ * Enable Jumbo frame support.
+ * When Enabled GMAC supports jumbo frames of 9018/9022(VLAN tagged).
+ * Giant frame error is not reported in receive frame status.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_jumbo_frame_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_config, gmac_jumbo_frame);
+}
+
+/*
+ * Disable Jumbo frame support.
+ * When Disabled GMAC does not supports jumbo frames.
+ * Giant frame error is reported in receive frame status.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_jumbo_frame_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_jumbo_frame);
+}
+
+/*
+ * Enable twokpe frame support.
+ * When Enabled GMAC supports jumbo frames of <= 2000 bytes.
+ * Giant frame error is not reported in receive frame status.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_twokpe_frame_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_config, gmac_twokpe);
+}
+
+/*
+ * Disable twokpe SUPPORT.
+ * When disabled gmac does not support frames of length > 1522 bytes.
+ * Giant frame error is reported in receive frame status
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_twokpe_frame_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_twokpe);
+}
+
+/*
+ * Disable Carrier sense.
+ * When Disabled GMAC ignores CRS signal during frame transmission
+ * in half duplex mode.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_disable_crs(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_config, gmac_disable_crs);
+}
+
+/*
+ * Enable Carrier sense.
+ * When Carrier sense is enabled GMAC generates Loss of Carier
+ * or No carrier errors and can abort transmissions.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_enable_crs(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_config, gmac_disable_crs);
+}
+
+/*
+ * Selects the GMII port.
+ * When called GMII (1000Mbps) port is selected (programmable only in
+ * 10/100/1000 Mbps configuration).
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_select_gmii(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_mii_gmii);
+}
+
+/*
+ * Selects the MII port.
+ * When called MII (10/100Mbps) port is selected (programmable only in
+ * 10/100/1000 Mbps configuration).
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_select_mii(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_config, gmac_mii_gmii);
+
+	if (gmacdev->speed == SPEED100) {
+		nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+				      gmac_config, gmac_fe_speed100);
+		return;
+	}
+
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_fe_speed100);
+}
+
+/*
+ * Enables Receive Own bit (Only in Half Duplex Mode).
+ * When enaled GMAC receives all the packets given by phy while transmitting.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_rx_own_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_rx_own);
+}
+
+/*
+ * Disables Receive Own bit (Only in Half Duplex Mode).
+ * When enaled GMAC disables the reception of frames when
+ * gmii_txen_o is asserted.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_rx_own_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_config, gmac_rx_own);
+}
+
+/*
+ * Sets the GMAC in Normal mode.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_loopback_off(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_loopback);
+}
+
+/*
+ * Sets the GMAC core in Full-Duplex mode.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_set_full_duplex(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_config, gmac_duplex);
+}
+
+/*
+ * Sets the GMAC core in Half-Duplex mode.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_set_half_duplex(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_duplex);
+}
+
+/*
+ * GMAC tries retransmission (Only in Half Duplex mode).
+ * If collision occurs on the GMII/MII, GMAC attempt retries based on the
+ * back off limit configured.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ * @note This function is tightly coupled with
+ * nss_gmac_back_off_limit(nss_gmac_dev *, uint32_t).
+ */
+void nss_gmac_retry_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_retry);
+}
+
+/*
+ * GMAC tries only one transmission (Only in Half Duplex mode).
+ * If collision occurs on the GMII/MII, GMAC will ignore the current frami
+ * transmission and report a frame abort with excessive collision
+ * in tranmit frame status.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_retry_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_config, gmac_retry);
+}
+
+/*
+ * GMAC doesnot strips the Pad/FCS field of incoming frames.
+ * GMAC will pass all the incoming frames to Host unmodified.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_pad_crc_strip_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_pad_crc_strip);
+}
+
+/*
+ * GMAC programmed with the back off limit value.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ * @note This function is tightly coupled with
+ * nss_gmac_retry_enable(nss_gmac_dev *gmacdev)
+ */
+void nss_gmac_back_off_limit(struct nss_gmac_dev *gmacdev, uint32_t value)
+{
+	uint32_t data;
+
+	data = nss_gmac_read_reg((uint32_t *)gmacdev->mac_base, gmac_config);
+	data &= (~gmac_backoff_limit);
+	data |= value;
+	nss_gmac_write_reg((uint32_t *)gmacdev->mac_base, gmac_config, data);
+}
+
+/*
+ * Disables the Deferral check in GMAC (Only in Half Duplex mode).
+ * GMAC defers until the CRS signal goes inactive.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_deferral_check_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_deferral_check);
+}
+
+/*
+ * Enable the reception of frames on GMII/MII.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_rx_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base, gmac_config,
+			      gmac_rx);
+}
+
+/*
+ * Disable the reception of frames on GMII/MII.
+ * GMAC receive state machine is disabled after completion of reception of
+ * current frame.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_rx_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_rx);
+
+}
+
+/*
+ * Enable the transmission of frames on GMII/MII.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_tx_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base, gmac_config,
+			      gmac_tx);
+}
+
+/*
+ * Disable the transmission of frames on GMII/MII.
+ * GMAC transmit state machine is disabled after completion of
+ * transmission of current frame.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_tx_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_tx);
+}
+
+/*Receive frame filter configuration functions*/
+
+/*
+ * Enables reception of all the frames to application.
+ * GMAC passes all the frames received to application
+ * irrespective of whether they pass SA/DA address filtering or not.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_frame_filter_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_frame_filter, gmac_filter);
+}
+
+/*
+ * Disables Source address filtering.
+ * When disabled GMAC forwards the received frames with updated
+ * SAMatch bit in rx_status.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_src_addr_filter_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_frame_filter, gmac_src_addr_filter);
+}
+
+/*
+ * Enables the normal Destination address filtering.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_dst_addr_filter_normal(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_frame_filter, gmac_dest_addr_filter_inv);
+}
+
+/*
+ * Enables forwarding of control frames.
+ * When set forwards all the control frames
+ * (incl. unicast and multicast PAUSE frames).
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] pass control.
+ * @return void.
+ * @note Depends on RFE of flow_control_register[2]
+ */
+void nss_gmac_set_pass_control(struct nss_gmac_dev *gmacdev,
+						uint32_t passcontrol)
+{
+	uint32_t data;
+
+	data =
+	    nss_gmac_read_reg((uint32_t *)gmacdev->mac_base, gmac_frame_filter);
+	data &= (~gmac_pass_control);
+	data |= passcontrol;
+	nss_gmac_write_reg((uint32_t *)gmacdev->mac_base, gmac_frame_filter,
+			   data);
+}
+
+/*
+ * Enables Broadcast frames.
+ * When enabled Address filtering module passes all incoming broadcast frames.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_broadcast_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_frame_filter, gmac_broadcast);
+}
+
+/*
+ * Enables Multicast frames.
+ * When enabled all multicast frames are passed.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_multicast_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_frame_filter, gmac_multicast_filter);
+}
+
+/*
+ * Disable Multicast frames.
+ * When disabled multicast frame filtering depends on HMC bit.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_multicast_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_frame_filter, gmac_multicast_filter);
+}
+
+/*
+ * Disables multicast hash filtering.
+ * When disabled GMAC performs perfect destination address filtering
+ * for multicast frames, it compares DA field with the value programmed
+ * in DA register.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_multicast_hash_filter_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_frame_filter, gmac_mcast_hash_filter);
+}
+
+/*
+ * Enables promiscous mode.
+ * When enabled Address filter modules pass all incoming frames
+ * regardless of their Destination and source addresses.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_promisc_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_frame_filter, gmac_promiscuous_mode);
+}
+
+/*
+ * Clears promiscous mode.
+ * When called the GMAC falls back to normal operation from promiscous mode.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_promisc_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_frame_filter, gmac_promiscuous_mode);
+}
+
+/*
+ * Disables multicast hash filtering.
+ * When disabled GMAC performs perfect destination address filtering for unicast
+ * frames, it compares DA field with the value programmed in DA register.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_unicast_hash_filter_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_frame_filter, gmac_ucast_hash_filter);
+}
+
+/*Flow control configuration functions*/
+
+/*
+ * Disables detection of pause frames with stations unicast address.
+ * When disabled GMAC only detects with the unique multicast address (802.3x).
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_unicast_pause_frame_detect_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_flow_control, gmac_unicast_pause_frame);
+}
+
+/*
+ * Rx flow control disable.
+ * When disabled GMAC will not decode pause frame.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_rx_flow_control_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_flow_control, gmac_rx_flow_control);
+}
+
+/*
+ * Tx flow control disable.
+ * When Disabled
+ *	- In full duplex GMAC will not transmit any pause frames.
+ *	- In Half duplex GMAC disables the back pressure feature.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_tx_flow_control_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+			gmac_flow_control, gmac_tx_flow_control);
+}
+
+
+/*
+ * This enables processing of received pause frame.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_tx_pause_enable(struct nss_gmac_dev *gmacdev)
+{
+	netdev_dbg(gmacdev->netdev, "%s: enable Tx flow control", __func__);
+
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_flow_control, gmac_tx_flow_control);
+}
+
+/*
+ * disable processing of received pause frame.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_tx_pause_disable(struct nss_gmac_dev *gmacdev)
+{
+	netdev_dbg(gmacdev->netdev, "%s: disable Tx flow control", __func__);
+
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_flow_control, gmac_tx_flow_control);
+
+}
+
+/*
+ * This enables pause frame generation after
+ * programming the appropriate registers.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_rx_pause_enable(struct nss_gmac_dev *gmacdev)
+{
+	netdev_dbg(gmacdev->netdev, "%s: enable Rx flow control", __func__);
+
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->dma_base, dma_control,
+			dma_en_hw_flow_ctrl | dma_rx_flow_ctrl_act3K |
+			dma_rx_flow_ctrl_deact4K);
+
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_flow_control, gmac_rx_flow_control);
+}
+
+/*
+ * Disable pause frame generation.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_rx_pause_disable(struct nss_gmac_dev *gmacdev)
+{
+	netdev_dbg(gmacdev->netdev, "%s: disable Rx flow control", __func__);
+
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->dma_base,
+				dma_control, dma_en_hw_flow_ctrl);
+
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_flow_control, gmac_rx_flow_control);
+}
+
+
+/*
+ * Flush Dma Tx fifo.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_flush_tx_fifo(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->dma_base,
+				dma_control, dma_flush_tx_fifo);
+}
+
+/*
+ * Configure and set Tx/Rx flow control
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+void nss_gmac_config_flow_control(struct nss_gmac_dev *gmacdev)
+{
+	uint16_t phyreg;
+
+	netdev_dbg(gmacdev->netdev, "%s:", __func__);
+
+	if (gmacdev->pause == 0) {
+		nss_gmac_rx_pause_disable(gmacdev);
+		nss_gmac_tx_pause_disable(gmacdev);
+		return;
+	}
+
+	phyreg = nss_gmac_mii_rd_reg(gmacdev, gmacdev->phy_base, MII_LPA);
+
+	if (phyreg & LPA_PAUSE_CAP) {
+		/* link partner can do Tx/Rx flow control */
+		netdev_dbg(gmacdev->netdev,
+			      "%s: Link partner supports Tx/Rx flow control",
+			      __func__);
+
+		if (gmacdev->pause & FLOW_CTRL_RX)
+			nss_gmac_rx_pause_enable(gmacdev);
+
+		if (gmacdev->pause & FLOW_CTRL_TX)
+			nss_gmac_tx_pause_enable(gmacdev);
+
+		return;
+	}
+
+	if (phyreg & LPA_PAUSE_ASYM) {
+		/* link partner can do Rx flow control only */
+		netdev_dbg(gmacdev->netdev,
+			      "%s: Link partner supports Rx flow control only",
+			      __func__);
+
+		/* disable Rx flow control as link
+		 * partner cannot process pause frames
+		 */
+		nss_gmac_rx_pause_disable(gmacdev);
+		if (gmacdev->pause & FLOW_CTRL_TX)
+			nss_gmac_tx_pause_enable(gmacdev);
+
+		return;
+	}
+
+	/* link partner does not support Tx/Rx flow control */
+	netdev_dbg(gmacdev->netdev,
+		      "%s: Link partner does not support Tx/Rx flow control",
+		      __func__);
+	nss_gmac_rx_flow_control_disable(gmacdev);
+	nss_gmac_tx_flow_control_disable(gmacdev);
+}
+
+/*
+ * Initialize IPC Checksum offloading.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void
+ */
+void nss_gmac_ipc_offload_init(struct nss_gmac_dev *gmacdev)
+{
+	if (test_bit(__NSS_GMAC_RXCSUM, &gmacdev->flags)) {
+		/* Enable the offload engine in the receive path */
+		nss_gmac_enable_rx_chksum_offload(gmacdev);
+
+		/* DMA drops the packets if error in encapsulated ethernet
+		 * payload.
+		 */
+		nss_gmac_rx_tcpip_chksum_drop_enable(gmacdev);
+		netdev_dbg(gmacdev->netdev, "%s: enable Rx checksum", __func__);
+	} else {
+		nss_gmac_disable_rx_chksum_offload(gmacdev);
+		netdev_dbg(gmacdev->netdev, "%s: disable Rx checksum", __func__);
+	}
+}
+
+
+/*
+ * Mac initialization sequence.
+ * This function calls the initialization routines
+ * to initialize the GMAC register.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void
+ */
+void nss_gmac_mac_init(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_wd_enable(gmacdev);
+	nss_gmac_jab_enable(gmacdev);
+	nss_gmac_frame_burst_enable(gmacdev);
+	nss_gmac_loopback_off(gmacdev);
+
+	if (gmacdev->speed == SPEED1000)
+		nss_gmac_select_gmii(gmacdev);
+	else
+		nss_gmac_select_mii(gmacdev);
+
+	if (gmacdev->duplex_mode == FULLDUPLEX) {
+		nss_gmac_set_full_duplex(gmacdev);
+		nss_gmac_rx_own_enable(gmacdev);
+		nss_gmac_retry_disable(gmacdev);
+		nss_gmac_enable_crs(gmacdev);
+	} else {
+		nss_gmac_set_half_duplex(gmacdev);
+		nss_gmac_rx_own_disable(gmacdev);
+		nss_gmac_retry_enable(gmacdev);
+		nss_gmac_disable_crs(gmacdev);
+	}
+
+	nss_gmac_pad_crc_strip_disable(gmacdev);
+	nss_gmac_back_off_limit(gmacdev, gmac_backoff_limit0);
+	nss_gmac_deferral_check_disable(gmacdev);
+
+	nss_gmac_set_mac_addr(gmacdev, gmac_addr0_high,
+			      gmac_addr0_low, gmacdev->netdev->dev_addr);
+
+	/*Frame Filter Configuration */
+	nss_gmac_frame_filter_enable(gmacdev);
+	nss_gmac_set_pass_control(gmacdev, gmac_pass_control0);
+	nss_gmac_broadcast_enable(gmacdev);
+	nss_gmac_src_addr_filter_disable(gmacdev);
+	nss_gmac_multicast_enable(gmacdev);
+	gmacdev->netdev->flags |= IFF_ALLMULTI;
+	nss_gmac_dst_addr_filter_normal(gmacdev);
+	nss_gmac_multicast_hash_filter_disable(gmacdev);
+	nss_gmac_promisc_enable(gmacdev);
+	nss_gmac_unicast_hash_filter_disable(gmacdev);
+
+	nss_gmac_ipc_offload_init(gmacdev);
+
+	/* Flow Control Configuration */
+	nss_gmac_unicast_pause_frame_detect_disable(gmacdev);
+	nss_gmac_config_flow_control(gmacdev);
+
+	nss_gmac_tx_enable(gmacdev);
+	nss_gmac_rx_enable(gmacdev);
+}
+
+
+static void nss_gmac_check_pcs_status(struct nss_gmac_dev *gmacdev)
+{
+	struct nss_gmac_global_ctx *ctx = NULL;
+	uint32_t *qsgmii_base = NULL;
+	uint32_t id = 0;
+	uint32_t reg = 0;
+
+	ctx = gmacdev->ctx;
+	qsgmii_base = ctx->qsgmii_base;
+	id = gmacdev->macid;
+
+	gmacdev->link_state = LINKDOWN;
+
+	/* confirm link is up in PCS_QSGMII_MAC_STATUS register */
+	reg = nss_gmac_read_reg(qsgmii_base, PCS_QSGMII_MAC_STAT);
+	if (!(reg & PCS_MAC_STAT_CHn_LINK(id)))
+		return;
+
+	gmacdev->link_state = LINKUP;
+
+	/* save duplexity */
+	if (reg & PCS_MAC_STAT_CHn_DUPLEX(id))
+		gmacdev->duplex_mode = FULLDUPLEX;
+	else
+		gmacdev->duplex_mode = HALFDUPLEX;
+
+	/* save speed */
+	switch (PCS_MAC_STAT_CHn_SPEED(id, reg)) {
+	case 0:
+		gmacdev->speed = SPEED10;
+		break;
+
+	case 1:
+		gmacdev->speed = SPEED100;
+		break;
+
+	case 2:
+		gmacdev->speed = SPEED1000;
+		break;
+	}
+}
+
+
+/*
+ * Handle Q/SGMII linkup
+ * @param[in] pointer to nss_gmac_dev.
+ * @return void.
+ */
+static void nss_gmac_check_sgmii_link(struct nss_gmac_dev *gmacdev)
+{
+	struct nss_gmac_global_ctx *ctx = NULL;
+	uint32_t *qsgmii_base = NULL;
+	uint32_t id = 0;
+	uint32_t reg = 0;
+	uint32_t previous_linkup_duplex = 0;
+	uint32_t previous_linkup_speed = 0;
+	uint32_t new_duplex = 0;
+	uint32_t new_speed = 0;
+	int32_t timeout = 0;
+	int32_t timeout_count = 0;
+
+	ctx = gmacdev->ctx;
+	qsgmii_base = ctx->qsgmii_base;
+	id = gmacdev->macid;
+
+	previous_linkup_speed = gmacdev->speed;
+	previous_linkup_duplex = gmacdev->duplex_mode;
+
+reheck_pcs_mac_status:
+	nss_gmac_check_pcs_status(gmacdev);
+	if (gmacdev->link_state == LINKDOWN) {
+		if (gmacdev->phydev->link) {
+			netdev_dbg(gmacdev->netdev, "SGMII PCS error. Resetting PHY using MDIO");
+			phy_write(gmacdev->phydev, MII_BMCR,
+				BMCR_RESET | phy_read(gmacdev->phydev, MII_BMCR));
+		}
+
+		return;
+	}
+
+	new_speed = gmacdev->speed;
+	new_duplex = gmacdev->duplex_mode;
+
+	/* reinitiate autoneg in QSGMII CSR. */
+	nss_gmac_set_reg_bits(qsgmii_base, PCS_MODE_CTL,
+				PCS_MODE_CTL_CHn_AUTONEG_RESTART(id));
+	nss_gmac_clear_reg_bits(qsgmii_base, PCS_MODE_CTL,
+				PCS_MODE_CTL_CHn_AUTONEG_RESTART(id));
+	timeout = 50;
+	reg = nss_gmac_read_reg(qsgmii_base, PCS_ALL_CH_STAT);
+	while (!(reg & PCS_CHn_AUTONEG_COMPLETE(id)) && timeout > 0) {
+		timeout--;
+		usleep_range(10000, 12000);
+		reg = nss_gmac_read_reg(qsgmii_base, PCS_ALL_CH_STAT);
+	}
+
+	/* handle autoneg timeout */
+	if (timeout == 0) {
+		netdev_dbg(gmacdev->netdev, "%s: PCS ch %d autoneg timeout",
+							__func__, id);
+		timeout_count++;
+		if (timeout_count == 2) {
+			gmacdev->link_state = LINKDOWN;
+			nss_gmac_set_reg_bits(qsgmii_base, PCS_MODE_CTL,
+					      PCS_MODE_CTL_CHn_PHY_RESET(id));
+			return;
+		}
+		goto reheck_pcs_mac_status;
+	}
+	netdev_dbg(gmacdev->netdev, "%s: PCS ch %d autoneg complete",
+							__func__, id);
+
+	nss_gmac_check_pcs_status(gmacdev);
+
+	if ((gmacdev->link_state == LINKDOWN) || (new_speed != gmacdev->speed)) {
+		gmacdev->link_state = LINKDOWN;
+			netdev_dbg(gmacdev->netdev, "SGMII PCS error. Resetting PHY using MDIO");
+			phy_write(gmacdev->phydev, MII_BMCR,
+				BMCR_RESET | phy_read(gmacdev->phydev, MII_BMCR));
+		return;
+	}
+
+	/* check if initial speed has changed */
+	if (previous_linkup_speed != gmacdev->speed) {
+		/* switch clock dividers */
+		nss_gmac_dev_set_speed(gmacdev);
+
+		/* flush GMAC fifo */
+		nss_gmac_flush_tx_fifo(gmacdev);
+	}
+}
+
+
+/*
+ * This function checks to see if phy PHY autonegotiation is complete.
+ * It reads PHY registers to retrieve current speed and duplexity settings.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return 0 on success. If successful, it updates gmacdev->speed and
+ *	   gmacdev->duplex_mode with current speed and duplex mode.
+ */
+int32_t nss_gmac_check_phy_init(struct nss_gmac_dev *gmacdev)
+{
+	struct phy_device *phydev = NULL;
+	int32_t count;
+
+	/*
+	 * If link polling is disabled, we need to use the forced speed
+	 * and duplex configured for the interface.
+	 */
+	if (!test_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags)
+					&& !gmacdev->emulation) {
+		if (gmacdev->forced_speed != SPEED_UNKNOWN) {
+			gmacdev->speed = gmacdev->forced_speed;
+			gmacdev->duplex_mode = gmacdev->forced_duplex;
+			return 0;
+		} else {
+			netdev_dbg(gmacdev->netdev, "%s: Invalid forced speed/duplex configuration with link polling disabled"
+								, __func__);
+			return -EIO;
+		}
+	}
+
+	if (gmacdev->emulation && (gmacdev->phy_mii_type == GMAC_INTF_SGMII
+			|| gmacdev->phy_mii_type == GMAC_INTF_QSGMII)) {
+		/* Emulation build, Q/SGMII interface. Returning 100Mbps FD */
+		gmacdev->speed = SPEED100;
+		gmacdev->duplex_mode = FULLDUPLEX;
+		goto out;
+	}
+
+	if (gmacdev->phy_mii_type == GMAC_INTF_SGMII
+		|| gmacdev->phy_mii_type == GMAC_INTF_QSGMII) {
+		nss_gmac_check_sgmii_link(gmacdev);
+		if (gmacdev->link_state == LINKDOWN) {
+			netdev_dbg(gmacdev->netdev, "%s: SGMII phy linkup ERROR."
+								, __func__);
+			return -EIO;
+		}
+
+		netdev_dbg(gmacdev->netdev, "%s: SGMII phy linkup OK.",
+								__func__);
+		goto out;
+	}
+
+	/*
+	 * Read the link status from the PHY for RGMII interfaces
+	 * with link polling enabled.
+	 */
+	phydev = gmacdev->phydev;
+
+	for (count = 0; count < DEFAULT_LOOP_VARIABLE; count++) {
+		if (phydev->state == PHY_RUNNING) {
+			netdev_dbg(gmacdev->netdev, "%s: %s Autoneg. complete",
+				      __func__, gmacdev->netdev->name);
+			break;
+		}
+	}
+
+	if (count == DEFAULT_LOOP_VARIABLE) {
+		netdev_dbg(gmacdev->netdev, "%s: %s Timeout waiting for autoneg.",
+			      __func__, gmacdev->netdev->name);
+		return -EIO;
+	}
+
+	genphy_read_status(phydev);
+
+	switch (phydev->speed) {
+	case SPEED_10:
+		gmacdev->speed = SPEED10;
+		break;
+
+	case SPEED_100:
+		gmacdev->speed = SPEED100;
+		break;
+
+	case SPEED_1000:
+		gmacdev->speed = SPEED1000;
+		break;
+	}
+
+	switch (phydev->duplex) {
+	case DUPLEX_HALF:
+		gmacdev->duplex_mode = HALFDUPLEX;
+		break;
+
+	case DUPLEX_FULL:
+		gmacdev->duplex_mode = FULLDUPLEX;
+		break;
+	}
+
+out:
+	netdev_info(gmacdev->netdev, "%sMbps %sDuplex",
+			(gmacdev->speed == SPEED1000) ?
+			"1000" : ((gmacdev->speed == SPEED100) ? "100" : "10"),
+			(gmacdev->duplex_mode == FULLDUPLEX) ? "Full" : "Half");
+
+	/*
+	 * We may want to force speed and duplex settings even after link
+	 * polling. This may be for a GMAC connected to a switch where the
+	 * parameters of link between GAMC and switch are forced.
+	 */
+	if (gmacdev->forced_speed != SPEED_UNKNOWN) {
+		gmacdev->speed = gmacdev->forced_speed;
+		gmacdev->duplex_mode = gmacdev->forced_duplex;
+	}
+
+	return 0;
+}
+
+/*
+ * Write a MDIO Manageable Device(MMD) register of a Phy.
+ * @phydev[in] pointer to struct phy_device
+ * @mmd_dev_addr[in] MMD device address
+ * @reg[in] register offset
+ * @val[in] value to be written
+ * @return 0 on success
+ */
+int32_t nss_gmac_ath_phy_mmd_wr(struct phy_device *phydev,
+			uint32_t mmd_dev_addr, uint32_t reg, uint16_t val)
+{
+	if (IS_ERR_OR_NULL(phydev))
+		return -EINVAL;
+
+	phy_write(phydev, ATH_MII_MMD_ACCESS_CTRL, mmd_dev_addr);
+	phy_write(phydev, ATH_MII_MMD_ACCESS_ADDR_DATA, reg);
+	phy_write(phydev, ATH_MII_MMD_ACCESS_CTRL,
+		  ath_mmd_acc_ctrl_data_no_incr | mmd_dev_addr);
+	phy_write(phydev, ATH_MII_MMD_ACCESS_ADDR_DATA, val);
+
+	return 0;
+}
+
+/*
+ * Read a MDIO Manageable Device(MMD) register form a Phy.
+ * @phydev[in] pointer to struct phy_device
+ * @mmd_dev_addr[in] MMD device address
+ * @reg[in] register offset
+ * @return -EINVAL on failure. Register value on success.
+ */
+int32_t nss_gmac_ath_phy_mmd_rd(struct phy_device *phydev,
+			uint32_t mmd_dev_addr, uint32_t reg)
+{
+	if (IS_ERR_OR_NULL(phydev))
+		return -EINVAL;
+
+	phy_write(phydev, ATH_MII_MMD_ACCESS_CTRL, mmd_dev_addr);
+	phy_write(phydev, ATH_MII_MMD_ACCESS_ADDR_DATA, reg);
+	phy_write(phydev, ATH_MII_MMD_ACCESS_CTRL,
+		  ath_mmd_acc_ctrl_data_no_incr | mmd_dev_addr);
+	return phy_read(phydev, ATH_MII_MMD_ACCESS_ADDR_DATA);
+}
+
+/*
+ * Disable QCA Smart Energy Efficient Ethernet on a Phy.
+ * @phydev[in] pointer to struct phy_device
+ * @return 0 on success.
+ */
+int32_t nss_gmac_ath_phy_disable_smart_802az(struct phy_device *phydev)
+{
+	uint16_t val = 0;
+
+	if (IS_ERR_OR_NULL(phydev))
+		return -EINVAL;
+
+	val = nss_gmac_ath_phy_mmd_rd(phydev, ATH_MMD_DEVADDR_3,
+					ath_mmd_smart_eee_ctrl_3);
+	val &= ~ath_mmd_smart_eee_ctrl3_lpi_en;
+	nss_gmac_ath_phy_mmd_wr(phydev, ATH_MMD_DEVADDR_3,
+					ath_mmd_smart_eee_ctrl_3, val);
+
+	return 0;
+}
+
+/*
+ * Disable Energy Efficient Ethernet (IEEE 802.3az) on a Phy.
+ * @phydev[in] pointer to struct phy_device
+ * @return 0 on success.
+ */
+int32_t nss_gmac_ath_phy_disable_802az(struct phy_device *phydev)
+{
+	uint16_t val = 0;
+
+	if (IS_ERR_OR_NULL(phydev))
+		return -EINVAL;
+
+	val = nss_gmac_ath_phy_mmd_rd(phydev, ATH_MMD_DEVADDR_7,
+						ath_mmd_eee_adv);
+	val &= ~(ath_mmd_eee_adv_100BT | ath_mmd_eee_adv_1000BT);
+	nss_gmac_ath_phy_mmd_wr(phydev, ATH_MMD_DEVADDR_7,
+					ath_mmd_eee_adv, val);
+
+	return 0;
+}
+
+/*
+ * Sets the Mac address in to GMAC register.
+ * This function sets the MAC address to the MAC register in question.
+ * @param[in] pointer to nss_gmac_dev to populate mac dma and phy addresses.
+ * @param[in] Register offset for Mac address high
+ * @param[in] Register offset for Mac address low
+ * @param[in] buffer containing mac address to be programmed.
+ * @return void
+ */
+void nss_gmac_set_mac_addr(struct nss_gmac_dev *gmacdev, uint32_t mac_high,
+			      uint32_t mac_low, uint8_t *mac_addr)
+{
+	uint32_t data;
+
+	netdev_dbg(gmacdev->netdev, "Set addr %02x:%02x:%02x:%02x:%02x:%02x",
+		      mac_addr[0], mac_addr[1], mac_addr[2],
+		      mac_addr[3], mac_addr[4], mac_addr[5]);
+
+	data = (mac_addr[5] << 8) | mac_addr[4] | 0x80000000;
+	nss_gmac_write_reg((uint32_t *)gmacdev->mac_base, mac_high, data);
+	data = (mac_addr[3] << 24) | (mac_addr[2] << 16)
+	    | (mac_addr[1] << 8) | mac_addr[0];
+	nss_gmac_write_reg((uint32_t *)gmacdev->mac_base, mac_low, data);
+}
+
+/*
+ * Get the Mac address in to the address specified.
+ * The mac register contents are read and written to buffer passed.
+ * @param[in] pointer to nss_gmac_dev to populate mac dma and phy addresses.
+ * @param[in] Register offset for Mac address high
+ * @param[in] Register offset for Mac address low
+ * @param[out] buffer containing the device mac address.
+ * @return void
+ */
+void nss_gmac_get_mac_addr(struct nss_gmac_dev *gmacdev, uint32_t mac_high,
+			      uint32_t mac_low, uint8_t *mac_addr)
+{
+	uint32_t data;
+
+	data = nss_gmac_read_reg((uint32_t *)gmacdev->mac_base, mac_high);
+	mac_addr[5] = (data >> 8) & 0xff;
+	mac_addr[4] = (data) & 0xff;
+
+	data = nss_gmac_read_reg((uint32_t *)gmacdev->mac_base, mac_low);
+	mac_addr[3] = (data >> 24) & 0xff;
+	mac_addr[2] = (data >> 16) & 0xff;
+	mac_addr[1] = (data >> 8) & 0xff;
+	mac_addr[0] = (data) & 0xff;
+}
+
+/*
+ * Attaches the NSS GMAC device structure to the hardware.
+ * Device structure is populated with MAC/DMA and PHY base addresses.
+ * @param[in] pointer to nss_gmac_dev to populate mac dma and phy addresses.
+ * @param[in] GMAC IP register base address.
+ * @param[in] GMAC IP register length.
+ * @return 0 upon success. Error code upon failure.
+ * @note This is important function.
+ */
+int32_t nss_gmac_attach(struct nss_gmac_dev *gmacdev,
+			uint32_t reg_base, uint32_t reglen)
+{
+	struct net_device *netdev = NULL;
+	netdev = gmacdev->netdev;
+
+	/*Populate the mac and dma base addresses */
+	gmacdev->memres = request_mem_region(reg_base, reglen, netdev->name);
+	if (!gmacdev->memres) {
+		netdev_dbg(netdev, "Unable to request resource.");
+		return -EIO;
+	}
+
+	/* ioremap addresses */
+	gmacdev->mac_base = (uint32_t)ioremap_nocache(reg_base,
+						      NSS_GMAC_REG_BLOCK_LEN);
+	if (!gmacdev->mac_base) {
+		netdev_dbg(netdev, "ioremap fail.");
+		return -EIO;
+	}
+
+	netdev_dbg(netdev, "ioremap OK. Size 0x%x. reg_base 0x%x. mac_base 0x%x.",
+		      NSS_GMAC_REG_BLOCK_LEN, reg_base, gmacdev->mac_base);
+
+	gmacdev->dma_base = gmacdev->mac_base + NSS_GMAC_DMABASE;
+
+	return 0;
+}
+
+/**
+ * Detaches the NSS GMAC device structure from hardware.
+ * MAC/DMA base addresses are freed from device structure.
+ * @param[in] pointer to nss_gmac_dev to populate mac dma and phy addresses.
+ * @return void
+ * @note This is important function.
+ */
+void nss_gmac_detach(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t reglen;
+
+	reglen = gmacdev->memres->end - gmacdev->memres->start + 1;
+	iounmap((void *)gmacdev->mac_base);
+	release_mem_region((gmacdev->memres)->start, reglen);
+
+	gmacdev->memres = NULL;
+
+	gmacdev->mac_base = 0;
+	gmacdev->dma_base = 0;
+}
+
+
+/*
+ * Programs the dma_rx_base_address with the Rx descriptor base address.
+ * Rx Descriptor's base address is available in the gmacdev structure.
+ * This function progrms the Dma Rx Base address with the starting address
+ * of the descriptor ring or chain.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_init_rx_desc_base(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base,
+			   dma_rx_base_addr, (uint32_t)gmacdev->rx_desc_dma);
+}
+
+/*
+ * Programs the dma_tx_base_address with the Tx descriptor base address.
+ * Tx Descriptor's base address is available in the gmacdev structure.
+ * This function progrms the Dma Tx Base address with the starting
+ * address of the descriptor ring or chain.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_init_tx_desc_base(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base,
+			   dma_tx_base_addr, (uint32_t)gmacdev->tx_desc_dma);
+}
+
+/*
+ * Makes the Dma as owner for this descriptor.
+ * This function sets the own bit of status field of the DMA descriptor,
+ * indicating the DMA is the owner for this descriptor.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns void.
+ */
+void nss_gmac_set_owner_dma(struct dma_desc *desc)
+{
+	desc->status |= desc_own_by_dma;
+}
+
+/*
+ * set tx descriptor to indicate SOF.
+ * This Descriptor contains the start of ethernet frame.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns void.
+ */
+void nss_gmac_set_desc_sof(struct dma_desc *desc)
+{
+	desc->status |= desc_tx_first;
+}
+
+/*
+ * set tx descriptor to indicate EOF.
+ * This descriptor contains the End of ethernet frame.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns void.
+ */
+void nss_gmac_set_desc_eof(struct dma_desc *desc)
+{
+	desc->status |= desc_tx_last;
+}
+
+/*
+ * checks whether this descriptor contains start of frame.
+ * This function is to check whether the descriptor's data buffer
+ * contains a fresh ethernet frame?
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if SOF in current descriptor, else returns fail.
+ */
+bool nss_gmac_is_sof_in_rx_desc(struct dma_desc *desc)
+{
+	return (desc->status & desc_rx_first) == desc_rx_first;
+}
+
+/*
+ * checks whether this descriptor contains end of frame.
+ * This function is to check whether the descriptor's data buffer
+ * contains end of ethernet frame?
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if SOF in current descriptor, else returns fail.
+ */
+bool nss_gmac_is_eof_in_rx_desc(struct dma_desc *desc)
+{
+	return (desc->status & desc_rx_last) == desc_rx_last;
+}
+
+/*
+ * checks whether destination address filter failed in the rx frame.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if Failed, false if not.
+ */
+bool nss_gmac_is_da_filter_failed(struct dma_desc *desc)
+{
+	return (desc->status & desc_da_filter_fail) == desc_da_filter_fail;
+}
+
+/*
+ * checks whether source address filter failed in the rx frame.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if Failed, false if not.
+ */
+bool nss_gmac_is_sa_filter_failed(struct dma_desc *desc)
+{
+	return (desc->status & desc_sa_filter_fail) == desc_sa_filter_fail;
+}
+
+/*
+ * Checks whether the tx is aborted due to collisions.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if collisions, else returns false.
+ */
+bool nss_gmac_is_tx_aborted(uint32_t status)
+{
+	return ((status & desc_tx_late_collision) == desc_tx_late_collision)
+	    || ((status & desc_tx_exc_collisions) == desc_tx_exc_collisions);
+
+}
+
+/*
+ * Checks whether the tx carrier error.
+ * @param[in] Tx completion status.
+ * @return returns true if carrier error occurred, else returns false.
+ */
+bool nss_gmac_is_tx_carrier_error(uint32_t status)
+{
+	return ((status & desc_tx_lost_carrier) == desc_tx_lost_carrier)
+		|| ((status & desc_tx_no_carrier) == desc_tx_no_carrier);
+}
+
+/*
+ * Checks whether for tx underflow.
+ * @param[in] Tx completion status.
+ * @return returns true if tx underflow occurred, else returns false.
+ */
+bool nss_gmac_is_tx_underflow_error(uint32_t status)
+{
+	return (status & desc_tx_underflow) == desc_tx_underflow;
+}
+
+/*
+ * Checks whether for tx late collision.
+ * @param[in] Tx completion status.
+ * @return returns true if tx late collision occurred, else returns false.
+ */
+bool nss_gmac_is_tx_lc_error(uint32_t status)
+{
+	return (status & desc_tx_late_collision) == desc_tx_late_collision;
+}
+
+/*
+ * Check for damaged frame due to overflow or collision.
+ * Retruns true if rx frame was damaged due to buffer overflow
+ * in MTL or late collision in half duplex mode.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if error else returns false.
+ */
+bool nss_gmac_is_rx_frame_damaged(uint32_t status)
+{
+	return ((status & desc_rx_damaged) == desc_rx_damaged)
+		|| ((status & desc_rx_collision) == desc_rx_collision);
+}
+
+/*
+ * Check for damaged frame due to collision.
+ * Retruns true if rx frame was damaged due to late collision
+ * in half duplex mode.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if error else returns false.
+ */
+bool nss_gmac_is_rx_frame_collision(uint32_t status)
+{
+	return (status & desc_rx_collision) == desc_rx_collision;
+}
+
+/*
+ * Check for receive CRC error.
+ * Retruns true if rx frame CRC error occurred.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if error else returns false.
+ */
+bool nss_gmac_is_rx_crc(uint32_t status)
+{
+	return (status & desc_rx_crc) == desc_rx_crc;
+}
+
+/*
+ * Indicates rx frame has non integer multiple of bytes. (odd nibbles).
+ * Retruns true if dribbling error in rx frame.
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if error else returns false.
+ */
+bool nss_gmac_is_frame_dribbling_errors(uint32_t status)
+{
+	return (status & desc_rx_dribbling) == desc_rx_dribbling;
+}
+
+/*
+ * Indicates error in rx frame length.
+ * Retruns true if received frame length doesnot match with the length field
+ * @param[in] pointer to dma_desc structure.
+ * @return returns true if error else returns false.
+ */
+bool nss_gmac_is_rx_frame_length_errors(uint32_t status)
+{
+	return (status & desc_rx_length_error) == desc_rx_length_error;
+}
+
+/*
+ * Driver Api to get the descriptor field information.
+ * This returns the status, dma-able address of buffer1, the length of
+ * buffer1, virtual address of buffer1 dma-able address of buffer2, length
+ * of buffer2, virtural adddress of buffer2.
+ * @param[in]  pointer to dma_desc structure.
+ * @param[out] pointer to status field fo descriptor.
+ * @param[out] dma-able address of buffer1.
+ * @param[out] length of buffer1.
+ * @param[out] virtual address of buffer1.
+ * @return returns void.
+ */
+void nss_gmac_get_desc_data(struct dma_desc *desc,
+			    uint32_t *Status, uint32_t *Buffer1,
+			    uint32_t *Length1, uint32_t *Data1)
+{
+	/*
+	 * The first time, we map the descriptor as DMA_TO_DEVICE.
+	 * Then we only wait for changes from device, so we use DMA_FROM_DEVICE.
+	 */
+	if (Status != 0)
+		*Status = desc->status;
+
+	if (Buffer1 != 0)
+		*Buffer1 = desc->buffer1;
+
+	if (Length1 != 0)
+		*Length1 = (desc->length & desc_size1_mask) >> desc_size1_shift;
+
+	if (Data1 != 0)
+		*Data1 = desc->data1;
+}
+
+/*
+ * Enable the DMA Reception.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_enable_dma_rx(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t data;
+
+	data = nss_gmac_read_reg((uint32_t *)gmacdev->dma_base, dma_control);
+	data |= dma_rx_start;
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base, dma_control, data);
+}
+
+/*
+ * Enable the DMA Transmission.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_enable_dma_tx(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t data;
+
+	data = nss_gmac_read_reg((uint32_t *)gmacdev->dma_base, dma_control);
+	data |= dma_tx_start;
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base, dma_control, data);
+}
+
+/*
+ * Take ownership of this Descriptor.
+ * The function is same for both the ring mode and
+ * the chain mode DMA structures.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_take_desc_ownership(struct dma_desc *desc)
+{
+	if (desc) {
+		/* Clear the DMA own bit */
+		desc->status &= ~desc_own_by_dma;
+	}
+}
+
+/*
+ * Take ownership of all the rx Descriptors.
+ * This function is called when there is fatal error in DMA transmission.
+ * When called it takes the ownership of all the rx descriptor in rx
+ * descriptor pool/queue from DMA. The function is same for both the ring
+ * mode and the chain mode DMA structures.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ * @note Make sure to disable the transmission before calling this function,
+ * otherwise may result in racing situation.
+ */
+void nss_gmac_take_desc_ownership_rx(struct nss_gmac_dev *gmacdev)
+{
+	int32_t i;
+	struct dma_desc *desc;
+
+	desc = gmacdev->rx_desc;
+	for (i = 0; i < gmacdev->rx_desc_count; i++)
+		nss_gmac_take_desc_ownership(desc + i);
+}
+
+/*
+ * Take ownership of all the rx Descriptors.
+ * This function is called when there is fatal error in DMA transmission.
+ * When called it takes the ownership of all the tx descriptor in
+ * tx descriptor pool/queue from DMA. The function is same for both the
+ * ring mode and the chain mode DMA structures.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ * @note Make sure to disable the transmission before calling this function,
+ * otherwise may result in racing situation.
+ */
+void nss_gmac_take_desc_ownership_tx(struct nss_gmac_dev *gmacdev)
+{
+	int32_t i;
+	struct dma_desc *desc;
+
+	desc = gmacdev->tx_desc;
+	for (i = 0; i < gmacdev->tx_desc_count; i++)
+		nss_gmac_take_desc_ownership(desc + i);
+}
+
+/*
+ * Disable the DMA for Transmission.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_disable_dma_tx(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t data;
+
+	data = nss_gmac_read_reg((uint32_t *)gmacdev->dma_base, dma_control);
+	data &= (~dma_tx_start);
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base, dma_control, data);
+}
+
+/*
+ * Disable the DMA for Reception.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_disable_dma_rx(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t data;
+
+	data = nss_gmac_read_reg((uint32_t *)gmacdev->dma_base, dma_control);
+	data &= (~dma_rx_start);
+	nss_gmac_write_reg((uint32_t *)gmacdev->dma_base, dma_control, data);
+}
+
+/*******************MMC APIs****************************/
+
+/*
+ * Disable the MMC Tx interrupt.
+ * The MMC tx interrupts are masked out as per the mask specified.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] tx interrupt bit mask for which interrupts needs to be disabled.
+ * @return returns void.
+ */
+void nss_gmac_disable_mmc_tx_interrupt(struct nss_gmac_dev *gmacdev,
+						uint32_t mask)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_mmc_intr_mask_tx, mask);
+}
+
+/*
+ * Disable the MMC Rx interrupt.
+ * The MMC rx interrupts are masked out as per the mask specified.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] rx interrupt bit mask for which interrupts needs to be disabled.
+ * @return returns void.
+ */
+void nss_gmac_disable_mmc_rx_interrupt(struct nss_gmac_dev *gmacdev,
+						uint32_t mask)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_mmc_intr_mask_rx, mask);
+}
+
+/*
+ * Disable the MMC ipc rx checksum offload interrupt.
+ * The MMC ipc rx checksum offload interrupts are masked out as
+ * per the mask specified.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] rx interrupt bit mask for which interrupts needs to be disabled.
+ * @return returns void.
+ */
+void nss_gmac_disable_mmc_ipc_rx_interrupt(struct nss_gmac_dev *gmacdev,
+					   uint32_t mask)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_mmc_rx_ipc_intr_mask, mask);
+}
+
+/************Ip checksum offloading APIs*************/
+
+/*
+ * Enables the ip checksum offloading in receive path.
+ * When set GMAC calculates 16 bit 1's complement of all received
+ * ethernet frame payload. It also checks IPv4 Header checksum is correct.
+ * GMAC core appends the 16 bit checksum calculated for payload of IP
+ * datagram and appends it to Ethernet frame transferred to the application.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_enable_rx_chksum_offload(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->mac_base,
+			      gmac_config, gmac_rx_ipc_offload);
+}
+
+/*
+ * Disable the ip checksum offloading in receive path.
+ * Ip checksum offloading is disabled in the receive path.
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_disable_rx_chksum_offload(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->mac_base,
+				gmac_config, gmac_rx_ipc_offload);
+}
+
+/*
+ * Instruct the DMA to drop the packets fails tcp ip checksum.
+ * This is to instruct the receive DMA engine to drop the recevied
+ * packet if they fails the tcp/ip checksum in hardware. Valid only when
+ * full checksum offloading is enabled(type-2).
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_rx_tcpip_chksum_drop_enable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)gmacdev->dma_base,
+				dma_control, dma_disable_drop_tcp_cs);
+}
+
+/*
+ * Instruct the DMA not to drop the packets even if it fails tcp ip checksum.
+ * This is to instruct the receive DMA engine to allow the packets
+ * even if recevied packet fails the tcp/ip checksum in hardware.
+ * Valid only when full checksum offloading is enabled(type-2).
+ * @param[in] pointer to nss_gmac_dev.
+ * @return returns void.
+ */
+void nss_gmac_rx_tcpip_chksum_drop_disable(struct nss_gmac_dev *gmacdev)
+{
+	nss_gmac_set_reg_bits((uint32_t *)gmacdev->dma_base,
+			      dma_control, dma_disable_drop_tcp_cs);
+}
+
+/*******************Ip checksum offloading APIs**********************/
diff --git a/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_ethtool.c b/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_ethtool.c
new file mode 100644
index 0000000..941d09e
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_ethtool.c
@@ -0,0 +1,526 @@
+/*
+ * Copyright (c) 2013-2015, The Linux Foundation. All rights reserved.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
+ * SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
+ * RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT
+ * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
+ * USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+/*
+ * @file
+ * This is the network dependent layer to handle ethtool related functionality.
+ * This file is tightly coupled to neworking frame work of linux kernel.
+ * The functionality carried out in this file should be treated as an
+ * example only if the underlying operating system is not Linux.
+ *-----------------------------REVISION HISTORY--------------------------------
+ * Qualcomm Atheros			01/Mar/2010			Created
+ */
+
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+
+#ifdef CONFIG_OF
+#include <msm_nss_macsec.h>
+#else
+#include <mach/msm_nss_macsec.h>
+#endif
+
+#include <nss_gmac_dev.h>
+#include <nss_gmac_network_interface.h>
+
+
+struct nss_gmac_ethtool_stats {
+	uint8_t stat_string[ETH_GSTRING_LEN];
+	uint32_t stat_offset;
+};
+
+#define DRVINFO_LEN		32
+#define NSS_GMAC_STAT(m)	offsetof(struct nss_gmac_stats, m)
+#define HW_ERR_SIZE		sizeof(uint32_t)
+
+/**
+ * @brief Array of strings describing statistics
+ */
+static const struct nss_gmac_ethtool_stats gmac_gstrings_stats[] = {
+	{"rx_bytes", NSS_GMAC_STAT(rx_bytes)},
+	{"rx_packets", NSS_GMAC_STAT(rx_packets)},
+	{"rx_errors", NSS_GMAC_STAT(rx_errors)},
+	{"rx_receive_errors", NSS_GMAC_STAT(rx_receive_errors)},
+	{"rx_overflow_errors", NSS_GMAC_STAT(rx_overflow_errors)},
+	{"rx_descriptor_errors", NSS_GMAC_STAT(rx_descriptor_errors)},
+	{"rx_watchdog_timeout_errors", NSS_GMAC_STAT(rx_watchdog_timeout_errors)},
+	{"rx_crc_errors", NSS_GMAC_STAT(rx_crc_errors)},
+	{"rx_late_collision_errors", NSS_GMAC_STAT(rx_late_collision_errors)},
+	{"rx_dribble_bit_errors", NSS_GMAC_STAT(rx_dribble_bit_errors)},
+	{"rx_length_errors", NSS_GMAC_STAT(rx_length_errors)},
+	{"rx_ip_header_errors", NSS_GMAC_STAT(rx_ip_header_errors)},
+	{"rx_ip_payload_errors", NSS_GMAC_STAT(rx_ip_payload_errors)},
+	{"rx_no_buffer_errors", NSS_GMAC_STAT(rx_no_buffer_errors)},
+	{"rx_transport_csum_bypassed", NSS_GMAC_STAT(rx_transport_csum_bypassed)},
+	{"tx_bytes", NSS_GMAC_STAT(tx_bytes)},
+	{"tx_packets", NSS_GMAC_STAT(tx_packets)},
+	{"tx_collisions", NSS_GMAC_STAT(tx_collisions)},
+	{"tx_errors", NSS_GMAC_STAT(tx_errors)},
+	{"tx_jabber_timeout_errors", NSS_GMAC_STAT(tx_jabber_timeout_errors)},
+	{"tx_frame_flushed_errors", NSS_GMAC_STAT(tx_frame_flushed_errors)},
+	{"tx_loss_of_carrier_errors", NSS_GMAC_STAT(tx_loss_of_carrier_errors)},
+	{"tx_no_carrier_errors", NSS_GMAC_STAT(tx_no_carrier_errors)},
+	{"tx_late_collision_errors", NSS_GMAC_STAT(tx_late_collision_errors)},
+	{"tx_excessive_collision_errors", NSS_GMAC_STAT(tx_excessive_collision_errors)},
+	{"tx_excessive_deferral_errors", NSS_GMAC_STAT(tx_excessive_deferral_errors)},
+	{"tx_underflow_errors", NSS_GMAC_STAT(tx_underflow_errors)},
+	{"tx_ip_header_errors", NSS_GMAC_STAT(tx_ip_header_errors)},
+	{"tx_ip_payload_errors", NSS_GMAC_STAT(tx_ip_payload_errors)},
+	{"tx_dropped", NSS_GMAC_STAT(tx_dropped)},
+	{"rx_missed", NSS_GMAC_STAT(rx_missed)},
+	{"fifo_overflows", NSS_GMAC_STAT(fifo_overflows)},
+	{"rx_scatter_errors", NSS_GMAC_STAT(rx_scatter_errors)},
+	{"pmt_interrupts", NSS_GMAC_STAT(hw_errs[0])},
+	{"mmc_interrupts", NSS_GMAC_STAT(hw_errs[0]) + (1 * HW_ERR_SIZE)},
+	{"line_interface_interrupts", NSS_GMAC_STAT(hw_errs[0]) + (2 * HW_ERR_SIZE)},
+	{"fatal_bus_error_interrupts", NSS_GMAC_STAT(hw_errs[0]) + (3 * HW_ERR_SIZE)},
+	{"rx_buffer_unavailable_interrupts", NSS_GMAC_STAT(hw_errs[0]) + (4 * HW_ERR_SIZE)},
+	{"rx_process_stopped_interrupts", NSS_GMAC_STAT(hw_errs[0]) + (5 * HW_ERR_SIZE)},
+	{"tx_underflow_interrupts", NSS_GMAC_STAT(hw_errs[0]) + (6 * HW_ERR_SIZE)},
+	{"rx_overflow_interrupts", NSS_GMAC_STAT(hw_errs[0]) + (7 * HW_ERR_SIZE)},
+	{"tx_jabber_timeout_interrutps", NSS_GMAC_STAT(hw_errs[0]) + (8 * HW_ERR_SIZE)},
+	{"tx_process_stopped_interrutps", NSS_GMAC_STAT(hw_errs[0]) + (9 * HW_ERR_SIZE)},
+	{"gmac_total_ticks", NSS_GMAC_STAT(gmac_total_ticks)},
+	{"gmac_worst_case_ticks", NSS_GMAC_STAT(gmac_worst_case_ticks)},
+	{"gmac_iterations", NSS_GMAC_STAT(gmac_iterations)},
+};
+
+#define NSS_GMAC_STATS_LEN	ARRAY_SIZE(gmac_gstrings_stats)
+
+
+/*
+ * Convert NSS GMAC speed id to ethtool id.
+ * @param[in] nss gmac specific speed
+ * @return Returns ethtool speed
+ */
+static int32_t nss_gmac_to_ethtool_speed(int32_t speed)
+{
+	int32_t ret;
+
+	switch (speed) {
+	case SPEED10:
+		ret = SPEED_10;
+		break;
+
+	case SPEED100:
+		ret = SPEED_100;
+		break;
+
+	case SPEED1000:
+		ret = SPEED_1000;
+		break;
+
+	default:
+		ret = SPEED_UNKNOWN;
+		break;
+	}
+
+	return ret;
+}
+
+/*
+ * Convert NSS GMAC duplex id to ethtool id.
+ * @param[in] nss gmac specific duplex value
+ * @return Returns ethtool duplex value
+ */
+static int32_t nss_gmac_to_ethtool_duplex(int32_t duplex)
+{
+	int32_t ret;
+
+	switch (duplex) {
+	case HALFDUPLEX:
+		ret = DUPLEX_HALF;
+		break;
+
+	case FULLDUPLEX:
+		ret = DUPLEX_FULL;
+		break;
+
+	default:
+		ret = DUPLEX_UNKNOWN;
+		break;
+	}
+
+	return ret;
+}
+
+
+/**
+ * @brief Get number of strings that describe requested objects.
+ * @param[in] pointer to struct net_device.
+ * @param[in] string set to get
+ */
+static int32_t nss_gmac_get_strset_count(struct net_device *netdev,
+					 int32_t sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return NSS_GMAC_STATS_LEN;
+
+	default:
+		netdev_dbg(netdev, "%s: Invalid string set", __func__);
+		return -EOPNOTSUPP;
+	}
+}
+
+
+/**
+ * @brief Get strings that describe requested objects
+ * @param[in] pointer to struct net_device.
+ * @param[in] string set to get
+ * @param[out] pointer to buffer
+ */
+static void nss_gmac_get_strings(struct net_device *netdev, uint32_t stringset,
+			  uint8_t *data)
+{
+	uint8_t *p = data;
+	uint32_t i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < NSS_GMAC_STATS_LEN; i++) {
+			memcpy(p, gmac_gstrings_stats[i].stat_string,
+				ETH_GSTRING_LEN);
+			p += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+
+/**
+ * @brief Get statistics
+ * @param[in] pointer to struct net_device.
+ * @param[in] string set to get
+ * @param[out] pointer to buffer
+ */
+static void nss_gmac_get_ethtool_stats(struct net_device *netdev,
+				struct ethtool_stats *stats, uint64_t *data)
+{
+	struct nss_gmac_dev *gmacdev = netdev_priv(netdev);
+	int32_t i;
+	uint8_t *p = NULL;
+
+	spin_lock_bh(&gmacdev->stats_lock);
+	for (i = 0; i < NSS_GMAC_STATS_LEN; i++) {
+		p = (uint8_t *)&(gmacdev->nss_stats) +
+					gmac_gstrings_stats[i].stat_offset;
+		data[i] = *(uint32_t *)p;
+	}
+	spin_unlock_bh(&gmacdev->stats_lock);
+}
+
+
+/**
+ * @brief Return driver information.
+ *	  Note: Fields are 32 bytes in length.
+ * @param[in] pointer to struct net_device.
+ * @param[out] pointer to struct ethtool_drvinfo
+ */
+static void nss_gmac_get_drvinfo(struct net_device *dev,
+						struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, nss_gmac_driver_string, DRVINFO_LEN);
+	strlcpy(info->version, nss_gmac_driver_version, DRVINFO_LEN);
+	strlcpy(info->bus_info, "NSS", ETHTOOL_BUSINFO_LEN);
+}
+
+
+/**
+ * @brief Return pause parameters.
+ * @param[in] pointer to struct net_device.
+ * @param[in] pointer to ethtool_pauseparam structure.
+ */
+static void nss_gmac_get_pauseparam(struct net_device *netdev,
+			     struct ethtool_pauseparam *pause)
+{
+	struct nss_gmac_dev *gmacdev = NULL;
+
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	BUG_ON(gmacdev == NULL);
+	BUG_ON(gmacdev->netdev != netdev);
+
+	pause->rx_pause = gmacdev->pause & FLOW_CTRL_RX ? 1 : 0;
+	pause->tx_pause = gmacdev->pause & FLOW_CTRL_TX ? 1 : 0;
+
+	pause->autoneg = AUTONEG_ENABLE;
+}
+
+/**
+ * @brief Return pause parameters.
+ * @param[in] pointer to struct net_device.
+ * @param[in] pointer to ethtool_pauseparam structure.
+ */
+static int nss_gmac_set_pauseparam(struct net_device *netdev,
+			    struct ethtool_pauseparam *pause)
+{
+	struct nss_gmac_dev *gmacdev = NULL;
+	struct phy_device *phydev = NULL;
+
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	BUG_ON(gmacdev == NULL);
+	BUG_ON(gmacdev->netdev != netdev);
+
+	/* set flow control settings */
+	gmacdev->pause = 0;
+	if (pause->rx_pause)
+		gmacdev->pause |= FLOW_CTRL_RX;
+
+	if (pause->tx_pause)
+		gmacdev->pause |= FLOW_CTRL_TX;
+
+	/*
+	 * If the link polling for this GMAC is disabled, we do not
+	 * attempt to make changes to the PHY settings.
+	 */
+	if (!test_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags))
+		return 0;
+
+	phydev = gmacdev->phydev;
+
+	/* Update flow control advertisment */
+	phydev->advertising &= ~(ADVERTISED_Pause | ADVERTISED_Asym_Pause);
+
+	if (gmacdev->pause & FLOW_CTRL_RX)
+		phydev->advertising |=
+				(ADVERTISED_Pause | ADVERTISED_Asym_Pause);
+
+	if (gmacdev->pause & FLOW_CTRL_TX)
+		phydev->advertising |= ADVERTISED_Asym_Pause;
+
+	genphy_config_aneg(gmacdev->phydev);
+
+	return 0;
+}
+
+/**
+ * @brief Restart autonegotiation
+ * @param[in] pointer to struct net_device.
+ */
+static int nss_gmac_nway_reset(struct net_device *netdev)
+{
+	struct nss_gmac_dev *gmacdev = NULL;
+
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	BUG_ON(gmacdev == NULL);
+
+	if (!netif_running(netdev))
+		return -EAGAIN;
+
+	/*
+	 * If the link polling for this GMAC is disabled, we probably
+	 * do not have a PHY attached.
+	 */
+	if (!test_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags))
+		return -EINVAL;
+
+	if (!test_bit(__NSS_GMAC_AUTONEG, &gmacdev->flags))
+		return -EINVAL;
+
+	genphy_restart_aneg(gmacdev->phydev);
+
+	return 0;
+}
+
+
+
+/**
+ * @brief Get Wake On Lan settings
+ * @param[in] pointer to struct net_device.
+ * @param[in] pointer to struct ethtool_wolinfo.
+ */
+static void nss_gmac_get_wol(struct net_device *netdev,
+			     struct ethtool_wolinfo *wol)
+{
+	wol->supported = 0;
+	wol->wolopts = 0;
+}
+
+/**
+ * @brief Get message level
+ * @param[in] pointer to struct net_device.
+ */
+static uint32_t nss_gmac_get_msglevel(struct net_device *netdev)
+{
+	return 0;
+}
+
+/**
+ * @brief Get Settings
+ * @param[in] pointer to struct net_device.
+ * @param[in] pointer to struct ethtool_cmd.
+ */
+static int32_t nss_gmac_get_settings(struct net_device *netdev,
+			      struct ethtool_cmd *ecmd)
+{
+	struct nss_gmac_dev *gmacdev = NULL;
+	struct phy_device *phydev = NULL;
+	uint16_t phyreg;
+
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	BUG_ON(gmacdev == NULL);
+
+	/* Populate supported capabilities */
+	ecmd->supported = NSS_GMAC_SUPPORTED_FEATURES;
+
+	/*
+	 * If the speed/duplex for this GMAC is forced and we are not
+	 * polling for link state changes, return the values as specified by
+	 * platform. This will be true for GMACs connected to switch, and
+	 * interfaces that do not use a PHY.
+	 */
+	if (!test_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags)) {
+		if (gmacdev->forced_speed != SPEED_UNKNOWN) {
+			ethtool_cmd_speed_set(ecmd, nss_gmac_to_ethtool_speed(gmacdev->forced_speed));
+			ecmd->duplex = nss_gmac_to_ethtool_duplex(gmacdev->forced_duplex);
+			ecmd->mdio_support = 0;
+			ecmd->lp_advertising = 0;
+			return 0;
+		} else {
+			/* Non-link polled interfaced must have a forced
+			 * speed/duplex
+			 */
+			return -EIO;
+		}
+	}
+
+	phydev = gmacdev->phydev;
+
+	/* update PHY status */
+	if (genphy_read_status(phydev) != 0)
+		return -EIO;
+
+	/* Populate capabilities advertised by self */
+	ecmd->advertising = phydev->advertising;
+
+	ecmd->autoneg = phydev->autoneg;
+	ethtool_cmd_speed_set(ecmd, phydev->speed);
+	ecmd->duplex = phydev->duplex;
+
+	if (gmacdev->link_state == LINKDOWN) {
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
+	}
+
+	ecmd->port = PORT_TP;
+	ecmd->phy_address = gmacdev->phy_base;
+	ecmd->transceiver = XCVR_EXTERNAL;
+
+	ecmd->mdio_support = ETH_MDIO_SUPPORTS_C22;
+
+	/* Populate capabilities advertised by link partner */
+	phyreg = nss_gmac_mii_rd_reg(gmacdev, gmacdev->phy_base, MII_LPA);
+	if (phyreg & LPA_10HALF)
+		ecmd->lp_advertising |= ADVERTISED_10baseT_Half;
+
+	if (phyreg & LPA_10FULL)
+		ecmd->lp_advertising |= ADVERTISED_10baseT_Full;
+
+	if (phyreg & LPA_100HALF)
+		ecmd->lp_advertising |= ADVERTISED_100baseT_Half;
+
+	if (phyreg & LPA_100FULL)
+		ecmd->lp_advertising |= ADVERTISED_100baseT_Full;
+
+	if (phyreg & LPA_PAUSE_CAP)
+		ecmd->lp_advertising |= ADVERTISED_Pause;
+
+	if (phyreg & LPA_PAUSE_ASYM)
+		ecmd->lp_advertising |= ADVERTISED_Asym_Pause;
+
+	phyreg = nss_gmac_mii_rd_reg(gmacdev, gmacdev->phy_base, MII_STAT1000);
+	if (phyreg & LPA_1000HALF)
+		ecmd->lp_advertising |= ADVERTISED_1000baseT_Half;
+
+	if (phyreg & LPA_1000FULL)
+		ecmd->lp_advertising |= ADVERTISED_1000baseT_Full;
+
+	return 0;
+}
+
+/**
+ * @brief Set Settings
+ * @param[in] pointer to struct net_device.
+ * @param[in] pointer to struct ethtool_cmd.
+ */
+static int32_t nss_gmac_set_settings(struct net_device *netdev,
+			      struct ethtool_cmd *ecmd)
+{
+	struct nss_gmac_dev *gmacdev = NULL;
+	struct phy_device *phydev = NULL;
+
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	BUG_ON(gmacdev == NULL);
+
+	/*
+	 * If the speed for this GMAC is forced, do not proceed with the
+	 * changes below. This would be true for GMACs connected to switch
+	 * and interfaces that do not use a PHY.
+	 */
+	if (gmacdev->forced_speed != SPEED_UNKNOWN)
+		return -EPERM;
+
+	phydev = gmacdev->phydev;
+
+	mutex_lock(&gmacdev->link_mutex);
+	nss_gmac_linkdown(gmacdev);
+	mutex_unlock(&gmacdev->link_mutex);
+
+	phydev->advertising = ecmd->advertising;
+	phydev->autoneg = ecmd->autoneg;
+
+	phydev->speed = ethtool_cmd_speed(ecmd);
+	phydev->duplex = ecmd->duplex;
+
+	if (ecmd->autoneg == AUTONEG_ENABLE)
+		test_and_set_bit(__NSS_GMAC_AUTONEG, &gmacdev->flags);
+	else
+		test_and_clear_bit(__NSS_GMAC_AUTONEG, &gmacdev->flags);
+
+	genphy_config_aneg(phydev);
+
+	return 0;
+}
+
+
+/**
+ * Ethtool operations
+ */
+struct ethtool_ops nss_gmac_ethtool_ops = {
+	.get_drvinfo = &nss_gmac_get_drvinfo,
+	.get_link = &ethtool_op_get_link,
+	.get_msglevel = &nss_gmac_get_msglevel,
+	.get_pauseparam = &nss_gmac_get_pauseparam,
+	.set_pauseparam = &nss_gmac_set_pauseparam,
+	.nway_reset = &nss_gmac_nway_reset,
+	.get_wol = &nss_gmac_get_wol,
+	.get_settings = &nss_gmac_get_settings,
+	.set_settings = &nss_gmac_set_settings,
+	.get_strings = &nss_gmac_get_strings,
+	.get_sset_count = &nss_gmac_get_strset_count,
+	.get_ethtool_stats = &nss_gmac_get_ethtool_stats,
+};
+
+
+/**
+ * @brief Register ethtool_ops
+ * @param[in] pointer to struct net_device
+ */
+void nss_gmac_ethtool_register(struct net_device *netdev)
+{
+	netdev->ethtool_ops = &nss_gmac_ethtool_ops;
+}
+
diff --git a/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_init.c b/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_init.c
new file mode 100644
index 0000000..76202bf
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_init.c
@@ -0,0 +1,1131 @@
+/*
+ **************************************************************************
+ * Copyright (c) 2014-2015, The Linux Foundation. All rights reserved.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for
+ * any purpose with or without fee is hereby granted, provided that the
+ * above copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
+ * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ **************************************************************************
+ */
+/*
+ * @file
+ * This file defines the APIs for accessing global NSS GMAC
+ * software interface register space.
+ * ------------------------REVISION HISTORY-----------------------------
+ * Qualcomm Atheros         01/Mar/2013              Created
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/notifier.h>
+
+#include <nss_gmac_dev.h>
+#include <nss_gmac_clocks.h>
+#include <nss_gmac_network_interface.h>
+
+#ifndef CONFIG_OF
+#include <mach/msm_nss_gmac.h>
+#include <mach/msm_nss_macsec.h>
+#include <mach/socinfo.h>
+#else
+#include <linux/of.h>
+#include <msm_nss_gmac.h>
+#include <msm_nss_macsec.h>
+
+#define SOCINFO_VERSION_MAJOR(ver) (ver)
+#endif
+
+/* Initialize notifier list for NSS GMAC */
+static BLOCKING_NOTIFIER_HEAD(nss_gmac_notifier_list);
+
+/**
+ * @brief Emulation specific initialization.
+ *
+ * @param[in] nss_gmac_dev *
+ * @return void
+ */
+void nss_gmac_spare_ctl(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t val;
+	uint32_t count;
+	uint32_t id = gmacdev->macid;
+	uint32_t *nss_base = (uint32_t *)(gmacdev->ctx->nss_base);
+
+	if (!gmacdev->emulation)
+		return;
+
+	val = 1 << id;
+	nss_gmac_set_reg_bits(nss_base, NSS_ETH_SPARE_CTL, val);
+
+	val = nss_gmac_read_reg(nss_base, NSS_ETH_SPARE_CTL);
+	netdev_dbg(gmacdev->netdev, "NSS_ETH_SPARE_CTL - 0x%x", val);
+
+	val = 1 << id;
+	nss_gmac_clear_reg_bits(nss_base, NSS_ETH_SPARE_CTL, val);
+
+	val = nss_gmac_read_reg(nss_base, NSS_ETH_SPARE_CTL);
+	netdev_dbg(gmacdev->netdev,
+		      "NSS_ETH_SPARE_CTL - 0x%x after clear for gmac %d", val,
+		      id);
+
+	val = nss_gmac_read_reg(nss_base, NSS_ETH_SPARE_STAT);
+	netdev_dbg(gmacdev->netdev,
+		      "NSS_ETH_SPARE_STAT - 0x%x; gmac %d spare ctl reset...",
+		      val, id);
+	count = 0;
+	while ((val & (1 << id)) != (1 << id)) {
+		usleep_range(10000, 12000);
+		val = nss_gmac_read_reg(nss_base,
+					NSS_ETH_SPARE_STAT);
+		if (count++ > 20) {
+			netdev_dbg(gmacdev->netdev,
+				      "!!!!!! Timeout waiting for NSS_ETH_SPARE_STAT bit to set.");
+			break;
+		}
+	}
+}
+
+
+/**
+ * @brief QSGMII Init for Emulation
+ *
+ * @param[in] nss_gmac_dev *
+ * @return void
+ */
+static void nss_gmac_rumi_qsgmii_init(struct nss_gmac_dev *gmacdev)
+{
+	struct nss_gmac_dev *gmac1_dev;
+	uint16_t phy_reg_val;
+	uint32_t *qsgmii_base;
+	uint8_t *nss_base;
+
+	netdev_dbg(gmacdev->netdev, "%s:", __func__);
+
+	gmac1_dev = gmacdev->ctx->nss_gmac[1];
+	qsgmii_base = gmacdev->ctx->qsgmii_base;
+	nss_base = (uint8_t *)(gmacdev->ctx->nss_base);
+
+	/*
+	 * _SGMII: Set only bit 3, with no polling for reset completion
+	 * inside status register for GMAC2
+	 */
+	netdev_dbg(gmacdev->netdev, "Eth2: spare_ctl_reg value before setting = 0x%x",
+	      nss_gmac_read_reg((uint32_t *)nss_base, NSS_ETH_SPARE_CTL));
+	nss_gmac_set_reg_bits((uint32_t *)nss_base, NSS_ETH_SPARE_CTL, 0x8);
+	netdev_dbg(gmacdev->netdev, "Eth2: spare_ctl_reg value after setting = 0x%x",
+	      nss_gmac_read_reg((uint32_t *)nss_base, NSS_ETH_SPARE_CTL));
+
+	netdev_dbg(gmac1_dev->netdev, "%s: GMAC1's MACBASE = 0x%x", __func__,
+							gmac1_dev->mac_base);
+
+	/* Put PHY in SGMII Mode */
+	nss_gmac_write_reg(qsgmii_base, QSGMII_PHY_MODE_CTL, 0x0);
+
+	/* Set SERDES signal detects for channel2, bypass SDO */
+	nss_gmac_write_reg(qsgmii_base, PCS_QSGMII_CTL, 0x4213B);
+
+	/* SERDES Configuration, drive strength settings through GMAC1's MDIO */
+
+	/* Configure SERDES to SGMII-1+SGMII-2 mode */
+	nss_gmac_mii_wr_reg(gmac1_dev, 0x0, 0x1, 0x8241);
+	nss_gmac_mii_wr_reg(gmac1_dev, 0x0, 0x3, 0xB909);
+
+	/* Writes to SERDES registers using MDIO debug registers */
+	nss_gmac_mii_wr_reg(gmac1_dev, 0x0, 0x1D, 0x10);
+	phy_reg_val = nss_gmac_mii_rd_reg(gmac1_dev, 0x0, 0x1E);
+
+	nss_gmac_mii_wr_reg(gmac1_dev, 0x0, 0x1D, 0x10);
+	nss_gmac_mii_wr_reg(gmac1_dev, 0x0, 0x1E, 0x2000);
+	nss_gmac_mii_wr_reg(gmac1_dev, 0x0, 0x1D, 0x10);
+	nss_gmac_mii_wr_reg(gmac1_dev, 0x0, 0x1E, 0x0);
+	nss_gmac_mii_wr_reg(gmac1_dev, 0x0, 0x1D, 0x10);
+
+	phy_reg_val = nss_gmac_mii_rd_reg(gmac1_dev, 0x0, 0x1E);
+
+	nss_gmac_mii_wr_reg(gmac1_dev, 0x0, 0x1D, 0x0A);
+	phy_reg_val = nss_gmac_mii_rd_reg(gmac1_dev, 0x0, 0x1E);
+
+	netdev_dbg(gmacdev->netdev, "Reg 1A reset val:  0x%x", phy_reg_val);
+
+	nss_gmac_mii_wr_reg(gmac1_dev, 0x0, 0x1D, 0x0A);
+	nss_gmac_mii_wr_reg(gmac1_dev, 0x0, 0x1E, 0x3F9);
+	nss_gmac_mii_wr_reg(gmac1_dev, 0x0, 0x1D, 0x0A);
+
+	phy_reg_val = nss_gmac_mii_rd_reg(gmac1_dev, 0x0, 0x1E);
+
+	netdev_dbg(gmacdev->netdev, "Reg 1A after programming:  0x%x",
+								phy_reg_val);
+	nss_gmac_mii_wr_reg(gmac1_dev, 0x0, 0x18, 0x30);
+
+	/* Put PCS in SGMII Mode */
+	nss_gmac_write_reg(qsgmii_base, PCS_QSGMII_SGMII_MODE, 0x0);
+
+	/* Channel 2 force speed */
+	nss_gmac_write_reg(qsgmii_base, PCS_ALL_CH_CTL, 0xF0000600);
+}
+
+
+/**
+ * @brief QSGMII dev init
+ *
+ * @param[in] nss_gmac_dev *
+ * @return void
+ */
+void nss_gmac_qsgmii_dev_init(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t val = 0;
+	uint32_t id = gmacdev->macid;
+	uint8_t *nss_base = (uint8_t *)(gmacdev->ctx->nss_base);
+	uint32_t *qsgmii_base = (uint32_t *)(gmacdev->ctx->qsgmii_base);
+	uint32_t qsgmii_tx_drv;
+	uint32_t qsgmii_tx_slew;
+	uint32_t qsgmii_deemphasis;
+
+	if (gmacdev->emulation)
+		nss_gmac_rumi_qsgmii_init(gmacdev);
+
+	if (gmacdev->phy_mii_type == GMAC_INTF_SGMII) {
+		switch (gmacdev->macid) {
+		case 1:
+			if (SOCINFO_VERSION_MAJOR(gmacdev->ctx->socver) < 2) {
+				qsgmii_tx_drv = QSGMII_PHY_TX_DRV_AMP(0xC);
+				qsgmii_tx_slew = QSGMII_PHY_TX_SLEW(0x2);
+				qsgmii_deemphasis =  QSGMII_PHY_DEEMPHASIS_LVL(0x2);
+			} else {
+				qsgmii_tx_drv = QSGMII_PHY_TX_DRV_AMP(0xD);
+				qsgmii_tx_slew = QSGMII_PHY_TX_SLEW(0);
+				qsgmii_deemphasis =  QSGMII_PHY_DEEMPHASIS_LVL(0);
+			}
+
+			nss_gmac_write_reg((uint32_t *)qsgmii_base,
+				   QSGMII_PHY_QSGMII_CTL, QSGMII_PHY_CDR_EN
+					  | QSGMII_PHY_RX_FRONT_EN
+					  | QSGMII_PHY_RX_SIGNAL_DETECT_EN
+					  | QSGMII_PHY_TX_DRIVER_EN
+					  | QSGMII_PHY_QSGMII_EN
+					  | QSGMII_PHY_PHASE_LOOP_GAIN(0x4)
+					  | QSGMII_PHY_RX_DC_BIAS(0x2)
+					  | QSGMII_PHY_RX_INPUT_EQU(0x1)
+					  | QSGMII_PHY_CDR_PI_SLEW(0x2)
+					  | qsgmii_tx_slew
+					  | qsgmii_deemphasis
+					  | qsgmii_tx_drv);
+
+			val = nss_gmac_read_reg((uint32_t *)qsgmii_base,
+							QSGMII_PHY_QSGMII_CTL);
+			netdev_dbg(gmacdev->netdev, "%s: QSGMII_PHY_QSGMII_CTL(0x%x) - 0x%x",
+					__func__, QSGMII_PHY_QSGMII_CTL, val);
+
+			break;
+
+		case 2:
+			nss_gmac_write_reg((uint32_t *)qsgmii_base,
+				   QSGMII_PHY_SGMII_1_CTL, QSGMII_PHY_CDR_EN
+					  | QSGMII_PHY_RX_FRONT_EN
+					  | QSGMII_PHY_RX_SIGNAL_DETECT_EN
+					  | QSGMII_PHY_TX_DRIVER_EN
+					  | QSGMII_PHY_QSGMII_EN
+					  | QSGMII_PHY_PHASE_LOOP_GAIN(0x4)
+					  | QSGMII_PHY_RX_DC_BIAS(0x3)
+					  | QSGMII_PHY_RX_INPUT_EQU(0x1)
+					  | QSGMII_PHY_CDR_PI_SLEW(0x2)
+					  | QSGMII_PHY_TX_DRV_AMP(0xC));
+
+			val = nss_gmac_read_reg((uint32_t *)qsgmii_base,
+							QSGMII_PHY_SGMII_1_CTL);
+			netdev_dbg(gmacdev->netdev, "%s: QSGMII_PHY_SGMII_1_CTL(0x%x) - 0x%x",
+					__func__, QSGMII_PHY_SGMII_1_CTL, val);
+			break;
+
+		case 3:
+			nss_gmac_write_reg((uint32_t *)qsgmii_base,
+				   QSGMII_PHY_SGMII_2_CTL, QSGMII_PHY_CDR_EN
+					  | QSGMII_PHY_RX_FRONT_EN
+					  | QSGMII_PHY_RX_SIGNAL_DETECT_EN
+					  | QSGMII_PHY_TX_DRIVER_EN
+					  | QSGMII_PHY_QSGMII_EN
+					  | QSGMII_PHY_PHASE_LOOP_GAIN(0x4)
+					  | QSGMII_PHY_RX_DC_BIAS(0x3)
+					  | QSGMII_PHY_RX_INPUT_EQU(0x1)
+					  | QSGMII_PHY_CDR_PI_SLEW(0x2)
+					  | QSGMII_PHY_TX_DRV_AMP(0xC));
+
+			val = nss_gmac_read_reg((uint32_t *)qsgmii_base,
+							QSGMII_PHY_SGMII_2_CTL);
+			netdev_dbg(gmacdev->netdev, "%s: QSGMII_PHY_SGMII_2_CTL(0x%x) - 0x%x",
+					__func__, QSGMII_PHY_SGMII_2_CTL, val);
+			break;
+		}
+	}
+
+	/* Enable clk for GMACn */
+	val = 0;
+	if ((gmacdev->phy_mii_type == GMAC_INTF_SGMII)
+			|| (gmacdev->phy_mii_type == GMAC_INTF_QSGMII)) {
+		val |= GMACn_QSGMII_RX_CLK(id) | GMACn_QSGMII_TX_CLK(id);
+	}
+
+	nss_gmac_clear_reg_bits((uint32_t *)nss_base, NSS_QSGMII_CLK_CTL, val);
+
+	val = nss_gmac_read_reg((uint32_t *)nss_base, NSS_QSGMII_CLK_CTL);
+	netdev_dbg(gmacdev->netdev, "%s: NSS_QSGMII_CLK_CTL(0x%x) - 0x%x",
+		      __func__, NSS_QSGMII_CLK_CTL, val);
+
+	/* Enable autonegotiation between PCS and PHY */
+	if (test_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags)) {
+		nss_gmac_clear_reg_bits(qsgmii_base, PCS_ALL_CH_CTL,
+					PCS_CHn_SPEED_MASK(gmacdev->macid));
+		nss_gmac_clear_reg_bits(qsgmii_base, PCS_ALL_CH_CTL,
+					PCS_CHn_FORCE_SPEED(gmacdev->macid));
+	}
+}
+
+
+/**
+ * @brief Clear all NSS GMAC interface registers.
+ * @return returns 0 on success.
+ */
+static void nss_gmac_clear_all_regs(uint32_t *nss_base)
+{
+	nss_gmac_clear_reg_bits((uint32_t *)nss_base,
+				NSS_ETH_CLK_GATE_CTL, 0xFFFFFFFF);
+	nss_gmac_clear_reg_bits((uint32_t *)nss_base,
+				NSS_ETH_CLK_DIV0, 0xFFFFFFFF);
+	nss_gmac_clear_reg_bits((uint32_t *)nss_base,
+				NSS_ETH_CLK_DIV1, 0xFFFFFFFF);
+	nss_gmac_clear_reg_bits((uint32_t *)nss_base,
+				NSS_ETH_CLK_SRC_CTL, 0xFFFFFFFF);
+	nss_gmac_clear_reg_bits((uint32_t *)nss_base,
+				NSS_ETH_CLK_INV_CTL, 0xFFFFFFFF);
+	nss_gmac_clear_reg_bits((uint32_t *)nss_base,
+				NSS_GMAC0_CTL, 0xFFFFFFFF);
+	nss_gmac_clear_reg_bits((uint32_t *)nss_base,
+				NSS_GMAC1_CTL, 0xFFFFFFFF);
+	nss_gmac_clear_reg_bits((uint32_t *)nss_base,
+				NSS_GMAC2_CTL, 0xFFFFFFFF);
+	nss_gmac_clear_reg_bits((uint32_t *)nss_base,
+				NSS_GMAC3_CTL, 0xFFFFFFFF);
+	nss_gmac_clear_reg_bits((uint32_t *)nss_base,
+				NSS_QSGMII_CLK_CTL, 0xFFFFFFFF);
+}
+
+#ifdef CONFIG_OF
+/**
+ * @brief Determine board type and return relevant
+ *	NSS GMAC Phy profile.
+ *
+ * @return Phy profile
+ */
+int32_t nss_gmac_get_phy_profile(void)
+{
+	if (of_machine_is_compatible("qcom,ipq8064"))
+		return NSS_GMAC_PHY_PROFILE_2R_2S;
+
+	return NSS_GMAC_PHY_PROFILE_1R_3S;
+}
+#endif
+
+/**
+ * @brief QSGMII common init
+ *
+ * @param[in] nss_gmac_dev *
+ * @return void
+ */
+static void nss_gmac_qsgmii_common_init(struct nss_gmac_global_ctx *ctx)
+{
+	uint32_t val;
+	uint32_t *qsgmii_base = ctx->qsgmii_base;
+
+	if (nss_gmac_get_phy_profile() == NSS_GMAC_PHY_PROFILE_QS) {
+		/* Configure QSGMII Block for QSGMII mode */
+
+		/* Put PHY in QSGMII Mode */
+		nss_gmac_write_reg(qsgmii_base, QSGMII_PHY_MODE_CTL,
+						QSGMII_PHY_MODE_QSGMII);
+
+		/* Put PCS in QSGMII Mode */
+		nss_gmac_write_reg(qsgmii_base, PCS_QSGMII_SGMII_MODE,
+						PCS_QSGMII_MODE_QSGMII);
+
+		nss_gmac_clear_reg_bits(qsgmii_base, QSGMII_PHY_QSGMII_CTL,
+						QSGMII_PHY_TX_SLEW_MASK);
+
+		goto out;
+	}
+
+	/* Configure QSGMII Block for 3xSGMII mode */
+
+	/* Put PHY in SGMII Mode */
+	nss_gmac_write_reg(qsgmii_base, QSGMII_PHY_MODE_CTL,
+							QSGMII_PHY_MODE_SGMII);
+
+	/* Put PCS in SGMII Mode */
+	nss_gmac_write_reg(qsgmii_base, PCS_QSGMII_SGMII_MODE,
+							PCS_QSGMII_MODE_SGMII);
+
+out:
+	val = nss_gmac_read_reg(qsgmii_base, QSGMII_PHY_MODE_CTL);
+	pr_debug("%s: qsgmii_base(0x%x) + QSGMII_PHY_MODE_CTL(0x%x): 0x%x",
+					__func__, (uint32_t)qsgmii_base,
+					(uint32_t)QSGMII_PHY_MODE_CTL, val);
+
+	val = nss_gmac_read_reg(qsgmii_base, PCS_QSGMII_SGMII_MODE);
+	pr_debug("%s: qsgmii_base(0x%x) + PCS_QSGMII_SGMII_MODE(0x%x): 0x%x",
+					 __func__, (uint32_t)qsgmii_base,
+					(uint32_t)PCS_QSGMII_SGMII_MODE, val);
+
+	/* Mode ctrl signal for mode selection */
+	nss_gmac_clear_reg_bits(qsgmii_base, PCS_MODE_CTL,
+			PCS_MODE_CTL_SGMII_MAC | PCS_MODE_CTL_SGMII_PHY);
+	nss_gmac_set_reg_bits(qsgmii_base, PCS_MODE_CTL,
+						PCS_MODE_CTL_SGMII_MAC);
+
+	/* Apply reset to PCS and release */
+	nss_gmac_write_reg((uint32_t *)(ctx->clk_ctl_base),
+					NSS_RESET_SPARE, 0x3FFFFFF);
+	udelay(100);
+	nss_gmac_write_reg((uint32_t *)(ctx->clk_ctl_base),
+					NSS_RESET_SPARE, 0x0);
+
+	val = nss_gmac_read_reg((uint32_t *)(ctx->clk_ctl_base),
+							NSS_RESET_SPARE);
+	pr_debug("%s: qsgmii_base(0x%x) + NSS_RESET_SPARE(0x%x): 0x%x",
+					__func__, (uint32_t)(ctx->clk_ctl_base),
+					(uint32_t)NSS_RESET_SPARE, val);
+
+	/* signal detect and channel enable */
+	nss_gmac_write_reg(qsgmii_base,
+		PCS_QSGMII_CTL, PCS_QSGMII_SW_VER_1_7
+		| PCS_QSGMII_ATHR_CSCO_AUTONEG
+		/*| PCS_QSGMII_CUTTHROUGH_TX | PCS_QSGMII_CUTTHROUGH_RX*/
+		| PCS_QSGMII_SHORT_THRESH | PCS_QSGMII_SHORT_LATENCY
+		| PCS_QSGMII_DEPTH_THRESH(1) | PCS_CHn_SERDES_SN_DETECT(0)
+		| PCS_CHn_SERDES_SN_DETECT(1) | PCS_CHn_SERDES_SN_DETECT(2)
+		| PCS_CHn_SERDES_SN_DETECT(3) | PCS_CHn_SERDES_SN_DETECT_2(0)
+		| PCS_CHn_SERDES_SN_DETECT_2(1) | PCS_CHn_SERDES_SN_DETECT_2(2)
+		| PCS_CHn_SERDES_SN_DETECT_2(3));
+	val = nss_gmac_read_reg(qsgmii_base, PCS_QSGMII_CTL);
+	pr_debug("%s: qsgmii_base(0x%x) + PCS_QSGMII_CTL(0x%x): 0x%x",
+	       __func__, (uint32_t)qsgmii_base, (uint32_t)PCS_QSGMII_CTL, val);
+
+	/* set debug bits */
+	nss_gmac_set_reg_bits((uint32_t *)qsgmii_base, PCS_ALL_CH_CTL,
+								0xF0000000);
+}
+
+
+/*
+ * @brief Initialization commom to all GMACs.
+ * @return returns 0 on success.
+ */
+int32_t nss_gmac_common_init(struct nss_gmac_global_ctx *ctx)
+{
+	uint32_t val;
+
+	spin_lock_init(&ctx->reg_lock);
+
+	nss_gmac_clear_all_regs((uint32_t *)ctx->nss_base);
+
+	nss_gmac_write_reg((uint32_t *)(ctx->qsgmii_base),
+		QSGMII_PHY_QSGMII_CTL, QSGMII_PHY_CDR_EN
+		| QSGMII_PHY_RX_FRONT_EN | QSGMII_PHY_RX_SIGNAL_DETECT_EN
+		| QSGMII_PHY_TX_DRIVER_EN | QSGMII_PHY_QSGMII_EN
+		| QSGMII_PHY_DEEMPHASIS_LVL(0x2)
+		| QSGMII_PHY_PHASE_LOOP_GAIN(0x2) | QSGMII_PHY_RX_DC_BIAS(0x2)
+		| QSGMII_PHY_RX_INPUT_EQU(0x1) | QSGMII_PHY_CDR_PI_SLEW(0x2)
+		| QSGMII_PHY_TX_SLEW(0x2) | QSGMII_PHY_TX_DRV_AMP(0xC));
+
+	nss_gmac_write_reg((uint32_t *)(ctx->qsgmii_base), PCS_CAL_LCKDT_CTL,
+								PCS_LCKDT_RST);
+	/*
+	 * TCSR cannot be accessed from HLOS drivers after XPUs are enabled.
+	 * TrustZone will initialize this register during init.
+	 *
+	 * nss_gmac_write_reg((msm_tcsr_base), 0xc0, 0x0);
+	 */
+
+	/*
+	 * Deaassert GMAC AHB reset
+	 */
+	nss_gmac_clear_reg_bits((uint32_t *)(ctx->clk_ctl_base),
+							GMAC_AHB_RESET, 0x1);
+	val = nss_gmac_read_reg(ctx->clk_ctl_base, GMAC_AHB_RESET);
+	pr_debug("%s: ctx->clk_ctl_base(0x%x) + GMAC_AHB_RESET(0x%x): 0x%x",
+					__func__, (uint32_t)ctx->clk_ctl_base,
+					(uint32_t)GMAC_AHB_RESET, val);
+
+	/* Bypass MACSEC */
+	nss_gmac_set_reg_bits((uint32_t *)(ctx->nss_base), NSS_MACSEC_CTL,
+				GMACn_MACSEC_BYPASS(1) | GMACn_MACSEC_BYPASS(2)
+				| GMACn_MACSEC_BYPASS(3));
+
+	val = nss_gmac_read_reg((uint32_t *)ctx->nss_base, NSS_MACSEC_CTL);
+	pr_debug("%s: nss_bsae(0x%x) + NSS_MACSEC_CTL(0x%x): 0x%x",
+					__func__, (uint32_t)ctx->nss_base,
+					(uint32_t)NSS_MACSEC_CTL, val);
+
+	nss_gmac_qsgmii_common_init(ctx);
+
+	/*
+	 * Initialize ACC_GMAC_CUST field of NSS_ACC_REG register
+	 * for GMAC and MACSEC memories.
+	 */
+	nss_gmac_clear_reg_bits((uint32_t *)(ctx->clk_ctl_base), NSS_ACC_REG,
+							GMAC_ACC_CUST_MASK);
+	val = nss_gmac_read_reg(ctx->clk_ctl_base, NSS_ACC_REG);
+	pr_debug("%s: ctx->clk_ctl_base(0x%x) + NSS_ACC_REG(0x%x): 0x%x",
+					__func__, (uint32_t)ctx->clk_ctl_base,
+					(uint32_t)NSS_ACC_REG, val);
+
+	return 0;
+}
+
+/**
+ * @brief Global common deinitialization.
+ * @return void
+ */
+void nss_gmac_common_deinit(struct nss_gmac_global_ctx *ctx)
+{
+	nss_gmac_clear_all_regs((uint32_t *)ctx->nss_base);
+
+	if (ctx->qsgmii_base) {
+		iounmap(ctx->qsgmii_base);
+		ctx->qsgmii_base = NULL;
+	}
+
+	if (ctx->clk_ctl_base) {
+		iounmap(ctx->clk_ctl_base);
+		ctx->clk_ctl_base = NULL;
+	}
+
+	if (ctx->nss_base) {
+		iounmap(ctx->nss_base);
+		ctx->nss_base = NULL;
+	}
+}
+
+/*
+ * @brief Return clock divider value for QSGMII PHY.
+ * @param[in] nss_gmac_dev *
+ * @return returns QSGMII clock divider value.
+ */
+static uint32_t clk_div_qsgmii(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t div;
+
+	switch (gmacdev->speed) {
+	case SPEED1000:
+		div = QSGMII_CLK_DIV_1000;
+		break;
+
+	case SPEED100:
+		div = QSGMII_CLK_DIV_100;
+		break;
+
+	case SPEED10:
+		div = QSGMII_CLK_DIV_10;
+		break;
+
+	default:
+		div = QSGMII_CLK_DIV_1000;
+		break;
+	}
+
+	return div;
+}
+
+/**
+ * @brief Return clock divider value for SGMII PHY.
+ * @param[in] nss_gmac_dev *
+ * @return returns SGMII clock divider value.
+ */
+static uint32_t clk_div_sgmii(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t div;
+
+	switch (gmacdev->speed) {
+	case SPEED1000:
+		div = SGMII_CLK_DIV_1000;
+		break;
+
+	case SPEED100:
+		div = SGMII_CLK_DIV_100;
+		break;
+
+	case SPEED10:
+		div = SGMII_CLK_DIV_10;
+		break;
+
+	default:
+		div = SGMII_CLK_DIV_1000;
+		break;
+	}
+
+	return div;
+}
+
+/**
+ * @brief Return clock divider value for RGMII PHY.
+ * @param[in] nss_gmac_dev *
+ * @return returns RGMII clock divider value.
+ */
+static uint32_t clk_div_rgmii(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t div;
+
+	switch (gmacdev->speed) {
+	case SPEED1000:
+		div = RGMII_CLK_DIV_1000;
+		break;
+
+	case SPEED100:
+		div = RGMII_CLK_DIV_100;
+		break;
+
+	case SPEED10:
+		div = RGMII_CLK_DIV_10;
+		break;
+
+	default:
+		div = RGMII_CLK_DIV_1000;
+		break;
+	}
+
+	return div;
+}
+
+/**
+ * @brief Return PCS Channel speed values
+ * @param[in] nss_gmac_dev *
+ * @return returns PCS speed values.
+ */
+static uint32_t get_pcs_speed(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t speed;
+
+	switch (gmacdev->speed) {
+	case SPEED1000:
+		speed = PCS_CH_SPEED_1000;
+		break;
+
+	case SPEED100:
+		speed = PCS_CH_SPEED_100;
+		break;
+
+	case SPEED10:
+		speed = PCS_CH_SPEED_10;
+		break;
+
+	default:
+		speed = PCS_CH_SPEED_1000;
+		break;
+	}
+
+	return speed;
+}
+/**
+ * @brief Set GMAC speed.
+ * @param[in] nss_gmac_dev *
+ * @return returns 0 on success.
+ */
+int32_t nss_gmac_dev_set_speed(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t val = 0;
+	uint32_t id = gmacdev->macid;
+	uint32_t div = 0, pcs_speed = 0;
+	uint32_t clk = 0;
+	uint32_t *nss_base = (uint32_t *)(gmacdev->ctx->nss_base);
+	uint32_t *qsgmii_base = (uint32_t *)(gmacdev->ctx->qsgmii_base);
+	struct nss_gmac_speed_ctx gmac_speed_ctx = {0, 0};
+
+	switch (gmacdev->phy_mii_type) {
+	case GMAC_INTF_RGMII:
+		div = clk_div_rgmii(gmacdev);
+		break;
+
+	case GMAC_INTF_SGMII:
+		div = clk_div_sgmii(gmacdev);
+		break;
+
+	case GMAC_INTF_QSGMII:
+		div = clk_div_qsgmii(gmacdev);
+		break;
+
+	default:
+		netdev_dbg(gmacdev->netdev, "%s: Invalid MII type", __func__);
+		return -EINVAL;
+	}
+
+	/* Force speed control signal if link polling is disabled */
+	if (!test_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags)) {
+		if (gmacdev->phy_mii_type == GMAC_INTF_SGMII) {
+			pcs_speed = get_pcs_speed(gmacdev);
+			nss_gmac_set_reg_bits(qsgmii_base, PCS_ALL_CH_CTL,
+						PCS_CHn_FORCE_SPEED(id));
+			nss_gmac_clear_reg_bits(qsgmii_base, PCS_ALL_CH_CTL,
+						PCS_CHn_SPEED_MASK(id));
+			nss_gmac_set_reg_bits(qsgmii_base, PCS_ALL_CH_CTL,
+						PCS_CHn_SPEED(id, pcs_speed));
+		}
+	}
+
+	clk = 0;
+	/* Disable GMACn Tx/Rx clk */
+	if (gmacdev->phy_mii_type == GMAC_INTF_RGMII)
+		clk |= GMACn_RGMII_RX_CLK(id) | GMACn_RGMII_TX_CLK(id);
+	else
+		clk |= GMACn_GMII_RX_CLK(id) | GMACn_GMII_TX_CLK(id);
+	nss_gmac_clear_reg_bits(nss_base, NSS_ETH_CLK_GATE_CTL, clk);
+
+	/* set clock divider */
+	val = nss_gmac_read_reg(nss_base, NSS_ETH_CLK_DIV0);
+	val &= ~GMACn_CLK_DIV(id, GMACn_CLK_DIV_SIZE);
+	val |= GMACn_CLK_DIV(id, div);
+	nss_gmac_write_reg(nss_base, NSS_ETH_CLK_DIV0, val);
+
+	/* Enable GMACn Tx/Rx clk */
+	nss_gmac_set_reg_bits(nss_base, NSS_ETH_CLK_GATE_CTL, clk);
+
+	val = nss_gmac_read_reg(nss_base, NSS_ETH_CLK_DIV0);
+	netdev_dbg(gmacdev->netdev, "%s:NSS_ETH_CLK_DIV0(0x%x) - 0x%x",
+		      __func__, NSS_ETH_CLK_DIV0, val);
+
+	if (gmacdev->phy_mii_type == GMAC_INTF_SGMII
+	    || gmacdev->phy_mii_type == GMAC_INTF_QSGMII) {
+		nss_gmac_clear_reg_bits(qsgmii_base, PCS_MODE_CTL,
+					PCS_MODE_CTL_CHn_AUTONEG_EN(id));
+
+		/* Enable autonegotiation from MII register of PHY */
+		if (test_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags)) {
+			nss_gmac_set_reg_bits(qsgmii_base, PCS_MODE_CTL,
+					      PCS_MODE_CTL_CHn_AUTONEG_EN(id));
+		}
+
+		val = nss_gmac_read_reg(qsgmii_base, PCS_MODE_CTL);
+		netdev_dbg(gmacdev->netdev, "%s: qsgmii_base(0x%x) + PCS_MODE_CTL(0x%x): 0x%x",
+		       __func__, (uint32_t)qsgmii_base, (uint32_t)PCS_MODE_CTL, val);
+
+	}
+
+	/* Notify link speed change to notifier list */
+	gmac_speed_ctx.mac_id = gmacdev->macid;
+	gmac_speed_ctx.speed = gmacdev->speed;
+	blocking_notifier_call_chain(&nss_gmac_notifier_list,
+					NSS_GMAC_SPEED_SET, &gmac_speed_ctx);
+
+	return 0;
+}
+
+/**
+ * @brief GMAC device initializaton.
+ * @param[in] nss_gmac_dev *
+ * @return void
+ */
+void nss_gmac_dev_init(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t val = 0;
+	uint32_t div = 0;
+	uint32_t id = gmacdev->macid;
+	uint32_t *nss_base = (uint32_t *)(gmacdev->ctx->nss_base);
+	struct nss_gmac_global_ctx *ctx = gmacdev->ctx;
+
+	/*
+	 * Initialize wake and sleep counter values of
+	 * GMAC memory footswitch control.
+	 */
+	nss_gmac_set_reg_bits(ctx->clk_ctl_base, GMAC_COREn_CLK_FS(id),
+							 GMAC_FS_S_W_VAL);
+	val = nss_gmac_read_reg(ctx->clk_ctl_base, GMAC_COREn_CLK_FS(id));
+	netdev_dbg(gmacdev->netdev, "%s: ctx->clk_ctl_base(0x%x) + GMAC_COREn_CLK_FS(%d)(0x%x): 0x%x",
+		       __func__, (uint32_t)ctx->clk_ctl_base, id, (uint32_t)GMAC_COREn_CLK_FS(id), val);
+
+	/*
+	 * Bring up GMAC core clock
+	 */
+	/* a) Program GMAC_COREn_CLK_SRC_CTL register */
+	nss_gmac_clear_reg_bits(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC_CTL(id),
+				GMAC_DUAL_MN8_SEL |
+				GMAC_CLK_ROOT_ENA |
+				GMAC_CLK_LOW_PWR_ENA);
+	nss_gmac_set_reg_bits(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC_CTL(id),
+			      GMAC_CLK_ROOT_ENA);
+
+	val = nss_gmac_read_reg(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC_CTL(id));
+	netdev_dbg(gmacdev->netdev, "%s: ctx->clk_ctl_base(0x%x) + GMAC_COREn_CLK_SRC_CTL(%d)(0x%x): 0x%x",
+				__func__, (uint32_t)ctx->clk_ctl_base, id,
+				(uint32_t)GMAC_COREn_CLK_SRC_CTL(id), val);
+
+	/* b) Program M & D values in GMAC_COREn_CLK_SRC[0,1]_MD register. */
+	nss_gmac_write_reg(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC0_MD(id), 0);
+	nss_gmac_write_reg(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC1_MD(id), 0);
+	nss_gmac_set_reg_bits(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC0_MD(id),
+			      GMAC_CORE_CLK_M_VAL | GMAC_CORE_CLK_D_VAL);
+	nss_gmac_set_reg_bits(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC1_MD(id),
+			      GMAC_CORE_CLK_M_VAL | GMAC_CORE_CLK_D_VAL);
+
+	val = nss_gmac_read_reg(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC0_MD(id));
+	netdev_dbg(gmacdev->netdev, "%s: ctx->clk_ctl_base(0x%x) + GMAC_COREn_CLK_SRC0_MD(%d)(0x%x): 0x%x",
+				__func__, (uint32_t)ctx->clk_ctl_base, id,
+				(uint32_t)GMAC_COREn_CLK_SRC0_MD(id), val);
+	val = nss_gmac_read_reg(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC1_MD(id));
+	netdev_dbg(gmacdev->netdev, "%s: ctx->clk_ctl_base(0x%x) + GMAC_COREn_CLK_SRC1_MD(%d)(0x%x): 0x%x",
+				__func__, (uint32_t)ctx->clk_ctl_base, id,
+				(uint32_t)GMAC_COREn_CLK_SRC1_MD(id), val);
+
+	/* c) Program N values on GMAC_COREn_CLK_SRC[0,1]_NS register */
+	nss_gmac_write_reg(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC0_NS(id), 0);
+	nss_gmac_write_reg(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC1_NS(id), 0);
+	nss_gmac_set_reg_bits(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC0_NS(id),
+			      GMAC_CORE_CLK_N_VAL
+			      | GMAC_CORE_CLK_MNCNTR_EN
+			      | GMAC_CORE_CLK_MNCNTR_MODE_DUAL
+			      | GMAC_CORE_CLK_PRE_DIV_SEL_BYP
+			      | GMAC_CORE_CLK_SRC_SEL_PLL0);
+	nss_gmac_set_reg_bits(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC1_NS(id),
+			      GMAC_CORE_CLK_N_VAL
+			      | GMAC_CORE_CLK_MNCNTR_EN
+			      | GMAC_CORE_CLK_MNCNTR_MODE_DUAL
+			      | GMAC_CORE_CLK_PRE_DIV_SEL_BYP
+			      | GMAC_CORE_CLK_SRC_SEL_PLL0);
+
+	val = nss_gmac_read_reg(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC0_NS(id));
+	netdev_dbg(gmacdev->netdev, "%s: ctx->clk_ctl_base(0x%x) + GMAC_COREn_CLK_SRC0_NS(%d)(0x%x): 0x%x",
+				__func__, (uint32_t)ctx->clk_ctl_base, id,
+				(uint32_t)GMAC_COREn_CLK_SRC0_NS(id), val);
+	val = nss_gmac_read_reg(ctx->clk_ctl_base, GMAC_COREn_CLK_SRC1_NS(id));
+	netdev_dbg(gmacdev->netdev, "%s: ctx->clk_ctl_base(0x%x) + GMAC_COREn_CLK_SRC1_NS(%d)(0x%x): 0x%x",
+				__func__, (uint32_t)ctx->clk_ctl_base, id,
+				(uint32_t)GMAC_COREn_CLK_SRC1_NS(id), val);
+
+	/* d) Un-halt GMACn clock */
+	nss_gmac_clear_reg_bits(ctx->clk_ctl_base,
+		CLK_HALT_NSSFAB0_NSSFAB1_STATEA, GMACn_CORE_CLK_HALT(id));
+	val = nss_gmac_read_reg(ctx->clk_ctl_base,
+					CLK_HALT_NSSFAB0_NSSFAB1_STATEA);
+	netdev_dbg(gmacdev->netdev, "%s: ctx->clk_ctl_base(0x%x) + CLK_HALT_NSSFAB0_NSSFAB1_STATEA(0x%x): 0x%x",
+				__func__, (uint32_t)ctx->clk_ctl_base,
+				(uint32_t)CLK_HALT_NSSFAB0_NSSFAB1_STATEA, val);
+
+	/* e) CLK_COREn_CLK_CTL: select branch enable and disable clk invert */
+	nss_gmac_clear_reg_bits(ctx->clk_ctl_base, GMAC_COREn_CLK_CTL(id),
+							GMAC_CLK_INV);
+	nss_gmac_set_reg_bits(ctx->clk_ctl_base, GMAC_COREn_CLK_CTL(id),
+							GMAC_CLK_BRANCH_EN);
+	val = nss_gmac_read_reg(ctx->clk_ctl_base, GMAC_COREn_CLK_CTL(id));
+	netdev_dbg(gmacdev->netdev, "%s: ctx->clk_ctl_base(0x%x) + GMAC_COREn_CLK_CTL(%d)(0x%x): 0x%x",
+				__func__, (uint32_t)ctx->clk_ctl_base, id,
+				(uint32_t)GMAC_COREn_CLK_CTL(id), val);
+
+	/* Set GMACn Ctl: Phy interface select, IFG, AXI low power request
+	 * signal (CSYSREQ)
+	 */
+	val = GMAC_IFG_CTL(GMAC_IFG) | GMAC_IFG_LIMIT(GMAC_IFG) | GMAC_CSYS_REQ;
+	if (gmacdev->phy_mii_type == GMAC_INTF_RGMII)
+		val |= GMAC_PHY_RGMII;
+	else
+		val &= ~GMAC_PHY_RGMII;
+
+	nss_gmac_write_reg(nss_base, NSS_GMACn_CTL(id), 0x0);
+	nss_gmac_write_reg(nss_base, NSS_GMACn_CTL(id), val);
+
+	val = nss_gmac_read_reg(nss_base, NSS_GMACn_CTL(id));
+	netdev_dbg(gmacdev->netdev, "%s: nss_base(0x%x) + NSS_GMACn_CTL(%d)(0x%x): 0x%x",
+					__func__, (uint32_t)nss_base, id,
+					(uint32_t)NSS_GMACn_CTL(id), val);
+
+	/*
+	 * Optionally enable/disable MACSEC bypass.
+	 * We are doing this in nss_gmac_plat_init()
+	 */
+
+	/*
+	 * Deassert GMACn power on reset
+	 */
+	nss_gmac_clear_reg_bits(ctx->clk_ctl_base, GMAC_COREn_RESET(id), 0x1);
+
+	/* Configure clock dividers for 1000Mbps default */
+	gmacdev->speed = SPEED1000;
+	switch (gmacdev->phy_mii_type) {
+	case GMAC_INTF_RGMII:
+		div = clk_div_rgmii(gmacdev);
+		break;
+
+	case GMAC_INTF_SGMII:
+		div = clk_div_sgmii(gmacdev);
+		break;
+
+	case GMAC_INTF_QSGMII:
+		div = clk_div_qsgmii(gmacdev);
+		break;
+	}
+	val = nss_gmac_read_reg(nss_base, NSS_ETH_CLK_DIV0);
+	val &= ~GMACn_CLK_DIV(id, GMACn_CLK_DIV_SIZE);
+	val |= GMACn_CLK_DIV(id, div);
+	nss_gmac_write_reg(nss_base, NSS_ETH_CLK_DIV0, val);
+
+	val = nss_gmac_read_reg(nss_base, NSS_ETH_CLK_DIV0);
+	netdev_dbg(gmacdev->netdev, "%s: nss_base(0x%x) + NSS_ETH_CLK_DIV0(0x%x): 0x%x",
+		__func__, (uint32_t)nss_base, (uint32_t)NSS_ETH_CLK_DIV0, val);
+
+	/* Select Tx/Rx CLK source */
+	val = 0;
+	if (id == 0 || id == 1) {
+		if (gmacdev->phy_mii_type == GMAC_INTF_RGMII)
+			val |= (1 << id);
+	} else {
+		if (gmacdev->phy_mii_type == GMAC_INTF_SGMII)
+			val |= (1 << id);
+	}
+	nss_gmac_set_reg_bits(nss_base, NSS_ETH_CLK_SRC_CTL, val);
+
+	/* Enable xGMII clk for GMACn */
+	val = 0;
+	if (gmacdev->phy_mii_type == GMAC_INTF_RGMII)
+		val |= GMACn_RGMII_RX_CLK(id) | GMACn_RGMII_TX_CLK(id);
+	else
+		val |= GMACn_GMII_RX_CLK(id) | GMACn_GMII_TX_CLK(id);
+
+	/* Optionally configure RGMII CDC delay */
+
+	/* Enable PTP clock */
+	val |= GMACn_PTP_CLK(id);
+	nss_gmac_set_reg_bits(nss_base, NSS_ETH_CLK_GATE_CTL, val);
+
+	if ((gmacdev->phy_mii_type == GMAC_INTF_SGMII)
+	     || (gmacdev->phy_mii_type == GMAC_INTF_QSGMII)) {
+		nss_gmac_qsgmii_dev_init(gmacdev);
+		netdev_dbg(gmacdev->netdev, "SGMII Specific Init for GMAC%d Done!", id);
+	}
+}
+
+/**
+ * @brief Do macsec related initialization in gmac register scope.
+ * @return void.
+ */
+void nss_macsec_pre_init(void)
+{
+	uint32_t val = 0;
+	uint32_t *nss_base = (uint32_t *)ctx.nss_base;
+
+	/*
+	 * Initialize wake and sleep counter values of
+	 * MACSEC memory footswitch control.
+	 */
+	nss_gmac_write_reg(nss_base, NSS_MACSEC1_CORE_CLK_FS_CTL,
+						MACSEC_CLK_FS_CTL_S_W_VAL);
+	nss_gmac_write_reg(nss_base, NSS_MACSEC2_CORE_CLK_FS_CTL,
+						MACSEC_CLK_FS_CTL_S_W_VAL);
+	nss_gmac_write_reg(nss_base, NSS_MACSEC3_CORE_CLK_FS_CTL,
+						MACSEC_CLK_FS_CTL_S_W_VAL);
+
+	/* MACSEC reset */
+	nss_gmac_write_reg(ctx.clk_ctl_base, MACSEC_CORE1_RESET, 1);
+	nss_gmac_write_reg(ctx.clk_ctl_base, MACSEC_CORE2_RESET, 1);
+	nss_gmac_write_reg(ctx.clk_ctl_base, MACSEC_CORE3_RESET, 1);
+	msleep(100);
+
+	/* Deassert MACSEC reset */
+	nss_gmac_write_reg(ctx.clk_ctl_base, MACSEC_CORE1_RESET, 0);
+	nss_gmac_write_reg(ctx.clk_ctl_base, MACSEC_CORE2_RESET, 0);
+	nss_gmac_write_reg(ctx.clk_ctl_base, MACSEC_CORE3_RESET, 0);
+
+	/* Enable MACSEC clocks */
+	val = nss_gmac_read_reg(nss_base, NSS_ETH_CLK_GATE_CTL);
+	val |= (MACSEC_CORE_CLKEN_VAL | MACSEC_GMII_RX_CLKEN_VAL |
+						MACSEC_GMII_TX_CLKEN_VAL);
+	nss_gmac_write_reg(nss_base, NSS_ETH_CLK_GATE_CTL, val);
+
+	/* Bypass all MACSECs */
+	nss_gmac_write_reg(nss_base, NSS_MACSEC_CTL, MACSEC_EXT_BYPASS_EN_MASK |
+						MACSEC_DP_RST_VAL);
+}
+EXPORT_SYMBOL(nss_macsec_pre_init);
+
+/**
+ * @brief reset MACSEC IFG register
+ * @param[in] gmac_id
+ * @return void
+ */
+static void nss_gmac_ifg_reset(uint32_t gmac_id)
+{
+	uint32_t val = 0;
+	uint32_t *nss_base = (uint32_t *)ctx.nss_base;
+
+	val = nss_gmac_read_reg(nss_base, NSS_GMACn_CTL(gmac_id));
+	val &= ~(IFG_MASK | GMAC_IFG_LIMIT(IFG_MASK));
+	val |= (GMAC_IFG_CTL(GMAC_IFG) | GMAC_IFG_LIMIT(GMAC_IFG));
+	nss_gmac_write_reg(nss_base, NSS_GMACn_CTL(gmac_id), val);
+}
+
+/**
+ * @brief set gmac link status into expected state
+ * @param[in] gmac_id
+ * @param[in] link_state
+ * @return void
+ */
+static void nss_gmac_link_status_set(uint32_t gmac_id, uint32_t link_state)
+{
+	struct nss_gmac_dev *gmac_dev = NULL;
+
+	gmac_dev = ctx.nss_gmac[gmac_id];
+	if (gmac_dev == NULL)
+		return;
+
+	if (!test_bit(__NSS_GMAC_UP, &gmac_dev->flags))
+		return;
+
+	if (link_state == LINKDOWN && gmac_dev->link_state == LINKUP)
+		nss_gmac_linkdown(gmac_dev);
+	else if (link_state == LINKUP && gmac_dev->link_state == LINKDOWN)
+		nss_gmac_linkup(gmac_dev);
+}
+
+/**
+ * @brief enable or disable MACSEC bypass function
+ * @param[in] gmac_id
+ * @param[in] enable
+ * @return void
+ */
+void nss_macsec_bypass_en_set(uint32_t gmac_id, bool enable)
+{
+	uint32_t val = 0;
+	uint32_t *nss_base = (uint32_t *)ctx.nss_base;
+	struct nss_gmac_dev *gmac_dev = NULL;
+	uint32_t link_reset_flag = 0;
+	struct nss_gmac_speed_ctx gmac_speed_ctx = {0, 0};
+
+	if ((gmac_id == 0) || (gmac_id > 3))
+		return;
+
+	gmac_dev = ctx.nss_gmac[gmac_id];
+	if (gmac_dev == NULL)
+		return;
+
+	mutex_lock(&gmac_dev->link_mutex);
+
+	/* If gmac is in link up state, it need to simulate link down event
+	 * before setting IFG and simulate link up event after the operation
+	 */
+	if (gmac_dev->link_state == LINKUP)
+		link_reset_flag = 1;
+
+	/* simulate a gmac link down event */
+	if (link_reset_flag)
+		nss_gmac_link_status_set(gmac_id, LINKDOWN);
+
+	/* Set MACSEC_IFG value */
+	if (enable) {
+		nss_gmac_ifg_reset(gmac_id);
+	} else {
+		val = nss_gmac_read_reg(nss_base, NSS_GMACn_CTL(gmac_id));
+		val &= ~(IFG_MASK | GMAC_IFG_LIMIT(IFG_MASK));
+		val |= (GMAC_IFG_CTL(MACSEC_IFG) | GMAC_IFG_LIMIT(MACSEC_IFG));
+		nss_gmac_write_reg(nss_base, NSS_GMACn_CTL(gmac_id), val);
+	}
+
+	/* Enable/Disable MACSEC for related port */
+	val = nss_gmac_read_reg(nss_base, NSS_MACSEC_CTL);
+	val |= MACSEC_DP_RST_VAL;
+	if (enable)
+		val |= (1<<(gmac_id - 1));
+	else
+		val &= ~(1<<(gmac_id - 1));
+	nss_gmac_write_reg(nss_base, NSS_MACSEC_CTL, val);
+
+	/* simulate a gmac link up event */
+	if (link_reset_flag)
+		nss_gmac_link_status_set(gmac_id, LINKUP);
+
+	mutex_unlock(&gmac_dev->link_mutex);
+
+	/* Set MACSEC speed */
+	gmac_speed_ctx.mac_id = gmac_dev->macid;
+	gmac_speed_ctx.speed = gmac_dev->speed;
+	blocking_notifier_call_chain(&nss_gmac_notifier_list,
+					NSS_GMAC_SPEED_SET, &gmac_speed_ctx);
+}
+EXPORT_SYMBOL(nss_macsec_bypass_en_set);
+
+/**
+ * @brief  Do macsec related exist function in gmac register scope
+ * @return void
+ */
+void nss_macsec_pre_exit(void)
+{
+	uint32_t *nss_base = (uint32_t *)ctx.nss_base;
+	struct nss_gmac_dev *gmac_dev = NULL;
+	uint32_t gmac_id = 0;
+	uint32_t link_reset_flag = 0;
+
+	/* MACSEC reset */
+	nss_gmac_write_reg(ctx.clk_ctl_base, MACSEC_CORE1_RESET, 1);
+	nss_gmac_write_reg(ctx.clk_ctl_base, MACSEC_CORE2_RESET, 1);
+	nss_gmac_write_reg(ctx.clk_ctl_base, MACSEC_CORE3_RESET, 1);
+
+	/* Bypass all MACSECs */
+	nss_gmac_write_reg(nss_base, NSS_MACSEC_CTL,
+				MACSEC_EXT_BYPASS_EN_MASK | MACSEC_DP_RST_VAL);
+
+	/* Reset GMAC_IFG value */
+	for (gmac_id = 1; gmac_id < 4; gmac_id++) {
+		gmac_dev = ctx.nss_gmac[gmac_id];
+		if (gmac_dev == NULL)
+			continue;
+
+		/*
+		 * If gmac is in link up state, it need to simulate link down
+		 * event before setting IFG and simulate link up event after the
+		 * operation
+		 */
+		link_reset_flag = 0;
+
+		mutex_lock(&gmac_dev->link_mutex);
+
+		if (gmac_dev->link_state == LINKUP)
+			link_reset_flag = 1;
+
+		/* simulate a gmac link down event */
+		if (link_reset_flag)
+			nss_gmac_link_status_set(gmac_id, LINKDOWN);
+
+		nss_gmac_ifg_reset(gmac_id);
+
+		/* simulate a gmac link up event */
+		if (link_reset_flag)
+			nss_gmac_link_status_set(gmac_id, LINKUP);
+
+		mutex_unlock(&gmac_dev->link_mutex);
+	}
+}
+EXPORT_SYMBOL(nss_macsec_pre_exit);
+
+/**
+ * @brief register notifier into gmac module
+ * @param[in] struct notifier_block *
+ * @return void
+ */
+void nss_gmac_link_state_change_notify_register(struct notifier_block *nb)
+{
+	blocking_notifier_chain_register(&nss_gmac_notifier_list, nb);
+}
+EXPORT_SYMBOL_GPL(nss_gmac_link_state_change_notify_register);
+
+/**
+ * @brief unregister notifier into gmac module
+ * @param[in] struct notifier_block *
+ * @return void
+ */
+void nss_gmac_link_state_change_notify_unregister(struct notifier_block *nb)
+{
+	blocking_notifier_chain_unregister(&nss_gmac_notifier_list, nb);
+}
+EXPORT_SYMBOL_GPL(nss_gmac_link_state_change_notify_unregister);
diff --git a/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_mdiobus.c b/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_mdiobus.c
new file mode 100644
index 0000000..94c5d33
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_mdiobus.c
@@ -0,0 +1,187 @@
+/*
+ **************************************************************************
+ * Copyright (c) 2013-2015, The Linux Foundation. All rights reserved.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for
+ * any purpose with or without fee is hereby granted, provided that the
+ * above copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
+ * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ **************************************************************************
+ */
+/*
+ * @file
+ * IPQ806x MDIO bus support.
+ *
+ * @note Many of the functions other than the device specific functions
+ *  changes for operating system other than Linux 2.6.xx
+ *-----------------------------REVISION HISTORY--------------------------------
+ * Qualcomm Atheros		09/Jun/2013				Created
+ */
+
+#include <linux/version.h>
+#include <linux/kernel.h>
+#include <linux/bitops.h>
+#include <linux/phy.h>
+#include <linux/device.h>
+
+#ifdef CONFIG_OF
+#include <msm_nss_gmac.h>
+#else
+#include <mach/msm_nss_gmac.h>
+#endif
+
+#include <nss_gmac_dev.h>
+#include <nss_gmac_network_interface.h>
+
+
+static int32_t phy_irq[PHY_MAX_ADDR];
+
+
+/**
+ * @brief MDIO bus read
+ * @param[in] pointer to struct mii_bus
+ * @param[in] Phy MDIO address
+ * @param[in] Register number
+ * @return Contents of MDIO register
+ */
+static int32_t nss_gmac_mdiobus_read(struct mii_bus *bus, int32_t phy_id,
+							int32_t regnum)
+{
+	int32_t status;
+	uint16_t data;
+	struct nss_gmac_dev *gmacdev;
+
+	gmacdev = (struct nss_gmac_dev *)bus->priv;
+
+	status = nss_gmac_read_phy_reg((uint32_t *)gmacdev->mac_base,
+					phy_id, regnum,
+					&data, gmacdev->mdc_clk_div);
+
+	if (status != 0)
+		data = 0;
+
+	return (int32_t)data;
+}
+
+
+/**
+ * @brief MDIO bus write
+ * @param[in] pointer to struct mii_bus
+ * @param[in] Phy MDIO address
+ * @param[in] Register number
+ * @param[in] Value to write
+ * @return 0 on Success
+ */
+static int32_t nss_gmac_mdiobus_write(struct mii_bus *bus, int32_t phy_id,
+						int32_t regnum, uint16_t val)
+{
+	struct nss_gmac_dev *gmacdev;
+
+	gmacdev = (struct nss_gmac_dev *)bus->priv;
+
+	nss_gmac_write_phy_reg((uint32_t *)gmacdev->mac_base, phy_id,
+				regnum, val, gmacdev->mdc_clk_div);
+
+	return 0;
+}
+
+
+/**
+ * @brief MDIO bus reset
+ * @param[in] pointer to struct mii_bus
+ * @return 0 on Success
+ */
+int32_t nss_gmac_mdiobus_reset(struct mii_bus *bus)
+{
+	struct nss_gmac_dev *gmacdev;
+
+	gmacdev = (struct nss_gmac_dev *)bus->priv;
+	gmacdev->mdc_clk_div = MDC_CLK_DIV;
+	netdev_dbg(gmacdev->netdev, "%s: GMAC%d MDC Clk div set to - 0x%x",
+		      __func__, gmacdev->macid, gmacdev->mdc_clk_div);
+
+	return 0;
+}
+
+
+/**
+ * @brief Initialize and register MDIO bus
+ * @param[in] pointer to nss_gmac_dev
+ * @return 0 on Success
+ */
+int32_t nss_gmac_init_mdiobus(struct nss_gmac_dev *gmacdev)
+{
+	struct mii_bus *miibus = NULL;
+	struct phy_device *phydev = NULL;
+
+	miibus = mdiobus_alloc();
+	if (miibus == NULL)
+		return -ENOMEM;
+
+	miibus->name = "nss gmac mdio bus";
+	snprintf(miibus->id, MII_BUS_ID_SIZE, "mdiobus%x", gmacdev->macid);
+
+	miibus->priv = (void *)gmacdev;
+	miibus->read = nss_gmac_mdiobus_read;
+	miibus->write = nss_gmac_mdiobus_write;
+	miibus->reset = nss_gmac_mdiobus_reset;
+	mutex_init(&(miibus->mdio_lock));
+	miibus->parent = &(gmacdev->pdev->dev);
+
+	phy_irq[gmacdev->phy_base] = PHY_POLL;
+	miibus->irq = phy_irq;
+	miibus->phy_mask = ~((uint32_t)(1 << gmacdev->phy_base));
+
+	if (mdiobus_register(miibus) != 0) {
+		mdiobus_free(miibus);
+		netdev_dbg(gmacdev->netdev, "%s: mdiobus_reg failed", __func__);
+		return -EIO;
+	}
+
+	phydev = miibus->phy_map[gmacdev->phy_base];
+	if (!phydev) {
+		netdev_dbg(gmacdev->netdev, "%s: No phy device", __func__);
+		mdiobus_unregister(miibus);
+		mdiobus_free(miibus);
+		return -ENODEV;
+	}
+
+	switch (gmacdev->phy_mii_type) {
+	case GMAC_INTF_RGMII:
+		phydev->interface = PHY_INTERFACE_MODE_RGMII;
+		break;
+
+	case GMAC_INTF_SGMII:
+		phydev->interface = PHY_INTERFACE_MODE_SGMII;
+		break;
+
+	case GMAC_INTF_QSGMII:
+		phydev->interface = PHY_INTERFACE_MODE_SGMII;
+		break;
+	}
+
+	gmacdev->miibus = miibus;
+	return 0;
+}
+
+
+/**
+ * @brief De-initialize MDIO bus
+ * @param[in] pointer to nss_gmac_dev
+ * @return void
+ */
+void nss_gmac_deinit_mdiobus(struct nss_gmac_dev *gmacdev)
+{
+	mdiobus_unregister(gmacdev->miibus);
+	mdiobus_free(gmacdev->miibus);
+	gmacdev->miibus = NULL;
+}
+
+
diff --git a/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_tx_rx_offload.c b/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_tx_rx_offload.c
new file mode 100644
index 0000000..2dc9f69
--- /dev/null
+++ b/drivers/net/ethernet/atheros/nss-gmac/nss_gmac_tx_rx_offload.c
@@ -0,0 +1,1175 @@
+/*
+ * Copyright (c) 2013-2015, The Linux Foundation. All rights reserved.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
+ * SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
+ * RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT
+ * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
+ * USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+/*
+ * @file
+ * This is the network dependent layer to handle network related functionality.
+ * This file is tightly coupled to neworking frame work of linux kernel.
+ * The functionality carried out in this file should be treated as an
+ * example only if the underlying operating system is not Linux.
+ *
+ * @note Many of the functions other than the device specific functions
+ *  changes for operating system other than Linux 2.6.xx
+ *-----------------------------REVISION HISTORY---------------------------------
+ * Qualcomm Atheros		15/Feb/2013			Created
+ */
+
+#include <linux/version.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/workqueue.h>
+#include <linux/bitops.h>
+#include <linux/phy.h>
+#include <linux/interrupt.h>
+
+#include <nss_gmac_dev.h>
+#include <nss_gmac_network_interface.h>
+
+#define NSS_GMAC_NAPI_BUDGET	64
+#define dma_int_enable		(dma_ie_normal | dma_int_tx_norm_mask | dma_int_rx_norm_mask)
+
+/**
+ * This sets up the transmit Descriptor queue in ring or chain mode.
+ * This function is tightly coupled to the platform and operating system
+ * Device is interested only after the descriptors are setup. Therefore this
+ * function is not included in the device driver API. This function should be
+ * treated as an example code to design the descriptor structures for ring mode
+ * or chain mode.
+ * This function depends on the device structure for allocation consistent
+ * dma-able memory in case of linux.
+ *	- Allocates the memory for the descriptors.
+ *	- Initialize the Busy and Next descriptors indices to 0(Indicating
+ *	  first descriptor).
+ *	- Initialize the Busy and Next descriptors to first descriptor address.
+ *	- Initialize the last descriptor with the endof ring in case of ring
+ *	  mode.
+ *	- Initialize the descriptors in chain mode.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] pointer to device structure.
+ * @param[in] number of descriptor expected in tx descriptor queue.
+ * @param[in] whether descriptors to be created in RING mode or CHAIN mode.
+ * @return 0 upon success. Error code upon failure.
+ * @note This function fails if allocation fails for required number of
+ * descriptors in Ring mode, but in chain mode function returns -ENOMEM in the
+ * process of descriptor chain creation. once returned from this function user
+ * should for gmacdev->tx_desc_count to see how many descriptors are there in
+ * the chain.
+ * Should continue further only if the number of descriptors in the
+ * chain meets the requirements.
+ */
+static int32_t nss_gmac_setup_tx_desc_queue(struct nss_gmac_dev *gmacdev,
+						struct device *dev,
+						uint32_t no_of_desc,
+						uint32_t desc_mode)
+{
+	int32_t i;
+	struct dma_desc *first_desc = NULL;
+	dma_addr_t dma_addr;
+
+	gmacdev->tx_desc_count = 0;
+
+	BUG_ON(desc_mode != RINGMODE);
+	BUG_ON((no_of_desc & (no_of_desc - 1)) != 0);
+
+	netdev_dbg(gmacdev->netdev, "Total size of memory required for Tx Descriptors in Ring Mode = 0x%08x"
+			, (uint32_t) ((sizeof(struct dma_desc) * no_of_desc)));
+
+	first_desc = dma_alloc_coherent(dev, sizeof(struct dma_desc) * no_of_desc
+					, &dma_addr, GFP_KERNEL);
+	if (first_desc == NULL) {
+		netdev_dbg(gmacdev->netdev,
+				"Error in Tx Descriptors memory allocation");
+		return -ENOMEM;
+	}
+
+	gmacdev->tx_desc_count = no_of_desc;
+	gmacdev->tx_desc = first_desc;
+	gmacdev->tx_desc_dma = dma_addr;
+	netdev_dbg(gmacdev->netdev, "Tx Descriptors in Ring Mode: No. of descriptors = %d base = 0x%08x dma = 0x%08x"
+			, no_of_desc, (uint32_t)first_desc, dma_addr);
+
+	for (i = 0; i < gmacdev->tx_desc_count; i++) {
+		nss_gmac_tx_desc_init_ring(gmacdev->tx_desc + i,
+					i == (gmacdev->tx_desc_count - 1));
+	}
+
+	gmacdev->tx_next = 0;
+	gmacdev->tx_busy = 0;
+	gmacdev->tx_next_desc = gmacdev->tx_desc;
+	gmacdev->tx_busy_desc = gmacdev->tx_desc;
+	gmacdev->busy_tx_desc = 0;
+
+	return 0;
+}
+
+
+/**
+ * This sets up the receive Descriptor queue in ring or chain mode.
+ * This function is tightly coupled to the platform and operating system
+ * Device is interested only after the descriptors are setup. Therefore this
+ * function is not included in the device driver API. This function should be
+ * treated as an example code to design the descriptor structures in ring mode
+ * or chain mode.
+ * This function depends on the device structure for allocation of
+ * consistent dma-able memory in case of linux.
+ *	- Allocates the memory for the descriptors.
+ *	- Initialize the Busy and Next descriptors indices to 0(Indicating first
+ *	  descriptor).
+ *	- Initialize the Busy and Next descriptors to first descriptor address.
+ *	- Initialize the last descriptor with the endof ring in case of ring
+ *	   mode.
+ *	- Initialize the descriptors in chain mode.
+ * @param[in] pointer to nss_gmac_dev.
+ * @param[in] pointer to device structure.
+ * @param[in] number of descriptor expected in rx descriptor queue.
+ * @param[in] whether descriptors to be created in RING mode or CHAIN mode.
+ * @return 0 upon success. Error code upon failure.
+ * @note This function fails if allocation fails for required number of
+ * descriptors in Ring mode, but in chain mode function returns -ENOMEM in the
+ * process of descriptor chain creation. once returned from this function user
+ * should for gmacdev->rx_desc_count to see how many descriptors are there in
+ * the chain.
+ * Should continue further only if the number of descriptors in the
+ * chain meets the requirements.
+ */
+static int32_t nss_gmac_setup_rx_desc_queue(struct nss_gmac_dev *gmacdev,
+						struct device *dev,
+						uint32_t no_of_desc,
+						uint32_t desc_mode)
+{
+	int32_t i;
+	struct dma_desc *first_desc = NULL;
+	dma_addr_t dma_addr;
+
+	gmacdev->rx_desc_count = 0;
+
+	BUG_ON(desc_mode != RINGMODE);
+	BUG_ON((no_of_desc & (no_of_desc - 1)) != 0);
+
+	netdev_dbg(gmacdev->netdev, "total size of memory required for Rx Descriptors in Ring Mode = 0x%08x"
+			, (uint32_t) ((sizeof(struct dma_desc) * no_of_desc)));
+
+	first_desc = dma_alloc_coherent(dev, sizeof(struct dma_desc) * no_of_desc
+					, &dma_addr, GFP_KERNEL);
+	if (first_desc == NULL) {
+		netdev_dbg(gmacdev->netdev, "Error in Rx Descriptor Memory allocation in Ring mode");
+		return -ENOMEM;
+	}
+
+	gmacdev->rx_desc_count = no_of_desc;
+	gmacdev->rx_desc = first_desc;
+	gmacdev->rx_desc_dma = dma_addr;
+	netdev_dbg(gmacdev->netdev, "Rx Descriptors in Ring Mode: No. of descriptors = %d base = 0x%08x dma = 0x%08x",
+			no_of_desc, (uint32_t)first_desc, dma_addr);
+
+	for (i = 0; i < gmacdev->rx_desc_count; i++) {
+		nss_gmac_rx_desc_init_ring(gmacdev->rx_desc + i,
+					i == (gmacdev->rx_desc_count - 1));
+	}
+
+	gmacdev->rx_next = 0;
+	gmacdev->rx_busy = 0;
+	gmacdev->rx_next_desc = gmacdev->rx_desc;
+	gmacdev->rx_busy_desc = gmacdev->rx_desc;
+	gmacdev->busy_rx_desc = 0;
+
+	return 0;
+}
+
+/*
+ * nss_gmac_rx_refill()
+ *	Refill the RX descrptor
+ */
+static inline void nss_gmac_rx_refill(struct nss_gmac_dev *gmacdev)
+{
+	int count = NSS_GMAC_RX_DESC_SIZE - gmacdev->busy_rx_desc;
+	dma_addr_t dma_addr;
+	int i;
+	struct sk_buff *skb;
+
+	for (i = 0; i < count; i++) {
+		skb = __netdev_alloc_skb(gmacdev->netdev,
+				NSS_GMAC_MINI_JUMBO_FRAME_MTU, GFP_KERNEL);
+		if (unlikely(skb == NULL)) {
+			netdev_dbg(gmacdev->netdev, "Unable to allocate skb, will try next time");
+			break;
+		}
+		skb_reserve(skb, NET_IP_ALIGN);
+		dma_addr = dma_map_single(&gmacdev->netdev->dev, skb->data,
+				NSS_GMAC_MINI_JUMBO_FRAME_MTU, DMA_FROM_DEVICE);
+		nss_gmac_set_rx_qptr(gmacdev, dma_addr,
+				NSS_GMAC_MINI_JUMBO_FRAME_MTU, (uint32_t)skb);
+	}
+}
+
+/*
+ * nss_gmac_rx()
+ *	Process RX packets
+ */
+static inline int nss_gmac_rx(struct nss_gmac_dev *gmacdev, int budget)
+{
+	struct dma_desc *desc = NULL;
+	int frame_length, busy;
+	uint32_t status;
+	struct sk_buff *rx_skb;
+
+	if (!gmacdev->busy_rx_desc) {
+		/* no desc are hold by gmac dma, we are done */
+		return 0;
+	}
+
+	busy = gmacdev->busy_rx_desc;
+	if (busy > budget)
+		busy = budget;
+
+	do {
+		desc = gmacdev->rx_busy_desc;
+		if (nss_gmac_is_desc_owned_by_dma(desc)) {
+			/* desc still hold by gmac dma, so we are done */
+			break;
+		}
+
+		status = desc->status;
+		rx_skb = (struct sk_buff *)desc->reserved1;
+		dma_unmap_single(&gmacdev->netdev->dev, desc->buffer1,
+				NSS_GMAC_MINI_JUMBO_FRAME_MTU, DMA_FROM_DEVICE);
+
+		if (likely(nss_gmac_is_rx_desc_valid(status))) {
+			/* We have a pkt to process get the frame length */
+			frame_length = nss_gmac_get_rx_desc_frame_length(status);
+			/* Get rid of FCS: 4 */
+			frame_length -= ETH_FCS_LEN;
+
+			/* Valid packet, collect stats */
+			gmacdev->stats.rx_packets++;
+			gmacdev->stats.rx_bytes += frame_length;
+
+			/* type_trans and deliver to linux */
+			skb_put(rx_skb, frame_length);
+			rx_skb->protocol = eth_type_trans(rx_skb, gmacdev->netdev);
+			rx_skb->ip_summed = CHECKSUM_UNNECESSARY;
+			napi_gro_receive(&gmacdev->napi, rx_skb);
+
+		} else {
+			gmacdev->stats.rx_errors++;
+			dev_kfree_skb(rx_skb);
+
+			if (status & (desc_rx_crc | desc_rx_collision |
+					desc_rx_damaged | desc_rx_dribbling |
+					desc_rx_length_error)) {
+				gmacdev->stats.rx_crc_errors += (status & desc_rx_crc) ? 1 : 0;
+				gmacdev->stats.collisions += (status & desc_rx_collision) ? 1 : 0;
+				gmacdev->stats.rx_over_errors += (status & desc_rx_damaged) ? 1 : 0;
+				gmacdev->stats.rx_frame_errors += (status & desc_rx_dribbling) ? 1 : 0;
+				gmacdev->stats.rx_length_errors += (status & desc_rx_length_error) ? 1 : 0;
+			}
+		}
+
+		nss_gmac_reset_rx_qptr(gmacdev);
+		busy--;
+	} while (busy > 0);
+	return budget - busy;
+}
+
+/*
+ * nss_gmac_process_tx_complete
+ *	Xmit complete, clear descriptor and free the skb
+ */
+static inline void nss_gmac_process_tx_complete(struct nss_gmac_dev *gmacdev)
+{
+	int busy, len;
+	uint32_t status;
+	struct dma_desc *desc = NULL;
+	struct sk_buff *skb;
+
+	spin_lock(&gmacdev->slock);
+	busy = gmacdev->busy_tx_desc;
+
+	if (!busy) {
+		/* No desc are hold by gmac dma, we are done */
+		spin_unlock(&gmacdev->slock);
+		return;
+	}
+
+	do {
+		desc = gmacdev->tx_busy_desc;
+		if (nss_gmac_is_desc_owned_by_dma(desc)) {
+			/* desc still hold by gmac dma, so we are done */
+			break;
+		}
+		len = (desc->length & desc_size1_mask) >> desc_size1_shift;
+		dma_unmap_single(&gmacdev->netdev->dev, desc->buffer1, len,
+								DMA_TO_DEVICE);
+
+		status = desc->status;
+		if (status & desc_tx_last) {
+			/* TX is done for this whole skb, we can free it */
+			skb = (struct sk_buff *)desc->reserved1;
+			BUG_ON(!skb);
+			dev_kfree_skb(skb);
+
+			if (unlikely(status & desc_error)) {
+				/* Some error happen, collect statistics */
+				gmacdev->stats.tx_errors++;
+				gmacdev->stats.tx_carrier_errors += (status & desc_tx_lost_carrier) ? 1 : 0;
+				gmacdev->stats.tx_carrier_errors += (status & desc_tx_no_carrier) ? 1 : 0;
+				gmacdev->stats.tx_window_errors += (status & desc_tx_late_collision) ? 1 : 0;
+				gmacdev->stats.tx_fifo_errors += (status & desc_tx_underflow) ? 1 : 0;
+			} else {
+				/* No error, recored tx pkts/bytes and
+				 * collision
+				 */
+				gmacdev->stats.tx_packets++;
+				gmacdev->stats.collisions += nss_gmac_get_tx_collision_count(status);
+				gmacdev->stats.tx_bytes += len;
+			}
+		}
+		nss_gmac_reset_tx_qptr(gmacdev);
+		busy--;
+	} while (busy > 0);
+	spin_unlock(&gmacdev->slock);
+}
+
+/*
+ * nss_gmac_poll
+ *	Scheduled by napi to process RX and TX complete
+ */
+int nss_gmac_poll(struct napi_struct *napi, int budget)
+{
+	struct nss_gmac_dev *gmacdev = container_of(napi,
+					struct nss_gmac_dev, napi);
+	int work_done;
+
+	nss_gmac_process_tx_complete(gmacdev);
+	work_done = nss_gmac_rx(gmacdev, budget);
+	nss_gmac_rx_refill(gmacdev);
+
+	if (work_done < budget) {
+		napi_complete(napi);
+		nss_gmac_enable_interrupt(gmacdev, dma_int_enable);
+	}
+	return work_done;
+}
+
+/*
+ * nss_gmac_handle_irq
+ *	Process IRQ and schedule napi
+ */
+irqreturn_t nss_gmac_handle_irq(int irq, void *ctx)
+{
+	struct nss_gmac_dev *gmacdev = (struct nss_gmac_dev *)ctx;
+
+	nss_gmac_clear_interrupt(gmacdev);
+
+	/*
+	 * Disable interrupt and schedule napi
+	 */
+	nss_gmac_disable_interrupt(gmacdev, dma_int_enable);
+	napi_schedule(&gmacdev->napi);
+	return IRQ_HANDLED;
+}
+
+/*
+ * nss_gmac_slowpath_if_open
+ *	Do slow path data plane open
+ */
+static int nss_gmac_slowpath_if_open(void *app_data, uint32_t tx_desc_ring,
+					uint32_t rx_desc_ring, uint32_t mode)
+{
+	return NSS_GMAC_SUCCESS;
+}
+
+static int nss_gmac_slowpath_if_close(void *app_data)
+{
+	return NSS_GMAC_SUCCESS;
+}
+
+static int nss_gmac_slowpath_if_link_state(void *app_data, uint32_t link_state)
+{
+	struct net_device *netdev = (struct net_device *)app_data;
+	struct nss_gmac_dev *gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+
+	if (link_state) {
+		napi_enable(&gmacdev->napi);
+		nss_gmac_enable_dma_rx(gmacdev);
+		nss_gmac_enable_dma_tx(gmacdev);
+		nss_gmac_enable_interrupt(gmacdev, dma_int_enable);
+	} else if (gmacdev->link_state == LINKUP) {
+		nss_gmac_disable_interrupt(gmacdev, dma_int_enable);
+		napi_disable(&gmacdev->napi);
+	}
+	return NSS_GMAC_SUCCESS;
+}
+
+static int nss_gmac_slowpath_if_mac_addr(void *app_data, uint8_t *addr)
+{
+	return NSS_GMAC_SUCCESS;
+}
+static int nss_gmac_slowpath_if_change_mtu(void *app_data, uint32_t mtu)
+{
+	return NSS_GMAC_SUCCESS;
+}
+
+static int nss_gmac_slowpath_if_xmit(void *app_data, struct sk_buff *skb)
+{
+	struct net_device *netdev = (struct net_device *)app_data;
+	struct nss_gmac_dev *gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	unsigned int len = skb_headlen(skb);
+	dma_addr_t dma_addr;
+	int nfrags = skb_shinfo(skb)->nr_frags;
+
+	/*
+	 * We don't have enough tx descriptor for this pkt, return busy
+	 */
+	if ((NSS_GMAC_TX_DESC_SIZE - gmacdev->busy_tx_desc) < nfrags + 1)
+		return NETDEV_TX_BUSY;
+
+	/*
+	 * Most likely, it is not a fragmented pkt, optimize for that
+	 */
+	if (likely(nfrags == 0)) {
+		dma_addr = dma_map_single(&netdev->dev, skb->data, len,
+								DMA_TO_DEVICE);
+		spin_lock(&gmacdev->slock);
+		nss_gmac_set_tx_qptr(gmacdev, dma_addr, len, (uint32_t)skb,
+				(skb->ip_summed == CHECKSUM_PARTIAL),
+				(desc_tx_last | desc_tx_first),
+				desc_own_by_dma);
+		gmacdev->busy_tx_desc++;
+		spin_unlock(&gmacdev->slock);
+		nss_gmac_resume_dma_tx(gmacdev);
+
+		return NSS_GMAC_SUCCESS;
+	}
+
+	/*
+	 * Handle frag pkts here if we decided to
+	 */
+
+	return NSS_GMAC_FAILURE;
+}
+
+struct nss_gmac_data_plane_ops nss_gmac_slowpath_ops = {
+	.open		= nss_gmac_slowpath_if_open,
+	.close		= nss_gmac_slowpath_if_close,
+	.link_state	= nss_gmac_slowpath_if_link_state,
+	.mac_addr	= nss_gmac_slowpath_if_mac_addr,
+	.change_mtu	= nss_gmac_slowpath_if_change_mtu,
+	.xmit		= nss_gmac_slowpath_if_xmit,
+};
+
+/**
+ * @brief Save GMAC statistics
+ * @param[in] pointer to gmac context
+ * @param[in] pointer to gmac statistics
+ * @return Returns void.
+ */
+static void nss_gmac_copy_stats(struct nss_gmac_dev *gmacdev,
+				struct nss_gmac_stats *gstat)
+{
+	BUG_ON(!spin_is_locked(&gmacdev->stats_lock));
+
+	gmacdev->nss_stats.rx_bytes += gstat->rx_bytes;
+	gmacdev->nss_stats.rx_packets += gstat->rx_packets;
+	gmacdev->nss_stats.rx_errors += gstat->rx_errors;
+	gmacdev->nss_stats.rx_receive_errors += gstat->rx_receive_errors;
+	gmacdev->nss_stats.rx_overflow_errors += gstat->rx_overflow_errors;
+	gmacdev->nss_stats.rx_descriptor_errors += gstat->rx_descriptor_errors;
+	gmacdev->nss_stats.rx_watchdog_timeout_errors +=
+		gstat->rx_watchdog_timeout_errors;
+	gmacdev->nss_stats.rx_crc_errors += gstat->rx_crc_errors;
+	gmacdev->nss_stats.rx_late_collision_errors +=
+		gstat->rx_late_collision_errors;
+	gmacdev->nss_stats.rx_dribble_bit_errors += gstat->rx_dribble_bit_errors;
+	gmacdev->nss_stats.rx_length_errors += gstat->rx_length_errors;
+	gmacdev->nss_stats.rx_ip_header_errors += gstat->rx_ip_header_errors;
+	gmacdev->nss_stats.rx_ip_payload_errors += gstat->rx_ip_payload_errors;
+	gmacdev->nss_stats.rx_no_buffer_errors += gstat->rx_no_buffer_errors;
+	gmacdev->nss_stats.rx_transport_csum_bypassed +=
+		gstat->rx_transport_csum_bypassed;
+	gmacdev->nss_stats.tx_bytes += gstat->tx_bytes;
+	gmacdev->nss_stats.tx_packets += gstat->tx_packets;
+	gmacdev->nss_stats.tx_collisions += gstat->tx_collisions;
+	gmacdev->nss_stats.tx_errors += gstat->tx_errors;
+	gmacdev->nss_stats.tx_jabber_timeout_errors +=
+		gstat->tx_jabber_timeout_errors;
+	gmacdev->nss_stats.tx_frame_flushed_errors +=
+		gstat->tx_frame_flushed_errors;
+	gmacdev->nss_stats.tx_loss_of_carrier_errors +=
+		gstat->tx_loss_of_carrier_errors;
+	gmacdev->nss_stats.tx_no_carrier_errors += gstat->tx_no_carrier_errors;
+	gmacdev->nss_stats.tx_late_collision_errors +=
+		gstat->tx_late_collision_errors;
+	gmacdev->nss_stats.tx_excessive_collision_errors +=
+		gstat->tx_excessive_collision_errors;
+	gmacdev->nss_stats.tx_excessive_deferral_errors +=
+		gstat->tx_excessive_deferral_errors;
+	gmacdev->nss_stats.tx_underflow_errors += gstat->tx_underflow_errors;
+	gmacdev->nss_stats.tx_ip_header_errors += gstat->tx_ip_header_errors;
+	gmacdev->nss_stats.tx_ip_payload_errors += gstat->tx_ip_payload_errors;
+	gmacdev->nss_stats.tx_dropped += gstat->tx_dropped;
+	gmacdev->nss_stats.hw_errs[0] += gstat->hw_errs[0];
+	gmacdev->nss_stats.hw_errs[1] += gstat->hw_errs[1];
+	gmacdev->nss_stats.hw_errs[2] += gstat->hw_errs[2];
+	gmacdev->nss_stats.hw_errs[3] += gstat->hw_errs[3];
+	gmacdev->nss_stats.hw_errs[4] += gstat->hw_errs[4];
+	gmacdev->nss_stats.hw_errs[5] += gstat->hw_errs[5];
+	gmacdev->nss_stats.hw_errs[6] += gstat->hw_errs[6];
+	gmacdev->nss_stats.hw_errs[7] += gstat->hw_errs[7];
+	gmacdev->nss_stats.hw_errs[8] += gstat->hw_errs[8];
+	gmacdev->nss_stats.hw_errs[9] += gstat->hw_errs[9];
+	gmacdev->nss_stats.rx_missed += gstat->rx_missed;
+	gmacdev->nss_stats.fifo_overflows += gstat->fifo_overflows;
+	gmacdev->nss_stats.rx_scatter_errors += gstat->rx_scatter_errors;
+	gmacdev->nss_stats.gmac_total_ticks += gstat->gmac_total_ticks;
+	gmacdev->nss_stats.gmac_worst_case_ticks += gstat->gmac_worst_case_ticks;
+	gmacdev->nss_stats.gmac_iterations += gstat->gmac_iterations;
+}
+
+
+/**
+ * @brief Stats Callback to receive statistics from NSS
+ * @param[in] pointer to gmac context
+ * @param[in] pointer to gmac statistics
+ * @return Returns void.
+ */
+static void nss_gmac_stats_receive(struct nss_gmac_dev *gmacdev,
+					struct nss_gmac_stats *gstat)
+{
+	struct net_device *netdev = NULL;
+
+	netdev = (struct net_device *)gmacdev->netdev;
+
+	if (!test_bit(__NSS_GMAC_UP, &gmacdev->flags))
+		return;
+
+	spin_lock(&gmacdev->stats_lock);
+
+	nss_gmac_copy_stats(gmacdev, gstat);
+
+	gmacdev->stats.rx_packets += gstat->rx_packets;
+	gmacdev->stats.rx_bytes += gstat->rx_bytes;
+	gmacdev->stats.rx_errors += gstat->rx_errors;
+	gmacdev->stats.rx_dropped += gstat->rx_errors;
+	gmacdev->stats.rx_length_errors += gstat->rx_length_errors;
+	gmacdev->stats.rx_over_errors += gstat->rx_overflow_errors;
+	gmacdev->stats.rx_crc_errors += gstat->rx_crc_errors;
+	gmacdev->stats.rx_frame_errors += gstat->rx_dribble_bit_errors;
+	gmacdev->stats.rx_fifo_errors += gstat->fifo_overflows;
+	gmacdev->stats.rx_missed_errors += gstat->rx_missed;
+	gmacdev->stats.collisions += gstat->tx_collisions
+		+ gstat->rx_late_collision_errors;
+	gmacdev->stats.tx_packets += gstat->tx_packets;
+	gmacdev->stats.tx_bytes += gstat->tx_bytes;
+	gmacdev->stats.tx_errors += gstat->tx_errors;
+	gmacdev->stats.tx_dropped += gstat->tx_dropped;
+	gmacdev->stats.tx_carrier_errors += gstat->tx_loss_of_carrier_errors
+		+ gstat->tx_no_carrier_errors;
+	gmacdev->stats.tx_fifo_errors += gstat->tx_underflow_errors;
+	gmacdev->stats.tx_window_errors += gstat->tx_late_collision_errors;
+
+	spin_unlock(&gmacdev->stats_lock);
+}
+EXPORT_SYMBOL(nss_gmac_receive);
+
+/**
+ * NSS Driver interface APIs
+ */
+
+/**
+ * @brief Rx Callback to receive frames from NSS
+ * @param[in] pointer to net device context
+ * @param[in] pointer to skb
+ * @return Returns void
+ */
+void nss_gmac_receive(struct net_device *netdev, struct sk_buff *skb,
+						struct napi_struct *napi)
+{
+	struct nss_gmac_dev *gmacdev;
+
+	BUG_ON(netdev == NULL);
+
+	gmacdev = netdev_priv(netdev);
+
+	BUG_ON(gmacdev->netdev != netdev);
+
+	skb->dev = netdev;
+	skb->protocol = eth_type_trans(skb, netdev);
+	netdev_dbg(netdev,
+			"%s: Rx on gmac%d, packet len %d, CSUM %d",
+			__func__, gmacdev->macid, skb->len, skb->ip_summed);
+
+	napi_gro_receive(napi, skb);
+}
+
+
+/**
+ * @brief Event Callback to receive events from NSS
+ * @param[in] pointer to net device context
+ * @param[in] event type
+ * @param[in] pointer to buffer
+ * @param[in] length of buffer
+ * @return Returns void
+ */
+void nss_gmac_event_receive(void *if_ctx, int ev_type,
+				void *os_buf, uint32_t len)
+{
+	struct net_device *netdev = NULL;
+	struct nss_gmac_dev *gmacdev = NULL;
+
+	netdev = (struct net_device *)if_ctx;
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	BUG_ON(!gmacdev);
+
+	switch (ev_type) {
+	case NSS_GMAC_EVENT_STATS:
+		nss_gmac_stats_receive(gmacdev,
+				(struct nss_gmac_stats *)os_buf);
+		break;
+
+	default:
+		netdev_dbg(netdev, "%s: Unknown Event from NSS", __func__);
+		break;
+	}
+}
+EXPORT_SYMBOL(nss_gmac_event_receive);
+
+/**
+ * @brief Notify linkup event to NSS
+ * @param[in] pointer to gmac context
+ * @return Returns void.
+ */
+static void nss_notify_linkup(struct nss_gmac_dev *gmacdev)
+{
+	uint32_t link = 0;
+
+	if (!test_bit(__NSS_GMAC_UP, &gmacdev->flags))
+		return;
+
+	link = 0x1;
+	if (gmacdev->speed == SPEED1000)
+		link |= 0x4;
+	else if (gmacdev->speed == SPEED100)
+		link |= 0x2;
+
+	gmacdev->data_plane_ops->link_state(gmacdev->data_plane_ctx, link);
+}
+
+/**
+ * This function checks for completion of PHY init
+ * and proceeds to initialize mac based on parameters
+ * read from PHY registers. It indicates presence of carrier to OS.
+ * @param[in] pointer to gmac context
+ * @return Returns void.
+ */
+void nss_gmac_linkup(struct nss_gmac_dev *gmacdev)
+{
+	struct net_device *netdev = gmacdev->netdev;
+	uint32_t gmac_tx_desc = 0, gmac_rx_desc = 0;
+	uint32_t mode = NSS_GMAC_MODE0;
+
+	nss_gmac_spare_ctl(gmacdev);
+
+	if (nss_gmac_check_phy_init(gmacdev) != 0) {
+		gmacdev->link_state = LINKDOWN;
+		return;
+	}
+
+	gmacdev->link_state = LINKUP;
+	if (nss_gmac_dev_set_speed(gmacdev) != 0)
+		return;
+
+	if (gmacdev->first_linkup_done == 0) {
+		nss_gmac_disable_interrupt_all(gmacdev);
+		nss_gmac_reset(gmacdev);
+		nss_gmac_clear_interrupt(gmacdev);
+
+		/* Program Tx/Rx descriptor base addresses */
+		nss_gmac_init_tx_desc_base(gmacdev);
+		nss_gmac_init_rx_desc_base(gmacdev);
+		nss_gmac_dma_bus_mode_init(gmacdev, dma_bus_mode_val);
+		nss_gmac_dma_axi_bus_mode_init(gmacdev, dma_axi_bus_mode_val);
+		nss_gmac_dma_control_init(gmacdev, dma_omr);
+		nss_gmac_disable_mmc_tx_interrupt(gmacdev, 0xFFFFFFFF);
+		nss_gmac_disable_mmc_rx_interrupt(gmacdev, 0xFFFFFFFF);
+		nss_gmac_disable_mmc_ipc_rx_interrupt(gmacdev, 0xFFFFFFFF);
+
+		/* Restore the Jumbo support settings as per corresponding
+		 * interface mtu
+		 */
+		nss_gmac_linux_change_mtu(gmacdev->netdev, gmacdev->netdev->mtu);
+		gmacdev->first_linkup_done = 1;
+	}
+
+	nss_gmac_mac_init(gmacdev);
+
+	if (gmacdev->data_plane_ops->open(gmacdev->data_plane_ctx, gmac_tx_desc,
+				gmac_rx_desc, mode) != NSS_GMAC_SUCCESS) {
+		netdev_dbg(netdev, "%s: data plane open command un-successful",
+								__func__);
+		gmacdev->link_state = LINKDOWN;
+		return;
+	}
+	netdev_dbg(netdev, "%s: data plane open command successfully issued",
+								__func__);
+
+	nss_notify_linkup(gmacdev);
+
+	netif_carrier_on(netdev);
+}
+
+
+/**
+ * Save current state of link and
+ * indicate absence of carrier to OS.
+ * @param[in] nss_gmac_dev *
+ * @return Returns void.
+ */
+void nss_gmac_linkdown(struct nss_gmac_dev *gmacdev)
+{
+	struct net_device *netdev = gmacdev->netdev;
+
+	netdev_info(netdev, "Link down");
+
+	if (test_bit(__NSS_GMAC_UP, &gmacdev->flags)) {
+		netif_carrier_off(netdev);
+
+		gmacdev->data_plane_ops->link_state(gmacdev->data_plane_ctx, 0);
+	}
+	gmacdev->link_state = LINKDOWN;
+	gmacdev->duplex_mode = 0;
+	gmacdev->speed = 0;
+}
+
+
+/**
+ * @brief Link state change callback
+ * @param[in] struct net_device *
+ * @return Returns void.
+ */
+void nss_gmac_adjust_link(struct net_device *netdev)
+{
+	int32_t status = 0;
+	struct nss_gmac_dev *gmacdev = NULL;
+
+	gmacdev = netdev_priv(netdev);
+
+	if (!test_bit(__NSS_GMAC_UP, &gmacdev->flags))
+		return;
+
+	status = nss_gmac_check_link(gmacdev);
+	mutex_lock(&gmacdev->link_mutex);
+	if (status == LINKUP && gmacdev->link_state == LINKDOWN)
+		nss_gmac_linkup(gmacdev);
+	else if (status == LINKDOWN && gmacdev->link_state == LINKUP)
+		nss_gmac_linkdown(gmacdev);
+	mutex_unlock(&gmacdev->link_mutex);
+}
+
+void nss_gmac_start_up(struct nss_gmac_dev *gmacdev)
+{
+	if (test_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags)) {
+		if (!IS_ERR_OR_NULL(gmacdev->phydev)) {
+			netdev_dbg(gmacdev->netdev, "%s: start phy 0x%x",
+					__func__, gmacdev->phydev->phy_id);
+			phy_start(gmacdev->phydev);
+			phy_start_aneg(gmacdev->phydev);
+		} else {
+			netdev_dbg(gmacdev->netdev, "%s: Invalid PHY device for a link polled interface",
+								__func__);
+		}
+		return;
+	}
+	netdev_dbg(gmacdev->netdev, "%s: Force link up", __func__);
+	/*
+	 * Force link up if link polling is disabled
+	 */
+	mutex_lock(&gmacdev->link_mutex);
+	nss_gmac_linkup(gmacdev);
+	mutex_unlock(&gmacdev->link_mutex);
+}
+
+/**
+ * @brief Function to transmit a given packet on the wire.
+ *
+ * Whenever Linux Kernel has a packet ready to be transmitted, this function is
+ * called.
+ * The function prepares a packet and prepares the descriptor and
+ * enables/resumes the transmission.
+ * @param[in] pointer to sk_buff structure.
+ * @param[in] pointer to net_device structure.
+ * @return NETDEV_TX_xxx
+ */
+int32_t nss_gmac_linux_xmit_frames(struct sk_buff *skb,
+						struct net_device *netdev)
+{
+	int msg_status = 0;
+	struct nss_gmac_dev *gmacdev = NULL;
+
+	BUG_ON(skb == NULL);
+	if (skb->len < ETH_HLEN) {
+		netdev_dbg(netdev, "%s: skb->len < ETH_HLEN", __func__);
+		goto drop;
+	}
+
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	BUG_ON(gmacdev == NULL);
+	BUG_ON(gmacdev->netdev != netdev);
+
+	netdev_dbg(netdev, "%s:Tx packet, len %d, CSUM %d",
+			__func__, skb->len, skb->ip_summed);
+
+	msg_status = gmacdev->data_plane_ops->xmit(gmacdev->data_plane_ctx, skb);
+
+	if (likely(msg_status == NSS_GMAC_SUCCESS))
+		goto tx_done;
+
+drop:
+	/*
+	 * Now drop it
+	 */
+	netdev_dbg(netdev, "dropping skb");
+	dev_kfree_skb_any(skb);
+	netdev->stats.tx_dropped++;
+
+tx_done:
+	return NETDEV_TX_OK;
+}
+
+/**
+ * @brief Function used when the interface is opened for use.
+ *
+ * We register nss_gmac_linux_open function to linux open(). Basically this
+ * function prepares the the device for operation. This function is called
+ * whenever ifconfig (in Linux) activates the device (for example
+ * "ifconfig eth0 up"). This function registers system resources needed.
+ *	- Disables interrupts
+ *	- Starts Linux network queue interface
+ *	- Checks for NSS init completion and determines initial link status
+ *	- Starts timer to detect cable plug/unplug
+ * @param[in] pointer to net_device structure.
+ * @return Returns 0 on success and error status upon failure.
+ */
+int nss_gmac_linux_open(struct net_device *netdev)
+{
+	struct device *dev = NULL;
+	struct nss_gmac_dev *gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	struct nss_gmac_global_ctx *ctx = NULL;
+	int err;
+
+	if (!gmacdev)
+		return -EINVAL;
+
+	dev = &netdev->dev;
+	ctx = gmacdev->ctx;
+
+	netif_carrier_off(netdev);
+
+	if (!gmacdev->data_plane_ops) {
+		netdev_dbg(netdev, "%s: offload is not enabled, bring up gmac with slowpath",
+								__func__);
+
+		netif_napi_add(netdev, &gmacdev->napi, nss_gmac_poll,
+							NSS_GMAC_NAPI_BUDGET);
+		/* Initial the RX/TX ring */
+		dma_set_coherent_mask(dev, 0xffffffff);
+		nss_gmac_setup_rx_desc_queue(gmacdev, dev,
+					NSS_GMAC_RX_DESC_SIZE, RINGMODE);
+		nss_gmac_setup_tx_desc_queue(gmacdev, dev,
+					NSS_GMAC_TX_DESC_SIZE, RINGMODE);
+		nss_gmac_rx_refill(gmacdev);
+
+		/* Register IRQ */
+		err = request_irq(netdev->irq, nss_gmac_handle_irq,
+					IRQF_DISABLED, "nss-gmac", gmacdev);
+		if (err) {
+			netdev_dbg(netdev, "Mac %d IRQ %d request failed",
+						gmacdev->macid, netdev->irq);
+			return err;
+		}
+
+		gmacdev->data_plane_ops = &nss_gmac_slowpath_ops;
+		gmacdev->data_plane_ctx = gmacdev->netdev;
+	}
+
+	/**
+	 * Now platform dependent initialization.
+	 */
+	nss_gmac_disable_interrupt_all(gmacdev);
+
+	gmacdev->speed = SPEED100;
+	gmacdev->duplex_mode = FULLDUPLEX;
+
+	/**
+	 * Lets read the version of ip in to device structure
+	 */
+	nss_gmac_read_version(gmacdev);
+
+	/*
+	 * Inform the Linux Networking stack about the hardware
+	 * capability of checksum offloading and other features.
+	 */
+	netdev->features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_TSO | NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_UFO | NETIF_F_TSO6;
+	netdev->hw_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_TSO | NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_UFO | NETIF_F_TSO6;
+	netdev->vlan_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_TSO | NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_UFO | NETIF_F_TSO6;
+	netdev->wanted_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_TSO | NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_UFO | NETIF_F_TSO6;
+
+	/**
+	 * Set GMAC state to UP before link state is checked
+	 */
+	test_and_set_bit(__NSS_GMAC_UP, &gmacdev->flags);
+	netif_start_queue(netdev);
+
+	gmacdev->link_state = LINKDOWN;
+
+	nss_gmac_start_up(gmacdev);
+
+	gmacdev->data_plane_ops->mac_addr(gmacdev->data_plane_ctx,
+					(uint8_t *)gmacdev->netdev->dev_addr);
+
+	return 0;
+}
+
+/**
+ * @brief Function used when the interface is closed.
+ *
+ * This function is registered to linux stop() function. This function is
+ * called whenever ifconfig (in Linux) closes the device (for example
+ * "ifconfig eth0 down"). This releases all the system resources allocated
+ * during open call.
+ *	- Disable the device interrupts
+ *	- Send a link change event to NSS GMAC driver.
+ *	- Stop the Linux network queue interface
+ *	- Cancel timer rgistered for cable plug/unplug tracking
+ * @param[in] pointer to net_device structure.
+ * @return Returns 0 on success and error status upon failure.
+ */
+int nss_gmac_linux_close(struct net_device *netdev)
+{
+	struct nss_gmac_dev *gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+
+	if (!gmacdev)
+		return -EINVAL;
+
+	test_and_set_bit(__NSS_GMAC_CLOSING, &gmacdev->flags);
+
+	netif_stop_queue(netdev);
+	netif_carrier_off(netdev);
+
+	nss_gmac_rx_disable(gmacdev);
+	nss_gmac_tx_disable(gmacdev);
+
+	nss_gmac_disable_interrupt_all(gmacdev);
+	gmacdev->data_plane_ops->link_state(gmacdev->data_plane_ctx, 0);
+
+	if (!IS_ERR_OR_NULL(gmacdev->phydev))
+		phy_stop(gmacdev->phydev);
+
+	test_and_clear_bit(__NSS_GMAC_UP, &gmacdev->flags);
+	test_and_clear_bit(__NSS_GMAC_CLOSING, &gmacdev->flags);
+
+	gmacdev->data_plane_ops->close(gmacdev->data_plane_ctx);
+
+	return 0;
+}
+
+/**
+ * @brief Function to handle a Tx Hang.
+ * This is a software hook (Linux) to handle transmitter hang if any.
+ * @param[in] pointer to net_device structure
+ * @return void.
+ */
+void nss_gmac_linux_tx_timeout(struct net_device *netdev)
+{
+	struct nss_gmac_dev *gmacdev = NULL;
+
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	BUG_ON(gmacdev == NULL);
+
+	if (gmacdev->gmac_power_down == 0) {
+		/* If Mac is in powerdown */
+		netdev_dbg(netdev,
+				"%s TX time out during power down is ignored",
+				netdev->name);
+		return;
+	}
+
+	netif_carrier_off(netdev);
+	nss_gmac_disable_dma_tx(gmacdev);
+	nss_gmac_flush_tx_fifo(gmacdev);
+	nss_gmac_enable_dma_tx(gmacdev);
+	netif_carrier_on(netdev);
+	netif_start_queue(netdev);
+}
+
+
+/**
+ * @brief Function to change the Maximum Transfer Unit.
+ * @param[in] pointer to net_device structure.
+ * @param[in] New value for maximum frame size.
+ * @return Returns 0 on success Errorcode on failure.
+ */
+int32_t nss_gmac_linux_change_mtu(struct net_device *netdev, int32_t newmtu)
+{
+	struct nss_gmac_dev *gmacdev = NULL;
+
+	gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	if (!gmacdev)
+		return -EINVAL;
+
+	if (newmtu > NSS_GMAC_JUMBO_MTU)
+		return -EINVAL;
+
+	if (gmacdev->data_plane_ops->change_mtu(gmacdev->data_plane_ctx, newmtu)
+							 != NSS_GMAC_SUCCESS)
+		return -EAGAIN;
+
+	if (newmtu <= NSS_GMAC_NORMAL_FRAME_MTU) {
+		nss_gmac_jumbo_frame_disable(gmacdev);
+		nss_gmac_twokpe_frame_disable(gmacdev);
+	} else if (newmtu <= NSS_GMAC_MINI_JUMBO_FRAME_MTU) {
+		nss_gmac_jumbo_frame_disable(gmacdev);
+		nss_gmac_twokpe_frame_enable(gmacdev);
+	} else if (newmtu <= NSS_GMAC_FULL_JUMBO_FRAME_MTU) {
+		nss_gmac_jumbo_frame_enable(gmacdev);
+	}
+
+	netdev->mtu = newmtu;
+	return 0;
+}
+
+/*
+ * nss_gmac_is_in_open_state()
+ *	Return if a gmac is opened or not
+ */
+bool nss_gmac_is_in_open_state(struct net_device *netdev)
+{
+	struct nss_gmac_dev *gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+
+	if (test_bit(__NSS_GMAC_UP, &gmacdev->flags))
+		return true;
+	return false;
+}
+EXPORT_SYMBOL(nss_gmac_is_in_open_state);
+
+/*
+ * nss_gmac_register_offload()
+ *
+ * @param[netdev] netdev instance that is going to register
+ * @param[dp_ops] dataplan ops for chaning mac addr/mtu/link status
+ * @param[ctx] passing the ctx of this nss_phy_if to gmac
+ *
+ * @return Return SUCCESS or FAILURE
+ */
+int nss_gmac_override_data_plane(struct net_device *netdev,
+				struct nss_gmac_data_plane_ops *dp_ops,
+				void *ctx)
+{
+	struct nss_gmac_dev *gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+
+	BUG_ON(!gmacdev);
+
+	if (!dp_ops->open || !dp_ops->close || !dp_ops->link_state
+		|| !dp_ops->mac_addr || !dp_ops->change_mtu || !dp_ops->xmit) {
+		netdev_dbg(netdev, "%s: All the op functions must be present, reject this registeration",
+								__func__);
+		return NSS_GMAC_FAILURE;
+	}
+
+	/*
+	 * If this gmac is up, close the netdev to force TX/RX stop
+	 */
+	if (test_bit(__NSS_GMAC_UP, &gmacdev->flags))
+		nss_gmac_linux_close(netdev);
+
+	/* Recored the data_plane_ctx, data_plane_ops */
+	gmacdev->data_plane_ctx = ctx;
+	gmacdev->data_plane_ops = dp_ops;
+	gmacdev->first_linkup_done = 0;
+
+	return NSS_GMAC_SUCCESS;
+}
+EXPORT_SYMBOL(nss_gmac_override_data_plane);
+
+/*
+ * nss_gmac_restore_data_plane()
+ *	Data plane to inform netdev it is ready to start
+ * @param[netdev] net_device context
+ * @param[ctx] context of the data plane
+ */
+void nss_gmac_start_data_plane(struct net_device *netdev, void *ctx)
+{
+	struct nss_gmac_dev *gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+	struct nss_gmac_global_ctx *global_ctx = gmacdev->ctx;
+
+	if (test_bit(__NSS_GMAC_UP, &gmacdev->flags)) {
+		netdev_dbg(netdev, "This netdev already up, something is wrong\n");
+		return;
+	}
+	if (gmacdev->data_plane_ctx == ctx) {
+		netdev_dbg(netdev, "Data plane cookie matches, let's start the netdev again\n");
+		queue_delayed_work(global_ctx->gmac_workqueue,
+				&gmacdev->gmacwork, NSS_GMAC_LINK_CHECK_TIME);
+	}
+}
+EXPORT_SYMBOL(nss_gmac_start_data_plane);
+
+/*
+ * gmac_unregister_nss_if()
+ *
+ * @param[if_num] gmac device id - 0~3
+ */
+void nss_gmac_restore_data_plane(struct net_device *netdev)
+{
+	struct nss_gmac_dev *gmacdev = (struct nss_gmac_dev *)netdev_priv(netdev);
+
+	/*
+	 * If this gmac is up, close the netdev to force TX/RX stop
+	 */
+	if (test_bit(__NSS_GMAC_UP, &gmacdev->flags))
+		nss_gmac_linux_close(netdev);
+	gmacdev->data_plane_ctx = netdev;
+	gmacdev->data_plane_ops = &nss_gmac_slowpath_ops;
+}
+EXPORT_SYMBOL(nss_gmac_restore_data_plane);
+
+/*
+ * nss_gmac_get_netdev_by_macid()
+ *	return the net device of the corrsponding macid if exist
+ */
+struct net_device *nss_gmac_get_netdev_by_macid(int macid)
+{
+	struct nss_gmac_dev *gmacdev = ctx.nss_gmac[macid];
+
+	if (!gmacdev)
+		return NULL;
+	return gmacdev->netdev;
+}
+EXPORT_SYMBOL(nss_gmac_get_netdev_by_macid);
+
+/*
+ * nss_gmac_open_work()
+ *	Schedule delayed work to open the netdev again
+ */
+void nss_gmac_open_work(struct work_struct *work)
+{
+	struct nss_gmac_dev *gmacdev = container_of(to_delayed_work(work),
+						struct nss_gmac_dev, gmacwork);
+
+	netdev_dbg(gmacdev->netdev, "Do the network up in delayed queue %s\n",
+							gmacdev->netdev->name);
+	nss_gmac_linux_open(gmacdev->netdev);
+}
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
