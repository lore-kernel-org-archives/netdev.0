From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 28 Oct 2015 18:39:56 +0900
Message-ID: <CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151027.233235.1641084823622810663.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 28, 2015 at 3:32 PM, David Miller <davem@davemloft.net> wrote:
>
> This may look a bit scary this late in the release cycle, but as is typically
> the case it's predominantly small driver fixes all over the place.

Christ people. This is just sh*t.

The conflict I get is due to stupid new gcc header file crap. But what
makes me upset is that the crap is for completely bogus reasons.

This is the old code in net/ipv6/ip6_output.c:

        mtu -= hlen + sizeof(struct frag_hdr);

and this is the new "improved" code that uses fancy stuff that wants
magical built-in compiler support and has silly wrapper functions for
when it doesn't exist:

        if (overflow_usub(mtu, hlen + sizeof(struct frag_hdr), &mtu) ||
            mtu <= 7)
                goto fail_toobig;

and anybody who thinks that the above is

 (a) legible
 (b) efficient (even with the magical compiler support)
 (c) particularly safe

is just incompetent and out to lunch.

The above code is sh*t, and it generates shit code. It looks bad, and
there's no reason for it.

The code could *easily* have been done with just a single and
understandable conditional, and the compiler would actually have
generated better code, and the code would look better and more
understandable. Why is this not

        if (mtu < hlen + sizeof(struct frag_hdr) + 8)
                goto fail_toobig;
        mtu -= hlen + sizeof(struct frag_hdr);

which is the same number of lines, doesn't use crazy helper functions
that nobody knows what they do, and is much more obvious what it
actually does.

I guarantee that the second more obvious version is easier to read and
understand. Does anybody really want to dispute this?

Really. Give me *one* reason why it was written in that idiotic way
with two different conditionals, and a shiny new nonstandard function
that wants particular compiler support to generate even half-way sane
code, and even then generates worse code? A shiny function that we
have never ever needed anywhere else, and that is just
compiler-masturbation.

And yes, you still could have overflow issues if the whole "hlen +
xyz" expression overflows, but quite frankly, the "overflow_usub()"
code had that too. So if you worry about that, then you damn well
didn't do the right thing to begin with.

So I really see no reason for this kind of complete idiotic crap.

Tell me why. Because I'm not pulling this kind of completely insane
stuff that generates conflicts at rc7 time, and that seems to have
absolutely no reason for being anm idiotic unreadable mess.

The code seems *designed* to use that new "overflow_usub()" code. It
seems to be an excuse to use that function.

And it's a f*cking bad excuse for that braindamage.

I'm sorry, but we don't add idiotic new interfaces like this for
idiotic new code like that.

Yes, yes, if this had stayed inside the network layer I would never
have noticed. But since I *did* notice, I really don't want to pull
this. In fact, I want to make it clear to *everybody* that code like
this is completely unacceptable. Anybody who thinks that code like
this is "safe" and "secure" because it uses fancy overflow detection
functions is so far out to lunch that it's not even funny. All this
kind of crap does is to make the code a unreadable mess with code that
no sane person will ever really understand what it actually does.

Get rid of it. And I don't *ever* want to see that shit again.

                Linus
