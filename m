From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: >Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Wed, 02 Nov 2011 01:14:34 +0100
Message-ID: <1320192874.4728.19.camel@edumazet-laptop>
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
	 <1319987765.13597.60.camel@edumazet-laptop>
	 <CA+55aFyGEhBMv31QXN7q9PJc36TVtHLOvdFYB1+6NTo+nKSkbQ@mail.gmail.com>
	 <1319996494.13597.69.camel@edumazet-laptop>
	 <CA+55aFz-mp8k7qdF3LaOjgX19TbzrCirGuCmGwqVMq9SwQ8yvw@mail.gmail.com>
	 <1319997593.13597.76.camel@edumazet-laptop>
	 <CA+55aFws7bm1mr7fhAheD2t3wTchWx_gEbKhSggSROf2UT86Hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37016 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199Ab1KBAOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 20:14:40 -0400
In-Reply-To: <CA+55aFws7bm1mr7fhAheD2t3wTchWx_gEbKhSggSROf2UT86Hg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 30 octobre 2011 =C3=A0 11:09 -0700, Linus Torvalds a =C3=A9=
crit :

> Argh. Ok. Testing a refcount in a const struct doesn't make much
> sense, but there does seem to be perfectly valid uses of it
> (sk_wmem_alloc etc).
>=20
> Annoying. I guess we have to have those casts. Grr.
>=20

OK, please check following patch then.

Thanks !

[PATCH v3] atomic: introduce ACCESS_AT_MOST_ONCE() helper

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

0,05 :  ffffffff815e4775:    je     ffffffff815e4970 <tcp_sendmsg+0xc80=
>
0,05 :  ffffffff815e477b:    mov    0x1c(%r9),%eax    // useless
3,32 :  ffffffff815e477f:    mov    (%r9),%rax        // useless
0,51 :  ffffffff815e4782:    lock incl 0x1c(%r9)
3,87 :  ffffffff815e4787:    mov    (%r9),%rax
0,00 :  ffffffff815e478a:    test   $0x80,%ah
0,00 :  ffffffff815e478d:    jne    ffffffff815e49f2 <tcp_sendmsg+0xd02=
>

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
10704040        2894216 1540096 15138352         e6fe30 vmlinux.new

Basically an extension of a prior patch from Linus

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 arch/x86/include/asm/atomic.h      |    5 +----
 arch/x86/include/asm/atomic64_64.h |    6 ++----
 arch/x86/include/asm/bitops.h      |    6 ++++--
 include/asm-generic/atomic.h       |    2 +-
 include/linux/compiler.h           |   10 ++++++++++
 5 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomi=
c.h
index 58cb6d4..2581008 100644
--- a/arch/x86/include/asm/atomic.h
+++ b/arch/x86/include/asm/atomic.h
@@ -20,10 +20,7 @@
  *
  * Atomically reads the value of @v.
  */
-static inline int atomic_read(const atomic_t *v)
-{
-	return (*(volatile int *)&(v)->counter);
-}
+#define atomic_read(v) ACCESS_AT_MOST_ONCE(*(int *)&(v)->counter)
=20
 /**
  * atomic_set - set atomic variable
diff --git a/arch/x86/include/asm/atomic64_64.h b/arch/x86/include/asm/=
atomic64_64.h
index 0e1cbfc..15bbad4 100644
--- a/arch/x86/include/asm/atomic64_64.h
+++ b/arch/x86/include/asm/atomic64_64.h
@@ -1,6 +1,7 @@
 #ifndef _ASM_X86_ATOMIC64_64_H
 #define _ASM_X86_ATOMIC64_64_H
=20
+#include <linux/compiler.h>
 #include <linux/types.h>
 #include <asm/alternative.h>
 #include <asm/cmpxchg.h>
@@ -16,10 +17,7 @@
  * Atomically reads the value of @v.
  * Doesn't imply a read memory barrier.
  */
-static inline long atomic64_read(const atomic64_t *v)
-{
-	return (*(volatile long *)&(v)->counter);
-}
+#define atomic64_read(v) ACCESS_AT_MOST_ONCE(*(long *)&(v)->counter);
=20
 /**
  * atomic64_set - set atomic64 variable
diff --git a/arch/x86/include/asm/bitops.h b/arch/x86/include/asm/bitop=
s.h
index 1775d6e..6dcf4b1 100644
--- a/arch/x86/include/asm/bitops.h
+++ b/arch/x86/include/asm/bitops.h
@@ -308,8 +308,10 @@ static inline int test_and_change_bit(int nr, vola=
tile unsigned long *addr)
=20
 static __always_inline int constant_test_bit(unsigned int nr, const vo=
latile unsigned long *addr)
 {
-	return ((1UL << (nr % BITS_PER_LONG)) &
-		(addr[nr / BITS_PER_LONG])) !=3D 0;
+	unsigned long *word =3D (unsigned long *)addr + (nr / BITS_PER_LONG);
+	unsigned long bit =3D 1UL << (nr % BITS_PER_LONG);
+
+	return (bit & ACCESS_AT_MOST_ONCE(*word)) !=3D 0;
 }
=20
 static inline int variable_test_bit(int nr, volatile const unsigned lo=
ng *addr)
diff --git a/include/asm-generic/atomic.h b/include/asm-generic/atomic.=
h
index e37963c..76ab683 100644
--- a/include/asm-generic/atomic.h
+++ b/include/asm-generic/atomic.h
@@ -39,7 +39,7 @@
  * Atomically reads the value of @v.
  */
 #ifndef atomic_read
-#define atomic_read(v)	(*(volatile int *)&(v)->counter)
+#define atomic_read(v)	ACCESS_AT_MOST_ONCE(*(int *)&(v)->counter)
 #endif
=20
 /**
diff --git a/include/linux/compiler.h b/include/linux/compiler.h
index 320d6c9..307f342 100644
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -308,4 +308,14 @@ void ftrace_likely_update(struct ftrace_branch_dat=
a *f, int val, int expect);
  */
 #define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))
=20
+/*
+ * Like ACCESS_ONCE, but can be optimized away if nothing uses the val=
ue,
+ * and/or merged with previous non-ONCE accesses.
+ */
+#define ACCESS_AT_MOST_ONCE(x)			\
+	({	typeof(x) __y;			\
+		asm("":"=3Dr" (__y):"0" (x));	\
+		__y;				\
+	})
+
 #endif /* __LINUX_COMPILER_H */
