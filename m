From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH v2] random32: avoid attempt to late reseed if in the middle of seeding
Date: Thu, 27 Mar 2014 02:01:35 -0400
Message-ID: <1395900095-15254-2-git-send-email-sasha.levin@oracle.com>
References: <1395900095-15254-1-git-send-email-sasha.levin@oracle.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	hannes@stressinduktion.org, tytso@mit.edu, dborkman@redhat.com,
	Sasha Levin <sasha.levin@oracle.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395900095-15254-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 4af712e8df ("random32: add prandom_reseed_late() and call when
nonblocking pool becomes initialized") has added a late reseed stage
that happens as soon as the nonblocking pool is marked as initialized.

This fails in the case that the nonblocking pool gets initialized
during __prandom_reseed()'s call to get_random_bytes(). In that case
we'd double back into __prandom_reseed() in an attempt to do a late
reseed - deadlocking on 'lock' early on in the boot process.

Instead, just avoid even waiting to do a reseed if a reseed is already
occuring.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 lib/random32.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/lib/random32.c b/lib/random32.c
index b33b23e..d67b6a7 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -245,8 +245,20 @@ static void __prandom_reseed(bool late)
 	static bool latch = false;
 	static DEFINE_SPINLOCK(lock);
 
+	/*
+	 * Asking for random bytes might result in bytes getting
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
 
-- 
1.8.3.2
