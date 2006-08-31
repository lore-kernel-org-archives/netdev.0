From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 2.6.17 4/9] NetXen: intr routines and niu handling
Date: Thu, 31 Aug 2006 07:20:02 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0608310717170.23783@dut39>
References: <Pine.LNX.4.64.0608310543370.23783@dut39>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sanjeev@netxen.com, rob@netxen.com, unmproj@linsyssoft.com,
	shemminger@osdl.org, brazilnut@us.ibm.com, wendyx@us.ibm.com,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:46957 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S932325AbWHaOUD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 10:20:03 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0608310543370.23783@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -Narup -X linux-2.6.17.orig/Documentation/dontdiff linux-2.6.17.orig/drivers/net/netxen/netxen_nic_isr.c linux-2.6.17/drivers/net/netxen/netxen_nic_isr.c
--- linux-2.6.17.orig/drivers/net/netxen/netxen_nic_isr.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.17/drivers/net/netxen/netxen_nic_isr.c	2006-08-31 06:17:22.000000000 -0700
@@ -0,0 +1,301 @@
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
+#include <linux/netdevice.h>
+#include <linux/delay.h>
+
+#include "netxen_nic.h"
+#include "netxen_nic_hw.h"
+#include "netxen_nic_phan_reg.h"
+
+/*
+ * netxen_nic_get_stats - Get System Network Statistics
+ * @netdev: network interface device structure
+ */
+struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
+{
+	struct netxen_port *port = netdev_priv(netdev);
+	struct net_device_stats *stats = &port->net_stats;
+
+	memset(stats, 0, sizeof(*stats));
+
+	/* total packets received   */
+	stats->rx_packets = port->stats.no_rcv;
+	/* total packets transmitted    */
+	stats->tx_packets = port->stats.xmitedframes + port->stats.xmitfinished;
+	/* total bytes received     */
+	stats->rx_bytes = port->stats.rxbytes;
+	/* total bytes transmitted  */
+	stats->tx_bytes = port->stats.txbytes;
+	/* bad packets received     */
+	stats->rx_errors = port->stats.rcvdbadskb;
+	/* packet transmit problems */
+	stats->tx_errors = port->stats.nocmddescriptor;
+	/* no space in linux buffers    */
+	stats->rx_dropped = port->stats.updropped;
+	/* no space available in linux  */
+	stats->tx_dropped = port->stats.txdropped;
+
+	return stats;
+}
+
+long netxen_nic_enable_phy_interrupts(struct netxen_adapter *adapter,
+				      long portno)
+{
+	long result = 0;
+
+	switch (adapter->ahw.board_type) {
+	case NETXEN_NIC_GBE:
+		result = netxen_niu_gbe_enable_phy_interrupts(adapter, portno);
+		break;
+
+	case NETXEN_NIC_XGBE:
+		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_INT_MASK, 0x3f);
+		break;
+
+	default:
+		printk(KERN_ERR "%s: Unknown board type\n",
+		       netxen_nic_driver_name);
+		result = -1;
+	}
+
+	return result;
+}
+
+long netxen_nic_disable_phy_interrupts(struct netxen_adapter *adapter,
+				       long portno)
+{
+	long result = 0;
+
+	switch (adapter->ahw.board_type) {
+	case NETXEN_NIC_GBE:
+		result = netxen_niu_gbe_disable_phy_interrupts(adapter, portno);
+		break;
+
+	case NETXEN_NIC_XGBE:
+		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_INT_MASK, 0x7f);
+		break;
+
+	default:
+		printk(KERN_ERR "%s: Unknown board type\n",
+		       netxen_nic_driver_name);
+		result = -1;
+	}
+
+	return result;
+}
+
+long netxen_nic_clear_phy_interrupts(struct netxen_adapter *adapter,
+				     long portno)
+{
+	long result = 0;
+
+	switch (adapter->ahw.board_type) {
+	case NETXEN_NIC_GBE:
+		result = netxen_niu_gbe_clear_phy_interrupts(adapter, portno);
+		break;
+
+	case NETXEN_NIC_XGBE:
+		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_ACTIVE_INT, -1);
+		break;
+
+	default:
+		printk(KERN_ERR "%s: Unknown board type\n",
+		       netxen_nic_driver_name);
+		result = -1;
+	}
+
+	return result;
+}
+
+void netxen_indicate_link_status(struct netxen_adapter *adapter, u32 portno,
+				 u32 link)
+{
+	struct netxen_port *pport = adapter->port[portno];
+	struct net_device *netdev = pport->netdev;
+
+	if (link)
+		netif_carrier_on(netdev);
+	else
+		netif_carrier_off(netdev);
+}
+
+void netxen_handle_port_int(struct netxen_adapter *adapter, u32 portno,
+			    u32 enable)
+{
+	netxen_niu_phy_interrupt int_src;
+	struct netxen_port *port;
+
+	/*  This should clear the interrupt source */
+	netxen_nic_phy_read(adapter, portno,
+			    NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS, &int_src);
+	if (int_src == 0) {
+		DPRINTK(INFO, "No phy interrupts for port #%d\n", portno);
+		return;
+	}
+	netxen_nic_disable_phy_interrupts(adapter, portno);
+
+	port = adapter->port[portno];
+
+	if (netxen_get_phy_int_jabber(int_src))
+		DPRINTK(INFO, "NetXen: %s Jabber interrupt \n",
+			port->netdev->name);
+
+	if (netxen_get_phy_int_polarity_changed(int_src))
+		DPRINTK(INFO, "NetXen: %s POLARITY CHANGED int \n",
+			port->netdev->name);
+
+	if (netxen_get_phy_int_energy_detect(int_src))
+		DPRINTK(INFO, "NetXen: %s ENERGY DETECT INT \n",
+			port->netdev->name);
+
+	if (netxen_get_phy_int_downshift(int_src))
+		DPRINTK(INFO, "NetXen: %s DOWNSHIFT INT \n",
+			port->netdev->name);
+	/* write it down later.. */
+	if ((netxen_get_phy_int_speed_changed(int_src))
+	    || (netxen_get_phy_int_link_status_changed(int_src))) {
+		netxen_niu_phy_status status;
+
+		DPRINTK(INFO, "NetXen: %s SPEED CHANGED OR"
+			" LINK STATUS CHANGED \n", port->netdev->name);
+
+		if (netxen_nic_phy_read(adapter, portno,
+					NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+					&status) == 0) {
+			if (netxen_get_phy_int_link_status_changed(int_src)) {
+				if (netxen_get_phy_link(status)) {
+					netxen_niu_gbe_init_port(adapter,
+								 portno);
+					printk("%s: %s Link UP\n",
+					       netxen_nic_driver_name,
+					       port->netdev->name);
+
+				} else {
+					printk("%s: %s Link DOWN\n",
+					       netxen_nic_driver_name,
+					       port->netdev->name);
+				}
+				netxen_indicate_link_status(adapter, portno,
+							    netxen_get_phy_link
+							    (status));
+			}
+		}
+	}
+	netxen_nic_enable_phy_interrupts(adapter, portno);
+}
+
+void netxen_nic_isr_other(struct netxen_adapter *adapter)
+{
+	u32 enable, portno;
+	u32 i2qhi;
+
+	/*
+	 * bit 3 is for i2qInt, if high its enabled
+	 * check for phy interrupts
+	 * read vector and check for bit 45 for phy
+	 * clear int by writing the same value into ISR_INT_VECTOR REG
+	 */
+
+	DPRINTK(INFO, "I2Q is the source of INT \n");
+
+	/* verify the offset */
+	i2qhi = readl(NETXEN_CRB_NORMALIZE(adapter, NETXEN_I2Q_CLR_PCI_HI));
+
+	DPRINTK(INFO, "isr NETXEN_I2Q_CLR_PCI_HI = 0x%x \n", i2qhi);
+
+	if (i2qhi & 0x4000) {
+		for (portno = 0; portno < NETXEN_NIU_MAX_GBE_PORTS; portno++) {
+			DPRINTK(INFO, "External PHY interrupt ON PORT %d\n",
+				portno);
+
+			enable = 1;
+			netxen_handle_port_int(adapter, portno, enable);
+		}
+
+		/* Clear the interrupt on I2Q */
+		writel((u32) i2qhi,
+		       NETXEN_CRB_NORMALIZE(adapter, NETXEN_I2Q_CLR_PCI_HI));
+
+	}
+}
+
+void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
+{
+	u32 val, val1;
+
+	switch (adapter->ahw.board_type) {
+	case NETXEN_NIC_GBE:
+		val = readl(NETXEN_CRB_NORMALIZE(adapter, ISR_INT_VECTOR));
+		if (val & 0x4) {
+			adapter->stats.otherints++;
+			netxen_nic_isr_other(adapter);
+		}
+		break;
+
+	case NETXEN_NIC_XGBE:
+		{
+			struct net_device *netdev = adapter->port[0]->netdev;
+
+			/* WINDOW = 1 */
+			val1 =
+			    readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
+
+			if (adapter->ahw.xg_linkup == 1 && val1 != XG_LINK_UP) {
+				printk(KERN_INFO "%s: %s NIC Link is down\n",
+				       netxen_nic_driver_name, netdev->name);
+				adapter->ahw.xg_linkup = 0;
+				/* read twice to clear sticky bits */
+				/* WINDOW = 0 */
+				netxen_nic_read_w0(adapter,
+						   NETXEN_NIU_XG_STATUS, &val1);
+				netxen_nic_read_w0(adapter,
+						   NETXEN_NIU_XG_STATUS, &val1);
+
+				if ((val1 & 0xffb) != 0xffb) {
+					printk(KERN_INFO
+					       "%s ISR: Sync/Align BAD: 0x%08x\n",
+					       netxen_nic_driver_name, val1);
+				}
+
+			} else if (adapter->ahw.xg_linkup == 0
+				   && val1 == XG_LINK_UP) {
+				printk(KERN_INFO "%s: %s NIC Link is up\n",
+				       netxen_nic_driver_name, netdev->name);
+				adapter->ahw.xg_linkup = 1;
+			}
+
+		}
+		break;
+
+	default:
+		printk(KERN_ERR "%s ISR: Unknown board type\n",
+		       netxen_nic_driver_name);
+	}
+}
diff -Narup -X linux-2.6.17.orig/Documentation/dontdiff linux-2.6.17.orig/drivers/net/netxen/netxen_nic_niu.c linux-2.6.17/drivers/net/netxen/netxen_nic_niu.c
--- linux-2.6.17.orig/drivers/net/netxen/netxen_nic_niu.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.17/drivers/net/netxen/netxen_nic_niu.c	2006-08-31 06:17:22.000000000 -0700
@@ -0,0 +1,779 @@
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
+	netxen_niu_gb_mii_mgmt_address address;
+	netxen_niu_gb_mii_mgmt_command command;
+	netxen_niu_gb_mii_mgmt_indicators status;
+	netxen_niu_gb_mii_mgmt_config mii_cfg;
+	netxen_niu_gb_mac_config_0_t mac_cfg0;
+
+	/* MII mgmt all goes through port 0 MAC interface, so it cannot be in reset */
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0),
+				  &mac_cfg0, 4))
+		return -EIO;
+	if (netxen_gb_get_soft_reset(mac_cfg0)) {
+		netxen_niu_gb_mac_config_0_t temp;
+		temp = 0;
+		netxen_gb_tx_reset_pb(temp);
+		netxen_gb_rx_reset_pb(temp);
+		netxen_gb_tx_reset_mac(temp);
+		netxen_gb_rx_reset_mac(temp);
+		if (netxen_nic_hw_write_wx(adapter,
+					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
+					   &temp, 4))
+			return -EIO;
+		restore = 1;
+	}
+
+	/* reset MII management interface */
+	mii_cfg = 0;
+	netxen_gb_set_mii_mgmt_clockselect(mii_cfg, 7);
+	netxen_gb_mii_mgmt_reset(mii_cfg);
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(0),
+				   &mii_cfg, 4))
+		return -EIO;
+	netxen_gb_mii_mgmt_unset(mii_cfg);
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(0),
+				   &mii_cfg, 4))
+		return -EIO;
+
+	address = 0;
+	netxen_gb_mii_mgmt_reg_addr(address, reg);
+	netxen_gb_mii_mgmt_phy_addr(address, phy);
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0),
+				   &address, 4))
+		return -EIO;
+	command = 0;		/* turn off any prior activity */
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
+				   &command, 4))
+		return -EIO;
+	/* send read command */
+	netxen_gb_mii_mgmt_set_read_cycle(command);
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
+				   &command, 4))
+		return -EIO;
+
+	status = 0;
+	do {
+		if (netxen_nic_hw_read_wx(adapter,
+					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0),
+					  &status, 4))
+			return -EIO;
+		timeout++;
+	} while ((netxen_get_gb_mii_mgmt_busy(status)
+		  || netxen_get_gb_mii_mgmt_notvalid(status))
+		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
+
+	if (timeout < NETXEN_NIU_PHY_WAITMAX) {
+		if (netxen_nic_hw_read_wx(adapter,
+					  NETXEN_NIU_GB_MII_MGMT_STATUS(0),
+					  readval, 4))
+			return -EIO;
+		result = 0;
+	} else
+		result = -1;
+
+	if (restore)
+		if (netxen_nic_hw_write_wx(adapter,
+					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
+					   &mac_cfg0, 4))
+			return -EIO;
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
+	netxen_niu_gb_mii_mgmt_address address;
+	netxen_niu_gb_mii_mgmt_command command;
+	netxen_niu_gb_mii_mgmt_indicators status;
+	netxen_niu_gb_mac_config_0_t mac_cfg0;
+
+	/* MII mgmt all goes through port 0 MAC interface, so it cannot be in reset */
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0),
+				  &mac_cfg0, 4))
+		return -EIO;
+	if (netxen_gb_get_soft_reset(mac_cfg0)) {
+		netxen_niu_gb_mac_config_0_t temp;
+		temp = 0;
+		netxen_gb_tx_reset_pb(temp);
+		netxen_gb_rx_reset_pb(temp);
+		netxen_gb_tx_reset_mac(temp);
+		netxen_gb_rx_reset_mac(temp);
+
+		if (netxen_nic_hw_write_wx(adapter,
+					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
+					   &temp, 4))
+			return -EIO;
+		restore = 1;
+	}
+
+	command = 0;		/* turn off any prior activity */
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
+				   &command, 4))
+		return -EIO;
+
+	address = 0;
+	netxen_gb_mii_mgmt_reg_addr(address, reg);
+	netxen_gb_mii_mgmt_phy_addr(address, phy);
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0),
+				   &address, 4))
+		return -EIO;
+
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CTRL(0),
+				   &val, 4))
+		return -EIO;
+
+	status = 0;
+	do {
+		if (netxen_nic_hw_read_wx(adapter,
+					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0),
+					  &status, 4))
+			return -EIO;
+		timeout++;
+	} while ((netxen_get_gb_mii_mgmt_busy(status))
+		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
+
+	if (timeout < NETXEN_NIU_PHY_WAITMAX)
+		result = 0;
+	else
+		result = -EIO;
+
+	/* restore the state of port 0 MAC in case we tampered with it */
+	if (restore)
+		if (netxen_nic_hw_write_wx(adapter,
+					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
+					   &mac_cfg0, 4))
+			return -EIO;
+
+	return result;
+}
+
+long netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter,
+					  long port)
+{
+	long result = 0;
+	netxen_niu_phy_interrupt enable = 0;
+	netxen_set_phy_int_link_status_changed(enable);
+	netxen_set_phy_int_autoneg_completed(enable);
+	netxen_set_phy_int_speed_changed(enable);
+
+	if (0 !=
+	    netxen_niu_gbe_phy_write(adapter, port,
+				     NETXEN_NIU_GB_MII_MGMT_ADDR_INT_ENABLE,
+				     enable))
+		result = -EIO;
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
+		result = -EIO;
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
+				     -EIO))
+		result = -EIO;
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
+		printk(KERN_ERR PFX "ERROR enabling PHY interrupts\n");
+	if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
+		printk(KERN_ERR PFX "ERROR clearing PHY interrupts\n");
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
+		printk(KERN_ERR PFX "ERROR enabling PHY interrupts\n");
+	if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
+		printk(KERN_ERR PFX "ERROR clearing PHY interrupts\n");
+}
+
+long netxen_niu_gbe_init_port(struct netxen_adapter *adapter, long port)
+{
+	long result = 0;
+	netxen_niu_phy_status status;
+
+	if (0 ==
+	    netxen_niu_gbe_phy_read(adapter, port,
+				    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+				    (netxen_crbword_t *) & status)) {
+		if (netxen_get_phy_link(status)) {
+			if (netxen_get_phy_speed(status) == 2) {
+				netxen_niu_gbe_set_gmii_mode(adapter, port, 1);
+			} else if ((netxen_get_phy_speed(status) == 1)
+				   || (netxen_get_phy_speed(status) == 0)) {
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
+				printk(KERN_ERR PFX
+				       "ERROR clearing PHY interrupts\n");
+			if (netxen_niu_gbe_enable_phy_interrupts(adapter, port))
+				printk(KERN_ERR PFX
+				       "ERROR enabling PHY interrupts\n");
+			if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
+				printk(KERN_ERR PFX
+				       "ERROR clearing PHY interrupts\n");
+			result = -1;
+		}
+	} else {
+		result = -EIO;
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
+	netxen_niu_phy_interrupt int_src;
+
+	printk(KERN_INFO PFX "NETXEN: Handling PHY interrupt on port %d"
+	       " (device enable = %d)\n", (int)port, (int)enable);
+
+	/* The read of the PHY INT status will clear the pending interrupt status */
+	if (netxen_niu_gbe_phy_read(adapter, port,
+				    NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
+				    &int_src) != 0)
+		result = -EINVAL;
+	else {
+		printk(KERN_INFO PFX "PHY Interrupt source = 0x%x \n", int_src);
+		if (netxen_get_phy_int_jabber(int_src))
+			printk(KERN_INFO PFX "jabber Interrupt ");
+		if (netxen_get_phy_int_polarity_changed(int_src))
+			printk(KERN_INFO PFX "polarity changed ");
+		if (netxen_get_phy_int_energy_detect(int_src))
+			printk(KERN_INFO PFX "energy detect \n");
+		if (netxen_get_phy_int_downshift(int_src))
+			printk(KERN_INFO PFX "downshift \n");
+		if (netxen_get_phy_int_mdi_xover_changed(int_src))
+			printk(KERN_INFO PFX "mdi_xover_changed ");
+		if (netxen_get_phy_int_fifo_over_underflow(int_src))
+			printk(KERN_INFO PFX "fifo_over_underflow ");
+		if (netxen_get_phy_int_false_carrier(int_src))
+			printk(KERN_INFO PFX "false_carrier ");
+		if (netxen_get_phy_int_symbol_error(int_src))
+			printk(KERN_INFO PFX "symbol_error ");
+		if (netxen_get_phy_int_autoneg_completed(int_src))
+			printk(KERN_INFO PFX "autoneg_completed ");
+		if (netxen_get_phy_int_page_received(int_src))
+			printk(KERN_INFO PFX "page_received ");
+		if (netxen_get_phy_int_duplex_changed(int_src))
+			printk(KERN_INFO PFX "duplex_changed ");
+		if (netxen_get_phy_int_autoneg_error(int_src))
+			printk(KERN_INFO PFX "autoneg_error ");
+		if ((netxen_get_phy_int_speed_changed(int_src))
+		    || (netxen_get_phy_int_link_status_changed(int_src))) {
+			netxen_niu_phy_status status;
+
+			printk(KERN_INFO PFX
+			       "speed_changed or link status changed");
+			if (netxen_niu_gbe_phy_read
+			    (adapter, port,
+			     NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+			     &status) == 0) {
+				if (netxen_get_phy_speed(status) == 2) {
+					printk
+					    (KERN_INFO PFX "Link speed changed"
+					     " to 1000 Mbps\n");
+					netxen_niu_gbe_set_gmii_mode(adapter,
+								     port,
+								     enable);
+				} else if (netxen_get_phy_speed(status) == 1) {
+					printk
+					    (KERN_INFO PFX "Link speed changed"
+					     " to 100 Mbps\n");
+					netxen_niu_gbe_set_mii_mode(adapter,
+								    port,
+								    enable);
+				} else if (netxen_get_phy_speed(status) == 0) {
+					printk
+					    (KERN_INFO PFX "Link speed changed"
+					     " to 10 Mbps\n");
+					netxen_niu_gbe_set_mii_mode(adapter,
+								    port,
+								    enable);
+				} else {
+					printk(KERN_ERR PFX "ERROR reading"
+					       "PHY status. Illegal speed.\n");
+					result = -1;
+				}
+			} else {
+				printk(KERN_ERR PFX
+				       "ERROR reading PHY status.\n");
+				result = -1;
+			}
+
+		}
+		printk(KERN_INFO "\n");
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
+	netxen_niu_gb_station_address_high stationhigh;
+	netxen_niu_gb_station_address_low stationlow;
+
+	if (addr == NULL)
+		return -EINVAL;
+	if ((phy < 0) || (phy > 3))
+		return -EINVAL;
+
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy),
+				  &stationhigh, 4))
+		return -EIO;
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy),
+				  &stationlow, 4))
+		return -EIO;
+
+	result = (u64) netxen_gb_get_stationaddress_low(stationlow);
+	result |= (u64) stationhigh << 16;
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
+		return -EINVAL;
+
+	memcpy(&temp, addr, 2);
+	temp <<= 16;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy),
+				   &temp, 4))
+		return -EIO;
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
+	netxen_niu_gb_mac_config_0_t mac_cfg0;
+	netxen_niu_gb_mac_config_1_t mac_cfg1;
+	netxen_niu_gb_mii_mgmt_config mii_cfg;
+
+	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
+		return -EINVAL;
+
+	mac_cfg0 = 0;
+	netxen_gb_soft_reset(mac_cfg0);
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				   &mac_cfg0, 4))
+		return -EIO;
+	mac_cfg0 = 0;
+	netxen_gb_enable_tx(mac_cfg0);
+	netxen_gb_enable_rx(mac_cfg0);
+	netxen_gb_unset_rx_flowctl(mac_cfg0);
+	netxen_gb_tx_reset_pb(mac_cfg0);
+	netxen_gb_rx_reset_pb(mac_cfg0);
+	netxen_gb_tx_reset_mac(mac_cfg0);
+	netxen_gb_rx_reset_mac(mac_cfg0);
+
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				   &mac_cfg0, 4))
+		return -EIO;
+	mac_cfg1 = 0;
+	netxen_gb_set_preamblelen(mac_cfg1, 0xf);
+	netxen_gb_set_duplex(mac_cfg1);
+	netxen_gb_set_crc_enable(mac_cfg1);
+	netxen_gb_set_padshort(mac_cfg1);
+	netxen_gb_set_checklength(mac_cfg1);
+	netxen_gb_set_hugeframes(mac_cfg1);
+
+	if (mode == NETXEN_NIU_10_100_MB) {
+		netxen_gb_set_intfmode(mac_cfg1, 1);
+		if (netxen_nic_hw_write_wx(adapter,
+					   NETXEN_NIU_GB_MAC_CONFIG_1(port),
+					   &mac_cfg1, 4))
+			return -EIO;
+
+		/* set mii mode */
+		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_GMII_MODE +
+					    (port << 3), 0);
+		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_MII_MODE +
+					    (port << 3), 1);
+
+	} else if (mode == NETXEN_NIU_1000_MB) {
+		netxen_gb_set_intfmode(mac_cfg1, 2);
+		if (netxen_nic_hw_write_wx(adapter,
+					   NETXEN_NIU_GB_MAC_CONFIG_1(port),
+					   &mac_cfg1, 4))
+			return -EIO;
+		/* set gmii mode */
+		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_MII_MODE +
+					    (port << 3), 0);
+		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_GMII_MODE +
+					    (port << 3), 1);
+	}
+	mii_cfg = 0;
+	netxen_gb_set_mii_mgmt_clockselect(mii_cfg, 7);
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(port),
+				   &mii_cfg, 4))
+		return -EIO;
+	mac_cfg0 = 0;
+	netxen_gb_enable_tx(mac_cfg0);
+	netxen_gb_enable_rx(mac_cfg0);
+	netxen_gb_unset_rx_flowctl(mac_cfg0);
+	netxen_gb_unset_tx_flowctl(mac_cfg0);
+
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				   &mac_cfg0, 4))
+		return -EIO;
+	return 0;
+}
+
+/* Disable a GbE interface */
+long netxen_niu_disable_gbe_port(struct netxen_adapter *adapter, long port)
+{
+	netxen_niu_gb_mac_config_0_t mac_cfg0;
+
+	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
+		return -EINVAL;
+
+	mac_cfg0 = 0;
+	netxen_gb_soft_reset(mac_cfg0);
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				   &mac_cfg0, 4))
+		return -EIO;
+	return 0;
+}
+
+/* Disable an XG interface */
+long netxen_niu_disable_xg_port(struct netxen_adapter *adapter, long port)
+{
+	netxen_niu_xg_mac_config_0_t mac_cfg;
+
+	if (port != 0)
+		return -EINVAL;
+
+	mac_cfg = 0;
+	netxen_xg_soft_reset(mac_cfg);
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_CONFIG_0,
+				   &mac_cfg, 4))
+		return -EIO;
+	return 0;
+}
+
+/* Set promiscuous mode for a GbE interface */
+long netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter, long port,
+				     netxen_niu_prom_mode_t mode)
+{
+	netxen_niu_gb_drop_crc reg;
+
+	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
+		return -EINVAL;
+
+	/* save previous contents */
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR,
+				  &reg, 4))
+		return -EIO;
+	if (mode == NETXEN_NIU_PROMISCOUS_MODE) {
+		switch (port) {
+		case 0:
+			netxen_clear_gb_drop_gb0(reg);
+			break;
+		case 1:
+			netxen_clear_gb_drop_gb1(reg);
+			break;
+		case 2:
+			netxen_clear_gb_drop_gb2(reg);
+			break;
+		case 3:
+			netxen_clear_gb_drop_gb3(reg);
+			break;
+		default:
+			return -EIO;
+		}
+	} else {
+		switch (port) {
+		case 0:
+			netxen_set_gb_drop_gb0(reg);
+			break;
+		case 1:
+			netxen_set_gb_drop_gb1(reg);
+			break;
+		case 2:
+			netxen_set_gb_drop_gb2(reg);
+			break;
+		case 3:
+			netxen_set_gb_drop_gb3(reg);
+			break;
+		default:
+			return -EIO;
+		}
+	}
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR,
+				   &reg, 4))
+		return -EIO;
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
+		return -EINVAL;
+
+	memcpy(&temp, addr, 2);
+	temp = cpu_to_le32(temp);
+	temp <<= 16;
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
+				   &temp, 4))
+		return -EIO;
+
+	temp = 0;
+
+	memcpy(&temp, ((u8 *) addr) + 2, sizeof(netxen_crbword_t));
+	temp = cpu_to_le32(temp);
+	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
+				   &temp, 4))
+		return -EIO;
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
+		return -EINVAL;
+	if (phy != 0)
+		return -EINVAL;
+
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
+				  &stationhigh, 4))
+		return -EIO;
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
+				  &stationlow, 4))
+		return -EIO;
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
+	netxen_crbword_t reg;
+
+	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
+		return -EINVAL;
+
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_CONFIG_1, &reg, 4))
+		return -EIO;
+	if (mode == NETXEN_NIU_PROMISCOUS_MODE)
+		reg = (reg | 0x2000UL);
+	else
+		reg = (reg & ~0x2000UL);
+
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_XGE_CONFIG_1, reg);
+
+	return 0;
+}

