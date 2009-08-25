From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 05/26] et131x: kill refcount
Date: Tue, 25 Aug 2009 15:58:11 +0100
Message-ID: <20090825145804.16176.38223.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:42580 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755320AbZHYPDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:03:33 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RefCount field is accessed only by a macro and the only use of it in
the tree is to read it, so it can go

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et1310_pm.c      |    2 --
 drivers/staging/et131x/et1310_rx.c      |    7 -------
 drivers/staging/et131x/et131x_adapter.h |    4 ----
 3 files changed, 0 insertions(+), 13 deletions(-)


diff --git a/drivers/staging/et131x/et1310_pm.c b/drivers/staging/et131x/et1310_pm.c
index a507411..848d6b0 100644
--- a/drivers/staging/et131x/et1310_pm.c
+++ b/drivers/staging/et131x/et1310_pm.c
@@ -139,8 +139,6 @@ void EnablePhyComa(struct et131x_adapter *etdev)
 	spin_unlock_irqrestore(&etdev->SendHWLock, flags);
 
 	/* Wait for outstanding Receive packets */
-	while ((MP_GET_RCV_REF(etdev) != 0) && (LoopCounter-- > 0))
-		mdelay(2);
 
 	/* Gate off JAGCore 3 clock domains */
 	GlobalPmCSR.bits.pm_sysclk_gate = 0;
diff --git a/drivers/staging/et131x/et1310_rx.c b/drivers/staging/et131x/et1310_rx.c
index b05b8c5..6423552 100644
--- a/drivers/staging/et131x/et1310_rx.c
+++ b/drivers/staging/et131x/et1310_rx.c
@@ -1258,13 +1258,6 @@ void et131x_handle_recv_interrupt(struct et131x_adapter *etdev)
 			 * Besides, we don't really need (at this point) the
 			 * pending list anyway.
 			 */
-			/* spin_lock_irqsave( &etdev->RcvPendLock, flags );
-			 * list_add_tail( &pMpRfd->list_node, &etdev->RxRing.RecvPendingList );
-			 * spin_unlock_irqrestore( &etdev->RcvPendLock, flags );
-			 */
-
-			/* Update the number of outstanding Recvs */
-			/* MP_INC_RCV_REF( etdev ); */
 		} else {
 			RFDFreeArray[PacketFreeCount] = pMpRfd;
 			PacketFreeCount++;
diff --git a/drivers/staging/et131x/et131x_adapter.h b/drivers/staging/et131x/et131x_adapter.h
index 82686ea..04de4ff 100644
--- a/drivers/staging/et131x/et131x_adapter.h
+++ b/drivers/staging/et131x/et131x_adapter.h
@@ -108,8 +108,6 @@
 #define MP_TEST_FLAGS(_M, _F)       (((_M)->Flags & (_F)) == (_F))
 #define MP_IS_FLAG_CLEAR(_M, _F)    (((_M)->Flags & (_F)) == 0)
 
-#define MP_GET_RCV_REF(_A)          atomic_read(&(_A)->RcvRefCount)
-
 /* Macros specific to the private adapter structure */
 #define MP_TCB_RESOURCES_AVAILABLE(_M) ((_M)->TxRing.nBusySend < NUM_TCB)
 #define MP_TCB_RESOURCES_NOT_AVAILABLE(_M) ((_M)->TxRing.nBusySend >= NUM_TCB)
@@ -311,8 +309,6 @@ struct et131x_adapter {
 	MP_POWER_MGMT PoMgmt;
 	INTERRUPT_t CachedMaskValue;
 
-	atomic_t RcvRefCount;	/* Num packets not yet returned */
-
 	/* Xcvr status at last poll */
 	MI_BMSR_t Bmsr;
 

