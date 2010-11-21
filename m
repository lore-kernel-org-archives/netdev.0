From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000: fix screaming IRQ
Date: Sun, 21 Nov 2010 02:48:28 -0800
Message-ID: <20101121104747.17414.88773.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Anupam Chanda <anupamc@vmware.com>,
	stable kernel <stable@kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:56406 "EHLO
	qmta05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751384Ab0KUKsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 05:48:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anupam Chanda <anupamc@vmware.com>

VMWare reports that the e1000 driver has a bug when bringing down the
interface, such that interrupts are not disabled in the hardware but the
driver stops reporting that it consumed the interrupt.

The fix is to set the driver's "down" flag later in the routine,
after all the timers and such have exited, preventing the interrupt
handler from being called and exiting early without handling the
interrupt.

CC: Anupam Chanda <anupamc@vmware.com>
CC: stable kernel <stable@kernel.org>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4686c39..4d62f7b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -31,7 +31,7 @@
 
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-#define DRV_VERSION "7.3.21-k6-NAPI"
+#define DRV_VERSION "7.3.21-k8-NAPI"
 const char e1000_driver_version[] = DRV_VERSION;
 static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
@@ -485,9 +485,6 @@ void e1000_down(struct e1000_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	u32 rctl, tctl;
 
-	/* signal that we're down so the interrupt handler does not
-	 * reschedule our watchdog timer */
-	set_bit(__E1000_DOWN, &adapter->flags);
 
 	/* disable receives in the hardware */
 	rctl = er32(RCTL);
@@ -508,6 +505,13 @@ void e1000_down(struct e1000_adapter *adapter)
 
 	e1000_irq_disable(adapter);
 
+	/*
+	 * Setting DOWN must be after irq_disable to prevent
+	 * a screaming interrupt.  Setting DOWN also prevents
+	 * timers and tasks from rescheduling.
+	 */
+	set_bit(__E1000_DOWN, &adapter->flags);
+
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);

