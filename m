From: John Bowler <jbowler@acm.org>
Subject: [PATCH] 2.6.14-rc5-mm1 net/ipv4/route.c: spin_unlock call fails to compile
Date: Fri, 28 Oct 2005 00:08:26 -0700
Message-ID: <001401c5db8e$650bd380$1001a8c0@kalmiopsis>
Reply-To: <jbowler@acm.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <mingo@elte.hu>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965182AbVJ1IAN@vger.kernel.org>
To: <netdev@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The spin_unlock call which gets an rt_hash_lock_addr(i)
argument fails to compile on rc5-mm1 uniprocessor with
no CONFIG_DEBUG_SPINLOCK because, in mm1, the spin_unlock
macro expands to a statement of the form:

do { (void)&ptr->raw; } while (0)

and 'ptr' is 'NULL'.  Since the expression is address-of
(therefore not evaluated as an r-value - i.e. no attempt
is made to load the non-existent raw, just take its address)
this expression is harmless.

The patch makes 'ptr' ((spinlock_t*)NULL), which the compiler
can compile (sizeof *ptr is 0 in the case - the spinlock_t
struct is empty - so the patch is particularly safe.)

The patch applies to both 2.6.14 and 2.6.14-rc5-mm1 (although
only the latter requires it.)

Signed-off-by: John Bowler <jbowler@acm.org>

--- linux-2.6.14-rc5/net/ipv4/route.c	2005-10-26 08:37:20.752285410 -0700
+++ patched/net/ipv4/route.c	2005-10-26 12:17:00.761651111 -0700
@@ -231,7 +231,7 @@ static spinlock_t	*rt_hash_locks;
 			spin_lock_init(&rt_hash_locks[i]); \
 		}
 #else
-# define rt_hash_lock_addr(slot) NULL
+# define rt_hash_lock_addr(slot) ((spinlock_t*)NULL)
 # define rt_hash_lock_init()
 #endif
 
