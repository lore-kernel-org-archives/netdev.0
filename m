From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] [2/2] srandom32 fixes
Date: Tue,  4 Mar 2008 18:34:49 +0100 (CET)
Message-ID: <20080304173449.8BAD21B4199@basil.firstfloor.org>
References: <20080304634.504158800@firstfloor.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out01.alice-dsl.net ([88.44.60.11]:40641 "EHLO
	smtp-out01.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753827AbYCDRew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 12:34:52 -0500
In-Reply-To: <20080304634.504158800@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


- Rename it to a different name because it does something quite
different from a traditional user land srandom32 -- it doesn't
reset state but just adds to it.

- Let it update the state of all CPUs. The network stack goes
into pains to feed the current IP addresses in, but it is not very
effective if that is only done for some random CPU instead of all.
So change it to feed bits into all CPUs.  I decided to do that lockless 
because well somewhat random results are ok.

Signed-off-by: Andi Kleen <ak@suse.de>
Index: linux/include/linux/random.h
===================================================================
--- linux.orig/include/linux/random.h
+++ linux/include/linux/random.h
@@ -70,7 +70,7 @@ unsigned int get_random_int(void);
 unsigned long randomize_range(unsigned long start, unsigned long end, unsigned long len);
 
 u32 random32(void);
-void srandom32(u32 seed);
+void random32_add_bits(u32 seed);
 
 #endif /* __KERNEL___ */
 
Index: linux/lib/random32.c
===================================================================
--- linux.orig/lib/random32.c
+++ linux/lib/random32.c
@@ -93,19 +93,24 @@ u32 random32(void)
 EXPORT_SYMBOL(random32);
 
 /**
- *	srandom32 - add entropy to pseudo random number generator
+ *	random32_add_bits - add entropy to pseudo random number generator
  *	@seed: seed value
  *
  *	Add some additional seeding to the random32() pool.
- *	Note: this pool is per cpu so it only affects current CPU.
  */
-void srandom32(u32 entropy)
+void random32_add_bits(u32 entropy)
 {
-	struct rnd_state *state = &get_cpu_var(net_rand_state);
-	__set_random32(state, state->s1 ^ entropy);
-	put_cpu_var(state);
+	int i;
+	/*
+	 * No locking on the CPUs, but then somewhat random results are, well,
+	 * expected.
+	 */
+	for_each_possible_cpu (i) {
+		struct rnd_state *state = &per_cpu(net_rand_state, i);
+		__set_random32(state, state->s1 ^ entropy);
+	}
 }
-EXPORT_SYMBOL(srandom32);
+EXPORT_SYMBOL(random32_add_bits);
 
 /*
  *	Generate some initially weak seeding values to allow
Index: linux/include/linux/net.h
===================================================================
--- linux.orig/include/linux/net.h
+++ linux/include/linux/net.h
@@ -213,7 +213,7 @@ extern struct socket *sockfd_lookup(int 
 extern int	     net_ratelimit(void);
 
 #define net_random()		random32()
-#define net_srandom(seed)	srandom32((__force u32)seed)
+#define net_srandom(seed)	random32_add_bits((__force u32)seed)
 
 extern int   	     kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 				    struct kvec *vec, size_t num, size_t len);
