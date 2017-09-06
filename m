From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v13 1/5] block: DAC960: Replace PCI pool old API
Date: Wed,  6 Sep 2017 11:08:53 +0200
Message-ID: <20170906090857.14846-2-romain.perier@collabora.com>
References: <20170906090857.14846-1-romain.perier@collabora.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
To: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        Aviad Krawczyk <aviad.krawczyk-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170906090857.14846-1-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Acked-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Tested-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
---
 drivers/block/DAC960.c | 38 ++++++++++++++++++--------------------
 drivers/block/DAC960.h |  4 ++--
 2 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/drivers/block/DAC960.c b/drivers/block/DAC960.c
index 255591ab3716..2a8950ee382c 100644
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
index 85fa9bb63759..47d7d698ece2 100644
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
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
