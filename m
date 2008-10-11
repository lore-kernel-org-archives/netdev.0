From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/6] [NET-NEXT]qlge: Clean up and fix MSI and legacy
	irq handling.
Date: Sat, 11 Oct 2008 22:59:03 +0200
Message-ID: <20081011205903.GA29496@electric-eye.fr.zoreil.com>
References: <20081011171614.GA26384@susedev.qlogic.org> <1223745433-26440-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41516 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758799AbYJKU7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 16:59:15 -0400
Content-Disposition: inline
In-Reply-To: <1223745433-26440-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Mercer <ron.mercer@qlogic.com> :
[...]
>  static u32 ql_disable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
>  {
>  	u32 var = 0;
>  
> -	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags)))
> +	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr))
>  		goto exit;
> -	else if (!atomic_read(&qdev->intr_context[intr].irq_cnt)) {
> -		ql_write32(qdev, INTR_EN,
> -			   qdev->intr_context[intr].intr_dis_mask);
> -		var = ql_read32(qdev, STS);
> -	}
> -	atomic_inc(&qdev->intr_context[intr].irq_cnt);
> +	else {
> +		unsigned long hw_flags = 0;
> +		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
> +              if (!atomic_read(&qdev->intr_context[intr].irq_cnt)) {
> +		       ql_write32(qdev, INTR_EN,
> +			          qdev->intr_context[intr].intr_dis_mask);
> +       		var = ql_read32(qdev, STS);
> +	       }
> +       	atomic_inc(&qdev->intr_context[intr].irq_cnt);
> +		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
> +       }
>  exit:
>  	return var;
>  }

Ron, the style is a bit convoluted and the indent mixes whitespaces and
tabs. Could you make it look something like :

{
	u32 var = 0;

	if (unlikely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr)) {
		unsigned long flags;

		spin_lock_irqsave(&qdev->hw_lock, flags);
		if (!atomic_read(&qdev->intr_context[intr].irq_cnt)) {
			ql_write32(qdev, INTR_EN,
				   qdev->intr_context[intr].intr_dis_mask);
			var = ql_read32(qdev, STS);
		}
		atomic_inc(&qdev->intr_context[intr].irq_cnt);
		spin_unlock_irqrestore(&qdev->hw_lock, flags);
	}
	return var;
}

or (assuming there is no locking issue with the local variable ctx) :

{
	u32 var = 0;

	if (unlikely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr)) {
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

[...]
> @@ -1752,12 +1743,15 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
>  	int i;
>  	int work_done = 0;
>  
> -	if (qdev->legacy_check && qdev->legacy_check(qdev)) {
> -		QPRINTK(qdev, INTR, INFO, "Already busy, not our interrupt.\n");
> -		return IRQ_NONE;	/* Not our interrupt */
> +	spin_lock(&qdev->hw_lock);
> +	if(atomic_read(&qdev->intr_context[0].irq_cnt)) {
         ^^ if (

[...]
> @@ -2791,8 +2786,13 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
>  		/*
>  		 * Single interrupt means one handler for all rings.
>  		 */
> -		intr_context->handler = qlge_isr;
> -		sprintf(intr_context->name, "%s-single_irq", qdev->ndev->name);
> +		if (likely(test_bit(QL_MSI_ENABLED, &qdev->flags))) {
> +			intr_context->handler = qlge_isr;
> +			sprintf(intr_context->name, "%s-msi-single_irq", qdev->ndev->name);
> +		} else {
> +			intr_context->handler = qlge_isr;
> +			sprintf(intr_context->name, "%s-legacy-single_irq", qdev->ndev->name);
> +		}

It is the same "intr_context->handler = qlge_isr;" in both branches, is not it ?

-- 
Ueimor
