From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: sch_htb: add per class overlimits
 counter
Date: Mon, 18 Sep 2017 12:36:22 -0700
Message-ID: <1505763382.29839.27.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35460 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750886AbdIRTgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:36:25 -0400
Received: by mail-pf0-f196.google.com with SMTP id i23so577485pfi.2
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 12:36:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

HTB qdisc overlimits counter is properly increased, but we have no per
class counter, meaning it is difficult to diagnose HTB problems.

This patch adds this counter, visible in "tc -s class show dev eth0",
with current iproute2.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
---

We have used this at Google for few years already, time to ship it !

 net/sched/sch_htb.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 7e148376ba528efabe5a53a09653f9161c264be7..c6d7ae81b41f4e277afb93a3003fefcd3f27de35 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -142,6 +142,7 @@ struct htb_class {
 	struct rb_node		node[TC_HTB_NUMPRIO];	/* node for self or feed tree */
 
 	unsigned int drops ____cacheline_aligned_in_smp;
+	unsigned int		overlimits;
 };
 
 struct htb_level {
@@ -533,6 +534,9 @@ htb_change_class_mode(struct htb_sched *q, struct htb_class *cl, s64 *diff)
 	if (new_mode == cl->cmode)
 		return;
 
+	if (new_mode == HTB_CANT_SEND)
+		cl->overlimits++;
+
 	if (cl->prio_activity) {	/* not necessary: speed optimization */
 		if (cl->cmode != HTB_CANT_SEND)
 			htb_deactivate_prios(q, cl);
@@ -1143,6 +1147,7 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 	struct htb_class *cl = (struct htb_class *)arg;
 	struct gnet_stats_queue qs = {
 		.drops = cl->drops,
+		.overlimits = cl->overlimits,
 	};
 	__u32 qlen = 0;
 
