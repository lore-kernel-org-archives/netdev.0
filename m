From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Mon, 2 Nov 2015 17:54:43 -0800
Message-ID: <CA+55aFxas=6fg2LtcLjDB3jM9cHBj=7PnDf-8J31jc3yXNpXNQ@mail.gmail.com>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
	<CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
	<5637C8DF.800@kernel.org>
	<CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com>
	<CA+55aFy6nC9tQFE_kRrF-YS9N7Jp18CnSxsLNcnAykNLyXQUtg@mail.gmail.com>
	<CALCETrUxU_AVcQheeCXc0qTh=o2tmDbDct27QfTCb_+G6qc3gQ@mail.gmail.com>
	<1446512176.17404.30.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>,
	Andy Lutomirski <luto@kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446512176.17404.30.camel@kernel.crashing.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 2, 2015 at 4:56 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
>
> Also how much of the problem is simply that the function signature
> (naming and choice of arguments) just plain sucks ?

Some of that is pretty much inevitable.

C really has no good way to return multiple values. The traditional
(pass pointer to fill in result) one simply doesn't result in
good-looking code.

We've occasionally done it by simply breaking C syntax: see "do_div()"
(which returns a value *and* just changes the first argument directly
as a macro). People have tended to absolutely hate it, and while it
can be very practical, it has certainly also resulted in people being
confused. It was originally done for printing numbers, where the whole
"return remainder and divide argument" model was really convenient.

Sometimes we've done it by knowing the value space: the whole "return
error value _or_ a resulting pointer value" by just knowing the
domains (ie "ERR_PTR()" end friends). That tends to work really badly
for arithmetic overflows, though.

And at other times, we've returned structures, which can efficiently
contain two words, and gcc generates reasonable code for.

The *natural* thing to do would actually be to trap and set a flag. We
do that with

    put_user_try {
        ...
    } put_user_catch(err);

which sets "err" if one of the "put_user_ex()" or calls in between traps.

The "try/catch" model would probably be the best one syntactically for
overflow handling.  It could even be done with macros (ie the "catch"
thing would contain a special overflow label, and the "overflow
functions" would then just jump to that labeln in the error case as a
way to avoid the "return two different values" thing).

Of course, try/catch only really makes sense if you have multiple
operations that can overflow in different parts. That's can be the
pattern in many other cases, but for the kernel it's quite unusual.
It's seldom more than one single operation we need to worry about in
any particular sequence (the "put_user_try/catch" use we have is
exactly because signal handling writes multiple different values to
the same stack when it generates the stack frame).

And with all that said, realistically, in the kernel we seldom have a
ton of complex overflow issues. Most of the values we have are
unsigned, and we have historically just done them manually with

    sum = a+b;
    if (sum < a)
         .. handle error ..

which really doesn't get much better from any syntactic stuff around
it (because any other syntax will involve the whole "how do I return
two values" problem and make it less legible).

Gcc is even smart enough to turn that into a "just check the carry
flag" if the patterns are simple enough, so the simple approach can
even generate optimal code.

The biggest problem - and where the compiler could actually help us -
tends to be multiplication overflows. We have several (not *many*, but
certainly more than just a couple) cases where we simply check by
dividing MAX_INT or something.

See for example kmalloc_array(), which does

        if (size != 0 && n > SIZE_MAX / size)
                return NULL;

exactly to avoid the overflow when it does the "n*size" allocation.

So for multiplication, we really *could* use overflow logic. It's not
horribly common, but it definitely happens.

Signed integer overflows are annoying even for simple addition and
subtraction, but I can't off-hand recall any real case where that was
even an issue in the kernel.

                  Linus
