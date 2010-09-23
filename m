From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] e1000: fix occasional panic on unload
Date: Wed, 22 Sep 2010 21:22:42 -0700
Message-ID: <20100923042240.11798.65680.stgit@localhost.localdomain>
References: <20100923042126.11798.49675.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:39000
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752555Ab0IWEXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 00:23:03 -0400
In-Reply-To: <20100923042126.11798.49675.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Net drivers in general have an issue where timers fired
by mod_timer or work threads with schedule_work are running
outside of the rtnl_lock.

With no other lock protection these routines are vulnerable
to races with driver unload or reset paths.

The longer term solution to this might be a redesign with
safer locks being taken in the driver to guarantee no
reentrance, but for now a safe and effective fix is
to take the rtnl_lock in these routines.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   20 +++++++++++++++++++-
 1 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 5b4c6c0..c88439d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -521,8 +521,21 @@ void e1000_down(struct e1000_adapter *adapter)
 	e1000_clean_all_rx_rings(adapter);
 }
 
+void e1000_reinit_safe(struct e1000_adapter *adapter)
+{
+	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
+		msleep(1);
+	rtnl_lock();
+	e1000_down(adapter);
+	e1000_up(adapter);
+	rtnl_unlock();
+	clear_bit(__E1000_RESETTING, &adapter->flags);
+}
+
 void e1000_reinit_locked(struct e1000_adapter *adapter)
 {
+	/* if rtnl_lock is not held the call path is bogus */
+	ASSERT_RTNL();
 	WARN_ON(in_interrupt());
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
 		msleep(1);
@@ -2247,7 +2260,10 @@ static void e1000_update_phy_info_task(struct work_struct *work)
 	                                             struct e1000_adapter,
 	                                             phy_info_task);
 	struct e1000_hw *hw = &adapter->hw;
+
+	rtnl_lock();
 	e1000_phy_get_info(hw, &adapter->phy_info);
+	rtnl_unlock();
 }
 
 /**
@@ -2273,6 +2289,7 @@ static void e1000_82547_tx_fifo_stall_task(struct work_struct *work)
 	struct net_device *netdev = adapter->netdev;
 	u32 tctl;
 
+	rtnl_lock();
 	if (atomic_read(&adapter->tx_fifo_stall)) {
 		if ((er32(TDT) == er32(TDH)) &&
 		   (er32(TDFT) == er32(TDFH)) &&
@@ -2293,6 +2310,7 @@ static void e1000_82547_tx_fifo_stall_task(struct work_struct *work)
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
 		}
 	}
+	rtnl_unlock();
 }
 
 bool e1000_has_link(struct e1000_adapter *adapter)
@@ -3160,7 +3178,7 @@ static void e1000_reset_task(struct work_struct *work)
 	struct e1000_adapter *adapter =
 		container_of(work, struct e1000_adapter, reset_task);
 
-	e1000_reinit_locked(adapter);
+	e1000_reinit_safe(adapter);
 }
 
 /**

