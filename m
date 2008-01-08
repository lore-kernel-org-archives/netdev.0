From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/7]: [NET]: Add NAPI_STATE_DISABLE.
Date: Mon, 07 Jan 2008 21:38:32 -0800 (PST)
Message-ID: <20080107.213832.249015054.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32880
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750696AbYAHFid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:38:33 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id AD2D9C8C217
	for <netdev@vger.kernel.org>; Mon,  7 Jan 2008 21:38:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[NET]: Add NAPI_STATE_DISABLE.

Create a bit to signal that a napi_disable() is in progress.

This sets up infrastructure such that net_rx_action() can generically
break out of the ->poll() loop on a NAPI context that has a pending
napi_disable() yet is being bombed with packets (and thus would
otherwise poll endlessly and not allow the napi_disable() to finish).

Now, what napi_disable() does is first set the NAPI_STATE_DISABLE bit
(to indicate that a disable is pending), then it polls for the
NAPI_STATE_SCHED bit, and once the NAPI_STATE_SCHED bit is acquired
the NAPI_STATE_DISABLE bit is cleared.  Here, the test_and_set_bit()
provides the necessary memory barrier between the various bitops.

napi_schedule_prep() now tests for a pending disable as it's first
action and won't try to obtain the NAPI_STATE_SCHED bit if a disable
is pending.

As a result, we can remove the netif_running() check in
netif_rx_schedule_prep() because the NAPI disable pending state serves
this purpose.  And, it does so in a NAPI centric manner which is what
we really want.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e393995..b0813c3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -319,21 +319,29 @@ struct napi_struct {
 enum
 {
 	NAPI_STATE_SCHED,	/* Poll is scheduled */
+	NAPI_STATE_DISABLE,	/* Disable pending */
 };
 
 extern void FASTCALL(__napi_schedule(struct napi_struct *n));
 
+static inline int napi_disable_pending(struct napi_struct *n)
+{
+	return test_bit(NAPI_STATE_DISABLE, &n->state);
+}
+
 /**
  *	napi_schedule_prep - check if napi can be scheduled
  *	@n: napi context
  *
  * Test if NAPI routine is already running, and if not mark
  * it as running.  This is used as a condition variable
- * insure only one NAPI poll instance runs
+ * insure only one NAPI poll instance runs.  We also make
+ * sure there is no pending NAPI disable.
  */
 static inline int napi_schedule_prep(struct napi_struct *n)
 {
-	return !test_and_set_bit(NAPI_STATE_SCHED, &n->state);
+	return !napi_disable_pending(n) &&
+		!test_and_set_bit(NAPI_STATE_SCHED, &n->state);
 }
 
 /**
@@ -389,8 +397,10 @@ static inline void napi_complete(struct napi_struct *n)
  */
 static inline void napi_disable(struct napi_struct *n)
 {
+	set_bit(NAPI_STATE_DISABLE, &n->state);
 	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
 		msleep(1);
+	clear_bit(NAPI_STATE_DISABLE, &n->state);
 }
 
 /**
@@ -1268,7 +1278,7 @@ static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
 static inline int netif_rx_schedule_prep(struct net_device *dev,
 					 struct napi_struct *napi)
 {
-	return netif_running(dev) && napi_schedule_prep(napi);
+	return napi_schedule_prep(napi);
 }
 
 /* Add interface to tail of rx poll list. This assumes that _prep has
-- 
1.5.4.rc2.38.gd6da3

