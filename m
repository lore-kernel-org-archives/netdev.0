From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 net] xen-netfront: use napi_complete() correctly to prevent Rx stalling
Date: Tue, 16 Dec 2014 18:59:46 +0000
Message-ID: <1418756386-6940-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:15683 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbaLPTA1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 14:00:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After d75b1ade567ffab085e8adbbdacf0092d10cd09c (net: less interrupt
masking in NAPI) the napi instance is removed from the per-cpu list
prior to calling the n->poll(), and is only requeued if all of the
budget was used.  This inadvertently broke netfront because netfront
does not use NAPI correctly.

If netfront had not used all of its budget it would do a final check
for any Rx responses and avoid calling napi_complete() if there were
more responses.  It would still return under budget so it would never
be rescheduled.  The final check would also not re-enable the Rx
interrupt.

Additionally, xenvif_poll() would also call napi_complete() /after/
enabling the interrupt.  This resulted in a race between the
napi_complete() and the napi_schedule() in the interrupt handler.  The
use of local_irq_save/restore() avoided by race iff the handler is
running on the same CPU but not if it was running on a different CPU.

Fix both of these by always calling napi_compete() if the budget was
not all used, and then calling napi_schedule() if the final checks
says there's more work.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/xen-netfront.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 2f0a9ce..22bcb4e 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -977,7 +977,6 @@ static int xennet_poll(struct napi_struct *napi, int budget)
 	struct sk_buff_head rxq;
 	struct sk_buff_head errq;
 	struct sk_buff_head tmpq;
-	unsigned long flags;
 	int err;
 
 	spin_lock(&queue->rx_lock);
@@ -1050,15 +1049,11 @@ err:
 	if (work_done < budget) {
 		int more_to_do = 0;
 
-		napi_gro_flush(napi, false);
-
-		local_irq_save(flags);
+		napi_complete(napi);
 
 		RING_FINAL_CHECK_FOR_RESPONSES(&queue->rx, more_to_do);
-		if (!more_to_do)
-			__napi_complete(napi);
-
-		local_irq_restore(flags);
+		if (more_to_do)
+			napi_schedule(napi);
 	}
 
 	spin_unlock(&queue->rx_lock);
-- 
1.7.10.4
