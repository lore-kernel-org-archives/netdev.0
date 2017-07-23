From: Liping Zhang <zlpnobody@163.com>
Subject: [PATCH net] openvswitch: fix potential out of bound access in parse_ct
Date: Sun, 23 Jul 2017 17:52:23 +0800
Message-ID: <1500803543-7297-1-git-send-email-zlpnobody@163.com>
Cc: netdev@vger.kernel.org, Liping Zhang <zlpnobody@gmail.com>
To: davem@davemloft.net, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:60603 "EHLO m12-14.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750909AbdGWJxS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Jul 2017 05:53:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

Before the 'type' is validated, we shouldn't use it to fetch the
ovs_ct_attr_lens's minlen and maxlen, else, out of bound access
may happen.

Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
---
 net/openvswitch/conntrack.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index e3c4c6c..03859e3 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -1310,8 +1310,8 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 
 	nla_for_each_nested(a, attr, rem) {
 		int type = nla_type(a);
-		int maxlen = ovs_ct_attr_lens[type].maxlen;
-		int minlen = ovs_ct_attr_lens[type].minlen;
+		int maxlen;
+		int minlen;
 
 		if (type > OVS_CT_ATTR_MAX) {
 			OVS_NLERR(log,
@@ -1319,6 +1319,9 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 				  type, OVS_CT_ATTR_MAX);
 			return -EINVAL;
 		}
+
+		maxlen = ovs_ct_attr_lens[type].maxlen;
+		minlen = ovs_ct_attr_lens[type].minlen;
 		if (nla_len(a) < minlen || nla_len(a) > maxlen) {
 			OVS_NLERR(log,
 				  "Conntrack attr type has unexpected length (type=%d, length=%d, expected=%d)",
-- 
2.5.5
