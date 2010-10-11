From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 2/3] ATM: iphase, remove sleep-inside-atomic
Date: Mon, 11 Oct 2010 11:26:57 +0200
Message-ID: <1286789218-13976-2-git-send-email-jslaby@suse.cz>
References: <1286789218-13976-1-git-send-email-jslaby@suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Chas Williams <chas@cmf.nrl.navy.mil>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286789218-13976-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stanse found that ia_init_one locks a spinlock and inside of that it
calls ia_start which calls:
* request_irq
* tx_init which does kmalloc(GFP_KERNEL)

Both of them can thus sleep and result in a deadlock. I don't see a
reason to have a per-device spinlock there which is used only there
and inited right before the lock location. So remove it completely.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
---
 drivers/atm/iphase.c |    6 ------
 drivers/atm/iphase.h |    2 +-
 2 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 8b358d7..9309d47 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -3156,7 +3156,6 @@ static int __devinit ia_init_one(struct pci_dev *pdev,
 {  
 	struct atm_dev *dev;  
 	IADEV *iadev;  
-        unsigned long flags;
 	int ret;
 
 	iadev = kzalloc(sizeof(*iadev), GFP_KERNEL);
@@ -3188,19 +3187,14 @@ static int __devinit ia_init_one(struct pci_dev *pdev,
 	ia_dev[iadev_count] = iadev;
 	_ia_dev[iadev_count] = dev;
 	iadev_count++;
-	spin_lock_init(&iadev->misc_lock);
-	/* First fixes first. I don't want to think about this now. */
-	spin_lock_irqsave(&iadev->misc_lock, flags); 
 	if (ia_init(dev) || ia_start(dev)) {  
 		IF_INIT(printk("IA register failed!\n");)
 		iadev_count--;
 		ia_dev[iadev_count] = NULL;
 		_ia_dev[iadev_count] = NULL;
-		spin_unlock_irqrestore(&iadev->misc_lock, flags); 
 		ret = -EINVAL;
 		goto err_out_deregister_dev;
 	}
-	spin_unlock_irqrestore(&iadev->misc_lock, flags); 
 	IF_EVENT(printk("iadev_count = %d\n", iadev_count);)
 
 	iadev->next_board = ia_boards;  
diff --git a/drivers/atm/iphase.h b/drivers/atm/iphase.h
index b2cd20f..077735e 100644
--- a/drivers/atm/iphase.h
+++ b/drivers/atm/iphase.h
@@ -1022,7 +1022,7 @@ typedef struct iadev_t {
 	struct dle_q rx_dle_q;  
 	struct free_desc_q *rx_free_desc_qhead;  
 	struct sk_buff_head rx_dma_q;  
-        spinlock_t rx_lock, misc_lock;
+	spinlock_t rx_lock;
 	struct atm_vcc **rx_open;	/* list of all open VCs */  
         u16 num_rx_desc, rx_buf_sz, rxing;
         u32 rx_pkt_ram, rx_tmp_cnt;
-- 
1.7.3.1
