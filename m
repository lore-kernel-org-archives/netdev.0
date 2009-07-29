From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Wed, 29 Jul 2009 11:04:36 +0000
Message-ID: <20090729110436.GA5490@ff.dom.local>
References: <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728071247.GA25611@gondor.apana.org.au> <20090728.125919.146001472.davem@davemloft.net> <20090729004428.GA765@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f221.google.com ([209.85.218.221]:53182 "EHLO
	mail-bw0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040AbZG2LEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 07:04:42 -0400
Received: by bwz21 with SMTP id 21so609747bwz.37
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 04:04:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090729004428.GA765@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 08:44:28AM +0800, Herbert Xu wrote:
> On Tue, Jul 28, 2009 at 12:59:19PM -0700, David Miller wrote:
> >
> > The premise is that there'd be only one.  The qdisc lock.
> > 
> > If the traffic is distributed, flow wise, the driver XMIT
> > lock would spread due to multiqueue.
> 
> Suppose that we have a single large flow going through that has
> filled up the hardware queue and is now backlogged in the qdisc
> with qdisc_run on CPU A.   Now some other flow comes along and
> sends a packet on CPU B.
> 
> So now CPU A and B will both be processing packets for the first
> flow causing loads of lock contention.
> 
> But worse yet, we have introduced packet reordering.  So are you
> convinced now :)

How about this: instead of the _RUNNING flag we take tx lock while
holding qdisc lock and release qdisc lock just after (before xmit).
This should prevent reordering, and probably could improve cache use:
CPU B which takes qdisc lock only for enqueuing now, would use it for
dequeuing too, plus if accidentally the next xmit goes to a different
tx queue, it could start before CPU A finishes. Otherwise it would
simply wait for CPU A (without tx lock contention). Of course it
needs testing... 

Cheers,
Jarek P.
