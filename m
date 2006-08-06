From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 7 Aug 2006 09:04:07 +1000
Message-ID: <20060806230406.GA1413@gondor.apana.org.au>
References: <20060805230517.GA25468@gondor.apana.org.au> <1551EAE59135BE47B544934E30FC4FC093FA17@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, David Miller <davem@davemloft.net>,
	shemminger@osdl.org, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33042 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750758AbWHFXGY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 19:06:24 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093FA17@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 06, 2006 at 10:20:12AM -0700, Michael Chan wrote:
> 
> Do you mean the same race condition bug between tg3_start_xmit()
> and tg3_tx() that I brought up?  I don't think tg3 has that problem.
> Did I miss something?

Yes it has the problem in two places.  First of all the first
netif_stop_queue in tg3_start_xmit doesn't take the tx_lock at
all so it's obviously vulnerable.

The last netif_stop_queue is susceptible to a more subtle problem:

CPU0					CPU1
tg3_start_xmit
	TX_BUFF_AVAIL <= threshold
		tx_lock
					tg3_tx
						!netif_queue_stopped
		netif_stop_queue
		BUFF_AVAIL <= threshold
						tx_cons = sw_idx
		tx_unlock

Because netif_queue_stopped is *not* a memory barrier, it can float
above the assignment to tx_cons.  So even though netif_stop_queue *is*
a memory barrier on x86, the second BUFF_AVAIL test can still fail to
see the updated index.

The fix here is obviously to add a memory barrier in tg3_tx.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
