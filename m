From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH 2.6.35-rc1] net: vmxnet3 fixes [2/5] Interrupt control
 bitmap
Date: Wed, 7 Jul 2010 02:24:16 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1007070222110.6105@localhost.localdomain>
References: <alpine.LRH.2.00.1007070125440.4652@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, pv-drivers@vmware.com,
	ronghua@vmware.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1007070125440.4652@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A new bit map 'intrCtrl' is introduced in the DriverShared area. The driver 
should update VMXNET3_IC_DISABLE_ALL bit before writing IMR.

Signed-off-by: Ronghua Zang <ronghua@vmware.com>
Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

---

diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index b4889e6..ca7727b 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -464,6 +464,9 @@ enum vmxnet3_intr_type {
 /* addition 1 for events */
 #define VMXNET3_MAX_INTRS      25
 
+/* value of intrCtrl */
+#define VMXNET3_IC_DISABLE_ALL  0x1   /* bit 0 */
+
 
 struct Vmxnet3_IntrConf {
 	bool		autoMask;
@@ -471,7 +474,8 @@ struct Vmxnet3_IntrConf {
 	u8		eventIntrIdx;
 	u8		modLevels[VMXNET3_MAX_INTRS];	/* moderation level for
 							 * each intr */
-	__le32		reserved[3];
+	__le32		intrCtrl;
+	__le32		reserved[2];
 };
 
 /* one bit per VLAN ID, the size is in the units of u32	*/
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 1b2d467..29db294 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -72,6 +72,7 @@ vmxnet3_enable_all_intrs(struct vmxnet3_adapter *adapter)
 
 	for (i = 0; i < adapter->intr.num_intrs; i++)
 		vmxnet3_enable_intr(adapter, i);
+	adapter->shared->devRead.intrConf.intrCtrl &= ~VMXNET3_IC_DISABLE_ALL;
 }
 
 
@@ -80,6 +81,7 @@ vmxnet3_disable_all_intrs(struct vmxnet3_adapter *adapter)
 {
 	int i;
 
+	adapter->shared->devRead.intrConf.intrCtrl |= VMXNET3_IC_DISABLE_ALL;
 	for (i = 0; i < adapter->intr.num_intrs; i++)
 		vmxnet3_disable_intr(adapter, i);
 }
@@ -1880,6 +1882,7 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 		devRead->intrConf.modLevels[i] = adapter->intr.mod_levels[i];
 
 	devRead->intrConf.eventIntrIdx = adapter->intr.event_intr_idx;
+	devRead->intrConf.intrCtrl |= VMXNET3_IC_DISABLE_ALL;
 
 	/* rx filter settings */
 	devRead->rxFilterConf.rxMode = 0;
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 7985ba4..0ddfe3c 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -68,10 +68,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.0.6.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.0.9.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01000600
+#define VMXNET3_DRIVER_VERSION_NUM      0x01000900
 
 
 /*
