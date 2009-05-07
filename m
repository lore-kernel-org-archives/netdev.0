From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] e1000/e1000e/igb/ixgb: don't txhang after link
	down
Date: Thu, 07 May 2009 14:07:35 -0700
Message-ID: <20090507210734.20173.63453.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:44090 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751837AbZEGVHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 17:07:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

after the recent changes to wired drivers to use only
netif_carrier_off the driver can have outstanding tx work to
complete that will never complete once link is down.  Since the
intel hardware will hold this tx work forever, the driver
notices a tx timeout condition internally and might try
to instigate printk and reset of the part with a
netif_stop_queue, which doesn't work because link is down.

Don't bother arming to tx hang detection when link is down.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 ++
 drivers/net/e1000e/netdev.c    |    2 ++
 drivers/net/igb/igb_main.c     |    2 ++
 drivers/net/ixgb/ixgb_main.c   |    2 ++
 4 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 71d4fe1..b455dca 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2646,6 +2646,8 @@ static void e1000_watchdog(unsigned long data)
 			 * (Do the reset outside of interrupt context). */
 			adapter->tx_timeout_count++;
 			schedule_work(&adapter->reset_task);
+			/* return immediately since reset is imminent */
+			return;
 		}
 	}
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index da6b37e..ccaaee0 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3651,6 +3651,8 @@ link_up:
 			 */
 			adapter->tx_timeout_count++;
 			schedule_work(&adapter->reset_task);
+			/* return immediately since reset is imminent */
+			return;
 		}
 	}
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 8de8629..8784c05 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2711,6 +2711,8 @@ link_up:
 			 * (Do the reset outside of interrupt context). */
 			adapter->tx_timeout_count++;
 			schedule_work(&adapter->reset_task);
+			/* return immediately since reset is imminent */
+			return;
 		}
 	}
 
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index cb9ecc4..04cb81a 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1140,6 +1140,8 @@ ixgb_watchdog(unsigned long data)
 			 * to get done, so reset controller to flush Tx.
 			 * (Do the reset outside of interrupt context). */
 			schedule_work(&adapter->tx_timeout_task);
+			/* return immediately since reset is imminent */
+			return;
 		}
 	}
 

