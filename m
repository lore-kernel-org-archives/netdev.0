From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net 4/4] openvswitch: Serialize nested ct actions if provided
Date: Mon, 19 Oct 2015 19:19:00 -0700
Message-ID: <1445307540-6786-4-git-send-email-joestringer@nicira.com>
References: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
Cc: tgraf@suug.ch, jrajahalme@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36232 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbbJTCTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 22:19:11 -0400
Received: by pacfv9 with SMTP id fv9so5000562pac.3
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 19:19:10 -0700 (PDT)
In-Reply-To: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If userspace provides a ct action with no nested mark or label, then the
storage for these fields is zeroed. Later when actions are requested,
such zeroed fields are serialized even though userspace didn't
originally specify them. Fix the behaviour by ensuring that no action is
serialized in this case, and reject actions where userspace attempts to
set these fields with mask=0. This should make netlink marshalling
consistent across deserialization/reserialization.

Reported-by: Jarno Rajahalme <jrajahalme@nicira.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
v2: Reuse labels_nonzero().
    Don't check for labels support during execution.
v3: Acked.
---
 net/openvswitch/conntrack.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 8ad121871834..a5ec34f8502f 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -224,9 +224,6 @@ static int ovs_ct_set_labels(struct sk_buff *skb, struct sw_flow_key *key,
 	struct nf_conn *ct;
 	int err;
 
-	if (!IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS))
-		return -ENOTSUPP;
-
 	/* The connection could be invalid, in which case set_label is no-op.*/
 	ct = nf_ct_get(skb, &ctinfo);
 	if (!ct)
@@ -587,6 +584,10 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 		case OVS_CT_ATTR_MARK: {
 			struct md_mark *mark = nla_data(a);
 
+			if (!mark->mask) {
+				OVS_NLERR(log, "ct_mark mask cannot be 0");
+				return -EINVAL;
+			}
 			info->mark = *mark;
 			break;
 		}
@@ -595,6 +596,10 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 		case OVS_CT_ATTR_LABELS: {
 			struct md_labels *labels = nla_data(a);
 
+			if (!labels_nonzero(&labels->mask)) {
+				OVS_NLERR(log, "ct_labels mask cannot be 0");
+				return -EINVAL;
+			}
 			info->labels = *labels;
 			break;
 		}
@@ -705,11 +710,12 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_ZONES) &&
 	    nla_put_u16(skb, OVS_CT_ATTR_ZONE, ct_info->zone.id))
 		return -EMSGSIZE;
-	if (IS_ENABLED(CONFIG_NF_CONNTRACK_MARK) &&
+	if (IS_ENABLED(CONFIG_NF_CONNTRACK_MARK) && ct_info->mark.mask &&
 	    nla_put(skb, OVS_CT_ATTR_MARK, sizeof(ct_info->mark),
 		    &ct_info->mark))
 		return -EMSGSIZE;
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
+	    labels_nonzero(&ct_info->labels.mask) &&
 	    nla_put(skb, OVS_CT_ATTR_LABELS, sizeof(ct_info->labels),
 		    &ct_info->labels))
 		return -EMSGSIZE;
-- 
2.1.4
