From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v7 01/15] block: DAC960: Replace PCI pool old API
Date: Fri,  7 Apr 2017 09:25:29 +0200
Message-ID: <20170407072543.6936-2-romain.perier@collabora.com>
References: <20170407072543.6936-1-romain.perier@collabora.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170407072543.6936-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Acked-by: Peter Senna Tschudin <peter.senna@collabora.com>
Tested-by: Peter Senna Tschudin <peter.senna@collabora.com>
---
 drivers/block/DAC960.c | 38 ++++++++++++++++++--------------------
 drivers/block/DAC960.h |  4 ++--
 2 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/drivers/block/DAC960.c b/drivers/block/DAC960.c
index 26a51be..a0883ad 100644
--- a/drivers/block/DAC960.c
+++ b/drivers/block/DAC960.c
@@ -268,17 +268,17 @@ static bool DAC960_CreateAuxiliaryStructures(DAC960_Controller_T *Controller)
   void *AllocationPointer = NULL;
   void *ScatterGatherCPU = NULL;
   dma_addr_t ScatterGatherDMA;
-  struct pci_pool *ScatterGatherPool;
+  struct dma_pool *ScatterGatherPool;
   void *RequestSenseCPU = NULL;
   dma_addr_t RequestSenseDMA;
-  struct pci_pool *RequestSensePool = NULL;
+  struct dma_pool *RequestSensePool = NULL;
 
   if (Controller->FirmwareType == DAC960_V1_Controller)
     {
       CommandAllocationLength = offsetof(DAC960_Command_T, V1.EndMarker);
       CommandAllocationGroupSize = DAC960_V1_CommandAllocationGroupSize;
-      ScatterGatherPool = pci_pool_create("DAC960_V1_ScatterGather",
-		Controller->PCIDevice,
+      ScatterGatherPool = dma_pool_create("DAC960_V1_ScatterGather",
+		&Controller->PCIDevice->dev,
 	DAC960_V1_ScatterGatherLimit * sizeof(DAC960_V1_ScatterGatherSegment_T),
 	sizeof(DAC960_V1_ScatterGatherSegment_T), 0);
       if (ScatterGatherPool == NULL)
@@ -290,18 +290,18 @@ static bool DAC960_CreateAuxiliaryStructures(DAC960_Controller_T *Controller)
     {
       CommandAllocationLength = offsetof(DAC960_Command_T, V2.EndMarker);
       CommandAllocationGroupSize = DAC960_V2_CommandAllocationGroupSize;
-      ScatterGatherPool = pci_pool_create("DAC960_V2_ScatterGather",
-		Controller->PCIDevice,
+      ScatterGatherPool = dma_pool_create("DAC960_V2_ScatterGather",
+		&Controller->PCIDevice->dev,
 	DAC960_V2_ScatterGatherLimit * sizeof(DAC960_V2_ScatterGatherSegment_T),
 	sizeof(DAC960_V2_ScatterGatherSegment_T), 0);
       if (ScatterGatherPool == NULL)
 	    return DAC960_Failure(Controller,
 			"AUXILIARY STRUCTURE CREATION (SG)");
-      RequestSensePool = pci_pool_create("DAC960_V2_RequestSense",
-		Controller->PCIDevice, sizeof(DAC960_SCSI_RequestSense_T),
+      RequestSensePool = dma_pool_create("DAC960_V2_RequestSense",
+		&Controller->PCIDevice->dev, sizeof(DAC960_SCSI_RequestSense_T),
 		sizeof(int), 0);
       if (RequestSensePool == NULL) {
-	    pci_pool_destroy(ScatterGatherPool);
+	    dma_pool_destroy(ScatterGatherPool);
 	    return DAC960_Failure(Controller,
 			"AUXILIARY STRUCTURE CREATION (SG)");
       }
@@ -335,16 +335,16 @@ static bool DAC960_CreateAuxiliaryStructures(DAC960_Controller_T *Controller)
       Command->Next = Controller->FreeCommands;
       Controller->FreeCommands = Command;
       Controller->Commands[CommandIdentifier-1] = Command;
-      ScatterGatherCPU = pci_pool_alloc(ScatterGatherPool, GFP_ATOMIC,
+      ScatterGatherCPU = dma_pool_alloc(ScatterGatherPool, GFP_ATOMIC,
 							&ScatterGatherDMA);
       if (ScatterGatherCPU == NULL)
 	  return DAC960_Failure(Controller, "AUXILIARY STRUCTURE CREATION");
 
       if (RequestSensePool != NULL) {
-  	  RequestSenseCPU = pci_pool_alloc(RequestSensePool, GFP_ATOMIC,
+  	  RequestSenseCPU = dma_pool_alloc(RequestSensePool, GFP_ATOMIC,
 						&RequestSenseDMA);
   	  if (RequestSenseCPU == NULL) {
-                pci_pool_free(ScatterGatherPool, ScatterGatherCPU,
+                dma_pool_free(ScatterGatherPool, ScatterGatherCPU,
                                 ScatterGatherDMA);
     		return DAC960_Failure(Controller,
 					"AUXILIARY STRUCTURE CREATION");
@@ -379,8 +379,8 @@ static bool DAC960_CreateAuxiliaryStructures(DAC960_Controller_T *Controller)
 static void DAC960_DestroyAuxiliaryStructures(DAC960_Controller_T *Controller)
 {
   int i;
-  struct pci_pool *ScatterGatherPool = Controller->ScatterGatherPool;
-  struct pci_pool *RequestSensePool = NULL;
+  struct dma_pool *ScatterGatherPool = Controller->ScatterGatherPool;
+  struct dma_pool *RequestSensePool = NULL;
   void *ScatterGatherCPU;
   dma_addr_t ScatterGatherDMA;
   void *RequestSenseCPU;
@@ -411,9 +411,9 @@ static void DAC960_DestroyAuxiliaryStructures(DAC960_Controller_T *Controller)
 	  RequestSenseDMA = Command->V2.RequestSenseDMA;
       }
       if (ScatterGatherCPU != NULL)
-          pci_pool_free(ScatterGatherPool, ScatterGatherCPU, ScatterGatherDMA);
+          dma_pool_free(ScatterGatherPool, ScatterGatherCPU, ScatterGatherDMA);
       if (RequestSenseCPU != NULL)
-          pci_pool_free(RequestSensePool, RequestSenseCPU, RequestSenseDMA);
+          dma_pool_free(RequestSensePool, RequestSenseCPU, RequestSenseDMA);
 
       if ((Command->CommandIdentifier
 	   % Controller->CommandAllocationGroupSize) == 1) {
@@ -437,13 +437,11 @@ static void DAC960_DestroyAuxiliaryStructures(DAC960_Controller_T *Controller)
       Controller->CurrentStatusBuffer = NULL;
     }
 
-  if (ScatterGatherPool != NULL)
-  	pci_pool_destroy(ScatterGatherPool);
+  dma_pool_destroy(ScatterGatherPool);
   if (Controller->FirmwareType == DAC960_V1_Controller)
   	return;
 
-  if (RequestSensePool != NULL)
-	pci_pool_destroy(RequestSensePool);
+  dma_pool_destroy(RequestSensePool);
 
   for (i = 0; i < DAC960_MaxLogicalDrives; i++) {
 	kfree(Controller->V2.LogicalDeviceInformation[i]);
diff --git a/drivers/block/DAC960.h b/drivers/block/DAC960.h
index 85fa9bb..47d7d69 100644
--- a/drivers/block/DAC960.h
+++ b/drivers/block/DAC960.h
@@ -2316,7 +2316,7 @@ typedef struct DAC960_Controller
   bool SuppressEnclosureMessages;
   struct timer_list MonitoringTimer;
   struct gendisk *disks[DAC960_MaxLogicalDrives];
-  struct pci_pool *ScatterGatherPool;
+  struct dma_pool *ScatterGatherPool;
   DAC960_Command_T *FreeCommands;
   unsigned char *CombinedStatusBuffer;
   unsigned char *CurrentStatusBuffer;
@@ -2429,7 +2429,7 @@ typedef struct DAC960_Controller
       bool NeedDeviceSerialNumberInformation;
       bool StartLogicalDeviceInformationScan;
       bool StartPhysicalDeviceInformationScan;
-      struct pci_pool *RequestSensePool;
+      struct dma_pool *RequestSensePool;
 
       dma_addr_t	FirstCommandMailboxDMA;
       DAC960_V2_CommandMailbox_T *FirstCommandMailbox;
-- 
2.9.3
