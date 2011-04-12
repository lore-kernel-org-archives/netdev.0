From: David Miller <davem@davemloft.net>
Subject: [PATCH] atm: iphase: Fix set-but-not-used warnings.
Date: Tue, 12 Apr 2011 16:10:47 -0700 (PDT)
Message-ID: <20110412.161047.233699167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53930
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756225Ab1DLXLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 19:11:22 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 37FB830001
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 16:10:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The "iavcc" case is obvious.

The intr_status and frmr_intr cases are reading a register to clear
the chip status.  This driver is pretty old and creaky, and uses
volatile pointer dereferences to do register I/O when it should be
using readl() and friends.  However that it outside of the scope of
these changes.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/atm/iphase.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 1c674a9..bb7e139 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -613,7 +613,6 @@ static int ia_que_tx (IADEV *iadev) {
    struct sk_buff *skb;
    int num_desc;
    struct atm_vcc *vcc;
-   struct ia_vcc *iavcc;
    num_desc = ia_avail_descs(iadev);
 
    while (num_desc && (skb = skb_dequeue(&iadev->tx_backlog))) {
@@ -627,7 +626,6 @@ static int ia_que_tx (IADEV *iadev) {
          printk("Free the SKB on closed vci %d \n", vcc->vci);
          break;
       }
-      iavcc = INPH_IA_VCC(vcc);
       if (ia_pkt_tx (vcc, skb)) {
          skb_queue_head(&iadev->tx_backlog, skb);
       }
@@ -823,8 +821,6 @@ static void IaFrontEndIntr(IADEV *iadev) {
   volatile IA_SUNI *suni;
   volatile ia_mb25_t *mb25;
   volatile suni_pm7345_t *suni_pm7345;
-  u32 intr_status;
-  u_int frmr_intr;
 
   if(iadev->phy_type & FE_25MBIT_PHY) {
      mb25 = (ia_mb25_t*)iadev->phy;
@@ -832,18 +828,18 @@ static void IaFrontEndIntr(IADEV *iadev) {
   } else if (iadev->phy_type & FE_DS3_PHY) {
      suni_pm7345 = (suni_pm7345_t *)iadev->phy;
      /* clear FRMR interrupts */
-     frmr_intr   = suni_pm7345->suni_ds3_frm_intr_stat; 
+     (void) suni_pm7345->suni_ds3_frm_intr_stat; 
      iadev->carrier_detect =  
            Boolean(!(suni_pm7345->suni_ds3_frm_stat & SUNI_DS3_LOSV));
   } else if (iadev->phy_type & FE_E3_PHY ) {
      suni_pm7345 = (suni_pm7345_t *)iadev->phy;
-     frmr_intr   = suni_pm7345->suni_e3_frm_maint_intr_ind;
+     (void) suni_pm7345->suni_e3_frm_maint_intr_ind;
      iadev->carrier_detect =
            Boolean(!(suni_pm7345->suni_e3_frm_fram_intr_ind_stat&SUNI_E3_LOS));
   }
   else { 
      suni = (IA_SUNI *)iadev->phy;
-     intr_status = suni->suni_rsop_status & 0xff;
+     (void) suni->suni_rsop_status;
      iadev->carrier_detect = Boolean(!(suni->suni_rsop_status & SUNI_LOSV));
   }
   if (iadev->carrier_detect)
-- 
1.7.4.3

