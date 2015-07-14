From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH net-next]r8169: Serialise some operations from open close
Date: Tue, 14 Jul 2015 23:23:11 +0300
Message-ID: <20150714202311.GA5189@192-168-0-3.rdsnet.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f66.google.com ([74.125.82.66]:33275 "EHLO
	mail-wg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238AbbGNUXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 16:23:15 -0400
Received: by wgwk7 with SMTP id k7so1640634wgw.0
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 13:23:14 -0700 (PDT)
Received: from 192-168-0-3 (5-14-229-57.residential.rdsnet.ro. [5.14.229.57])
        by smtp.gmail.com with ESMTPSA id dz4sm22709280wib.17.2015.07.14.13.23.12
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jul 2015 13:23:13 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------mine-boundary-string
Content-Type: text/plain; charset=UTF-8; format=fixed
Content-Transfer-Encoding: 8bit


Serialize some operations from open close function especial when write
read from main structure(struct rtl8169_private).Ensure that alls op is
executed.On slow proc this is good.
 Committer: Corcodel Marian <corcodel.marian@gmail.com>

 On branch master
 Your branch is ahead of 'origin/master' by 14 commits.
   (use "git push" to publish your local commits)

 Changes to be committed:
	modified:   drivers/net/ethernet/realtek/r8169.c

Signed-off-by: Corcodel Marian <asu@192-168-0-3.rdsnet.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)


--------------mine-boundary-string
Content-Type: text/x-patch; name="0001-Signed-off-by-Corcodel-Marian-corcodel.marian-gmail..patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="0001-Signed-off-by-Corcodel-Marian-corcodel.marian-gmail..patch"

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 410c1ee..be67873 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7555,11 +7555,13 @@ static int rtl8169_close(struct net_device *dev)
 
 	rtl_lock_work(tp);
 	clear_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
-
-	rtl8169_down(dev);
 	rtl_unlock_work(tp);
 
+	rtl8169_down(dev);
+	//rtl_unlock_work(tp);
+        rtl_lock_work(tp);
 	cancel_work_sync(&tp->wk.work);
+	rtl_unlock_work(tp);
 
 	free_irq(pdev->irq, dev);
 
@@ -7567,9 +7569,10 @@ static int rtl8169_close(struct net_device *dev)
 			  tp->RxPhyAddr);
 	dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->TxDescArray,
 			  tp->TxPhyAddr);
+	rtl_lock_work(tp);
 	tp->TxDescArray = NULL;
 	tp->RxDescArray = NULL;
-
+        rtl_unlock_work(tp);
 	pm_runtime_put_sync(&pdev->dev);
 
 	return 0;
@@ -7611,10 +7614,12 @@ static int rtl_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_free_rx_1;
 
+        rtl_lock_work(tp);
 	INIT_WORK(&tp->wk.work, rtl_task);
-
+        rtl_unlock_work(tp);
 	smp_mb();
 
+        rtl_lock_work(tp);
 	rtl_request_firmware(tp);
 
 	retval = request_irq(pdev->irq, rtl8169_interrupt,
@@ -7623,7 +7628,7 @@ static int rtl_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_release_fw_2;
 
-	rtl_lock_work(tp);
+	//rtl_lock_work(tp);
 
 	set_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
 
@@ -7634,17 +7639,21 @@ static int rtl_open(struct net_device *dev)
        //__rtl8169_set_features(dev, dev->features);
 
 	rtl_pll_power_up(tp);
+	rtl_unlock_work(tp);
 
 	rtl_hw_start(dev);
 
 	netif_start_queue(dev);
 
-	rtl_unlock_work(tp);
-
+	rtl_lock_work(tp);
 	tp->saved_wolopts = 0;
-	pm_runtime_put_noidle(&pdev->dev);
+	rtl_unlock_work(tp);
 
+	pm_runtime_put_noidle(&pdev->dev)
+		;
+        rtl_lock_work(tp);
 	rtl8169_check_link_status(dev, tp, ioaddr);
+	rtl_unlock_work(tp);
 out:
 	return retval;
 

--------------mine-boundary-string--
