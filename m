From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC repost 4/8] datapath: execution of select group action
Date: Thu, 18 Sep 2014 10:55:07 +0900
Message-ID: <1411005311-11752-5-git-send-email-simon.horman@netronome.com>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Cc: Pravin Shelar <pshelar@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:59013 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757052AbaIRB5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 21:57:47 -0400
Received: by mail-pa0-f54.google.com with SMTP id lj1so347370pab.13
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 18:57:47 -0700 (PDT)
In-Reply-To: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow execution of select group action in the datapath.
A subsequent patch will add validation and copying of
the select group action in the datapath.

The selection algorithm used is based on the RSS hash.
This was chosen because it resembles the algorithm currently
used by the implementation of select groups in ovs-vswitchd.

It may well be that in this case it is more efficient to handle
things in ovs-vswitchd, avoiding the cost of hashing on each packet.
Or that the hashing mechanism used can be optimised somehow. However,
we would like to avoid focusing on these questions of this particular
implementation.

The purpose of this patch is to form part of a prototype for a select
group action. The current Open Flow specification allows for the
implementation to select an algorithm. And we have made a separate
proposal to allow the selection algorithm to be configured via Open Flow.
Thus the algorithm and used and its implementation are not central
to the prototype.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 datapath/actions.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 70 insertions(+)

diff --git a/datapath/actions.c b/datapath/actions.c
index 8d18848..51ca40b 100644
--- a/datapath/actions.c
+++ b/datapath/actions.c
@@ -809,6 +809,72 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 	return 0;
 }
 
+const struct nlattr *bucket_actions(const struct nlattr *attr)
+{
+	const struct nlattr *a;
+	int rem;
+
+	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
+	     a = nla_next(a, &rem)) {
+		if (nla_type(a) == OVS_BUCKET_ATTR_ACTIONS) {
+			return a;
+		}
+	}
+
+	return NULL;
+}
+
+static u16 bucket_weight(const struct nlattr *attr)
+{
+	const struct nlattr *weight;
+
+	/* validate_and_copy_bucket() ensures that the first
+	 * attribute is OVS_BUCKET_ATTR_WEIGHT */
+	weight = nla_data(attr);
+	BUG_ON(nla_type(weight) != OVS_BUCKET_ATTR_WEIGHT);
+	return nla_get_u16(weight);
+}
+
+static int select_group(struct datapath *dp, struct sk_buff *skb,
+			const struct nlattr *attr)
+{
+	const struct nlattr *best_bucket = NULL;
+	const struct nlattr *acts_list;
+	const struct nlattr *bucket;
+	struct sk_buff *sample_skb;
+	u32 best_score = 0;
+	u32 basis;
+	u32 i = 0;
+	int rem;
+
+	basis = skb_get_hash(skb);
+
+	/* Only possible type of attributes is OVS_SELECT_GROUP_ATTR_BUCKET */
+	for (bucket = nla_data(attr), rem = nla_len(attr); rem > 0;
+	     bucket = nla_next(bucket, &rem)) {
+		uint16_t weight = bucket_weight(bucket);
+		// XXX: This hashing seems expensive
+		u32 score = (jhash_1word(i, basis) & 0xffff) * weight;
+
+		if (score >= best_score) {
+			best_bucket = bucket;
+			best_score = score;
+		}
+		i++;
+	}
+
+	acts_list = bucket_actions(best_bucket);
+
+	/* A select group action is always the final action so
+	 * there is no need to clone the skb in case of side effects.
+	 * Instead just take a reference to it which will be released
+	 * by do_execute_actions(). */
+	skb_get(skb);
+
+	return do_execute_actions(dp, skb, nla_data(acts_list),
+				  nla_len(acts_list));
+}
+
 static void execute_hash(struct sk_buff *skb, const struct nlattr *attr)
 {
 	struct sw_flow_key *key = OVS_CB(skb)->pkt_key;
@@ -986,6 +1052,10 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		case OVS_ACTION_ATTR_SAMPLE:
 			err = sample(dp, skb, a);
 			break;
+
+		case OVS_ACTION_ATTR_SELECT_GROUP:
+			err = select_group(dp, skb, a);
+			break;
 		}
 
 		if (unlikely(err)) {
-- 
2.0.1
