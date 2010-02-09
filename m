From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 6/7] drivers/net/qlge: Use netif_printk helpers
Date: Tue,  9 Feb 2010 13:49:52 -0800
Message-ID: <01876a7b8cb54f54f60b640f00eeb55bd6945705.1265751024.git.joe@perches.com>
References: <cover.1265751023.git.joe@perches.com>
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1910 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754220Ab0BIVt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 16:49:56 -0500
In-Reply-To: <cover.1265751023.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert QPRINTK macros to netif_<level> equivalents.
Expands and standardizes the logging message output.
Removes __func__ from most logging messages.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/qlge/qlge.h         |    8 -
 drivers/net/qlge/qlge_dbg.c     |   58 ++--
 drivers/net/qlge/qlge_ethtool.c |   49 ++-
 drivers/net/qlge/qlge_main.c    |  841 ++++++++++++++++++++-------------------
 drivers/net/qlge/qlge_mpi.c     |  183 ++++-----
 5 files changed, 580 insertions(+), 559 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index ebfd177..57d135e 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -19,14 +19,6 @@
 #define DRV_VERSION	"v1.00.00.23.00.00-01"
 
 #define PFX "qlge: "
-#define QPRINTK(qdev, nlevel, klevel, fmt, args...)     \
-       do {       \
-	if (!((qdev)->msg_enable & NETIF_MSG_##nlevel))		\
-		;						\
-	else							\
-		dev_printk(KERN_##klevel, &((qdev)->pdev->dev),	\
-			   "%s: " fmt, __func__, ##args);  \
-       } while (0)
 
 #define WQ_ADDR_ALIGN	0x3	/* 4 byte alignment */
 
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 57df835..ff8550d 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -443,8 +443,8 @@ static int ql_get_cam_entries(struct ql_adapter *qdev, u32 * buf)
 		status = ql_get_mac_addr_reg(qdev,
 					MAC_ADDR_TYPE_CAM_MAC, i, value);
 		if (status) {
-			QPRINTK(qdev, DRV, ERR,
-				"Failed read of mac index register.\n");
+			netif_err(qdev, drv, qdev->ndev,
+				  "Failed read of mac index register.\n");
 			goto err;
 		}
 		*buf++ = value[0];	/* lower MAC address */
@@ -455,8 +455,8 @@ static int ql_get_cam_entries(struct ql_adapter *qdev, u32 * buf)
 		status = ql_get_mac_addr_reg(qdev,
 					MAC_ADDR_TYPE_MULTI_MAC, i, value);
 		if (status) {
-			QPRINTK(qdev, DRV, ERR,
-				"Failed read of mac index register.\n");
+			netif_err(qdev, drv, qdev->ndev,
+				  "Failed read of mac index register.\n");
 			goto err;
 		}
 		*buf++ = value[0];	/* lower Mcast address */
@@ -479,8 +479,8 @@ static int ql_get_routing_entries(struct ql_adapter *qdev, u32 * buf)
 	for (i = 0; i < 16; i++) {
 		status = ql_get_routing_reg(qdev, i, &value);
 		if (status) {
-			QPRINTK(qdev, DRV, ERR,
-				"Failed read of routing index register.\n");
+			netif_err(qdev, drv, qdev->ndev,
+				  "Failed read of routing index register.\n");
 			goto err;
 		} else {
 			*buf++ = value;
@@ -736,8 +736,7 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 	int i;
 
 	if (!mpi_coredump) {
-		QPRINTK(qdev, DRV, ERR,
-			"No memory available.\n");
+		netif_err(qdev, drv, qdev->ndev, "No memory available.\n");
 		return -ENOMEM;
 	}
 
@@ -749,8 +748,8 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 
 	status = ql_pause_mpi_risc(qdev);
 	if (status) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed RISC pause. Status = 0x%.08x\n", status);
+		netif_err(qdev, drv, qdev->ndev,
+			  "Failed RISC pause. Status = 0x%.08x\n", status);
 		goto err;
 	}
 
@@ -911,9 +910,9 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 
 	status = ql_get_serdes_regs(qdev, mpi_coredump);
 	if (status) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed Dump of Serdes Registers. Status = 0x%.08x\n",
-			status);
+		netif_err(qdev, drv, qdev->ndev,
+			  "Failed Dump of Serdes Registers. Status = 0x%.08x\n",
+			  status);
 		goto err;
 	}
 
@@ -1177,16 +1176,16 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 	/* clear the pause */
 	status = ql_unpause_mpi_risc(qdev);
 	if (status) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed RISC unpause. Status = 0x%.08x\n", status);
+		netif_err(qdev, drv, qdev->ndev,
+			  "Failed RISC unpause. Status = 0x%.08x\n", status);
 		goto err;
 	}
 
 	/* Reset the RISC so we can dump RAM */
 	status = ql_hard_reset_mpi_risc(qdev);
 	if (status) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed RISC reset. Status = 0x%.08x\n", status);
+		netif_err(qdev, drv, qdev->ndev,
+			  "Failed RISC reset. Status = 0x%.08x\n", status);
 		goto err;
 	}
 
@@ -1198,8 +1197,9 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 	status = ql_dump_risc_ram_area(qdev, &mpi_coredump->code_ram[0],
 					CODE_RAM_ADDR, CODE_RAM_CNT);
 	if (status) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed Dump of CODE RAM. Status = 0x%.08x\n", status);
+		netif_err(qdev, drv, qdev->ndev,
+			  "Failed Dump of CODE RAM. Status = 0x%.08x\n",
+			  status);
 		goto err;
 	}
 
@@ -1212,8 +1212,9 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 	status = ql_dump_risc_ram_area(qdev, &mpi_coredump->memc_ram[0],
 					MEMC_RAM_ADDR, MEMC_RAM_CNT);
 	if (status) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed Dump of MEMC RAM. Status = 0x%.08x\n", status);
+		netif_err(qdev, drv, qdev->ndev,
+			  "Failed Dump of MEMC RAM. Status = 0x%.08x\n",
+			  status);
 		goto err;
 	}
 err:
@@ -1225,21 +1226,19 @@ err:
 static void ql_get_core_dump(struct ql_adapter *qdev)
 {
 	if (!ql_own_firmware(qdev)) {
-		QPRINTK(qdev, DRV, ERR, "%s: Don't own firmware!\n",
-					qdev->ndev->name);
+		netif_err(qdev, drv, qdev->ndev, "Don't own firmware!\n");
 		return;
 	}
 
 	if (!netif_running(qdev->ndev)) {
-		QPRINTK(qdev, IFUP, ERR,
-			"Force Coredump can only be done from interface "
-			"that is up.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Force Coredump can only be done from interface that is up.\n");
 		return;
 	}
 
 	if (ql_mb_sys_err(qdev)) {
-		QPRINTK(qdev, IFUP, ERR,
-			"Fail force coredump with ql_mb_sys_err().\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Fail force coredump with ql_mb_sys_err().\n");
 		return;
 	}
 }
@@ -1334,7 +1333,8 @@ void ql_mpi_core_to_log(struct work_struct *work)
 
 	count = sizeof(struct ql_mpi_coredump) / sizeof(u32);
 	tmp = (u32 *)qdev->mpi_coredump;
-	QPRINTK(qdev, DRV, DEBUG, "Core is dumping to log file!\n");
+	netif_printk(qdev, drv, KERN_DEBUG, qdev->ndev,
+		     "Core is dumping to log file!\n");
 
 	for (i = 0; i < count; i += 8) {
 		printk(KERN_ERR "%.08x: %.08x %.08x %.08x %.08x %.08x "
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index 058fa0a..4f26afe 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -67,8 +67,8 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
 			status = ql_write_cfg(qdev, cqicb, sizeof(*cqicb),
 						CFG_LCQ, rx_ring->cq_id);
 			if (status) {
-				QPRINTK(qdev, IFUP, ERR,
-					"Failed to load CQICB.\n");
+				netif_err(qdev, ifup, qdev->ndev,
+					  "Failed to load CQICB.\n");
 				goto exit;
 			}
 		}
@@ -89,8 +89,8 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
 			status = ql_write_cfg(qdev, cqicb, sizeof(*cqicb),
 						CFG_LCQ, rx_ring->cq_id);
 			if (status) {
-				QPRINTK(qdev, IFUP, ERR,
-					"Failed to load CQICB.\n");
+				netif_err(qdev, ifup, qdev->ndev,
+					  "Failed to load CQICB.\n");
 				goto exit;
 			}
 		}
@@ -107,8 +107,8 @@ static void ql_update_stats(struct ql_adapter *qdev)
 
 	spin_lock(&qdev->stats_lock);
 	if (ql_sem_spinlock(qdev, qdev->xg_sem_mask)) {
-			QPRINTK(qdev, DRV, ERR,
-				"Couldn't get xgmac sem.\n");
+			netif_err(qdev, drv, qdev->ndev,
+				  "Couldn't get xgmac sem.\n");
 		goto quit;
 	}
 	/*
@@ -116,8 +116,9 @@ static void ql_update_stats(struct ql_adapter *qdev)
 	 */
 	for (i = 0x200; i < 0x280; i += 8) {
 		if (ql_read_xgmac_reg64(qdev, i, &data)) {
-			QPRINTK(qdev, DRV, ERR,
-				"Error reading status register 0x%.04x.\n", i);
+			netif_err(qdev, drv, qdev->ndev,
+				  "Error reading status register 0x%.04x.\n",
+				  i);
 			goto end;
 		} else
 			*iter = data;
@@ -129,8 +130,9 @@ static void ql_update_stats(struct ql_adapter *qdev)
 	 */
 	for (i = 0x300; i < 0x3d0; i += 8) {
 		if (ql_read_xgmac_reg64(qdev, i, &data)) {
-			QPRINTK(qdev, DRV, ERR,
-				"Error reading status register 0x%.04x.\n", i);
+			netif_err(qdev, drv, qdev->ndev,
+				  "Error reading status register 0x%.04x.\n",
+				  i);
 			goto end;
 		} else
 			*iter = data;
@@ -142,8 +144,9 @@ static void ql_update_stats(struct ql_adapter *qdev)
 	 */
 	for (i = 0x500; i < 0x540; i += 8) {
 		if (ql_read_xgmac_reg64(qdev, i, &data)) {
-			QPRINTK(qdev, DRV, ERR,
-				"Error reading status register 0x%.04x.\n", i);
+			netif_err(qdev, drv, qdev->ndev,
+				  "Error reading status register 0x%.04x.\n",
+				  i);
 			goto end;
 		} else
 			*iter = data;
@@ -155,8 +158,9 @@ static void ql_update_stats(struct ql_adapter *qdev)
 	 */
 	for (i = 0x568; i < 0x5a8; i += 8) {
 		if (ql_read_xgmac_reg64(qdev, i, &data)) {
-			QPRINTK(qdev, DRV, ERR,
-				"Error reading status register 0x%.04x.\n", i);
+			netif_err(qdev, drv, qdev->ndev,
+				  "Error reading status register 0x%.04x.\n",
+				  i);
 			goto end;
 		} else
 			*iter = data;
@@ -167,8 +171,8 @@ static void ql_update_stats(struct ql_adapter *qdev)
 	 * Get RX NIC FIFO DROP statistics.
 	 */
 	if (ql_read_xgmac_reg64(qdev, 0x5b8, &data)) {
-		QPRINTK(qdev, DRV, ERR,
-			"Error reading status register 0x%.04x.\n", i);
+		netif_err(qdev, drv, qdev->ndev,
+			  "Error reading status register 0x%.04x.\n", i);
 		goto end;
 	} else
 		*iter = data;
@@ -396,14 +400,13 @@ static int ql_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 		return -EINVAL;
 	qdev->wol = wol->wolopts;
 
-	QPRINTK(qdev, DRV, INFO, "Set wol option 0x%x on %s\n",
-			 qdev->wol, ndev->name);
+	netif_info(qdev, drv, qdev->ndev, "Set wol option 0x%x\n", qdev->wol);
 	if (!qdev->wol) {
 		u32 wol = 0;
 		status = ql_mb_wol_mode(qdev, wol);
-		QPRINTK(qdev, DRV, ERR, "WOL %s (wol code 0x%x) on %s\n",
-			(status == 0) ? "cleared sucessfully" : "clear failed",
-			wol, qdev->ndev->name);
+		netif_err(qdev, drv, qdev->ndev, "WOL %s (wol code 0x%x)\n",
+			  status == 0 ? "cleared sucessfully" : "clear failed",
+			  wol);
 	}
 
 	return 0;
@@ -534,8 +537,8 @@ static void ql_self_test(struct net_device *ndev,
 		}
 		clear_bit(QL_SELFTEST, &qdev->flags);
 	} else {
-		QPRINTK(qdev, DRV, ERR,
-			"%s: is down, Loopback test will fail.\n", ndev->name);
+		netif_err(qdev, drv, qdev->ndev,
+			  "is down, Loopback test will fail.\n");
 		eth_test->flags |= ETH_TEST_FL_FAILED;
 	}
 }
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 3cb60e1..7e2172c 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -128,7 +128,7 @@ static int ql_sem_trylock(struct ql_adapter *qdev, u32 sem_mask)
 		sem_bits = SEM_SET << SEM_PROC_REG_SHIFT;
 		break;
 	default:
-		QPRINTK(qdev, PROBE, ALERT, "Bad Semaphore mask!.\n");
+		netif_alert(qdev, probe, qdev->ndev, "bad Semaphore mask!.\n");
 		return -EINVAL;
 	}
 
@@ -168,17 +168,17 @@ int ql_wait_reg_rdy(struct ql_adapter *qdev, u32 reg, u32 bit, u32 err_bit)
 
 		/* check for errors */
 		if (temp & err_bit) {
-			QPRINTK(qdev, PROBE, ALERT,
-				"register 0x%.08x access error, value = 0x%.08x!.\n",
-				reg, temp);
+			netif_alert(qdev, probe, qdev->ndev,
+				    "register 0x%.08x access error, value = 0x%.08x!.\n",
+				    reg, temp);
 			return -EIO;
 		} else if (temp & bit)
 			return 0;
 		udelay(UDELAY_DELAY);
 		count--;
 	}
-	QPRINTK(qdev, PROBE, ALERT,
-		"Timed out waiting for reg %x to come ready.\n", reg);
+	netif_alert(qdev, probe, qdev->ndev,
+		    "Timed out waiting for reg %x to come ready.\n", reg);
 	return -ETIMEDOUT;
 }
 
@@ -221,7 +221,7 @@ int ql_write_cfg(struct ql_adapter *qdev, void *ptr, int size, u32 bit,
 
 	map = pci_map_single(qdev->pdev, ptr, size, direction);
 	if (pci_dma_mapping_error(qdev->pdev, map)) {
-		QPRINTK(qdev, IFUP, ERR, "Couldn't map DMA area.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Couldn't map DMA area.\n");
 		return -ENOMEM;
 	}
 
@@ -231,8 +231,8 @@ int ql_write_cfg(struct ql_adapter *qdev, void *ptr, int size, u32 bit,
 
 	status = ql_wait_cfg(qdev, bit);
 	if (status) {
-		QPRINTK(qdev, IFUP, ERR,
-			"Timed out waiting for CFG to come ready.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Timed out waiting for CFG to come ready.\n");
 		goto exit;
 	}
 
@@ -313,8 +313,8 @@ int ql_get_mac_addr_reg(struct ql_adapter *qdev, u32 type, u16 index,
 	case MAC_ADDR_TYPE_VLAN:
 	case MAC_ADDR_TYPE_MULTI_FLTR:
 	default:
-		QPRINTK(qdev, IFUP, CRIT,
-			"Address type %d not yet supported.\n", type);
+		netif_crit(qdev, ifup, qdev->ndev,
+			   "Address type %d not yet supported.\n", type);
 		status = -EPERM;
 	}
 exit:
@@ -371,12 +371,11 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 			    (addr[2] << 24) | (addr[3] << 16) | (addr[4] << 8) |
 			    (addr[5]);
 
-			QPRINTK(qdev, IFUP, DEBUG,
-				"Adding %s address %pM"
-				" at index %d in the CAM.\n",
-				((type ==
-				  MAC_ADDR_TYPE_MULTI_MAC) ? "MULTICAST" :
-				 "UNICAST"), addr, index);
+			netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+				     "Adding %s address %pM at index %d in the CAM.\n",
+				     type == MAC_ADDR_TYPE_MULTI_MAC ?
+				     "MULTICAST" : "UNICAST",
+				     addr, index);
 
 			status =
 			    ql_wait_reg_rdy(qdev,
@@ -426,9 +425,11 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 			 * addressing. It's either MAC_ADDR_E on or off.
 			 * That's bit-27 we're talking about.
 			 */
-			QPRINTK(qdev, IFUP, INFO, "%s VLAN ID %d %s the CAM.\n",
-				(enable_bit ? "Adding" : "Removing"),
-				index, (enable_bit ? "to" : "from"));
+			netif_info(qdev, ifup, qdev->ndev,
+				   "%s VLAN ID %d %s the CAM.\n",
+				   enable_bit ? "Adding" : "Removing",
+				   index,
+				   enable_bit ? "to" : "from");
 
 			status =
 			    ql_wait_reg_rdy(qdev,
@@ -443,8 +444,8 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 		}
 	case MAC_ADDR_TYPE_MULTI_FLTR:
 	default:
-		QPRINTK(qdev, IFUP, CRIT,
-			"Address type %d not yet supported.\n", type);
+		netif_crit(qdev, ifup, qdev->ndev,
+			   "Address type %d not yet supported.\n", type);
 		status = -EPERM;
 	}
 exit:
@@ -463,14 +464,13 @@ static int ql_set_mac_addr(struct ql_adapter *qdev, int set)
 
 	if (set) {
 		addr = &qdev->ndev->dev_addr[0];
-		QPRINTK(qdev, IFUP, DEBUG,
-			"Set Mac addr %pM\n", addr);
+		netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+			     "Set Mac addr %pM\n", addr);
 	} else {
 		memset(zero_mac_addr, 0, ETH_ALEN);
 		addr = &zero_mac_addr[0];
-		QPRINTK(qdev, IFUP, DEBUG,
-				"Clearing MAC address on %s\n",
-				qdev->ndev->name);
+		netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+			     "Clearing MAC address\n");
 	}
 	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
 	if (status)
@@ -479,23 +479,21 @@ static int ql_set_mac_addr(struct ql_adapter *qdev, int set)
 			MAC_ADDR_TYPE_CAM_MAC, qdev->func * MAX_CQ);
 	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 	if (status)
-		QPRINTK(qdev, IFUP, ERR, "Failed to init mac "
-			"address.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Failed to init mac address.\n");
 	return status;
 }
 
 void ql_link_on(struct ql_adapter *qdev)
 {
-	QPRINTK(qdev, LINK, ERR, "%s: Link is up.\n",
-				 qdev->ndev->name);
+	netif_err(qdev, link, qdev->ndev, "Link is up.\n");
 	netif_carrier_on(qdev->ndev);
 	ql_set_mac_addr(qdev, 1);
 }
 
 void ql_link_off(struct ql_adapter *qdev)
 {
-	QPRINTK(qdev, LINK, ERR, "%s: Link is down.\n",
-				 qdev->ndev->name);
+	netif_err(qdev, link, qdev->ndev, "Link is down.\n");
 	netif_carrier_off(qdev->ndev);
 	ql_set_mac_addr(qdev, 0);
 }
@@ -532,27 +530,27 @@ static int ql_set_routing_reg(struct ql_adapter *qdev, u32 index, u32 mask,
 	int status = -EINVAL; /* Return error if no mask match. */
 	u32 value = 0;
 
-	QPRINTK(qdev, IFUP, DEBUG,
-		"%s %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s mask %s the routing reg.\n",
-		(enable ? "Adding" : "Removing"),
-		((index == RT_IDX_ALL_ERR_SLOT) ? "MAC ERROR/ALL ERROR" : ""),
-		((index == RT_IDX_IP_CSUM_ERR_SLOT) ? "IP CSUM ERROR" : ""),
-		((index ==
-		  RT_IDX_TCP_UDP_CSUM_ERR_SLOT) ? "TCP/UDP CSUM ERROR" : ""),
-		((index == RT_IDX_BCAST_SLOT) ? "BROADCAST" : ""),
-		((index == RT_IDX_MCAST_MATCH_SLOT) ? "MULTICAST MATCH" : ""),
-		((index == RT_IDX_ALLMULTI_SLOT) ? "ALL MULTICAST MATCH" : ""),
-		((index == RT_IDX_UNUSED6_SLOT) ? "UNUSED6" : ""),
-		((index == RT_IDX_UNUSED7_SLOT) ? "UNUSED7" : ""),
-		((index == RT_IDX_RSS_MATCH_SLOT) ? "RSS ALL/IPV4 MATCH" : ""),
-		((index == RT_IDX_RSS_IPV6_SLOT) ? "RSS IPV6" : ""),
-		((index == RT_IDX_RSS_TCP4_SLOT) ? "RSS TCP4" : ""),
-		((index == RT_IDX_RSS_TCP6_SLOT) ? "RSS TCP6" : ""),
-		((index == RT_IDX_CAM_HIT_SLOT) ? "CAM HIT" : ""),
-		((index == RT_IDX_UNUSED013) ? "UNUSED13" : ""),
-		((index == RT_IDX_UNUSED014) ? "UNUSED14" : ""),
-		((index == RT_IDX_PROMISCUOUS_SLOT) ? "PROMISCUOUS" : ""),
-		(enable ? "to" : "from"));
+	netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+		     "%s %s mask %s the routing reg.\n",
+		     enable ? "Adding" : "Removing",
+		     index == RT_IDX_ALL_ERR_SLOT ? "MAC ERROR/ALL ERROR" :
+		     index == RT_IDX_IP_CSUM_ERR_SLOT ? "IP CSUM ERROR" :
+		     index == RT_IDX_TCP_UDP_CSUM_ERR_SLOT ? "TCP/UDP CSUM ERROR" :
+		     index == RT_IDX_BCAST_SLOT ? "BROADCAST" :
+		     index == RT_IDX_MCAST_MATCH_SLOT ? "MULTICAST MATCH" :
+		     index == RT_IDX_ALLMULTI_SLOT ? "ALL MULTICAST MATCH" :
+		     index == RT_IDX_UNUSED6_SLOT ? "UNUSED6" :
+		     index == RT_IDX_UNUSED7_SLOT ? "UNUSED7" :
+		     index == RT_IDX_RSS_MATCH_SLOT ? "RSS ALL/IPV4 MATCH" :
+		     index == RT_IDX_RSS_IPV6_SLOT ? "RSS IPV6" :
+		     index == RT_IDX_RSS_TCP4_SLOT ? "RSS TCP4" :
+		     index == RT_IDX_RSS_TCP6_SLOT ? "RSS TCP6" :
+		     index == RT_IDX_CAM_HIT_SLOT ? "CAM HIT" :
+		     index == RT_IDX_UNUSED013 ? "UNUSED13" :
+		     index == RT_IDX_UNUSED014 ? "UNUSED14" :
+		     index == RT_IDX_PROMISCUOUS_SLOT ? "PROMISCUOUS" :
+		     "(Bad index != RT_IDX)",
+		     enable ? "to" : "from");
 
 	switch (mask) {
 	case RT_IDX_CAM_HIT:
@@ -612,8 +610,8 @@ static int ql_set_routing_reg(struct ql_adapter *qdev, u32 index, u32 mask,
 			break;
 		}
 	default:
-		QPRINTK(qdev, IFUP, ERR, "Mask type %d not yet supported.\n",
-			mask);
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Mask type %d not yet supported.\n", mask);
 		status = -EPERM;
 		goto exit;
 	}
@@ -719,7 +717,7 @@ static int ql_validate_flash(struct ql_adapter *qdev, u32 size, const char *str)
 
 	status = strncmp((char *)&qdev->flash, str, 4);
 	if (status) {
-		QPRINTK(qdev, IFUP, ERR, "Invalid flash signature.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Invalid flash signature.\n");
 		return	status;
 	}
 
@@ -727,8 +725,8 @@ static int ql_validate_flash(struct ql_adapter *qdev, u32 size, const char *str)
 		csum += le16_to_cpu(*flash++);
 
 	if (csum)
-		QPRINTK(qdev, IFUP, ERR,
-			"Invalid flash checksum, csum = 0x%.04x.\n", csum);
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Invalid flash checksum, csum = 0x%.04x.\n", csum);
 
 	return csum;
 }
@@ -780,7 +778,8 @@ static int ql_get_8000_flash_params(struct ql_adapter *qdev)
 	for (i = 0; i < size; i++, p++) {
 		status = ql_read_flash_word(qdev, i+offset, p);
 		if (status) {
-			QPRINTK(qdev, IFUP, ERR, "Error reading flash.\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Error reading flash.\n");
 			goto exit;
 		}
 	}
@@ -789,7 +788,7 @@ static int ql_get_8000_flash_params(struct ql_adapter *qdev)
 			sizeof(struct flash_params_8000) / sizeof(u16),
 			"8000");
 	if (status) {
-		QPRINTK(qdev, IFUP, ERR, "Invalid flash.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Invalid flash.\n");
 		status = -EINVAL;
 		goto exit;
 	}
@@ -807,7 +806,7 @@ static int ql_get_8000_flash_params(struct ql_adapter *qdev)
 			qdev->ndev->addr_len);
 
 	if (!is_valid_ether_addr(mac_addr)) {
-		QPRINTK(qdev, IFUP, ERR, "Invalid MAC address.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Invalid MAC address.\n");
 		status = -EINVAL;
 		goto exit;
 	}
@@ -841,7 +840,8 @@ static int ql_get_8012_flash_params(struct ql_adapter *qdev)
 	for (i = 0; i < size; i++, p++) {
 		status = ql_read_flash_word(qdev, i+offset, p);
 		if (status) {
-			QPRINTK(qdev, IFUP, ERR, "Error reading flash.\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Error reading flash.\n");
 			goto exit;
 		}
 
@@ -851,7 +851,7 @@ static int ql_get_8012_flash_params(struct ql_adapter *qdev)
 			sizeof(struct flash_params_8012) / sizeof(u16),
 			"8012");
 	if (status) {
-		QPRINTK(qdev, IFUP, ERR, "Invalid flash.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Invalid flash.\n");
 		status = -EINVAL;
 		goto exit;
 	}
@@ -969,17 +969,17 @@ static int ql_8012_port_initialize(struct ql_adapter *qdev)
 		/* Another function has the semaphore, so
 		 * wait for the port init bit to come ready.
 		 */
-		QPRINTK(qdev, LINK, INFO,
-			"Another function has the semaphore, so wait for the port init bit to come ready.\n");
+		netif_info(qdev, link, qdev->ndev,
+			   "Another function has the semaphore, so wait for the port init bit to come ready.\n");
 		status = ql_wait_reg_rdy(qdev, STS, qdev->port_init, 0);
 		if (status) {
-			QPRINTK(qdev, LINK, CRIT,
-				"Port initialize timed out.\n");
+			netif_crit(qdev, link, qdev->ndev,
+				   "Port initialize timed out.\n");
 		}
 		return status;
 	}
 
-	QPRINTK(qdev, LINK, INFO, "Got xgmac semaphore!.\n");
+	netif_info(qdev, link, qdev->ndev, "Got xgmac semaphore!.\n");
 	/* Set the core reset. */
 	status = ql_read_xgmac_reg(qdev, GLOBAL_CFG, &data);
 	if (status)
@@ -1109,8 +1109,8 @@ static int ql_get_next_chunk(struct ql_adapter *qdev, struct rx_ring *rx_ring,
 						GFP_ATOMIC,
 						qdev->lbq_buf_order);
 		if (unlikely(!rx_ring->pg_chunk.page)) {
-			QPRINTK(qdev, DRV, ERR,
-				"page allocation failed.\n");
+			netif_err(qdev, drv, qdev->ndev,
+				  "page allocation failed.\n");
 			return -ENOMEM;
 		}
 		rx_ring->pg_chunk.offset = 0;
@@ -1120,8 +1120,8 @@ static int ql_get_next_chunk(struct ql_adapter *qdev, struct rx_ring *rx_ring,
 		if (pci_dma_mapping_error(qdev->pdev, map)) {
 			__free_pages(rx_ring->pg_chunk.page,
 					qdev->lbq_buf_order);
-			QPRINTK(qdev, DRV, ERR,
-				"PCI mapping failed.\n");
+			netif_err(qdev, drv, qdev->ndev,
+				  "PCI mapping failed.\n");
 			return -ENOMEM;
 		}
 		rx_ring->pg_chunk.map = map;
@@ -1158,15 +1158,15 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 
 	while (rx_ring->lbq_free_cnt > 32) {
 		for (i = 0; i < 16; i++) {
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-				"lbq: try cleaning clean_idx = %d.\n",
-				clean_idx);
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "lbq: try cleaning clean_idx = %d.\n",
+				     clean_idx);
 			lbq_desc = &rx_ring->lbq[clean_idx];
 			if (ql_get_next_chunk(qdev, rx_ring, lbq_desc)) {
-				QPRINTK(qdev, IFUP, ERR,
-					"Could not get a page chunk.\n");
-					return;
-				}
+				netif_err(qdev, ifup, qdev->ndev,
+					  "Could not get a page chunk.\n");
+				return;
+			}
 
 			map = lbq_desc->p.pg_chunk.map +
 				lbq_desc->p.pg_chunk.offset;
@@ -1191,9 +1191,9 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	}
 
 	if (start_idx != clean_idx) {
-		QPRINTK(qdev, RX_STATUS, DEBUG,
-			"lbq: updating prod idx = %d.\n",
-			rx_ring->lbq_prod_idx);
+		netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+			     "lbq: updating prod idx = %d.\n",
+			     rx_ring->lbq_prod_idx);
 		ql_write_db_reg(rx_ring->lbq_prod_idx,
 				rx_ring->lbq_prod_idx_db_reg);
 	}
@@ -1211,19 +1211,20 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	while (rx_ring->sbq_free_cnt > 16) {
 		for (i = 0; i < 16; i++) {
 			sbq_desc = &rx_ring->sbq[clean_idx];
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-				"sbq: try cleaning clean_idx = %d.\n",
-				clean_idx);
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "sbq: try cleaning clean_idx = %d.\n",
+				     clean_idx);
 			if (sbq_desc->p.skb == NULL) {
-				QPRINTK(qdev, RX_STATUS, DEBUG,
-					"sbq: getting new skb for index %d.\n",
-					sbq_desc->index);
+				netif_printk(qdev, rx_status, KERN_DEBUG,
+					     qdev->ndev,
+					     "sbq: getting new skb for index %d.\n",
+					     sbq_desc->index);
 				sbq_desc->p.skb =
 				    netdev_alloc_skb(qdev->ndev,
 						     SMALL_BUFFER_SIZE);
 				if (sbq_desc->p.skb == NULL) {
-					QPRINTK(qdev, PROBE, ERR,
-						"Couldn't get an skb.\n");
+					netif_err(qdev, probe, qdev->ndev,
+						  "Couldn't get an skb.\n");
 					rx_ring->sbq_clean_idx = clean_idx;
 					return;
 				}
@@ -1233,7 +1234,8 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 						     rx_ring->sbq_buf_size,
 						     PCI_DMA_FROMDEVICE);
 				if (pci_dma_mapping_error(qdev->pdev, map)) {
-					QPRINTK(qdev, IFUP, ERR, "PCI mapping failed.\n");
+					netif_err(qdev, ifup, qdev->ndev,
+						  "PCI mapping failed.\n");
 					rx_ring->sbq_clean_idx = clean_idx;
 					dev_kfree_skb_any(sbq_desc->p.skb);
 					sbq_desc->p.skb = NULL;
@@ -1257,9 +1259,9 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	}
 
 	if (start_idx != clean_idx) {
-		QPRINTK(qdev, RX_STATUS, DEBUG,
-			"sbq: updating prod idx = %d.\n",
-			rx_ring->sbq_prod_idx);
+		netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+			     "sbq: updating prod idx = %d.\n",
+			     rx_ring->sbq_prod_idx);
 		ql_write_db_reg(rx_ring->sbq_prod_idx,
 				rx_ring->sbq_prod_idx_db_reg);
 	}
@@ -1291,8 +1293,9 @@ static void ql_unmap_send(struct ql_adapter *qdev,
 			 * then its an OAL.
 			 */
 			if (i == 7) {
-				QPRINTK(qdev, TX_DONE, DEBUG,
-					"unmapping OAL area.\n");
+				netif_printk(qdev, tx_done, KERN_DEBUG,
+					     qdev->ndev,
+					     "unmapping OAL area.\n");
 			}
 			pci_unmap_single(qdev->pdev,
 					 pci_unmap_addr(&tx_ring_desc->map[i],
@@ -1301,8 +1304,8 @@ static void ql_unmap_send(struct ql_adapter *qdev,
 						       maplen),
 					 PCI_DMA_TODEVICE);
 		} else {
-			QPRINTK(qdev, TX_DONE, DEBUG, "unmapping frag %d.\n",
-				i);
+			netif_printk(qdev, tx_done, KERN_DEBUG, qdev->ndev,
+				     "unmapping frag %d.\n", i);
 			pci_unmap_page(qdev->pdev,
 				       pci_unmap_addr(&tx_ring_desc->map[i],
 						      mapaddr),
@@ -1327,7 +1330,8 @@ static int ql_map_send(struct ql_adapter *qdev,
 	int frag_cnt = skb_shinfo(skb)->nr_frags;
 
 	if (frag_cnt) {
-		QPRINTK(qdev, TX_QUEUED, DEBUG, "frag_cnt = %d.\n", frag_cnt);
+		netif_printk(qdev, tx_queued, KERN_DEBUG, qdev->ndev,
+			     "frag_cnt = %d.\n", frag_cnt);
 	}
 	/*
 	 * Map the skb buffer first.
@@ -1336,8 +1340,8 @@ static int ql_map_send(struct ql_adapter *qdev,
 
 	err = pci_dma_mapping_error(qdev->pdev, map);
 	if (err) {
-		QPRINTK(qdev, TX_QUEUED, ERR,
-			"PCI mapping failed with error: %d\n", err);
+		netif_err(qdev, tx_queued, qdev->ndev,
+			  "PCI mapping failed with error: %d\n", err);
 
 		return NETDEV_TX_BUSY;
 	}
@@ -1383,9 +1387,9 @@ static int ql_map_send(struct ql_adapter *qdev,
 					     PCI_DMA_TODEVICE);
 			err = pci_dma_mapping_error(qdev->pdev, map);
 			if (err) {
-				QPRINTK(qdev, TX_QUEUED, ERR,
-					"PCI mapping outbound address list with error: %d\n",
-					err);
+				netif_err(qdev, tx_queued, qdev->ndev,
+					  "PCI mapping outbound address list with error: %d\n",
+					  err);
 				goto map_error;
 			}
 
@@ -1413,9 +1417,9 @@ static int ql_map_send(struct ql_adapter *qdev,
 
 		err = pci_dma_mapping_error(qdev->pdev, map);
 		if (err) {
-			QPRINTK(qdev, TX_QUEUED, ERR,
-				"PCI mapping frags failed with error: %d.\n",
-				err);
+			netif_err(qdev, tx_queued, qdev->ndev,
+				  "PCI mapping frags failed with error: %d.\n",
+				  err);
 			goto map_error;
 		}
 
@@ -1460,7 +1464,8 @@ static void ql_process_mac_rx_gro_page(struct ql_adapter *qdev,
 
 	skb = napi_get_frags(napi);
 	if (!skb) {
-		QPRINTK(qdev, DRV, ERR, "Couldn't get an skb, exiting.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Couldn't get an skb, exiting.\n");
 		rx_ring->rx_dropped++;
 		put_page(lbq_desc->p.pg_chunk.page);
 		return;
@@ -1503,8 +1508,8 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 
 	skb = netdev_alloc_skb(ndev, length);
 	if (!skb) {
-		QPRINTK(qdev, DRV, ERR, "Couldn't get an skb, "
-				"need to unwind!.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Couldn't get an skb, need to unwind!.\n");
 		rx_ring->rx_dropped++;
 		put_page(lbq_desc->p.pg_chunk.page);
 		return;
@@ -1516,8 +1521,8 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 
 	/* Frame error, so drop the packet. */
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
-		QPRINTK(qdev, DRV, ERR, "Receive error, flags2 = 0x%x\n",
-				ib_mac_rsp->flags2);
+		netif_err(qdev, drv, qdev->ndev,
+			  "Receive error, flags2 = 0x%x\n", ib_mac_rsp->flags2);
 		rx_ring->rx_errors++;
 		goto err_out;
 	}
@@ -1526,14 +1531,15 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 	 * MTU since FCoE uses 2k frames.
 	 */
 	if (skb->len > ndev->mtu + ETH_HLEN) {
-		QPRINTK(qdev, DRV, ERR, "Segment too small, dropping.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Segment too small, dropping.\n");
 		rx_ring->rx_dropped++;
 		goto err_out;
 	}
 	memcpy(skb_put(skb, ETH_HLEN), addr, ETH_HLEN);
-	QPRINTK(qdev, RX_STATUS, DEBUG,
-		"%d bytes of headers and data in large. Chain "
-		"page to new skb and pull tail.\n", length);
+	netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+		     "%d bytes of headers and data in large. Chain page to new skb and pull tail.\n",
+		     length);
 	skb_fill_page_desc(skb, 0, lbq_desc->p.pg_chunk.page,
 				lbq_desc->p.pg_chunk.offset+ETH_HLEN,
 				length-ETH_HLEN);
@@ -1550,8 +1556,8 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 		!(ib_mac_rsp->flags1 & IB_MAC_CSUM_ERR_MASK)) {
 		/* TCP frame. */
 		if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_T) {
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-					"TCP checksum done!\n");
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "TCP checksum done!\n");
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		} else if ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_U) &&
 				(ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_V4)) {
@@ -1560,8 +1566,9 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 			if (!(iph->frag_off &
 				cpu_to_be16(IP_MF|IP_OFFSET))) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
-				QPRINTK(qdev, RX_STATUS, DEBUG,
-						"TCP checksum done!\n");
+				netif_printk(qdev, rx_status, KERN_DEBUG,
+					     qdev->ndev,
+					     "TCP checksum done!\n");
 			}
 		}
 	}
@@ -1600,8 +1607,8 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 	/* Allocate new_skb and copy */
 	new_skb = netdev_alloc_skb(qdev->ndev, length + NET_IP_ALIGN);
 	if (new_skb == NULL) {
-		QPRINTK(qdev, PROBE, ERR,
-			"No skb available, drop the packet.\n");
+		netif_err(qdev, probe, qdev->ndev,
+			  "No skb available, drop the packet.\n");
 		rx_ring->rx_dropped++;
 		return;
 	}
@@ -1611,8 +1618,8 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 
 	/* Frame error, so drop the packet. */
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
-		QPRINTK(qdev, DRV, ERR, "Receive error, flags2 = 0x%x\n",
-					ib_mac_rsp->flags2);
+		netif_err(qdev, drv, qdev->ndev,
+			  "Receive error, flags2 = 0x%x\n", ib_mac_rsp->flags2);
 		dev_kfree_skb_any(skb);
 		rx_ring->rx_errors++;
 		return;
@@ -1637,16 +1644,18 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 	prefetch(skb->data);
 	skb->dev = ndev;
 	if (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) {
-		QPRINTK(qdev, RX_STATUS, DEBUG, "%s%s%s Multicast.\n",
-			(ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
-			IB_MAC_IOCB_RSP_M_HASH ? "Hash" : "",
-			(ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
-			IB_MAC_IOCB_RSP_M_REG ? "Registered" : "",
-			(ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
-			IB_MAC_IOCB_RSP_M_PROM ? "Promiscuous" : "");
+		netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+			     "%s Multicast.\n",
+			     (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
+			     IB_MAC_IOCB_RSP_M_HASH ? "Hash" :
+			     (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
+			     IB_MAC_IOCB_RSP_M_REG ? "Registered" :
+			     (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
+			     IB_MAC_IOCB_RSP_M_PROM ? "Promiscuous" : "");
 	}
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_P)
-		QPRINTK(qdev, RX_STATUS, DEBUG, "Promiscuous Packet.\n");
+		netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+			     "Promiscuous Packet.\n");
 
 	rx_ring->rx_packets++;
 	rx_ring->rx_bytes += skb->len;
@@ -1660,8 +1669,8 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 		!(ib_mac_rsp->flags1 & IB_MAC_CSUM_ERR_MASK)) {
 		/* TCP frame. */
 		if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_T) {
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-					"TCP checksum done!\n");
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "TCP checksum done!\n");
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		} else if ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_U) &&
 				(ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_V4)) {
@@ -1670,8 +1679,9 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 			if (!(iph->frag_off &
 				cpu_to_be16(IP_MF|IP_OFFSET))) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
-				QPRINTK(qdev, RX_STATUS, DEBUG,
-						"TCP checksum done!\n");
+				netif_printk(qdev, rx_status, KERN_DEBUG,
+					     qdev->ndev,
+					     "TCP checksum done!\n");
 			}
 		}
 	}
@@ -1725,7 +1735,8 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 	 */
 	if (ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HV &&
 	    ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HS) {
-		QPRINTK(qdev, RX_STATUS, DEBUG, "Header of %d bytes in small buffer.\n", hdr_len);
+		netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+			     "Header of %d bytes in small buffer.\n", hdr_len);
 		/*
 		 * Headers fit nicely into a small buffer.
 		 */
@@ -1744,15 +1755,16 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 	 * Handle the data buffer(s).
 	 */
 	if (unlikely(!length)) {	/* Is there data too? */
-		QPRINTK(qdev, RX_STATUS, DEBUG,
-			"No Data buffer in this packet.\n");
+		netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+			     "No Data buffer in this packet.\n");
 		return skb;
 	}
 
 	if (ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_DS) {
 		if (ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HS) {
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-				"Headers in small, data of %d bytes in small, combine them.\n", length);
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "Headers in small, data of %d bytes in small, combine them.\n",
+				     length);
 			/*
 			 * Data is less than small buffer size so it's
 			 * stuffed in a small buffer.
@@ -1778,8 +1790,9 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 							maplen),
 						       PCI_DMA_FROMDEVICE);
 		} else {
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-				"%d bytes in a single small buffer.\n", length);
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "%d bytes in a single small buffer.\n",
+				     length);
 			sbq_desc = ql_get_curr_sbuf(rx_ring);
 			skb = sbq_desc->p.skb;
 			ql_realign_skb(skb, length);
@@ -1794,18 +1807,18 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 		}
 	} else if (ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_DL) {
 		if (ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HS) {
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-				"Header in small, %d bytes in large. Chain large to small!\n", length);
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "Header in small, %d bytes in large. Chain large to small!\n",
+				     length);
 			/*
 			 * The data is in a single large buffer.  We
 			 * chain it to the header buffer's skb and let
 			 * it rip.
 			 */
 			lbq_desc = ql_get_curr_lchunk(qdev, rx_ring);
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-				"Chaining page at offset = %d,"
-				"for %d bytes  to skb.\n",
-				lbq_desc->p.pg_chunk.offset, length);
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "Chaining page at offset = %d, for %d bytes  to skb.\n",
+				     lbq_desc->p.pg_chunk.offset, length);
 			skb_fill_page_desc(skb, 0, lbq_desc->p.pg_chunk.page,
 						lbq_desc->p.pg_chunk.offset,
 						length);
@@ -1821,8 +1834,8 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 			lbq_desc = ql_get_curr_lchunk(qdev, rx_ring);
 			skb = netdev_alloc_skb(qdev->ndev, length);
 			if (skb == NULL) {
-				QPRINTK(qdev, PROBE, DEBUG,
-					"No skb available, drop the packet.\n");
+				netif_printk(qdev, probe, KERN_DEBUG, qdev->ndev,
+					     "No skb available, drop the packet.\n");
 				return NULL;
 			}
 			pci_unmap_page(qdev->pdev,
@@ -1831,8 +1844,9 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 				       pci_unmap_len(lbq_desc, maplen),
 				       PCI_DMA_FROMDEVICE);
 			skb_reserve(skb, NET_IP_ALIGN);
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-				"%d bytes of headers and data in large. Chain page to new skb and pull tail.\n", length);
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "%d bytes of headers and data in large. Chain page to new skb and pull tail.\n",
+				     length);
 			skb_fill_page_desc(skb, 0,
 						lbq_desc->p.pg_chunk.page,
 						lbq_desc->p.pg_chunk.offset,
@@ -1873,8 +1887,9 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 			 * a local buffer and use it to find the
 			 * pages to chain.
 			 */
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-				"%d bytes of headers & data in chain of large.\n", length);
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "%d bytes of headers & data in chain of large.\n",
+				     length);
 			skb = sbq_desc->p.skb;
 			sbq_desc->p.skb = NULL;
 			skb_reserve(skb, NET_IP_ALIGN);
@@ -1884,9 +1899,9 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 			size = (length < rx_ring->lbq_buf_size) ? length :
 				rx_ring->lbq_buf_size;
 
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-				"Adding page %d to skb for %d bytes.\n",
-				i, size);
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "Adding page %d to skb for %d bytes.\n",
+				     i, size);
 			skb_fill_page_desc(skb, i,
 						lbq_desc->p.pg_chunk.page,
 						lbq_desc->p.pg_chunk.offset,
@@ -1916,16 +1931,16 @@ static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 
 	skb = ql_build_rx_skb(qdev, rx_ring, ib_mac_rsp);
 	if (unlikely(!skb)) {
-		QPRINTK(qdev, RX_STATUS, DEBUG,
-			"No skb available, drop packet.\n");
+		netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+			     "No skb available, drop packet.\n");
 		rx_ring->rx_dropped++;
 		return;
 	}
 
 	/* Frame error, so drop the packet. */
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
-		QPRINTK(qdev, DRV, ERR, "Receive error, flags2 = 0x%x\n",
-					ib_mac_rsp->flags2);
+		netif_err(qdev, drv, qdev->ndev,
+			  "Receive error, flags2 = 0x%x\n", ib_mac_rsp->flags2);
 		dev_kfree_skb_any(skb);
 		rx_ring->rx_errors++;
 		return;
@@ -1950,17 +1965,18 @@ static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 	prefetch(skb->data);
 	skb->dev = ndev;
 	if (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) {
-		QPRINTK(qdev, RX_STATUS, DEBUG, "%s%s%s Multicast.\n",
-			(ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
-			IB_MAC_IOCB_RSP_M_HASH ? "Hash" : "",
-			(ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
-			IB_MAC_IOCB_RSP_M_REG ? "Registered" : "",
-			(ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
-			IB_MAC_IOCB_RSP_M_PROM ? "Promiscuous" : "");
+		netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev, "%s Multicast.\n",
+			     (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
+			     IB_MAC_IOCB_RSP_M_HASH ? "Hash" :
+			     (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
+			     IB_MAC_IOCB_RSP_M_REG ? "Registered" :
+			     (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
+			     IB_MAC_IOCB_RSP_M_PROM ? "Promiscuous" : "");
 		rx_ring->rx_multicast++;
 	}
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_P) {
-		QPRINTK(qdev, RX_STATUS, DEBUG, "Promiscuous Packet.\n");
+		netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+			     "Promiscuous Packet.\n");
 	}
 
 	skb->protocol = eth_type_trans(skb, ndev);
@@ -1973,8 +1989,8 @@ static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 		!(ib_mac_rsp->flags1 & IB_MAC_CSUM_ERR_MASK)) {
 		/* TCP frame. */
 		if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_T) {
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-					"TCP checksum done!\n");
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "TCP checksum done!\n");
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		} else if ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_U) &&
 				(ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_V4)) {
@@ -1983,8 +1999,8 @@ static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 			if (!(iph->frag_off &
 				cpu_to_be16(IP_MF|IP_OFFSET))) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
-				QPRINTK(qdev, RX_STATUS, DEBUG,
-						"TCP checksum done!\n");
+				netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+					     "TCP checksum done!\n");
 			}
 		}
 	}
@@ -2054,8 +2070,9 @@ static unsigned long ql_process_mac_rx_intr(struct ql_adapter *qdev,
 
 		/* Free small buffer that holds the IAL */
 		lbq_desc = ql_get_curr_sbuf(rx_ring);
-		QPRINTK(qdev, RX_ERR, ERR, "Dropping frame, len %d > mtu %d\n",
-			length, qdev->ndev->mtu);
+		netif_err(qdev, rx_err, qdev->ndev,
+			  "Dropping frame, len %d > mtu %d\n",
+			  length, qdev->ndev->mtu);
 
 		/* Unwind the large buffers for this frame. */
 		while (length > 0) {
@@ -2090,20 +2107,20 @@ static void ql_process_mac_tx_intr(struct ql_adapter *qdev,
 					OB_MAC_IOCB_RSP_L |
 					OB_MAC_IOCB_RSP_P | OB_MAC_IOCB_RSP_B))) {
 		if (mac_rsp->flags1 & OB_MAC_IOCB_RSP_E) {
-			QPRINTK(qdev, TX_DONE, WARNING,
-				"Total descriptor length did not match transfer length.\n");
+			netif_warn(qdev, tx_done, qdev->ndev,
+				   "Total descriptor length did not match transfer length.\n");
 		}
 		if (mac_rsp->flags1 & OB_MAC_IOCB_RSP_S) {
-			QPRINTK(qdev, TX_DONE, WARNING,
-				"Frame too short to be legal, not sent.\n");
+			netif_warn(qdev, tx_done, qdev->ndev,
+				   "Frame too short to be valid, not sent.\n");
 		}
 		if (mac_rsp->flags1 & OB_MAC_IOCB_RSP_L) {
-			QPRINTK(qdev, TX_DONE, WARNING,
-				"Frame too long, but sent anyway.\n");
+			netif_warn(qdev, tx_done, qdev->ndev,
+				   "Frame too long, but sent anyway.\n");
 		}
 		if (mac_rsp->flags1 & OB_MAC_IOCB_RSP_B) {
-			QPRINTK(qdev, TX_DONE, WARNING,
-				"PCI backplane error. Frame not sent.\n");
+			netif_warn(qdev, tx_done, qdev->ndev,
+				   "PCI backplane error. Frame not sent.\n");
 		}
 	}
 	atomic_inc(&tx_ring->tx_count);
@@ -2133,33 +2150,35 @@ static void ql_process_chip_ae_intr(struct ql_adapter *qdev,
 {
 	switch (ib_ae_rsp->event) {
 	case MGMT_ERR_EVENT:
-		QPRINTK(qdev, RX_ERR, ERR,
-			"Management Processor Fatal Error.\n");
+		netif_err(qdev, rx_err, qdev->ndev,
+			  "Management Processor Fatal Error.\n");
 		ql_queue_fw_error(qdev);
 		return;
 
 	case CAM_LOOKUP_ERR_EVENT:
-		QPRINTK(qdev, LINK, ERR,
-			"Multiple CAM hits lookup occurred.\n");
-		QPRINTK(qdev, DRV, ERR, "This event shouldn't occur.\n");
+		netif_err(qdev, link, qdev->ndev,
+			  "Multiple CAM hits lookup occurred.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "This event shouldn't occur.\n");
 		ql_queue_asic_error(qdev);
 		return;
 
 	case SOFT_ECC_ERROR_EVENT:
-		QPRINTK(qdev, RX_ERR, ERR, "Soft ECC error detected.\n");
+		netif_err(qdev, rx_err, qdev->ndev,
+			  "Soft ECC error detected.\n");
 		ql_queue_asic_error(qdev);
 		break;
 
 	case PCI_ERR_ANON_BUF_RD:
-		QPRINTK(qdev, RX_ERR, ERR,
-			"PCI error occurred when reading anonymous buffers from rx_ring %d.\n",
-			ib_ae_rsp->q_id);
+		netif_err(qdev, rx_err, qdev->ndev,
+			  "PCI error occurred when reading anonymous buffers from rx_ring %d.\n",
+			  ib_ae_rsp->q_id);
 		ql_queue_asic_error(qdev);
 		break;
 
 	default:
-		QPRINTK(qdev, DRV, ERR, "Unexpected event %d.\n",
-			ib_ae_rsp->event);
+		netif_err(qdev, drv, qdev->ndev, "Unexpected event %d.\n",
+			  ib_ae_rsp->event);
 		ql_queue_asic_error(qdev);
 		break;
 	}
@@ -2176,9 +2195,9 @@ static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 	/* While there are entries in the completion queue. */
 	while (prod != rx_ring->cnsmr_idx) {
 
-		QPRINTK(qdev, RX_STATUS, DEBUG,
-			"cq_id = %d, prod = %d, cnsmr = %d.\n.", rx_ring->cq_id,
-			prod, rx_ring->cnsmr_idx);
+		netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+			     "cq_id = %d, prod = %d, cnsmr = %d.\n.",
+			     rx_ring->cq_id, prod, rx_ring->cnsmr_idx);
 
 		net_rsp = (struct ob_mac_iocb_rsp *)rx_ring->curr_entry;
 		rmb();
@@ -2189,9 +2208,9 @@ static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 			ql_process_mac_tx_intr(qdev, net_rsp);
 			break;
 		default:
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-				"Hit default case, not handled! dropping the packet, opcode = %x.\n",
-				net_rsp->opcode);
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "Hit default case, not handled! dropping the packet, opcode = %x.\n",
+				     net_rsp->opcode);
 		}
 		count++;
 		ql_update_cq(rx_ring);
@@ -2223,9 +2242,9 @@ static int ql_clean_inbound_rx_ring(struct rx_ring *rx_ring, int budget)
 	/* While there are entries in the completion queue. */
 	while (prod != rx_ring->cnsmr_idx) {
 
-		QPRINTK(qdev, RX_STATUS, DEBUG,
-			"cq_id = %d, prod = %d, cnsmr = %d.\n.", rx_ring->cq_id,
-			prod, rx_ring->cnsmr_idx);
+		netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+			     "cq_id = %d, prod = %d, cnsmr = %d.\n.",
+			     rx_ring->cq_id, prod, rx_ring->cnsmr_idx);
 
 		net_rsp = rx_ring->curr_entry;
 		rmb();
@@ -2241,11 +2260,10 @@ static int ql_clean_inbound_rx_ring(struct rx_ring *rx_ring, int budget)
 						net_rsp);
 			break;
 		default:
-			{
-				QPRINTK(qdev, RX_STATUS, DEBUG,
-					"Hit default case, not handled! dropping the packet, opcode = %x.\n",
-					net_rsp->opcode);
-			}
+			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+				     "Hit default case, not handled! dropping the packet, opcode = %x.\n",
+				     net_rsp->opcode);
+			break;
 		}
 		count++;
 		ql_update_cq(rx_ring);
@@ -2266,8 +2284,8 @@ static int ql_napi_poll_msix(struct napi_struct *napi, int budget)
 	int i, work_done = 0;
 	struct intr_context *ctx = &qdev->intr_context[rx_ring->cq_id];
 
-	QPRINTK(qdev, RX_STATUS, DEBUG, "Enter, NAPI POLL cq_id = %d.\n",
-		rx_ring->cq_id);
+	netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
+		     "Enter, NAPI POLL cq_id = %d.\n", rx_ring->cq_id);
 
 	/* Service the TX rings first.  They start
 	 * right after the RSS rings. */
@@ -2279,9 +2297,9 @@ static int ql_napi_poll_msix(struct napi_struct *napi, int budget)
 		if ((ctx->irq_mask & (1 << trx_ring->cq_id)) &&
 			(ql_read_sh_reg(trx_ring->prod_idx_sh_reg) !=
 					trx_ring->cnsmr_idx)) {
-			QPRINTK(qdev, INTR, DEBUG,
-				"%s: Servicing TX completion ring %d.\n",
-				__func__, trx_ring->cq_id);
+			netif_printk(qdev, intr, KERN_DEBUG, qdev->ndev,
+				     "%s: Servicing TX completion ring %d.\n",
+				     __func__, trx_ring->cq_id);
 			ql_clean_outbound_rx_ring(trx_ring);
 		}
 	}
@@ -2291,9 +2309,9 @@ static int ql_napi_poll_msix(struct napi_struct *napi, int budget)
 	 */
 	if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) !=
 					rx_ring->cnsmr_idx) {
-		QPRINTK(qdev, INTR, DEBUG,
-			"%s: Servicing RX completion ring %d.\n",
-			__func__, rx_ring->cq_id);
+		netif_printk(qdev, intr, KERN_DEBUG, qdev->ndev,
+			     "%s: Servicing RX completion ring %d.\n",
+			     __func__, rx_ring->cq_id);
 		work_done = ql_clean_inbound_rx_ring(rx_ring, budget);
 	}
 
@@ -2310,12 +2328,13 @@ static void qlge_vlan_rx_register(struct net_device *ndev, struct vlan_group *gr
 
 	qdev->vlgrp = grp;
 	if (grp) {
-		QPRINTK(qdev, IFUP, DEBUG, "Turning on VLAN in NIC_RCV_CFG.\n");
+		netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+			     "Turning on VLAN in NIC_RCV_CFG.\n");
 		ql_write32(qdev, NIC_RCV_CFG, NIC_RCV_CFG_VLAN_MASK |
 			   NIC_RCV_CFG_VLAN_MATCH_AND_NON);
 	} else {
-		QPRINTK(qdev, IFUP, DEBUG,
-			"Turning off VLAN in NIC_RCV_CFG.\n");
+		netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+			     "Turning off VLAN in NIC_RCV_CFG.\n");
 		ql_write32(qdev, NIC_RCV_CFG, NIC_RCV_CFG_VLAN_MASK);
 	}
 }
@@ -2331,7 +2350,8 @@ static void qlge_vlan_rx_add_vid(struct net_device *ndev, u16 vid)
 		return;
 	if (ql_set_mac_addr_reg
 	    (qdev, (u8 *) &enable_bit, MAC_ADDR_TYPE_VLAN, vid)) {
-		QPRINTK(qdev, IFUP, ERR, "Failed to init vlan address.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Failed to init vlan address.\n");
 	}
 	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 }
@@ -2348,7 +2368,8 @@ static void qlge_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 
 	if (ql_set_mac_addr_reg
 	    (qdev, (u8 *) &enable_bit, MAC_ADDR_TYPE_VLAN, vid)) {
-		QPRINTK(qdev, IFUP, ERR, "Failed to clear vlan address.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Failed to clear vlan address.\n");
 	}
 	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 
@@ -2377,7 +2398,8 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 
 	spin_lock(&qdev->hw_lock);
 	if (atomic_read(&qdev->intr_context[0].irq_cnt)) {
-		QPRINTK(qdev, INTR, DEBUG, "Shared Interrupt, Not ours!\n");
+		netif_printk(qdev, intr, KERN_DEBUG, qdev->ndev,
+			     "Shared Interrupt, Not ours!\n");
 		spin_unlock(&qdev->hw_lock);
 		return IRQ_NONE;
 	}
@@ -2390,10 +2412,11 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	 */
 	if (var & STS_FE) {
 		ql_queue_asic_error(qdev);
-		QPRINTK(qdev, INTR, ERR, "Got fatal error, STS = %x.\n", var);
+		netif_err(qdev, intr, qdev->ndev,
+			  "Got fatal error, STS = %x.\n", var);
 		var = ql_read32(qdev, ERR_STS);
-		QPRINTK(qdev, INTR, ERR,
-			"Resetting chip. Error Status Register = 0x%x\n", var);
+		netif_err(qdev, intr, qdev->ndev,
+			  "Resetting chip. Error Status Register = 0x%x\n", var);
 		return IRQ_HANDLED;
 	}
 
@@ -2406,7 +2429,8 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 		 * We've got an async event or mailbox completion.
 		 * Handle it and clear the source of the interrupt.
 		 */
-		QPRINTK(qdev, INTR, ERR, "Got MPI processor interrupt.\n");
+		netif_err(qdev, intr, qdev->ndev,
+			  "Got MPI processor interrupt.\n");
 		ql_disable_completion_interrupt(qdev, intr_context->intr);
 		ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16));
 		queue_delayed_work_on(smp_processor_id(),
@@ -2421,8 +2445,8 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	 */
 	var = ql_read32(qdev, ISR1);
 	if (var & intr_context->irq_mask) {
-		QPRINTK(qdev, INTR, INFO,
-			"Waking handler for rx_ring[0].\n");
+		netif_info(qdev, intr, qdev->ndev,
+			   "Waking handler for rx_ring[0].\n");
 		ql_disable_completion_interrupt(qdev, intr_context->intr);
 		napi_schedule(&rx_ring->napi);
 		work_done++;
@@ -2519,9 +2543,9 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 		return NETDEV_TX_OK;
 
 	if (unlikely(atomic_read(&tx_ring->tx_count) < 2)) {
-		QPRINTK(qdev, TX_QUEUED, INFO,
-			"%s: shutting down tx queue %d du to lack of resources.\n",
-			__func__, tx_ring_idx);
+		netif_info(qdev, tx_queued, qdev->ndev,
+			   "%s: shutting down tx queue %d du to lack of resources.\n",
+			   __func__, tx_ring_idx);
 		netif_stop_subqueue(ndev, tx_ring->wq_id);
 		atomic_inc(&tx_ring->queue_stopped);
 		tx_ring->tx_errors++;
@@ -2542,8 +2566,8 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 	mac_iocb_ptr->frame_len = cpu_to_le16((u16) skb->len);
 
 	if (qdev->vlgrp && vlan_tx_tag_present(skb)) {
-		QPRINTK(qdev, TX_QUEUED, DEBUG, "Adding a vlan tag %d.\n",
-			vlan_tx_tag_get(skb));
+		netif_printk(qdev, tx_queued, KERN_DEBUG, qdev->ndev,
+			     "Adding a vlan tag %d.\n", vlan_tx_tag_get(skb));
 		mac_iocb_ptr->flags3 |= OB_MAC_IOCB_V;
 		mac_iocb_ptr->vlan_tci = cpu_to_le16(vlan_tx_tag_get(skb));
 	}
@@ -2557,8 +2581,8 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 	}
 	if (ql_map_send(qdev, mac_iocb_ptr, skb, tx_ring_desc) !=
 			NETDEV_TX_OK) {
-		QPRINTK(qdev, TX_QUEUED, ERR,
-				"Could not map the segments.\n");
+		netif_err(qdev, tx_queued, qdev->ndev,
+			  "Could not map the segments.\n");
 		tx_ring->tx_errors++;
 		return NETDEV_TX_BUSY;
 	}
@@ -2569,8 +2593,9 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 	wmb();
 
 	ql_write_db_reg(tx_ring->prod_idx, tx_ring->prod_idx_db_reg);
-	QPRINTK(qdev, TX_QUEUED, DEBUG, "tx queued, slot %d, len %d\n",
-		tx_ring->prod_idx, skb->len);
+	netif_printk(qdev, tx_queued, KERN_DEBUG, qdev->ndev,
+		     "tx queued, slot %d, len %d\n",
+		     tx_ring->prod_idx, skb->len);
 
 	atomic_dec(&tx_ring->tx_count);
 	return NETDEV_TX_OK;
@@ -2601,8 +2626,8 @@ static int ql_alloc_shadow_space(struct ql_adapter *qdev)
 	    pci_alloc_consistent(qdev->pdev,
 				 PAGE_SIZE, &qdev->rx_ring_shadow_reg_dma);
 	if (qdev->rx_ring_shadow_reg_area == NULL) {
-		QPRINTK(qdev, IFUP, ERR,
-			"Allocation of RX shadow space failed.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Allocation of RX shadow space failed.\n");
 		return -ENOMEM;
 	}
 	memset(qdev->rx_ring_shadow_reg_area, 0, PAGE_SIZE);
@@ -2610,8 +2635,8 @@ static int ql_alloc_shadow_space(struct ql_adapter *qdev)
 	    pci_alloc_consistent(qdev->pdev, PAGE_SIZE,
 				 &qdev->tx_ring_shadow_reg_dma);
 	if (qdev->tx_ring_shadow_reg_area == NULL) {
-		QPRINTK(qdev, IFUP, ERR,
-			"Allocation of TX shadow space failed.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Allocation of TX shadow space failed.\n");
 		goto err_wqp_sh_area;
 	}
 	memset(qdev->tx_ring_shadow_reg_area, 0, PAGE_SIZE);
@@ -2665,7 +2690,7 @@ static int ql_alloc_tx_resources(struct ql_adapter *qdev,
 
 	if ((tx_ring->wq_base == NULL) ||
 	    tx_ring->wq_base_dma & WQ_ADDR_ALIGN) {
-		QPRINTK(qdev, IFUP, ERR, "tx_ring alloc failed.\n");
+		netif_err(qdev, ifup, qdev->ndev, "tx_ring alloc failed.\n");
 		return -ENOMEM;
 	}
 	tx_ring->q =
@@ -2716,7 +2741,8 @@ static void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring
 	for (i = 0; i < rx_ring->sbq_len; i++) {
 		sbq_desc = &rx_ring->sbq[i];
 		if (sbq_desc == NULL) {
-			QPRINTK(qdev, IFUP, ERR, "sbq_desc %d is NULL.\n", i);
+			netif_err(qdev, ifup, qdev->ndev,
+				  "sbq_desc %d is NULL.\n", i);
 			return;
 		}
 		if (sbq_desc->p.skb) {
@@ -2843,7 +2869,7 @@ static int ql_alloc_rx_resources(struct ql_adapter *qdev,
 				 &rx_ring->cq_base_dma);
 
 	if (rx_ring->cq_base == NULL) {
-		QPRINTK(qdev, IFUP, ERR, "rx_ring alloc failed.\n");
+		netif_err(qdev, ifup, qdev->ndev, "rx_ring alloc failed.\n");
 		return -ENOMEM;
 	}
 
@@ -2856,8 +2882,8 @@ static int ql_alloc_rx_resources(struct ql_adapter *qdev,
 					 &rx_ring->sbq_base_dma);
 
 		if (rx_ring->sbq_base == NULL) {
-			QPRINTK(qdev, IFUP, ERR,
-				"Small buffer queue allocation failed.\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Small buffer queue allocation failed.\n");
 			goto err_mem;
 		}
 
@@ -2868,8 +2894,8 @@ static int ql_alloc_rx_resources(struct ql_adapter *qdev,
 		    kmalloc(rx_ring->sbq_len * sizeof(struct bq_desc),
 			    GFP_KERNEL);
 		if (rx_ring->sbq == NULL) {
-			QPRINTK(qdev, IFUP, ERR,
-				"Small buffer queue control block allocation failed.\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Small buffer queue control block allocation failed.\n");
 			goto err_mem;
 		}
 
@@ -2885,8 +2911,8 @@ static int ql_alloc_rx_resources(struct ql_adapter *qdev,
 					 &rx_ring->lbq_base_dma);
 
 		if (rx_ring->lbq_base == NULL) {
-			QPRINTK(qdev, IFUP, ERR,
-				"Large buffer queue allocation failed.\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Large buffer queue allocation failed.\n");
 			goto err_mem;
 		}
 		/*
@@ -2896,8 +2922,8 @@ static int ql_alloc_rx_resources(struct ql_adapter *qdev,
 		    kmalloc(rx_ring->lbq_len * sizeof(struct bq_desc),
 			    GFP_KERNEL);
 		if (rx_ring->lbq == NULL) {
-			QPRINTK(qdev, IFUP, ERR,
-				"Large buffer queue control block allocation failed.\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Large buffer queue control block allocation failed.\n");
 			goto err_mem;
 		}
 
@@ -2926,10 +2952,10 @@ static void ql_tx_ring_clean(struct ql_adapter *qdev)
 		for (i = 0; i < tx_ring->wq_len; i++) {
 			tx_ring_desc = &tx_ring->q[i];
 			if (tx_ring_desc && tx_ring_desc->skb) {
-				QPRINTK(qdev, IFDOWN, ERR,
-				"Freeing lost SKB %p, from queue %d, index %d.\n",
-					tx_ring_desc->skb, j,
-					tx_ring_desc->index);
+				netif_err(qdev, ifdown, qdev->ndev,
+					  "Freeing lost SKB %p, from queue %d, index %d.\n",
+					  tx_ring_desc->skb, j,
+					  tx_ring_desc->index);
 				ql_unmap_send(qdev, tx_ring_desc,
 					      tx_ring_desc->map_cnt);
 				dev_kfree_skb(tx_ring_desc->skb);
@@ -2960,16 +2986,16 @@ static int ql_alloc_mem_resources(struct ql_adapter *qdev)
 
 	for (i = 0; i < qdev->rx_ring_count; i++) {
 		if (ql_alloc_rx_resources(qdev, &qdev->rx_ring[i]) != 0) {
-			QPRINTK(qdev, IFUP, ERR,
-				"RX resource allocation failed.\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "RX resource allocation failed.\n");
 			goto err_mem;
 		}
 	}
 	/* Allocate tx queue resources */
 	for (i = 0; i < qdev->tx_ring_count; i++) {
 		if (ql_alloc_tx_resources(qdev, &qdev->tx_ring[i]) != 0) {
-			QPRINTK(qdev, IFUP, ERR,
-				"TX resource allocation failed.\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "TX resource allocation failed.\n");
 			goto err_mem;
 		}
 	}
@@ -3104,14 +3130,15 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		cqicb->pkt_delay = cpu_to_le16(qdev->rx_max_coalesced_frames);
 		break;
 	default:
-		QPRINTK(qdev, IFUP, DEBUG, "Invalid rx_ring->type = %d.\n",
-			rx_ring->type);
+		netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+			     "Invalid rx_ring->type = %d.\n", rx_ring->type);
 	}
-	QPRINTK(qdev, IFUP, DEBUG, "Initializing rx work queue.\n");
+	netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+		     "Initializing rx work queue.\n");
 	err = ql_write_cfg(qdev, cqicb, sizeof(struct cqicb),
 			   CFG_LCQ, rx_ring->cq_id);
 	if (err) {
-		QPRINTK(qdev, IFUP, ERR, "Failed to load CQICB.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Failed to load CQICB.\n");
 		return err;
 	}
 	return err;
@@ -3157,10 +3184,11 @@ static int ql_start_tx_ring(struct ql_adapter *qdev, struct tx_ring *tx_ring)
 	err = ql_write_cfg(qdev, wqicb, sizeof(*wqicb), CFG_LRQ,
 			   (u16) tx_ring->wq_id);
 	if (err) {
-		QPRINTK(qdev, IFUP, ERR, "Failed to load tx_ring.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Failed to load tx_ring.\n");
 		return err;
 	}
-	QPRINTK(qdev, IFUP, DEBUG, "Successfully loaded WQICB.\n");
+	netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+		     "Successfully loaded WQICB.\n");
 	return err;
 }
 
@@ -3214,15 +3242,15 @@ static void ql_enable_msix(struct ql_adapter *qdev)
 		if (err < 0) {
 			kfree(qdev->msi_x_entry);
 			qdev->msi_x_entry = NULL;
-			QPRINTK(qdev, IFUP, WARNING,
-				"MSI-X Enable failed, trying MSI.\n");
+			netif_warn(qdev, ifup, qdev->ndev,
+				   "MSI-X Enable failed, trying MSI.\n");
 			qdev->intr_count = 1;
 			qlge_irq_type = MSI_IRQ;
 		} else if (err == 0) {
 			set_bit(QL_MSIX_ENABLED, &qdev->flags);
-			QPRINTK(qdev, IFUP, INFO,
-				"MSI-X Enabled, got %d vectors.\n",
-				qdev->intr_count);
+			netif_info(qdev, ifup, qdev->ndev,
+				   "MSI-X Enabled, got %d vectors.\n",
+				   qdev->intr_count);
 			return;
 		}
 	}
@@ -3231,13 +3259,14 @@ msi:
 	if (qlge_irq_type == MSI_IRQ) {
 		if (!pci_enable_msi(qdev->pdev)) {
 			set_bit(QL_MSI_ENABLED, &qdev->flags);
-			QPRINTK(qdev, IFUP, INFO,
-				"Running with MSI interrupts.\n");
+			netif_info(qdev, ifup, qdev->ndev,
+				   "Running with MSI interrupts.\n");
 			return;
 		}
 	}
 	qlge_irq_type = LEG_IRQ;
-	QPRINTK(qdev, IFUP, DEBUG, "Running with legacy interrupts.\n");
+	netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+		     "Running with legacy interrupts.\n");
 }
 
 /* Each vector services 1 RSS ring and and 1 or more
@@ -3409,12 +3438,12 @@ static void ql_free_irq(struct ql_adapter *qdev)
 			if (test_bit(QL_MSIX_ENABLED, &qdev->flags)) {
 				free_irq(qdev->msi_x_entry[i].vector,
 					 &qdev->rx_ring[i]);
-				QPRINTK(qdev, IFDOWN, DEBUG,
-					"freeing msix interrupt %d.\n", i);
+				netif_printk(qdev, ifdown, KERN_DEBUG, qdev->ndev,
+					     "freeing msix interrupt %d.\n", i);
 			} else {
 				free_irq(qdev->pdev->irq, &qdev->rx_ring[0]);
-				QPRINTK(qdev, IFDOWN, DEBUG,
-					"freeing msi interrupt %d.\n", i);
+				netif_printk(qdev, ifdown, KERN_DEBUG, qdev->ndev,
+					     "freeing msi interrupt %d.\n", i);
 			}
 		}
 	}
@@ -3439,32 +3468,33 @@ static int ql_request_irq(struct ql_adapter *qdev)
 					     intr_context->name,
 					     &qdev->rx_ring[i]);
 			if (status) {
-				QPRINTK(qdev, IFUP, ERR,
-					"Failed request for MSIX interrupt %d.\n",
-					i);
+				netif_err(qdev, ifup, qdev->ndev,
+					  "Failed request for MSIX interrupt %d.\n",
+					  i);
 				goto err_irq;
 			} else {
-				QPRINTK(qdev, IFUP, DEBUG,
-					"Hooked intr %d, queue type %s%s%s, with name %s.\n",
-					i,
-					qdev->rx_ring[i].type ==
-					DEFAULT_Q ? "DEFAULT_Q" : "",
-					qdev->rx_ring[i].type ==
-					TX_Q ? "TX_Q" : "",
-					qdev->rx_ring[i].type ==
-					RX_Q ? "RX_Q" : "", intr_context->name);
+				netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+					     "Hooked intr %d, queue type %s, with name %s.\n",
+					     i,
+					     qdev->rx_ring[i].type == DEFAULT_Q ?
+					     "DEFAULT_Q" :
+					     qdev->rx_ring[i].type == TX_Q ?
+					     "TX_Q" :
+					     qdev->rx_ring[i].type == RX_Q ?
+					     "RX_Q" : "",
+					     intr_context->name);
 			}
 		} else {
-			QPRINTK(qdev, IFUP, DEBUG,
-				"trying msi or legacy interrupts.\n");
-			QPRINTK(qdev, IFUP, DEBUG,
-				"%s: irq = %d.\n", __func__, pdev->irq);
-			QPRINTK(qdev, IFUP, DEBUG,
-				"%s: context->name = %s.\n", __func__,
-			       intr_context->name);
-			QPRINTK(qdev, IFUP, DEBUG,
-				"%s: dev_id = 0x%p.\n", __func__,
-			       &qdev->rx_ring[0]);
+			netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+				     "trying msi or legacy interrupts.\n");
+			netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+				     "%s: irq = %d.\n", __func__, pdev->irq);
+			netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+				     "%s: context->name = %s.\n", __func__,
+				     intr_context->name);
+			netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+				     "%s: dev_id = 0x%p.\n", __func__,
+				     &qdev->rx_ring[0]);
 			status =
 			    request_irq(pdev->irq, qlge_isr,
 					test_bit(QL_MSI_ENABLED,
@@ -3474,20 +3504,20 @@ static int ql_request_irq(struct ql_adapter *qdev)
 			if (status)
 				goto err_irq;
 
-			QPRINTK(qdev, IFUP, ERR,
-				"Hooked intr %d, queue type %s%s%s, with name %s.\n",
-				i,
-				qdev->rx_ring[0].type ==
-				DEFAULT_Q ? "DEFAULT_Q" : "",
-				qdev->rx_ring[0].type == TX_Q ? "TX_Q" : "",
-				qdev->rx_ring[0].type == RX_Q ? "RX_Q" : "",
-				intr_context->name);
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Hooked intr %d, queue type %s, with name %s.\n",
+				  i,
+				  qdev->rx_ring[0].type == DEFAULT_Q ?
+				  "DEFAULT_Q" :
+				  qdev->rx_ring[0].type == TX_Q ? "TX_Q" :
+				  qdev->rx_ring[0].type == RX_Q ? "RX_Q" : "",
+				  intr_context->name);
 		}
 		intr_context->hooked = 1;
 	}
 	return status;
 err_irq:
-	QPRINTK(qdev, IFUP, ERR, "Failed to get the interrupts!!!/n");
+	netif_err(qdev, ifup, qdev->ndev, "Failed to get the interrupts!!!/n");
 	ql_free_irq(qdev);
 	return status;
 }
@@ -3521,14 +3551,15 @@ static int ql_start_rss(struct ql_adapter *qdev)
 	memcpy((void *)&ricb->ipv6_hash_key[0], init_hash_seed, 40);
 	memcpy((void *)&ricb->ipv4_hash_key[0], init_hash_seed, 16);
 
-	QPRINTK(qdev, IFUP, DEBUG, "Initializing RSS.\n");
+	netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev, "Initializing RSS.\n");
 
 	status = ql_write_cfg(qdev, ricb, sizeof(*ricb), CFG_LR, 0);
 	if (status) {
-		QPRINTK(qdev, IFUP, ERR, "Failed to load RICB.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Failed to load RICB.\n");
 		return status;
 	}
-	QPRINTK(qdev, IFUP, DEBUG, "Successfully loaded RICB.\n");
+	netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+		     "Successfully loaded RICB.\n");
 	return status;
 }
 
@@ -3543,9 +3574,8 @@ static int ql_clear_routing_entries(struct ql_adapter *qdev)
 	for (i = 0; i < 16; i++) {
 		status = ql_set_routing_reg(qdev, i, 0, 0);
 		if (status) {
-			QPRINTK(qdev, IFUP, ERR,
-				"Failed to init routing register for CAM "
-				"packets.\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Failed to init routing register for CAM packets.\n");
 			break;
 		}
 	}
@@ -3569,14 +3599,14 @@ static int ql_route_initialize(struct ql_adapter *qdev)
 
 	status = ql_set_routing_reg(qdev, RT_IDX_ALL_ERR_SLOT, RT_IDX_ERR, 1);
 	if (status) {
-		QPRINTK(qdev, IFUP, ERR,
-			"Failed to init routing register for error packets.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Failed to init routing register for error packets.\n");
 		goto exit;
 	}
 	status = ql_set_routing_reg(qdev, RT_IDX_BCAST_SLOT, RT_IDX_BCAST, 1);
 	if (status) {
-		QPRINTK(qdev, IFUP, ERR,
-			"Failed to init routing register for broadcast packets.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Failed to init routing register for broadcast packets.\n");
 		goto exit;
 	}
 	/* If we have more than one inbound queue, then turn on RSS in the
@@ -3586,8 +3616,8 @@ static int ql_route_initialize(struct ql_adapter *qdev)
 		status = ql_set_routing_reg(qdev, RT_IDX_RSS_MATCH_SLOT,
 					RT_IDX_RSS_MATCH, 1);
 		if (status) {
-			QPRINTK(qdev, IFUP, ERR,
-				"Failed to init routing register for MATCH RSS packets.\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Failed to init routing register for MATCH RSS packets.\n");
 			goto exit;
 		}
 	}
@@ -3595,8 +3625,8 @@ static int ql_route_initialize(struct ql_adapter *qdev)
 	status = ql_set_routing_reg(qdev, RT_IDX_CAM_HIT_SLOT,
 				    RT_IDX_CAM_HIT, 1);
 	if (status)
-		QPRINTK(qdev, IFUP, ERR,
-			"Failed to init routing register for CAM packets.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Failed to init routing register for CAM packets.\n");
 exit:
 	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
 	return status;
@@ -3614,13 +3644,13 @@ int ql_cam_route_initialize(struct ql_adapter *qdev)
 	set &= qdev->port_link_up;
 	status = ql_set_mac_addr(qdev, set);
 	if (status) {
-		QPRINTK(qdev, IFUP, ERR, "Failed to init mac address.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Failed to init mac address.\n");
 		return status;
 	}
 
 	status = ql_route_initialize(qdev);
 	if (status)
-		QPRINTK(qdev, IFUP, ERR, "Failed to init routing table.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Failed to init routing table.\n");
 
 	return status;
 }
@@ -3685,8 +3715,8 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 	for (i = 0; i < qdev->rx_ring_count; i++) {
 		status = ql_start_rx_ring(qdev, &qdev->rx_ring[i]);
 		if (status) {
-			QPRINTK(qdev, IFUP, ERR,
-				"Failed to start rx ring[%d].\n", i);
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Failed to start rx ring[%d].\n", i);
 			return status;
 		}
 	}
@@ -3697,7 +3727,7 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 	if (qdev->rss_ring_count > 1) {
 		status = ql_start_rss(qdev);
 		if (status) {
-			QPRINTK(qdev, IFUP, ERR, "Failed to start RSS.\n");
+			netif_err(qdev, ifup, qdev->ndev, "Failed to start RSS.\n");
 			return status;
 		}
 	}
@@ -3706,8 +3736,8 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 	for (i = 0; i < qdev->tx_ring_count; i++) {
 		status = ql_start_tx_ring(qdev, &qdev->tx_ring[i]);
 		if (status) {
-			QPRINTK(qdev, IFUP, ERR,
-				"Failed to start tx ring[%d].\n", i);
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Failed to start tx ring[%d].\n", i);
 			return status;
 		}
 	}
@@ -3715,20 +3745,20 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 	/* Initialize the port and set the max framesize. */
 	status = qdev->nic_ops->port_initialize(qdev);
 	if (status)
-		QPRINTK(qdev, IFUP, ERR, "Failed to start port.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Failed to start port.\n");
 
 	/* Set up the MAC address and frame routing filter. */
 	status = ql_cam_route_initialize(qdev);
 	if (status) {
-		QPRINTK(qdev, IFUP, ERR,
-				"Failed to init CAM/Routing tables.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Failed to init CAM/Routing tables.\n");
 		return status;
 	}
 
 	/* Start NAPI for the RSS queues. */
 	for (i = 0; i < qdev->rss_ring_count; i++) {
-		QPRINTK(qdev, IFUP, DEBUG, "Enabling NAPI for rx_ring[%d].\n",
-			i);
+		netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+			     "Enabling NAPI for rx_ring[%d].\n", i);
 		napi_enable(&qdev->rx_ring[i].napi);
 	}
 
@@ -3745,7 +3775,7 @@ static int ql_adapter_reset(struct ql_adapter *qdev)
 	/* Clear all the entries in the routing table. */
 	status = ql_clear_routing_entries(qdev);
 	if (status) {
-		QPRINTK(qdev, IFUP, ERR, "Failed to clear routing bits.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Failed to clear routing bits.\n");
 		return status;
 	}
 
@@ -3768,8 +3798,8 @@ static int ql_adapter_reset(struct ql_adapter *qdev)
 	} while (time_before(jiffies, end_jiffies));
 
 	if (value & RST_FO_FR) {
-		QPRINTK(qdev, IFDOWN, ERR,
-			"ETIMEDOUT!!! errored out of resetting the chip!\n");
+		netif_err(qdev, ifdown, qdev->ndev,
+			  "ETIMEDOUT!!! errored out of resetting the chip!\n");
 		status = -ETIMEDOUT;
 	}
 
@@ -3782,16 +3812,17 @@ static void ql_display_dev_info(struct net_device *ndev)
 {
 	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
 
-	QPRINTK(qdev, PROBE, INFO,
-		"Function #%d, Port %d, NIC Roll %d, NIC Rev = %d, "
-		"XG Roll = %d, XG Rev = %d.\n",
-		qdev->func,
-		qdev->port,
-		qdev->chip_rev_id & 0x0000000f,
-		qdev->chip_rev_id >> 4 & 0x0000000f,
-		qdev->chip_rev_id >> 8 & 0x0000000f,
-		qdev->chip_rev_id >> 12 & 0x0000000f);
-	QPRINTK(qdev, PROBE, INFO, "MAC address %pM\n", ndev->dev_addr);
+	netif_info(qdev, probe, qdev->ndev,
+		   "Function #%d, Port %d, NIC Roll %d, NIC Rev = %d, "
+		   "XG Roll = %d, XG Rev = %d.\n",
+		   qdev->func,
+		   qdev->port,
+		   qdev->chip_rev_id & 0x0000000f,
+		   qdev->chip_rev_id >> 4 & 0x0000000f,
+		   qdev->chip_rev_id >> 8 & 0x0000000f,
+		   qdev->chip_rev_id >> 12 & 0x0000000f);
+	netif_info(qdev, probe, qdev->ndev,
+		   "MAC address %pM\n", ndev->dev_addr);
 }
 
 int ql_wol(struct ql_adapter *qdev)
@@ -3808,23 +3839,23 @@ int ql_wol(struct ql_adapter *qdev)
 
 	if (qdev->wol & (WAKE_ARP | WAKE_MAGICSECURE | WAKE_PHY | WAKE_UCAST |
 			WAKE_MCAST | WAKE_BCAST)) {
-		QPRINTK(qdev, IFDOWN, ERR,
-			"Unsupported WOL paramter. qdev->wol = 0x%x.\n",
-			qdev->wol);
+		netif_err(qdev, ifdown, qdev->ndev,
+			  "Unsupported WOL paramter. qdev->wol = 0x%x.\n",
+			  qdev->wol);
 		return -EINVAL;
 	}
 
 	if (qdev->wol & WAKE_MAGIC) {
 		status = ql_mb_wol_set_magic(qdev, 1);
 		if (status) {
-			QPRINTK(qdev, IFDOWN, ERR,
-				"Failed to set magic packet on %s.\n",
-				qdev->ndev->name);
+			netif_err(qdev, ifdown, qdev->ndev,
+				  "Failed to set magic packet on %s.\n",
+				  qdev->ndev->name);
 			return status;
 		} else
-			QPRINTK(qdev, DRV, INFO,
-				"Enabled magic packet successfully on %s.\n",
-				qdev->ndev->name);
+			netif_info(qdev, drv, qdev->ndev,
+				   "Enabled magic packet successfully on %s.\n",
+				   qdev->ndev->name);
 
 		wol |= MB_WOL_MAGIC_PKT;
 	}
@@ -3832,9 +3863,10 @@ int ql_wol(struct ql_adapter *qdev)
 	if (qdev->wol) {
 		wol |= MB_WOL_MODE_ON;
 		status = ql_mb_wol_mode(qdev, wol);
-		QPRINTK(qdev, DRV, ERR, "WOL %s (wol code 0x%x) on %s\n",
-			(status == 0) ? "Sucessfully set" : "Failed", wol,
-			qdev->ndev->name);
+		netif_err(qdev, drv, qdev->ndev,
+			  "WOL %s (wol code 0x%x) on %s\n",
+			  (status == 0) ? "Sucessfully set" : "Failed",
+			  wol, qdev->ndev->name);
 	}
 
 	return status;
@@ -3875,8 +3907,8 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 
 	status = ql_adapter_reset(qdev);
 	if (status)
-		QPRINTK(qdev, IFDOWN, ERR, "reset(func #%d) FAILED!\n",
-			qdev->func);
+		netif_err(qdev, ifdown, qdev->ndev, "reset(func #%d) FAILED!\n",
+			  qdev->func);
 	return status;
 }
 
@@ -3886,7 +3918,7 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 
 	err = ql_adapter_initialize(qdev);
 	if (err) {
-		QPRINTK(qdev, IFUP, INFO, "Unable to initialize adapter.\n");
+		netif_info(qdev, ifup, qdev->ndev, "Unable to initialize adapter.\n");
 		goto err_init;
 	}
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
@@ -3918,7 +3950,7 @@ static int ql_get_adapter_resources(struct ql_adapter *qdev)
 	int status = 0;
 
 	if (ql_alloc_mem_resources(qdev)) {
-		QPRINTK(qdev, IFUP, ERR, "Unable to  allocate memory.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Unable to  allocate memory.\n");
 		return -ENOMEM;
 	}
 	status = ql_request_irq(qdev);
@@ -3934,7 +3966,7 @@ static int qlge_close(struct net_device *ndev)
 	 * brought the adapter down.
 	 */
 	if (test_bit(QL_EEH_FATAL, &qdev->flags)) {
-		QPRINTK(qdev, DRV, ERR, "EEH fatal did unload.\n");
+		netif_err(qdev, drv, qdev->ndev, "EEH fatal did unload.\n");
 		clear_bit(QL_EEH_FATAL, &qdev->flags);
 		return 0;
 	}
@@ -4008,9 +4040,10 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 			rx_ring->lbq_size =
 			    rx_ring->lbq_len * sizeof(__le64);
 			rx_ring->lbq_buf_size = (u16)lbq_buf_len;
-			QPRINTK(qdev, IFUP, DEBUG,
-				"lbq_buf_size %d, order = %d\n",
-				rx_ring->lbq_buf_size, qdev->lbq_buf_order);
+			netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+				     "lbq_buf_size %d, order = %d\n",
+				     rx_ring->lbq_buf_size,
+				     qdev->lbq_buf_order);
 			rx_ring->sbq_len = NUM_SMALL_BUFFERS;
 			rx_ring->sbq_size =
 			    rx_ring->sbq_len * sizeof(__le64);
@@ -4074,14 +4107,14 @@ static int ql_change_rx_buffers(struct ql_adapter *qdev)
 	if (!test_bit(QL_ADAPTER_UP, &qdev->flags)) {
 		int i = 3;
 		while (i-- && !test_bit(QL_ADAPTER_UP, &qdev->flags)) {
-			QPRINTK(qdev, IFUP, ERR,
-				 "Waiting for adapter UP...\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Waiting for adapter UP...\n");
 			ssleep(1);
 		}
 
 		if (!i) {
-			QPRINTK(qdev, IFUP, ERR,
-			 "Timed out waiting for adapter UP\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Timed out waiting for adapter UP\n");
 			return -ETIMEDOUT;
 		}
 	}
@@ -4107,8 +4140,8 @@ static int ql_change_rx_buffers(struct ql_adapter *qdev)
 
 	return status;
 error:
-	QPRINTK(qdev, IFUP, ALERT,
-		"Driver up/down cycle failed, closing device.\n");
+	netif_alert(qdev, ifup, qdev->ndev,
+		    "Driver up/down cycle failed, closing device.\n");
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
 	dev_close(qdev->ndev);
 	return status;
@@ -4120,9 +4153,9 @@ static int qlge_change_mtu(struct net_device *ndev, int new_mtu)
 	int status;
 
 	if (ndev->mtu == 1500 && new_mtu == 9000) {
-		QPRINTK(qdev, IFUP, ERR, "Changing to jumbo MTU.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Changing to jumbo MTU.\n");
 	} else if (ndev->mtu == 9000 && new_mtu == 1500) {
-		QPRINTK(qdev, IFUP, ERR, "Changing to normal MTU.\n");
+		netif_err(qdev, ifup, qdev->ndev, "Changing to normal MTU.\n");
 	} else
 		return -EINVAL;
 
@@ -4137,8 +4170,8 @@ static int qlge_change_mtu(struct net_device *ndev, int new_mtu)
 
 	status = ql_change_rx_buffers(qdev);
 	if (status) {
-		QPRINTK(qdev, IFUP, ERR,
-			"Changing MTU failed.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Changing MTU failed.\n");
 	}
 
 	return status;
@@ -4198,8 +4231,8 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 		if (!test_bit(QL_PROMISCUOUS, &qdev->flags)) {
 			if (ql_set_routing_reg
 			    (qdev, RT_IDX_PROMISCUOUS_SLOT, RT_IDX_VALID, 1)) {
-				QPRINTK(qdev, HW, ERR,
-					"Failed to set promiscous mode.\n");
+				netif_err(qdev, hw, qdev->ndev,
+					  "Failed to set promiscous mode.\n");
 			} else {
 				set_bit(QL_PROMISCUOUS, &qdev->flags);
 			}
@@ -4208,8 +4241,8 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 		if (test_bit(QL_PROMISCUOUS, &qdev->flags)) {
 			if (ql_set_routing_reg
 			    (qdev, RT_IDX_PROMISCUOUS_SLOT, RT_IDX_VALID, 0)) {
-				QPRINTK(qdev, HW, ERR,
-					"Failed to clear promiscous mode.\n");
+				netif_err(qdev, hw, qdev->ndev,
+					  "Failed to clear promiscous mode.\n");
 			} else {
 				clear_bit(QL_PROMISCUOUS, &qdev->flags);
 			}
@@ -4225,8 +4258,8 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 		if (!test_bit(QL_ALLMULTI, &qdev->flags)) {
 			if (ql_set_routing_reg
 			    (qdev, RT_IDX_ALLMULTI_SLOT, RT_IDX_MCAST, 1)) {
-				QPRINTK(qdev, HW, ERR,
-					"Failed to set all-multi mode.\n");
+				netif_err(qdev, hw, qdev->ndev,
+					  "Failed to set all-multi mode.\n");
 			} else {
 				set_bit(QL_ALLMULTI, &qdev->flags);
 			}
@@ -4235,8 +4268,8 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 		if (test_bit(QL_ALLMULTI, &qdev->flags)) {
 			if (ql_set_routing_reg
 			    (qdev, RT_IDX_ALLMULTI_SLOT, RT_IDX_MCAST, 0)) {
-				QPRINTK(qdev, HW, ERR,
-					"Failed to clear all-multi mode.\n");
+				netif_err(qdev, hw, qdev->ndev,
+					  "Failed to clear all-multi mode.\n");
 			} else {
 				clear_bit(QL_ALLMULTI, &qdev->flags);
 			}
@@ -4251,16 +4284,16 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 		     i++, mc_ptr = mc_ptr->next)
 			if (ql_set_mac_addr_reg(qdev, (u8 *) mc_ptr->dmi_addr,
 						MAC_ADDR_TYPE_MULTI_MAC, i)) {
-				QPRINTK(qdev, HW, ERR,
-					"Failed to loadmulticast address.\n");
+				netif_err(qdev, hw, qdev->ndev,
+					  "Failed to loadmulticast address.\n");
 				ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 				goto exit;
 			}
 		ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 		if (ql_set_routing_reg
 		    (qdev, RT_IDX_MCAST_MATCH_SLOT, RT_IDX_MCAST_MATCH, 1)) {
-			QPRINTK(qdev, HW, ERR,
-				"Failed to set multicast match mode.\n");
+			netif_err(qdev, hw, qdev->ndev,
+				  "Failed to set multicast match mode.\n");
 		} else {
 			set_bit(QL_ALLMULTI, &qdev->flags);
 		}
@@ -4285,7 +4318,7 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
 	status = ql_set_mac_addr_reg(qdev, (u8 *) ndev->dev_addr,
 			MAC_ADDR_TYPE_CAM_MAC, qdev->func * MAX_CQ);
 	if (status)
-		QPRINTK(qdev, HW, ERR, "Failed to load MAC address.\n");
+		netif_err(qdev, hw, qdev->ndev, "Failed to load MAC address.\n");
 	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 	return status;
 }
@@ -4318,8 +4351,8 @@ static void ql_asic_reset_work(struct work_struct *work)
 	rtnl_unlock();
 	return;
 error:
-	QPRINTK(qdev, IFUP, ALERT,
-		"Driver up/down cycle failed, closing device\n");
+	netif_alert(qdev, ifup, qdev->ndev,
+		    "Driver up/down cycle failed, closing device\n");
 
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
 	dev_close(qdev->ndev);
@@ -4578,7 +4611,7 @@ static void ql_timer(unsigned long data)
 
 	var = ql_read32(qdev, STS);
 	if (pci_channel_offline(qdev->pdev)) {
-		QPRINTK(qdev, IFUP, ERR, "EEH STS = 0x%.08x.\n", var);
+		netif_err(qdev, ifup, qdev->ndev, "EEH STS = 0x%.08x.\n", var);
 		return;
 	}
 
@@ -4747,14 +4780,14 @@ static pci_ers_result_t qlge_io_slot_reset(struct pci_dev *pdev)
 
 	pci_restore_state(pdev);
 	if (pci_enable_device(pdev)) {
-		QPRINTK(qdev, IFUP, ERR,
-			"Cannot re-enable PCI device after reset.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
 
 	if (ql_adapter_reset(qdev)) {
-		QPRINTK(qdev, DRV, ERR, "reset FAILED!\n");
+		netif_err(qdev, drv, qdev->ndev, "reset FAILED!\n");
 		set_bit(QL_EEH_FATAL, &qdev->flags);
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
@@ -4771,13 +4804,13 @@ static void qlge_io_resume(struct pci_dev *pdev)
 	if (netif_running(ndev)) {
 		err = qlge_open(ndev);
 		if (err) {
-			QPRINTK(qdev, IFUP, ERR,
-				"Device initialization failed after reset.\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Device initialization failed after reset.\n");
 			return;
 		}
 	} else {
-		QPRINTK(qdev, IFUP, ERR,
-			"Device was not running prior to EEH.\n");
+		netif_err(qdev, ifup, qdev->ndev,
+			  "Device was not running prior to EEH.\n");
 	}
 	qdev->timer.expires = jiffies + (5*HZ);
 	add_timer(&qdev->timer);
@@ -4828,7 +4861,7 @@ static int qlge_resume(struct pci_dev *pdev)
 	pci_restore_state(pdev);
 	err = pci_enable_device(pdev);
 	if (err) {
-		QPRINTK(qdev, IFUP, ERR, "Cannot enable PCI device from suspend\n");
+		netif_err(qdev, ifup, qdev->ndev, "Cannot enable PCI device from suspend\n");
 		return err;
 	}
 	pci_set_master(pdev);
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index e2c846f..3c00462 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -135,7 +135,7 @@ static int ql_get_mb_sts(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		    ql_read_mpi_reg(qdev, qdev->mailbox_out + i,
 				     &mbcp->mbox_out[i]);
 		if (status) {
-			QPRINTK(qdev, DRV, ERR, "Failed mailbox read.\n");
+			netif_err(qdev, drv, qdev->ndev, "Failed mailbox read.\n");
 			break;
 		}
 	}
@@ -208,7 +208,7 @@ static int ql_idc_req_aen(struct ql_adapter *qdev)
 	int status;
 	struct mbox_params *mbcp = &qdev->idc_mbc;
 
-	QPRINTK(qdev, DRV, ERR, "Enter!\n");
+	netif_err(qdev, drv, qdev->ndev, "Enter!\n");
 	/* Get the status data and start up a thread to
 	 * handle the request.
 	 */
@@ -216,8 +216,8 @@ static int ql_idc_req_aen(struct ql_adapter *qdev)
 	mbcp->out_count = 4;
 	status = ql_get_mb_sts(qdev, mbcp);
 	if (status) {
-		QPRINTK(qdev, DRV, ERR,
-			"Could not read MPI, resetting ASIC!\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Could not read MPI, resetting ASIC!\n");
 		ql_queue_asic_error(qdev);
 	} else	{
 		/* Begin polled mode early so
@@ -240,8 +240,8 @@ static int ql_idc_cmplt_aen(struct ql_adapter *qdev)
 	mbcp->out_count = 4;
 	status = ql_get_mb_sts(qdev, mbcp);
 	if (status) {
-		QPRINTK(qdev, DRV, ERR,
-			"Could not read MPI, resetting RISC!\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Could not read MPI, resetting RISC!\n");
 		ql_queue_fw_error(qdev);
 	} else
 		/* Wake up the sleeping mpi_idc_work thread that is
@@ -259,13 +259,13 @@ static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 
 	status = ql_get_mb_sts(qdev, mbcp);
 	if (status) {
-		QPRINTK(qdev, DRV, ERR,
-			"%s: Could not get mailbox status.\n", __func__);
+		netif_err(qdev, drv, qdev->ndev,
+			  "%s: Could not get mailbox status.\n", __func__);
 		return;
 	}
 
 	qdev->link_status = mbcp->mbox_out[1];
-	QPRINTK(qdev, DRV, ERR, "Link Up.\n");
+	netif_err(qdev, drv, qdev->ndev, "Link Up.\n");
 
 	/* If we're coming back from an IDC event
 	 * then set up the CAM and frame routing.
@@ -273,8 +273,8 @@ static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	if (test_bit(QL_CAM_RT_SET, &qdev->flags)) {
 		status = ql_cam_route_initialize(qdev);
 		if (status) {
-			QPRINTK(qdev, IFUP, ERR,
-			"Failed to init CAM/Routing tables.\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Failed to init CAM/Routing tables.\n");
 			return;
 		} else
 			clear_bit(QL_CAM_RT_SET, &qdev->flags);
@@ -285,7 +285,7 @@ static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	 * to our liking.
 	 */
 	if (!test_bit(QL_PORT_CFG, &qdev->flags)) {
-		QPRINTK(qdev, DRV, ERR, "Queue Port Config Worker!\n");
+		netif_err(qdev, drv, qdev->ndev, "Queue Port Config Worker!\n");
 		set_bit(QL_PORT_CFG, &qdev->flags);
 		/* Begin polled mode early so
 		 * we don't get another interrupt
@@ -307,7 +307,7 @@ static void ql_link_down(struct ql_adapter *qdev, struct mbox_params *mbcp)
 
 	status = ql_get_mb_sts(qdev, mbcp);
 	if (status)
-		QPRINTK(qdev, DRV, ERR, "Link down AEN broken!\n");
+		netif_err(qdev, drv, qdev->ndev, "Link down AEN broken!\n");
 
 	ql_link_off(qdev);
 }
@@ -320,9 +320,9 @@ static int ql_sfp_in(struct ql_adapter *qdev, struct mbox_params *mbcp)
 
 	status = ql_get_mb_sts(qdev, mbcp);
 	if (status)
-		QPRINTK(qdev, DRV, ERR, "SFP in AEN broken!\n");
+		netif_err(qdev, drv, qdev->ndev, "SFP in AEN broken!\n");
 	else
-		QPRINTK(qdev, DRV, ERR, "SFP insertion detected.\n");
+		netif_err(qdev, drv, qdev->ndev, "SFP insertion detected.\n");
 
 	return status;
 }
@@ -335,9 +335,9 @@ static int ql_sfp_out(struct ql_adapter *qdev, struct mbox_params *mbcp)
 
 	status = ql_get_mb_sts(qdev, mbcp);
 	if (status)
-		QPRINTK(qdev, DRV, ERR, "SFP out AEN broken!\n");
+		netif_err(qdev, drv, qdev->ndev, "SFP out AEN broken!\n");
 	else
-		QPRINTK(qdev, DRV, ERR, "SFP removal detected.\n");
+		netif_err(qdev, drv, qdev->ndev, "SFP removal detected.\n");
 
 	return status;
 }
@@ -350,13 +350,13 @@ static int ql_aen_lost(struct ql_adapter *qdev, struct mbox_params *mbcp)
 
 	status = ql_get_mb_sts(qdev, mbcp);
 	if (status)
-		QPRINTK(qdev, DRV, ERR, "Lost AEN broken!\n");
+		netif_err(qdev, drv, qdev->ndev, "Lost AEN broken!\n");
 	else {
 		int i;
-		QPRINTK(qdev, DRV, ERR, "Lost AEN detected.\n");
+		netif_err(qdev, drv, qdev->ndev, "Lost AEN detected.\n");
 		for (i = 0; i < mbcp->out_count; i++)
-			QPRINTK(qdev, DRV, ERR, "mbox_out[%d] = 0x%.08x.\n",
-					i, mbcp->mbox_out[i]);
+			netif_err(qdev, drv, qdev->ndev, "mbox_out[%d] = 0x%.08x.\n",
+				  i, mbcp->mbox_out[i]);
 
 	}
 
@@ -371,15 +371,15 @@ static void ql_init_fw_done(struct ql_adapter *qdev, struct mbox_params *mbcp)
 
 	status = ql_get_mb_sts(qdev, mbcp);
 	if (status) {
-		QPRINTK(qdev, DRV, ERR, "Firmware did not initialize!\n");
+		netif_err(qdev, drv, qdev->ndev, "Firmware did not initialize!\n");
 	} else {
-		QPRINTK(qdev, DRV, ERR, "Firmware Revision  = 0x%.08x.\n",
-			mbcp->mbox_out[1]);
+		netif_err(qdev, drv, qdev->ndev, "Firmware Revision  = 0x%.08x.\n",
+			  mbcp->mbox_out[1]);
 		qdev->fw_rev_id = mbcp->mbox_out[1];
 		status = ql_cam_route_initialize(qdev);
 		if (status)
-			QPRINTK(qdev, IFUP, ERR,
-				"Failed to init CAM/Routing tables.\n");
+			netif_err(qdev, ifup, qdev->ndev,
+				  "Failed to init CAM/Routing tables.\n");
 	}
 }
 
@@ -398,8 +398,8 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	mbcp->out_count = 1;
 	status = ql_get_mb_sts(qdev, mbcp);
 	if (status) {
-		QPRINTK(qdev, DRV, ERR,
-			"Could not read MPI, resetting ASIC!\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Could not read MPI, resetting ASIC!\n");
 		ql_queue_asic_error(qdev);
 		goto end;
 	}
@@ -488,15 +488,14 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 			mbcp->mbox_out[0] = MB_CMD_STS_ERR;
 			return status;
 		}
-		QPRINTK(qdev, DRV, ERR,
-			"Firmware initialization failed.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Firmware initialization failed.\n");
 		status = -EIO;
 		ql_queue_fw_error(qdev);
 		break;
 
 	case AEN_SYS_ERR:
-		QPRINTK(qdev, DRV, ERR,
-			"System Error.\n");
+		netif_err(qdev, drv, qdev->ndev, "System Error.\n");
 		ql_queue_fw_error(qdev);
 		status = -EIO;
 		break;
@@ -509,8 +508,8 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		/* Need to support AEN 8110 */
 		break;
 	default:
-		QPRINTK(qdev, DRV, ERR,
-			"Unsupported AE %.08x.\n", mbcp->mbox_out[0]);
+		netif_err(qdev, drv, qdev->ndev,
+			  "Unsupported AE %.08x.\n", mbcp->mbox_out[0]);
 		/* Clear the MPI firmware status. */
 	}
 end:
@@ -583,8 +582,8 @@ static int ql_mailbox_command(struct ql_adapter *qdev, struct mbox_params *mbcp)
 			goto done;
 	} while (time_before(jiffies, count));
 
-	QPRINTK(qdev, DRV, ERR,
-		"Timed out waiting for mailbox complete.\n");
+	netif_err(qdev, drv, qdev->ndev,
+		  "Timed out waiting for mailbox complete.\n");
 	status = -ETIMEDOUT;
 	goto end;
 
@@ -646,8 +645,8 @@ int ql_mb_about_fw(struct ql_adapter *qdev)
 		return status;
 
 	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed about firmware command\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Failed about firmware command\n");
 		status = -EIO;
 	}
 
@@ -678,8 +677,8 @@ int ql_mb_get_fw_state(struct ql_adapter *qdev)
 		return status;
 
 	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed Get Firmware State.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Failed Get Firmware State.\n");
 		status = -EIO;
 	}
 
@@ -688,8 +687,8 @@ int ql_mb_get_fw_state(struct ql_adapter *qdev)
 	 * happen.
 	 */
 	if (mbcp->mbox_out[1] & 1) {
-		QPRINTK(qdev, DRV, ERR,
-			"Firmware waiting for initialization.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Firmware waiting for initialization.\n");
 		status = -EIO;
 	}
 
@@ -721,8 +720,7 @@ int ql_mb_idc_ack(struct ql_adapter *qdev)
 		return status;
 
 	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed IDC ACK send.\n");
+		netif_err(qdev, drv, qdev->ndev, "Failed IDC ACK send.\n");
 		status = -EIO;
 	}
 	return status;
@@ -753,11 +751,11 @@ int ql_mb_set_port_cfg(struct ql_adapter *qdev)
 		return status;
 
 	if (mbcp->mbox_out[0] == MB_CMD_STS_INTRMDT) {
-		QPRINTK(qdev, DRV, ERR,
-			"Port Config sent, wait for IDC.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Port Config sent, wait for IDC.\n");
 	} else	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed Set Port Configuration.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Failed Set Port Configuration.\n");
 		status = -EIO;
 	}
 	return status;
@@ -791,8 +789,7 @@ int ql_mb_dump_ram(struct ql_adapter *qdev, u64 req_dma, u32 addr,
 		return status;
 
 	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed to dump risc RAM.\n");
+		netif_err(qdev, drv, qdev->ndev, "Failed to dump risc RAM.\n");
 		status = -EIO;
 	}
 	return status;
@@ -842,12 +839,12 @@ int ql_mb_get_port_cfg(struct ql_adapter *qdev)
 		return status;
 
 	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed Get Port Configuration.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Failed Get Port Configuration.\n");
 		status = -EIO;
 	} else	{
-		QPRINTK(qdev, DRV, DEBUG,
-			"Passed Get Port Configuration.\n");
+		netif_printk(qdev, drv, KERN_DEBUG, qdev->ndev,
+			     "Passed Get Port Configuration.\n");
 		qdev->link_config = mbcp->mbox_out[1];
 		qdev->max_frame_size = mbcp->mbox_out[2];
 	}
@@ -874,8 +871,7 @@ int ql_mb_wol_mode(struct ql_adapter *qdev, u32 wol)
 		return status;
 
 	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed to set WOL mode.\n");
+		netif_err(qdev, drv, qdev->ndev, "Failed to set WOL mode.\n");
 		status = -EIO;
 	}
 	return status;
@@ -917,8 +913,7 @@ int ql_mb_wol_set_magic(struct ql_adapter *qdev, u32 enable_wol)
 		return status;
 
 	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed to set WOL mode.\n");
+		netif_err(qdev, drv, qdev->ndev, "Failed to set WOL mode.\n");
 		status = -EIO;
 	}
 	return status;
@@ -944,8 +939,7 @@ static int ql_idc_wait(struct ql_adapter *qdev)
 			wait_for_completion_timeout(&qdev->ide_completion,
 							wait_time);
 		if (!wait_time) {
-			QPRINTK(qdev, DRV, ERR,
-				"IDC Timeout.\n");
+			netif_err(qdev, drv, qdev->ndev, "IDC Timeout.\n");
 			break;
 		}
 		/* Now examine the response from the IDC process.
@@ -953,18 +947,17 @@ static int ql_idc_wait(struct ql_adapter *qdev)
 		 * more wait time.
 		 */
 		if (mbcp->mbox_out[0] == AEN_IDC_EXT) {
-			QPRINTK(qdev, DRV, ERR,
-				"IDC Time Extension from function.\n");
+			netif_err(qdev, drv, qdev->ndev,
+				  "IDC Time Extension from function.\n");
 			wait_time += (mbcp->mbox_out[1] >> 8) & 0x0000000f;
 		} else if (mbcp->mbox_out[0] == AEN_IDC_CMPLT) {
-			QPRINTK(qdev, DRV, ERR,
-				"IDC Success.\n");
+			netif_err(qdev, drv, qdev->ndev, "IDC Success.\n");
 			status = 0;
 			break;
 		} else {
-			QPRINTK(qdev, DRV, ERR,
-				"IDC: Invalid State 0x%.04x.\n",
-				mbcp->mbox_out[0]);
+			netif_err(qdev, drv, qdev->ndev,
+				  "IDC: Invalid State 0x%.04x.\n",
+				  mbcp->mbox_out[0]);
 			status = -EIO;
 			break;
 		}
@@ -993,8 +986,8 @@ int ql_mb_set_led_cfg(struct ql_adapter *qdev, u32 led_config)
 		return status;
 
 	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed to set LED Configuration.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Failed to set LED Configuration.\n");
 		status = -EIO;
 	}
 
@@ -1019,8 +1012,8 @@ int ql_mb_get_led_cfg(struct ql_adapter *qdev)
 		return status;
 
 	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed to get LED Configuration.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Failed to get LED Configuration.\n");
 		status = -EIO;
 	} else
 		qdev->led_config = mbcp->mbox_out[1];
@@ -1050,16 +1043,16 @@ int ql_mb_set_mgmnt_traffic_ctl(struct ql_adapter *qdev, u32 control)
 		return status;
 
 	if (mbcp->mbox_out[0] == MB_CMD_STS_INVLD_CMD) {
-		QPRINTK(qdev, DRV, ERR,
-			"Command not supported by firmware.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Command not supported by firmware.\n");
 		status = -EINVAL;
 	} else if (mbcp->mbox_out[0] == MB_CMD_STS_ERR) {
 		/* This indicates that the firmware is
 		 * already in the state we are trying to
 		 * change it to.
 		 */
-		QPRINTK(qdev, DRV, ERR,
-			"Command parameters make no change.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Command parameters make no change.\n");
 	}
 	return status;
 }
@@ -1089,12 +1082,12 @@ static int ql_mb_get_mgmnt_traffic_ctl(struct ql_adapter *qdev, u32 *control)
 	}
 
 	if (mbcp->mbox_out[0] == MB_CMD_STS_INVLD_CMD) {
-		QPRINTK(qdev, DRV, ERR,
-			"Command not supported by firmware.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Command not supported by firmware.\n");
 		status = -EINVAL;
 	} else if (mbcp->mbox_out[0] == MB_CMD_STS_ERR) {
-		QPRINTK(qdev, DRV, ERR,
-			"Failed to get MPI traffic control.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Failed to get MPI traffic control.\n");
 		status = -EIO;
 	}
 	return status;
@@ -1150,8 +1143,8 @@ void ql_mpi_port_cfg_work(struct work_struct *work)
 	status = ql_mb_get_port_cfg(qdev);
 	rtnl_unlock();
 	if (status) {
-		QPRINTK(qdev, DRV, ERR,
-			"Bug: Failed to get port config data.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Bug: Failed to get port config data.\n");
 		goto err;
 	}
 
@@ -1164,8 +1157,8 @@ void ql_mpi_port_cfg_work(struct work_struct *work)
 	qdev->max_frame_size = CFG_DEFAULT_MAX_FRAME_SIZE;
 	status = ql_set_port_cfg(qdev);
 	if (status) {
-		QPRINTK(qdev, DRV, ERR,
-			"Bug: Failed to set port config data.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Bug: Failed to set port config data.\n");
 		goto err;
 	}
 end:
@@ -1197,8 +1190,8 @@ void ql_mpi_idc_work(struct work_struct *work)
 
 	switch (aen) {
 	default:
-		QPRINTK(qdev, DRV, ERR,
-			"Bug: Unhandled IDC action.\n");
+		netif_err(qdev, drv, qdev->ndev,
+			  "Bug: Unhandled IDC action.\n");
 		break;
 	case MB_CMD_PORT_RESET:
 	case MB_CMD_STOP_FW:
@@ -1213,11 +1206,11 @@ void ql_mpi_idc_work(struct work_struct *work)
 		if (timeout) {
 			status = ql_mb_idc_ack(qdev);
 			if (status)
-				QPRINTK(qdev, DRV, ERR,
-					"Bug: No pending IDC!\n");
+				netif_err(qdev, drv, qdev->ndev,
+					  "Bug: No pending IDC!\n");
 		} else {
-			QPRINTK(qdev, DRV, DEBUG,
-				    "IDC ACK not required\n");
+			netif_printk(qdev, drv, KERN_DEBUG, qdev->ndev,
+				     "IDC ACK not required\n");
 			status = 0; /* success */
 		}
 		break;
@@ -1246,11 +1239,11 @@ void ql_mpi_idc_work(struct work_struct *work)
 		if (timeout) {
 			status = ql_mb_idc_ack(qdev);
 			if (status)
-				QPRINTK(qdev, DRV, ERR,
-				    "Bug: No pending IDC!\n");
+				netif_err(qdev, drv, qdev->ndev,
+					  "Bug: No pending IDC!\n");
 		} else {
-			QPRINTK(qdev, DRV, DEBUG,
-			    "IDC ACK not required\n");
+			netif_printk(qdev, drv, KERN_DEBUG, qdev->ndev,
+				     "IDC ACK not required\n");
 			status = 0; /* success */
 		}
 		break;
@@ -1298,12 +1291,12 @@ void ql_mpi_reset_work(struct work_struct *work)
 	 * then there is nothing to do.
 	 */
 	if (!ql_own_firmware(qdev)) {
-		QPRINTK(qdev, DRV, ERR, "Don't own firmware!\n");
+		netif_err(qdev, drv, qdev->ndev, "Don't own firmware!\n");
 		return;
 	}
 
 	if (!ql_core_dump(qdev, qdev->mpi_coredump)) {
-		QPRINTK(qdev, DRV, ERR, "Core is dumped!\n");
+		netif_err(qdev, drv, qdev->ndev, "Core is dumped!\n");
 		qdev->core_is_dumped = 1;
 		queue_delayed_work(qdev->workqueue,
 			&qdev->mpi_core_to_log, 5 * HZ);
-- 
1.7.0.rc1.33.g07cf0f

