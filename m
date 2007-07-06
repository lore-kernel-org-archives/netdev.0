From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] net: netdevice locking assumptions documentation
Date: Fri, 6 Jul 2007 11:26:23 -0700
Message-ID: <20070706112623.478aedcf@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38770 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762449AbXGFSdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 14:33:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the documentation about locking assumptions.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/Documentation/networking/netdevices.txt	2007-06-25 09:03:04.000000000 -0700
+++ b/Documentation/networking/netdevices.txt	2007-07-06 10:15:31.000000000 -0700
@@ -20,7 +20,6 @@ private data which gets freed when the n
 separately allocated data is attached to the network device
 (dev->priv) then it is up to the module exit handler to free that.
 
-
 struct net_device synchronization rules
 =======================================
 dev->open:
@@ -43,16 +42,17 @@ dev->get_stats:
 
 dev->hard_start_xmit:
 	Synchronization: netif_tx_lock spinlock.
+
 	When the driver sets NETIF_F_LLTX in dev->features this will be
 	called without holding netif_tx_lock. In this case the driver
 	has to lock by itself when needed. It is recommended to use a try lock
-	for this and return -1 when the spin lock fails. 
+	for this and return NETDEV_TX_LOCKED when the spin lock fails.
 	The locking there should also properly protect against 
-	set_multicast_list
-	Context: Process with BHs disabled or BH (timer).
-	Notes: netif_queue_stopped() is guaranteed false
-               Interrupts must be enabled when calling hard_start_xmit.
-                (Interrupts must also be enabled when enabling the BH handler.)
+	set_multicast_list.
+
+	Context: Process with BHs disabled or BH (timer),
+	         will be called with interrupts disabled by netconsole.
+
 	Return codes: 
 	o NETDEV_TX_OK everything ok. 
 	o NETDEV_TX_BUSY Cannot transmit packet, try later 
@@ -74,4 +74,5 @@ dev->poll:
 	Synchronization: __LINK_STATE_RX_SCHED bit in dev->state.  See
 		dev_close code and comments in net/core/dev.c for more info.
 	Context: softirq
+	         will be called with interrupts disabled by netconsole.
 
