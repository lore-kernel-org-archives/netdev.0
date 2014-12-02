From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/6] net_sched: cls_flow: remove faulty use of list_for_each_entry_rcu
Date: Tue,  2 Dec 2014 18:00:34 +0100
Message-ID: <1417539636-12710-5-git-send-email-jiri@resnulli.us>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:58583 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932706AbaLBRAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 12:00:44 -0500
Received: by mail-wg0-f42.google.com with SMTP id z12so17719381wgg.29
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 09:00:43 -0800 (PST)
In-Reply-To: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rcu variant is not correct here. The code is called by updater (rtnl
lock is held), not by reader (no rcu_read_lock is held).

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/cls_flow.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 4ac515f..a605739 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -578,7 +578,7 @@ static unsigned long flow_get(struct tcf_proto *tp, u32 handle)
 	struct flow_head *head = rtnl_dereference(tp->root);
 	struct flow_filter *f;
 
-	list_for_each_entry_rcu(f, &head->filters, list)
+	list_for_each_entry(f, &head->filters, list)
 		if (f->handle == handle)
 			return (unsigned long)f;
 	return 0;
@@ -654,7 +654,7 @@ static void flow_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	struct flow_head *head = rtnl_dereference(tp->root);
 	struct flow_filter *f;
 
-	list_for_each_entry_rcu(f, &head->filters, list) {
+	list_for_each_entry(f, &head->filters, list) {
 		if (arg->count < arg->skip)
 			goto skip;
 		if (arg->fn(tp, (unsigned long)f, arg) < 0) {
-- 
1.9.3
