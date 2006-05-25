From: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
Subject: [PATCH 5/9] Resending NetXen 1G/10G NIC driver patch
Date: Thu, 25 May 2006 03:54:12 -0700 (PDT)
Message-ID: <Pine.LNX.4.33.0605250353171.5844-100000@unmsrvr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:60526 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S965018AbWEYKyN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 06:54:13 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -Naru linux-2.6.16.18.orig/drivers/net/netxen/netxen_nic_hw.h linux-2.6.16.18/drivers/net/netxen/netxen_nic_hw.h
--- linux-2.6.16.18.orig/drivers/net/netxen/netxen_nic_hw.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.16.18/drivers/net/netxen/netxen_nic_hw.h	2006-05-25 02:43:22.000000000 -0700
@@ -0,0 +1,339 @@
+/*
+ * Copyright (C) 2003 - 2006 NetXen, Inc.
+ * All rights reserved.
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *                            
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *                                   
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
+ * MA  02111-1307, USA.
+ * 
+ * The full GNU General Public License is included in this distribution
+ * in the file called LICENSE.
+ * 
+ * Contact Information:
+ *    info@netxen.com
+ * NetXen,
+ * 3965 Freedom Circle, Fourth floor,
+ * Santa Clara, CA 95054
+ *
+ *
+ * Structures, enums, and macros for the MAC
+ *
+ */
+
+#ifndef __NETXEN_NIC_HW_H_
+#define __NETXEN_NIC_HW_H_
+
+#include "netxen_nic_hdr.h"
+
+/* Hardware memory size of 128 meg */
+#define NETXEN_MEMADDR_MAX (128 * 1024 * 1024)
+
+#ifndef readq
+static inline u64 readq(void __iomem * addr)
+{
+	return readl(addr) | (((u64) readl(addr + 4)) << 32LL);
+}
+#endif
+
+#ifndef writeq
+static inline void writeq(u64 val, void __iomem * addr)
+{
+	writel(((u32) (val)), (addr));
+	writel(((u32) (val >> 32)), (addr + 4));
+}
+#endif
+
+#define NETXEN_NIC_HW_BLOCK_WRITE_64(DATA_PTR, ADDR, NUM_WORDS)     \
+        do {                                                        \
+                int num;                                            \
+                u64 *a = (u64 *) (DATA_PTR);                        \
+                u64 *b = (u64 *) (ADDR);                            \
+                for (num = 0; num < (NUM_WORDS); num++) {           \
+                        writeq(readq(a), b);                        \
+                        b++;                                        \
+                        a++;                                        \
+                }                                                   \
+        } while (0)
+
+#define NETXEN_NIC_HW_BLOCK_READ_64(DATA_PTR, ADDR, NUM_WORDS)        \
+        do {                                                          \
+                int num;                                              \
+                u64 *a = (u64 *) (DATA_PTR);                          \
+                u64 *b = (u64 *) (ADDR);                              \
+                for (num = 0; num < (NUM_WORDS); num++) {             \
+                        writeq(readq(b), a);                          \
+                        b++;                                          \
+                        a++;                                          \
+                }                                                     \
+        } while (0)
+
+#define NETXEN_PCI_MAPSIZE_BYTES  (NETXEN_PCI_MAPSIZE << 20)
+
+#define NETXEN_NIC_LOCKED_READ_REG(X, Y)   		\
+        addr = (void *)(adapter->ahw.pci_base + X);     \
+        *(u32 *)Y = readl(addr);
+
+#define NETXEN_NIC_LOCKED_WRITE_REG(X, Y)   		\
+	addr = (void *)(adapter->ahw.pci_base + X); 	\
+	writel(*(u32 *)Y, addr);
+
+struct netxen_port;
+void netxen_nic_set_link_parameters(struct netxen_port *port);
+struct netxen_adapter;
+void netxen_nic_flash_print(struct netxen_adapter *adapter);
+
+int netxen_nic_hw_write_wx(struct netxen_adapter *adapter, u64 off,
+			   void *data, int len);
+void netxen_crb_writelit_adapter(struct netxen_adapter *adapter,
+				 unsigned long off, int data);
+int netxen_nic_hw_read_wx(struct netxen_adapter *adapter, u64 off,
+			  void *data, int len);
+
+typedef u8 netxen_ethernet_macaddr_t[6];
+
+/* Nibble or Byte mode for phy interface (GbE mode only) */
+typedef enum {
+	NETXEN_NIU_10_100_MB = 0,
+	NETXEN_NIU_1000_MB
+} netxen_niu_gbe_ifmode_t;
+
+/*
+ * NIU GB MAC Config Register 0 (applies to GB0, GB1, GB2, GB3)
+ */
+struct netxen_niu_gb_mac_config_0_t {
+	netxen_crbword_t tx_enable:1,	/* 1:enable frame xmit, 0:disable */
+	 tx_synched:1,		/* R/O: xmit enable synched to xmit stream */
+	 rx_enable:1,		/* 1:enable frame recv, 0:disable */
+	 rx_synched:1,		/* R/O: recv enable synched to recv stream */
+	 tx_flowctl:1,		/* 1:enable pause frame generation, 0:disable */
+	 rx_flowctl:1,		/* 1:act on recv'd pause frames, 0:ignore */
+	 rsvd1:2, loopback:1,	/* 1:loop MAC xmits to MAC recvs, 0:normal */
+	 rsvd2:7,
+	 tx_reset_pb:1,	/* 1:reset frame xmit protocol blk, 0:no-op */
+	 rx_reset_pb:1,		/* 1:reset frame recv protocol blk, 0:no-op */
+	 tx_reset_mac:1,	/* 1:reset data/ctl multiplexer blk, 0:no-op */
+	 rx_reset_mac:1,	/* 1:reset ctl frames & timers blk, 0:no-op */
+	 rsvd3:11,
+	 soft_reset:1;	/* 1:reset the MAC and the SERDES, 0:no-op */
+};
+
+/*
+ * NIU GB MAC Config Register 1 (applies to GB0, GB1, GB2, GB3)
+ */
+struct netxen_niu_gb_mac_config_1_t {
+	netxen_crbword_t duplex:1,	/* 1:full duplex mode, 0:half duplex */
+	 crc_enable:1,		/* 1:append CRC to xmit frames, 0:dont append */
+	 padshort:1,		/* 1:pad short frames and add CRC, 0:dont pad */
+	 rsvd1:1,
+	 checklength:1,	/* 1:check framelen with actual, 0:dont check */
+	 hugeframes:1,		/* 1:allow oversize xmit frames, 0:dont allow */
+	 rsvd2:2, intfmode:2,	/* 01:nibble (10/100), 10:byte (1000) */
+	 rsvd3:2,
+	 preamblelen:4,	/* preamble field length in bytes, default 7 */
+	 rsvd4:16;
+};
+
+/*
+ * NIU GB Station Address High Register
+ * NOTE: this value is in network byte order.
+ */
+struct netxen_niu_gb_station_address_high {
+	netxen_crbword_t address:32;	/* station address [47:16] */
+};
+
+/*
+ * NIU GB Station Address Low Register
+ * NOTE: this value is in network byte order.
+ */
+struct netxen_niu_gb_station_address_low {
+	netxen_crbword_t rsvd:16, address:16;	/* station address [15:0] */
+};
+
+/*
+ * NIU GB MII Mgmt Config Register (applies to GB0, GB1, GB2, GB3)
+ */
+struct netxen_niu_gb_mii_mgmt_config {
+	netxen_crbword_t clockselect:3,
+		/* 0:clk/4,  1:clk/4,  2:clk/6,  3:clk/8 */
+		/* 4:clk/10, 5:clk/14, 6:clk/20, 7:clk/28 */
+	 rsvd1:1, nopreamble:1,	/* 1:suppress preamble generation, 0:normal */
+	 scanauto:1, rsvd2:25, reset:1;	/* 1:reset MII mgmt, 0:no-op */
+};
+
+/*
+ * NIU GB MII Mgmt Command Register (applies to GB0, GB1, GB2, GB3)
+ */
+struct netxen_niu_gb_mii_mgmt_command {
+	netxen_crbword_t read_cycle:1,	/* 1:perform single read cycle, 0:no-op */
+	 scan_cycle:1,		/* 1:perform continuous read cycles, 0:no-op */
+	 rsvd:30;
+};
+
+/*
+ * NIU GB MII Mgmt Address Register (applies to GB0, GB1, GB2, GB3)
+ */
+struct netxen_niu_gb_mii_mgmt_address {
+	netxen_crbword_t reg_addr:5,	/* which mgmt register we want to talk to */
+	 rsvd1:3, phy_addr:5,	/* which PHY to talk to (0 is reserved) */
+	 rsvd:19;
+};
+
+/*
+ * NIU GB MII Mgmt Indicators Register (applies to GB0, GB1, GB2, GB3)
+ * Read-only register.
+ */
+struct netxen_niu_gb_mii_mgmt_indicators {
+	netxen_crbword_t busy:1,	/* 1:performing an MII mgmt cycle, 0:idle */
+	 scanning:1,		/* 1:scan operation in progress, 0:idle */
+	 notvalid:1,		/* 1:mgmt result data not yet valid, 0:idle */
+	 rsvd:29;
+};
+
+/*
+ * PHY-Specific MII control/status registers.
+ */
+typedef enum {
+	NETXEN_NIU_GB_MII_MGMT_ADDR_CONTROL = 0,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_STATUS = 1,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_ID_0 = 2,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_ID_1 = 3,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG = 4,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_LNKPART = 5,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG_MORE = 6,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_NEXTPAGE_XMIT = 7,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_LNKPART_NEXTPAGE = 8,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_1000BT_CONTROL = 9,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_1000BT_STATUS = 10,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_EXTENDED_STATUS = 15,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_CONTROL = 16,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS = 17,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_INT_ENABLE = 18,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS = 19,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_CONTROL_MORE = 20,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_RECV_ERROR_COUNT = 21,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_LED_CONTROL = 24,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_LED_OVERRIDE = 25,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_CONTROL_MORE_YET = 26,
+	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS_MORE = 27
+} netxen_niu_phy_register_t;
+
+/*
+ * PHY-Specific Status Register (reg 17).
+ */
+struct netxen_niu_phy_status {
+	netxen_crbword_t jabber:1,	/* 1:jabber detected, 0:not */
+	 polarity:1,		/* 1:polarity reversed, 0:normal */
+	 recvpause:1,		/* 1:receive pause enabled, 0:disabled */
+	 xmitpause:1,		/* 1:transmit pause enabled, 0:disabled */
+	 energydetect:1,	/* 1:sleep, 0:active */
+	 downshift:1,		/* 1:downshift, 0:no downshift */
+	 crossover:1,		/* 1:MDIX (crossover), 0:MDI (no crossover) */
+	 cablelen:3,		/* not valid in 10Mb/s mode */
+	    /* 0:<50m, 1:50-80m, 2:80-110m, 3:110-140m, 4:>140m */
+	 link:1,		/* 1:link up, 0:link down */
+	 resolved:1,		/* 1:speed and duplex resolved, 0:not yet */
+	 pagercvd:1,		/* 1:page received, 0:page not received */
+	 duplex:1,		/* 1:full duplex, 0:half duplex */
+	 speed:2,		/* 0:10Mb/s, 1:100Mb/s, 2:1000Mb/s, 3:rsvd */
+	 rsvd:16;
+};
+
+/*
+ * Interrupt Register definition
+ * This definition applies to registers 18 and 19 (int enable and int status).
+ */
+struct netxen_niu_phy_interrupt {
+	netxen_crbword_t
+	    jabber:1,
+	    polarity_changed:1,
+	    reserved:2,
+	    energy_detect:1,
+	    downshift:1,
+	    mdi_xover_changed:1,
+	    fifo_over_underflow:1,
+	    false_carrier:1,
+	    symbol_error:1,
+	    link_status_changed:1,
+	    autoneg_completed:1,
+	    page_received:1,
+	    duplex_changed:1, speed_changed:1, autoneg_error:1, rsvd:16;
+};
+
+/*
+ * NIU Mode Register.
+ */
+struct netxen_niu_control {
+	netxen_crbword_t enable_fc:1,	/* enable FibreChannel */
+	 enable_ge:1,		/* enable 10/100/1000 Ethernet */
+	 enable_xgb:1,		/* enable 10Gb Ethernet */
+	 rsvd:29;
+};
+
+/* Promiscous mode options (GbE mode only) */
+typedef enum {
+	NETXEN_NIU_PROMISCOUS_MODE = 0,
+	NETXEN_NIU_NON_PROMISCOUS_MODE
+} netxen_niu_prom_mode_t;
+
+/*
+ * NIU GB Drop CRC Register
+ */
+struct netxen_niu_gb_drop_crc {
+	netxen_crbword_t drop_gb0:1,	/* 1:drop pkts with bad CRCs, 0:pass them on */
+	 drop_gb1:1,		/* 1:drop pkts with bad CRCs, 0:pass them on */
+	 drop_gb2:1,		/* 1:drop pkts with bad CRCs, 0:pass them on */
+	 drop_gb3:1,		/* 1:drop pkts with bad CRCs, 0:pass them on */
+	 rsvd:28;
+};
+
+/*
+ * NIU XG MAC Config Register
+ */
+struct netxen_niu_xg_mac_config_0_t {
+	netxen_crbword_t tx_enable:1,	/* 1:enable frame xmit, 0:disable */
+	 rsvd1:1, rx_enable:1,	/* 1:enable frame recv, 0:disable */
+	 rsvd2:1, soft_reset:1,	/* 1:reset the MAC , 0:no-op */
+	 rsvd3:22,
+	    xaui_framer_reset:1,
+	    xaui_rx_reset:1,
+	    xaui_tx_reset:1, xg_ingress_afifo_reset:1, xg_egress_afifo_reset:1;
+};
+
+/* Set promiscuous mode for a GbE interface */
+long netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter, long port,
+				     netxen_niu_prom_mode_t mode);
+long netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
+					long port, netxen_niu_prom_mode_t mode);
+
+/* get/set the MAC address for a given MAC */
+int netxen_niu_macaddr_get(struct netxen_adapter *adapter, int port,
+			   netxen_ethernet_macaddr_t * addr);
+int netxen_niu_macaddr_set(struct netxen_adapter *adapter, int port,
+			   netxen_ethernet_macaddr_t addr);
+
+/* XG versons */
+int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter, int port,
+			      netxen_ethernet_macaddr_t * addr);
+int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter, int port,
+			      netxen_ethernet_macaddr_t addr);
+
+/* Generic enable for GbE ports. Will detect the speed of the link. */
+long netxen_niu_gbe_init_port(struct netxen_adapter *adapter, long port);
+
+/* Disable a GbE interface */
+long netxen_niu_disable_gbe_port(struct netxen_adapter *adapter, long port);
+
+long netxen_niu_disable_xg_port(struct netxen_adapter *adapter, long port);
+
+#endif				/* __NETXEN_NIC_HW_H_ */

