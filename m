From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH net 1/1] net sched filters: pass netlink message flags in event notification
Date: Wed, 16 Nov 2016 17:16:10 -0500
Message-ID: <1479334570-25159-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34049 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932688AbcKPWQp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 17:16:45 -0500
Received: by mail-it0-f66.google.com with SMTP id o1so10311400ito.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 14:16:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userland client should be able to read an event, and reflect it back to
the kernel, therefore it needs to extract complete set of netlink flags.

For example, this will allow "tc monitor" to distinguish Add and Replace
operations.

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/cls_api.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 2b2a797..8e93d4a 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -112,7 +112,7 @@ static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
 
 	for (it_chain = chain; (tp = rtnl_dereference(*it_chain)) != NULL;
 	     it_chain = &tp->next)
-		tfilter_notify(net, oskb, n, tp, 0, event, false);
+		tfilter_notify(net, oskb, n, tp, n->nlmsg_flags, event, false);
 }
 
 /* Select new prio value from the range, managed by kernel. */
@@ -430,7 +430,8 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 	if (!skb)
 		return -ENOBUFS;
 
-	if (tcf_fill_node(net, skb, tp, fh, portid, n->nlmsg_seq, 0, event) <= 0) {
+	if (tcf_fill_node(net, skb, tp, fh, portid, n->nlmsg_seq,
+			  n->nlmsg_flags, event) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
-- 
1.9.1
