From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM] iphase: BUG: sleeping function called from invalid context
Date: Sat, 14 Jun 2008 17:05:29 -0400
Message-ID: <200806142105.m5EL5T49003929@cmf.nrl.navy.mil>
References: <4848106F.30503@dti2.net>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:39797 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754593AbYFNVGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 17:06:00 -0400
In-reply-to: <4848106F.30503@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <4848106F.30503@dti2.net>,"Jorge Boncompte [DTI2]" writes:
>	iphase driver calls ioremap under spinlock_irqsave in his
>initialization function. The spinlock seems to be there just for the 
>sole purpose of preventing initializing multiple cards at once. So I 
>think that removing it should be fine.

the lock is necessary to prevent multiple cards from modifying iadev_count
at the wrong time since iadev_count is incremented and decremented.
it might be simpler to just make a local copy of iadev_count and just
always increment iadev_count.  if you fail to init a particular card,
you will just leave a hole in ia_dev[].  something like the attached.

also, ia_remove_one() is broken since it assumes that the cards will be
removed in the same order that they were installed.

even better would be to rewrite this to avoid the iadev[] array entirely
and use a linked list.


diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 5c28ca7..64d1c97 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -3171,7 +3171,6 @@ static int __devinit ia_init_one(struct pci_dev *pdev,
 {  
 	struct atm_dev *dev;  
 	IADEV *iadev;  
-        unsigned long flags;
 	int ret;
 
 	iadev = kzalloc(sizeof(*iadev), GFP_KERNEL);
@@ -3180,6 +3179,7 @@ static int __devinit ia_init_one(struct pci_dev *pdev,
 		goto err_out;
 	}
 
+	iadev->iadev_count = iadev_count++;
 	iadev->pci = pdev;
 
 	IF_INIT(printk("ia detected at bus:%d dev: %d function:%d\n",
@@ -3198,23 +3198,17 @@ static int __devinit ia_init_one(struct pci_dev *pdev,
 	IF_INIT(printk("dev_id = 0x%x iadev->LineRate = %d \n", (u32)dev,
 		iadev->LineRate);)
 
-	ia_dev[iadev_count] = iadev;
-	_ia_dev[iadev_count] = dev;
-	iadev_count++;
-	spin_lock_init(&iadev->misc_lock);
-	/* First fixes first. I don't want to think about this now. */
-	spin_lock_irqsave(&iadev->misc_lock, flags); 
+	ia_dev[iadev->iadev_count] = iadev;
+	_ia_dev[iadev->iadev_count] = dev;
 	if (ia_init(dev) || ia_start(dev)) {  
 		IF_INIT(printk("IA register failed!\n");)
 		iadev_count--;
-		ia_dev[iadev_count] = NULL;
-		_ia_dev[iadev_count] = NULL;
-		spin_unlock_irqrestore(&iadev->misc_lock, flags); 
+		ia_dev[iadev->iadev_count] = NULL;
+		_ia_dev[iadev->iadev_count] = NULL;
 		ret = -EINVAL;
 		goto err_out_deregister_dev;
 	}
-	spin_unlock_irqrestore(&iadev->misc_lock, flags); 
-	IF_EVENT(printk("iadev_count = %d\n", iadev_count);)
+	IF_EVENT(printk("iadev_count = %d\n", iadev->iadev_count);)
 
 	iadev->next_board = ia_boards;  
 	ia_boards = dev;  
@@ -3243,9 +3237,8 @@ static void __devexit ia_remove_one(struct pci_dev *pdev)
 
 	/* De-register device */  
       	free_irq(iadev->irq, dev);
-	iadev_count--;
-	ia_dev[iadev_count] = NULL;
-	_ia_dev[iadev_count] = NULL;
+	ia_dev[iadev->iadev_count] = NULL;
+	_ia_dev[iadev->iadev_count] = NULL;
 	IF_EVENT(printk("deregistering iav at (itf:%d)\n", dev->number);)
 	atm_dev_deregister(dev);
 
diff --git a/drivers/atm/iphase.h b/drivers/atm/iphase.h
index b2cd20f..a0b1982 100644
--- a/drivers/atm/iphase.h
+++ b/drivers/atm/iphase.h
@@ -1022,7 +1022,7 @@ typedef struct iadev_t {
 	struct dle_q rx_dle_q;  
 	struct free_desc_q *rx_free_desc_qhead;  
 	struct sk_buff_head rx_dma_q;  
-        spinlock_t rx_lock, misc_lock;
+        spinlock_t rx_lock;
 	struct atm_vcc **rx_open;	/* list of all open VCs */  
         u16 num_rx_desc, rx_buf_sz, rxing;
         u32 rx_pkt_ram, rx_tmp_cnt;
@@ -1064,6 +1064,7 @@ typedef struct iadev_t {
         struct testTable_t **testTable;
 	dma_addr_t tx_dle_dma;
 	dma_addr_t rx_dle_dma;
+	int iadev_count;
 } IADEV;
   
   
