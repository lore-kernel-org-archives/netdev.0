From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: >Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Fri, 28 Oct 2011 16:47:32 +0200
Message-ID: <1319813252.23112.122.camel@edumazet-laptop>
References: <1319764761.23112.14.camel@edumazet-laptop>
	 <20111028012521.GF25795@one.firstfloor.org>
	 <CA+55aFy9oJSK99K=brRzSfSnLocO=PuS7yuKkAcw3t5hATJrfw@mail.gmail.com>
	 <1319766293.6759.17.camel@deadeye>
	 <1319770376.23112.58.camel@edumazet-laptop>
	 <1319772566.6759.27.camel@deadeye>
	 <1319777025.23112.67.camel@edumazet-laptop>
	 <CA+55aFzHf563auNYdNeJnsbbry1OUfkepkiVHt7Fy-bG64Fruw@mail.gmail.com>
	 <1319803781.23112.113.camel@edumazet-laptop>
	 <CA+55aFxzgc5pC1p6J8YADNDwmAjUYNRKLvir6OQMueWqUXOaEQ@mail.gmail.com>
	 <CA+55aFxy6VSBbikFrfXwUPOafihR+MOdi+yKSp_6qz7_Vax_YA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxy6VSBbikFrfXwUPOafihR+MOdi+yKSp_6qz7_Vax_YA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 28 octobre 2011 =C3=A0 05:40 -0700, Linus Torvalds a =C3=A9=
crit :
> On Fri, Oct 28, 2011 at 5:19 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > "Sane interfaces" are important. Insane interfaces lead to bugs.
>=20
> Qutie frankly, if I do "atomic_read()", I do expect to get a single
> value. If I don't get a single value, but some mixture of two values,
> I'd personally go
>=20
>   wtf, what does that "atomic" mean in "atomic_read()"?
>=20
> and I think that's a reasonable wtf to ask.
>=20
> That said, as mentioned, I don't know of any way to tell gcc "at most=
 once".
>=20
> Hmm.
>=20
> Except perhaps using inline asm. Something like this might work:
>=20
>   static inline int atomic_read(const atomic_t *v)
>   {
>        int val;
>        asm("":"=3Dr" (val):"0" (v->value));
>        return val;
>   }
>=20
> (totally untested, but you get the idea: use a non-volatile asm to
> make sure that gcc doesn't think it can re-load the value).
>=20
> That's the trick we use in asmlinkage_protect() and a couple of other
> places. It *should* make gcc able to optimize the value away entirely
> if it isn't used, but will stop gcc from doing the reload magic.
>=20
> Does that work for the test-case with VM_BUG_ON()?


On x86 it seems to work :

c050f80f: 0f 84 ea 00 00 00       je     c050f8ff <tcp_sendmsg+0xa1f>
c050f815: 8b 55 bc                mov    -0x44(%ebp),%edx
c050f818: f0 ff 42 10             lock incl 0x10(%edx)      atomic_inc(=
&page->count)
c050f81c: 8b 02                   mov    (%edx),%eax        page->flags
c050f81e: 25 00 40 02 00          and    $0x24000,%eax
c050f823: 3d 00 40 02 00          cmp    $0x24000,%eax
c050f828: 0f 84 9f 01 00 00       je     c050f9cd <tcp_sendmsg+0xaed>

On x86_64 (gcc-4.6.1 Debian-4.6.1-4) we still have a page->flags useles=
s load,
but the atomic_read() itself is removed.


This looks like a CONFIG_PAGEFLAGS_EXTENDED difference.

In this case, PageTail() is :

#define TESTPAGEFLAG(uname, lname)                  \
static inline int Page##uname(const struct page *page)          \
	{ return test_bit(PG_##lname, &page->flags); }=20


So we need a similar idea to remove the volatile from :

static __always_inline int constant_test_bit(unsigned int nr, const vol=
atile unsigned long *addr)
{
return ((1UL << (nr % BITS_PER_LONG)) &
	 (addr[nr / BITS_PER_LONG])) !=3D 0;
}
