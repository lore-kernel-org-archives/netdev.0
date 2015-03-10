From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: fix struct tc_u_hnode layout in u32
Date: Mon,  9 Mar 2015 17:03:40 -0700
Message-ID: <1425945820-9582-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:39012 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbbCJADr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 20:03:47 -0400
Received: by pdbft15 with SMTP id ft15so38135651pdb.6
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 17:03:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We dynamically allocate divisor+1 entries for ->ht[] in tc_u_hnode:

  ht = kzalloc(sizeof(*ht) + divisor*sizeof(void *), GFP_KERNEL);

So ->ht is supposed to be the last field of this struct, however
this is broken, since an rcu head is appended after it.

Fixes: 1ce87720d456 ("net: sched: make cls_u32 lockless")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_u32.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 09487af..95fdf4e 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -78,8 +78,11 @@ struct tc_u_hnode {
 	struct tc_u_common	*tp_c;
 	int			refcnt;
 	unsigned int		divisor;
-	struct tc_u_knode __rcu	*ht[1];
 	struct rcu_head		rcu;
+	/* The 'ht' field MUST be the last field in structure to allow for
+	 * more entries allocated at end of structure.
+	 */
+	struct tc_u_knode __rcu	*ht[1];
 };
 
 struct tc_u_common {
-- 
1.8.3.1
