From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 2/6] neigh: fix a possible leak issue of neigh entry
Date: Fri, 15 May 2015 14:55:42 +0800
Message-ID: <1431672946-300-3-git-send-email-ying.xue@windriver.com>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <alexei@purestorage.com>,
	<joern@purestorage.com>, <ja@ssi.bg>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:48101 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184AbbEOG4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 02:56:06 -0400
In-Reply-To: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once modifying a pending timer of a neighbour, it's insufficient to
post a warning message. Instead we should not take the neighbour's
reference count at the same time, otherwise, it causes an issue that
the neighbour cannot be freed forever.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/core/neighbour.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 3de6542..5595db3 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -164,10 +164,11 @@ static int neigh_forced_gc(struct neigh_table *tbl)
 
 static void neigh_add_timer(struct neighbour *n, unsigned long when)
 {
-	neigh_hold(n);
-	if (unlikely(mod_timer(&n->timer, when))) {
-		printk("NEIGH: BUG, double timer add, state is %x\n",
-		       n->nud_state);
+	if (likely(!mod_timer(&n->timer, when))) {
+		neigh_hold(n);
+	} else {
+		pr_warn("NEIGH: BUG, double timer add, state is %x\n",
+			n->nud_state);
 		dump_stack();
 	}
 }
-- 
1.7.9.5
