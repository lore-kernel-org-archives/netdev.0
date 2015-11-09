From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [GIT] Networking
Date: Mon, 09 Nov 2015 15:16:56 +0100
Message-ID: <87a8qnz293.fsf@rasmusvillemoes.dk>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
	<CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
	<1446030209.105419.422375497.14563933@webmail.messagingengine.com>
	<87pozzvzj6.fsf@rasmusvillemoes.dk>
	<1447070962.399769.433652241.038FDB6A@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447070962.399769.433652241.038FDB6A@webmail.messagingengine.com>
	(Hannes Frederic Sowa's message of "Mon, 09 Nov 2015 13:09:22 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 09 2015, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> Hi,
>
> On Wed, Oct 28, 2015, at 15:27, Rasmus Villemoes wrote:
>> 
>> I agree - proper overflow checking can be really hard. Quick, assuming a
>> and b have the same unsigned integer type, is 'a+b<a' sufficient to
>> check overflow? Of course not (hint: promotion rules). And as you say,
>> it gets even more complicated for signed types.
>> 
>> A few months ago I tried posting a complete set of fallbacks for older
>> compilers (https://lkml.org/lkml/2015/7/19/358), but nothing really
>> happened. Now I know where Linus stands, so I guess I can just delete
>> that branch.
>
> I actually like your approach of being type agnostic a bit more (in
> comparison to static inline functions), mostly because of one specific
> reason:
>
> The type agnostic __builtin_*_overflow function even do the correct
> things if you deal with types smaller than int. Imagine e.g. you want to
> add to unsigned chars a and b,

If you read my mail again you'll see that I mentioned exactly this :-)
so obviously I agree that this is a nice part of it.

> unsigned char a, b;
> if (a + b < a)
>   goto overflow;
> else
>   a += b;
>
> The overflow condition will never trigger, as the comparisons will
> always be done in the integer domain and a + b < a is never true. I
> actually think that this is easy to overlook and the functions should
> handle that.

Yes. While people very rarely use local u8 or u16 variables for
computations, I think one could imagine a and b being struct members,
which for one reason or another happens to be of a type narrower than
int (which would also make the issue much harder to spot since the
struct definition is far away). Something like

combine_packets(struct foo *a, const struct foo *b)
{
  if (a->len + b->len < a->len)
    return -EOVERFLOW;
  /* ensure a->payload is big enough...*/
  memcpy(a->payload + a->len, b->payload, b->len);
  a->len += b->len;
  ...
}

which, depending on details, would either lead to memory corruption or
loss of parts of the packets.

I haven't actually found any instance of this in the kernel, but that
doesn't mean it couldn't get introduced (or that it doesn't exist).

Aside: It turns out clang is smart enough to optimize away the broken
overflow check, but gcc isn't. Neither issue a warning, despite the
intention being rather clear.

Rasmus
