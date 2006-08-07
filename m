From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 6 Aug 2006 20:56:31 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FA18@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <20060806230406.GA1413@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "jamal" <hadi@cyberus.ca>, "David Miller" <davem@davemloft.net>,
	shemminger@osdl.org, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:51209 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751005AbWHGD4o convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 23:56:44 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20060806230406.GA1413@gondor.apana.org.au>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

> Yes it has the problem in two places.  First of all the first
> netif_stop_queue in tg3_start_xmit doesn't take the tx_lock at
> all so it's obviously vulnerable.

Oh, that first one near the top of tg3_start_xmit()?  That
condition is not supposed to happen and is a bug condition.  But
we can certainly add a spinlock to make it more correct.

> 
> The last netif_stop_queue is susceptible to a more subtle problem:
> 
> CPU0					CPU1
> tg3_start_xmit
> 	TX_BUFF_AVAIL <= threshold
> 		tx_lock
> 					tg3_tx
> 						!netif_queue_stopped
> 		netif_stop_queue
> 		BUFF_AVAIL <= threshold
> 						tx_cons = sw_idx
> 		tx_unlock
> 
> Because netif_queue_stopped is *not* a memory barrier, it can float
> above the assignment to tx_cons.  So even though netif_stop_queue *is*
> a memory barrier on x86, the second BUFF_AVAIL test can still fail to
> see the updated index.
> 
> The fix here is obviously to add a memory barrier in tg3_tx.

You are absolutely right and I missed it.  We should add a wmb()
after the tx_cons update in tg3_tx().  Thanks.


