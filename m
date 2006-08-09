From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Tue, 8 Aug 2006 21:25:11 -0400
Message-ID: <20060809012511.GB16059@kvack.org>
References: <20060804110829.62136ebb@dxpl.pdx.osdl.net> <20060804.163111.85390037.davem@davemloft.net> <20060808170432.GD27383@kvack.org> <20060808.150607.10247901.davem@davemloft.net> <20060808232108.GA16059@kvack.org> <20060809002530.GA19881@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, hadi@cyberus.ca, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:28365 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S1030393AbWHIBZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 21:25:19 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060809002530.GA19881@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 10:25:30AM +1000, Herbert Xu wrote:
> The problem here is that the TX clean function does not take the lock
> (nor do we want it to).  It can thus come in while you're transmitting
> and empty the queue.

That can be solved with sequence numbers -- ie, we keep track of the number 
of packets queued to the hardware, as well as tracking the number of tx 
completions that have been reaped.  Because those numbers are flushed to 
memory by other locks (barriers) taken during processing, the code in 
hard_start_xmit() and the actual tx completion reaping could be done without 
the atomic ops.  The key thing is that the higher level code in the network 
stack calling dev->hard_start_xmit() would know that it needs to retry if 
the tx complete sequence changes.  I'll ponder this a bit more and try to 
come up with some sample code.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
