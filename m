From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/4] s2io: RTNL and flush_scheduled_work deadlock
Date: Thu, 15 Feb 2007 23:37:50 +0100
Message-ID: <20070215223750.GD19840@electric-eye.fr.zoreil.com>
References: <20070214132729.479793ac@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59160 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161602AbXBOWoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 17:44:37 -0500
Content-Disposition: inline
In-Reply-To: <20070214132729.479793ac@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mantra: don't use flush_scheduled_work with RTNL held.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/s2io.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index e8e0d94..fd85648 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3758,7 +3758,6 @@ static int s2io_close(struct net_device *dev)
 {
 	struct s2io_nic *sp = dev->priv;
 
-	flush_scheduled_work();
 	netif_stop_queue(dev);
 	/* Reset card, kill tasklet and free Tx and Rx buffers. */
 	s2io_card_down(sp);
@@ -5847,9 +5846,14 @@ static void s2io_set_link(struct work_struct *work)
 	register u64 val64;
 	u16 subid;
 
+	rtnl_lock();
+
+	if (!netif_running(dev))
+		goto out_unlock;
+
 	if (test_and_set_bit(0, &(nic->link_state))) {
 		/* The card is being reset, no point doing anything */
-		return;
+		goto out_unlock;
 	}
 
 	subid = nic->pdev->subsystem_device;
@@ -5903,6 +5907,9 @@ static void s2io_set_link(struct work_struct *work)
 		s2io_link(nic, LINK_DOWN);
 	}
 	clear_bit(0, &(nic->link_state));
+
+out_unlock:
+	rtnl_lock();
 }
 
 static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
@@ -6356,6 +6363,11 @@ static void s2io_restart_nic(struct work_struct *work)
 	struct s2io_nic *sp = container_of(work, struct s2io_nic, rst_timer_task);
 	struct net_device *dev = sp->dev;
 
+	rtnl_lock();
+
+	if (!netif_running(dev))
+		goto out_unlock;
+
 	s2io_card_down(sp);
 	if (s2io_card_up(sp)) {
 		DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n",
@@ -6364,7 +6376,8 @@ static void s2io_restart_nic(struct work_struct *work)
 	netif_wake_queue(dev);
 	DBG_PRINT(ERR_DBG, "%s: was reset by Tx watchdog timer\n",
 		  dev->name);
-
+out_unlock:
+	rtnl_unlock();
 }
 
 /**
@@ -7173,6 +7186,8 @@ static void __devexit s2io_rem_nic(struct pci_dev *pdev)
 		return;
 	}
 
+	flush_scheduled_work();
+
 	sp = dev->priv;
 	unregister_netdev(dev);
 
-- 
1.4.4.4

