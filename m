From: David Miller <davem@davemloft.net>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
 pointer dereference
Date: Thu, 24 Jul 2008 15:09:20 -0700 (PDT)
Message-ID: <20080724.150920.120141367.davem@davemloft.net>
References: <84144f020807240544q507e1b7cv220d1afbae0ee0f0@mail.gmail.com>
	<48887A71.5010209@trash.net>
	<alpine.LFD.1.10.0807241407410.8109@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, penberg@cs.helsinki.fi, mingo@elte.hu,
	herbert@gondor.apana.org.au, w@1wt.eu, davidn@davidnewall.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi, davej@redhat.com
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56996
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751149AbYGXWJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 18:09:20 -0400
In-Reply-To: <alpine.LFD.1.10.0807241407410.8109@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 24 Jul 2008 14:13:42 -0700 (PDT)

> Finally, why do the "ct->ext" dereference thing, when we know it has
> to be equal to "new"?

Actually in the old code this precondition didn't hold, which explains
how it is.

The old code looked like:

	if (newlen >= ksize(ct->ext)) {
		new = kmalloc(newlen, gfp);
		if (!new)
			return NULL;
 ...
		ct->ext = new;
	}

	ct->ext->offset[id] = newoff;
	ct->ext->len = newlen;
	memset((void *)ct->ext + newoff, 0, newlen - newoff);
	return (void *)ct->ext + newoff;

and in that context 'new' is only assigned in the "newlen >=" guarded
code block.

Anyways, it does seem that we should indeed only update the
new larger length only after we've initialized the contents.

Note that we could make krealloc() and friends clear out the trailing
bits of the new buffer, and therefore the caller wouldn't even need to
be mindful of such things.

I don't know if that's desirable in general, probably it isn't.
