From: Jeff Mahoney <jeffm@suse.com>
Subject: [PATCH] net sched: fix kernel leak in act_police
Date: Tue, 31 Aug 2010 19:21:42 -0400
Message-ID: <4C7D8E86.6020705@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Network Development <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53807 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754637Ab0HaXVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 19:21:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 While reviewing commit 1c40be12f7d8ca1d387510d39787b12e512a7ce8, I
 audited other users of tc_action_ops->dump for information leaks.

 That commit covered almost all of them but act_police still had a leak.

 opt.limit and opt.capab aren't zeroed out before the structure is
 passed out.

 This patch uses the C99 initializers to zero everything unused out.

Signed-off-by: Jeff Mahoney <jeffm@suse.com>
Acked-by: Jeff Mahoney <jeffm@suse.com>
---
 net/sched/act_police.c |   19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -350,22 +350,19 @@ tcf_act_police_dump(struct sk_buff *skb,
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tcf_police *police = a->priv;
-	struct tc_police opt;
+	struct tc_police opt = {
+		.index = police->tcf_index,
+		.action = police->tcf_action,
+		.mtu = police->tcfp_mtu,
+		.burst = police->tcfp_burst,
+		.refcnt = police->tcf_refcnt - ref,
+		.bindcnt = police->tcf_bindcnt - bind,
+	};
 
-	opt.index = police->tcf_index;
-	opt.action = police->tcf_action;
-	opt.mtu = police->tcfp_mtu;
-	opt.burst = police->tcfp_burst;
-	opt.refcnt = police->tcf_refcnt - ref;
-	opt.bindcnt = police->tcf_bindcnt - bind;
 	if (police->tcfp_R_tab)
 		opt.rate = police->tcfp_R_tab->rate;
-	else
-		memset(&opt.rate, 0, sizeof(opt.rate));
 	if (police->tcfp_P_tab)
 		opt.peakrate = police->tcfp_P_tab->rate;
-	else
-		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
 	NLA_PUT(skb, TCA_POLICE_TBF, sizeof(opt), &opt);
 	if (police->tcfp_result)
 		NLA_PUT_U32(skb, TCA_POLICE_RESULT, police->tcfp_result);
-- 
Jeff Mahoney
SUSE Labs
