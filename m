From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 3/3] enic: add h/w interfaces
Date: Fri, 29 Aug 2008 11:58:17 -0700
Message-ID: <ada4p53k5rq.fsf@cisco.com>
References: <ada63poldrp.fsf@cisco.com>
	<Pine.LNX.4.64.0808291052470.9391@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:18420 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598AbYH2S6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 14:58:18 -0400
In-Reply-To: <Pine.LNX.4.64.0808291052470.9391@palito_client100.nuovasystems.com>
	(Scott Feldman's message of "Fri, 29 Aug 2008 11:17:20 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > > spinning for 100 usecs is pretty nasty... can this be changed to
 > > usleep()?
 > 
 > No because we can't sleep in some of the calling contexts.

I don't think it's a merge-blocker but it is definitely worth thinking
about how to avoid udelay(100) -- a 100+ microsecond latency is pretty
nasty for lots of cases.

 > > not sure why you're making this volatile here... I suspect it doesn't do
 > > what you really want on architectures with a weak memory ordering model,
 > > so it would be better to make things explicit with a memory barrier plus
 > > a comment explaining what you're doing.
 > 
 > We're using volatile here to make the color bit in the descriptor is
 > read first before the any of the other desc fields.  The hardware
 > guarantees the color bit is the last byte (bit) written on the
 > descriptor.  I'll put in a comment explaining what we're doing.

So then volatile doesn't actually do what you want.  You need rmb() to
make sure CPUs with weak ordering models don't reorder things.  Volatile
makes sure the compiler doesn't reorder things but out-of-order CPUs can
easily execute the reads in a different order than that.

 > > This looks way too big to inline.
 > 
 > It's called in the performance path in several places.

My guess is that the benefit of having only one copy in I$ outweighs the
function call overhead.  I guess you could see if you could measure a
difference either way.  And if things are equal then the smaller code is
preferable because it reduces the cache pressure on other code that
might be running.

 - R.
