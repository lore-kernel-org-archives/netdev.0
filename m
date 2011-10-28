From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: >Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Fri, 28 Oct 2011 05:40:53 -0700
Message-ID: <CA+55aFxy6VSBbikFrfXwUPOafihR+MOdi+yKSp_6qz7_Vax_YA@mail.gmail.com>
References: <1319764761.23112.14.camel@edumazet-laptop> <20111028012521.GF25795@one.firstfloor.org>
 <CA+55aFy9oJSK99K=brRzSfSnLocO=PuS7yuKkAcw3t5hATJrfw@mail.gmail.com>
 <1319766293.6759.17.camel@deadeye> <1319770376.23112.58.camel@edumazet-laptop>
 <1319772566.6759.27.camel@deadeye> <1319777025.23112.67.camel@edumazet-laptop>
 <CA+55aFzHf563auNYdNeJnsbbry1OUfkepkiVHt7Fy-bG64Fruw@mail.gmail.com>
 <1319803781.23112.113.camel@edumazet-laptop> <CA+55aFxzgc5pC1p6J8YADNDwmAjUYNRKLvir6OQMueWqUXOaEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxzgc5pC1p6J8YADNDwmAjUYNRKLvir6OQMueWqUXOaEQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 28, 2011 at 5:19 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> "Sane interfaces" are important. Insane interfaces lead to bugs.

Qutie frankly, if I do "atomic_read()", I do expect to get a single
value. If I don't get a single value, but some mixture of two values,
I'd personally go

  wtf, what does that "atomic" mean in "atomic_read()"?

and I think that's a reasonable wtf to ask.

That said, as mentioned, I don't know of any way to tell gcc "at most once".

Hmm.

Except perhaps using inline asm. Something like this might work:

  static inline int atomic_read(const atomic_t *v)
  {
       int val;
       asm("":"=r" (val):"0" (v->value));
       return val;
  }

(totally untested, but you get the idea: use a non-volatile asm to
make sure that gcc doesn't think it can re-load the value).

That's the trick we use in asmlinkage_protect() and a couple of other
places. It *should* make gcc able to optimize the value away entirely
if it isn't used, but will stop gcc from doing the reload magic.

Does that work for the test-case with VM_BUG_ON()?

                          Linus
