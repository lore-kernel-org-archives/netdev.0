From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 3/8] odp-util: formatting of datapath select group action
Date: Thu, 18 Sep 2014 10:52:28 +0900
Message-ID: <1411005153-11041-4-git-send-email-simon.horman@netronome.com>
References: <1411005153-11041-1-git-send-email-simon.horman@netronome.com>
Cc: Pravin Shelar <pshelar@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: dev@openvswtich.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:46708 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757408AbaIRBwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 21:52:54 -0400
Received: by mail-pd0-f173.google.com with SMTP id ft15so320913pdb.4
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 18:52:53 -0700 (PDT)
In-Reply-To: <1411005153-11041-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow formatting of select group action. This is used
when pretty-printing datapath flows. Subsequent patches
will add support for the select group action to the datapath
and ovs-vswtichd.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 lib/odp-util.c | 67 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff --git a/lib/odp-util.c b/lib/odp-util.c
index 77b456f..4c8dd39 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -182,6 +182,71 @@ format_odp_sample_action(struct ds *ds, const struct nlattr *attr)
     ds_put_format(ds, "))");
 }
 
+static bool
+format_odp_bucket(struct ds *ds, const struct nlattr *attr)
+{
+    static const struct nl_policy ovs_sample_policy[] = {
+        [OVS_BUCKET_ATTR_WEIGHT] = { .type = NL_A_U16 },
+        [OVS_BUCKET_ATTR_ACTIONS] = { .type = NL_A_NESTED }
+    };
+    struct nlattr *a[ARRAY_SIZE(ovs_sample_policy)];
+    const struct nlattr *nla_acts;
+    int len;
+
+    ds_put_cstr(ds, "bucket");
+
+    if (!nl_parse_nested(attr, ovs_sample_policy, a, ARRAY_SIZE(a))) {
+        ds_put_cstr(ds, "(error)");
+        return false;
+    }
+
+    ds_put_format(ds, "(weight=%d,",
+                  nl_attr_get_u16(a[OVS_BUCKET_ATTR_WEIGHT]));
+
+    ds_put_cstr(ds, "actions(");
+    nla_acts = nl_attr_get(a[OVS_SAMPLE_ATTR_ACTIONS]);
+    len = nl_attr_get_size(a[OVS_SAMPLE_ATTR_ACTIONS]);
+    format_odp_actions(ds, nla_acts, len);
+    ds_put_format(ds, "))");
+
+    return true;
+}
+
+static void
+format_odp_select_group_action(struct ds *ds, const struct nlattr *attr)
+{
+    static const struct nl_policy ovs_sample_policy[] = {
+        [OVS_SELECT_GROUP_ATTR_BUCKET] = { .type = NL_A_NESTED,
+                                           .multiple = true }
+    };
+    struct nlattr *a[ARRAY_SIZE(ovs_sample_policy)];
+    struct nlattr *nla;
+    struct ofpbuf buf;
+    size_t left;
+
+    ds_put_cstr(ds, "select_group");
+
+    if (!nl_parse_nested(attr, ovs_sample_policy, a, ARRAY_SIZE(a))) {
+        ds_put_cstr(ds, "(error)");
+        return;
+    }
+
+    ds_put_cstr(ds, "(actions(");
+
+    nl_attr_get_nested(attr, &buf);
+    NL_ATTR_FOR_EACH (nla, left, ofpbuf_data(&buf), ofpbuf_size(&buf))
+    {
+        uint16_t type = nl_attr_type(nla);
+
+        ovs_assert(type == OVS_SELECT_GROUP_ATTR_BUCKET);
+        if (!format_odp_bucket(ds, nla)) {
+            break;
+        }
+    }
+
+    ds_put_format(ds, "))");
+}
+
 static const char *
 slow_path_reason_to_string(uint32_t reason)
 {
@@ -583,6 +648,8 @@ format_odp_action(struct ds *ds, const struct nlattr *a)
         format_odp_sample_action(ds, a);
         break;
     case OVS_ACTION_ATTR_SELECT_GROUP:
+        format_odp_select_group_action(ds, a);
+        break;
     case OVS_ACTION_ATTR_UNSPEC:
     case __OVS_ACTION_ATTR_MAX:
     default:
-- 
2.0.1
