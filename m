From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: fealnx oopses
Date: Fri, 26 Mar 2004 21:57:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403262157.21624.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <20040326192211.GA15319@scream.fjortis.info>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Henriksson <andreas@fjortis.info>
In-Reply-To: <20040326192211.GA15319@scream.fjortis.info>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 26 March 2004 21:22, Andreas Henriksson wrote:
> On Fri, Mar 26, 2004 at 12:14:57PM +0200, Denis Vlasenko wrote:
>
> <snip>
>
> > BTW, my box is indeed slow and low on RAM, this fits.
>
> I have only been looking at problems with races between the interrupt
> handler and the rest of the driver code.. there might be a bunch of
> problems with failed memory allocations that hasn't bitten me.
>
> > Regarding your patch: I looked in start_tx(). Apart from latent
> > bug in commented out part of code:
> > 	next = (struct fealnx *) np->cur_tx_copy.next_desc_logical;
> > which must be
> > 	next = (struct fealnx_desc *) np->cur_tx_copy->next_desc_logical;
> > I can't see anything racy there. The function just submits more
> > tx buffers for the card, it never touch cur_tx or cur_tx->skbuff...
>
> Francois Romieu explains the race in a comment to the bug I opened in
> the bugzilla.
>
> http://bugzilla.kernel.org/show_bug.cgi?id=1902#c1

> The problem is that really_tx_count and similar parts of the private
> structure isn't atomically updated and both the interrupt handler and
> the start_tx function updates them.
> (they are regular integers instead of atomic_t)

------- Additional Comment #1 From Francois Romieu  2004-02-27 14:53 -------
Afaiks, np->{free_tx_count/really_tx_count} update in start_xmit is not atomic 
wrt the irq handler and the irq handler updates these variables as well. 
So we could have: 
- start_xmit reads really_tx_count (first step to update really_tx_count); 
- first tx irq takes place in and updates really_tx_count 
- start_xmit ends updating really_tx_count, ignoring the value set in the irq 
handler 
- second tx irq takes place and reads an erroneously high really_tx_count 
value 
- <censored> 

Nice explanation, but on x86 uniprocessor it can't happen.

> > If I miss something and it indeed races with interrupt, you
> > definitely need to add
> >         spin_lock(&np->lock);
> > ...
> >         spin_unlock(&np->lock);
> > around interrupt handler body or at least around tx part
> > of it, or else your patch is incomplete (race will still
> > be possible on SMP).
>
> I came to the conclusion that there should be a spinlock in the
> interrupt handler yesterday, but it won't effect me at all since I don't
> have SMP (nor preempt) so I'll leave it for now anyway.
>
> > Anyway, I applied your patch and flooded with UDP again.
> > My box did not oops. Unfortunately, it did not oops when
> > I reverted back to old, presumably buggy driver. I cannot
> > reproduce it anymore with old driver too! Bad. :(
>
> I haven't been able to reproduce a kernel panic with my patch eighter.
> And I've been transfering Terabytes of traffic during the last weeks (or
> maybee it's months, well anyway.. I've done enough testing to say that
> the card works "good enough" in this machine atleast).
> And I've even tried your udp test..
>
> Although I now have the myson/fealnx card in my p3-900 (256Mb)
> workstation instead of the old p-166 (40Mb) which served as a gateway
> before. It might just be that it's harder to trigger on newer/bigger
> machines. Maybee I should power up my p-166 again.. I actually have 2 of
> these cards so I can have one in each machine.. :)

A Good Idea (tm)
I have a spare P75, do you need it? ;)
--
vda
