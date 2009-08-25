From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 03/26] et131x: power state
Date: Tue, 25 Aug 2009 15:57:51 +0100
Message-ID: <20090825145749.16176.5547.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:42572 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755307AbZHYPDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:03:16 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is assigned once to ndis d0, and then never changes so it is a constant
and we can zap it

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et1310_pm.h      |   10 ----------
 drivers/staging/et131x/et1310_rx.c      |    2 --
 drivers/staging/et131x/et131x_initpci.c |    2 --
 drivers/staging/et131x/et131x_isr.c     |    3 +--
 4 files changed, 1 insertions(+), 16 deletions(-)


diff --git a/drivers/staging/et131x/et1310_pm.h b/drivers/staging/et131x/et1310_pm.h
index dca9977..8e06039 100644
--- a/drivers/staging/et131x/et1310_pm.h
+++ b/drivers/staging/et131x/et1310_pm.h
@@ -66,15 +66,6 @@
 #define NUM_WOL_PATTERNS       0x5
 #define CRC16_POLY             0x1021
 
-/* Definition of NDIS_DEVICE_POWER_STATE */
-typedef enum {
-	NdisDeviceStateUnspecified = 0,
-	NdisDeviceStateD0,
-	NdisDeviceStateD1,
-	NdisDeviceStateD2,
-	NdisDeviceStateD3
-} NDIS_DEVICE_POWER_STATE;
-
 typedef struct _MP_POWER_MGMT {
 	/* variable putting the phy into coma mode when boot up with no cable
 	 * plugged in after 5 seconds
@@ -97,7 +88,6 @@ typedef struct _MP_POWER_MGMT {
 	} IPAddress;
 
 	/* Current Power state of the adapter. */
-	NDIS_DEVICE_POWER_STATE PowerState;
 	bool WOLState;
 	bool WOLEnabled;
 	bool Failed10Half;
diff --git a/drivers/staging/et131x/et1310_rx.c b/drivers/staging/et131x/et1310_rx.c
index 9dc08fb..b05b8c5 100644
--- a/drivers/staging/et131x/et1310_rx.c
+++ b/drivers/staging/et131x/et1310_rx.c
@@ -1235,13 +1235,11 @@ void et131x_handle_recv_interrupt(struct et131x_adapter *etdev)
 			break;
 
 		/* Do not receive any packets until a filter has been set.
-		 * Do not receive any packets until we are at D0.
 		 * Do not receive any packets until we have link.
 		 * If length is zero, return the RFD in order to advance the
 		 * Free buffer ring.
 		 */
 		if ((!etdev->PacketFilter) ||
-		    (etdev->PoMgmt.PowerState != NdisDeviceStateD0) ||
 		    (!MP_LINK_DETECTED(etdev)) ||
 		    (pMpRfd->PacketSize == 0)) {
 			continue;
diff --git a/drivers/staging/et131x/et131x_initpci.c b/drivers/staging/et131x/et131x_initpci.c
index b9018e6..d84b654 100644
--- a/drivers/staging/et131x/et131x_initpci.c
+++ b/drivers/staging/et131x/et131x_initpci.c
@@ -967,8 +967,6 @@ int __devinit et131x_pci_setup(struct pci_dev *pdev,
 	DBG_TRACE(et131x_dbginfo, "Init send data structures...\n");
 	et131x_init_send(adapter);
 
-	adapter->PoMgmt.PowerState = NdisDeviceStateD0;
-
 	/* Register the interrupt
 	 *
 	 * NOTE - This is being done in the open routine, where most other
diff --git a/drivers/staging/et131x/et131x_isr.c b/drivers/staging/et131x/et131x_isr.c
index 9f51425..f9687b3 100644
--- a/drivers/staging/et131x/et131x_isr.c
+++ b/drivers/staging/et131x/et131x_isr.c
@@ -479,6 +479,5 @@ void et131x_isr_handler(struct work_struct *work)
 		}
 	}
 
-	if (etdev->PoMgmt.PowerState == NdisDeviceStateD0)
-		et131x_enable_interrupts(etdev);
+	et131x_enable_interrupts(etdev);
 }

