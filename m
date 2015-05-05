From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: fix a use-after-free in tc_ctl_tfilter()
Date: Tue,  5 May 2015 15:22:02 -0700
Message-ID: <1430864522-15691-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34347 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139AbbEEWWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 18:22:16 -0400
Received: by pacyx8 with SMTP id yx8so207043158pac.1
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 15:22:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tcf_destroy() returns true, tp could be already destroyed,
we should not use tp->next after that.

For long term, we probably should move tp list to list_head.

Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_api.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 8b0470e..b6ef9a0 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -308,12 +308,11 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 		case RTM_DELTFILTER:
 			err = tp->ops->delete(tp, fh);
 			if (err == 0) {
-				tfilter_notify(net, skb, n, tp, fh, RTM_DELTFILTER);
-				if (tcf_destroy(tp, false)) {
-					struct tcf_proto *next = rtnl_dereference(tp->next);
+				struct tcf_proto *next = rtnl_dereference(tp->next);
 
+				tfilter_notify(net, skb, n, tp, fh, RTM_DELTFILTER);
+				if (tcf_destroy(tp, false))
 					RCU_INIT_POINTER(*back, next);
-				}
 			}
 			goto errout;
 		case RTM_GETTFILTER:
-- 
1.8.3.1
