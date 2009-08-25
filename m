From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 1/4] netxen: remove unused code
Date: Mon, 24 Aug 2009 22:23:25 -0700
Message-ID: <1251177808-16450-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:54411 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754477AbZHYFX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 01:23:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove code for phy access on unreleased NX2031 based quad-gig board.

NX3031 based production quad-gig boards do not require direct phy
access by driver.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   13 --
 drivers/net/netxen/netxen_nic_hw.h   |  107 ---------------
 drivers/net/netxen/netxen_nic_init.c |   43 ++-----
 drivers/net/netxen/netxen_nic_niu.c  |  240 ----------------------------------
 4 files changed, 12 insertions(+), 391 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 7a93f82..74ccef5 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1148,8 +1148,6 @@ struct netxen_adapter {
 	struct netxen_recv_context recv_ctx;
 	struct nx_host_tx_ring *tx_ring;
 
-	int (*enable_phy_interrupts) (struct netxen_adapter *);
-	int (*disable_phy_interrupts) (struct netxen_adapter *);
 	int (*macaddr_set) (struct netxen_adapter *, u8 *);
 	int (*set_mtu) (struct netxen_adapter *, int);
 	int (*set_promisc) (struct netxen_adapter *, u32);
@@ -1187,22 +1185,11 @@ struct netxen_adapter {
 	const struct firmware *fw;
 };
 
-/* Set promiscuous mode for a GbE interface */
-int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter, u32 mode);
 int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 		u32 mode);
-/* Generic enable for GbE ports. Will detect the speed of the link. */
-int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port);
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port);
-
-/* Disable a GbE interface */
-int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter);
 int netxen_niu_disable_xg_port(struct netxen_adapter *adapter);
 
-int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter);
-int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter);
-int netxen_niu_xgbe_disable_phy_interrupts(struct netxen_adapter *adapter);
-int netxen_niu_gbe_disable_phy_interrupts(struct netxen_adapter *adapter);
 int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 			    __u32 * readval);
 int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index fc0638f..98e4b95 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -61,10 +61,6 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter);
  *	Bit 31: soft_reset => 1:reset the MAC and the SERDES, 0:no-op
  */
 
-#define netxen_gb_enable_tx(config_word)	\
-	((config_word) |= 1 << 0)
-#define netxen_gb_enable_rx(config_word)	\
-	((config_word) |= 1 << 2)
 #define netxen_gb_tx_flowctl(config_word)	\
 	((config_word) |= 1 << 4)
 #define netxen_gb_rx_flowctl(config_word)	\
@@ -77,8 +73,6 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter);
 	((config_word) |= 1 << 18)
 #define netxen_gb_rx_reset_mac(config_word)	\
 	((config_word) |= 1 << 19)
-#define netxen_gb_soft_reset(config_word)	\
-	((config_word) |= 1 << 31)
 
 #define netxen_gb_unset_tx_flowctl(config_word)	\
 	((config_word) &= ~(1 << 4))
@@ -240,7 +234,6 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter);
  * Bits 14-15 : speed => 0:10Mb/s, 1:100Mb/s, 2:1000Mb/s, 3:rsvd
  */
 
-#define netxen_get_phy_cablelen(config_word) (((config_word) >> 7) & 0x07)
 #define netxen_get_phy_speed(config_word) (((config_word) >> 14) & 0x03)
 
 #define netxen_set_phy_speed(config_word, val)	\
@@ -250,85 +243,12 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter);
 #define netxen_clear_phy_duplex(config_word)	\
 		((config_word) &= ~(1 << 13))
 
-#define netxen_get_phy_jabber(config_word)	\
-		_netxen_crb_get_bit(config_word, 0)
-#define netxen_get_phy_polarity(config_word)	\
-		_netxen_crb_get_bit(config_word, 1)
-#define netxen_get_phy_recvpause(config_word)	\
-		_netxen_crb_get_bit(config_word, 2)
-#define netxen_get_phy_xmitpause(config_word)	\
-		_netxen_crb_get_bit(config_word, 3)
-#define netxen_get_phy_energydetect(config_word) \
-		_netxen_crb_get_bit(config_word, 4)
-#define netxen_get_phy_downshift(config_word)	\
-		_netxen_crb_get_bit(config_word, 5)
-#define netxen_get_phy_crossover(config_word)	\
-		_netxen_crb_get_bit(config_word, 6)
 #define netxen_get_phy_link(config_word)	\
 		_netxen_crb_get_bit(config_word, 10)
-#define netxen_get_phy_resolved(config_word)	\
-		_netxen_crb_get_bit(config_word, 11)
-#define netxen_get_phy_pagercvd(config_word)	\
-		_netxen_crb_get_bit(config_word, 12)
 #define netxen_get_phy_duplex(config_word)	\
 		_netxen_crb_get_bit(config_word, 13)
 
 /*
- * Interrupt Register definition
- * This definition applies to registers 18 and 19 (int enable and int status).
- * Bit 0 : jabber
- * Bit 1 : polarity_changed
- * Bit 4 : energy_detect
- * Bit 5 : downshift
- * Bit 6 : mdi_xover_changed
- * Bit 7 : fifo_over_underflow
- * Bit 8 : false_carrier
- * Bit 9 : symbol_error
- * Bit 10: link_status_changed
- * Bit 11: autoneg_completed
- * Bit 12: page_received
- * Bit 13: duplex_changed
- * Bit 14: speed_changed
- * Bit 15: autoneg_error
- */
-
-#define netxen_get_phy_int_jabber(config_word)	\
-		_netxen_crb_get_bit(config_word, 0)
-#define netxen_get_phy_int_polarity_changed(config_word)	\
-		_netxen_crb_get_bit(config_word, 1)
-#define netxen_get_phy_int_energy_detect(config_word)	\
-		_netxen_crb_get_bit(config_word, 4)
-#define netxen_get_phy_int_downshift(config_word)	\
-		_netxen_crb_get_bit(config_word, 5)
-#define netxen_get_phy_int_mdi_xover_changed(config_word)	\
-		_netxen_crb_get_bit(config_word, 6)
-#define netxen_get_phy_int_fifo_over_underflow(config_word)	\
-		_netxen_crb_get_bit(config_word, 7)
-#define netxen_get_phy_int_false_carrier(config_word)	\
-		_netxen_crb_get_bit(config_word, 8)
-#define netxen_get_phy_int_symbol_error(config_word)	\
-		_netxen_crb_get_bit(config_word, 9)
-#define netxen_get_phy_int_link_status_changed(config_word)	\
-		_netxen_crb_get_bit(config_word, 10)
-#define netxen_get_phy_int_autoneg_completed(config_word)	\
-		_netxen_crb_get_bit(config_word, 11)
-#define netxen_get_phy_int_page_received(config_word)	\
-		_netxen_crb_get_bit(config_word, 12)
-#define netxen_get_phy_int_duplex_changed(config_word)	\
-		_netxen_crb_get_bit(config_word, 13)
-#define netxen_get_phy_int_speed_changed(config_word)	\
-		_netxen_crb_get_bit(config_word, 14)
-#define netxen_get_phy_int_autoneg_error(config_word)	\
-		_netxen_crb_get_bit(config_word, 15)
-
-#define netxen_set_phy_int_link_status_changed(config_word)	\
-		((config_word) |= 1 << 10)
-#define netxen_set_phy_int_autoneg_completed(config_word)	\
-		((config_word) |= 1 << 11)
-#define netxen_set_phy_int_speed_changed(config_word)	\
-		((config_word) |= 1 << 14)
-
-/*
  * NIU Mode Register.
  * Bit 0 : enable FibreChannel
  * Bit 1 : enable 10/100/1000 Ethernet
@@ -343,33 +263,6 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter);
 #define NETXEN_NIU_ALLMULTI_MODE	2
 
 /*
- * NIU GB Drop CRC Register
- *
- * Bit 0 : drop_gb0 => 1:drop pkts with bad CRCs, 0:pass them on
- * Bit 1 : drop_gb1 => 1:drop pkts with bad CRCs, 0:pass them on
- * Bit 2 : drop_gb2 => 1:drop pkts with bad CRCs, 0:pass them on
- * Bit 3 : drop_gb3 => 1:drop pkts with bad CRCs, 0:pass them on
- */
-
-#define netxen_set_gb_drop_gb0(config_word)	\
-		((config_word) |= 1 << 0)
-#define netxen_set_gb_drop_gb1(config_word)	\
-		((config_word) |= 1 << 1)
-#define netxen_set_gb_drop_gb2(config_word)	\
-		((config_word) |= 1 << 2)
-#define netxen_set_gb_drop_gb3(config_word)	\
-		((config_word) |= 1 << 3)
-
-#define netxen_clear_gb_drop_gb0(config_word)	\
-		((config_word) &= ~(1 << 0))
-#define netxen_clear_gb_drop_gb1(config_word)	\
-		((config_word) &= ~(1 << 1))
-#define netxen_clear_gb_drop_gb2(config_word)	\
-		((config_word) &= ~(1 << 2))
-#define netxen_clear_gb_drop_gb3(config_word)	\
-		((config_word) &= ~(1 << 3))
-
-/*
  * NIU XG MAC Config Register
  *
  * Bit 0 : tx_enable => 1:enable frame xmit, 0:disable
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 474c568..f5807da 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -321,44 +321,25 @@ err_out:
 
 void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 {
-	adapter->macaddr_set = netxen_p2_nic_set_mac_addr;
-	adapter->set_multi = netxen_p2_nic_set_multi;
-
-	switch (adapter->ahw.port_type) {
-	case NETXEN_NIC_GBE:
-		adapter->enable_phy_interrupts =
-		    netxen_niu_gbe_enable_phy_interrupts;
-		adapter->disable_phy_interrupts =
-		    netxen_niu_gbe_disable_phy_interrupts;
-		adapter->set_mtu = netxen_nic_set_mtu_gb;
-		adapter->set_promisc = netxen_niu_set_promiscuous_mode;
-		adapter->phy_read = netxen_niu_gbe_phy_read;
-		adapter->phy_write = netxen_niu_gbe_phy_write;
-		adapter->init_port = netxen_niu_gbe_init_port;
-		adapter->stop_port = netxen_niu_disable_gbe_port;
-		break;
+	adapter->init_port = netxen_niu_xg_init_port;
+	adapter->stop_port = netxen_niu_disable_xg_port;
 
-	case NETXEN_NIC_XGBE:
-		adapter->enable_phy_interrupts =
-		    netxen_niu_xgbe_enable_phy_interrupts;
-		adapter->disable_phy_interrupts =
-		    netxen_niu_xgbe_disable_phy_interrupts;
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+		adapter->macaddr_set = netxen_p2_nic_set_mac_addr;
+		adapter->set_multi = netxen_p2_nic_set_multi;
 		adapter->set_mtu = netxen_nic_set_mtu_xgb;
-		adapter->init_port = netxen_niu_xg_init_port;
 		adapter->set_promisc = netxen_niu_xg_set_promiscuous_mode;
-		adapter->stop_port = netxen_niu_disable_xg_port;
-		break;
-
-	default:
-		break;
-	}
-
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+	} else {
 		adapter->set_mtu = nx_fw_cmd_set_mtu;
 		adapter->set_promisc = netxen_p3_nic_set_promisc;
 		adapter->macaddr_set = netxen_p3_nic_set_mac_addr;
 		adapter->set_multi = netxen_p3_nic_set_multi;
 	}
+
+	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
+		adapter->phy_read = netxen_niu_gbe_phy_read;
+		adapter->phy_write = netxen_niu_gbe_phy_write;
+	}
 }
 
 /*
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 5941c79..8b7cd9e 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -30,11 +30,6 @@
 
 #include "netxen_nic.h"
 
-#define NETXEN_GB_MAC_SOFT_RESET	0x80000000
-#define NETXEN_GB_MAC_RESET_PROT_BLK   0x000F0000
-#define NETXEN_GB_MAC_ENABLE_TX_RX     0x00000005
-#define NETXEN_GB_MAC_PAUSED_FRMS      0x00000020
-
 static long phy_lock_timeout = 100000000;
 
 static int phy_lock(struct netxen_adapter *adapter)
@@ -227,171 +222,6 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 	return result;
 }
 
-int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter)
-{
-	NXWR32(adapter, NETXEN_NIU_INT_MASK, 0x3f);
-	return 0;
-}
-
-int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter)
-{
-	int result = 0;
-	__u32 enable = 0;
-	netxen_set_phy_int_link_status_changed(enable);
-	netxen_set_phy_int_autoneg_completed(enable);
-	netxen_set_phy_int_speed_changed(enable);
-
-	if (0 !=
-	    netxen_niu_gbe_phy_write(adapter,
-				     NETXEN_NIU_GB_MII_MGMT_ADDR_INT_ENABLE,
-				     enable))
-		result = -EIO;
-
-	return result;
-}
-
-int netxen_niu_xgbe_disable_phy_interrupts(struct netxen_adapter *adapter)
-{
-	NXWR32(adapter, NETXEN_NIU_INT_MASK, 0x7f);
-	return 0;
-}
-
-int netxen_niu_gbe_disable_phy_interrupts(struct netxen_adapter *adapter)
-{
-	int result = 0;
-	if (0 !=
-	    netxen_niu_gbe_phy_write(adapter,
-				     NETXEN_NIU_GB_MII_MGMT_ADDR_INT_ENABLE, 0))
-		result = -EIO;
-
-	return result;
-}
-
-static int netxen_niu_gbe_clear_phy_interrupts(struct netxen_adapter *adapter)
-{
-	int result = 0;
-	if (0 !=
-	    netxen_niu_gbe_phy_write(adapter,
-				     NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
-				     -EIO))
-		result = -EIO;
-
-	return result;
-}
-
-/*
- * netxen_niu_gbe_set_mii_mode- Set 10/100 Mbit Mode for GbE MAC
- *
- */
-static void netxen_niu_gbe_set_mii_mode(struct netxen_adapter *adapter,
-					int port, long enable)
-{
-	NXWR32(adapter, NETXEN_NIU_MODE, 0x2);
-	NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), 0x80000000);
-	NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), 0x0000f0025);
-	NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_1(port), 0xf1ff);
-	NXWR32(adapter, NETXEN_NIU_GB0_GMII_MODE + (port << 3), 0);
-	NXWR32(adapter, NETXEN_NIU_GB0_MII_MODE + (port << 3), 1);
-	NXWR32(adapter, (NETXEN_NIU_GB0_HALF_DUPLEX + port * 4), 0);
-	NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(port), 0x7);
-
-	if (enable) {
-		/*
-		 * Do NOT enable flow control until a suitable solution for
-		 *  shutting down pause frames is found.
-		 */
-		NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), 0x5);
-	}
-
-	if (netxen_niu_gbe_enable_phy_interrupts(adapter))
-		printk(KERN_ERR "ERROR enabling PHY interrupts\n");
-	if (netxen_niu_gbe_clear_phy_interrupts(adapter))
-		printk(KERN_ERR "ERROR clearing PHY interrupts\n");
-}
-
-/*
- * netxen_niu_gbe_set_gmii_mode- Set GbE Mode for GbE MAC
- */
-static void netxen_niu_gbe_set_gmii_mode(struct netxen_adapter *adapter,
-					 int port, long enable)
-{
-	NXWR32(adapter, NETXEN_NIU_MODE, 0x2);
-	NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), 0x80000000);
-	NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), 0x0000f0025);
-	NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_1(port), 0xf2ff);
-	NXWR32(adapter, NETXEN_NIU_GB0_MII_MODE + (port << 3), 0);
-	NXWR32(adapter, NETXEN_NIU_GB0_GMII_MODE + (port << 3), 1);
-	NXWR32(adapter, (NETXEN_NIU_GB0_HALF_DUPLEX + port * 4), 0);
-	NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(port), 0x7);
-
-	if (enable) {
-		/*
-		 * Do NOT enable flow control until a suitable solution for
-		 *  shutting down pause frames is found.
-		 */
-		NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), 0x5);
-	}
-
-	if (netxen_niu_gbe_enable_phy_interrupts(adapter))
-		printk(KERN_ERR "ERROR enabling PHY interrupts\n");
-	if (netxen_niu_gbe_clear_phy_interrupts(adapter))
-		printk(KERN_ERR "ERROR clearing PHY interrupts\n");
-}
-
-int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port)
-{
-	int result = 0;
-	__u32 status;
-
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		return 0;
-
-	if (adapter->disable_phy_interrupts)
-		adapter->disable_phy_interrupts(adapter);
-	mdelay(2);
-
-	if (0 == netxen_niu_gbe_phy_read(adapter,
-			NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS, &status)) {
-		if (netxen_get_phy_link(status)) {
-			if (netxen_get_phy_speed(status) == 2) {
-				netxen_niu_gbe_set_gmii_mode(adapter, port, 1);
-			} else if ((netxen_get_phy_speed(status) == 1)
-				   || (netxen_get_phy_speed(status) == 0)) {
-				netxen_niu_gbe_set_mii_mode(adapter, port, 1);
-			} else {
-				result = -1;
-			}
-
-		} else {
-			/*
-			 * We don't have link. Cable  must be unconnected.
-			 * Enable phy interrupts so we take action when
-			 * plugged in.
-			 */
-
-			NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
-						    NETXEN_GB_MAC_SOFT_RESET);
-			NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
-					    NETXEN_GB_MAC_RESET_PROT_BLK |
-					    NETXEN_GB_MAC_ENABLE_TX_RX |
-					    NETXEN_GB_MAC_PAUSED_FRMS);
-			if (netxen_niu_gbe_clear_phy_interrupts(adapter))
-				printk(KERN_ERR
-				       "ERROR clearing PHY interrupts\n");
-			if (netxen_niu_gbe_enable_phy_interrupts(adapter))
-				printk(KERN_ERR
-				       "ERROR enabling PHY interrupts\n");
-			if (netxen_niu_gbe_clear_phy_interrupts(adapter))
-				printk(KERN_ERR
-				       "ERROR clearing PHY interrupts\n");
-			result = -1;
-		}
-	} else {
-		result = -EIO;
-	}
-	return result;
-}
-
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 {
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
@@ -402,24 +232,6 @@ int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 	return 0;
 }
 
-/* Disable a GbE interface */
-int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter)
-{
-	__u32 mac_cfg0;
-	u32 port = adapter->physical_port;
-
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		return 0;
-
-	if (port > NETXEN_NIU_MAX_GBE_PORTS)
-		return -EINVAL;
-	mac_cfg0 = 0;
-	netxen_gb_soft_reset(mac_cfg0);
-	if (NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), mac_cfg0))
-		return -EIO;
-	return 0;
-}
-
 /* Disable an XG interface */
 int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
 {
@@ -439,58 +251,6 @@ int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
 	return 0;
 }
 
-/* Set promiscuous mode for a GbE interface */
-int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
-		u32 mode)
-{
-	__u32 reg;
-	u32 port = adapter->physical_port;
-
-	if (port > NETXEN_NIU_MAX_GBE_PORTS)
-		return -EINVAL;
-
-	/* save previous contents */
-	reg = NXRD32(adapter, NETXEN_NIU_GB_DROP_WRONGADDR);
-	if (mode == NETXEN_NIU_PROMISC_MODE) {
-		switch (port) {
-		case 0:
-			netxen_clear_gb_drop_gb0(reg);
-			break;
-		case 1:
-			netxen_clear_gb_drop_gb1(reg);
-			break;
-		case 2:
-			netxen_clear_gb_drop_gb2(reg);
-			break;
-		case 3:
-			netxen_clear_gb_drop_gb3(reg);
-			break;
-		default:
-			return -EIO;
-		}
-	} else {
-		switch (port) {
-		case 0:
-			netxen_set_gb_drop_gb0(reg);
-			break;
-		case 1:
-			netxen_set_gb_drop_gb1(reg);
-			break;
-		case 2:
-			netxen_set_gb_drop_gb2(reg);
-			break;
-		case 3:
-			netxen_set_gb_drop_gb3(reg);
-			break;
-		default:
-			return -EIO;
-		}
-	}
-	if (NXWR32(adapter, NETXEN_NIU_GB_DROP_WRONGADDR, reg))
-		return -EIO;
-	return 0;
-}
-
 int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 		u32 mode)
 {
-- 
1.6.0.2

