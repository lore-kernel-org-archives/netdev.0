From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv3 net 3/3] net: cls_u32: catch all hardware offload errors
Date: Tue,  7 Jun 2016 23:17:03 +0100
Message-ID: <1465337823-16096-4-git-send-email-jakub.kicinski@netronome.com>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
 <1465337823-16096-1-git-send-email-jakub.kicinski@netronome.com>
Cc: john.r.fastabend@intel.com, sridhar.samudrala@intel.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38356 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756682AbcFGWRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:17:16 -0400
Received: by mail-wm0-f42.google.com with SMTP id m124so132762414wme.1
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 15:17:15 -0700 (PDT)
In-Reply-To: <1465337823-16096-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Errors reported by u32_replace_hw_hnode() were not propagated.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
---
v3:
 - new patch

 net/sched/cls_u32.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 0fc1d47885f8..b9c3875fddc6 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -923,11 +923,17 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
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
