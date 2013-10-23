From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 3/3] inet: remove old fragmentation hash initializing
Date: Wed, 23 Oct 2013 11:06:57 +0200
Message-ID: <1382519217-750-4-git-send-email-hannes@stressinduktion.org>
References: <1382519217-750-1-git-send-email-hannes@stressinduktion.org>
Cc: netfilter-devel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52248 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891Ab3JWJHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 05:07:15 -0400
In-Reply-To: <1382519217-750-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All fragmentation hash secrets now get initialized by their
corresponding hash function with net_get_random_once. Thus we can
eliminate the initial seeding.

Also provide a comment that hash secret seeding happens at the first
call to the corresponding hashing function.

Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/inet_frag.h  | 4 ++++
 net/ipv4/inet_fragment.c | 3 ---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index bfcbc00..6f59de9 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -64,6 +64,10 @@ struct inet_frags {
 	rwlock_t		lock ____cacheline_aligned_in_smp;
 	int			secret_interval;
 	struct timer_list	secret_timer;
+
+	/* The first call to hashfn is responsible to initialize
+	 * rnd. This is best done with net_get_random_once.
+	 */
 	u32			rnd;
 	int			qsize;
 
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index c5313a9..bb075fc 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -93,9 +93,6 @@ void inet_frags_init(struct inet_frags *f)
 	}
 	rwlock_init(&f->lock);
 
-	f->rnd = (u32) ((totalram_pages ^ (totalram_pages >> 7)) ^
-				   (jiffies ^ (jiffies >> 6)));
-
 	setup_timer(&f->secret_timer, inet_frag_secret_rebuild,
 			(unsigned long)f);
 	f->secret_timer.expires = jiffies + f->secret_interval;
-- 
1.8.3.1
