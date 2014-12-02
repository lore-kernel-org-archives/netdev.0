From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/6] net_sched: cls_bpf: remove faulty use of list_for_each_entry_rcu
Date: Tue,  2 Dec 2014 18:00:33 +0100
Message-ID: <1417539636-12710-4-git-send-email-jiri@resnulli.us>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:61827 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbaLBRFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 12:05:48 -0500
Received: by mail-wg0-f44.google.com with SMTP id b13so17603105wgh.3
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 09:05:46 -0800 (PST)
In-Reply-To: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rcu variant is not correct here. The code is called by updater (rtnl
lock is held), not by reader (no rcu_read_lock is held).

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/cls_bpf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index cbfaf6f..d0de979 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -141,7 +141,7 @@ static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
 	if (head == NULL)
 		return 0UL;
 
-	list_for_each_entry_rcu(prog, &head->plist, link) {
+	list_for_each_entry(prog, &head->plist, link) {
 		if (prog->handle == handle) {
 			ret = (unsigned long) prog;
 			break;
@@ -337,7 +337,7 @@ static void cls_bpf_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	struct cls_bpf_head *head = rtnl_dereference(tp->root);
 	struct cls_bpf_prog *prog;
 
-	list_for_each_entry_rcu(prog, &head->plist, link) {
+	list_for_each_entry(prog, &head->plist, link) {
 		if (arg->count < arg->skip)
 			goto skip;
 		if (arg->fn(tp, (unsigned long) prog, arg) < 0) {
-- 
1.9.3
