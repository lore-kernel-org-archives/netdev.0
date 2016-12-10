From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next 6/8] change name_is_vrf to return index
Date: Sat, 10 Dec 2016 12:32:12 -0800
Message-ID: <1481401934-4026-7-git-send-email-dsa@cumulusnetworks.com>
References: <1481401934-4026-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:34724 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752395AbcLJUcZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 15:32:25 -0500
Received: by mail-pg0-f50.google.com with SMTP id x23so20195681pgx.1
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2016 12:32:25 -0800 (PST)
In-Reply-To: <1481401934-4026-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

index of 0 means name is not a valid vrf.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ip_common.h  |  2 +-
 ip/iplink_vrf.c | 15 +++++++++------
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index 0147f45a7a31..3162f1ca5b2c 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -91,7 +91,7 @@ struct link_util *get_link_kind(const char *kind);
 void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf, size_t len);
 
 __u32 ipvrf_get_table(const char *name);
-bool name_is_vrf(const char *name);
+int name_is_vrf(const char *name);
 
 #ifndef	INFINITY_LIFE_TIME
 #define     INFINITY_LIFE_TIME      0xFFFFFFFFU
diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
index a238b2906805..c101ed770f87 100644
--- a/ip/iplink_vrf.c
+++ b/ip/iplink_vrf.c
@@ -159,7 +159,7 @@ __u32 ipvrf_get_table(const char *name)
 	return tb_id;
 }
 
-bool name_is_vrf(const char *name)
+int name_is_vrf(const char *name)
 {
 	struct {
 		struct nlmsghdr		n;
@@ -187,24 +187,27 @@ bool name_is_vrf(const char *name)
 	addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, strlen(name) + 1);
 
 	if (rtnl_talk(&rth, &req.n, &answer.n, sizeof(answer)) < 0)
-		return false;
+		return 0;
 
 	ifi = NLMSG_DATA(&answer.n);
 	len = answer.n.nlmsg_len - NLMSG_LENGTH(sizeof(*ifi));
 	if (len < 0) {
 		fprintf(stderr, "BUG: Invalid response to link query.\n");
-		return false;
+		return 0;
 	}
 
 	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
 
 	if (!tb[IFLA_LINKINFO])
-		return false;
+		return 0;
 
 	parse_rtattr_nested(li, IFLA_INFO_MAX, tb[IFLA_LINKINFO]);
 
 	if (!li[IFLA_INFO_KIND])
-		return false;
+		return 0;
+
+	if (strcmp(RTA_DATA(li[IFLA_INFO_KIND]), "vrf"))
+		return 0;
 
-	return strcmp(RTA_DATA(li[IFLA_INFO_KIND]), "vrf") == 0;
+	return ifi->ifi_index;
 }
-- 
2.1.4
