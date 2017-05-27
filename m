From: David Ahern <dsahern@gmail.com>
Subject: [PATCH iproute2 3/4] ip address: Change print_linkinfo_brief to take filter as an input
Date: Sat, 27 May 2017 17:34:49 -0600
Message-ID: <20170527233450.58015-4-dsahern@gmail.com>
References: <20170527233450.58015-1-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36675 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750751AbdE0Xe7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 19:34:59 -0400
Received: by mail-pg0-f67.google.com with SMTP id h64so2561447pge.3
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 16:34:59 -0700 (PDT)
In-Reply-To: <20170527233450.58015-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change print_linkinfo_brief to take the filter as an input arg.
If the arg is NULL, use the global filter in ipaddress.c.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 ip/ip_common.h |  3 ++-
 ip/ipaddress.c | 35 ++++++++++++++++++++---------------
 ip/iplink.c    |  2 +-
 3 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index 2b3cf7049b65..77e9dd06b864 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -22,7 +22,8 @@ int get_operstate(const char *name);
 int print_linkinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg);
 int print_linkinfo_brief(const struct sockaddr_nl *who,
-			 struct nlmsghdr *n, void *arg);
+			 struct nlmsghdr *n, void *arg,
+			 struct link_filter *filter);
 int print_addrinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg);
 int print_addrlabel(const struct sockaddr_nl *who,
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 3e2c38a8e53e..4900dce09df8 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -634,7 +634,8 @@ static void print_link_stats(FILE *fp, struct nlmsghdr *n)
 }
 
 int print_linkinfo_brief(const struct sockaddr_nl *who,
-				struct nlmsghdr *n, void *arg)
+			 struct nlmsghdr *n, void *arg,
+			 struct link_filter *pfilter)
 {
 	FILE *fp = (FILE *)arg;
 	struct ifinfomsg *ifi = NLMSG_DATA(n);
@@ -651,9 +652,12 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 	if (len < 0)
 		return -1;
 
-	if (filter.ifindex && ifi->ifi_index != filter.ifindex)
+	if (!pfilter)
+		pfilter = &filter;
+
+	if (pfilter->ifindex && ifi->ifi_index != pfilter->ifindex)
 		return -1;
-	if (filter.up && !(ifi->ifi_flags&IFF_UP))
+	if (pfilter->up && !(ifi->ifi_flags&IFF_UP))
 		return -1;
 
 	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
@@ -664,30 +668,30 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 		name = rta_getattr_str(tb[IFLA_IFNAME]);
 	}
 
-	if (filter.label &&
-	    (!filter.family || filter.family == AF_PACKET) &&
-	    fnmatch(filter.label, RTA_DATA(tb[IFLA_IFNAME]), 0))
+	if (pfilter->label &&
+	    (!pfilter->family || pfilter->family == AF_PACKET) &&
+	    fnmatch(pfilter->label, RTA_DATA(tb[IFLA_IFNAME]), 0))
 		return -1;
 
 	if (tb[IFLA_GROUP]) {
 		int group = rta_getattr_u32(tb[IFLA_GROUP]);
 
-		if (filter.group != -1 && group != filter.group)
+		if (pfilter->group != -1 && group != pfilter->group)
 			return -1;
 	}
 
 	if (tb[IFLA_MASTER]) {
 		int master = rta_getattr_u32(tb[IFLA_MASTER]);
 
-		if (filter.master > 0 && master != filter.master)
+		if (pfilter->master > 0 && master != pfilter->master)
 			return -1;
-	} else if (filter.master > 0)
+	} else if (pfilter->master > 0)
 		return -1;
 
-	if (filter.kind && match_link_kind(tb, filter.kind, 0))
+	if (pfilter->kind && match_link_kind(tb, pfilter->kind, 0))
 		return -1;
 
-	if (filter.slave_kind && match_link_kind(tb, filter.slave_kind, 1))
+	if (pfilter->slave_kind && match_link_kind(tb, pfilter->slave_kind, 1))
 		return -1;
 
 	if (n->nlmsg_type == RTM_DELLINK)
@@ -713,7 +717,7 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 	if (tb[IFLA_OPERSTATE])
 		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
 
-	if (filter.family == AF_PACKET) {
+	if (pfilter->family == AF_PACKET) {
 		SPRINT_BUF(b1);
 		if (tb[IFLA_ADDRESS]) {
 			color_fprintf(fp, COLOR_MAC, "%s ",
@@ -724,10 +728,10 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 		}
 	}
 
-	if (filter.family == AF_PACKET)
+	if (pfilter->family == AF_PACKET)
 		print_link_flags(fp, ifi->ifi_flags, m_flag);
 
-	if (filter.family == AF_PACKET)
+	if (pfilter->family == AF_PACKET)
 		fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
@@ -1736,7 +1740,8 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
 
 		if (brief) {
-			if (print_linkinfo_brief(NULL, &l->h, stdout) == 0)
+			if (print_linkinfo_brief(NULL, &l->h,
+						 stdout, NULL) == 0)
 				if (filter.family != AF_PACKET)
 					print_selected_addrinfo(ifi,
 								ainfo->head,
diff --git a/ip/iplink.c b/ip/iplink.c
index ae1c70ebcc81..58af402cc5eb 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -1036,7 +1036,7 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 		return -2;
 
 	if (brief)
-		print_linkinfo_brief(NULL, &answer.n, stdout);
+		print_linkinfo_brief(NULL, &answer.n, stdout, NULL);
 	else
 		print_linkinfo(NULL, &answer.n, stdout);
 
-- 
2.11.0 (Apple Git-81)
