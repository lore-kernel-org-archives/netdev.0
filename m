From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net 3/3] openvswitch: Serialize nested ct actions if provided
Date: Fri, 16 Oct 2015 11:08:21 -0700
Message-ID: <1445018901-18839-4-git-send-email-joestringer@nicira.com>
References: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35733 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162AbbJPSIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 14:08:35 -0400
Received: by padcn9 with SMTP id cn9so12036027pad.2
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 11:08:35 -0700 (PDT)
In-Reply-To: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
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
---
v2: Reuse labels_nonzero().
    Don't check for labels support during execution.
---
 net/openvswitch/conntrack.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 480dbb9095b7..b0287f13491a 100644
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
@@ -589,6 +586,10 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 		case OVS_CT_ATTR_MARK: {
 			struct md_mark *mark = nla_data(a);
 
+			if (!mark->mask) {
+				OVS_NLERR(log, "ct_mark mask cannot be 0");
+				return -EINVAL;
+			}
 			info->mark = *mark;
 			break;
 		}
@@ -597,6 +598,10 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 		case OVS_CT_ATTR_LABELS: {
 			struct md_labels *labels = nla_data(a);
 
+			if (!labels_nonzero(&labels->mask)) {
+				OVS_NLERR(log, "ct_labels mask cannot be 0");
+				return -EINVAL;
+			}
 			info->labels = *labels;
 			break;
 		}
@@ -707,11 +712,12 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
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
