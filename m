From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net] xen-netfront: use napi_complete() correctly to
 prevent Rx stalling
Date: Tue, 16 Dec 2014 15:22:17 -0500 (EST)
Message-ID: <20141216.152217.15156261870362937.davem@davemloft.net>
References: <1418756386-6940-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55649 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbaLPUWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 15:22:19 -0500
In-Reply-To: <1418756386-6940-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Tue, 16 Dec 2014 18:59:46 +0000

> After d75b1ade567ffab085e8adbbdacf0092d10cd09c (net: less interrupt
> masking in NAPI) the napi instance is removed from the per-cpu list
> prior to calling the n->poll(), and is only requeued if all of the
> budget was used.  This inadvertently broke netfront because netfront
> does not use NAPI correctly.
> 
> If netfront had not used all of its budget it would do a final check
> for any Rx responses and avoid calling napi_complete() if there were
> more responses.  It would still return under budget so it would never
> be rescheduled.  The final check would also not re-enable the Rx
> interrupt.
> 
> Additionally, xenvif_poll() would also call napi_complete() /after/
> enabling the interrupt.  This resulted in a race between the
> napi_complete() and the napi_schedule() in the interrupt handler.  The
> use of local_irq_save/restore() avoided by race iff the handler is
> running on the same CPU but not if it was running on a different CPU.
> 
> Fix both of these by always calling napi_compete() if the budget was
> not all used, and then calling napi_schedule() if the final checks
> says there's more work.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied, thanks.
