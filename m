From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] bridge: reduce frequency of forwarding cleanup timer in
 bridge
Date: Wed, 30 May 2007 12:12:52 -0700
Message-ID: <20070530121252.1248f506@freepuppy>
References: <20070519224605.GG14235@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Baruch Even <baruch@ev-en.org>, netdev@vger.kernel.org,
	power@bughost.org, bridge@linux-foundation.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:60035 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752892AbXE3T00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 15:26:26 -0400
In-Reply-To: <20070519224605.GG14235@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bridge cleanup timer is fired 10 times a second for timers that are
at least 15 seconds ahead in time and that are not critical to be
cleaned asap.

This patch calculates the next time to run the timer as the minimum of
all timers or a minimum based on the current state.

Signed-off-by: Baruch Even <baruch@ev-en.org>
Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- 2.6.22-rc2/net/bridge/br_fdb.c	2007-05-20 00:51:11.000000000 +0300
+++ 2.6-rc2/net/bridge/br_fdb.c	2007-05-20 00:50:31.000000000 +0300
@@ -121,6 +121,7 @@
 {
 	struct net_bridge *br = (struct net_bridge *)_data;
 	unsigned long delay = hold_time(br);
+	unsigned long next_timer = jiffies + br->forward_delay;
 	int i;
 
 	spin_lock_bh(&br->hash_lock);
@@ -129,14 +130,21 @@
 		struct hlist_node *h, *n;
 
 		hlist_for_each_entry_safe(f, h, n, &br->hash[i], hlist) {
+			unsigned long this_timer;
+			if (f->is_static)
+				continue;
+			this_timer = f->ageing_timer + delay;
+			if (time_before_eq(this_timer, jiffies))
-			if (!f->is_static &&
-			    time_before_eq(f->ageing_timer + delay, jiffies))
 				fdb_delete(f);
+			else if (this_timer < next_timer)
+				next_timer = this_timer;
 		}
 	}
 	spin_unlock_bh(&br->hash_lock);
 
+	/* Add HZ/4 to ensure we round the jiffies upwards to be after the next
+	 * timer, otherwise we might round down and will have no-op run. */
+	mod_timer(&br->gc_timer, round_jiffies(next_timer + HZ/4));
-	mod_timer(&br->gc_timer, jiffies + HZ/10);
 }
 
 /* Completely flush all dynamic entries in forwarding database.*/

