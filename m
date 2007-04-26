From: akpm@linux-foundation.org
Subject: [patch 14/15] rfcomm_worker(): fix wakeup race
Date: Thu, 26 Apr 2007 00:27:36 -0700
Message-ID: <200704260727.l3Q7RacZ023984@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	marcel@holtmann.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:54246 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933539AbXDZH6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:58:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

Set TASK_INTERRUPTIBLE prior to testing the flag to avoid missed wakeups.

Acked-by: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/bluetooth/rfcomm/core.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN net/bluetooth/rfcomm/core.c~rfcomm_worker-fix-wakeup-race net/bluetooth/rfcomm/core.c
--- a/net/bluetooth/rfcomm/core.c~rfcomm_worker-fix-wakeup-race
+++ a/net/bluetooth/rfcomm/core.c
@@ -1851,18 +1851,18 @@ static void rfcomm_worker(void)
 	BT_DBG("");
 
 	while (!atomic_read(&terminate)) {
+		set_current_state(TASK_INTERRUPTIBLE);
 		if (!test_bit(RFCOMM_SCHED_WAKEUP, &rfcomm_event)) {
 			/* No pending events. Let's sleep.
 			 * Incoming connections and data will wake us up. */
-			set_current_state(TASK_INTERRUPTIBLE);
 			schedule();
 		}
+		set_current_state(TASK_RUNNING);
 
 		/* Process stuff */
 		clear_bit(RFCOMM_SCHED_WAKEUP, &rfcomm_event);
 		rfcomm_process_sessions();
 	}
-	set_current_state(TASK_RUNNING);
 	return;
 }
 
_
