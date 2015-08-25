From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] cls_u32: complete the check for non-forced case in u32_destroy()
Date: Tue, 25 Aug 2015 16:38:12 -0700
Message-ID: <1440545892-20587-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: akshat.1984@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35756 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974AbbHYXi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:38:27 -0400
Received: by pacdd16 with SMTP id dd16so139051850pac.2
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 16:38:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
I added a check in u32_destroy() to see if all real filters are gone
for each tp, however, that is only done for root_ht, same is needed
for others.

This can be reproduced by the following tc commands:

tc filter add dev eth0 parent 1:0 prio 5 handle 15: protocol ip u32 divisor 256
tc filter add dev eth0 protocol ip parent 1: prio 5 handle 15:2:2 u32
ht 15:2: match ip src 10.0.0.2 flowid 1:10
tc filter add dev eth0 protocol ip parent 1: prio 5 handle 15:2:3 u32
ht 15:2: match ip src 10.0.0.3 flowid 1:10

Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
Reported-by: Akshat Kakkar <akshat.1984@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 net/sched/cls_u32.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index cab9e9b..4fbb674 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -490,6 +490,19 @@ static bool u32_destroy(struct tcf_proto *tp, bool force)
 					return false;
 			}
 		}
+
+		if (tp_c->refcnt > 1)
+			return false;
+
+		if (tp_c->refcnt == 1) {
+			struct tc_u_hnode *ht;
+
+			for (ht = rtnl_dereference(tp_c->hlist);
+			     ht;
+			     ht = rtnl_dereference(ht->next))
+				if (!ht_empty(ht))
+					return false;
+		}
 	}
 
 	if (root_ht && --root_ht->refcnt == 0)
-- 
1.8.3.1
