From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.24 2/3]S2io: Support for add/delete/store/restore ethernet
 addresses
Date: Fri, 14 Sep 2007 07:41:41 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10709140739230.474-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:53012 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154AbXINLln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 07:41:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Support to add/delete/store/restore 64 and 128 Ethernet addresses for Xframe I and Xframe II respectively.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -Nurp 2.0.26.5-1/drivers/net/s2io.c 2.0.26.5-2/drivers/net/s2io.c
--- 2.0.26.5-1/drivers/net/s2io.c	2007-09-06 14:42:24.000000000 -0700
+++ 2.0.26.5-2/drivers/net/s2io.c	2007-09-06 15:45:10.000000000 -0700
@@ -356,7 +356,7 @@ static char ethtool_driver_stats_keys[][
 			mod_timer(&timer, (jiffies + exp))	\
 
 /* copy mac addr to def_mac_addr array */
-static void do_s2io_copy_mac_addr(struct s2io_nic* sp, int offset, u64 mac_addr)
+static void do_s2io_copy_mac_addr(struct s2io_nic *sp, int offset, u64 mac_addr)
 {
 	sp->def_mac_addr[offset].mac_addr[5] = (u8) (mac_addr);	
 	sp->def_mac_addr[offset].mac_addr[4] = (u8) (mac_addr >> 8);
@@ -3371,6 +3371,9 @@ static void s2io_reset(struct s2io_nic *
 	/* Set swapper to enable I/O register access */
 	s2io_set_swapper(sp);
 
+	/* restore mac address entries */
+	do_s2io_restore_unicast_mc(sp);
+
 	/* Restore the MSIX table entries from local variables */
 	restore_xmsi_data(sp);
 
@@ -3429,9 +3432,6 @@ static void s2io_reset(struct s2io_nic *
 		writeq(val64, &bar0->pcc_err_reg);
 	}
 
-	/* restore the previously assigned mac address */
-	do_s2io_prog_unicast(sp->dev, (u8 *)&sp->def_mac_addr[0].mac_addr);
-
 	sp->device_enabled_once = FALSE;
 }
 
@@ -3901,8 +3901,17 @@ hw_init_failed:
 static int s2io_close(struct net_device *dev)
 {
 	struct s2io_nic *sp = dev->priv;
+	struct config_param *config = &sp->config;
+	u64 tmp64;
+	int off;
 
 	netif_stop_queue(dev);
+	/* delete all populated mac entries */
+	for(off =1; off < config->max_mc_addr; off++) {
+		tmp64 = do_s2io_read_unicast_mc(sp,off);
+		if(tmp64 != S2IO_DISABLE_MAC_ENTRY)
+			do_s2io_delete_unicast_mc(sp, tmp64);
+	}
 	/* Reset card, kill tasklet and free Tx and Rx buffers. */
 	s2io_card_down(sp);
 
@@ -4701,8 +4710,9 @@ static void s2io_set_multicast(struct ne
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u64 val64 = 0, multi_mac = 0x010203040506ULL, mask =
 	    0xfeffffffffffULL;
-	u64 dis_addr = 0xffffffffffffULL, mac_addr = 0;
+	u64 dis_addr = S2IO_DISABLE_MAC_ENTRY, mac_addr = 0;
 	void __iomem *add;
+	struct config_param *config = &sp->config;
 
 	if ((dev->flags & IFF_ALLMULTI) && (!sp->m_cast_flg)) {
 		/*  Enable all Multicast addresses */
@@ -4712,7 +4722,7 @@ static void s2io_set_multicast(struct ne
 		       &bar0->rmac_addr_data1_mem);
 		val64 = RMAC_ADDR_CMD_MEM_WE |
 		    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
-		    RMAC_ADDR_CMD_MEM_OFFSET(MAC_MC_ALL_MC_ADDR_OFFSET);
+		    RMAC_ADDR_CMD_MEM_OFFSET(config->max_mc_addr - 1);
 		writeq(val64, &bar0->rmac_addr_cmd_mem);
 		/* Wait till command completes */
 		wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
@@ -4720,7 +4730,7 @@ static void s2io_set_multicast(struct ne
 					S2IO_BIT_RESET);
 
 		sp->m_cast_flg = 1;
-		sp->all_multi_pos = MAC_MC_ALL_MC_ADDR_OFFSET;
+		sp->all_multi_pos = config->max_mc_addr - 1;
 	} else if ((dev->flags & IFF_ALLMULTI) && (sp->m_cast_flg)) {
 		/*  Disable all Multicast addresses */
 		writeq(RMAC_ADDR_DATA0_MEM_ADDR(dis_addr),
@@ -4789,7 +4799,8 @@ static void s2io_set_multicast(struct ne
 	/*  Update individual M_CAST address list */
 	if ((!sp->m_cast_flg) && dev->mc_count) {
 		if (dev->mc_count >
-		    (MAX_ADDRS_SUPPORTED - MAC_MC_ADDR_START_OFFSET - 1)) {
+		    ((config->max_mc_addr - config->max_mac_addr) 
+				- config->mc_start_offset  - 1)) {
 			DBG_PRINT(ERR_DBG, "%s: No more Rx filters ",
 				  dev->name);
 			DBG_PRINT(ERR_DBG, "can be added, please enable ");
@@ -4809,7 +4820,7 @@ static void s2io_set_multicast(struct ne
 			val64 = RMAC_ADDR_CMD_MEM_WE |
 			    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
 			    RMAC_ADDR_CMD_MEM_OFFSET
-			    (MAC_MC_ADDR_START_OFFSET + i);
+			    (config->mc_start_offset + i);
 			writeq(val64, &bar0->rmac_addr_cmd_mem);
 
 			/* Wait for command completes */
@@ -4841,7 +4852,7 @@ static void s2io_set_multicast(struct ne
 			val64 = RMAC_ADDR_CMD_MEM_WE |
 			    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
 			    RMAC_ADDR_CMD_MEM_OFFSET
-			    (i + MAC_MC_ADDR_START_OFFSET);
+			    (i + config->mc_start_offset);
 			writeq(val64, &bar0->rmac_addr_cmd_mem);
 
 			/* Wait for command completes */
@@ -4857,8 +4868,76 @@ static void s2io_set_multicast(struct ne
 	}
 }
 
-/* add unicast MAC address to CAM */
-static int do_s2io_add_unicast(struct s2io_nic *sp, u64 addr, int off)
+/* read from CAM unicast & multicast addresses and store it in def_mac_addr structure
+ **/
+void do_s2io_store_unicast_mc(struct s2io_nic *sp)
+{
+	int offset;
+	u64 mac_addr=0x0;
+	struct config_param *config = &sp->config;
+
+	/* store unicast & multicast mac addresses */
+	for(offset = 0; offset < config->max_mc_addr; offset++) {
+		mac_addr = do_s2io_read_unicast_mc(sp,offset);
+		/* if read fails disable the entry */
+		if(mac_addr == FAILURE)
+			mac_addr = S2IO_DISABLE_MAC_ENTRY;
+			do_s2io_copy_mac_addr(sp, offset, mac_addr);
+		}
+}
+
+/* restore unicast addresses & multicast to CAM from def_mac_addr structure */
+static void do_s2io_restore_unicast_mc(struct s2io_nic *sp)
+{
+	int offset;
+	struct config_param *config = &sp->config;
+
+	/* restore unicast mac address */
+	for(offset = 0; offset < config->max_mac_addr; offset++)
+		do_s2io_prog_unicast(sp->dev,sp->def_mac_addr[offset].mac_addr);
+
+	/* restore multicast mac address */
+	for(offset = config->mc_start_offset;
+		offset < config->max_mc_addr; offset++)
+	do_s2io_add_mc(sp, sp->def_mac_addr[offset].mac_addr);
+}
+
+/* add a multicast MAC address to CAM */ 
+static int do_s2io_add_mc(struct s2io_nic *sp, u8* addr)
+{
+	int i;
+	u64 mac_addr=0;
+	struct config_param *config = &sp->config;
+
+	for (i = 0; i < ETH_ALEN; i++) {
+		mac_addr <<= 8;
+		mac_addr |= addr[i];
+	}
+	if((0ULL == mac_addr) || (mac_addr == S2IO_DISABLE_MAC_ENTRY))
+		return SUCCESS;
+
+	/* check if the multicast mac already preset in CAM */
+	for(i = config->mc_start_offset; i < config->max_mc_addr; i++) {
+		u64 tmp64;
+		tmp64 = do_s2io_read_unicast_mc(sp,i);
+		if(tmp64 == S2IO_DISABLE_MAC_ENTRY) /* CAM entry is empty */
+		break;
+
+		if(tmp64 == mac_addr)
+			return SUCCESS;
+	}
+	if(i == config->max_mc_addr) {
+		DBG_PRINT(ERR_DBG,"CAM full no space left for multicast MAC\n");
+		return FAILURE;
+	}
+	/* Update the internal structure with this new mac address */
+	do_s2io_copy_mac_addr(sp, i, mac_addr);
+
+	return (do_s2io_add_mac(sp,mac_addr,i));
+}
+
+/* add MAC address to CAM memory */
+static int do_s2io_add_mac(struct s2io_nic *sp, u64 addr, int off)
 {
 	u64 val64;
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
@@ -4881,6 +4960,53 @@ static int do_s2io_add_unicast(struct s2
 	return SUCCESS;
 }
 
+/* deletes a specified unicast/multicast mac entry from CAM */
+static int do_s2io_delete_unicast_mc(struct s2io_nic *sp, u64 addr)
+{
+	int off;
+	u64 dis_addr = S2IO_DISABLE_MAC_ENTRY,tmp64;
+	struct config_param *config = &sp->config;
+
+	for(off = 1;
+		off < config->max_mc_addr; off++) {
+		tmp64 = do_s2io_read_unicast_mc(sp,off);
+		if(tmp64 == addr) {
+			/* disable the entry by writing  0xffffffffffffULL */
+			if(do_s2io_add_mac(sp,dis_addr,off) ==  FAILURE)
+				return FAILURE;
+			/* store the new mac list from CAM */
+			do_s2io_store_unicast_mc(sp);
+			return SUCCESS;
+		}
+	}
+	DBG_PRINT(ERR_DBG,"MAC address 0x%llx not found in CAM\n",
+            (unsigned long long)addr);
+	return FAILURE;
+}
+
+/* read mac entries from CAM */
+static u64 do_s2io_read_unicast_mc(struct s2io_nic *sp, int offset)
+{
+	u64 tmp64=0xffffffffffff0000ULL, val64;
+	struct XENA_dev_config __iomem *bar0 = sp->bar0;
+
+	/* read mac addr */
+	val64 =
+		RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
+		RMAC_ADDR_CMD_MEM_OFFSET(offset);
+	writeq(val64, &bar0->rmac_addr_cmd_mem);
+
+	/* Wait till command completes */
+	if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
+		RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
+		S2IO_BIT_RESET)) {
+		DBG_PRINT(INFO_DBG, "do_s2io_read_unicast_mc failed\n");
+		return FAILURE;
+	}
+	tmp64 = readq(&bar0->rmac_addr_data0_mem);
+	return (tmp64 >> 16);
+}
+
 /**
  * s2io_set_mac_addr driver entry point
  */
@@ -4911,6 +5037,8 @@ static int do_s2io_prog_unicast(struct n
 	struct s2io_nic *sp = dev->priv;
 	register u64 mac_addr = 0,perm_addr=0;
 	int i;
+	u64 tmp64;
+	struct config_param *config = &sp->config;
 
 	/*
 	* Set the new MAC address as the new unicast filter and reflect this
@@ -4928,9 +5056,27 @@ static int do_s2io_prog_unicast(struct n
 	if(mac_addr == perm_addr)
 		return SUCCESS;
 
+	/* check if the mac already preset in CAM */
+	for(i = 1; i < config->max_mac_addr; i++) {
+		tmp64 = do_s2io_read_unicast_mc(sp,i);
+		if(tmp64 == S2IO_DISABLE_MAC_ENTRY) /* CAM entry is empty */
+			break;
+
+		if(tmp64 == mac_addr) {
+			DBG_PRINT(INFO_DBG,
+			"MAC addr:0x%llx already present in CAM\n",
+			(unsigned long long)mac_addr);
+			return SUCCESS;
+		}
+	}
+	if(i == config->max_mac_addr) {
+		DBG_PRINT(ERR_DBG,"CAM full no space left for Unicast MAC\n");
+		return FAILURE;
+	}
+
 	/* Update the internal structure with this new mac address */
-	do_s2io_copy_mac_addr(sp, 0, mac_addr);
-	return (do_s2io_add_unicast(sp,mac_addr,0));
+	do_s2io_copy_mac_addr(sp, i, mac_addr);
+	return (do_s2io_add_mac(sp,mac_addr,i));
 }
 
 /**
@@ -7636,7 +7782,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	 */
 	bar0 = sp->bar0;
 	val64 = RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
-	    RMAC_ADDR_CMD_MEM_OFFSET(0 + MAC_MAC_ADDR_START_OFFSET);
+	    RMAC_ADDR_CMD_MEM_OFFSET(0 + S2IO_MAC_ADDR_START_OFFSET);
 	writeq(val64, &bar0->rmac_addr_cmd_mem);
 	wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
 		      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING, S2IO_BIT_RESET);
@@ -7656,7 +7802,22 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	memcpy(dev->dev_addr, sp->def_mac_addr, ETH_ALEN);
 	memcpy(dev->perm_addr, dev->dev_addr, ETH_ALEN);
 
-	 /* Store the values of the MSIX table in the s2io_nic structure */
+	/* initialize number of multicast & unicast MAC entries variables */
+	if (sp->device_type == XFRAME_I_DEVICE) {
+		config->max_mc_addr = S2IO_XENA_MAX_MC_ADDRESSES;
+		config->max_mac_addr = S2IO_XENA_MAX_MAC_ADDRESSES;
+		config->mc_start_offset = S2IO_XENA_MC_ADDR_START_OFFSET;
+	}
+	else  if (sp->device_type == XFRAME_II_DEVICE) {
+		config->max_mc_addr = S2IO_HERC_MAX_MC_ADDRESSES;
+		config->max_mac_addr = S2IO_HERC_MAX_MAC_ADDRESSES;
+		config->mc_start_offset = S2IO_HERC_MC_ADDR_START_OFFSET;
+	}
+
+	/* store mac addresses from CAM to s2io_nic structure */
+	do_s2io_store_unicast_mc(sp);
+
+	/* Store the values of the MSIX table in the s2io_nic structure */
 	store_xmsi_data(sp);
 	/* reset Nic and bring it to known state */
 	s2io_reset(sp);
diff -Nurp 2.0.26.5-1/drivers/net/s2io.h 2.0.26.5-2/drivers/net/s2io.h
--- 2.0.26.5-1/drivers/net/s2io.h	2007-09-06 14:42:24.000000000 -0700
+++ 2.0.26.5-2/drivers/net/s2io.h	2007-09-06 15:45:10.000000000 -0700
@@ -31,6 +31,7 @@
 #define SUCCESS 0
 #define FAILURE -1
 #define S2IO_MINUS_ONE 0xFFFFFFFFFFFFFFFFULL
+#define S2IO_DISABLE_MAC_ENTRY 0xFFFFFFFFFFFFULL
 #define S2IO_MAX_PCI_CONFIG_SPACE_REINIT 100
 #define S2IO_BIT_RESET 1
 #define S2IO_BIT_SET 2
@@ -458,6 +459,9 @@ struct config_param {
 #define MAX_MTU_JUMBO               (MAX_PYLD_JUMBO+18)
 #define MAX_MTU_JUMBO_VLAN          (MAX_PYLD_JUMBO+22)
 	u16 bus_speed;
+	int max_mc_addr;	/* xena=64 herc=256 */
+	int max_mac_addr;	/* xena=16 herc=64 */
+	int mc_start_offset;	/* xena=16 herc=64 */
 };
 
 /* Structure representing MAC Addrs */
@@ -823,9 +827,8 @@ struct s2io_nic {
 	void __iomem *bar0;
 	void __iomem *bar1;
 #define MAX_MAC_SUPPORTED   16
-#define MAX_SUPPORTED_MULTICASTS MAX_MAC_SUPPORTED
 
-	struct mac_addr def_mac_addr[MAX_MAC_SUPPORTED];
+	struct mac_addr def_mac_addr[256];
 
 	struct net_device_stats stats;
 	int high_dma_flag;
@@ -849,10 +852,9 @@ struct s2io_nic {
 #define PROMISC     1
 #define ALL_MULTI   2
 
-#define MAX_ADDRS_SUPPORTED 64
 	u16 usr_addr_count;
 	u16 mc_addr_count;
-	struct usr_addr usr_addrs[MAX_ADDRS_SUPPORTED];
+	struct usr_addr usr_addrs[256];
 
 	u16 m_cast_flg;
 	u16 all_multi_pos;
@@ -1065,6 +1067,12 @@ static int s2io_add_isr(struct s2io_nic 
 static void s2io_rem_isr(struct s2io_nic * sp);
 
 static void restore_xmsi_data(struct s2io_nic *nic);
+static void do_s2io_store_unicast_mc(struct s2io_nic *sp);
+static void do_s2io_restore_unicast_mc(struct s2io_nic *sp);
+static u64 do_s2io_read_unicast_mc(struct s2io_nic *sp, int offset);
+static int do_s2io_add_mc(struct s2io_nic *sp, u8 *addr);
+static int do_s2io_add_mac(struct s2io_nic *sp, u64 addr, int offset);
+static int do_s2io_delete_unicast_mc(struct s2io_nic *sp, u64 addr);
 
 static int
 s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
diff -Nurp 2.0.26.5-1/drivers/net/s2io-regs.h 2.0.26.5-2/drivers/net/s2io-regs.h
--- 2.0.26.5-1/drivers/net/s2io-regs.h	2007-09-06 14:42:24.000000000 -0700
+++ 2.0.26.5-2/drivers/net/s2io-regs.h	2007-09-06 15:45:10.000000000 -0700
@@ -721,12 +721,16 @@ struct XENA_dev_config {
 
 	u64 rmac_cfg_key;
 #define RMAC_CFG_KEY(val)               vBIT(val,0,16)
+#define S2IO_MAC_ADDR_START_OFFSET 0
 
-#define MAX_MAC_ADDRESSES           16
-#define MAX_MC_ADDRESSES            32	/* Multicast addresses */
-#define MAC_MAC_ADDR_START_OFFSET   0
-#define MAC_MC_ADDR_START_OFFSET    16
-#define MAC_MC_ALL_MC_ADDR_OFFSET   63	/* enables all multicast pkts */
+#define S2IO_XENA_MAX_MC_ADDRESSES 64  /* multicast addresses */
+#define S2IO_HERC_MAX_MC_ADDRESSES 256
+
+#define S2IO_XENA_MAX_MAC_ADDRESSES    16
+#define S2IO_HERC_MAX_MAC_ADDRESSES    64
+
+#define S2IO_XENA_MC_ADDR_START_OFFSET 16
+#define S2IO_HERC_MC_ADDR_START_OFFSET 64
 	u64 rmac_addr_cmd_mem;
 #define RMAC_ADDR_CMD_MEM_WE                    BIT(7)
 #define RMAC_ADDR_CMD_MEM_RD                    0

