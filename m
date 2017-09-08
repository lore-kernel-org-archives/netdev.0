From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/3] bridge: isolate vlans  parsing code in a separate API
Date: Fri,  8 Sep 2017 17:52:21 -0400
Message-ID: <1504907543-14394-2-git-send-email-mrv@mojatatu.com>
References: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:37024 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932323AbdIHVwv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 17:52:51 -0400
Received: by mail-io0-f195.google.com with SMTP id p63so1715333ioe.4
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 14:52:51 -0700 (PDT)
In-Reply-To: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFLA_BRIDGE_VLAN_INFO parsing logic will be used in link and vlan
processing code, so it makes sense to move it in the separate function.

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 bridge/br_common.h |   1 +
 bridge/vlan.c      | 145 +++++++++++++++++++++++++++--------------------------
 2 files changed, 76 insertions(+), 70 deletions(-)

diff --git a/bridge/br_common.h b/bridge/br_common.h
index c649e7d..01447dd 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -4,6 +4,7 @@
 #define MDB_RTR_RTA(r) \
 		((struct rtattr *)(((char *)(r)) + RTA_ALIGN(sizeof(__u32))))
 
+extern void print_vlan_info(FILE *fp, struct rtattr *tb, int ifindex);
 extern int print_linkinfo(const struct sockaddr_nl *who,
 			  struct nlmsghdr *n,
 			  void *arg);
diff --git a/bridge/vlan.c b/bridge/vlan.c
index ebcdace..fc361ae 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -189,7 +189,6 @@ static int print_vlan(const struct sockaddr_nl *who,
 	struct ifinfomsg *ifm = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *tb[IFLA_MAX+1];
-	bool vlan_flags = false;
 
 	if (n->nlmsg_type != RTM_NEWLINK) {
 		fprintf(stderr, "Not RTM_NEWLINK: %08x %08x %08x\n",
@@ -218,75 +217,7 @@ static int print_vlan(const struct sockaddr_nl *who,
 				ll_index_to_name(ifm->ifi_index));
 		return 0;
 	} else {
-		struct rtattr *i, *list = tb[IFLA_AF_SPEC];
-		int rem = RTA_PAYLOAD(list);
-		__u16 last_vid_start = 0;
-
-		if (!filter_vlan)
-			print_vlan_port(fp, ifm->ifi_index);
-
-		for (i = RTA_DATA(list); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
-			struct bridge_vlan_info *vinfo;
-			int vcheck_ret;
-
-			if (i->rta_type != IFLA_BRIDGE_VLAN_INFO)
-				continue;
-
-			vinfo = RTA_DATA(i);
-
-			if (!(vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END))
-				last_vid_start = vinfo->vid;
-			vcheck_ret = filter_vlan_check(vinfo);
-			if (vcheck_ret == -1)
-				break;
-			else if (vcheck_ret == 0)
-				continue;
-
-			if (filter_vlan)
-				print_vlan_port(fp, ifm->ifi_index);
-			if (jw_global) {
-				jsonw_start_object(jw_global);
-				jsonw_uint_field(jw_global, "vlan",
-						 last_vid_start);
-				if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN)
-					continue;
-			} else {
-				fprintf(fp, "\t %hu", last_vid_start);
-			}
-			if (last_vid_start != vinfo->vid) {
-				if (jw_global)
-					jsonw_uint_field(jw_global, "vlanEnd",
-							 vinfo->vid);
-				else
-					fprintf(fp, "-%hu", vinfo->vid);
-			}
-			if (vinfo->flags & BRIDGE_VLAN_INFO_PVID) {
-				if (jw_global) {
-					start_json_vlan_flags_array(&vlan_flags);
-					jsonw_string(jw_global, "PVID");
-				} else {
-					fprintf(fp, " PVID");
-				}
-			}
-			if (vinfo->flags & BRIDGE_VLAN_INFO_UNTAGGED) {
-				if (jw_global) {
-					start_json_vlan_flags_array(&vlan_flags);
-					jsonw_string(jw_global,
-						     "Egress Untagged");
-				} else {
-					fprintf(fp, " Egress Untagged");
-				}
-			}
-			if (jw_global && vlan_flags) {
-				jsonw_end_array(jw_global);
-				vlan_flags = false;
-			}
-
-			if (jw_global)
-				jsonw_end_object(jw_global);
-			else
-				fprintf(fp, "\n");
-		}
+		print_vlan_info(fp, tb[IFLA_AF_SPEC], ifm->ifi_index);
 	}
 	if (!filter_vlan) {
 		if (jw_global)
@@ -470,6 +401,80 @@ static int vlan_show(int argc, char **argv)
 	return 0;
 }
 
+void print_vlan_info(FILE *fp, struct rtattr *tb, int ifindex)
+{
+	struct rtattr *i, *list = tb;
+	int rem = RTA_PAYLOAD(list);
+	__u16 last_vid_start = 0;
+	bool vlan_flags = false;
+
+	if (!filter_vlan)
+		print_vlan_port(fp, ifindex);
+
+	for (i = RTA_DATA(list); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		struct bridge_vlan_info *vinfo;
+		int vcheck_ret;
+
+		if (i->rta_type != IFLA_BRIDGE_VLAN_INFO)
+			continue;
+
+		vinfo = RTA_DATA(i);
+
+		if (!(vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END))
+			last_vid_start = vinfo->vid;
+		vcheck_ret = filter_vlan_check(vinfo);
+		if (vcheck_ret == -1)
+			break;
+		else if (vcheck_ret == 0)
+			continue;
+
+		if (filter_vlan)
+			print_vlan_port(fp, ifindex);
+		if (jw_global) {
+			jsonw_start_object(jw_global);
+			jsonw_uint_field(jw_global, "vlan",
+					 last_vid_start);
+			if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN)
+				continue;
+		} else {
+			fprintf(fp, "\t %hu", last_vid_start);
+		}
+		if (last_vid_start != vinfo->vid) {
+			if (jw_global)
+				jsonw_uint_field(jw_global, "vlanEnd",
+						 vinfo->vid);
+			else
+				fprintf(fp, "-%hu", vinfo->vid);
+		}
+		if (vinfo->flags & BRIDGE_VLAN_INFO_PVID) {
+			if (jw_global) {
+				start_json_vlan_flags_array(&vlan_flags);
+				jsonw_string(jw_global, "PVID");
+			} else {
+				fprintf(fp, " PVID");
+			}
+		}
+		if (vinfo->flags & BRIDGE_VLAN_INFO_UNTAGGED) {
+			if (jw_global) {
+				start_json_vlan_flags_array(&vlan_flags);
+				jsonw_string(jw_global,
+					     "Egress Untagged");
+			} else {
+				fprintf(fp, " Egress Untagged");
+			}
+		}
+		if (jw_global && vlan_flags) {
+			jsonw_end_array(jw_global);
+			vlan_flags = false;
+		}
+
+		if (jw_global)
+			jsonw_end_object(jw_global);
+		else
+			fprintf(fp, "\n");
+	}
+}
+
 int do_vlan(int argc, char **argv)
 {
 	ll_init_map(&rth);
-- 
1.9.1
