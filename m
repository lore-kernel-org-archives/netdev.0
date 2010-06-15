From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: fdb cleanup runs too often
Date: Tue, 15 Jun 2010 09:14:12 -0700
Message-ID: <20100615091412.17e0d656@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37386 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752358Ab0FOQOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 12:14:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is common in end-node, non STP bridges to set forwarding
delay to zero; which causes the forwarding database cleanup
to run every clock tick. Change to run only as soon as needed
or at next ageing timer interval which ever is sooner.

Use round_jiffies_up macro rather than attempting round up
by changing value.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This is 2.6.35 bug fix, and should also be considered
for stable because of the performance impact.

--- a/net/bridge/br_fdb.c	2010-06-15 08:47:57.624465674 -0700
+++ b/net/bridge/br_fdb.c	2010-06-15 08:53:45.407855065 -0700
@@ -128,7 +128,7 @@ void br_fdb_cleanup(unsigned long _data)
 {
 	struct net_bridge *br = (struct net_bridge *)_data;
 	unsigned long delay = hold_time(br);
-	unsigned long next_timer = jiffies + br->forward_delay;
+	unsigned long next_timer = jiffies + br->ageing_time;
 	int i;
 
 	spin_lock_bh(&br->hash_lock);
@@ -149,9 +149,7 @@ void br_fdb_cleanup(unsigned long _data)
 	}
 	spin_unlock_bh(&br->hash_lock);
 
-	/* Add HZ/4 to ensure we round the jiffies upwards to be after the next
-	 * timer, otherwise we might round down and will have no-op run. */
-	mod_timer(&br->gc_timer, round_jiffies(next_timer + HZ/4));
+	mod_timer(&br->gc_timer, round_jiffies_up(next_timer));
 }
 
 /* Completely flush all dynamic entries in forwarding database.*/
