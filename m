From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Wed, 19 Aug 2009 13:19:26 +1000
Message-ID: <20090819031926.GA17367@gondor.apana.org.au>
References: <20090704090910.GA2185@gondor.apana.org.au> <20090705032658.GA7430@gondor.apana.org.au> <20090705033408.GB7430@gondor.apana.org.au> <20090817.184712.180559154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, patrick.ohly@intel.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	divy@chelsio.com, rolandd@cisco.com, xemul@openvz.org,
	dcbw@redhat.com, libertas-dev@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45478 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751857AbZHSDTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 23:19:40 -0400
Content-Disposition: inline
In-Reply-To: <20090817.184712.180559154.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2009 at 06:47:12PM -0700, David Miller wrote:
> 
> I'm pretty sure that for normal TCP and UDP workloads, this is just
> going to set the interrupt bit on the first packet that gets into the
> queue, and then not in the rest.
> 
> TCP just loops over packets in the send queue, and at initial state
> the qdisc will be empty.

The scheme I actually tried on the e1000e is not quite the same
as what I had here.  I'm basically just adding descriptors per
usual.

However, I don't give them to the hardware immediately.  Instead
they're held back so that on average we have about three descriptors
in the queue spaced equally that will cause interrupts.  It seems
to work fairly well for netperf-generated TCP/UDP traffic in terms
of generating the right amount of interrupts (once every qlen/3
packets).

I haven't posted anything yet because I ran into a weird problem
with the e1000e.  It was generating a lot more interrupts than
what I'm telling it to do.  Even if I hard-code the interrupts
at 0, qlen/3, 2qlen/2 I still get way more than qlen/3 interrupts
for qlen packets.

This may be related to the fact that e1000e doesn't really have
a way of turning the interrupts off for a given descriptor.  Well
actually it does but it also turns off status reporting which means
that we will never know whether that entry has finished processing.
So I've had to rely on using its TX interrupt delay mechanism as an
approximation of turning interrupt notification off.  Evidently that
is not working in the way I intended it to.

I'm in the process of repeating the same experiment with cxgb3
which hopefully should let me turn interrupts off on descriptors
while still reporting completion status.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
