From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sch_gred: should not use GFP_KERNEL while holding a spinlock
Date: Mon, 12 Dec 2011 10:42:53 +0100
Message-ID: <1323682973.2948.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:50474 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165Ab1LLJm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 04:42:56 -0500
Received: by vbbfc26 with SMTP id fc26so3578182vbb.19
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 01:42:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gred_change_vq() is called under sch_tree_lock(sch).

This means a spinlock is held, and we are not allowed to sleep in this
context.

We might pre-allocate memory using GFP_KERNEL before taking spinlock,
but this is not suitable for stable material.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_gred.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index b9493a0..6cd8ddf 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -385,7 +385,7 @@ static inline int gred_change_vq(struct Qdisc *sch, int dp,
 	struct gred_sched_data *q;
 
 	if (table->tab[dp] == NULL) {
-		table->tab[dp] = kzalloc(sizeof(*q), GFP_KERNEL);
+		table->tab[dp] = kzalloc(sizeof(*q), GFP_ATOMIC);
 		if (table->tab[dp] == NULL)
 			return -ENOMEM;
 	}
