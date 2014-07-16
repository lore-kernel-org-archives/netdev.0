From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: cancel nest attribute on failure in tcf_exts_dump()
Date: Wed, 16 Jul 2014 14:25:30 -0700
Message-ID: <1405545931-13832-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:62310 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312AbaGPVZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 17:25:42 -0400
Received: by mail-pd0-f182.google.com with SMTP id fp1so1866492pdb.41
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 14:25:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

Like other places, we need to cancel the nest attribute after
we start. Fortunately the netlink message will not be sent on
failure, so it's not a big problem at all.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 net/sched/cls_api.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 45527e6..c28b0d3 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -561,13 +561,14 @@ EXPORT_SYMBOL(tcf_exts_change);
 int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
+	struct nlattr *nest;
+
 	if (exts->action && !list_empty(&exts->actions)) {
 		/*
 		 * again for backward compatible mode - we want
 		 * to work with both old and new modes of entering
 		 * tc data even if iproute2  was newer - jhs
 		 */
-		struct nlattr *nest;
 		if (exts->type != TCA_OLD_COMPAT) {
 			nest = nla_nest_start(skb, exts->action);
 			if (nest == NULL)
@@ -585,10 +586,14 @@ int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts)
 			nla_nest_end(skb, nest);
 		}
 	}
-#endif
 	return 0;
-nla_put_failure: __attribute__ ((unused))
+
+nla_put_failure:
+	nla_nest_cancel(skb, nest);
 	return -1;
+#else
+	return 0;
+#endif
 }
 EXPORT_SYMBOL(tcf_exts_dump);
 
-- 
1.8.3.1
