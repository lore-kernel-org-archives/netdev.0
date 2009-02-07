From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 15/26] igb: remove redundant timer updates and
	cleanup watchdog_task
Date: Sat, 07 Feb 2009 01:19:50 -0800
Message-ID: <20090207091950.15697.29830.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:55536
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752373AbZBGJUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:20:10 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The igb watchdog task is modifying the watchdog timer twice duing a single
run.  It only needs to be called once to reschedule itself for 2 seconds from
the last time it ran.

In addition I removed the allocation of the mac_info structure since it is
only called twice and is easier to access via the e1000_hw struct.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3bf560f..cbb3858 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2314,13 +2314,10 @@ static void igb_watchdog_task(struct work_struct *work)
 	struct igb_adapter *adapter = container_of(work,
 					struct igb_adapter, watchdog_task);
 	struct e1000_hw *hw = &adapter->hw;
-
 	struct net_device *netdev = adapter->netdev;
 	struct igb_ring *tx_ring = adapter->tx_ring;
-	struct e1000_mac_info *mac = &adapter->hw.mac;
 	u32 link;
 	u32 eics = 0;
-	s32 ret_val;
 	int i;
 
 	link = igb_has_link(adapter);
@@ -2365,6 +2362,7 @@ static void igb_watchdog_task(struct work_struct *work)
 			netif_carrier_on(netdev);
 			netif_tx_wake_all_queues(netdev);
 
+			/* link state has changed, schedule phy info update */
 			if (!test_bit(__IGB_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
 					  round_jiffies(jiffies + 2 * HZ));
@@ -2378,6 +2376,8 @@ static void igb_watchdog_task(struct work_struct *work)
 			       netdev->name);
 			netif_carrier_off(netdev);
 			netif_tx_stop_all_queues(netdev);
+
+			/* link state has changed, schedule phy info update */
 			if (!test_bit(__IGB_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
 					  round_jiffies(jiffies + 2 * HZ));
@@ -2387,9 +2387,9 @@ static void igb_watchdog_task(struct work_struct *work)
 link_up:
 	igb_update_stats(adapter);
 
-	mac->tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;
+	hw->mac.tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;
 	adapter->tpt_old = adapter->stats.tpt;
-	mac->collision_delta = adapter->stats.colc - adapter->colc_old;
+	hw->mac.collision_delta = adapter->stats.colc - adapter->colc_old;
 	adapter->colc_old = adapter->stats.colc;
 
 	adapter->gorc = adapter->stats.gorc - adapter->gorc_old;

