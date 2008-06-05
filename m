From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH][ATM] iphase: BUG: sleeping function called from invalid context
Date: Thu, 05 Jun 2008 18:12:31 +0200
Message-ID: <4848106F.30503@dti2.net>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chas williams <chas@cmf.nrl.navy.mil>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:4512 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752352AbYFEQMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 12:12:40 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.6.5)
	with ESMTP id md50013608757.msg
	for <netdev@vger.kernel.org>; Thu, 05 Jun 2008 18:12:36 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	iphase driver calls ioremap under spinlock_irqsave in his
initialization function. The spinlock seems to be there just for the 
sole purpose of preventing initializing multiple cards at once. So I 
think that removing it should be fine.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
  drivers/atm/iphase.c |    6 ------
  drivers/atm/iphase.h |    2 +-
  2 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 5c28ca7..a51b7cb 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -3171,7 +3171,6 @@ static int __devinit ia_init_one(struct pci_dev *pdev,
  {
  	struct atm_dev *dev;
  	IADEV *iadev;
-        unsigned long flags;
  	int ret;

  	iadev = kzalloc(sizeof(*iadev), GFP_KERNEL);
@@ -3201,19 +3200,14 @@ static int __devinit ia_init_one(struct pci_dev 
*pdev,
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
index b2cd20f..f3457a9 100644
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
-- 

