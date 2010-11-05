From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Fri, 05 Nov 2010 20:20:44 +0100
Message-ID: <1288984844.2665.52.camel@edumazet-laptop>
References: <1288975980.2882.877.camel@edumazet-laptop>
	 <20101105102038.53e36f9e.akpm@linux-foundation.org>
	 <1288980046.2882.1054.camel@edumazet-laptop>
	 <20101105110828.52f061b3.akpm@linux-foundation.org>
	 <1288981224.2882.1105.camel@edumazet-laptop>
	 <20101105112821.57f80481.akpm@linux-foundation.org>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101105112821.57f80481.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 05 novembre 2010 =C3=A0 11:28 -0700, Andrew Morton a =C3=A9=
crit :
> But we haven't established that there _is_ duplicated code which need=
s
> that treatment.
>=20
> Scanning arch/x86/include/asm/atomic.h, perhaps ATOMIC_INIT() is a
> candidate.  But I'm not sure that it _should_ be hoisted up - if ever=
y
> architecture happens to do it the same way then that's just a fluke.
>=20
>=20

Not sure I understand you. I was trying to avoid recursive includes, bu=
t
that should be protected anyway. I see a lot of code that could be
factorized in this new header (atomic_inc_not_zero() for example)

Thanks

[PATCH v3] atomic: add atomic_inc_not_zero_hint()

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
V3: adds the include <asm/atomic.h>
    if hint is null, use atomic_inc_not_zero() (Paul suggestion)
V2: add #ifndef atomic_inc_not_zero_hint
    kerneldoc changes
    test that hint is not null
    Meant to be included at end of arch/*/asm/atomic.h files

diff --git a/include/linux/atomic.h b/include/linux/atomic.h
new file mode 100644
index 0000000..5a7df87
--- /dev/null
+++ b/include/linux/atomic.h
@@ -0,0 +1,37 @@
+#ifndef _LINUX_ATOMIC_H
+#define _LINUX_ATOMIC_H
+#include <asm/atomic.h>
+
+/**
+ * atomic_inc_not_zero_hint - increment if not null
+ * @v: pointer of type atomic_t
+ * @hint: probable value of the atomic before the increment
+ *
+ * This version of atomic_inc_not_zero() gives a hint of probable
+ * value of the atomic. This helps processor to not read the memory
+ * before doing the atomic read/modify/write cycle, lowering
+ * number of bus transactions on some arches.
+ *
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
+		return atomic_inc_not_zero(v);
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
