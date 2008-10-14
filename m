From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 1/6] [NET-NEXT]qlge: Clean up and fix MSI and legacy irq handling.
Date: Tue, 14 Oct 2008 13:19:15 -0700
Message-ID: <20081014201915.GA27393@susedev.qlogic.org>
References: <20081011171614.GA26384@susedev.qlogic.org> <1223745433-26440-1-git-send-email-ron.mercer@qlogic.com> <20081011205903.GA29496@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:47203 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737AbYJNUTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 16:19:25 -0400
Content-Disposition: inline
In-Reply-To: <20081011205903.GA29496@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 11, 2008 at 10:59:03PM +0200, Francois Romieu wrote:
> Ron Mercer <ron.mercer@qlogic.com> :
> [...]
> >  static u32 ql_disable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
> >  {
> >  	u32 var = 0;
> >  
> > -	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags)))
> > +	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr))
> >  		goto exit;
> > -	else if (!atomic_read(&qdev->intr_context[intr].irq_cnt)) {
> > -		ql_write32(qdev, INTR_EN,
> > -			   qdev->intr_context[intr].intr_dis_mask);
> > -		var = ql_read32(qdev, STS);
> > -	}
> > -	atomic_inc(&qdev->intr_context[intr].irq_cnt);
> > +	else {
> > +		unsigned long hw_flags = 0;
> > +		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
> > +              if (!atomic_read(&qdev->intr_context[intr].irq_cnt)) {
> > +		       ql_write32(qdev, INTR_EN,
> > +			          qdev->intr_context[intr].intr_dis_mask);
> > +       		var = ql_read32(qdev, STS);
> > +	       }
> > +       	atomic_inc(&qdev->intr_context[intr].irq_cnt);
> > +		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
> > +       }
> >  exit:
> >  	return var;
> >  }
> 
> Ron, the style is a bit convoluted and the indent mixes whitespaces and
> tabs. Could you make it look something like :

Sorry about the tabs/whitespaces.  I'll be more vigilant.

> 
> {
> 	u32 var = 0;
> 
> 	if (unlikely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr)) {
> 		unsigned long flags;
> 
> 		spin_lock_irqsave(&qdev->hw_lock, flags);
> 		if (!atomic_read(&qdev->intr_context[intr].irq_cnt)) {
> 			ql_write32(qdev, INTR_EN,
> 				   qdev->intr_context[intr].intr_dis_mask);
> 			var = ql_read32(qdev, STS);
> 		}
> 		atomic_inc(&qdev->intr_context[intr].irq_cnt);
> 		spin_unlock_irqrestore(&qdev->hw_lock, flags);
> 	}
> 	return var;
> }
> 
> or (assuming there is no locking issue with the local variable ctx) :
> 
> {
> 	u32 var = 0;
> 
> 	if (unlikely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr)) {
> 		struct intr_context *ctx = qdev->intr_context + intr;
> 		unsigned long flags;
> 
> 		spin_lock_irqsave(&qdev->hw_lock, flags);
> 		if (!atomic_read(&ctx->irq_cnt)) {
> 			ql_write32(qdev, INTR_EN, ctx->intr_dis_mask);
> 			var = ql_read32(qdev, STS);
> 		}
> 		atomic_inc(&ctx->irq_cnt);
> 		spin_unlock_irqrestore(&qdev->hw_lock, flags);
> 	}
> 	return var;
> }
>

Your example looks much better than what I had, but it reverses the
logic and won't work.  What I'm trying to do is skip the operation if
we're running with MSIX-multiple interrupts AND it's not context zero.
For all other cases we do the operation.  So fixing your suggestion it would
be:

{
	u32 var = 0;

	if (unlikely(!(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr))) {
	struct intr_context *ctx = qdev->intr_context + intr;
		unsigned long flags;

		spin_lock_irqsave(&qdev->hw_lock, flags);
		if (!atomic_read(&ctx->irq_cnt)) {
			ql_write32(qdev, INTR_EN, ctx->intr_dis_mask);
			var = ql_read32(qdev, STS);
		}
		atomic_inc(&ctx->irq_cnt);
		spin_unlock_irqrestore(&qdev->hw_lock, flags);
	}
	return var;
}

This is more compact, it's still optimized, but I think it becomes a
little hard to read.  I'll gladly try it and make the change if you
want.




> [...]
> > @@ -1752,12 +1743,15 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
> >  	int i;
> >  	int work_done = 0;
> >  
> > -	if (qdev->legacy_check && qdev->legacy_check(qdev)) {
> > -		QPRINTK(qdev, INTR, INFO, "Already busy, not our interrupt.\n");
> > -		return IRQ_NONE;	/* Not our interrupt */
> > +	spin_lock(&qdev->hw_lock);
> > +	if(atomic_read(&qdev->intr_context[0].irq_cnt)) {
>          ^^ if (
> 
> [...]
> > @@ -2791,8 +2786,13 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
> >  		/*
> >  		 * Single interrupt means one handler for all rings.
> >  		 */
> > -		intr_context->handler = qlge_isr;
> > -		sprintf(intr_context->name, "%s-single_irq", qdev->ndev->name);
> > +		if (likely(test_bit(QL_MSI_ENABLED, &qdev->flags))) {
> > +			intr_context->handler = qlge_isr;
> > +			sprintf(intr_context->name, "%s-msi-single_irq", qdev->ndev->name);
> > +		} else {
> > +			intr_context->handler = qlge_isr;
> > +			sprintf(intr_context->name, "%s-legacy-single_irq", qdev->ndev->name);
> > +		}
> 
> It is the same "intr_context->handler = qlge_isr;" in both branches, is not it ?

Yes, thanks.  I'll fix this.

Ron

