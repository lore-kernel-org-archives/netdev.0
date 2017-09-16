From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net] net/sched: cls_matchall: fix crash when used with classful qdisc
Date: Sat, 16 Sep 2017 14:02:21 +0200
Message-ID: <b930159de5531a4d216a1cd2c2ef03aa41f421f9.1505562794.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50470 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751185AbdIPMCf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 16 Sep 2017 08:02:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this script, edited from Linux Advanced Routing and Traffic Control guide

tc q a dev en0 root handle 1: htb default a
tc c a dev en0 parent 1:  classid 1:1 htb rate 6mbit burst 15k
tc c a dev en0 parent 1:1 classid 1:a htb rate 5mbit ceil 6mbit burst 15k
tc c a dev en0 parent 1:1 classid 1:b htb rate 1mbit ceil 6mbit burst 15k
tc f a dev en0 parent 1:0 prio 1 $clsname $clsargs classid 1:b
ping $address -c1
tc -s c s dev en0

classifies traffic to 1:b or 1:a, depending on whether the packet matches
or not the pattern $clsargs of filter $clsname. However, when $clsname is
'matchall', a systematic crash can be observed in htb_classify(). HTB and
classful qdiscs don't assign initial value to struct tcf_result, but then
they expect it to contain valid values after filters have been run. Thus,
current 'matchall' ignores the TCA_MATCHALL_CLASSID attribute, configured
by user, and makes HTB (and classful qdiscs) dereference random pointers.

By assigning head->res to *res in mall_classify(), before the actions are
invoked, we fix this crash and enable TCA_MATCHALL_CLASSID functionality,
that had no effect on 'matchall' classifier since its first introduction.

BugLink: https://bugzilla.redhat.com/show_bug.cgi?id=1460213
Reported-by: Jiri Benc <jbenc@redhat.com>
Fixes: b87f7936a932 ("net/sched: introduce Match-all classifier")
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 net/sched/cls_matchall.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index 21cc45caf842..eeac606c95ab 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -32,6 +32,7 @@ static int mall_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	if (tc_skip_sw(head->flags))
 		return -1;
 
+	*res = head->res;
 	return tcf_exts_exec(skb, &head->exts, res);
 }
 
-- 
2.13.5
