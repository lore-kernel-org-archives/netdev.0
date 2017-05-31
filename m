From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] enic: Fix another sleep-in-atomic bug
Date: Wed, 31 May 2017 10:43:40 +0800
Message-ID: <1496198620-1840-1-git-send-email-baijiaju1990@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jia-Ju Bai <baijiaju1990@163.com>
To: benve@cisco.com, _govind@gmx.com, neepatel@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-11.163.com ([220.181.12.11]:50325 "EHLO m12-11.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751039AbdEaClk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 22:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver may sleep under a spin lock in some function call paths.
The 1st function call path is:
enic_tx_hang_reset (acquire the lock by spin_lock)
  enic_stop
    enic_synchronize_irqs
      synchronize_irq --> may sleep
The 2nd function call path is:
enic_tx_hang_reset (acquire the lock by spin_lock)
  enic_dev_wait
    schedule_timeout_uninterruptible --> may sleep
The 3rd function call path is:
enic_tx_hang_reset (acquire the lock by spin_lock)
  enic_open
    enic_request_intr
      enic_set_rx_cpu_rmap
        enic_free_rx_cpu_rmap
          free_irq_cpu_rmap --> may sleep

To fix it, the "spin_lock" and "spin_unlock" are removed 
in enic_tx_hang_reset.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 4b87bee..d6523e2 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2330,7 +2330,6 @@ static void enic_tx_hang_reset(struct work_struct *work)
 
 	rtnl_lock();
 
-	spin_lock(&enic->enic_api_lock);
 	enic_dev_hang_notify(enic);
 	enic_stop(enic->netdev);
 	enic_dev_hang_reset(enic);
@@ -2339,7 +2338,6 @@ static void enic_tx_hang_reset(struct work_struct *work)
 	enic_set_rss_nic_cfg(enic);
 	enic_dev_set_ig_vlan_rewrite_mode(enic);
 	enic_open(enic->netdev);
-	spin_unlock(&enic->enic_api_lock);
 	call_netdevice_notifiers(NETDEV_REBOOT, enic->netdev);
 
 	rtnl_unlock();
-- 
1.7.9.5
