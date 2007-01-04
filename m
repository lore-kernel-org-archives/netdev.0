From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Thu, 4 Jan 2007 12:49:02 +0000
Message-ID: <200701041249.02459@strip-the-willow>
References: <E1H2GGi-0008E5-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35439 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964821AbXADMsy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 07:48:54 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1H2GGi-0008E5-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

|  > With the implementation now, the output of before(x,y) is reliable: it returns true
|  > if (and only if) x is indeed `before' y.
|  
|  Sorry but I don't think you've answered my question.
|  
|  Let y = (x + 2^31) % 2^32, how is making
|  
|  	before(x, y) == before(y, x) == 0
|  
|  any better than
|  
|  	before(x, y) == before(y, x) == 1
|  
|  For an unambiguous before, we must have before(x, y) != before(y, x)
|  if x != y.
I now see where you are coming from. This requirement

 * is fulfilled in both definitions as long as y != (x + 2^31) % 2^32
 * does not hold in both definitions when      y == (x + 2^31) % 2^32

The reason is in the underlying principle: due to sequence number wrapping, we are dealing
with circular arithmetic, and in circular arithmetic the mid of the range is ambiguous
(example: clock minute hands - 30 is as much `after' as it is `before').

This problematic case has been discussed before: RFC 1982 provides some background, and we
had quite some discussion about similar issues (48 bit sequence numbers) on dccp@vger.

So the short answer is - this kind of unambiguous `before' can not be implemented (see in
particular also the notes in sec. 3.2 of RFC 1982). 

The key point where the new definition differs from the old is that _the relation_
before(x,y) is unambiguous: the case "before(x,y) && before(y,x)" will no longer occur.

|  For a more concrete example, look at the code in tcp_ack:
|  
|          /* If the ack is newer than sent or older than previous acks
|           * then we can probably ignore it.
|           */
|          if (after(ack, tp->snd_nxt))
|                  goto uninteresting_ack;
|  
|          if (before(ack, prior_snd_una))
|                  goto old_ack;
|  
|  Here we have two checks that weed out cases that we do not wish to
|  process.  When all data have been acknowledged, we have
|  
|  	snd_nxt == snd_una
|  
|  At this point, we only want the value of ack == snd_nxt == snd_una
|  to pass this check.  With your change, the value snd_nxt + 2^31 can
|  also pass this check, which may have security implications.
This is true: with the old definition it is at this point certain that ack == snd_nxt.
The reason is that the code implicitly relies on the way `before' is defined. 

That has been the reason why this has been sent as an `RFC' patch: I am sure that the
new definition is is in itself better, but was not sure how it would work with the
existing code. 

With DCCP the case is different: it is a new protocol and an unambiguous `before' relation
is beneficial, since this can increase the accuracy of detecting loss. 

Since there is likely more code which implicitly relies on the old definition,
I will send a patch shortly.

Many thanks,
Gerrit
