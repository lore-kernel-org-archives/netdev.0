From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCHv3 net] xen-netback: fix race between napi_complete() and
 interrupt handler
Date: Fri, 16 May 2014 12:26:04 +0100
Message-ID: <5375F5CC.6000000@citrix.com>
References: <1400239202-10308-1-git-send-email-david.vrabel@citrix.com> <20140516112157.GI18551@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:35694 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932343AbaEPL03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 07:26:29 -0400
In-Reply-To: <20140516112157.GI18551@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/05/14 12:21, Wei Liu wrote:
> On Fri, May 16, 2014 at 12:20:02PM +0100, David Vrabel wrote:
>> When the NAPI budget was not all used, xenvif_poll() would call
>> napi_complete() /after/ enabling the interrupt.  This resulted in a
>> race between the napi_complete() and the napi_schedule() in the
>> interrupt handler.  The use of local_irq_save/restore() avoided by
>> race iff the handler is running on the same CPU but not if it was
>> running on a different CPU.
>>
>> Fix this properly by calling napi_complete() before reenabling
>> interrupts (in the xenvif_napi_schedule_or_enable_irq() call).
>>
>> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
>> Acked-by: Wei Lui <wei.lui2@citrix.com>
> 
> It's "Liu". ;-)

Sorry!

Dave, can you take this instead:

8<--------------
xen-netback: fix race between napi_complete() and interrupt handler

When the NAPI budget was not all used, xenvif_poll() would call
napi_complete() /after/ enabling the interrupt.  This resulted in a
race between the napi_complete() and the napi_schedule() in the
interrupt handler.  The use of local_irq_save/restore() avoided by
race iff the handler is running on the same CPU but not if it was
running on a different CPU.

Fix this properly by calling napi_complete() before reenabling
interrupts (in the xenvif_napi_schedule_or_enable_irq() call).

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Acked-by: Wei Liu <wei.liu2@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
---
v3:
- new name is xenvif_napi_schedule_or_enable_events().

v2:
- Rename xenvif_check_rx_xenvif() to
  xenvif_napi_schedule_or_enable_irq() to make it more obvious what it
  does.
---
 drivers/net/xen-netback/common.h    |    2 +-
 drivers/net/xen-netback/interface.c |   30 +++---------------------------
 drivers/net/xen-netback/netback.c   |    4 ++--
 3 files changed, 6 insertions(+), 30 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index ae413a2..d66de9a 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -209,7 +209,7 @@ int xenvif_map_frontend_rings(struct xenvif *vif,
 			      grant_ref_t rx_ring_ref);
 
 /* Check for SKBs from frontend and schedule backend processing */
-void xenvif_check_rx_xenvif(struct xenvif *vif);
+void xenvif_napi_schedule_or_enable_events(struct xenvif *vif);
 
 /* Prevent the device from generating any further traffic. */
 void xenvif_carrier_off(struct xenvif *vif);
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 7669d49..0200de2 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -65,32 +65,8 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
 	work_done = xenvif_tx_action(vif, budget);
 
 	if (work_done < budget) {
-		int more_to_do = 0;
-		unsigned long flags;
-
-		/* It is necessary to disable IRQ before calling
-		 * RING_HAS_UNCONSUMED_REQUESTS. Otherwise we might
-		 * lose event from the frontend.
-		 *
-		 * Consider:
-		 *   RING_HAS_UNCONSUMED_REQUESTS
-		 *   <frontend generates event to trigger napi_schedule>
-		 *   __napi_complete
-		 *
-		 * This handler is still in scheduled state so the
-		 * event has no effect at all. After __napi_complete
-		 * this handler is descheduled and cannot get
-		 * scheduled again. We lose event in this case and the ring
-		 * will be completely stalled.
-		 */
-
-		local_irq_save(flags);
-
-		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
-		if (!more_to_do)
-			__napi_complete(napi);
-
-		local_irq_restore(flags);
+		napi_complete(napi);
+		xenvif_napi_schedule_or_enable_events(vif);
 	}
 
 	return work_done;
@@ -166,7 +142,7 @@ static void xenvif_up(struct xenvif *vif)
 	enable_irq(vif->tx_irq);
 	if (vif->tx_irq != vif->rx_irq)
 		enable_irq(vif->rx_irq);
-	xenvif_check_rx_xenvif(vif);
+	xenvif_napi_schedule_or_enable_events(vif);
 }
 
 static void xenvif_down(struct xenvif *vif)
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index e5284bc..0efda31 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -604,7 +604,7 @@ done:
 		notify_remote_via_irq(vif->rx_irq);
 }
 
-void xenvif_check_rx_xenvif(struct xenvif *vif)
+void xenvif_napi_schedule_or_enable_events(struct xenvif *vif)
 {
 	int more_to_do;
 
@@ -638,7 +638,7 @@ static void tx_credit_callback(unsigned long data)
 {
 	struct xenvif *vif = (struct xenvif *)data;
 	tx_add_credit(vif);
-	xenvif_check_rx_xenvif(vif);
+	xenvif_napi_schedule_or_enable_events(vif);
 }
 
 static void xenvif_tx_err(struct xenvif *vif,
-- 
1.7.10.4
