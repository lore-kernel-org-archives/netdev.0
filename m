From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: increase receive packet quantum
Date: Mon, 3 Nov 2008 13:03:03 -0800
Message-ID: <20081103130303.29dd4e21@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40396 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754002AbYKCVDG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 16:03:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch gets about 1.25% back on tbench regression.

My change to NAPI for multiqueue support changed the time limit on
network receive processing.  Under sustained loads like tbench, this
can cause the receiver to reschedule prematurely. 

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/dev.c	2008-11-03 11:11:44.000000000 -0800
+++ b/net/core/dev.c	2008-11-03 11:16:07.000000000 -0800
@@ -2373,7 +2373,7 @@ EXPORT_SYMBOL(__napi_schedule);
 static void net_rx_action(struct softirq_action *h)
 {
 	struct list_head *list = &__get_cpu_var(softnet_data).poll_list;
-	unsigned long start_time = jiffies;
+	unsigned long time_limit = jiffies + 2;
 	int budget = netdev_budget;
 	void *have;
 
@@ -2384,13 +2384,10 @@ static void net_rx_action(struct softirq
 		int work, weight;
 
 		/* If softirq window is exhuasted then punt.
-		 *
-		 * Note that this is a slight policy change from the
-		 * previous NAPI code, which would allow up to 2
-		 * jiffies to pass before breaking out.  The test
-		 * used to be "jiffies - start_time > 1".
+		 * Allow this to run for 2 jiffies since which will allow
+		 * an average latency of 1.5/HZ.
 		 */
-		if (unlikely(budget <= 0 || jiffies != start_time))
+		if (unlikely(budget <= 0 || time_after(jiffies, time_limit)))
 			goto softnet_break;
 
 		local_irq_enable();
