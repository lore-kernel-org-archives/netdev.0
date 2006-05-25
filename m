From: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
Subject: [PATCH 9/9] Resending NetXen 1G/10G NIC driver patch
Date: Thu, 25 May 2006 03:58:26 -0700 (PDT)
Message-ID: <Pine.LNX.4.33.0605250357330.5844-100000@unmsrvr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:45161 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S965054AbWEYK61
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 06:58:27 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -Naru linux-2.6.16.18.orig/drivers/net/netxen/netxen_nic_niu.c linux-2.6.16.18/drivers/net/netxen/netxen_nic_niu.c
--- linux-2.6.16.18.orig/drivers/net/netxen/netxen_nic_niu.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.16.18/drivers/net/netxen/netxen_nic_niu.c	2006-05-25 02:43:22.000000000 -0700
@@ -0,0 +1,770 @@
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
+ * Provides access to the Network Interface Unit h/w block.
+ *
+ */
+
+#include "netxen_nic.h"
+#include <linux/delay.h>
+
+void netxen_delay(int value)
+{
+	unsigned long remainder;
+
+	remainder = value / 50000;
+	do {
+		if (remainder > 1000) {
+			udelay(1000);
+			remainder -= 1000;
+		} else {
+			udelay(remainder + 1);
+			remainder = 0;
+		}
+	} while (remainder > 0);
+}
+
+/** 
+ * netxen_niu_gbe_phy_read - read a register from the GbE PHY via
+ * mii management interface.
+ *
+ * Note: The MII management interface goes through port 0.
+ *       Individual phys are addressed as follows:
+ * @param phy  [15:8]  phy id
+ * @param reg  [7:0]   register number
+ *
+ * @returns  0 on success
+ *          -1 on error
+ *
+ **/
+long netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long phy,
+			     long reg, netxen_crbword_t * readval)
+{
+	long timeout = 0;
+	long result = 0;
+	long restore = 0;
+	struct netxen_niu_gb_mii_mgmt_address address;
+	struct netxen_niu_gb_mii_mgmt_command command;
+	struct netxen_niu_gb_mii_mgmt_indicators status;
+	struct netxen_niu_gb_mii_mgmt_config mii_cfg;
+	struct netxen_niu_gb_mac_config_0_t mac_cfg0;
+
+	/* MII mgmt all goes through port 0 MAC interface, so it cannot be in reset */
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0),
+				  &mac_cfg0, 4))
+		return -1;
+	if (mac_cfg0.soft_reset) {
+		struct netxen_niu_gb_mac_config_0_t temp;
+		*(netxen_crbword_t *) & temp = 0;
+		temp.tx_reset_pb = 1;
+		temp.rx_reset_pb = 1;
+		temp.tx_reset_mac = 1;
+		temp.rx_reset_mac = 1;
+		if (netxen_nic_hw_write_wx(adapter,
+					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
+					   &temp, 4))
+			return -1;
+		restore = 1;
+	}
+
+	/* reset MII management interface */
+	*(netxen_crbword_t *) & mii_cfg = 0;
+	mii_cfg.clockselect = 7;
+	mii_cfg.reset = 1;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(0),
+				   &mii_cfg, 4))
+		return -1;
+	mii_cfg.reset = 0;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(0),
+				   &mii_cfg, 4))
+		return -1;
+
+	*(netxen_crbword_t *) & address = 0;
+	address.reg_addr = reg;
+	address.phy_addr = phy;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0),
+				   &address, 4))
+		return -1;
+	*(netxen_crbword_t *) & command = 0;	/* turn off any prior activity */
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
+				   &command, 4))
+		return -1;
+	/* send read command */
+	command.read_cycle = 1;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
+				   &command, 4))
+		return -1;
+
+	*(netxen_crbword_t *) & status = 0;
+	do {
+		if (netxen_nic_hw_read_wx(adapter,
+					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0),
+					  &status, 4))
+			return -1;
+		timeout++;
+	} while ((status.busy || status.notvalid)
+		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
+
+	if (timeout < NETXEN_NIU_PHY_WAITMAX) {
+		if (netxen_nic_hw_read_wx(adapter,
+					  NETXEN_NIU_GB_MII_MGMT_STATUS(0),
+					  readval, 4))
+			return -1;
+		result = 0;
+	} else
+		result = -1;
+
+	if (restore)
+		if (netxen_nic_hw_write_wx(adapter,
+					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
+					   &mac_cfg0, 4))
+			return -1;
+
+	return result;
+}
+
+/** 
+ * netxen_niu_gbe_phy_write - write a register to the GbE PHY via
+ * mii management interface.
+ *
+ * Note: The MII management interface goes through port 0.
+ *       Individual phys are addressed as follows:
+ * @param phy      [15:8]  phy id
+ * @param reg      [7:0]   register number
+ *
+ * @returns  0 on success
+ *          -1 on error
+ *
+ **/
+long netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
+			      long phy, long reg, netxen_crbword_t val)
+{
+	long timeout = 0;
+	long result = 0;
+	long restore = 0;
+	struct netxen_niu_gb_mii_mgmt_address address;
+	struct netxen_niu_gb_mii_mgmt_command command;
+	struct netxen_niu_gb_mii_mgmt_indicators status;
+	struct netxen_niu_gb_mac_config_0_t mac_cfg0;
+
+	/* MII mgmt all goes through port 0 MAC interface, so it cannot be in reset */
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0),
+				  &mac_cfg0, 4))
+		return -1;
+	if (mac_cfg0.soft_reset) {
+		struct netxen_niu_gb_mac_config_0_t temp;
+		*(netxen_crbword_t *) & temp = 0;
+		temp.tx_reset_pb = 1;
+		temp.rx_reset_pb = 1;
+		temp.tx_reset_mac = 1;
+		temp.rx_reset_mac = 1;
+		if (netxen_nic_hw_write_wx(adapter,
+					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
+					   &temp, 4))
+			return -1;
+		restore = 1;
+	}
+
+	*(netxen_crbword_t *) & command = 0;	/* turn off any prior activity */
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
+				   &command, 4))
+		return -1;
+
+	*(netxen_crbword_t *) & address = 0;
+	address.reg_addr = reg;
+	address.phy_addr = phy;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0),
+				   &address, 4))
+		return -1;
+
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CTRL(0),
+				   &val, 4))
+		return -1;
+
+	*(netxen_crbword_t *) & status = 0;
+	do {
+		if (netxen_nic_hw_read_wx(adapter,
+					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0),
+					  &status, 4))
+			return -1;
+		timeout++;
+	} while ((status.busy) && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
+
+	if (timeout < NETXEN_NIU_PHY_WAITMAX)
+		result = 0;
+	else
+		result = -1;
+
+	/* restore the state of port 0 MAC in case we tampered with it */
+	if (restore)
+		if (netxen_nic_hw_write_wx(adapter,
+					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
+					   &mac_cfg0, 4))
+			return -1;
+
+	return result;
+}
+
+long netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter,
+					  long port)
+{
+	long result = 0;
+	struct netxen_niu_phy_interrupt enable;
+	*(netxen_crbword_t *) & enable = 0;
+	enable.link_status_changed = 1;
+	enable.autoneg_completed = 1;
+	enable.speed_changed = 1;
+
+	if (0 !=
+	    netxen_niu_gbe_phy_write(adapter, port,
+				     NETXEN_NIU_GB_MII_MGMT_ADDR_INT_ENABLE,
+				     *(netxen_crbword_t *) & enable))
+		result = -1;
+
+	return result;
+}
+
+long netxen_niu_gbe_disable_phy_interrupts(struct netxen_adapter *adapter,
+					   long port)
+{
+	long result = 0;
+	if (0 !=
+	    netxen_niu_gbe_phy_write(adapter, port,
+				     NETXEN_NIU_GB_MII_MGMT_ADDR_INT_ENABLE, 0))
+		result = -1;
+
+	return result;
+}
+
+long netxen_niu_gbe_clear_phy_interrupts(struct netxen_adapter *adapter,
+					 long port)
+{
+	long result = 0;
+	if (0 !=
+	    netxen_niu_gbe_phy_write(adapter, port,
+				     NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
+				     -1))
+		result = -1;
+
+	return result;
+}
+
+/** 
+ * netxen_niu_gbe_set_mii_mode- Set 10/100 Mbit Mode for GbE MAC
+ *
+ **/
+void netxen_niu_gbe_set_mii_mode(struct netxen_adapter *adapter,
+				 long port, long enable)
+{
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_MODE, 0x2);
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				    0x80000000);
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				    0x0000f0025);
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_1(port),
+				    0xf1ff);
+	netxen_crb_writelit_adapter(adapter,
+				    NETXEN_NIU_GB0_GMII_MODE + (port << 3), 0);
+	netxen_crb_writelit_adapter(adapter,
+				    NETXEN_NIU_GB0_MII_MODE + (port << 3), 1);
+	netxen_crb_writelit_adapter(adapter,
+				    (NETXEN_NIU_GB0_HALF_DUPLEX + port * 4), 0);
+	netxen_crb_writelit_adapter(adapter,
+				    NETXEN_NIU_GB_MII_MGMT_CONFIG(port), 0x7);
+
+	if (enable) {
+		/* 
+		 * Do NOT enable flow control until a suitable solution for 
+		 *  shutting down pause frames is found. 
+		 */
+		netxen_crb_writelit_adapter(adapter,
+					    NETXEN_NIU_GB_MAC_CONFIG_0(port),
+					    0x5);
+	}
+
+	if (netxen_niu_gbe_enable_phy_interrupts(adapter, port))
+		printk("<1>ERROR enabling PHY interrupts\n");
+	if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
+		printk("<1>ERROR clearing PHY interrupts\n");
+}
+
+/** 
+ * netxen_niu_gbe_set_gmii_mode- Set GbE Mode for GbE MAC
+ **/
+void netxen_niu_gbe_set_gmii_mode(struct netxen_adapter *adapter,
+				  long port, long enable)
+{
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_MODE, 0x2);
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				    0x80000000);
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				    0x0000f0025);
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_1(port),
+				    0xf2ff);
+	netxen_crb_writelit_adapter(adapter,
+				    NETXEN_NIU_GB0_MII_MODE + (port << 3), 0);
+	netxen_crb_writelit_adapter(adapter,
+				    NETXEN_NIU_GB0_GMII_MODE + (port << 3), 1);
+	netxen_crb_writelit_adapter(adapter,
+				    (NETXEN_NIU_GB0_HALF_DUPLEX + port * 4), 0);
+	netxen_crb_writelit_adapter(adapter,
+				    NETXEN_NIU_GB_MII_MGMT_CONFIG(port), 0x7);
+
+	if (enable) {
+		/* 
+		 * Do NOT enable flow control until a suitable solution for 
+		 *  shutting down pause frames is found. 
+		 */
+		netxen_crb_writelit_adapter(adapter,
+					    NETXEN_NIU_GB_MAC_CONFIG_0(port),
+					    0x5);
+	}
+
+	if (netxen_niu_gbe_enable_phy_interrupts(adapter, port))
+		printk("<1>ERROR enabling PHY interrupts\n");
+	if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
+		printk("<1>ERROR clearing PHY interrupts\n");
+}
+
+long netxen_niu_gbe_init_port(struct netxen_adapter *adapter, long port)
+{
+	long result = 0;
+	struct netxen_niu_phy_status status;
+
+	if (0 ==
+	    netxen_niu_gbe_phy_read(adapter, port,
+				    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+				    (netxen_crbword_t *) & status)) {
+		if (status.link) {
+			if (status.speed == 2) {
+				netxen_niu_gbe_set_gmii_mode(adapter, port, 1);
+			} else if ((status.speed == 1) || (status.speed == 0)) {
+				netxen_niu_gbe_set_mii_mode(adapter, port, 1);
+			} else {
+				result = -1;
+			}
+
+		} else {
+			/* We don't have link. Cable  must be unconnected. */
+			/* Enable phy interrupts so we take action when plugged in */
+			netxen_crb_writelit_adapter(adapter,
+						    NETXEN_NIU_GB_MAC_CONFIG_0
+						    (port), 0x80000000);
+			netxen_crb_writelit_adapter(adapter,
+						    NETXEN_NIU_GB_MAC_CONFIG_0
+						    (port), 0x0000f0025);
+			if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
+				printk("<1>ERROR clearing PHY interrupts\n");
+			if (netxen_niu_gbe_enable_phy_interrupts(adapter, port))
+				printk("<1>ERROR enabling PHY interrupts\n");
+			if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
+				printk("<1>ERROR clearing PHY interrupts\n");
+			result = -1;
+		}
+	} else {
+		result = -1;
+	}
+	return result;
+}
+
+/** 
+ * netxen_niu_gbe_handle_phy_interrupt - Handles GbE PHY interrupts
+ * @param enable 0 means don't enable the port
+ *               1 means enable (or re-enable) the port
+ **/
+long netxen_niu_gbe_handle_phy_interrupt(struct netxen_adapter *adapter,
+					 long port, long enable)
+{
+	long result = 0;
+	struct netxen_niu_phy_interrupt int_src;
+
+	printk
+	    ("<1>NETXEN: Handling PHY interrupt on port %d (device enable = %d)\n",
+	     (int)port, (int)enable);
+
+	/* The read of the PHY INT status will clear the pending interrupt status */
+	if (netxen_niu_gbe_phy_read(adapter, port,
+				    NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
+				    (netxen_crbword_t *) & int_src) != 0)
+		result = -1;
+	else {
+		printk("<1>PHY Interrupt source = 0x%x \n", *(u32 *) & int_src);
+		if (int_src.jabber)
+			printk("<1>jabber Interrupt ");
+		if (int_src.polarity_changed)
+			printk("<1>polarity changed ");
+		if (int_src.energy_detect)
+			printk("<1>energy detect \n");
+		if (int_src.downshift)
+			printk("<1>downshift \n");
+		if (int_src.mdi_xover_changed)
+			printk("<1>mdi_xover_changed ");
+		if (int_src.fifo_over_underflow)
+			printk("<1>fifo_over_underflow ");
+		if (int_src.false_carrier)
+			printk("<1>false_carrier ");
+		if (int_src.symbol_error)
+			printk("<1>symbol_error ");
+		if (int_src.autoneg_completed)
+			printk("<1>autoneg_completed ");
+		if (int_src.page_received)
+			printk("<1>page_received ");
+		if (int_src.duplex_changed)
+			printk("<1>duplex_changed ");
+		if (int_src.autoneg_error)
+			printk("<1>autoneg_error ");
+		if ((int_src.speed_changed) || (int_src.link_status_changed)) {
+			struct netxen_niu_phy_status status;
+
+			printk("<1>speed_changed or link status changed");
+			if (netxen_niu_gbe_phy_read(adapter, port,
+						    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+						    (netxen_crbword_t *) &
+						    status) == 0) {
+				printk("<1>\n");
+				if (status.speed == 2) {
+					printk
+					    ("<1>Link speed changed to 1000 Mbps\n");
+					netxen_niu_gbe_set_gmii_mode(adapter,
+								     port,
+								     enable);
+				} else if (status.speed == 1) {
+					printk
+					    ("<1>Link speed changed to 100 Mbps\n");
+					netxen_niu_gbe_set_mii_mode(adapter,
+								    port,
+								    enable);
+				} else if (status.speed == 0) {
+					printk
+					    ("<1>Link speed changed to 10 Mbps\n");
+					netxen_niu_gbe_set_mii_mode(adapter,
+								    port,
+								    enable);
+				} else {
+					printk
+					    ("<1>ERROR reading PHY status. Illegal speed.\n");
+					result = -1;
+				}
+			} else {
+				printk("<1>ERROR reading PHY status.\n");
+				result = -1;
+			}
+
+		}
+		printk("<1>\n");
+	}
+	return result;
+}
+
+/**
+ * Return the current station MAC address.
+ * Note that the passed-in value must already be in network byte order.
+ **/
+int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
+			   int phy, netxen_ethernet_macaddr_t * addr)
+{
+	u64 result = 0;
+	struct netxen_niu_gb_station_address_high stationhigh;
+	struct netxen_niu_gb_station_address_low stationlow;
+
+	if (addr == NULL)
+		return -1;
+	if ((phy < 0) || (phy > 3))
+		return -1;
+
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy),
+				  &stationhigh, 4))
+		return -1;
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy),
+				  &stationlow, 4))
+		return -1;
+
+	result = (u64) stationlow.address;
+	result |= (u64) stationhigh.address << 16;
+	memcpy(*addr, &result, sizeof(netxen_ethernet_macaddr_t));
+
+	return 0;
+}
+
+/**
+ * Set the station MAC address.
+ * Note that the passed-in value must already be in network byte order.
+ **/
+int netxen_niu_macaddr_set(struct netxen_adapter *adapter, int phy,
+			   netxen_ethernet_macaddr_t addr)
+{
+	netxen_crbword_t temp = 0;
+
+	if ((phy < 0) || (phy > 3))
+		return -1;
+
+	memcpy(&temp, addr, 2);
+	temp <<= 16;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy),
+				   &temp, 4))
+		return -1;
+
+	temp = 0;
+
+	memcpy(&temp, ((u8 *) addr) + 2, sizeof(netxen_crbword_t));
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy),
+				   &temp, 4))
+		return -2;
+
+	return 0;
+}
+
+/* Enable a GbE interface */
+long netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
+				long port, netxen_niu_gbe_ifmode_t mode)
+{
+	struct netxen_niu_gb_mac_config_0_t mac_cfg0;
+	struct netxen_niu_gb_mac_config_1_t mac_cfg1;
+	struct netxen_niu_gb_mii_mgmt_config mii_cfg;
+
+	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
+		return -1;
+
+	*(netxen_crbword_t *) & mac_cfg0 = 0;
+	mac_cfg0.soft_reset = 1;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				   &mac_cfg0, 4))
+		return -1;
+	*(netxen_crbword_t *) & mac_cfg0 = 0;
+	mac_cfg0.tx_enable = 1;
+	mac_cfg0.rx_enable = 1;
+	mac_cfg0.rx_flowctl = 0;
+	mac_cfg0.tx_reset_pb = 1;
+	mac_cfg0.rx_reset_pb = 1;
+	mac_cfg0.tx_reset_mac = 1;
+	mac_cfg0.rx_reset_mac = 1;
+
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				   &mac_cfg0, 4))
+		return -1;
+	*(netxen_crbword_t *) & mac_cfg1 = 0;
+	mac_cfg1.preamblelen = 0xf;
+	mac_cfg1.duplex = 1;
+	mac_cfg1.crc_enable = 1;
+	mac_cfg1.padshort = 1;
+	mac_cfg1.checklength = 1;
+	mac_cfg1.hugeframes = 1;
+
+	if (mode == NETXEN_NIU_10_100_MB) {
+		mac_cfg1.intfmode = 1;
+		if (netxen_nic_hw_write_wx(adapter,
+					   NETXEN_NIU_GB_MAC_CONFIG_1(port),
+					   &mac_cfg1, 4))
+			return -1;
+
+		/* set mii mode */
+		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_GMII_MODE +
+					    (port << 3), 0);
+		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_MII_MODE +
+					    (port << 3), 1);
+
+	} else if (mode == NETXEN_NIU_1000_MB) {
+		mac_cfg1.intfmode = 2;
+		if (netxen_nic_hw_write_wx(adapter,
+					   NETXEN_NIU_GB_MAC_CONFIG_1(port),
+					   &mac_cfg1, 4))
+			return -1;
+		/* set gmii mode */
+		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_MII_MODE +
+					    (port << 3), 0);
+		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_GMII_MODE +
+					    (port << 3), 1);
+	}
+	*(netxen_crbword_t *) & mii_cfg = 0;
+	mii_cfg.clockselect = 7;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(port),
+				   &mii_cfg, 4))
+		return -1;
+
+	*(netxen_crbword_t *) & mac_cfg0 = 0;
+	mac_cfg0.tx_enable = 1;
+	mac_cfg0.rx_enable = 1;
+	mac_cfg0.tx_flowctl = 0;
+	mac_cfg0.rx_flowctl = 0;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				   &mac_cfg0, 4))
+		return -1;
+	return 0;
+}
+
+/* Disable a GbE interface */
+long netxen_niu_disable_gbe_port(struct netxen_adapter *adapter, long port)
+{
+	struct netxen_niu_gb_mac_config_0_t mac_cfg0;
+
+	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
+		return -1;
+
+	*(netxen_crbword_t *) & mac_cfg0 = 0;
+	mac_cfg0.soft_reset = 1;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				   &mac_cfg0, 4))
+		return -1;
+	return 0;
+}
+
+/* Disable an XG interface */
+long netxen_niu_disable_xg_port(struct netxen_adapter *adapter, long port)
+{
+	struct netxen_niu_xg_mac_config_0_t mac_cfg;
+
+	if (port != 0)
+		return -1;
+
+	*(netxen_crbword_t *) & mac_cfg = 0;
+	mac_cfg.soft_reset = 1;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_CONFIG_0,
+				   &mac_cfg, 4))
+		return -1;
+	return 0;
+}
+
+/* Set promiscuous mode for a GbE interface */
+long netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter, long port,
+				     netxen_niu_prom_mode_t mode)
+{
+	struct netxen_niu_gb_drop_crc reg;
+	long data;
+
+	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
+		return -1;
+
+	if (mode == NETXEN_NIU_PROMISCOUS_MODE)
+		data = 0;
+	else
+		data = 1;
+
+	/* save previous contents */
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR,
+				  &reg, 4))
+		return -1;
+	switch (port) {
+	case 0:
+		reg.drop_gb0 = data;
+		break;
+	case 1:
+		reg.drop_gb0 = data;
+		break;
+	case 2:
+		reg.drop_gb0 = data;
+		break;
+	case 3:
+		reg.drop_gb0 = data;
+		break;
+	default:
+		return -1;
+	}
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR,
+				   &reg, 4))
+		return -1;
+	return 0;
+}
+
+/**
+ * Set the MAC address for an XG port
+ * Note that the passed-in value must already be in network byte order.
+ **/
+int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter, int phy,
+			      netxen_ethernet_macaddr_t addr)
+{
+	netxen_crbword_t temp = 0;
+
+	if ((phy < 0) || (phy > 3))
+		return -1;
+
+	memcpy(&temp, addr, 2);
+	temp <<= 16;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
+				   &temp, 4))
+		return -1;
+
+	temp = 0;
+
+	memcpy(&temp, ((u8 *) addr) + 2, sizeof(netxen_crbword_t));
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
+				   &temp, 4))
+		return -1;
+
+	return 0;
+}
+
+/**
+ * Return the current station MAC address.
+ * Note that the passed-in value must already be in network byte order.
+ **/
+int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter, int phy,
+			      netxen_ethernet_macaddr_t * addr)
+{
+	netxen_crbword_t stationhigh;
+	netxen_crbword_t stationlow;
+	u64 result;
+
+	if (addr == NULL)
+		return -1;
+	if (phy != 0)
+		return -1;
+
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
+				  &stationhigh, 4))
+		return -1;
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
+				  &stationlow, 4))
+		return -1;
+
+	result = ((u64) stationlow) >> 16;
+	result |= (u64) stationhigh << 16;
+	memcpy(*addr, &result, sizeof(netxen_ethernet_macaddr_t));
+
+	return 0;
+}
+
+long netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
+					long port, netxen_niu_prom_mode_t mode)
+{
+	long reg;
+
+	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
+		return -1;
+
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_CONFIG_1, &reg, 4))
+		return -1;
+	if (mode == NETXEN_NIU_PROMISCOUS_MODE)
+		reg = (reg | 0x2000UL);
+	else
+		reg = (reg & ~0x2000UL);
+
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_XGE_CONFIG_1, reg);
+
+	return 0;
+}
diff -Naru linux-2.6.16.18.orig/drivers/net/netxen/netxen_nic_phan_reg.h linux-2.6.16.18/drivers/net/netxen/netxen_nic_phan_reg.h
--- linux-2.6.16.18.orig/drivers/net/netxen/netxen_nic_phan_reg.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.16.18/drivers/net/netxen/netxen_nic_phan_reg.h	2006-05-25 02:43:22.000000000 -0700
@@ -0,0 +1,195 @@
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
+ */
+
+#ifndef __NIC_PHAN_REG_H_
+#define __NIC_PHAN_REG_H_
+
+/** 
+ * CRB Registers or queue message done only at initialization time.
+ **/
+
+/**
+ * The following 2 are the base adresses for the CRB registers and their
+ * offsets will be added to get addresses for the index addresses.
+ **/
+#define NIC_CRB_BASE_PORT1	NETXEN_CAM_RAM(0x200)
+#define NIC_CRB_BASE_PORT2	NETXEN_CAM_RAM(0x250)
+
+#define NETXEN_NIC_REG(X)	(NIC_CRB_BASE_PORT1+(X))
+
+/**
+ * CrbPortPhanCntrHi/Lo is used to pass the address of HostPhantomIndex address
+ * which can be read by the Phantom host to get producer/consumer indexes from
+ * Phantom/Casper. If it is not HOST_SHARED_MEMORY, then the following
+ * registers will be used for the addresses of the ring's shared memory
+ * on the Phantom.
+ **/
+
+#define CRB_PHAN_CNTRL_LO_OFFSET	NETXEN_NIC_REG(0x00)
+#define CRB_PHAN_CNTRL_HI_OFFSET	NETXEN_NIC_REG(0x04)
+
+/* point to the indexes */
+#define CRB_CMD_PRODUCER_OFFSET		NETXEN_NIC_REG(0x08)
+#define CRB_CMD_CONSUMER_OFFSET		NETXEN_NIC_REG(0x0c)
+
+/* address of command descriptors in the host memory */
+#define CRB_HOST_CMD_ADDR_HI		NETXEN_NIC_REG(0x30)
+#define CRB_HOST_CMD_ADDR_LO		NETXEN_NIC_REG(0x34)
+
+/* The following 4 CRB registers are for doing performance coal */
+#define CRB_CMD_INTR_LOOP		NETXEN_NIC_REG(0x38)
+#define CRB_CMD_DMA_LOOP		NETXEN_NIC_REG(0x3c)
+#define CRB_RCV_INTR_LOOP		NETXEN_NIC_REG(0x40)
+#define CRB_RCV_DMA_LOOP		NETXEN_NIC_REG(0x44)
+
+/* Needed by the host to find out the state of Phantom's initialization */
+#define CRB_ENABLE_TX_INTR		NETXEN_NIC_REG(0x4c)
+#define CRB_CMDPEG_STATE		NETXEN_NIC_REG(0x50)
+#define CRB_CMDPEG_CMDRING		NETXEN_NIC_REG(0x54)
+
+/* Interrupt coalescing parameters */
+#define CRB_GLOBAL_INT_COAL		NETXEN_NIC_REG(0x80)
+#define CRB_INT_COAL_MODE		NETXEN_NIC_REG(0x84)
+#define CRB_MAX_RCV_BUFS		NETXEN_NIC_REG(0x88)
+#define CRB_TX_INT_THRESHOLD		NETXEN_NIC_REG(0x8c)
+#define CRB_RX_PKT_TIMER		NETXEN_NIC_REG(0x90)
+#define CRB_TX_PKT_TIMER		NETXEN_NIC_REG(0x94)
+#define CRB_RX_PKT_CNT			NETXEN_NIC_REG(0x98)
+#define CRB_RX_TMR_CNT			NETXEN_NIC_REG(0x9c)
+
+/* Register for communicating XG link status */
+#define CRB_XG_STATE			NETXEN_NIC_REG(0xa0)
+
+/* Debug registers for controlling NIC pkt gen agent */
+#define CRB_AGENT_GO			NETXEN_NIC_REG(0xb0)
+#define CRB_AGENT_TX_SIZE		NETXEN_NIC_REG(0xb4)
+#define CRB_AGENT_TX_TYPE		NETXEN_NIC_REG(0xb8)
+#define CRB_AGENT_TX_ADDR		NETXEN_NIC_REG(0xbc)
+#define CRB_AGENT_TX_MSS		NETXEN_NIC_REG(0xc0)
+
+/* Debug registers for observing NIC performance */
+#define CRB_TX_STATE			NETXEN_NIC_REG(0xd0)
+#define CRB_TX_COUNT			NETXEN_NIC_REG(0xd4)
+#define CRB_RX_STATE			NETXEN_NIC_REG(0xd8)
+
+/* CRB registers per Rcv Descriptor ring */
+struct netxen_rcv_desc_crb {
+	u32 crb_rcv_producer_offset __attribute__ ((aligned(512)));
+	u32 crb_rcv_consumer_offset;
+	u32 crb_globalrcv_ring;
+};
+
+/*
+ * CRB registers used by the receive peg logic. One instance of these
+ * needs to be instantiated per instance of the receive peg.
+ */
+
+struct netxen_recv_crb {
+	struct netxen_rcv_desc_crb rcv_desc_crb[NUM_RCV_DESC_RINGS];
+	u32 crb_rcvstatus_ring;
+	u32 crb_rcv_status_producer;
+	u32 crb_rcv_status_consumer;
+	u32 crb_rcvpeg_state;
+};
+
+#if defined(DEFINE_GLOBAL_RECV_CRB)
+struct netxen_recv_crb recv_crb_registers[] = {
+	/*
+	 * Instance 0.
+	 */
+	{
+	 /* rcv_desc_crb: */
+	 {
+	  {
+	   /* crb_rcv_producer_offset: */
+	   NETXEN_NIC_REG(0x18),
+	   /* crb_rcv_consumer_offset: */
+	   NETXEN_NIC_REG(0x1c),
+	   /* crb_gloablrcv_ring: */
+	   NETXEN_NIC_REG(0x20),
+	   },
+	  /* Jumbo frames */
+	  {
+	   /* crb_rcv_producer_offset: */
+	   NETXEN_NIC_REG(0x100),
+	   /* crb_rcv_consumer_offset: */
+	   NETXEN_NIC_REG(0x104),
+	   /* crb_gloablrcv_ring: */
+	   NETXEN_NIC_REG(0x108),
+	   }
+	  },
+	 /* crb_rcvstatus_ring: */
+	 NETXEN_NIC_REG(0x24),
+	 /* crb_rcv_status_producer: */
+	 NETXEN_NIC_REG(0x28),
+	 /* crb_rcv_status_consumer: */
+	 NETXEN_NIC_REG(0x2c),
+	 /* crb_rcvpeg_state: */
+	 NETXEN_NIC_REG(0x48),
+
+	 },
+	/*
+	 * Instance 1,
+	 */
+	{
+	 /* rcv_desc_crb: */
+	 {
+	  {
+	   /* crb_rcv_producer_offset: */
+	   NETXEN_NIC_REG(0x80),
+	   /* crb_rcv_consumer_offset: */
+	   NETXEN_NIC_REG(0x84),
+	   /* crb_globalrcv_ring: */
+	   NETXEN_NIC_REG(0x88),
+	   },
+	  /* Jumbo frames */
+	  {
+	   /* crb_rcv_producer_offset: */
+	   NETXEN_NIC_REG(0x10C),
+	   /* crb_rcv_consumer_offset: */
+	   NETXEN_NIC_REG(0x110),
+	   /* crb_globalrcv_ring: */
+	   NETXEN_NIC_REG(0x114),
+	   }
+	  },
+	 /* crb_rcvstatus_ring: */
+	 NETXEN_NIC_REG(0x8c),
+	 /* crb_rcv_status_producer: */
+	 NETXEN_NIC_REG(0x90),
+	 /* crb_rcv_status_consumer: */
+	 NETXEN_NIC_REG(0x94),
+	 /* crb_rcvpeg_state: */
+	 NETXEN_NIC_REG(0x98),
+	 },
+};
+#else
+extern struct netxen_recv_crb recv_crb_registers[];
+#endif				/* DEFINE_GLOBAL_RECEIVE_CRB */
+
+#endif				/* __NIC_PHAN_REG_H_ */

