From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Thu, 04 Jan 2007 11:15:40 +1100
Message-ID: <E1H2GGi-0008E5-00@gondolin.me.apana.org.au>
References: <200701030856.19416@strip-the-willow>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3497 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932180AbXADAPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 19:15:55 -0500
To: gerrit@erg.abdn.ac.uk (Gerrit Renker)
In-Reply-To: <200701030856.19416@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>
> |  Prior to the patch, we have values x and y such that both
> |  before(x, y) and before(y, x) are true.  Now for those same
> |  values both before(x, y) and before(y, x) are false.
> |
> |  It's still as ambiguous as ever.  Surely to resolve the
> |  ambiguity we want to make before(x, y) = !before(y, x), no?
>
> Please let me restate:
> Ambiguity here means that for those numbers x,y such that  (x + 2^31) % 2^32) = y
> before(x, y) = 1 and before(y, x) = 1. With the previous implementation, one could 
> not tell the difference here: and there are 2^32 such cases where this occurs.
> 
> With the implementation now, the output of before(x,y) is reliable: it returns true
> if (and only if) x is indeed `before' y.

Sorry but I don't think you've answered my question.

Let y = (x + 2^31) % 2^32, how is making

	before(x, y) == before(y, x) == 0

any better than

	before(x, y) == before(y, x) == 1

For an unambiguous before, we must have before(x, y) != before(y, x)
if x != y.

For a more concrete example, look at the code in tcp_ack:

        /* If the ack is newer than sent or older than previous acks
         * then we can probably ignore it.
         */
        if (after(ack, tp->snd_nxt))
                goto uninteresting_ack;

        if (before(ack, prior_snd_una))
                goto old_ack;

Here we have two checks that weed out cases that we do not wish to
process.  When all data have been acknowledged, we have

	snd_nxt == snd_una

At this point, we only want the value of ack == snd_nxt == snd_una
to pass this check.  With your change, the value snd_nxt + 2^31 can
also pass this check, which may have security implications.

Granted I have not looked at other checks in the TCP path that may
prevent this code from being invoked in that case.  However, this
does illustrate the need to audit every single before/after check
if they were ambiguous.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
