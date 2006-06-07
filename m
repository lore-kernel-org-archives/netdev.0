From: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
Subject: [PATCH 1/9] NetXen 1G/10G ethernet driver patch with corrections
Date: Wed, 7 Jun 2006 02:39:31 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0606070237220.10031@unmsrvr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:15109 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S932096AbWFGJjc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 05:39:32 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2006-06-07 Amit S. Kale <amitkale@unminc.com>
 	* Add Kconfig, Makefile entries and Makefiles for netxen driver
 	* Add ethtool interface for netxen driver

diff -Naru linux-2.6.16.20.orig/drivers/net/Kconfig linux-2.6.16.20/drivers/net/Kconfig
--- linux-2.6.16.20.orig/drivers/net/Kconfig	2006-06-06 04:48:38.000000000 -0700
+++ linux-2.6.16.20/drivers/net/Kconfig	2006-06-06 05:02:26.000000000 -0700
@@ -2313,6 +2313,11 @@

  	  If in doubt, say N.

+config NETXEN_NIC
+	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
+	help
+	  This enables the support for NetXen's Gigabit Ethernet card.
+
  endmenu

  if !UML
diff -Naru linux-2.6.16.20.orig/drivers/net/Makefile linux-2.6.16.20/drivers/net/Makefile
--- linux-2.6.16.20.orig/drivers/net/Makefile	2006-06-06 04:48:38.000000000 -0700
+++ linux-2.6.16.20/drivers/net/Makefile	2006-06-06 04:49:32.000000000 -0700
@@ -213,3 +213,4 @@

  obj-$(CONFIG_FS_ENET) += fs_enet/

+obj-$(CONFIG_NETXEN_NIC) += netxen/
diff -Naru linux-2.6.16.20.orig/drivers/net/netxen/Makefile linux-2.6.16.20/drivers/net/netxen/Makefile
--- linux-2.6.16.20.orig/drivers/net/netxen/Makefile	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.16.20/drivers/net/netxen/Makefile	2006-06-06 06:58:11.000000000 -0700
@@ -0,0 +1,35 @@
+# Copyright (C) 2003 - 2006 NetXen, Inc.
+# All rights reserved.
+# 
+# This program is free software; you can redistribute it and/or
+# modify it under the terms of the GNU General Public License
+# as published by the Free Software Foundation; either version 2
+# of the License, or (at your option) any later version.
+# 
+# This program is distributed in the hope that it will be useful, but
+# WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+# 
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software
+# Foundation, Inc., 59 Temple Place - Suite 330, Boston,
+# MA  02111-1307, USA.
+# 
+# The full GNU General Public License is included in this distribution
+# in the file called LICENSE.
+# 
+# Contact Information:
+#    info@netxen.com
+# NetXen,
+# 3965 Freedom Circle, Fourth floor,
+# Santa Clara, CA 95054
+#
+# Makefile for the NetXen NIC Driver
+#
+
+
+obj-$(CONFIG_NETXEN_NIC) := netxen_nic.o
+
+netxen_nic-y := netxen_nic_hw.o netxen_nic_main.o netxen_nic_init.o \
+	netxen_nic_isr.o netxen_nic_ethtool.o netxen_nic_niu.o
diff -Naru linux-2.6.16.20.orig/drivers/net/netxen/netxen_nic_ethtool.c linux-2.6.16.20/drivers/net/netxen/netxen_nic_ethtool.c
--- linux-2.6.16.20.orig/drivers/net/netxen/netxen_nic_ethtool.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.16.20/drivers/net/netxen/netxen_nic_ethtool.c	2006-06-06 06:58:11.000000000 -0700
@@ -0,0 +1,775 @@
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
+ * ethtool support for netxen nic
+ *
+ */
+
+#include <linux/types.h>
+#include <asm/uaccess.h>
+#include <linux/pci.h>
+#include <asm/io.h>
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/version.h>
+
+#include "netxen_nic_hw.h"
+#include "netxen_nic.h"
+#include "netxen_nic_phan_reg.h"
+#include "netxen_nic_ioctl.h"
+
+struct netxen_nic_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+
+#define NETXEN_NIC_STAT(m) sizeof(((struct netxen_port *)0)->m), \
+                    offsetof(struct netxen_port, m)
+
+static const struct netxen_nic_stats netxen_nic_gstrings_stats[] = {
+	{"rcvd_bad_skb", NETXEN_NIC_STAT(stats.rcvdbadskb)},
+	{"xmit_called", NETXEN_NIC_STAT(stats.xmitcalled)},
+	{"xmited_frames", NETXEN_NIC_STAT(stats.xmitedframes)},
+	{"xmit_finished", NETXEN_NIC_STAT(stats.xmitfinished)},
+	{"bad_skb_len", NETXEN_NIC_STAT(stats.badskblen)},
+	{"no_cmd_desc", NETXEN_NIC_STAT(stats.nocmddescriptor)},
+	{"polled", NETXEN_NIC_STAT(stats.polled)},
+	{"uphappy", NETXEN_NIC_STAT(stats.uphappy)},
+	{"updropped", NETXEN_NIC_STAT(stats.updropped)},
+	{"uplcong", NETXEN_NIC_STAT(stats.uplcong)},
+	{"uphcong", NETXEN_NIC_STAT(stats.uphcong)},
+	{"upmcong", NETXEN_NIC_STAT(stats.upmcong)},
+	{"updunno", NETXEN_NIC_STAT(stats.updunno)},
+	{"skb_freed", NETXEN_NIC_STAT(stats.skbfreed)},
+	{"tx_dropped", NETXEN_NIC_STAT(stats.txdropped)},
+	{"tx_null_skb", NETXEN_NIC_STAT(stats.txnullskb)},
+	{"csummed", NETXEN_NIC_STAT(stats.csummed)},
+	{"no_rcv", NETXEN_NIC_STAT(stats.no_rcv)},
+	{"rx_bytes", NETXEN_NIC_STAT(stats.rxbytes)},
+	{"tx_bytes", NETXEN_NIC_STAT(stats.txbytes)},
+};
+
+#define NETXEN_NIC_STATS_LEN        \
+        sizeof(netxen_nic_gstrings_stats) / sizeof(struct netxen_nic_stats)
+
+static const char netxen_nic_gstrings_test[][ETH_GSTRING_LEN] = {
+	"Register_Test  (offline)", "EEPROM_Test    (offline)",
+	"Interrupt_Test (offline)", "Loopback_Test  (offline)",
+	"Link_Test   (on/offline)"
+};
+
+#define NETXEN_NIC_TEST_LEN sizeof(netxen_nic_gstrings_test) / ETH_GSTRING_LEN
+
+#define NETXEN_NIC_REGS_COUNT 42
+#define NETXEN_NIC_REGS_LEN (NETXEN_NIC_REGS_COUNT * sizeof(netxen_crbword_t))
+
+static int netxen_nic_get_eeprom_len(struct net_device *dev)
+{
+	struct netxen_port *port = netdev_priv(dev);
+	struct netxen_adapter *adapter = port->adapter;
+	int n;
+
+	if ((netxen_rom_fast_read(adapter, 0, &n) == 0) && (n & 0x80000000)) {
+		n &= ~0x80000000;
+		if (n < 1024)
+			return n;
+	}
+	return 0;
+}
+
+static void
+netxen_nic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
+{
+	struct netxen_port *port = netdev_priv(dev);
+
+	strncpy(drvinfo->driver, "NetXen NIC Driver", 32);
+	strncpy(drvinfo->version, NETXEN_NIC_LINUX_VERSIONID, 32);
+	strncpy(drvinfo->fw_version, NETXEN_NIC_FW_VERSIONID, 32);
+	strncpy(drvinfo->bus_info, pci_name(port->pdev), 32);
+	drvinfo->n_stats = NETXEN_NIC_STATS_LEN;
+	drvinfo->testinfo_len = NETXEN_NIC_TEST_LEN;
+	drvinfo->regdump_len = NETXEN_NIC_REGS_LEN;
+	drvinfo->eedump_len = netxen_nic_get_eeprom_len(dev);
+}
+
+static int
+netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+{
+	struct netxen_port *port = netdev_priv(dev);
+	struct netxen_adapter *adapter = port->adapter;
+
+	/* read which mode */
+	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
+		ecmd->supported = (SUPPORTED_10baseT_Half |
+				   SUPPORTED_10baseT_Full |
+				   SUPPORTED_100baseT_Half |
+				   SUPPORTED_100baseT_Full |
+				   SUPPORTED_1000baseT_Half |
+				   SUPPORTED_1000baseT_Full |
+				   SUPPORTED_TP |
+				   SUPPORTED_MII | SUPPORTED_Autoneg);
+
+		ecmd->advertising = (ADVERTISED_100baseT_Half |
+				     ADVERTISED_100baseT_Full |
+				     ADVERTISED_1000baseT_Half |
+				     ADVERTISED_1000baseT_Full |
+				     ADVERTISED_TP |
+				     ADVERTISED_MII | ADVERTISED_Autoneg);
+
+		ecmd->port = PORT_TP;
+
+		if (netif_running(dev)) {
+			ecmd->speed = port->link_speed;
+			ecmd->duplex = port->link_duplex;
+		} else
+			return -EIO;	/* link absent */
+
+		ecmd->phy_address = port->portnum;
+		ecmd->transceiver = XCVR_EXTERNAL;
+
+		/* get autoneg settings */
+		ecmd->autoneg = port->link_autoneg;
+		return 0;
+	}
+
+	if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
+		ecmd->supported = (SUPPORTED_TP |
+				   SUPPORTED_1000baseT_Full |
+				   SUPPORTED_10000baseT_Full);
+		ecmd->advertising = (ADVERTISED_TP |
+				     ADVERTISED_1000baseT_Full |
+				     ADVERTISED_10000baseT_Full);
+		ecmd->port = PORT_TP;
+
+		ecmd->speed = SPEED_10000;
+		ecmd->duplex = DUPLEX_FULL;
+		ecmd->phy_address = port->portnum;
+		ecmd->transceiver = XCVR_EXTERNAL;
+		ecmd->autoneg = AUTONEG_DISABLE;
+		return 0;
+	}
+
+	return -EIO;
+}
+
+static int
+netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+{
+	struct netxen_port *port = netdev_priv(dev);
+	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_niu_phy_status status;
+
+	/* read which mode */
+	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
+		/* autonegotiation */
+		if (netxen_nic_phy_write(port->adapter, port->portnum,
+					 NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
+					 (netxen_crbword_t) ecmd->autoneg) != 0)
+			return -EIO;
+		else
+			port->link_autoneg = ecmd->autoneg;
+
+		if (netxen_nic_phy_read(port->adapter, port->portnum,
+					NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+					(netxen_crbword_t *) & status) != 0)
+			return -EIO;
+
+		/* speed */
+		switch (ecmd->speed) {
+		case SPEED_10:
+			status.speed = 0;
+			break;
+		case SPEED_100:
+			status.speed = 1;
+			break;
+		case SPEED_1000:
+			status.speed = 2;
+			break;
+		}
+		/* set duplex mode */
+		if (ecmd->duplex == DUPLEX_HALF)
+			status.duplex = 0;
+		if (ecmd->duplex == DUPLEX_FULL)
+			status.duplex = 1;
+
+		if (netxen_nic_phy_write(port->adapter, port->portnum,
+					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+					 *((int *)&status)) != 0)
+			return -EIO;
+		else {
+			port->link_speed = ecmd->speed;
+			port->link_duplex = ecmd->duplex;
+		}
+	}
+	if (netif_running(dev)) {
+		dev->stop(dev);
+		dev->open(dev);
+	}
+	return 0;
+}
+
+static int netxen_nic_get_regs_len(struct net_device *dev)
+{
+	return NETXEN_NIC_REGS_LEN;
+}
+
+static void
+netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
+{
+	struct netxen_port *port = netdev_priv(dev);
+	struct netxen_adapter *adapter = port->adapter;
+	netxen_crbword_t mode, *regs_buff = p;
+	unsigned long flags;
+	void *addr;
+
+	memset(p, 0, NETXEN_NIC_REGS_LEN);
+	regs->version = (1 << 24) | (adapter->ahw.revision_id << 16) |
+	    adapter->ahw.device_id;
+	write_lock_irqsave(&adapter->adapter_lock, flags);
+	/* which mode */
+	NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_MODE, &regs_buff[0]);
+	mode = regs_buff[0];
+
+	/* Common registers to all the modes */
+	NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_STRAP_VALUE_SAVE_HIGHER,
+				   &regs_buff[2]);
+	switch (mode) {
+	case 4:{		/* XGB Mode */
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_SINGLE_TERM,
+						   &regs_buff[3]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_DRIVE_HI,
+						   &regs_buff[4]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_DRIVE_LO,
+						   &regs_buff[5]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_DTX,
+						   &regs_buff[6]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_DEQ,
+						   &regs_buff[7]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_WORD_ALIGN,
+						   &regs_buff[8]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_RESET,
+						   &regs_buff[9]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_POWER_DOWN,
+						   &regs_buff[10]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_RESET_PLL,
+						   &regs_buff[11]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XG_SERDES_LOOPBACK, &regs_buff[12]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_DO_BYTE_ALIGN,
+						   &regs_buff[13]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_TX_ENABLE,
+						   &regs_buff[14]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_RX_ENABLE,
+						   &regs_buff[15]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_STATUS,
+						   &regs_buff[16]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XG_PAUSE_THRESHOLD, &regs_buff[17]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_CONFIG_0,
+						   &regs_buff[18]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_CONFIG_1,
+						   &regs_buff[19]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_IPG,
+						   &regs_buff[20]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_STATION_ADDR_0_HI, &regs_buff[21]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_STATION_ADDR_0_1, &regs_buff[22]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_STATION_ADDR_1_LO, &regs_buff[23]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_STATUS,
+						   &regs_buff[24]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_MAX_FRAME_SIZE, &regs_buff[25]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_PAUSE_FRAME_VALUE, &regs_buff[26]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_TX_BYTE_CNT,
+						   &regs_buff[27]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_TX_FRAME_CNT,
+						   &regs_buff[28]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_RX_BYTE_CNT,
+						   &regs_buff[29]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_RX_FRAME_CNT,
+						   &regs_buff[30]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_AGGR_ERROR_CNT, &regs_buff[31]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_MULTICAST_FRAME_CNT,
+			     &regs_buff[32]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_UNICAST_FRAME_CNT, &regs_buff[33]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XGE_CRC_ERROR_CNT,
+						   &regs_buff[34]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_OVERSIZE_FRAME_ERR, &regs_buff[35]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_UNDERSIZE_FRAME_ERR,
+			     &regs_buff[36]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_LOCAL_ERROR_CNT, &regs_buff[37]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_REMOTE_ERROR_CNT, &regs_buff[38]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_CONTROL_CHAR_CNT, &regs_buff[39]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_XGE_PAUSE_FRAME_CNT, &regs_buff[40]);
+			break;
+		}
+
+	case 2:{		/* GB Mode */
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_SERDES_RESET,
+						   &regs_buff[3]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB0_MII_MODE,
+						   &regs_buff[4]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB1_MII_MODE,
+						   &regs_buff[5]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB2_MII_MODE,
+						   &regs_buff[6]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB3_MII_MODE,
+						   &regs_buff[7]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB0_GMII_MODE,
+						   &regs_buff[8]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB1_GMII_MODE,
+						   &regs_buff[9]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB2_GMII_MODE,
+						   &regs_buff[10]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB3_GMII_MODE,
+						   &regs_buff[11]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_REMOTE_LOOPBACK,
+						   &regs_buff[12]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB0_HALF_DUPLEX,
+						   &regs_buff[13]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB1_HALF_DUPLEX,
+						   &regs_buff[14]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_RESET_SYS_FIFOS,
+						   &regs_buff[15]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_CRC_DROP,
+						   &regs_buff[16]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_DROP_WRONGADDR,
+						   &regs_buff[17]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_TEST_MUX_CTL,
+						   &regs_buff[18]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MAC_CONFIG_0
+						   (port->portnum),
+						   &regs_buff[19]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MAC_CONFIG_1
+						   (port->portnum),
+						   &regs_buff[20]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_GB_HALF_DUPLEX_CTRL(port->portnum),
+			     &regs_buff[21]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MAX_FRAME_SIZE
+						   (port->portnum),
+						   &regs_buff[22]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_TEST_REG
+						   (port->portnum),
+						   &regs_buff[23]);
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MII_MGMT_CONFIG
+						   (port->portnum),
+						   &regs_buff[24]);
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_GB_MII_MGMT_COMMAND(port->portnum),
+			     &regs_buff[25]);
+
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MII_MGMT_ADDR
+						   (port->portnum),
+						   &regs_buff[26]);
+
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MII_MGMT_CTRL
+						   (port->portnum),
+						   &regs_buff[27]);
+
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_MII_MGMT_STATUS
+						   (port->portnum),
+						   &regs_buff[28]);
+
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_GB_MII_MGMT_INDICATE(port->portnum),
+			     &regs_buff[29]);
+
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_INTERFACE_CTRL
+						   (port->portnum),
+						   &regs_buff[30]);
+
+			NETXEN_NIC_LOCKED_READ_REG
+			    (NETXEN_NIU_GB_INTERFACE_STATUS(port->portnum),
+			     &regs_buff[31]);
+
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_STATION_ADDR_0
+						   (port->portnum),
+						   &regs_buff[32]);
+
+			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_GB_STATION_ADDR_1
+						   (port->portnum),
+						   &regs_buff[33]);
+			break;
+		}
+	}
+	write_unlock_irqrestore(&adapter->adapter_lock, flags);
+}
+
+static void
+netxen_nic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	wol->supported = WAKE_UCAST | WAKE_MCAST | WAKE_BCAST | WAKE_MAGIC;
+	wol->wolopts = 0;	/* options can be added depending upon the mode */
+}
+
+/* Restart Link Process */
+static int netxen_nic_nway_reset(struct net_device *dev)
+{
+	if (netif_running(dev)) {
+		dev->stop(dev);	/* verify */
+		dev->open(dev);
+	}
+	return 0;
+}
+
+static u32 netxen_nic_get_link(struct net_device *dev)
+{
+	struct netxen_port *port = netdev_priv(dev);
+	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_niu_phy_status status;
+
+	/* read which mode */
+	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
+		if (netxen_nic_phy_read(port->adapter, port->portnum,
+					NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+					(netxen_crbword_t *) & status) != 0)
+			return -EIO;
+		else
+			return status.link;
+	}
+	return -EIO;
+}
+
+static int
+netxen_nic_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
+		      u8 * bytes)
+{
+	struct netxen_port *port = netdev_priv(dev);
+	struct netxen_adapter *adapter = port->adapter;
+	int offset;
+
+	if (eeprom->len == 0)
+		return -EINVAL;
+
+	eeprom->magic = adapter->ahw.vendor_id | (adapter->ahw.device_id << 16);
+	for (offset = 0; offset < eeprom->len; offset++)
+		if (netxen_rom_fast_read
+		    (adapter, (8 * offset) + 8, (int *)eeprom->data) == -1)
+			return -1;
+	return 0;
+}
+
+static void
+netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
+{
+	struct netxen_port *port = netdev_priv(dev);
+	struct netxen_adapter *adapter = port->adapter;
+	int i, j;
+	struct netxen_ring_context *ctx;
+
+	ring->rx_pending = 0;
+	ring->rx_max_pending = 0;
+	ring->tx_max_pending = 0;
+	for (i = 0; i < MAX_RING_CTX; ++i) {
+		ctx = &adapter->ring_ctx[i];
+		for (j = 0; j < NUM_RCV_DESC_RINGS; j++)
+			ring->rx_pending +=
+			    ctx->recv_ctx.rcv_desc[j].rcv_pending;
+		ring->tx_pending += ctx->pending_cmd_count;
+		ring->rx_max_pending += ctx->max_rx_desc_count;
+		ring->tx_max_pending += ctx->max_tx_desc_count;
+	}
+
+	ring->rx_mini_max_pending = 0;
+	ring->rx_mini_pending = 0;
+	ring->rx_jumbo_max_pending = 0;
+	ring->rx_jumbo_pending = 0;
+}
+
+static void
+netxen_nic_get_pauseparam(struct net_device *dev,
+			  struct ethtool_pauseparam *pause)
+{
+	struct netxen_port *port = netdev_priv(dev);
+	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_niu_gb_mac_config_0_t val;
+
+	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
+		/* get flow control settings */
+		netxen_nic_read_w0(adapter,
+				   NETXEN_NIU_GB_MAC_CONFIG_0(port->portnum),
+				   (u32 *) & val);
+		pause->rx_pause = val.rx_flowctl;
+		pause->tx_pause = val.tx_flowctl;
+		/* get autoneg settings */
+		pause->autoneg = port->link_autoneg;
+	}
+}
+
+static int
+netxen_nic_set_pauseparam(struct net_device *dev,
+			  struct ethtool_pauseparam *pause)
+{
+	struct netxen_port *port = netdev_priv(dev);
+	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_niu_gb_mac_config_0_t val;
+	unsigned int autoneg;
+
+	/* read mode */
+	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
+		/* set flow control */
+		netxen_nic_read_w0(adapter,
+				   NETXEN_NIU_GB_MAC_CONFIG_0(port->portnum),
+				   (u32 *) & val);
+		val.rx_flowctl = pause->rx_pause;
+		val.tx_flowctl = pause->tx_pause;
+		netxen_nic_write_w0(adapter,
+				    NETXEN_NIU_GB_MAC_CONFIG_0(port->portnum),
+				    *(u32 *) (&val));
+		/* set autoneg */
+		autoneg = pause->autoneg;
+		if (netxen_nic_phy_write(port->adapter, port->portnum,
+					 NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
+					 (netxen_crbword_t) autoneg) != 0)
+			return -EIO;
+		else {
+			port->link_autoneg = pause->autoneg;
+			return 0;
+		}
+	} else
+		return -EIO;
+}
+
+static int netxen_nic_reg_test(struct net_device *dev)
+{
+	struct netxen_port *port = netdev_priv(dev);
+	struct netxen_adapter *adapter = port->adapter;
+	int data_read, data_written, save;
+	struct netxen_niu_control mode;
+
+	/* 
+	 * first test the "Read Only" registers by writing which mode
+	 */
+	netxen_nic_read_w0(adapter, NETXEN_NIU_MODE, (u32 *) & mode);
+	if (mode.enable_ge) {	/* GB Mode */
+		netxen_nic_read_w0(adapter,
+				   NETXEN_NIU_GB_MII_MGMT_STATUS(port->portnum),
+				   &data_read);
+
+		save = data_read;
+		if (data_read)
+			data_written = data_read & 0xDEADBEEF;
+		else
+			data_written = 0xDEADBEEF;
+		netxen_nic_write_w0(adapter,
+				    NETXEN_NIU_GB_MII_MGMT_STATUS(port->
+								  portnum),
+				    data_written);
+		netxen_nic_read_w0(adapter,
+				   NETXEN_NIU_GB_MII_MGMT_STATUS(port->portnum),
+				   &data_read);
+
+		if (data_written == data_read) {
+			netxen_nic_write_w0(adapter,
+					    NETXEN_NIU_GB_MII_MGMT_STATUS(port->
+									  portnum),
+					    save);
+
+			return 0;
+		}
+
+		/* netxen_niu_gb_mii_mgmt_indicators_t is read only */
+		netxen_nic_read_w0(adapter,
+				   NETXEN_NIU_GB_MII_MGMT_INDICATE(port->
+								   portnum),
+				   &data_read);
+
+		save = data_read;
+		if (data_read)
+			data_written = data_read & 0xDEADBEEF;
+		else
+			data_written = 0xDEADBEEF;
+		netxen_nic_write_w0(adapter,
+				    NETXEN_NIU_GB_MII_MGMT_INDICATE(port->
+								    portnum),
+				    data_written);
+
+		netxen_nic_read_w0(adapter,
+				   NETXEN_NIU_GB_MII_MGMT_INDICATE(port->
+								   portnum),
+				   &data_read);
+
+		if (data_written == data_read) {
+			netxen_nic_write_w0(adapter,
+					    NETXEN_NIU_GB_MII_MGMT_INDICATE
+					    (port->portnum), save);
+			return 0;
+		}
+
+		/* netxen_niu_gb_interface_status_t is read only */
+		netxen_nic_read_w0(adapter,
+				   NETXEN_NIU_GB_INTERFACE_STATUS(port->
+								  portnum),
+				   &data_read);
+
+		save = data_read;
+		if (data_read)
+			data_written = data_read & 0xDEADBEEF;
+		else
+			data_written = 0xDEADBEEF;
+		netxen_nic_write_w0(adapter,
+				    NETXEN_NIU_GB_INTERFACE_STATUS(port->
+								   portnum),
+				    data_written);
+
+		netxen_nic_read_w0(adapter,
+				   NETXEN_NIU_GB_INTERFACE_STATUS(port->
+								  portnum),
+				   &data_read);
+
+		if (data_written == data_read) {
+			netxen_nic_write_w0(adapter,
+					    NETXEN_NIU_GB_INTERFACE_STATUS
+					    (port->portnum), save);
+
+			return 0;
+		}
+	}			/* GB Mode */
+	return 1;
+}
+
+static int netxen_nic_diag_test_count(struct net_device *dev)
+{
+	return NETXEN_NIC_TEST_LEN;
+}
+
+static void
+netxen_nic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
+		     u64 * data)
+{
+	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {	/* offline tests */
+		/* link test */
+		if (!(data[4] = (u64) netxen_nic_get_link(dev)))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		if (netif_running(dev))
+			dev->stop(dev);
+
+		/* register tests */
+		if (!(data[0] = netxen_nic_reg_test(dev)))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+		/* other tests pass as of now */
+		data[1] = data[2] = data[3] = 1;
+		if (netif_running(dev))
+			dev->open(dev);
+	} else {		/* online tests */
+		/* link test */
+		if (!(data[4] = (u64) netxen_nic_get_link(dev)))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		/* other tests pass by default */
+		data[0] = data[1] = data[2] = data[3] = 1;
+	}
+}
+
+static void
+netxen_nic_get_strings(struct net_device *dev, u32 stringset, u8 * data)
+{
+	int index;
+
+	switch (stringset) {
+	case ETH_SS_TEST:
+		memcpy(data, *netxen_nic_gstrings_test,
+		       NETXEN_NIC_TEST_LEN * ETH_GSTRING_LEN);
+		break;
+	case ETH_SS_STATS:
+		for (index = 0; index < NETXEN_NIC_STATS_LEN; index++) {
+			memcpy(data + index * ETH_GSTRING_LEN,
+			       netxen_nic_gstrings_stats[index].stat_string,
+			       ETH_GSTRING_LEN);
+		}
+		break;
+	}
+}
+
+static int netxen_nic_get_stats_count(struct net_device *dev)
+{
+	return NETXEN_NIC_STATS_LEN;
+}
+
+static void
+netxen_nic_get_ethtool_stats(struct net_device *dev,
+			     struct ethtool_stats *stats, u64 * data)
+{
+	struct netxen_port *port = netdev_priv(dev);
+	int index;
+
+	for (index = 0; index < NETXEN_NIC_STATS_LEN; index++) {
+		char *p =
+		    (char *)port + netxen_nic_gstrings_stats[index].stat_offset;
+		data[index] =
+		    (netxen_nic_gstrings_stats[index].sizeof_stat ==
+		     sizeof(u64)) ? *(u64 *) p : *(u32 *) p;
+	}
+
+}
+
+struct ethtool_ops netxen_nic_ethtool_ops = {
+	.get_settings = netxen_nic_get_settings,
+	.set_settings = netxen_nic_set_settings,
+	.get_drvinfo = netxen_nic_get_drvinfo,
+	.get_regs_len = netxen_nic_get_regs_len,
+	.get_regs = netxen_nic_get_regs,
+	.get_wol = netxen_nic_get_wol,
+	.nway_reset = netxen_nic_nway_reset,
+	.get_link = netxen_nic_get_link,
+	.get_eeprom_len = netxen_nic_get_eeprom_len,
+	.get_eeprom = netxen_nic_get_eeprom,
+	.get_ringparam = netxen_nic_get_ringparam,
+	.get_pauseparam = netxen_nic_get_pauseparam,
+	.set_pauseparam = netxen_nic_set_pauseparam,
+	.get_tx_csum = ethtool_op_get_tx_csum,
+	.set_tx_csum = ethtool_op_set_tx_csum,
+	.get_sg = ethtool_op_get_sg,
+	.set_sg = ethtool_op_set_sg,
+#ifdef NETIF_F_TSO
+	.get_tso = ethtool_op_get_tso,
+	.set_tso = ethtool_op_set_tso,
+#endif
+	.self_test_count = netxen_nic_diag_test_count,
+	.self_test = netxen_nic_diag_test,
+	.get_strings = netxen_nic_get_strings,
+	.get_stats_count = netxen_nic_get_stats_count,
+	.get_ethtool_stats = netxen_nic_get_ethtool_stats,
+	.get_perm_addr = ethtool_op_get_perm_addr,
+};
