From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Mon, 2 Nov 2015 18:38:44 -0800
Message-ID: <CA+55aFxgr=VteHvxj7EY===QbchRdLY56r7cyFxSnuF_G0rqVA@mail.gmail.com>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
	<CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
	<5637C8DF.800@kernel.org>
	<CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com>
	<CA+55aFy6nC9tQFE_kRrF-YS9N7Jp18CnSxsLNcnAykNLyXQUtg@mail.gmail.com>
	<CALCETrUxU_AVcQheeCXc0qTh=o2tmDbDct27QfTCb_+G6qc3gQ@mail.gmail.com>
	<1446512176.17404.30.camel@kernel.crashing.org>
	<CA+55aFxas=6fg2LtcLjDB3jM9cHBj=7PnDf-8J31jc3yXNpXNQ@mail.gmail.com>
	<CALCETrUijiLwtYRwc-UHPkuhh+PoMh0scwffewuJ+7wRBR=Jfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Andy Lutomirski <luto@kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrUijiLwtYRwc-UHPkuhh+PoMh0scwffewuJ+7wRBR=Jfg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 2, 2015 at 5:58 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>
> Based in part on an old patch by Sasha, what if we relied on CSE:
>
> if (mul_would_overflow(size, n))
>   return NULL;
> do_something_with(size * n);

I suspect we wouldn't even have to rely on CSE. Are these things in
performance-critical areas? I suspect our current "use divides" is
actually slower than just using two multiplies, even if one is only
used for overflow checking.

That said, I also think that for something like this, where we
actually have a *reason* for using a special overflow helper function,
we could just try to use the gcc syntax.

I don't think it's wonderful syntax, but at least there's an excuse
for odd/ugly code in those kinds of situations. The reason I hated the
unsigned subtraction case so much was that the simple obvious code
just avoids all those issues entirely, and there wasn't any real
*reason* for the nasty syntax. For multiplication overflow, we'd at
least have a reason.

Sadly, the *nice* syntax, where we'd do something like "goto label"
when the multiply overflows, does not mesh well with inline asm.  Yes,
gcc now has "asm goto", but you can't use it with an output value ;(

But from a syntactic standpoint, the best syntax might actually be
something like

        mul = multiply_with_overflow(size, n, error_label);
        do_something_with(mul);

    error_label:
        return NULL;

and it would *almost* be possible to do this with inline asm if it
wasn't for the annoying "no output values" case.  There are many other
cases where I'd have wanted to do this (ie the whole "fetch value from
user space, but if an exception happens, point the exception handler
at the label).

Back in May, we talked to the gcc people about allowing output values
that are unspecified for the "goto" case (so only a fallthrough would
have them set), but I think that that doesn't match how gcc internally
thinks about branching instructions..

But you could still hide it inside a macro and make it expand to something like

   #define multiply_with_overflow(size, n, error_label) ({
        unsigned long result, error; \
        .. do multiply in asm, set result and error... \
        if (error) goto error_label;
        result; })

which would allow the above kind of odd hand-coded try/catch model in
C. Which I think would be pretty understandable and not very prone to
getting it wrong. Hmm?

                     Linus
