From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] pkt_sched: do not use rcu in tc_dump_qdisc()
Date: Mon, 10 Mar 2014 17:11:42 -0700
Message-ID: <1394496703-9278-2-git-send-email-edumazet@google.com>
References: <1394496703-9278-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:38039 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224AbaCKAMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 20:12:12 -0400
Received: by mail-ob0-f201.google.com with SMTP id gq1so1656038obb.2
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 17:12:11 -0700 (PDT)
In-Reply-To: <1394496703-9278-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like all rtnetlink dump operations, we hold RTNL in tc_dump_qdisc(),
so we do not need to use rcu protection to protect list of netdevices.

This will allow preemption to occur, thus reducing latencies.
Following patch adds explicit cond_resched() calls.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_api.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 1313145e3b86..272292efa7f0 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1434,9 +1434,9 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 	s_idx = cb->args[0];
 	s_q_idx = q_idx = cb->args[1];
 
-	rcu_read_lock();
 	idx = 0;
-	for_each_netdev_rcu(net, dev) {
+	ASSERT_RTNL();
+	for_each_netdev(net, dev) {
 		struct netdev_queue *dev_queue;
 
 		if (idx < s_idx)
@@ -1459,8 +1459,6 @@ cont:
 	}
 
 done:
-	rcu_read_unlock();
-
 	cb->args[0] = idx;
 	cb->args[1] = q_idx;
 
-- 
1.9.0.279.gdc9e3eb
