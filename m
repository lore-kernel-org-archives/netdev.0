From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v3 iproute2 5/6] ip vrf: Add ipvrf_get_table
Date: Wed, 29 Jun 2016 11:06:19 -0700
Message-ID: <1467223580-14548-6-git-send-email-dsa@cumulusnetworks.com>
References: <1467223580-14548-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36474 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbcF2SGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 14:06:30 -0400
Received: by mail-pf0-f174.google.com with SMTP id t190so20456413pfb.3
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 11:06:30 -0700 (PDT)
In-Reply-To: <1467223580-14548-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ipvrf_get_table to lookup table id for device name. Returns 0
on any error or if name is not a VRF device.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ip_common.h  |  1 +
 ip/iplink_vrf.c | 66 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index b747ea47122d..8faed6174f06 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -90,6 +90,7 @@ struct link_util *get_link_slave_kind(const char *slave_kind);
 
 void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf, size_t len);
 
+__u32 ipvrf_get_table(char *name);
 bool name_is_vrf(const char *name);
 
 #ifndef	INFINITY_LIFE_TIME
diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
index 166f566e6d77..b4013773537f 100644
--- a/ip/iplink_vrf.c
+++ b/ip/iplink_vrf.c
@@ -97,6 +97,72 @@ struct link_util vrf_slave_link_util = {
 	.slave          = true,
 };
 
+/* returns table id if name is a VRF device */
+__u32 ipvrf_get_table(char *name)
+{
+	struct {
+		struct nlmsghdr		n;
+		struct ifinfomsg	i;
+		char			buf[1024];
+	} req = {
+		.n = {
+			.nlmsg_len   = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type  = RTM_GETLINK,
+		},
+		.i = {
+			.ifi_family  = preferred_family,
+		},
+	};
+	struct {
+		struct nlmsghdr n;
+		char buf[8192];
+	} answer;
+	struct rtattr *tb[IFLA_MAX+1];
+	struct rtattr *li[IFLA_INFO_MAX+1];
+	struct rtattr *vrf_attr[IFLA_VRF_MAX + 1];
+	struct ifinfomsg *ifi;
+	__u32 tb_id = 0;
+	int len;
+
+	addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, strlen(name) + 1);
+
+	if (rtnl_talk(&rth, &req.n, &answer.n, sizeof(answer)) < 0)
+		goto err;
+
+	ifi = NLMSG_DATA(&answer.n);
+	len = answer.n.nlmsg_len - NLMSG_LENGTH(sizeof(*ifi));
+	if (len < 0) {
+		fprintf(stderr, "BUG: Invalid response to link query.\n");
+		goto err;
+	}
+
+	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
+
+	if (!tb[IFLA_LINKINFO])
+		goto err;
+
+	parse_rtattr_nested(li, IFLA_INFO_MAX, tb[IFLA_LINKINFO]);
+
+	if (!li[IFLA_INFO_KIND] || !li[IFLA_INFO_DATA])
+		goto err;
+
+	if (strcmp(RTA_DATA(li[IFLA_INFO_KIND]), "vrf"))
+		goto err;
+
+	parse_rtattr_nested(vrf_attr, IFLA_VRF_MAX, li[IFLA_INFO_DATA]);
+	if (vrf_attr[IFLA_VRF_TABLE])
+		tb_id = rta_getattr_u32(vrf_attr[IFLA_VRF_TABLE]);
+
+	if (!tb_id)
+		fprintf(stderr, "BUG: VRF %s is missing table id\n", name);
+
+	return tb_id;
+
+err:
+	return 0;
+}
+
 bool name_is_vrf(const char *name)
 {
 	struct {
-- 
2.1.4
