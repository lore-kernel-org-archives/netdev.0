From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 1/2] net: cls_u32: catch all hardware offload errors
Date: Wed,  8 Jun 2016 20:11:03 +0100
Message-ID: <1465413064-32196-2-git-send-email-jakub.kicinski@netronome.com>
References: <1465413064-32196-1-git-send-email-jakub.kicinski@netronome.com>
Cc: john.r.fastabend@intel.com, sridhar.samudrala@intel.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38520 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932725AbcFHTLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 15:11:55 -0400
Received: by mail-wm0-f48.google.com with SMTP id m124so30247475wme.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 12:11:54 -0700 (PDT)
In-Reply-To: <1465413064-32196-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Errors reported by u32_replace_hw_hnode() were not propagated.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 net/sched/cls_u32.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 27b99fd774d7..54ab32a8ff4c 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -922,11 +922,17 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		ht->divisor = divisor;
 		ht->handle = handle;
 		ht->prio = tp->prio;
+
+		err = u32_replace_hw_hnode(tp, ht, flags);
+		if (err) {
+			kfree(ht);
+			return err;
+		}
+
 		RCU_INIT_POINTER(ht->next, tp_c->hlist);
 		rcu_assign_pointer(tp_c->hlist, ht);
 		*arg = (unsigned long)ht;
 
-		u32_replace_hw_hnode(tp, ht, flags);
 		return 0;
 	}
 
-- 
1.9.1
