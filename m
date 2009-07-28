From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 16:03:54 +0800
Message-ID: <20090728080354.GA25953@gondor.apana.org.au>
References: <20090725032436.GA30741@gondor.apana.org.au> <20090727.192844.163233275.davem@davemloft.net> <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728064319.GA5424@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50909 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751179AbZG1IEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 04:04:01 -0400
Content-Disposition: inline
In-Reply-To: <20090728064319.GA5424@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2009 at 06:43:19AM +0000, Jarek Poplawski wrote:
>
> I guess the main sacrifice of Herbert's idea is sch_multiq, and we
> could probably consider some compromise like doing qdisc_run (with
> qdisc_restart) a callback or only adding a "if default qdisc" check,
> depending on costs/gains.

Indeed, getting rid of multiple queues for all non-default qdiscs
is overly drastic.  Here's a different plan.  We add the proposed
check only for the default qdisc (we still need to fix act_skbedit)
though) while all non-default qdiscs continue to behave as they
currently do.

This can be done by setting dev_queue for non-default qdiscs to
NULL and checking that before we do qdisc_run:

	if (!dev_queue || !queue_stopped(dev_queue))
		qdisc_run

This makes sense as non-default qdiscs do not map bijectively onto
dev queues so they shouldn't really have a pointer to a dev queue.

Of course we'll need to fix those places that use dev_queue for
other purposes such as getting back to the device.  If that is
too much work we could just add a new field that is identical
to dev_queue for the default qdisc but is NULL for non-default
qdiscs.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
