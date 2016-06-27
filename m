From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 1/6] ip vrf: Add name_is_vrf
Date: Mon, 27 Jun 2016 11:50:56 -0700
Message-ID: <1467053461-16147-2-git-send-email-dsa@cumulusnetworks.com>
References: <1467053461-16147-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36260 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbcF0SvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 14:51:10 -0400
Received: by mail-pa0-f54.google.com with SMTP id wo6so61538593pac.3
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 11:51:10 -0700 (PDT)
In-Reply-To: <1467053461-16147-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add name_is_vrf function to determine if given name corresponds to a
VRF device.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ip_common.h  |  2 ++
 ip/iplink_vrf.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index e8da9e034b15..410eb135774a 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -90,6 +90,8 @@ struct link_util *get_link_slave_kind(const char *slave_kind);
 
 void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf, size_t len);
 
+bool name_is_vrf(char *name);
+
 #ifndef	INFINITY_LIFE_TIME
 #define     INFINITY_LIFE_TIME      0xFFFFFFFFU
 #endif
diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
index e3c7b4652da5..abd43c08423e 100644
--- a/ip/iplink_vrf.c
+++ b/ip/iplink_vrf.c
@@ -96,3 +96,56 @@ struct link_util vrf_slave_link_util = {
 	.print_opt	= vrf_slave_print_opt,
 	.slave          = true,
 };
+
+bool name_is_vrf(char *name)
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
+	struct ifinfomsg *ifi;
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
+	if (!li[IFLA_INFO_KIND])
+		goto err;
+
+	return strcmp(RTA_DATA(li[IFLA_INFO_KIND]), "vrf") == 0;
+
+err:
+	return false;
+}
-- 
2.1.4
