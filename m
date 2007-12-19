From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] net: flow hash timer power saving
Date: Tue, 18 Dec 2007 18:18:27 -0800
Message-ID: <20071218181827.5a35d634@shemminger-laptop>
References: <Pine.LNX.4.64.0712181956180.3616@mini.warudkars.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: parag.warudkar@gmail.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34650 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751135AbXLSCSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 21:18:45 -0500
In-Reply-To: <Pine.LNX.4.64.0712181956180.3616@mini.warudkars.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The net flow hash randomization timer runs every 10 minutes.
This time is low priority and doesn't need to wakeup the CPU.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/flow.c	2007-12-18 07:43:31.000000000 -0800
+++ b/net/core/flow.c	2007-12-18 07:44:32.000000000 -0800
@@ -81,8 +81,8 @@ static void flow_cache_new_hashrnd(unsig
 	for_each_possible_cpu(i)
 		flow_hash_rnd_recalc(i) = 1;
 
-	flow_hash_rnd_timer.expires = jiffies + FLOW_HASH_RND_PERIOD;
-	add_timer(&flow_hash_rnd_timer);
+	mod_timer(&flow_hash_rnd_timer,
+		  round_jiffies(jiffies + FLOW_HASH_RND_PERIOD));
 }
 
 static void flow_entry_kill(int cpu, struct flow_cache_entry *fle)
@@ -352,7 +352,7 @@ static int __init flow_cache_init(void)
 	flow_lwm = 2 * flow_hash_size;
 	flow_hwm = 4 * flow_hash_size;
 
-	init_timer(&flow_hash_rnd_timer);
+	init_timer_deferrable(&flow_hash_rnd_timer);
 	flow_hash_rnd_timer.function = flow_cache_new_hashrnd;
 	flow_hash_rnd_timer.expires = jiffies + FLOW_HASH_RND_PERIOD;
 	add_timer(&flow_hash_rnd_timer);
