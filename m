From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 1/6] [NET-NEXT]qlge: Clean up and fix MSI and legacy irq handling.
Date: Tue, 14 Oct 2008 13:34:08 -0700
Message-ID: <adabpxmx6f3.fsf@cisco.com>
References: <20081011171614.GA26384@susedev.qlogic.org>
	<1223745433-26440-1-git-send-email-ron.mercer@qlogic.com>
	<20081011205903.GA29496@electric-eye.fr.zoreil.com>
	<20081014201915.GA27393@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:18076 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbYJNUff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 16:35:35 -0400
In-Reply-To: <20081014201915.GA27393@susedev.qlogic.org> (Ron Mercer's message
	of "Tue, 14 Oct 2008 13:19:15 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > Your example looks much better than what I had, but it reverses the
 > logic and won't work.  What I'm trying to do is skip the operation if
 > we're running with MSIX-multiple interrupts AND it's not context zero.
 > For all other cases we do the operation.  So fixing your suggestion it would
 > be:
 > 
 > {
 > 	u32 var = 0;
 > 
 > 	if (unlikely(!(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr))) {
 > 	struct intr_context *ctx = qdev->intr_context + intr;
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

I think the simplest thing is to avoid the goto and the else clause; ie
instead of putting the bulk of the function inside an block, just have
the exception leave early, and have the other code in the main flow of
the function... so you could do the following, and even include a
comment if you want:

{
	u32 var;
	struct intr_context *ctx;
	unsigned long flags;

	/* Nothing to do if we're using MSI-X and this is not context zero */
	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr))
		return 0;

	ctx = qdev->intr_context + intr;

	spin_lock_irqsave(&qdev->hw_lock, flags);
	if (!atomic_read(&ctx->irq_cnt)) {
		ql_write32(qdev, INTR_EN, ctx->intr_dis_mask);
		var = ql_read32(qdev, STS);
	}
	atomic_inc(&ctx->irq_cnt);
	spin_unlock_irqrestore(&qdev->hw_lock, flags);

	return var;
}

That should generate good code and IMO is the most readable variant.
(BTW the "if (likely(something) && somethingelse)" seems a little
fishy -- I don't know what gcc really does with that.  Either the whole
condition should be marked likely or it's probably not worth annotating
it at all)

 - R.
