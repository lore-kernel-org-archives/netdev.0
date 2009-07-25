From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Sat, 25 Jul 2009 11:24:36 +0800
Message-ID: <20090725032436.GA30741@gondor.apana.org.au>
References: <20090720074607.32463.23013.sendpatchset@localhost.localdomain> <20090724083006.GA5698@ff.dom.local> <20090724083749.GA23521@gondor.apana.org.au> <OFFA0E0F2C.B17AF73A-ON652575FD.00372349-652575FD.0039CB03@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Jarek Poplawski <jarkao2@gmail.com>,
	netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38755 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751996AbZGYDYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 23:24:46 -0400
Content-Disposition: inline
In-Reply-To: <OFFA0E0F2C.B17AF73A-ON652575FD.00372349-652575FD.0039CB03@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 24, 2009 at 04:01:15PM +0530, Krishna Kumar2 wrote:
>
> Assuming many CPU's share a queue, only one can xmit due to the
> RUNNING bit. And after RUNNING bit is taken, no other cpu can
> stop the queue. So the only change in the behavior with this
> patch is that the xmit is terminated a little earlier compared
> to the current code. In case of a stopped queue, the patch helps
> a little bit more by removing one stopped check for each queue'd
> skb, including those skbs that are added later while the current
> xmit session (qdisc_run) is ongoing.
> 
> I hope I have addressed your concern?

That got me to actually look at your patch :)

You're essentiall reverting f4ab543201992fe499bef5c406e09f23aa97b4d5
which cannot be right since the same problem still exists.

However, I am definitely with you in that we should perform this
optimisation since it makes sense for the majority of people who
use multiqueue TX.

So the fact that our current architecture penalises the people
who actually need multiqueue TX in order to ensure correctness
for the people who cannot use multiqueue TX effectively (i.e.,
those who use non-default qdiscs) makes me uneasy.

Dave, remember our discussion about the benefits of using multiqueue
TX just for the sake of enarlging the TX queues? How about just
going back to using a single queue for non-default qdiscs (at
least until such a time when non-default qdiscs start doing
multiple queues internally)?

Yes it would mean potentially smaller queues for those non-default
qdisc users, but they're usually the same people who want the
hardware to queue as little as possible in order to enforce whatever
it is that their qdisc is designed to enforce.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
