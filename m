From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: >Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Sun, 30 Oct 2011 16:16:05 +0100
Message-ID: <1319987765.13597.60.camel@edumazet-laptop>
References: <1319772566.6759.27.camel@deadeye>
	 <1319777025.23112.67.camel@edumazet-laptop>
	 <CA+55aFzHf563auNYdNeJnsbbry1OUfkepkiVHt7Fy-bG64Fruw@mail.gmail.com>
	 <1319803781.23112.113.camel@edumazet-laptop>
	 <CA+55aFxzgc5pC1p6J8YADNDwmAjUYNRKLvir6OQMueWqUXOaEQ@mail.gmail.com>
	 <CA+55aFxy6VSBbikFrfXwUPOafihR+MOdi+yKSp_6qz7_Vax_YA@mail.gmail.com>
	 <1319813252.23112.122.camel@edumazet-laptop>
	 <CA+55aFxvcvUopBc-Q6Fp87asTuBohev8Xdm67jcKfy4Z4_BZRg@mail.gmail.com>
	 <CA+55aFz=sxRjw6u-ww0P=9hhvWaZP=+QJZ68W+B9WtvQqj9Ogg@mail.gmail.com>
	 <1319964754.13597.26.camel@edumazet-laptop>
	 <20111030095918.GA19676@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55566 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019Ab1J3PQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2011 11:16:15 -0400
In-Reply-To: <20111030095918.GA19676@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 30 octobre 2011 =C3=A0 10:59 +0100, Andi Kleen a =C3=A9crit=
 :
> > +#define ACCESS_AT_MOST_ONCE(x)			\
> > +	({	unsigned long __y;		\
>=20
> why not typeof here?
>=20
> > +		asm("":"=3Dr" (__y):"0" (x));	\
> > +		(__force __typeof__(x)) __y;	\
> > +	})
> > +
>=20
> -Andi

Because it doesnt work if x is const.

/data/src/linux/arch/x86/include/asm/atomic.h: In function
=E2=80=98atomic_read=E2=80=99:
/data/src/linux/arch/x86/include/asm/atomic.h:25:2: erreur: read-only
variable =E2=80=98__y=E2=80=99 used as =E2=80=98asm=E2=80=99 output

I understand it wont work for u64 type on 32bit arches, but is
ACCESS_AT_MOST_ONCE() sensible for this kind of usage ?

In this V2, I added a check on sizeof(x) to trigger a compile error.

BTW, I forgot the atomic64_read() possible use of ACCESS_AT_MOST_ONCE()
in arch/x86/include/asm/atomic64_64.h, this saves 600 bytes more :)

On 32bit, I am afraid we cannot change current behavior, because of the
ATOMIC64_ALTERNATIVE() use.

Thanks !

[PATCH] atomic: introduce ACCESS_AT_MOST_ONCE() helper

In commit 4e60c86bd9e (gcc-4.6: mm: fix unused but set warnings)
Andi forced VM_BUG_ON(cond) to evaluate cond, even if CONFIG_DEBUG_VM i=
s
not set :

#ifdef CONFIG_DEBUG_VM
#define VM_BUG_ON(cond) BUG_ON(cond)
#else
#define VM_BUG_ON(cond) do { (void)(cond); } while (0)
#endif

As a side effect, get_page()/put_page_testzero() are performing more bu=
s
transactions on contended cache line on some workloads (tcp_sendmsg()
for example, where a page is acting as a shared buffer)

0,05 :  ffffffff815e4775:       je     ffffffff815e4970 <tcp_sendmsg+0x=
c80>
0,05 :  ffffffff815e477b:       mov    0x1c(%r9),%eax    // useless
3,32 :  ffffffff815e477f:       mov    (%r9),%rax        // useless
0,51 :  ffffffff815e4782:       lock incl 0x1c(%r9)
3,87 :  ffffffff815e4787:       mov    (%r9),%rax
0,00 :  ffffffff815e478a:       test   $0x80,%ah
0,00 :  ffffffff815e478d:       jne    ffffffff815e49f2 <tcp_sendmsg+0x=
d02>

Thats because both atomic_read() and constant_test_bit() use a volatile
attribute and thus compiler is forced to perform a read, even if the
result is optimized away.

Linus suggested using an asm("") trick and place it in a variant of
ACCESS_ONCE(), allowing compiler to omit reading memory if result is
unused.

This patch introduces ACCESS_AT_MOST_ONCE() helper and use it in the x8=
6
implementation of atomic_read() and constant_test_bit()

It's also used on x86_64 atomic64_read() implementation.

on x86_64, we thus reduce vmlinux text a bit (if CONFIG_DEBUG_VM=3Dn)

# size vmlinux.old vmlinux.new
   text    data     bss     dec     hex filename
10706848        2894216 1540096 15141160         e70928 vmlinux.old
10704040	2894216	1540096	15138352	 e6fe30	vmlinux.new

Based on a prior patch from Linus, and review from Andi

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
V2: Add a check on sizeof(x) in ACCESS_AT_MOST_ONCE()
    Use ACCESS_AT_MOST_ONCE() on x86_64 atomic64_read()

 arch/x86/include/asm/atomic.h      |    2 +-
 arch/x86/include/asm/atomic64_64.h |    2 +-
 arch/x86/include/asm/bitops.h      |    7 +++++--
 include/asm-generic/atomic.h       |    2 +-
 include/linux/compiler.h           |   15 +++++++++++++++
 5 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomi=
c.h
index 58cb6d4..b1f0c6b 100644
--- a/arch/x86/include/asm/atomic.h
+++ b/arch/x86/include/asm/atomic.h
@@ -22,7 +22,7 @@
  */
 static inline int atomic_read(const atomic_t *v)
 {
-	return (*(volatile int *)&(v)->counter);
+	return ACCESS_AT_MOST_ONCE(v->counter);
 }
=20
 /**
diff --git a/arch/x86/include/asm/atomic64_64.h b/arch/x86/include/asm/=
atomic64_64.h
index 0e1cbfc..bdca6fa 100644
--- a/arch/x86/include/asm/atomic64_64.h
+++ b/arch/x86/include/asm/atomic64_64.h
@@ -18,7 +18,7 @@
  */
 static inline long atomic64_read(const atomic64_t *v)
 {
-	return (*(volatile long *)&(v)->counter);
+	return ACCESS_AT_MOST_ONCE(v->counter);
 }
=20
 /**
diff --git a/arch/x86/include/asm/bitops.h b/arch/x86/include/asm/bitop=
s.h
index 1775d6e..e30a190 100644
--- a/arch/x86/include/asm/bitops.h
+++ b/arch/x86/include/asm/bitops.h
@@ -308,8 +308,11 @@ static inline int test_and_change_bit(int nr, vola=
tile unsigned long *addr)
=20
 static __always_inline int constant_test_bit(unsigned int nr, const vo=
latile unsigned long *addr)
 {
-	return ((1UL << (nr % BITS_PER_LONG)) &
-		(addr[nr / BITS_PER_LONG])) !=3D 0;
+	const unsigned long *word =3D (const unsigned long *)addr +
+				    (nr / BITS_PER_LONG);
+	unsigned long bit =3D 1UL << (nr % BITS_PER_LONG);
+
+	return (bit & ACCESS_AT_MOST_ONCE(*word)) !=3D 0;
 }
=20
 static inline int variable_test_bit(int nr, volatile const unsigned lo=
ng *addr)
diff --git a/include/asm-generic/atomic.h b/include/asm-generic/atomic.=
h
index e37963c..c05e21f 100644
--- a/include/asm-generic/atomic.h
+++ b/include/asm-generic/atomic.h
@@ -39,7 +39,7 @@
  * Atomically reads the value of @v.
  */
 #ifndef atomic_read
-#define atomic_read(v)	(*(volatile int *)&(v)->counter)
+#define atomic_read(v)	ACCESS_AT_MOST_ONCE((v)->counter)
 #endif
=20
 /**
diff --git a/include/linux/compiler.h b/include/linux/compiler.h
index 320d6c9..bd18562 100644
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -308,4 +308,19 @@ void ftrace_likely_update(struct ftrace_branch_dat=
a *f, int val, int expect);
  */
 #define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))
=20
+#ifndef __ASSEMBLY__
+/*
+ * Like ACCESS_ONCE, but can be optimized away if nothing uses the val=
ue,
+ * and/or merged with previous non-ONCE accesses.
+ */
+extern void ACCESS_AT_MOST_ONCE_bad(void);
+#define ACCESS_AT_MOST_ONCE(x)				\
+	({	unsigned long __y;			\
+		if (sizeof(x) > sizeof(__y))		\
+			ACCESS_AT_MOST_ONCE_bad();	\
+		asm("":"=3Dr" (__y):"0" (x));		\
+		(__force __typeof__(x)) __y;		\
+	})
+#endif /* __ASSEMBLY__ */
+
 #endif /* __LINUX_COMPILER_H */
