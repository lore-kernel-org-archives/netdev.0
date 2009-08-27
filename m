From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 12/14] pktgen: use common idle routine
Date: Thu, 27 Aug 2009 16:55:18 -0700
Message-ID: <20090827235706.063577285@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35396 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752047AbZH0X7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:13 -0400
Content-Disposition: inline; filename=pktgen-idle-common.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simpler to have one place that spins and accounts for delays,
this will also make the last packet be detected faster for more
repeatable timing.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/pktgen.c	2009-08-27 16:28:17.520270294 -0700
+++ b/net/core/pktgen.c	2009-08-27 16:29:53.826372401 -0700
@@ -3458,16 +3458,10 @@ static void pktgen_xmit(struct pktgen_de
 
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
-		if (atomic_read(&(pkt_dev->skb->users)) != 1) {
-			ktime_t idle_start = ktime_now();
-			while (atomic_read(&(pkt_dev->skb->users)) != 1) {
-				if (signal_pending(current)) {
-					break;
-				}
-				schedule();
-			}
-			pkt_dev->idle_acc += ktime_to_ns(ktime_sub(ktime_now(),
-								   idle_start));
+		while (atomic_read(&(pkt_dev->skb->users)) != 1) {
+			if (signal_pending(current))
+				break;
+			idle(pkt_dev);
 		}
 
 		/* Done with this */

-- 

