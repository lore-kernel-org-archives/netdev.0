From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 5/6] neigh: neigh dead and timer variables should be protected under its lock
Date: Fri, 15 May 2015 14:55:45 +0800
Message-ID: <1431672946-300-6-git-send-email-ying.xue@windriver.com>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <alexei@purestorage.com>,
	<joern@purestorage.com>, <ja@ssi.bg>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35267 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179AbbEOG5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 02:57:25 -0400
In-Reply-To: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As neigh lock is not taken before its variables like dead and timer
are used in neigh_destroy(), this is unsafe for us. The commit allows
neigh lock to cover all area of using them.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/core/neighbour.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8a438fc..67a0e42 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -687,9 +687,11 @@ void neigh_destroy(struct neighbour *neigh)
 
 	NEIGH_CACHE_STAT_INC(neigh->tbl, destroys);
 
+	write_lock_bh(&neigh->lock);
 	if (!neigh->dead) {
 		pr_warn("Destroying alive neighbour %p\n", neigh);
 		dump_stack();
+		write_unlock_bh(&neigh->lock);
 		return;
 	}
 
@@ -698,7 +700,6 @@ void neigh_destroy(struct neighbour *neigh)
 		dump_stack();
 	}
 
-	write_lock_bh(&neigh->lock);
 	__skb_queue_purge(&neigh->arp_queue);
 	write_unlock_bh(&neigh->lock);
 	neigh->arp_queue_len_bytes = 0;
-- 
1.7.9.5
