From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 3/6] neigh: don't delete neighbour time in neigh_destroy
Date: Fri, 15 May 2015 14:55:43 +0800
Message-ID: <1431672946-300-4-git-send-email-ying.xue@windriver.com>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <alexei@purestorage.com>,
	<joern@purestorage.com>, <ja@ssi.bg>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35251 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337AbbEOG4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 02:56:08 -0400
In-Reply-To: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The timer of neighbour should be stopped before neigh_destroy(),
otherwise, this is definitely a bug. Even if we do the deletion of
the timer in neigh_destroy(), it's meaningless as its neighbour
would be freed shortly. So it's better to add a warning message
when detectting timer is pending in neigh_destroy().

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/core/neighbour.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 5595db3..433b617 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -689,8 +689,10 @@ void neigh_destroy(struct neighbour *neigh)
 		return;
 	}
 
-	if (neigh_del_timer(neigh))
-		pr_warn("Impossible event\n");
+	if (timer_pending(&neigh->timer)) {
+		pr_warn("Timer is pending, impossible event %p\n", neigh);
+		dump_stack();
+	}
 
 	write_lock_bh(&neigh->lock);
 	__skb_queue_purge(&neigh->arp_queue);
-- 
1.7.9.5
