From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 11/11] act_police: remove <=mtu check for gso skbs
Date: Tue, 12 Feb 2013 11:12:09 +0100
Message-ID: <1360663929-1023-12-git-send-email-jiri@resnulli.us>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:35229 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138Ab3BLKMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 05:12:48 -0500
Received: by mail-ea0-f180.google.com with SMTP id c1so69306eaa.25
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 02:12:47 -0800 (PST)
In-Reply-To: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This check made bigger packets incorrectly dropped. Remove this
limitation for gso skbs.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/act_police.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 823463a..2dba297 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -325,7 +325,7 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 		return police->tcf_action;
 	}
 
-	if (qdisc_pkt_len(skb) <= police->tcfp_mtu) {
+	if (qdisc_pkt_len(skb) <= police->tcfp_mtu || skb_is_gso(skb)) {
 		if (!police->rate_present) {
 			spin_unlock(&police->tcf_lock);
 			return police->tcfp_result;
@@ -336,7 +336,7 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 			     police->tcfp_burst);
 		if (police->peak_present) {
 			ptoks = toks + police->tcfp_ptoks;
-			if (ptoks > police->tcfp_mtu_ptoks)
+			if (ptoks > police->tcfp_mtu_ptoks && !skb_is_gso(skb))
 				ptoks = police->tcfp_mtu_ptoks;
 			ptoks -= (s64) psched_l2t_ns(&police->peak,
 						     qdisc_pkt_len(skb));
-- 
1.8.1.2
