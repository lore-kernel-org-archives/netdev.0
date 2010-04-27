From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: ixgbe_down needs to stop dev_watchdog
Date: Tue, 27 Apr 2010 05:13:39 -0700
Message-ID: <20100427121300.25038.2341.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:39621 "EHLO
	qmta05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751386Ab0D0MN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 08:13:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

There is a small race between when the tx queues are stopped
and when netif_carrier_off() is called in ixgbe_down.  If the
dev_watchdog() timer fires during this time it is possible for
a false tx timeout to occur.

This patch moves the netif_carrier_off() so that it is called before
the tx queues are stopped preventing the dev_watchdog timer from
detecting false tx timeouts.  The race is seen occosionally when
FCoE or DCB settings are being configured or changed.

Testing note, running ifconfig up/down will not reproduce this
issue because dev_open/dev_close call dev_deactivate() and then
dev_activate().

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fe7e260..5258b3d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3291,22 +3291,23 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
 
-	netif_tx_disable(netdev);
-
 	IXGBE_WRITE_FLUSH(hw);
 	msleep(10);
 
 	netif_tx_stop_all_queues(netdev);
 
-	ixgbe_irq_disable(adapter);
-
-	ixgbe_napi_disable_all(adapter);
-
 	clear_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
 	del_timer_sync(&adapter->sfp_timer);
 	del_timer_sync(&adapter->watchdog_timer);
 	cancel_work_sync(&adapter->watchdog_task);
 
+	netif_carrier_off(netdev);
+	netif_tx_disable(netdev);
+
+	ixgbe_irq_disable(adapter);
+
+	ixgbe_napi_disable_all(adapter);
+
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
 	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
 		cancel_work_sync(&adapter->fdir_reinit_task);
@@ -3324,8 +3325,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 		                (IXGBE_READ_REG(hw, IXGBE_DMATXCTL) &
 		                 ~IXGBE_DMATXCTL_TE));
 
-	netif_carrier_off(netdev);
-
 	/* clear n-tuple filters that are cached */
 	ethtool_ntuple_flush(netdev);
 

