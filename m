From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH] arch/tile: fix rwlock so would-be write lockers don't block new readers
Date: Mon, 15 Nov 2010 09:18:49 -0500
Message-ID: <201011151425.oAFEPU3W005682@farm-0010.internal.tilera.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	<1289489007.17691.1310.camel@edumazet-laptop>
	<AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	<ZXmP8hjgLHA.4648@exchange1.tad.internal.tilera.com>
	<4CDF1945.8090101@tilera.com>
	<AANLkTind92uwcigzmDn8yn9a22exDy7zcreGQ5-6NLV-@mail.gmail.com>
Cc: =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, Cypher Wu <cypher.w@gmail.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from king.tilera.com ([72.1.168.226]:30224 "EHLO king.tilera.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757075Ab0KOOZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 09:25:31 -0500
In-Reply-To: <AANLkTind92uwcigzmDn8yn9a22exDy7zcreGQ5-6NLV-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This avoids a deadlock in the IGMP code where one core gets a read
lock, another core starts trying to get a write lock (thus blocking
new readers), and then the first core tries to recursively re-acquire
the read lock.

We still try to preserve some degree of balance by giving priority
to additional write lockers that come along while the lock is held
for write, so they can all complete quickly and return the lock to
the readers.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
This should apply relatively cleanly to 2.6.26.7 source code too.

 arch/tile/lib/spinlock_32.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/arch/tile/lib/spinlock_32.c b/arch/tile/lib/spinlock_32.c
index 485e24d..5cd1c40 100644
--- a/arch/tile/lib/spinlock_32.c
+++ b/arch/tile/lib/spinlock_32.c
@@ -167,23 +167,30 @@ void arch_write_lock_slow(arch_rwlock_t *rwlock, u32 val)
 	 * when we compare them.
 	 */
 	u32 my_ticket_;
+	u32 iterations = 0;
 
-	/* Take out the next ticket; this will also stop would-be readers. */
-	if (val & 1)
-		val = get_rwlock(rwlock);
-	rwlock->lock = __insn_addb(val, 1 << WR_NEXT_SHIFT);
+	/*
+	 * Wait until there are no readers, then bump up the next
+	 * field and capture the ticket value.
+	 */
+	for (;;) {
+		if (!(val & 1)) {
+			if ((val >> RD_COUNT_SHIFT) == 0)
+				break;
+			rwlock->lock = val;
+		}
+		delay_backoff(iterations++);
+		val = __insn_tns((int *)&rwlock->lock);
+	}
 
-	/* Extract my ticket value from the original word. */
+	/* Take out the next ticket and extract my ticket value. */
+	rwlock->lock = __insn_addb(val, 1 << WR_NEXT_SHIFT);
 	my_ticket_ = val >> WR_NEXT_SHIFT;
 
-	/*
-	 * Wait until the "current" field matches our ticket, and
-	 * there are no remaining readers.
-	 */
+	/* Wait until the "current" field matches our ticket. */
 	for (;;) {
 		u32 curr_ = val >> WR_CURR_SHIFT;
-		u32 readers = val >> RD_COUNT_SHIFT;
-		u32 delta = ((my_ticket_ - curr_) & WR_MASK) + !!readers;
+		u32 delta = ((my_ticket_ - curr_) & WR_MASK);
 		if (likely(delta == 0))
 			break;
 
-- 
1.6.5.2

