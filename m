From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net V2] net/sched: pedit: make sure that offset is valid
Date: Mon, 28 Nov 2016 12:56:40 +0200
Message-ID: <20161128105640.32363-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:33799 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932105AbcK1K5q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 05:57:46 -0500
Received: by mail-wj0-f196.google.com with SMTP id xy5so13545596wjc.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 02:57:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a validation function to make sure offset is valid:
1. Not below skb head (could happen when offset is negative).
2. Validate both 'offset' and 'at'.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
Hi Dave,

Please pull to -stable branches.

Changes from V0:
- Add a validation to the 'at' value (this is used as an offset too)
- Instead of validating the output of skb_header_pointer(), make sure that the
	offset is good before calling it.

Thanks,
Amir
 net/sched/act_pedit.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index b54d56d4959b..cf9b2fe8eac6 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -108,6 +108,17 @@ static void tcf_pedit_cleanup(struct tc_action *a, int bind)
 	kfree(keys);
 }
 
+static bool offset_valid(struct sk_buff *skb, int offset)
+{
+	if (offset > 0 && offset > skb->len)
+		return false;
+
+	if  (offset < 0 && -offset > skb_headroom(skb))
+		return false;
+
+	return true;
+}
+
 static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 		     struct tcf_result *res)
 {
@@ -134,6 +145,11 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 			if (tkey->offmask) {
 				char *d, _d;
 
+				if (!offset_valid(skb, off + tkey->at)) {
+					pr_info("tc filter pedit 'at' offset %d out of bounds\n",
+						off + tkey->at);
+					goto bad;
+				}
 				d = skb_header_pointer(skb, off + tkey->at, 1,
 						       &_d);
 				if (!d)
@@ -146,10 +162,10 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 					" offset must be on 32 bit boundaries\n");
 				goto bad;
 			}
-			if (offset > 0 && offset > skb->len) {
-				pr_info("tc filter pedit"
-					" offset %d can't exceed pkt length %d\n",
-				       offset, skb->len);
+
+			if (!offset_valid(skb, off + offset)) {
+				pr_info("tc filter pedit offset %d out of bounds\n",
+					offset);
 				goto bad;
 			}
 
-- 
2.10.2
