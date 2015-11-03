From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 3 Nov 2015 12:05:38 -0800
Message-ID: <CA+55aFw-pzoSNnO_eot1c2ZJOWKrFeRhXw4oQQS9dwt4NziHfQ@mail.gmail.com>
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
	<1446555200.1870849.427743457.63139285@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Andy Lutomirski <luto@kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446555200.1870849.427743457.63139285@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 3, 2015 at 4:53 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> And furthermore we don't actually have to rely on CSE if we want to, our
> overflow checks could look much more simpler as in "ordinary" C code
> because we tell the compiler that signed overflow is defined throughout
> the kernel ( -fno-strict-overflow). Thus the checks can be done after
> the calculations.

Yes. We could actually do overflow checks by just verifying the
result, even for signed stuff.

> I don't understand why you consider inline asm? Those builtins already
> normally produce very reasonable code

Those built-ins only exist with gcc-5+, afaik.

We'll have people who rely on old versions of gcc for *years* after
gcc5 is commonly available. They'll be running enterprise distros or
debian-stable or things like that.

So we do need to have reasonable backwards compatibility functions.
For things like multiplication overflow, inline asm may be the best
way to do that.

That said, we'll be able to work around it, I'm sure. But no, we're
not going to be in the situation where we just know we can use the
builtins.

> I don't see the problem with the
>
>   if (multiply_with_overflow(...))
>     overflowed_handle_error(...);

I do agree that it's likely not a big issue.

That said, I may be influenced by hardware design, but I think I'm
also influenced by traditional good C rules: I like functions that
return the *result*, so that the result can be used in a chain of
calculations. Like hardware, the "overflow" bit is separate and I
actually think the gcc overflow functions did the calling convention
wrong.

So even if we do the "pass one of the results by reference" thing, I'd
much rather that "pas by reference" be for the overflow condition.

And hardware that does it well tends to not just give an "overflow"
result, but a "summary overflow", so that you can do multiple
operations in series, and then just check the "summary overflow" at
the end.

So my gut feel is that overflow should either be an exception (ie the
whole "jump to another place" model), or it should be a flag value,
but it shouldn't be the "result" of the function.

For example, one of the overflow issues we've had occasionally has
been not about a single op, but a series of operations:
"multiply-and-add". Look at __timespec64_to_jiffies(), for example,
where the operation that can overflow is "seconds * SEC_CONVERSION +
nsec * NSEC_CONVERSION".

Now, in that case we currently handle the overflow by just knowing
that 'nsec' had better follow certain rules, so we can simply check
seconds against a known maximum, and we don't need to get the "exact"
overflow condition. And quite honestly, that may end up *always* being
the right thing to do - there just isn't any real reason to worry
about individual operations overflowing.

But imagine that we did. The "summary overflow" interface would allow
us to do something like

     bool overflow = 0;

     result = add_overflow(
        mul_overflow(sec, SEC_CONVERSION, &overflow),
        mul_overflow(nsec, NSEC_CONVERSION, &overflow),
        &overflow);

     return overflow ? MAX_JIFFIES : result;

which I'm not at all actually advocating (because (a) I think the
current code is simpler and (b) I don't like the silly
"add_overflow()" anyway), but that I'm giving as an example of why I
think the gcc builtin result passing choice looks a bit odd to me.

> multiply_with_overflow can have a __must_check attribute, so we see
> warnings if return value is not checked immediately.

Yes. There may be advantages to that too. That said, I'm not seeing
that as a big deal. If you use the overflow functions and don't check
the overflow condition, you kind of have bigger issues than "I'd like
to get a compiler warning". That's more of a "WTF is the person doing"
thing).

                  Linus
