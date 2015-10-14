From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 3/3] openvswitch: Serialize nested ct actions if provided
Date: Wed, 14 Oct 2015 11:10:49 -0700
Message-ID: <1444846249-52053-4-git-send-email-joestringer@nicira.com>
References: <1444846249-52053-1-git-send-email-joestringer@nicira.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33166 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097AbbJNSLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 14:11:00 -0400
Received: by pabrc13 with SMTP id rc13so60907520pab.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 11:10:59 -0700 (PDT)
In-Reply-To: <1444846249-52053-1-git-send-email-joestringer@nicira.com>
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
 net/openvswitch/conntrack.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 480dbb9095b7..ba29e6c2e0d4 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -540,6 +540,16 @@ static int ovs_ct_add_helper(struct ovs_conntrack_info *info, const char *name,
 	return 0;
 }
 
+static bool label_zero(const struct ovs_key_ct_labels *labels)
+{
+	int i;
+
+	for (i = 0; i < sizeof(*labels); i++)
+		if (labels->ct_labels[i])
+			return false;
+	return true;
+}
+
 static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 	[OVS_CT_ATTR_COMMIT]	= { .minlen = 0, .maxlen = 0 },
 	[OVS_CT_ATTR_ZONE]	= { .minlen = sizeof(u16),
@@ -589,6 +599,10 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 		case OVS_CT_ATTR_MARK: {
 			struct md_mark *mark = nla_data(a);
 
+			if (!mark->mask) {
+				OVS_NLERR(log, "ct_mark mask cannot be 0");
+				return -EINVAL;
+			}
 			info->mark = *mark;
 			break;
 		}
@@ -597,6 +611,10 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 		case OVS_CT_ATTR_LABELS: {
 			struct md_labels *labels = nla_data(a);
 
+			if (label_zero(&labels->mask)) {
+				OVS_NLERR(log, "ct_labels mask cannot be 0");
+				return -EINVAL;
+			}
 			info->labels = *labels;
 			break;
 		}
@@ -707,11 +725,12 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_ZONES) &&
 	    nla_put_u16(skb, OVS_CT_ATTR_ZONE, ct_info->zone.id))
 		return -EMSGSIZE;
-	if (IS_ENABLED(CONFIG_NF_CONNTRACK_MARK) &&
+	if (IS_ENABLED(CONFIG_NF_CONNTRACK_MARK) && ct_info->mark.mask &&
 	    nla_put(skb, OVS_CT_ATTR_MARK, sizeof(ct_info->mark),
 		    &ct_info->mark))
 		return -EMSGSIZE;
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
+	    !label_zero(&ct_info->labels.mask) &&
 	    nla_put(skb, OVS_CT_ATTR_LABELS, sizeof(ct_info->labels),
 		    &ct_info->labels))
 		return -EMSGSIZE;
-- 
2.1.4
