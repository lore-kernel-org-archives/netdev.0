From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Tue, 5 Apr 2016 21:04:18 -0300
Message-ID: <20160406000418.GA15000@localhost.localdomain>
References: <20160404162545.14332.653.stgit@localhost.localdomain>
 <20160404162818.14332.1076.stgit@localhost.localdomain>
 <20160405034437.GA9322@gondor.apana.org.au>
 <CAKgT0UfcqBUTY1SxawwKdnzS7qW7XggjzpKNcfT3cTSZ9DHMmA@mail.gmail.com>
 <20160405043209.GA9822@gondor.apana.org.au>
 <5703D4C5.9060305@solarflare.com>
 <CALx6S37p7sBZ_=xDpmW90-Aqs2sgnOjcjdvYJhEGZ7Y2=6+gcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Edward Cree <ecree@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Jesse Gross <jesse@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742AbcDFAEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 20:04:23 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S37p7sBZ_=xDpmW90-Aqs2sgnOjcjdvYJhEGZ7Y2=6+gcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2016 at 12:36:40PM -0300, Tom Herbert wrote:
> On Tue, Apr 5, 2016 at 12:07 PM, Edward Cree <ecree@solarflare.com> wrote:
> > On 05/04/16 05:32, Herbert Xu wrote:
> >> On Mon, Apr 04, 2016 at 09:26:55PM -0700, Alexander Duyck wrote:
> >>> The question I would have is what are you really losing with increment
> >>> from 0 versus fixed 0?  From what I see it is essentially just garbage
> >>> in/garbage out.
> >> GRO is meant to be lossless, that is, you should not be able to
> >> detect its presence from the outside.  If you lose information then
> >> you're breaking this rule and people will soon start asking for it
> >> to be disabled in various situations.
> >>
> >> I'm not against doing this per se but it should not be part of the
> >> default configuration.
> > I'm certainly in favour of this being configurable - indeed IMHO it should
> > also be possible to configure GRO with the 'looser' semantics of LRO, so
> > that people who want that can get it without all the horrible "don't confuse
> > Slow Start" hacks, and so that LRO can go away (AIUI the only reasons it
> > exists are (a) improved performance from the 'loose' semantics and (b) old
> > kernels without GRO.  We may not be able to kill (b) but we can certainly
> > address (a)).
> >
> > But I don't agree that the default has to be totally lossless; anyone who is
> > caring about the ID fields in atomic datagrams is breaking the RFCs, and can
> > be assumed to Know What They're Doing sufficiently to configure this.
> >
> > On the gripping hand, I feel like GRO+TSO is the wrong model for speeding up
> > forwarding/routing workloads.  Instead we should be looking into having lists
> > of SKBs traverse the stack together, splitting the list whenever e.g. the
> > destination changes.  That seems like it ought to be much more efficient than
> > rewriting headers twice, once to coalesce a superframe and once to segment it
> > again - and it also means this worry about GRO being lossless can go away.
> > But until someone tries implementing skb batches, we won't know for sure if
> > it works (and I don't have time right now ;)
> >
> Ed,
> 
> I thought about that some. It seems like we would want to do both GRO
> and retain all the individual packets in the skb so that we could use
> those for forwarding instead of GSO as I think you're saying. This

Retaining the individual packets would also help to make GRO feasible
for SCTP.  SCTP needs to know where each packet ended because of AUTH
chunks and we cannot rely on something like gso_size as each original
packet had it's own size.

I could do it for tx side (see my SCTP/GSO RFC patches) using
skb_gro_receive() with a specially crafted header skb, but I'm not
seeing a way to do it in rx side as I cannot guarantee incoming skbs
will follow that pattern.

  Marcelo

> would would work great in the plain forwarding case, but one problem
> is what to do if the host modifies the super packet (for instance when
> forwarding over a tunnel we might add encapsulation header). This
> should work in GSO (although we need to address the limitations around
> 1 encap level), not sure this is easy if we need to add a header to
> each packet in a batch.
> 
> Tom
> 
> 
> 
> > -Ed
> 
