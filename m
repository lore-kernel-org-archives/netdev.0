From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Regression in net-2.6.24?
Date: Fri, 12 Oct 2007 01:54:13 -0700
Message-ID: <1192179253.4788.14.camel@dell>
References: <20071011.171743.118962219.davem@davemloft.net>
 <20071011.181449.130846976.davem@davemloft.net>
 <1192159036.6889.6.camel@dell>
 <20071011.194009.48528774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, takano@axe-inc.co.jp,
	"netdev" <netdev@vger.kernel.org>, ilpo.jarvinen@helsinki.fi
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2490 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754874AbXJLH6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 03:58:14 -0400
In-Reply-To: <20071011.194009.48528774.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-10-11 at 19:40 -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Thu, 11 Oct 2007 20:17:16 -0700
>
> > > +               if (likely(!tg3_has_work(tp))) {
> > > +                       struct tg3_hw_status *sblk = tp->hw_status;
> > > +
> > 
> > --> new status block DMA
> > 
> > > +                       if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
> > > +                               tp->last_tag = sblk->status_tag;
> > > +                               rmb();
> > > +                       } else
> > > +                               sblk->status &= ~SD_STATUS_UPDATED;
> > 
> > We need to read the sblk->status_tag before calling tg3_has_work().  If
> > a new status block DMA happens in between (shown above), tp->last_tag
> > will get the new tag and we will end up acknowledging work that we
> > haven't processed.
> 
> Hmmm, the old code didn't do that and seemingly has the same
> problem.  Also, if you look at the before-patch code and think
> about what it does if we ->poll() multiple times for a single
> interrupt the side-effects are essentially the same.
> 

No, the old code before tonight's patch did this:

if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
	tp->last_tag = sblk->status_tag;
	rmb();
}

before checking for more work.  The rmb() is there to make sure that the
status tag is read and stored before we check for more work.

> What's the crucial difference?
> 

This sequence only matters when we eventually terminate and tell the
hardware the last tag we've processed and turn on the interrupt.  If
there's a status block race condition, the hw will know when the tag
written back does not match the latest one and it will generate an
interrupt right away.  The sequence guarantees that the hw will see the
proper tag corresponding to the work processed by the driver.

[TG3]: Refine napi poll loop.

Need to read and store sblk->status_tag before checking for more work.
The status tag is later written back to the hardware when enabling
interrupts to acknowledge how much work has been processed.  If the
order is reversed, we can end up acknowledging work we haven't
processed.

When we detect tx error, it is more correct to return the rx
work_done so far instead of 0.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 417641a..055cc68 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3576,7 +3576,7 @@ static int tg3_poll_work(struct tg3 *tp, int work_done, int budget)
 	if (sblk->idx[0].tx_consumer != tp->tx_cons) {
 		tg3_tx(tp);
 		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING))
-			return 0;
+			return work_done;
 	}
 
 	/* run RX thread, within the bounds set by NAPI.
@@ -3593,6 +3593,7 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 {
 	struct tg3 *tp = container_of(napi, struct tg3, napi);
 	int work_done = 0;
+	struct tg3_hw_status *sblk = tp->hw_status;
 
 	while (1) {
 		work_done = tg3_poll_work(tp, work_done, budget);
@@ -3603,15 +3604,17 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 		if (unlikely(work_done >= budget))
 			break;
 
-		if (likely(!tg3_has_work(tp))) {
-			struct tg3_hw_status *sblk = tp->hw_status;
-
-			if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
-				tp->last_tag = sblk->status_tag;
-				rmb();
-			} else
-				sblk->status &= ~SD_STATUS_UPDATED;
+		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
+			/* tp->last_tag is used in tg3_restart_ints() below
+			 * to tell the hw how much work has been processed,
+			 * so we must read it before checking for more work.
+			 */
+			tp->last_tag = sblk->status_tag;
+			rmb();
+		} else
+			sblk->status &= ~SD_STATUS_UPDATED;
 
+		if (likely(!tg3_has_work(tp))) {
 			netif_rx_complete(tp->dev, napi);
 			tg3_restart_ints(tp);
 			break;
@@ -3621,9 +3624,10 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 	return work_done;
 
 tx_recovery:
+	/* work_done is guaranteed to be less than budget. */
 	netif_rx_complete(tp->dev, napi);
 	schedule_work(&tp->reset_task);
-	return 0;
+	return work_done;
 }
 
 static void tg3_irq_quiesce(struct tg3 *tp)




