From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH] net: Always fire at least one linkwatch event
Date: Wed, 21 Sep 2011 15:51:29 -0400
Message-ID: <1316634689-15083-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>, jfeeney@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51287 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab1IUTvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 15:51:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was recently noted that the tg3 driver had a problem in that after boot a
kernel and if-upping the tg3 interface the sysfs operstate attribute continued
to read 'unkown'.  This was happening because tg3 assumes the default carrier
state (which is to say the __LINK_STATE_NOCARRIER bit is clear) is correct.
That said, when the device is if-upped, and the open path, calls
netif_carrier_on, the test_and_set_bit call in that function returns false
(since the bit was previously zero from its initial state).  This means that
netif_carrier_on call never generates a linkwatch event, and as a result
dev->operstate never gets recomputed.  This could be fixed by unconditionally
calling netif_carrier_off in the probe routine, to simply force a state change
on that bit, but that seems like a sub-par solution, given that many drivers may
have this error.  Instead it seems like it might be better to burn an extra bit
in the state field to indicate that the CARRIER bit is still in the initial
state and our first call to netif_carrier_[off|on] should always fire a
linkwatch event.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: jfeeney@redhat.com
---
 include/linux/netdevice.h |    1 +
 net/sched/sch_generic.c   |    8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0a7f619..85d6f68 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -306,6 +306,7 @@ enum netdev_state_t {
 	__LINK_STATE_NOCARRIER,
 	__LINK_STATE_LINKWATCH_PENDING,
 	__LINK_STATE_DORMANT,
+	__LINK_STATE_CARRIER_INIT,
 };
 
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 69fca27..6f8bfd1 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -298,7 +298,9 @@ static void dev_watchdog_down(struct net_device *dev)
  */
 void netif_carrier_on(struct net_device *dev)
 {
-	if (test_and_clear_bit(__LINK_STATE_NOCARRIER, &dev->state)) {
+	int force = !test_and_set_bit(__LINK_STATE_CARRIER_INIT, &dev->state);
+
+	if (test_and_clear_bit(__LINK_STATE_NOCARRIER, &dev->state) || force) {
 		if (dev->reg_state == NETREG_UNINITIALIZED)
 			return;
 		linkwatch_fire_event(dev);
@@ -316,7 +318,9 @@ EXPORT_SYMBOL(netif_carrier_on);
  */
 void netif_carrier_off(struct net_device *dev)
 {
-	if (!test_and_set_bit(__LINK_STATE_NOCARRIER, &dev->state)) {
+	int force = !test_and_set_bit(__LINK_STATE_CARRIER_INIT, &dev->state);
+
+	if (!test_and_set_bit(__LINK_STATE_NOCARRIER, &dev->state) || force) {
 		if (dev->reg_state == NETREG_UNINITIALIZED)
 			return;
 		linkwatch_fire_event(dev);
-- 
1.7.6.2
