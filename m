From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH net-next 2/3] act_ife: use registered ife_type as fallback
Date: Mon, 28 Aug 2017 15:03:14 -0400
Message-ID: <20170828190315.26646-3-aring@mojatatu.com>
References: <20170828190315.26646-1-aring@mojatatu.com>
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        lucasb@mojatatu.com, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org,
        Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32984 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751213AbdH1TEc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:04:32 -0400
Received: by mail-io0-f193.google.com with SMTP id s101so1094923ioe.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 12:04:32 -0700 (PDT)
In-Reply-To: <20170828190315.26646-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch handles a default IFE type if it's not given by user space
netlink api. The default IFE type will be the registered ethertype by
IEEE for IFE ForCES.

Signed-off-by: Alexander Aring <aring@mojatatu.com>
---
 net/sched/act_ife.c | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index c5dec308b8b1..7ed1be80ee86 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -435,8 +435,8 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 	struct nlattr *tb[TCA_IFE_MAX + 1];
 	struct nlattr *tb2[IFE_META_MAX + 1];
 	struct tcf_ife_info *ife;
+	u16 ife_type = ETH_P_IFE;
 	struct tc_ife *parm;
-	u16 ife_type = 0;
 	u8 *daddr = NULL;
 	u8 *saddr = NULL;
 	bool exists = false;
@@ -456,18 +456,6 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 	if (exists && bind)
 		return 0;
 
-	if (parm->flags & IFE_ENCODE) {
-		/* Until we get issued the ethertype, we cant have
-		 * a default..
-		**/
-		if (!tb[TCA_IFE_TYPE]) {
-			if (exists)
-				tcf_hash_release(*a, bind);
-			pr_info("You MUST pass etherype for encoding\n");
-			return -EINVAL;
-		}
-	}
-
 	if (!exists) {
 		ret = tcf_hash_create(tn, parm->index, est, a, &act_ife_ops,
 				      bind, false);
@@ -484,7 +472,8 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 	ife->flags = parm->flags;
 
 	if (parm->flags & IFE_ENCODE) {
-		ife_type = nla_get_u16(tb[TCA_IFE_TYPE]);
+		if (tb[TCA_IFE_TYPE])
+			ife_type = nla_get_u16(tb[TCA_IFE_TYPE]);
 		if (tb[TCA_IFE_DMAC])
 			daddr = nla_data(tb[TCA_IFE_DMAC]);
 		if (tb[TCA_IFE_SMAC])
-- 
2.11.0
