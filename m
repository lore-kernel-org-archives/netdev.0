From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net v3] random32: avoid attempt to late reseed if in the middle of seeding
Date: Fri, 28 Mar 2014 17:38:42 +0100
Message-ID: <1396024722-11632-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26145 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751443AbaC1Qis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 12:38:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Levin <sasha.levin@oracle.com>

Commit 4af712e8df ("random32: add prandom_reseed_late() and call when
nonblocking pool becomes initialized") has added a late reseed stage
that happens as soon as the nonblocking pool is marked as initialized.

This fails in the case that the nonblocking pool gets initialized
during __prandom_reseed()'s call to get_random_bytes(). In that case
we'd double back into __prandom_reseed() in an attempt to do a late
reseed - deadlocking on 'lock' early on in the boot process.

Instead, just avoid even waiting to do a reseed if a reseed is already
occuring.

Fixes: 4af712e8df99 ("random32: add prandom_reseed_late() and call when nonblocking pool becomes initialized")
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Recommended for -stable as well. I'm resending the patch as v2
 from [1] does not apply to the tree, perhaps some mail client
 issue ...

 [1] http://patchwork.ozlabs.org/patch/334223/

 lib/random32.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/lib/random32.c b/lib/random32.c
index 1e5b2df..6148967 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -244,8 +244,19 @@ static void __prandom_reseed(bool late)
 	static bool latch = false;
 	static DEFINE_SPINLOCK(lock);
 
+	/* Asking for random bytes might result in bytes getting
+	 * moved into the nonblocking pool and thus marking it
+	 * as initialized. In this case we would double back into
+	 * this function and attempt to do a late reseed.
+	 * Ignore the pointless attempt to reseed again if we're
+	 * already waiting for bytes when the nonblocking pool
+	 * got initialized.
+	 */
+
 	/* only allow initial seeding (late == false) once */
-	spin_lock_irqsave(&lock, flags);
+	if (!spin_trylock_irqsave(&lock, flags))
+		return;
+
 	if (latch && !late)
 		goto out;
 	latch = true;
-- 
1.7.11.7
