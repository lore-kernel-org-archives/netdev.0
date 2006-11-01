From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.4] bridge netfilter deadlock
Date: Wed, 1 Nov 2006 11:45:50 -0800
Message-ID: <20061101114550.459eead0@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52353 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992776AbWKATp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 14:45:56 -0500
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A deadlock was found in bridge netfilter code (2.4 only), when a device is removed.
The device removal path causes a BPDU to be generated and ends up
self deadlocking on the BR lock.

Simple fix would be to avoid generating config bpdu's
immediately when becoming root bridge, and just let the first hello
timer tick do that.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.4.33.3.orig/net/bridge/br_stp.c	2006-10-30 12:46:59.000000000 -0800
+++ linux-2.4.33.3/net/bridge/br_stp.c	2006-10-30 12:53:59.000000000 -0800
@@ -140,8 +140,8 @@
 	br->forward_delay = br->bridge_forward_delay;
 	br_topology_change_detection(br);
 	br_timer_clear(&br->tcn_timer);
-	br_config_bpdu_generation(br);
-	br_timer_set(&br->hello_timer, jiffies);
+
+	br_timer_set(&br->hello_timer, jiffies - br->hello_time);
 }
 
 /* called under bridge lock */



-- 
Stephen Hemminger <shemminger@osdl.org>
