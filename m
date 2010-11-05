From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Fri, 05 Nov 2010 19:00:46 +0100
Message-ID: <1288980046.2882.1054.camel@edumazet-laptop>
References: <1288975980.2882.877.camel@edumazet-laptop>
	 <20101105102038.53e36f9e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Nick Piggin <npiggin@kernel.dk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34273 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959Ab0KESAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 14:00:52 -0400
In-Reply-To: <20101105102038.53e36f9e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 novembre 2010 =C3=A0 10:20 -0700, Andrew Morton a =C3=A9=
crit :

> It totally makes sense to add include/linu/atomic.h for common things=
=2E=20
> Perhaps there's already code in arch/*/include/asm/atomic.h which
> should be hoisted up there.  But that can't reliably be done until a
> million files have had their #includes switched :(
>=20

Maybe including <linux/atomic.h> only from the end of various

arch/*/include/asm/atomic.h  ?

In this case, I remove the include <asm/atomic.h> from linux/atomic.h

> It's quite unobvious *why* `hint' cannot be zero.  Can you please add
> the reasoning to the comment?  Also, the local `hint' should be
> referred to as "@hint" in a kerneldoc comment.

Well ;)

We want to increment the counter if its not zero.
Typically used for refcounts, of RCU protected structures.

Giving a zero hint would be curious dont you think ?

I see no usage for this, and using atomic_inc_not_zero() in this case i=
s
the only choice, since we dont ever want to cmpxchg(v, 0, 1) (or risk
double free and crazy things)

Hmm... maybe I can add a test (compiler should optimize it anyway, sinc=
e
all usages I can foresee will use a constant hint)

>=20
> > +static inline int atomic_inc_not_zero_hint(atomic_t *v, int hint)
> > +{
> > +	int val, c =3D hint;
> > +
> > + 	do {
> > +		val =3D atomic_cmpxchg(v, c, c + 1);
> > +		if (val =3D=3D c)
> > +			return 1;
> > +		c =3D val;
> > +	} while (c);
> > +
> > +	return 0;
> > +}
>=20
> Should/could this have implemented a more general
> atomic_add_not_zero_hint() and made atomic_inc_not_zero_hint() a
> wrapper around that?

Well, I see no practical use for this, but yes, this could be done.

As atomic_add_not_zero() doesnt exist, I am not sure we need an
atomic_add_not_zero_hint() yet ?

>=20
> Also, it might make sense to add "#ifndef atomic_inc_not_zero_hint"
> wrappers around this function so that the arch can implement an
> overriding custom version.  And that becomes a general rule as more
> functions are added to include/linux/atomic.h.

Ah yes, thats right !

Thanks !

[PATCH v2] atomic: add atomic_inc_not_zero_hint()

=46ollowup of perf tools session in Netfilter WorkShop 2010

In network stack we make high usage of atomic_inc_not_zero() in context=
s
we know the probable value of atomic before increment (2 for udp socket=
s
for example)

Using a special version of atomic_inc_not_zero() giving this hint can
help processor to use less bus transactions.

On x86 (MESI protocol) for example, this avoids entering Shared state,
because "lock cmpxchg" issues an RFO (Read For Ownership)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: David Miller <davem@davemloft.net>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Nick Piggin <npiggin@kernel.dk>
---
V2: add #ifndef atomic_inc_not_zero_hint
    kerneldoc changes
    test that hint is not null
    Meant to be included at end of arch/*/asm/atomic.h files

 include/linux/atomic.h |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+)

diff --git a/include/linux/atomic.h b/include/linux/atomic.h
new file mode 100644
index 0000000..0897bdd
--- /dev/null
+++ b/include/linux/atomic.h
@@ -0,0 +1,36 @@
+#ifndef _LINUX_ATOMIC_H
+#define _LINUX_ATOMIC_H
+
+/**
+ * atomic_inc_not_zero_hint - increment if not null
+ * @v: pointer of type atomic_t
+ * @hint: probable value of the atomic before the increment
+ *
+ * This version of atomic_inc_not_zero() gives a hint of probable
+ * value of the atomic. This helps processor to not read memory
+ * before doing the atomic read/modify/write cycle, lowering
+ * number of bus transactions on some arches.
+ * Note: @hint MUST not be 0, or increment is not done.
+ * Returns: 0 if increment was not done, 1 otherwise.
+ */
+#ifndef atomic_inc_not_zero_hint
+static inline int atomic_inc_not_zero_hint(atomic_t *v, int hint)
+{
+	int val, c =3D hint;
+
+	/* sanity test, should be removed by compiler if hint is a constant *=
/
+	if (!hint)
+		return 0;
+
+ 	do {
+		val =3D atomic_cmpxchg(v, c, c + 1);
+		if (val =3D=3D c)
+			return 1;
+		c =3D val;
+	} while (c);
+
+	return 0;
+}
+#endif
+
+#endif /* _LINUX_ATOMIC_H */


