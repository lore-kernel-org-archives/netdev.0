From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [GIT] Networking
Date: Tue, 03 Nov 2015 13:53:20 +0100
Message-ID: <1446555200.1870849.427743457.63139285@webmail.messagingengine.com>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
 <CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
 <5637C8DF.800@kernel.org>
 <CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com>
 <CA+55aFy6nC9tQFE_kRrF-YS9N7Jp18CnSxsLNcnAykNLyXQUtg@mail.gmail.com>
 <CALCETrUxU_AVcQheeCXc0qTh=o2tmDbDct27QfTCb_+G6qc3gQ@mail.gmail.com>
 <1446512176.17404.30.camel@kernel.crashing.org>
 <CA+55aFxas=6fg2LtcLjDB3jM9cHBj=7PnDf-8J31jc3yXNpXNQ@mail.gmail.com>
 <CALCETrUijiLwtYRwc-UHPkuhh+PoMh0scwffewuJ+7wRBR=Jfg@mail.gmail.com>
 <CA+55aFxgr=VteHvxj7EY===QbchRdLY56r7cyFxSnuF_G0rqVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Andy Lutomirski <luto@kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxgr=VteHvxj7EY===QbchRdLY56r7cyFxSnuF_G0rqVA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Tue, Nov 3, 2015, at 03:38, Linus Torvalds wrote:
> On Mon, Nov 2, 2015 at 5:58 PM, Andy Lutomirski <luto@amacapital.net>
> wrote:
> >
> > Based in part on an old patch by Sasha, what if we relied on CSE:
> >
> > if (mul_would_overflow(size, n))
> >   return NULL;
> > do_something_with(size * n);
> 
> I suspect we wouldn't even have to rely on CSE. Are these things in
> performance-critical areas? I suspect our current "use divides" is
> actually slower than just using two multiplies, even if one is only
> used for overflow checking.

And furthermore we don't actually have to rely on CSE if we want to, our
overflow checks could look much more simpler as in "ordinary" C code
because we tell the compiler that signed overflow is defined throughout
the kernel ( -fno-strict-overflow). Thus the checks can be done after
the calculations.

> That said, I also think that for something like this, where we
> actually have a *reason* for using a special overflow helper function,
> we could just try to use the gcc syntax.
>
> I don't think it's wonderful syntax, but at least there's an excuse
> for odd/ugly code in those kinds of situations. The reason I hated the
> unsigned subtraction case so much was that the simple obvious code
> just avoids all those issues entirely, and there wasn't any real
> *reason* for the nasty syntax. For multiplication overflow, we'd at
> least have a reason.
> 
> Sadly, the *nice* syntax, where we'd do something like "goto label"
> when the multiply overflows, does not mesh well with inline asm.  Yes,
> gcc now has "asm goto", but you can't use it with an output value ;(

I don't understand why you consider inline asm? Those builtins already
normally produce very reasonable code (and yes, I checked). We can wrap
the gcc builtins anyway and adapt the syntax as needed. inline asm does
prohibit constant folding etc, so a __builtin_constant_p check would be
necessary or helpful further adding complexity.
 
> But from a syntactic standpoint, the best syntax might actually be
> something like
> 
>         mul = multiply_with_overflow(size, n, error_label);
>         do_something_with(mul);
> 
>     error_label:
>         return NULL;
> 
> and it would *almost* be possible to do this with inline asm if it
> wasn't for the annoying "no output values" case.  There are many other
> cases where I'd have wanted to do this (ie the whole "fetch value from
> user space, but if an exception happens, point the exception handler
> at the label).

I don't see the problem with the

  if (multiply_with_overflow(...))
    overflowed_handle_error(...);

multiply_with_overflow can have a __must_check attribute, so we see
warnings if return value is not checked immediately.

It allows chaining easily

if (multiply_with_overflow(...) ||
    multiply_with_overflow(...))
      goto overflow;

without adding checks between the different stages or calculation. It
just composes nicely. The error handling is very explicit.

> Back in May, we talked to the gcc people about allowing output values
> that are unspecified for the "goto" case (so only a fallthrough would
> have them set), but I think that that doesn't match how gcc internally
> thinks about branching instructions..
> 
> But you could still hide it inside a macro and make it expand to
> something like
> 
>    #define multiply_with_overflow(size, n, error_label) ({
>         unsigned long result, error; \
>         .. do multiply in asm, set result and error... \
>         if (error) goto error_label;
>         result; })
> 
> which would allow the above kind of odd hand-coded try/catch model in
> C. Which I think would be pretty understandable and not very prone to
> getting it wrong. Hmm?

Hiding branches in macros seems not to be a good idea to me at all. I
actually think a lot of users in functions would simply check their
arguments and return -EINVAL in case they overflow. Forcing them to do a
jump seems inappropriate.

I also don't think that reordering the arguments makes a lot of sense:

bool overflow;
int a = multiply_with_overflow(b, c, &overflow);
if (overflow)
  error out;

This scheme might be composable if we ||= the overflow flag in the
helper functions/macros and force the user to initialize the overflow
boolean it to false in the beginning. Way too many things that can go
wrong and an auditor has to verify.

Bye,
Hannes
