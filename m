From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: >Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Fri, 28 Oct 2011 06:43:45 +0200
Message-ID: <1319777025.23112.67.camel@edumazet-laptop>
References: <1319764761.23112.14.camel@edumazet-laptop>
	 <20111028012521.GF25795@one.firstfloor.org>
	 <CA+55aFy9oJSK99K=brRzSfSnLocO=PuS7yuKkAcw3t5hATJrfw@mail.gmail.com>
	 <1319766293.6759.17.camel@deadeye>
	 <1319770376.23112.58.camel@edumazet-laptop>
	 <1319772566.6759.27.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:51467 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab1J1En5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 00:43:57 -0400
In-Reply-To: <1319772566.6759.27.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 28 octobre 2011 =C3=A0 04:29 +0100, Ben Hutchings a =C3=A9c=
rit :
> On Fri, 2011-10-28 at 04:52 +0200, Eric Dumazet wrote:
> > Le vendredi 28 octobre 2011 =C3=A0 02:44 +0100, Ben Hutchings a =C3=
=A9crit :
> >=20
> > > Whether or not it needs to provide any ordering guarantee, atomic=
_read()
> > > must never read more than once, and I think that requires the vol=
atile
> > > qualification.  It might be clearer to use the ACCESS_ONCE macro,
> > > however.
> > >=20
> >=20
> > Where this requirement comes from ?
>=20
> That is the conventional behaviour of 'atomic' operations, and caller=
s
> may depend on it.
>=20

Thats your opinion, not a fact documented in
Documentation/atomic_ops.txt

<QUOTE>
---------------------------------------------------------
Next, we have:

        #define atomic_read(v)  ((v)->counter)

which simply reads the counter value currently visible to the calling t=
hread.
The read is atomic in that the return value is guaranteed to be one of =
the
values initialized or modified with the interface operations if a prope=
r
implicit or explicit memory barrier is used after possible runtime
initialization by any other thread and the value is modified only with =
the
interface operations.  atomic_read does not guarantee that the runtime
initialization by any other thread is visible yet, so the user of the
interface must take care of that with a proper implicit or explicit mem=
ory
barrier.

*** WARNING: atomic_read() and atomic_set() DO NOT IMPLY BARRIERS! ***

Some architectures may choose to use the volatile keyword, barriers, or=
 inline
assembly to guarantee some degree of immediacy for atomic_read() and
atomic_set().  This is not uniformly guaranteed, and may change in the =
future,
so all users of atomic_t should treat atomic_read() and atomic_set() as=
 simple
C statements that may be reordered or optimized away entirely by the co=
mpiler
or processor, and explicitly invoke the appropriate compiler and/or mem=
ory
barrier for each use case.  Failure to do so will result in code that m=
ay
suddenly break when used with different architectures or compiler
optimizations, or even changes in unrelated code which changes how the
compiler optimizes the section accessing atomic_t variables.

*** YOU HAVE BEEN WARNED! ***
---------------------------------------------------------------
</QUOTE>

The only requirement of atomic_read() is that it must return value
before or after an atomic_write(), not a garbled value.

So the ACCESS_ONCE semantic is on the write side (the atomic itself
cannot be used as a temporary variable. It must contain only two value
of atomic_{write|add|sub}() [ prior to the operation, after the
operation ]

In fact, if a compiler is stupid enough to issue two reads on following
code :

static inline atomic_read(const atomic_t *p)
{
	return p->value;
}

Then its fine, because in the end the returned value will be the old or
new one.
