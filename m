From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/10] net: sched: replace nprio by a bool to make the function more readable
Date: Thu, 27 Apr 2017 13:12:14 +0200
Message-ID: <1493291540-2119-5-git-send-email-jiri@resnulli.us>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, mlxsw@mellanox.com,
        simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36051 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935489AbdD0LMa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 07:12:30 -0400
Received: by mail-wr0-f193.google.com with SMTP id v42so3383274wrc.3
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 04:12:29 -0700 (PDT)
In-Reply-To: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The use of "nprio" variable in tc_ctl_tfilter is a bit cryptic and makes
a reader wonder what is going on for a while. So help him to understand
this priority allocation dance a litte bit better.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 88ec1a1..0e49e6e 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -271,7 +271,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	struct tcmsg *t;
 	u32 protocol;
 	u32 prio;
-	u32 nprio;
+	bool prio_allocate;
 	u32 parent;
 	struct net_device *dev;
 	struct Qdisc  *q;
@@ -300,7 +300,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	t = nlmsg_data(n);
 	protocol = TC_H_MIN(t->tcm_info);
 	prio = TC_H_MAJ(t->tcm_info);
-	nprio = prio;
+	prio_allocate = false;
 	parent = t->tcm_parent;
 	cl = 0;
 
@@ -316,6 +316,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 			 */
 			if (n->nlmsg_flags & NLM_F_CREATE) {
 				prio = TC_H_MAKE(0x80000000U, 0U);
+				prio_allocate = true;
 				break;
 			}
 			/* fall-through */
@@ -377,7 +378,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	     back = &tp->next) {
 		if (tp->prio >= prio) {
 			if (tp->prio == prio) {
-				if (!nprio ||
+				if (prio_allocate ||
 				    (tp->protocol != protocol && protocol)) {
 					err = -EINVAL;
 					goto errout;
@@ -403,11 +404,11 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 			goto errout;
 		}
 
-		if (!nprio)
-			nprio = TC_H_MAJ(tcf_auto_prio(rtnl_dereference(*back)));
+		if (prio_allocate)
+			prio = TC_H_MAJ(tcf_auto_prio(rtnl_dereference(*back)));
 
 		tp = tcf_proto_create(nla_data(tca[TCA_KIND]),
-				      protocol, nprio, parent, q, block);
+				      protocol, prio, parent, q, block);
 		if (IS_ERR(tp)) {
 			err = PTR_ERR(tp);
 			goto errout;
-- 
2.7.4
