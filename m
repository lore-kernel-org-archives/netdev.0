From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH/RFA] sch_generic: fix carrier-on bug?
Date: Tue, 16 Oct 2007 17:55:55 -0400
Message-ID: <20071016215555.GA4732@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:51481 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761718AbXJPVz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 17:55:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While looking at a net driver with the following construct,

	if (!netif_carrier_ok(dev))
		netif_carrier_on(dev);

it stuck me that the netif_carrier_ok() check was redundant, since
netif_carrier_on() checks bit __LINK_STATE_NOCARRIER anyway.  This is
the same reason why netif_queue_stopped() need not be called prior to
netif_wake_queue().

This is true, but there is however an unwanted side effect from assuming
that netif_carrier_on() can be called multiple times:  it touches the
watchdog, regardless of pre-existing carrier state.

The fix:  move watchdog-up inside the bit-cleared code path.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---

This looks like an obvious bug fix to me, but I found it by reading code
rather than hitting it in the field.  Review appreciated.


 net/sched/sch_generic.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 95ae119..e01d576 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -249,10 +249,11 @@ static void dev_watchdog_down(struct net_device *dev)
  */
 void netif_carrier_on(struct net_device *dev)
 {
-	if (test_and_clear_bit(__LINK_STATE_NOCARRIER, &dev->state))
+	if (test_and_clear_bit(__LINK_STATE_NOCARRIER, &dev->state)) {
 		linkwatch_fire_event(dev);
-	if (netif_running(dev))
-		__netdev_watchdog_up(dev);
+		if (netif_running(dev))
+			__netdev_watchdog_up(dev);
+	}
 }
 
 /**
