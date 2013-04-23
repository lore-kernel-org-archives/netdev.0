From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Unsigned widening casts of binary "not" operations..
Date: Tue, 23 Apr 2013 11:21:14 -0700
Message-ID: <CA+55aFz1mGf+XXQmXr+8GA2cEBRABzG1PSvPgLCJ-18hzViqZg@mail.gmail.com>
References: <CA+55aFxvpcF7+dyy5d3+JP4Wfv90zPsRVtEhNG9Pky5gWTm_Pg@mail.gmail.com>
	<20130423.133732.2222922370397287096.davem@davemloft.net>
	<CA+55aFzVcptyMSDpFzE_-npbs-ycS+9z_nknoZm1+bQws1pWnA@mail.gmail.com>
	<20130423.135657.824070337983596004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	Ingo Molnar <mingo@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130423.135657.824070337983596004.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 23, 2013 at 10:56 AM, David Miller <davem@davemloft.net> wrote:
>
> If you're not bored, and could add a check for that kind of narrowing
> situation, I'd really appreciate it.

It's pretty non-trivial.

For example, this is perfectly normal C:

   char a,b;
   ...
   a &= ~b;

and the arithmetic is technically done in "int" (because C really
never does any arithmetic in a narrower type). So the value of 'b'
will be widened to int before doing the binary not, and then the
binary 'and' will be done in 'int', and then in the end it will be
cast down to 'char' again and written back to 'a'.

And none of that matters. All the normal integer operations (both
arithmetic and logical) are "stable" in the smaller size. The upper
bits can be basically random uninteresting crap (ie do zero or sign
extension depending on the smaller type), but they don't matter
because they go away in the end. In fact, the compiler will usually
then end up doing the actual arithmetic/logical op in the narrower
type, even though *conceptually* there were lots of casts going on
back and forth.

The point being that at the actual time of the widening, it's hard to
say whether "~(u8)0" is problematic or not - it will depend on how it
ends up being used. At a much later point, sparse will have optimized
away the casts and will indeed linearize it to a simple 8-bit
operation, but by then sparse will *also* have simplified away the
obviously constant arithmetic, so by the time the casts back and forth
are gone, so is the logical "not", and all you have left of the
"~(u8)0" is either a 8-bit value (255) or an "int" (-1) depending on
how it was used.

Put another way: it's not possible to say that "~(u8)0" is wrong early
on (because it may be part of something that ends up only doing byte
arithmetic) and it is *also* not possible to say that it's invalid
much later on, because by then we will have munged it into something
totally different.

I'm not saying it's impossible to do. You could certainly do it with
sparse, but it would involve a fair amount of effort. You'd have to
add a whole new separate phase of "type narrowing": sparse *does* do
that as part of the simplification, but right now it's done while it
does all the *other* simplification too, so ..

Now, if you only wanted the warning when there is an *explicit* cast,
that would be different. It would be easy enough to find the pattern
where we do a "~" op on an explicit cast to something smaller than
"int" (which means that there would be an implicit cast after the
explicit one). But quite frankly, you could likely do that almost
equally well with just a judicious use of "grep".

                      Linus
