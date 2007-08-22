From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.24 1/3]S2io: Added support for set_mac_address driver
 entry point
Date: Wed, 22 Aug 2007 03:45:33 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10708220341560.29101-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:46762 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756223AbXHVHph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 03:45:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Added set_mac_address driver entry point
- Copying permanent mac address to dev->perm_addr
 
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN orig/drivers/net/s2io.c patch1/drivers/net/s2io.c
--- orig/drivers/net/s2io.c	2007-08-17 02:38:17.000000000 +0530
+++ patch1/drivers/net/s2io.c	2007-08-18 05:32:23.000000000 +0530
@@ -350,6 +350,15 @@ static char ethtool_driver_stats_keys[][
 			timer.data = (unsigned long) arg;	\
 			mod_timer(&timer, (jiffies + exp))	\
 
+#define	MAC_ADDR_SET(offset,mac_addr) 				\
+	memset(sp->def_mac_addr[offset].mac_addr, 0, sizeof(ETH_ALEN));\
+	sp->def_mac_addr[offset].mac_addr[5] = (u8) (mac_addr);	\
+	sp->def_mac_addr[offset].mac_addr[4] = (u8) (mac_addr >> 8);\
+	sp->def_mac_addr[offset].mac_addr[3] = (u8) (mac_addr >> 16);\
+	sp->def_mac_addr[offset].mac_addr[2] = (u8) (mac_addr >> 24);\
+	sp->def_mac_addr[offset].mac_addr[1] = (u8) (mac_addr >> 32);\
+	sp->def_mac_addr[offset].mac_addr[0] = (u8) (mac_addr >> 40);\
+
 /* Add the vlan */
 static void s2io_vlan_rx_register(struct net_device *dev,
 					struct vlan_group *grp)
@@ -3639,7 +3648,7 @@ static void s2io_reset(struct s2io_nic *
 	}
 
 	/* restore the previously assigned mac address */
-	s2io_set_mac_addr(sp->dev, (u8 *)&sp->def_mac_addr[0].mac_addr);
+	set_mac_addr(sp->dev, (u8 *)&sp->def_mac_addr[0].mac_addr);
 
 	sp->device_enabled_once = FALSE;
 }
@@ -4067,7 +4076,7 @@ static int s2io_open(struct net_device *
 		goto hw_init_failed;
 	}
 
-	if (s2io_set_mac_addr(dev, dev->dev_addr) == FAILURE) {
+	if (set_mac_addr(dev, dev->dev_addr) == FAILURE) {
 		DBG_PRINT(ERR_DBG, "Set Mac Address Failed\n");
 		s2io_card_down(sp);
 		err = -ENODEV;
@@ -5025,6 +5034,7 @@ static void s2io_set_multicast(struct ne
 	    0xfeffffffffffULL;
 	u64 dis_addr = 0xffffffffffffULL, mac_addr = 0;
 	void __iomem *add;
+	struct config_param *config = &sp->config;
 
 	if ((dev->flags & IFF_ALLMULTI) && (!sp->m_cast_flg)) {
 		/*  Enable all Multicast addresses */
@@ -5179,8 +5189,48 @@ static void s2io_set_multicast(struct ne
 	}
 }
 
+/* add MAC address to CAM */
+static int add_mac_addr(struct s2io_nic *sp, u64 addr, int off)
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
+	return (set_mac_addr(dev, dev->dev_addr));
+}
+
 /**
- *  s2io_set_mac_addr - Programs the Xframe mac address
+ *  set_mac_addr - Programs the Xframe mac address
  *  @dev : pointer to the device structure.
  *  @addr: a uchar pointer to the new mac address which is to be set.
  *  Description : This procedure will program the Xframe to receive
@@ -5188,56 +5238,31 @@ static void s2io_set_multicast(struct ne
  *  Return value: SUCCESS on success and an appropriate (-)ve integer
  *  as defined in errno.h file on failure.
  */
-
-static int s2io_set_mac_addr(struct net_device *dev, u8 * addr)
+static int set_mac_addr(struct net_device *dev, u8 * addr)
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
+	MAC_ADDR_SET(0, mac_addr);
+	return (add_mac_addr(sp,mac_addr,0));
 }
 
 /**
@@ -7897,6 +7922,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	dev->get_stats = &s2io_get_stats;
 	dev->set_multicast_list = &s2io_set_multicast;
 	dev->do_ioctl = &s2io_ioctl;
+	dev->set_mac_address = &s2io_set_mac_addr;
 	dev->change_mtu = &s2io_change_mtu;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
@@ -7983,6 +8009,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	/*  Set the factory defined MAC address initially   */
 	dev->addr_len = ETH_ALEN;
 	memcpy(dev->dev_addr, sp->def_mac_addr, ETH_ALEN);
+	memcpy(dev->perm_addr, dev->dev_addr, ETH_ALEN);
 
 	 /* Store the values of the MSIX table in the s2io_nic structure */
 	store_xmsi_data(sp);
diff -urpN orig/drivers/net/s2io.h patch1/drivers/net/s2io.h
--- orig/drivers/net/s2io.h	2007-08-17 02:38:17.000000000 +0530
+++ patch1/drivers/net/s2io.h	2007-08-18 04:52:10.000000000 +0530
@@ -1044,7 +1044,7 @@ static void s2io_link(struct s2io_nic * 
 static void s2io_reset(struct s2io_nic * sp);
 static int s2io_poll(struct net_device *dev, int *budget);
 static void s2io_init_pci(struct s2io_nic * sp);
-static int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
+static int set_mac_addr(struct net_device *dev, u8 * addr);
 static void s2io_alarm_handle(unsigned long data);
 static irqreturn_t
 s2io_msix_ring_handle(int irq, void *dev_id);

