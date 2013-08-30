From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/16] sfc: Remove unnecessary use of atomic_t
Date: Fri, 30 Aug 2013 04:38:52 +0100
Message-ID: <1377833932.2552.29.camel@deadeye.wl.decadent.org.uk>
References: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34950 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833Ab3H3Di4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:38:56 -0400
In-Reply-To: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can set, get and compare-and-exchange without using atomic_t.
Change efx_mcdi_iface::state to the enum type we really wanted it to
be.

Suggested-by: David Miller <davem@davemloft.net>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |   28 ++++++++++++----------------
 drivers/net/ethernet/sfc/mcdi.h |    2 +-
 2 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 89bc194..c616fb5 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/delay.h>
+#include <asm/cmpxchg.h>
 #include "net_driver.h"
 #include "nic.h"
 #include "io.h"
@@ -53,7 +54,7 @@ int efx_mcdi_init(struct efx_nic *efx)
 	mcdi = efx_mcdi(efx);
 	init_waitqueue_head(&mcdi->wq);
 	spin_lock_init(&mcdi->iface_lock);
-	atomic_set(&mcdi->state, MCDI_STATE_QUIESCENT);
+	mcdi->state = MCDI_STATE_QUIESCENT;
 	mcdi->mode = MCDI_MODE_POLL;
 
 	(void) efx_mcdi_poll_reboot(efx);
@@ -65,8 +66,7 @@ int efx_mcdi_init(struct efx_nic *efx)
 
 void efx_mcdi_fini(struct efx_nic *efx)
 {
-	BUG_ON(efx->mcdi &&
-	       atomic_read(&efx->mcdi->iface.state) != MCDI_STATE_QUIESCENT);
+	BUG_ON(efx->mcdi && efx->mcdi->iface.state != MCDI_STATE_QUIESCENT);
 	kfree(efx->mcdi);
 }
 
@@ -78,7 +78,7 @@ static void efx_mcdi_send_request(struct efx_nic *efx, unsigned cmd,
 	size_t hdr_len;
 	u32 xflags, seqno;
 
-	BUG_ON(atomic_read(&mcdi->state) == MCDI_STATE_QUIESCENT);
+	BUG_ON(mcdi->state == MCDI_STATE_QUIESCENT);
 
 	/* Serialise with efx_mcdi_ev_cpl() and efx_mcdi_ev_death() */
 	spin_lock_bh(&mcdi->iface_lock);
@@ -258,20 +258,17 @@ static void efx_mcdi_acquire(struct efx_mcdi_iface *mcdi)
 	/* Wait until the interface becomes QUIESCENT and we win the race
 	 * to mark it RUNNING. */
 	wait_event(mcdi->wq,
-		   atomic_cmpxchg(&mcdi->state,
-				  MCDI_STATE_QUIESCENT,
-				  MCDI_STATE_RUNNING)
-		   == MCDI_STATE_QUIESCENT);
+		   cmpxchg(&mcdi->state,
+			   MCDI_STATE_QUIESCENT, MCDI_STATE_RUNNING) ==
+		   MCDI_STATE_QUIESCENT);
 }
 
 static int efx_mcdi_await_completion(struct efx_nic *efx)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
 
-	if (wait_event_timeout(
-		    mcdi->wq,
-		    atomic_read(&mcdi->state) == MCDI_STATE_COMPLETED,
-		    MCDI_RPC_TIMEOUT) == 0)
+	if (wait_event_timeout(mcdi->wq, mcdi->state == MCDI_STATE_COMPLETED,
+			       MCDI_RPC_TIMEOUT) == 0)
 		return -ETIMEDOUT;
 
 	/* Check if efx_mcdi_set_mode() switched us back to polled completions.
@@ -296,9 +293,8 @@ static bool efx_mcdi_complete(struct efx_mcdi_iface *mcdi)
 	 * QUIESCENT. [A subsequent invocation would increment seqno, so would
 	 * have failed the seqno check].
 	 */
-	if (atomic_cmpxchg(&mcdi->state,
-			   MCDI_STATE_RUNNING,
-			   MCDI_STATE_COMPLETED) == MCDI_STATE_RUNNING) {
+	if (cmpxchg(&mcdi->state, MCDI_STATE_RUNNING, MCDI_STATE_COMPLETED) ==
+	    MCDI_STATE_RUNNING) {
 		wake_up(&mcdi->wq);
 		return true;
 	}
@@ -308,7 +304,7 @@ static bool efx_mcdi_complete(struct efx_mcdi_iface *mcdi)
 
 static void efx_mcdi_release(struct efx_mcdi_iface *mcdi)
 {
-	atomic_set(&mcdi->state, MCDI_STATE_QUIESCENT);
+	mcdi->state = MCDI_STATE_QUIESCENT;
 	wake_up(&mcdi->wq);
 }
 
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 303d9e8..6c0363a 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -46,7 +46,7 @@ enum efx_mcdi_mode {
  * @resp_data_len: Response data (SDU or error) length
  */
 struct efx_mcdi_iface {
-	atomic_t state;
+	enum efx_mcdi_state state;
 	enum efx_mcdi_mode mode;
 	wait_queue_head_t wq;
 	spinlock_t iface_lock;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
