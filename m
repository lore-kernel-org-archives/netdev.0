From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 2/4] netxen: implement generic pcie semaphore functions
Date: Mon, 24 Aug 2009 22:23:26 -0700
Message-ID: <1251177808-16450-2-git-send-email-dhananjay@netxen.com>
References: <1251177808-16450-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:54412 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754478AbZHYFX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 01:23:28 -0400
In-Reply-To: <1251177808-16450-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement common function for locking/unlocking 8 hardware
semaphores used for serializing access to shared resouces
on a NIC board by different PCI functions.

As by definition, callers of these semaphore API can be
put to sleep till the semaphore is locked.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   24 ++++++++++++++
 drivers/net/netxen/netxen_nic_ctx.c  |   35 ---------------------
 drivers/net/netxen/netxen_nic_hdr.h  |    8 +++++
 drivers/net/netxen/netxen_nic_hw.c   |   57 +++++++++++++++++----------------
 drivers/net/netxen/netxen_nic_init.c |   52 +++++--------------------------
 drivers/net/netxen/netxen_nic_niu.c  |   39 +----------------------
 6 files changed, 71 insertions(+), 144 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 74ccef5..061e8aa 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1207,6 +1207,30 @@ int netxen_p3_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr);
 #define NXWR32(adapter, off, val) \
 	(adapter->hw_write_wx(adapter, off, val))
 
+int netxen_pcie_sem_lock(struct netxen_adapter *, int, u32);
+void netxen_pcie_sem_unlock(struct netxen_adapter *, int);
+
+#define netxen_rom_lock(a)	\
+	netxen_pcie_sem_lock((a), 2, NETXEN_ROM_LOCK_ID)
+#define netxen_rom_unlock(a)	\
+	netxen_pcie_sem_unlock((a), 2)
+#define netxen_phy_lock(a)	\
+	netxen_pcie_sem_lock((a), 3, NETXEN_PHY_LOCK_ID)
+#define netxen_phy_unlock(a)	\
+	netxen_pcie_sem_unlock((a), 3)
+#define netxen_api_lock(a)	\
+	netxen_pcie_sem_lock((a), 5, 0)
+#define netxen_api_unlock(a)	\
+	netxen_pcie_sem_unlock((a), 5)
+#define netxen_sw_lock(a)	\
+	netxen_pcie_sem_lock((a), 6, 0)
+#define netxen_sw_unlock(a)	\
+	netxen_pcie_sem_unlock((a), 6)
+#define crb_win_lock(a)	\
+	netxen_pcie_sem_lock((a), 7, NETXEN_CRB_WIN_LOCK_ID)
+#define crb_win_unlock(a)	\
+	netxen_pcie_sem_unlock((a), 7)
+
 int netxen_nic_get_board_info(struct netxen_adapter *adapter);
 void netxen_nic_get_firmware_info(struct netxen_adapter *adapter);
 int netxen_nic_wol_supported(struct netxen_adapter *adapter);
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 3d676fe..ef846b4 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -33,41 +33,6 @@
 
 #define NXHAL_VERSION	1
 
-static int
-netxen_api_lock(struct netxen_adapter *adapter)
-{
-	u32 done = 0, timeout = 0;
-
-	for (;;) {
-		/* Acquire PCIE HW semaphore5 */
-		done = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM5_LOCK));
-
-		if (done == 1)
-			break;
-
-		if (++timeout >= NX_OS_CRB_RETRY_COUNT) {
-			printk(KERN_ERR "%s: lock timeout.\n", __func__);
-			return -1;
-		}
-
-		msleep(1);
-	}
-
-#if 0
-	NXWR32(adapter,
-		NETXEN_API_LOCK_ID, NX_OS_API_LOCK_DRIVER);
-#endif
-	return 0;
-}
-
-static int
-netxen_api_unlock(struct netxen_adapter *adapter)
-{
-	/* Release PCIE HW semaphore5 */
-	NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM5_UNLOCK));
-	return 0;
-}
-
 static u32
 netxen_poll_rsp(struct netxen_adapter *adapter)
 {
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index c4a4a8b..92f5970 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -899,16 +899,24 @@ enum {
 
 #define PCIE_DCR		0x00d8
 
+#define PCIE_SEM0_LOCK		(0x1c000)
+#define PCIE_SEM0_UNLOCK	(0x1c004)
+#define PCIE_SEM1_LOCK		(0x1c008)
+#define PCIE_SEM1_UNLOCK	(0x1c00c)
 #define PCIE_SEM2_LOCK		(0x1c010)	/* Flash lock   */
 #define PCIE_SEM2_UNLOCK	(0x1c014)	/* Flash unlock */
 #define PCIE_SEM3_LOCK	  	(0x1c018)	/* Phy lock     */
 #define PCIE_SEM3_UNLOCK	(0x1c01c)	/* Phy unlock   */
+#define PCIE_SEM4_LOCK	  	(0x1c020)
+#define PCIE_SEM4_UNLOCK	(0x1c024)
 #define PCIE_SEM5_LOCK		(0x1c028)	/* API lock     */
 #define PCIE_SEM5_UNLOCK	(0x1c02c)	/* API unlock   */
 #define PCIE_SEM6_LOCK		(0x1c030)	/* sw lock      */
 #define PCIE_SEM6_UNLOCK	(0x1c034)	/* sw unlock    */
 #define PCIE_SEM7_LOCK		(0x1c038)	/* crb win lock */
 #define PCIE_SEM7_UNLOCK	(0x1c03c)	/* crbwin unlock*/
+#define PCIE_SEM_LOCK(N)	(PCIE_SEM0_LOCK + 8*(N))
+#define PCIE_SEM_UNLOCK(N)	(PCIE_SEM0_UNLOCK + 8*(N))
 
 #define PCIE_SETUP_FUNCTION	(0x12040)
 #define PCIE_SETUP_FUNCTION2	(0x12048)
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 9138bbc..cbfe44c 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -86,7 +86,6 @@ static void __iomem *pci_base_offset(struct netxen_adapter *adapter,
 	return NULL;
 }
 
-#define CRB_WIN_LOCK_TIMEOUT 100000000
 static crb_128M_2M_block_map_t
 crb_128M_2M_map[64] __cacheline_aligned_in_smp = {
     {{{0, 0,         0,         0} } },		/* 0: PCI */
@@ -320,6 +319,35 @@ static unsigned crb_hub_agt[64] =
 
 #define NETXEN_WINDOW_ONE 	0x2000000 /*CRB Window: bit 25 of CRB address */
 
+#define NETXEN_PCIE_SEM_TIMEOUT	10000
+
+int
+netxen_pcie_sem_lock(struct netxen_adapter *adapter, int sem, u32 id_reg)
+{
+	int done = 0, timeout = 0;
+
+	while (!done) {
+		done = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM_LOCK(sem)));
+		if (done == 1)
+			break;
+		if (++timeout >= NETXEN_PCIE_SEM_TIMEOUT)
+			return -1;
+		msleep(1);
+	}
+
+	if (id_reg)
+		NXWR32(adapter, id_reg, adapter->portnum);
+
+	return 0;
+}
+
+void
+netxen_pcie_sem_unlock(struct netxen_adapter *adapter, int sem)
+{
+	int val;
+	val = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM_UNLOCK(sem)));
+}
+
 #define NETXEN_UNICAST_ADDR(port, index) \
 	(NETXEN_UNICAST_ADDR_BASE+(port*32)+(index*8))
 #define NETXEN_MCAST_ADDR(port, index) \
@@ -906,33 +934,6 @@ int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
 	return 0;
 }
 
-#define CRB_WIN_LOCK_TIMEOUT 100000000
-
-static int crb_win_lock(struct netxen_adapter *adapter)
-{
-	int done = 0, timeout = 0;
-
-	while (!done) {
-		/* acquire semaphore3 from PCI HW block */
-		done = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM7_LOCK));
-		if (done == 1)
-			break;
-		if (timeout >= CRB_WIN_LOCK_TIMEOUT)
-			return -1;
-		timeout++;
-		udelay(1);
-	}
-	NXWR32(adapter, NETXEN_CRB_WIN_LOCK_ID, adapter->portnum);
-	return 0;
-}
-
-static void crb_win_unlock(struct netxen_adapter *adapter)
-{
-	int val;
-
-	val = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM7_UNLOCK));
-}
-
 /*
  * Changes the CRB window to the specified window.
  */
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index f5807da..313cd26 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -369,37 +369,7 @@ static u32 netxen_decode_crb_addr(u32 addr)
 		return (pci_base + offset);
 }
 
-static long rom_max_timeout = 100;
-static long rom_lock_timeout = 10000;
-
-static int rom_lock(struct netxen_adapter *adapter)
-{
-	int iter;
-	u32 done = 0;
-	int timeout = 0;
-
-	while (!done) {
-		/* acquire semaphore2 from PCI HW block */
-		done = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM2_LOCK));
-		if (done == 1)
-			break;
-		if (timeout >= rom_lock_timeout)
-			return -EIO;
-
-		timeout++;
-		/*
-		 * Yield CPU
-		 */
-		if (!in_atomic())
-			schedule();
-		else {
-			for (iter = 0; iter < 20; iter++)
-				cpu_relax();	/*This a nop instr on i386 */
-		}
-	}
-	NXWR32(adapter, NETXEN_ROM_LOCK_ID, ROM_LOCK_DRIVER);
-	return 0;
-}
+#define NETXEN_MAX_ROM_WAIT_USEC	100
 
 static int netxen_wait_rom_done(struct netxen_adapter *adapter)
 {
@@ -411,22 +381,16 @@ static int netxen_wait_rom_done(struct netxen_adapter *adapter)
 	while (done == 0) {
 		done = NXRD32(adapter, NETXEN_ROMUSB_GLB_STATUS);
 		done &= 2;
-		timeout++;
-		if (timeout >= rom_max_timeout) {
-			printk("Timeout reached  waiting for rom done");
+		if (++timeout >= NETXEN_MAX_ROM_WAIT_USEC) {
+			dev_err(&adapter->pdev->dev,
+				"Timeout reached  waiting for rom done");
 			return -EIO;
 		}
+		udelay(1);
 	}
 	return 0;
 }
 
-static void netxen_rom_unlock(struct netxen_adapter *adapter)
-{
-	/* release semaphore2 */
-	NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM2_UNLOCK));
-
-}
-
 static int do_rom_fast_read(struct netxen_adapter *adapter,
 			    int addr, int *valp)
 {
@@ -471,7 +435,7 @@ netxen_rom_fast_read_words(struct netxen_adapter *adapter, int addr,
 {
 	int ret;
 
-	ret = rom_lock(adapter);
+	ret = netxen_rom_lock(adapter);
 	if (ret < 0)
 		return ret;
 
@@ -485,7 +449,7 @@ int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
 {
 	int ret;
 
-	if (rom_lock(adapter) != 0)
+	if (netxen_rom_lock(adapter) != 0)
 		return -EIO;
 
 	ret = do_rom_fast_read(adapter, addr, valp);
@@ -506,7 +470,7 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 	u32 off;
 
 	/* resetall */
-	rom_lock(adapter);
+	netxen_rom_lock(adapter);
 	NXWR32(adapter, NETXEN_ROMUSB_GLB_SW_RESET, 0xffffffff);
 	netxen_rom_unlock(adapter);
 
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 8b7cd9e..1392e89 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -30,40 +30,6 @@
 
 #include "netxen_nic.h"
 
-static long phy_lock_timeout = 100000000;
-
-static int phy_lock(struct netxen_adapter *adapter)
-{
-	int i;
-	int done = 0, timeout = 0;
-
-	while (!done) {
-		done = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM3_LOCK));
-		if (done == 1)
-			break;
-		if (timeout >= phy_lock_timeout) {
-			return -1;
-		}
-		timeout++;
-		if (!in_atomic())
-			schedule();
-		else {
-			for (i = 0; i < 20; i++)
-				cpu_relax();
-		}
-	}
-
-	NXWR32(adapter, NETXEN_PHY_LOCK_ID, PHY_LOCK_DRIVER);
-	return 0;
-}
-
-static int phy_unlock(struct netxen_adapter *adapter)
-{
-	adapter->pci_read_immediate(adapter, NETXEN_PCIE_REG(PCIE_SEM3_UNLOCK));
-
-	return 0;
-}
-
 /*
  * netxen_niu_gbe_phy_read - read a register from the GbE PHY via
  * mii management interface.
@@ -89,9 +55,8 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 	__u32 status;
 	__u32 mac_cfg0;
 
-	if (phy_lock(adapter) != 0) {
+	if (netxen_phy_lock(adapter) != 0)
 		return -1;
-	}
 
 	/*
 	 * MII mgmt all goes through port 0 MAC interface,
@@ -141,7 +106,7 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 	if (restore)
 		if (NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0), mac_cfg0))
 			return -EIO;
-	phy_unlock(adapter);
+	netxen_phy_unlock(adapter);
 	return result;
 }
 
-- 
1.6.0.2

