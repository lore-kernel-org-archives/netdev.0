From: roopa@cumulusnetworks.com
Subject: [PATCH 1/6] bridge: add support to parse multiple vlan info attributes in IFLA_AF_SPEC
Date: Mon, 29 Dec 2014 13:05:27 -0800
Message-ID: <1419887132-7084-2-git-send-email-roopa@cumulusnetworks.com>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
To: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:50934 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbaL2VFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 16:05:42 -0500
Received: by mail-pd0-f178.google.com with SMTP id r10so17880001pdi.23
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 13:05:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch changes bridge IFLA_AF_SPEC netlink attribute parser to
look for more than one IFLA_BRIDGE_VLAN_INFO attribute. This allows
userspace to pack more than one vlan in the setlink msg.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 9f5eb55..75971b1 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -230,18 +230,18 @@ static int br_afspec(struct net_bridge *br,
 		     struct nlattr *af_spec,
 		     int cmd)
 {
-	struct nlattr *tb[IFLA_BRIDGE_MAX+1];
+	struct bridge_vlan_info *vinfo;
 	int err = 0;
+	struct nlattr *attr;
+	int err = 0;
+	int rem;
+	u16 vid;
 
-	err = nla_parse_nested(tb, IFLA_BRIDGE_MAX, af_spec, ifla_br_policy);
-	if (err)
-		return err;
-
-	if (tb[IFLA_BRIDGE_VLAN_INFO]) {
-		struct bridge_vlan_info *vinfo;
-
-		vinfo = nla_data(tb[IFLA_BRIDGE_VLAN_INFO]);
+	nla_for_each_nested(attr, af_spec, rem) {
+		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
+			continue;
 
+		vinfo = nla_data(attr);
 		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
 			return -EINVAL;
 
-- 
1.7.10.4
