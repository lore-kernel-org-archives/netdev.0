From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Wed, 1 May 2013 13:08:38 +0100
Message-ID: <1367410118.5106.113.camel@deadeye.wl.decadent.org.uk>
References: <1367370761.11020.22.camel@edumazet-glaptop>
	 <1367372393.22115.6.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Paul Mackerras <paulus@samba.org>,
	"Ambrose Feinstein" <ambrose@google.com>,
	<linuxppc-dev@lists.ozlabs.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50713 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877Ab3EAMIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 08:08:44 -0400
In-Reply-To: <1367372393.22115.6.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-01 at 11:39 +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2013-04-30 at 18:12 -0700, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Using bit fields is dangerous on ppc64, as the compiler uses 64bit
> > instructions to manipulate them. If the 64bit word includes any
> > atomic_t or spinlock_t, we can lose critical concurrent changes.
> > 
> > This is happening in af_unix, where unix_sk(sk)->gc_candidate/
> > gc_maybe_cycle/lock share the same 64bit word.
> > 
> > This leads to fatal deadlock, as one/several cpus spin forever
> > on a spinlock that will never be available again.
> > 
> > Reported-by: Ambrose Feinstein <ambrose@google.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > Cc: Paul Mackerras <paulus@samba.org>
> > ---
> > 
> > Could ppc64 experts confirm using byte is safe, or should we really add
> > a 32bit hole after the spinlock ? If so, I wonder how many other places
> > need a change...
> 
> Wow, nice one !
> 
> I'm not even completely certain bytes are safe to be honest, though
> probably more than bitfields. I'll poke our compiler people.

There is a longstanding and hard-to-fix bug in gcc that is specific to
bitfields.  I think that the underlying type isn't propagated, so when
it comes to code generation the compiler doesn't know the natural width
for the memory access.

As for bytes - early Alphas couldn't load/store less than 32 bits, but I
doubt anyone cares any more.

> The worry is of course how many more of these do we potentially have ? 
> We might be able to automate finding these issues with sparse, I
> suppose.
> 
> Also I'd be surprised if ppc64 is the only one with that problem... what
> about sparc64 and arm64 ?

I expect they can have the same general problem, but gcc may be more or
less keen to generate 64-bit load/store instructions for bitfields on
different architectures.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
