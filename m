From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 1/3] remove irq_sem from atl1
Date: Tue, 27 Feb 2007 12:28:43 -0500
Message-ID: <45E46A4B.5090506@redhat.com>
References: <20070220.4mi.25231800@egw.corp.redhat.com> <45E3FAB8.2090504@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060501080201090904020007"
Cc: jacliburn@bellsouth.net, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751922AbXB0R2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 12:28:52 -0500
In-Reply-To: <45E3FAB8.2090504@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060501080201090904020007
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Garzik wrote:
> Chris Snook wrote:
>> From: Chris Snook <csnook@redhat.com>
>>
>> Remove unnecessary irq_sem code from atl1 driver.  Tested with no 
>> problems.
>>
>> Signed-off-by: Chris Snook <csnook@redhat.com>
>> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> 
> ACK, but patch does not apply:
> 
> 
> Applying 'remove irq_sem from atl1'
> 
> error: patch fragment without header at line 7: @@ -236,7 +236,6 @@ 
> struct atl1_adapter {
> error: patch fragment without header at line 21: @@ -163,7 +163,6 @@ 
> static int __devinit atl1_sw_init(struct
> error: patch fragment without header at line 29: @@ -272,8 +271,7 @@ 
> err_nomem:
> error: patch fragment without header at line 39: @@ -1205,7 +1203,6 @@ 
> static u32 atl1_configure(struct atl1_ad
> error: No changes
> Patch failed at 0004.
> When you have resolved this problem run "git-am --resolved".
> If you would prefer to skip this patch, instead run "git-am --skip".

Huh, looks like my mailer line-wrapped the headers.  Patch didn't 
complain, but I guess git is pickier.  I've attached the patch to avoid 
text mangling.  Were there any problems with the e1000 and ixgb patches?

	-- Chris

--------------060501080201090904020007
Content-Type: text/x-patch;
 name="remove-irq_sem-atl1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="remove-irq_sem-atl1.patch"

diff -urp linux-2.6.20-git14.orig/drivers/net/atl1/atl1.h linux-2.6.20-git14/drivers/net/atl1/atl1.h
--- linux-2.6.20-git14.orig/drivers/net/atl1/atl1.h	2007-02-19 14:32:15.000000000 -0500
+++ linux-2.6.20-git14/drivers/net/atl1/atl1.h	2007-02-19 15:10:07.000000000 -0500
@@ -236,7 +236,6 @@ struct atl1_adapter {
 	u16 link_speed;
 	u16 link_duplex;
 	spinlock_t lock;
-	atomic_t irq_sem;
 	struct work_struct tx_timeout_task;
 	struct work_struct link_chg_task;
 	struct work_struct pcie_dma_to_rst_task;
diff -urp linux-2.6.20-git14.orig/drivers/net/atl1/atl1_main.c linux-2.6.20-git14/drivers/net/atl1/atl1_main.c
--- linux-2.6.20-git14.orig/drivers/net/atl1/atl1_main.c	2007-02-19 14:32:15.000000000 -0500
+++ linux-2.6.20-git14/drivers/net/atl1/atl1_main.c	2007-02-19 15:10:44.000000000 -0500
@@ -163,7 +163,6 @@ static int __devinit atl1_sw_init(struct
 	hw->cmb_tx_timer = 1;	/* about 2us */
 	hw->smb_timer = 100000;	/* about 200ms */
 
-	atomic_set(&adapter->irq_sem, 0);
 	spin_lock_init(&adapter->lock);
 	spin_lock_init(&adapter->mb_lock);
 
@@ -272,8 +271,7 @@ err_nomem:
  */
 static void atl1_irq_enable(struct atl1_adapter *adapter)
 {
-	if (likely(!atomic_dec_and_test(&adapter->irq_sem)))
-		iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
+	iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
 }
 
 static void atl1_clear_phy_int(struct atl1_adapter *adapter)
@@ -1205,7 +1203,6 @@ static u32 atl1_configure(struct atl1_ad
  */
 static void atl1_irq_disable(struct atl1_adapter *adapter)
 {
-	atomic_inc(&adapter->irq_sem);
 	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
 	ioread32(adapter->hw.hw_addr + REG_IMR);
 	synchronize_irq(adapter->pdev->irq);

--------------060501080201090904020007--
