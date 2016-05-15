From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Subject: [PATCH] net/hsr: Use setup_timer and mod_timer.
Date: Sun, 15 May 2016 19:37:44 +0530
Message-ID: <1463321265-11577-1-git-send-email-falakreyaz@gmail.com>
Cc: Arvid Brodin <arvid.brodin@alten.se>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34543 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbcEOOH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 10:07:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function setup_timer combines the initialization of a timer with the
initialization of the timer's function and data fields. The mulitiline
code for timer initialization is now replaced with function setup_timer.

Also, quoting the mod_timer() function comment:
-> mod_timer() is a more efficient way to update the expire field of an
   active timer (if the timer is inactive it will be activated).

Use setup_timer() and mod_timer() to setup and arm a timer, making the
code compact and aid readablity.

Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>
---
 net/hsr/hsr_device.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index 386cbce..16737cd 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -461,13 +461,9 @@ int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *slave[2],
 	hsr->sequence_nr = HSR_SEQNR_START;
 	hsr->sup_sequence_nr = HSR_SUP_SEQNR_START;
 
-	init_timer(&hsr->announce_timer);
-	hsr->announce_timer.function = hsr_announce;
-	hsr->announce_timer.data = (unsigned long) hsr;
+	setup_timer(&hsr->announce_timer, hsr_announce, (unsigned long)hsr);
 
-	init_timer(&hsr->prune_timer);
-	hsr->prune_timer.function = hsr_prune_nodes;
-	hsr->prune_timer.data = (unsigned long) hsr;
+	setup_timer(&hsr->prune_timer, hsr_prune_nodes, (unsigned long)hsr);
 
 	ether_addr_copy(hsr->sup_multicast_addr, def_multicast_addr);
 	hsr->sup_multicast_addr[ETH_ALEN - 1] = multicast_spec;
@@ -502,8 +498,7 @@ int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *slave[2],
 	if (res)
 		goto fail;
 
-	hsr->prune_timer.expires = jiffies + msecs_to_jiffies(PRUNE_PERIOD);
-	add_timer(&hsr->prune_timer);
+	mod_timer(&hsr->prune_timer, jiffies + msecs_to_jiffies(PRUNE_PERIOD));
 
 	return 0;
 
-- 
1.9.1
