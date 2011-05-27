From: Arun Sharma <asharma@fb.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Fri, 27 May 2011 14:14:19 -0700
Message-ID: <20110527211419.GA6793@dev1756.snc6.facebook.com>
References: <20110525060609.GA32244@dev1756.snc6.facebook.com>
 <1306305331.3305.22.camel@edumazet-laptop>
 <4DDEAA3C.7020502@fb.com>
 <1306439246.2543.10.camel@edumazet-laptop>
 <4DDECA9B.8080206@fb.com>
 <1306447292.2543.32.camel@edumazet-laptop>
 <4DDEEBC5.80804@fb.com>
 <1306466831.2543.58.camel@edumazet-laptop>
 <4DDFE4D6.4010000@fb.com>
 <1306526219.2533.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arun Sharma <asharma@fb.com>, David Miller <davem@davemloft.net>,
	Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>,
	Yann Dupont <Yann.Dupont@univ-nantes.fr>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1306526219.2533.3.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 27, 2011 at 09:56:59PM +0200, Eric Dumazet wrote:
> > 
> > This looks very similar to atomic_add_unless(). If we had a
> > 
> > __atomic_add_unless() that returned "old", we could then do:
> > 
> > atomic_add_unless() { return __atomic_add_unless() != u }
> > atomic_add_unless_return() { return __atomic_add_unless() + a}
> > 
> 
> Sure !
> 
> I preferred to not touch lot of files in kernel (atomic_add_unless() is
> defined in several files) because its a stable candidate patch (2.6.36+)
> 
> So a cleanup patch for 2.6.40+ is certainly doable, do you want to do
> this ?

The attached works for me for x86_64. Cc'ing Ingo/Thomas for comment.

 -Arun

atomic: Refactor atomic_add_unless

Commit 686a7e3 (inetpeer: fix race in unused_list manipulations)
in net-2.6 added a atomic_add_unless_return() variant that tries
to detect 0->1 transitions of an atomic reference count.

This sounds like a generic functionality that could be expressed
in terms of an __atomic_add_unless() that returned the old value
instead of a bool.

Signed-off-by: Arun Sharma <asharma@fb.com>
---
 arch/x86/include/asm/atomic.h |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
index 952a826..bbdbffe 100644
--- a/arch/x86/include/asm/atomic.h
+++ b/arch/x86/include/asm/atomic.h
@@ -221,15 +221,15 @@ static inline int atomic_xchg(atomic_t *v, int new)
 }
 
 /**
- * atomic_add_unless - add unless the number is already a given value
+ * __atomic_add_unless - add unless the number is already a given value
  * @v: pointer of type atomic_t
  * @a: the amount to add to v...
  * @u: ...unless v is equal to u.
  *
  * Atomically adds @a to @v, so long as @v was not already @u.
- * Returns non-zero if @v was not @u, and zero otherwise.
+ * Returns the old value of v
  */
-static inline int atomic_add_unless(atomic_t *v, int a, int u)
+static inline int __atomic_add_unless(atomic_t *v, int a, int u)
 {
 	int c, old;
 	c = atomic_read(v);
@@ -241,7 +241,21 @@ static inline int atomic_add_unless(atomic_t *v, int a, int u)
 			break;
 		c = old;
 	}
-	return c != (u);
+	return c;
+}
+
+/**
+ * atomic_add_unless - add unless the number is already a given value
+ * @v: pointer of type atomic_t
+ * @a: the amount to add to v...
+ * @u: ...unless v is equal to u.
+ *
+ * Atomically adds @a to @v, so long as @v was not already @u.
+ * Returns non-zero if @v was not @u, and zero otherwise.
+ */
+static inline int atomic_add_unless(atomic_t *v, int a, int u)
+{
+	return __atomic_add_unless(v, a, u) != u;
 }
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
-- 
1.7.4
