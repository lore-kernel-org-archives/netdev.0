From: Andreas Henriksson <andreas@fjortis.info>
Subject: Re: fealnx oopses
Date: Fri, 26 Mar 2004 20:22:11 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040326192211.GA15319@scream.fjortis.info>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 26, 2004 at 12:14:57PM +0200, Denis Vlasenko wrote:

<snip>

> BTW, my box is indeed slow and low on RAM, this fits.
> 

I have only been looking at problems with races between the interrupt
handler and the rest of the driver code.. there might be a bunch of
problems with failed memory allocations that hasn't bitten me.

> 
> Regarding your patch: I looked in start_tx(). Apart from latent
> bug in commented out part of code:
> 	next = (struct fealnx *) np->cur_tx_copy.next_desc_logical;
> which must be
> 	next = (struct fealnx_desc *) np->cur_tx_copy->next_desc_logical;
> I can't see anything racy there. The function just submits more
> tx buffers for the card, it never touch cur_tx or cur_tx->skbuff...

Francois Romieu explains the race in a comment to the bug I opened in
the bugzilla.

http://bugzilla.kernel.org/show_bug.cgi?id=1902#c1

The problem is that really_tx_count and similar parts of the private
structure isn't atomically updated and both the interrupt handler and
the start_tx function updates them.
(they are regular integers instead of atomic_t)

> 
> If I miss something and it indeed races with interrupt, you
> definitely need to add
>         spin_lock(&np->lock);
> ...
>         spin_unlock(&np->lock);
> around interrupt handler body or at least around tx part
> of it, or else your patch is incomplete (race will still
> be possible on SMP).
> 

I came to the conclusion that there should be a spinlock in the
interrupt handler yesterday, but it won't effect me at all since I don't
have SMP (nor preempt) so I'll leave it for now anyway.

>
> Anyway, I applied your patch and flooded with UDP again.
> My box did not oops. Unfortunately, it did not oops when
> I reverted back to old, presumably buggy driver. I cannot
> reproduce it anymore with old driver too! Bad. :(

I haven't been able to reproduce a kernel panic with my patch eighter.
And I've been transfering Terabytes of traffic during the last weeks (or
maybee it's months, well anyway.. I've done enough testing to say that
the card works "good enough" in this machine atleast).
And I've even tried your udp test..

Although I now have the myson/fealnx card in my p3-900 (256Mb)
workstation instead of the old p-166 (40Mb) which served as a gateway before.
It might just be that it's harder to trigger on newer/bigger machines.
Maybee I should power up my p-166 again.. I actually have 2 of these
cards so I can have one in each machine.. :)

> --
> vda
> 

--

Regards,
Andreas Henriksson
