From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH] Phonet:fix build problem
Date: Sun, 22 Mar 2009 03:58:40 +0000
Message-ID: <1237694320.25297.3.camel@localhost.localdomain>
References: <20090320115838.GA26371@orion>
	 <20090321.165950.248659848.davem@davemloft.net>
	 <a4423d670903211719m76baeab0k51f054058d6f5134@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kyle@mcmartin.ca,
	linux-parisc@vger.kernel.org
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <a4423d670903211719m76baeab0k51f054058d6f5134@mail.gmail.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2009-03-22 at 03:19 +0300, Alexander Beregalov wrote:
> 2009/3/22 David Miller <davem@davemloft.net>:
> > From: Alexander Beregalov <a.beregalov@gmail.com>
> > Date: Fri, 20 Mar 2009 14:58:38 +0300
> >
> >> net/phonet/pep.c: In function 'pipe_rcv_status':
> >> net/phonet/pep.c:262: error: lvalue required as left operand of assignment
> >>
> >> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> >
> > What platform hits this problem?
> >
> > I think that platform's atomic_add() implementation should
> > be fixed instead.
> 
> It is parisc, CC added.

Looks like a macro argument screw up in atomic.h

This should fix it (uncompiled, of course).

James

---

diff --git a/arch/parisc/include/asm/atomic.h b/arch/parisc/include/asm/atomic.h
index edbfe25..ada3e53 100644
--- a/arch/parisc/include/asm/atomic.h
+++ b/arch/parisc/include/asm/atomic.h
@@ -25,7 +25,7 @@
  * Since "a" is usually an address, use one spinlock per cacheline.
  */
 #  define ATOMIC_HASH_SIZE 4
-#  define ATOMIC_HASH(a) (&(__atomic_hash[ (((unsigned long) a)/L1_CACHE_BYTES) & (ATOMIC_HASH_SIZE-1) ]))
+#  define ATOMIC_HASH(a) (&(__atomic_hash[ (((unsigned long) (a))/L1_CACHE_BYTES) & (ATOMIC_HASH_SIZE-1) ]))
 
 extern raw_spinlock_t __atomic_hash[ATOMIC_HASH_SIZE] __lock_aligned;
 
@@ -222,13 +222,13 @@ static __inline__ int atomic_add_unless(atomic_t *v, int a, int u)
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
 
-#define atomic_add(i,v)	((void)(__atomic_add_return( ((int)i),(v))))
-#define atomic_sub(i,v)	((void)(__atomic_add_return(-((int)i),(v))))
+#define atomic_add(i,v)	((void)(__atomic_add_return( ((int)(i)),(v))))
+#define atomic_sub(i,v)	((void)(__atomic_add_return(-((int)(i)),(v))))
 #define atomic_inc(v)	((void)(__atomic_add_return(   1,(v))))
 #define atomic_dec(v)	((void)(__atomic_add_return(  -1,(v))))
 
-#define atomic_add_return(i,v)	(__atomic_add_return( ((int)i),(v)))
-#define atomic_sub_return(i,v)	(__atomic_add_return(-((int)i),(v)))
+#define atomic_add_return(i,v)	(__atomic_add_return( ((int)(i)),(v)))
+#define atomic_sub_return(i,v)	(__atomic_add_return(-((int)(i)),(v)))
 #define atomic_inc_return(v)	(__atomic_add_return(   1,(v)))
 #define atomic_dec_return(v)	(__atomic_add_return(  -1,(v)))
 
@@ -289,13 +289,13 @@ atomic64_read(const atomic64_t *v)
 	return v->counter;
 }
 
-#define atomic64_add(i,v)	((void)(__atomic64_add_return( ((s64)i),(v))))
-#define atomic64_sub(i,v)	((void)(__atomic64_add_return(-((s64)i),(v))))
+#define atomic64_add(i,v)	((void)(__atomic64_add_return( ((s64)(i)),(v))))
+#define atomic64_sub(i,v)	((void)(__atomic64_add_return(-((s64)(i)),(v))))
 #define atomic64_inc(v)		((void)(__atomic64_add_return(   1,(v))))
 #define atomic64_dec(v)		((void)(__atomic64_add_return(  -1,(v))))
 
-#define atomic64_add_return(i,v)	(__atomic64_add_return( ((s64)i),(v)))
-#define atomic64_sub_return(i,v)	(__atomic64_add_return(-((s64)i),(v)))
+#define atomic64_add_return(i,v)	(__atomic64_add_return( ((s64)(i)),(v)))
+#define atomic64_sub_return(i,v)	(__atomic64_add_return(-((s64)(i)),(v)))
 #define atomic64_inc_return(v)		(__atomic64_add_return(   1,(v)))
 #define atomic64_dec_return(v)		(__atomic64_add_return(  -1,(v)))
 


