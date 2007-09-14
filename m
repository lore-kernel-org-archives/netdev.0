From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.24 1/3]S2io: Added support set_mac_address driver entry
 point
Date: Fri, 14 Sep 2007 07:39:19 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10709140733000.474-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:52972 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbXINLjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 07:39:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Added set_mac_address driver entry point
- Copying permanent mac address to dev->perm_addr
- Incorporated following review comments from Jeff
     - Converted the macro to a function and removed call to memset
     - regarding function naming convention, for all callbacks and entry points
       will have 's2io_' prefix and helper functions will have 'do_s2io_' prefix.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -urpN orig/drivers/net/s2io.c patch1/drivers/net/s2io.c
--- orig/drivers/net/s2io.c	2007-09-06 14:30:16.000000000 +0530
+++ patch1/drivers/net/s2io.c	2007-09-06 16:21:33.000000000 +0530
@@ -355,6 +355,16 @@ static char ethtool_driver_stats_keys[][
 			timer.data = (unsigned long) arg;	\
 			mod_timer(&timer, (jiffies + exp))	\
 
+/* copy mac addr to def_mac_addr array */
+static void do_s2io_copy_mac_addr(struct s2io_nic* sp, int offset, u64 mac_addr)
+{
+	sp->def_mac_addr[offset].mac_addr[5] = (u8) (mac_addr);	
+	sp->def_mac_addr[offset].mac_addr[4] = (u8) (mac_addr >> 8);
+	sp->def_mac_addr[offset].mac_addr[3] = (u8) (mac_addr >> 16);
+	sp->def_mac_addr[offset].mac_addr[2] = (u8) (mac_addr >> 24);
+	sp->def_mac_addr[offset].mac_addr[1] = (u8) (mac_addr >> 32);
+	sp->def_mac_addr[offset].mac_addr[0] = (u8) (mac_addr >> 40);
+}
 /* Add the vlan */
 static void s2io_vlan_rx_register(struct net_device *dev,
 					struct vlan_group *grp)
@@ -3420,7 +3430,7 @@ static void s2io_reset(struct s2io_nic *
 	}
 
 	/* restore the previously assigned mac address */
-	s2io_set_mac_addr(sp->dev, (u8 *)&sp->def_mac_addr[0].mac_addr);
+	do_s2io_prog_unicast(sp->dev, (u8 *)&sp->def_mac_addr[0].mac_addr);
 
 	sp->device_enabled_once = FALSE;
 }
@@ -3849,7 +3859,7 @@ static int s2io_open(struct net_device *
 		goto hw_init_failed;
 	}
 
-	if (s2io_set_mac_addr(dev, dev->dev_addr) == FAILURE) {
+	if (do_s2io_prog_unicast(dev, dev->dev_addr) == FAILURE) {
 		DBG_PRINT(ERR_DBG, "Set Mac Address Failed\n");
 		s2io_card_down(sp);
 		err = -ENODEV;
@@ -4847,8 +4857,48 @@ static void s2io_set_multicast(struct ne
 	}
 }
 
+/* add unicast MAC address to CAM */
+static int do_s2io_add_unicast(struct s2io_nic *sp, u64 addr, int off)
+{
+	u64 val64;
+	struct XENA_dev_config __iomem *bar0 = sp->bar0;
+
+	writeq(RMAC_ADDR_DATA0_MEM_ADDR(addr),
+		&bar0->rmac_addr_data0_mem);
+
+	val64 =
+		RMAC_ADDR_CMD_MEM_WE | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
+		RMAC_ADDR_CMD_MEM_OFFSET(off);
+	writeq(val64, &bar0->rmac_addr_cmd_mem);
+
+	/* Wait till command completes */
+	if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
+		RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
+		S2IO_BIT_RESET)) {
+		DBG_PRINT(INFO_DBG, "add_mac_addr failed\n");
+		return FAILURE;
+	}
+	return SUCCESS;
+}
+
+/**
+ * s2io_set_mac_addr driver entry point
+ */
+static int s2io_set_mac_addr(struct net_device *dev, void* p)
+{
+	struct sockaddr *addr=p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	memcpy(dev->dev_addr, addr->sa_data,dev->addr_len);
+
+	/* store the MAC address in CAM */
+	return (do_s2io_prog_unicast(dev, dev->dev_addr));
+}
+
 /**
- *  s2io_set_mac_addr - Programs the Xframe mac address
+ *  do_s2io_prog_unicast - Programs the Xframe mac address
  *  @dev : pointer to the device structure.
  *  @addr: a uchar pointer to the new mac address which is to be set.
  *  Description : This procedure will program the Xframe to receive
@@ -4856,56 +4906,31 @@ static void s2io_set_multicast(struct ne
  *  Return value: SUCCESS on success and an appropriate (-)ve integer
  *  as defined in errno.h file on failure.
  */
-
-static int s2io_set_mac_addr(struct net_device *dev, u8 * addr)
+static int do_s2io_prog_unicast(struct net_device *dev, u8 * addr)
 {
 	struct s2io_nic *sp = dev->priv;
-	struct XENA_dev_config __iomem *bar0 = sp->bar0;
-	register u64 val64, mac_addr = 0;
+	register u64 mac_addr = 0,perm_addr=0;
 	int i;
-	u64 old_mac_addr = 0;
 
 	/*
-	 * Set the new MAC address as the new unicast filter and reflect this
-	 * change on the device address registered with the OS. It will be
-	 * at offset 0.
-	 */
+	* Set the new MAC address as the new unicast filter and reflect this
+	* change on the device address registered with the OS. It will be
+	* at offset 0.
+	*/
 	for (i = 0; i < ETH_ALEN; i++) {
 		mac_addr <<= 8;
 		mac_addr |= addr[i];
-		old_mac_addr <<= 8;
-		old_mac_addr |= sp->def_mac_addr[0].mac_addr[i];
+		perm_addr <<= 8;
+		perm_addr |= sp->def_mac_addr[0].mac_addr[i];
 	}
 
-	if(0 == mac_addr)
+	/* check if the dev_addr is different than perm_addr */
+	if(mac_addr == perm_addr)
 		return SUCCESS;
 
 	/* Update the internal structure with this new mac address */
-	if(mac_addr != old_mac_addr) {
-		memset(sp->def_mac_addr[0].mac_addr, 0, sizeof(ETH_ALEN));
-		sp->def_mac_addr[0].mac_addr[5] = (u8) (mac_addr);
-		sp->def_mac_addr[0].mac_addr[4] = (u8) (mac_addr >> 8);
-		sp->def_mac_addr[0].mac_addr[3] = (u8) (mac_addr >> 16);
-		sp->def_mac_addr[0].mac_addr[2] = (u8) (mac_addr >> 24);
-		sp->def_mac_addr[0].mac_addr[1] = (u8) (mac_addr >> 32);
-		sp->def_mac_addr[0].mac_addr[0] = (u8) (mac_addr >> 40);
-	}
-
-	writeq(RMAC_ADDR_DATA0_MEM_ADDR(mac_addr),
-	       &bar0->rmac_addr_data0_mem);
-
-	val64 =
-	    RMAC_ADDR_CMD_MEM_WE | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
-	    RMAC_ADDR_CMD_MEM_OFFSET(0);
-	writeq(val64, &bar0->rmac_addr_cmd_mem);
-	/* Wait till command completes */
-	if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-		      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING, S2IO_BIT_RESET)) {
-		DBG_PRINT(ERR_DBG, "%s: set_mac_addr failed\n", dev->name);
-		return FAILURE;
-	}
-
-	return SUCCESS;
+	do_s2io_copy_mac_addr(sp, 0, mac_addr);
+	return (do_s2io_add_unicast(sp,mac_addr,0));
 }
 
 /**
@@ -7542,6 +7567,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	dev->get_stats = &s2io_get_stats;
 	dev->set_multicast_list = &s2io_set_multicast;
 	dev->do_ioctl = &s2io_ioctl;
+	dev->set_mac_address = &s2io_set_mac_addr;
 	dev->change_mtu = &s2io_change_mtu;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
@@ -7628,6 +7654,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	/*  Set the factory defined MAC address initially   */
 	dev->addr_len = ETH_ALEN;
 	memcpy(dev->dev_addr, sp->def_mac_addr, ETH_ALEN);
+	memcpy(dev->perm_addr, dev->dev_addr, ETH_ALEN);
 
 	 /* Store the values of the MSIX table in the s2io_nic structure */
 	store_xmsi_data(sp);
diff -urpN orig/drivers/net/s2io.h patch1/drivers/net/s2io.h
--- orig/drivers/net/s2io.h	2007-09-06 14:30:16.000000000 +0530
+++ patch1/drivers/net/s2io.h	2007-09-06 16:15:16.000000000 +0530
@@ -1046,7 +1046,7 @@ static void s2io_link(struct s2io_nic * 
 static void s2io_reset(struct s2io_nic * sp);
 static int s2io_poll(struct net_device *dev, int *budget);
 static void s2io_init_pci(struct s2io_nic * sp);
-static int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
+static int do_s2io_prog_unicast(struct net_device *dev, u8 * addr);
 static void s2io_alarm_handle(unsigned long data);
 static irqreturn_t
 s2io_msix_ring_handle(int irq, void *dev_id);

