From: akpm@linux-foundation.org
Subject: [patch 1/2] net: don't use in_atomic() in gfp_any()
Date: Wed, 11 Feb 2009 13:27:19 -0800
Message-ID: <200902112127.n1BLRJeJ031575@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andi@firstfloor.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51475 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758667AbZBKV2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 16:28:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

The problem is that in_atomic() will return false inside spinlocks if
CONFIG_PREEMPT=n.  This will lead to deadlockable GFP_KERNEL allocations
from spinlocked regions.

Secondly, if CONFIG_PREEMPT=y, this bug solves itself because networking
will instead use GFP_ATOMIC from this callsite.  Hence we won't get the
might_sleep() debugging warnings which would have informed us of the buggy
callsites.

Solve both these problems by switching to in_interrupt().  Now, if someone
runs a gfp_any() allocation from inside spinlock we will get the warning
if CONFIG_PREEMPT=y.

I reviewed all callsites and most of them were too complex for my little
brain and none of them documented their interface requirements.  I have no
idea what this patch will do.

Cc: Andi Kleen <andi@firstfloor.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/net/sock.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN include/net/sock.h~net-dont-use-in_atomic-in-gfp_any include/net/sock.h
--- a/include/net/sock.h~net-dont-use-in_atomic-in-gfp_any
+++ a/include/net/sock.h
@@ -1313,7 +1313,7 @@ static inline int sock_writeable(const s
 
 static inline gfp_t gfp_any(void)
 {
-	return in_atomic() ? GFP_ATOMIC : GFP_KERNEL;
+	return in_softirq() ? GFP_ATOMIC : GFP_KERNEL;
 }
 
 static inline long sock_rcvtimeo(const struct sock *sk, int noblock)
_
