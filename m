From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: >Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Sun, 30 Oct 2011 09:52:34 +0100
Message-ID: <1319964754.13597.26.camel@edumazet-laptop>
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
	 <1319813252.23112.122.camel@edumazet-laptop>
	 <CA+55aFxvcvUopBc-Q6Fp87asTuBohev8Xdm67jcKfy4Z4_BZRg@mail.gmail.com>
	 <CA+55aFz=sxRjw6u-ww0P=9hhvWaZP=+QJZ68W+B9WtvQqj9Ogg@mail.gmail.com>
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
In-Reply-To: <CA+55aFz=sxRjw6u-ww0P=9hhvWaZP=+QJZ68W+B9WtvQqj9Ogg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 29 octobre 2011 =C3=A0 10:34 -0700, Linus Torvalds a =C3=A9cr=
it :
> On Fri, Oct 28, 2011 at 7:55 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Comments? I think I'm open to tested patches..
>=20
> Here's a *untested* patch.
>=20
> In particular, I worry that I'd need to add a "#include
> <linux/compiler.h>" to some header file, although I suspect it gets
> included some way regardless.
>=20
> And when I say "untested", I mean it. I verified that this makes
> *some* difference to the generated code, but I didn't actually check
> if it really matters, or if it actually compiles and works in general=
=2E
>=20
> Caveat tester,
>=20

Since jetlag strikes me again, I took your patch and had to change it a
bit, since :

1) x86 uses its own atomic_read() definition in
arch/x86/include/asm/atomic.h

2) We can use a const pointer in ACCESS_AT_MOST_ONCE(*ptr), so I had to
change a bit your implementation, I hope I did not mess it.

Tested (built/booted) on x86 and x86_64

We could logically split this patch in three parts, but hey, maybe I ca=
n
try to sleep after all ;)

Thanks

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
0,05 :  ffffffff815e477b:       mov    0x1c(%r9),%eax    // useless    =
             =20
3,32 :  ffffffff815e477f:       mov    (%r9),%rax        // useless    =
             =20
0,51 :  ffffffff815e4782:       lock incl 0x1c(%r9)                    =
   =20
3,87 :  ffffffff815e4787:       mov    (%r9),%rax                      =
   =20
0,00 :  ffffffff815e478a:       test   $0x80,%ah                       =
   =20
0,00 :  ffffffff815e478d:       jne    ffffffff815e49f2 <tcp_sendmsg+0x=
d02>     =20

Thats because both atomic_read() and constant_test_bit() use a volatile
attribute and thus compiler is forced to perform a read, even if the
result is optimized away.

Linus suggested using an asm("") trick and place it in a variant of
ACCESS_ONCE(), allowing compiler to omit reading memory if result is
unused.

This patch introduces ACCESS_AT_MOST_ONCE() helper and use it in the x8=
6
implementation of atomic_read() and constant_test_bit()

on x86_64, we thus reduce vmlinux text a bit (if CONFIG_DEBUG_VM=3Dn)

# size vmlinux.old vmlinux.new
   text	   data	    bss	    dec	    hex	filename
10706848	2894216	1540096	15141160	 e70928	vmlinux.old
10704680	2894216	1540096	15138992	 e700b0	vmlinux.new

Based on a prior patch from Linus

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 arch/x86/include/asm/atomic.h |    2 +-
 arch/x86/include/asm/bitops.h |    7 +++++--
 include/asm-generic/atomic.h  |    2 +-
 include/linux/compiler.h      |   10 ++++++++++
 4 files changed, 17 insertions(+), 4 deletions(-)

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
index 320d6c9..21f102d 100644
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
+	({	unsigned long __y;		\
+		asm("":"=3Dr" (__y):"0" (x));	\
+		(__force __typeof__(x)) __y;	\
+	})
+
 #endif /* __LINUX_COMPILER_H */
