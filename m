From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH 2/2] random32: use msecs_to_jiffies for reseed timer
Date: Tue, 12 Nov 2013 23:45:42 +0100
Message-ID: <1384296342-3348-2-git-send-email-dborkman@redhat.com>
References: <1384296342-3348-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45581 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757432Ab3KLWpu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Nov 2013 17:45:50 -0500
In-Reply-To: <1384296342-3348-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use msecs_to_jiffies, for these calculations as different HZ
considerations are taken into account for conversion of the timer
shot, and also it makes the code more readable.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 lib/random32.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/random32.c b/lib/random32.c
index 4f9d5df..1e5b2df 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -214,18 +214,22 @@ static DEFINE_TIMER(seed_timer, __prandom_timer, 0, 0);
 static void __prandom_timer(unsigned long dontcare)
 {
 	u32 entropy;
+	unsigned long expires;
 
 	get_random_bytes(&entropy, sizeof(entropy));
 	prandom_seed(entropy);
+
 	/* reseed every ~60 seconds, in [40 .. 80) interval with slack */
-	seed_timer.expires = jiffies + (40 * HZ + (prandom_u32() % (40 * HZ)));
+	expires = 40 + (prandom_u32() % 40);
+	seed_timer.expires = jiffies + msecs_to_jiffies(expires * MSEC_PER_SEC);
+
 	add_timer(&seed_timer);
 }
 
 static void __init __prandom_start_seed_timer(void)
 {
 	set_timer_slack(&seed_timer, HZ);
-	seed_timer.expires = jiffies + 40 * HZ;
+	seed_timer.expires = jiffies + msecs_to_jiffies(40 * MSEC_PER_SEC);
 	add_timer(&seed_timer);
 }
 
-- 
1.8.3.1
