From: Andi Kleen <andi@firstfloor.org>
Subject: [PING^3] [PATCH] srandom32 fixes for networking v2
Date: Thu, 3 Apr 2008 22:36:11 +0200
Message-ID: <20080403203611.GA25305@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out01.alice-dsl.net ([88.44.60.11]:3724 "EHLO
	smtp-out01.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbYDCUgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 16:36:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

srandom32 fixes for networking v2

- Let it update the state of all CPUs. The network stack goes
into pains to feed the current IP addresses in, but it is not very
effective if that is only done for some random CPU instead of all.
So change it to feed bits into all CPUs.  I decided to do that lockless 
because well somewhat random results are ok.

v2: Drop rename so that this patch doesn't depend on x86 maintainers

Signed-off-by: Andi Kleen <ak@suse.de>
---
 include/linux/net.h    |    2 +-
 include/linux/random.h |    2 +-
 lib/random32.c         |   19 ++++++++++++-------
 3 files changed, 14 insertions(+), 9 deletions(-)

Index: linux/lib/random32.c
===================================================================
--- linux.orig/lib/random32.c
+++ linux/lib/random32.c
@@ -97,13 +97,18 @@ EXPORT_SYMBOL(random32);
  *	@seed: seed value
  *
  *	Add some additional seeding to the random32() pool.
- *	Note: this pool is per cpu so it only affects current CPU.
  */
 void srandom32(u32 entropy)
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
 EXPORT_SYMBOL(srandom32);
 
