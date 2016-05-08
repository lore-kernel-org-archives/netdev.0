From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH v2 6/6] net sched: ife action fix late binding
Date: Sun,  8 May 2016 13:26:32 -0400
Message-ID: <1462728392-28489-7-git-send-email-jhs@emojatatu.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35833 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbcEHR0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 13:26:47 -0400
Received: by mail-io0-f195.google.com with SMTP id u185so19023215iod.2
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 10:26:47 -0700 (PDT)
In-Reply-To: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

The process below was broken and is fixed with this patch.

//add an ife action and give it an instance id of 1
sudo tc actions add action ife encode \
type 0xDEAD allow mark dst 02:15:15:15:15:15 index 1

//create a filter which binds to skbedit action id 1
sudo tc filter add dev $DEV parent ffff: protocol ip prio 1 u32\
match ip dst 17.0.0.1/32 flowid 1:11 action ife index 1

Message before fix was:
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_ife.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 556f44c..17520ed 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -423,7 +423,7 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 	u16 ife_type = 0;
 	u8 *daddr = NULL;
 	u8 *saddr = NULL;
-	int ret = 0;
+	int ret = 0, aexists = 0;
 	int err;
 
 	err = nla_parse_nested(tb, TCA_IFE_MAX, nla, ife_policy);
@@ -435,25 +435,29 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 
 	parm = nla_data(tb[TCA_IFE_PARMS]);
 
+	aexists = tcf_hash_check(tn, parm->index, a, bind);
+	if (aexists && bind)
+		return 0;
+
 	if (parm->flags & IFE_ENCODE) {
 		/* Until we get issued the ethertype, we cant have
 		 * a default..
 		**/
 		if (!tb[TCA_IFE_TYPE]) {
+			if (aexists)
+				tcf_hash_release(a, bind);
 			pr_info("You MUST pass etherype for encoding\n");
 			return -EINVAL;
 		}
 	}
 
-	if (!tcf_hash_check(tn, parm->index, a, bind)) {
+	if (!aexists) {
 		ret = tcf_hash_create(tn, parm->index, est, a, sizeof(*ife),
 				      bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
-		if (bind)	/* dont override defaults */
-			return 0;
 		tcf_hash_release(a, bind);
 		if (!ovr)
 			return -EEXIST;
@@ -495,6 +499,8 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 				       NULL);
 		if (err) {
 metadata_parse_err:
+			if (aexists)
+				tcf_hash_release(a, bind);
 			if (ret == ACT_P_CREATED)
 				_tcf_ife_cleanup(a, bind);
 
@@ -689,7 +695,7 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 	/*
 	   OUTERHDR:TOTMETALEN:{TLVHDR:Metadatum:TLVHDR..}:ORIGDATA
 	   where ORIGDATA = original ethernet header ...
-	 */
+	*/
 	u16 metalen = ife_get_sz(skb, ife);
 	int hdrm = metalen + skb->dev->hard_header_len + IFE_METAHDRLEN;
 	unsigned int skboff = skb->dev->hard_header_len;
-- 
1.9.1
