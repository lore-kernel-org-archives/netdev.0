From: akpm@osdl.org
Subject: [patch 9/9] iPhase: 64bit cleanup
Date: Fri, 20 Oct 2006 14:43:18 -0700
Message-ID: <200610202143.k9KLhIgN003813@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, alan@lxorguk.ukuu.org.uk,
	alan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49284 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946178AbWJTVno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:43:44 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan@lxorguk.ukuu.org.uk>

Signed-off-by: Alan Cox <alan@redhat.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/atm/Kconfig  |    2 +-
 drivers/atm/iphase.c |   23 ++++++++++-------------
 2 files changed, 11 insertions(+), 14 deletions(-)

diff -puN drivers/atm/Kconfig~resend-iphase-64bit-cleanup drivers/atm/Kconfig
--- a/drivers/atm/Kconfig~resend-iphase-64bit-cleanup
+++ a/drivers/atm/Kconfig
@@ -289,7 +289,7 @@ config ATM_HORIZON_DEBUG
 
 config ATM_IA
 	tristate "Interphase ATM PCI x575/x525/x531"
-	depends on PCI && ATM && !64BIT
+	depends on PCI && ATM
 	---help---
 	  This is a driver for the Interphase (i)ChipSAR adapter cards
 	  which include a variety of variants in term of the size of the
diff -puN drivers/atm/iphase.c~resend-iphase-64bit-cleanup drivers/atm/iphase.c
--- a/drivers/atm/iphase.c~resend-iphase-64bit-cleanup
+++ a/drivers/atm/iphase.c
@@ -93,10 +93,6 @@ module_param(IADebugFlag, uint, 0644);
 
 MODULE_LICENSE("GPL");
 
-#if BITS_PER_LONG != 32
-#  error FIXME: this driver only works on 32-bit platforms
-#endif
-
 /**************************** IA_LIB **********************************/
 
 static void ia_init_rtn_q (IARTN_Q *que) 
@@ -1408,7 +1404,6 @@ static int rx_init(struct atm_dev *dev) 
 	struct abr_vc_table  *abr_vc_table; 
 	u16 *vc_table;  
 	u16 *reass_table;  
-        u16 *ptr16;
 	int i,j, vcsize_sel;  
 	u_short freeq_st_adr;  
 	u_short *freeq_start;  
@@ -1423,14 +1418,15 @@ static int rx_init(struct atm_dev *dev) 
 		printk(KERN_ERR DEV_LABEL "can't allocate DLEs\n");
 		goto err_out;
 	}
-	iadev->rx_dle_q.start = (struct dle*)dle_addr;  
+	iadev->rx_dle_q.start = (struct dle *)dle_addr;
 	iadev->rx_dle_q.read = iadev->rx_dle_q.start;  
 	iadev->rx_dle_q.write = iadev->rx_dle_q.start;  
-	iadev->rx_dle_q.end = (struct dle*)((u32)dle_addr+sizeof(struct dle)*DLE_ENTRIES);  
+	iadev->rx_dle_q.end = (struct dle*)((unsigned long)dle_addr+sizeof(struct dle)*DLE_ENTRIES);
 	/* the end of the dle q points to the entry after the last  
 	DLE that can be used. */  
   
 	/* write the upper 20 bits of the start address to rx list address register */  
+	/* We know this is 32bit bus addressed so the following is safe */
 	writel(iadev->rx_dle_dma & 0xfffff000,
 	       iadev->dma + IPHASE5575_RX_LIST_ADDR);  
 	IF_INIT(printk("Tx Dle list addr: 0x%08x value: 0x%0x\n", 
@@ -1584,11 +1580,12 @@ static int rx_init(struct atm_dev *dev) 
 	   Set Packet Aging Interval count register to overflow in about 4 us
  	*/  
         writew(0xF6F8, iadev->reass_reg+PKT_TM_CNT );
-        ptr16 = (u16*)j;
-        i = ((u32)ptr16 >> 6) & 0xff;
-	ptr16  += j - 1;
-	i |=(((u32)ptr16 << 2) & 0xff00);
+
+        i = (j >> 6) & 0xFF;
+        j += 2 * (j - 1);
+        i |= ((j << 2) & 0xFF00);
         writew(i, iadev->reass_reg+TMOUT_RANGE);
+
         /* initiate the desc_tble */
         for(i=0; i<iadev->num_tx_desc;i++)
             iadev->desc_tbl[i].timestamp = 0;
@@ -1911,7 +1908,7 @@ static int tx_init(struct atm_dev *dev) 
 	iadev->tx_dle_q.start = (struct dle*)dle_addr;  
 	iadev->tx_dle_q.read = iadev->tx_dle_q.start;  
 	iadev->tx_dle_q.write = iadev->tx_dle_q.start;  
-	iadev->tx_dle_q.end = (struct dle*)((u32)dle_addr+sizeof(struct dle)*DLE_ENTRIES);  
+	iadev->tx_dle_q.end = (struct dle*)((unsigned long)dle_addr+sizeof(struct dle)*DLE_ENTRIES);
 
 	/* write the upper 20 bits of the start address to tx list address register */  
 	writel(iadev->tx_dle_dma & 0xfffff000,
@@ -2913,7 +2910,7 @@ static int ia_pkt_tx (struct atm_vcc *vc
                  dev_kfree_skb_any(skb);
           return 0;
         }
-        if ((u32)skb->data & 3) {
+        if ((unsigned long)skb->data & 3) {
            printk("Misaligned SKB\n");
            if (vcc->pop)
                  vcc->pop(vcc, skb);
_
