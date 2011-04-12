From: David Miller <davem@davemloft.net>
Subject: [PATCH v2] atm: iphase: Fix set-but-not-used warnings.
Date: Tue, 12 Apr 2011 16:14:48 -0700 (PDT)
Message-ID: <20110412.161448.68136441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34675
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756330Ab1DLXPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 19:15:24 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E1DAC30001
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 16:14:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The "iavcc" and "iadev" cases are obvious.

The intr_status and frmr_intr cases are reading a register to clear
the chip status.  This driver is pretty old and creaky, and uses
volatile pointer dereferences to do register I/O when it should be
using readl() and friends.  However that it outside of the scope of
these changes.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/atm/iphase.c |   14 +++-----------
 1 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 1c674a9..dee4f01 100644
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
@@ -2660,7 +2656,6 @@ static void ia_close(struct atm_vcc *vcc)
   
 static int ia_open(struct atm_vcc *vcc)
 {  
-	IADEV *iadev;  
 	struct ia_vcc *ia_vcc;  
 	int error;  
 	if (!test_bit(ATM_VF_PARTIAL,&vcc->flags))  
@@ -2668,7 +2663,6 @@ static int ia_open(struct atm_vcc *vcc)
 		IF_EVENT(printk("ia: not partially allocated resources\n");)  
 		vcc->dev_data = NULL;
 	}  
-	iadev = INPH_IA_DEV(vcc->dev);  
 	if (vcc->vci != ATM_VPI_UNSPEC && vcc->vpi != ATM_VCI_UNSPEC)  
 	{  
 		IF_EVENT(printk("iphase open: unspec part\n");)  
@@ -3052,11 +3046,9 @@ static int ia_pkt_tx (struct atm_vcc *vcc, struct sk_buff *skb) {
 static int ia_send(struct atm_vcc *vcc, struct sk_buff *skb)
 {
         IADEV *iadev; 
-        struct ia_vcc *iavcc;
         unsigned long flags;
 
         iadev = INPH_IA_DEV(vcc->dev);
-        iavcc = INPH_IA_VCC(vcc); 
         if ((!skb)||(skb->len>(iadev->tx_buf_sz-sizeof(struct cpcs_trailer))))
         {
             if (!skb)
-- 
1.7.4.3

