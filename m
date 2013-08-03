From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: [PATCH iproute2 v2 1/2] ip link: fix display of interface groups
Date: Sat, 3 Aug 2013 14:20:53 +0200
Message-ID: <20130803122053.GM21970@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:35368 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727Ab3HCMUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 08:20:54 -0400
Received: from stefan by zirkel.wertarbyte.de with local (Exim 4.72)
	(envelope-from <stefan.tomanek@wertarbyte.de>)
	id 1V5apJ-0001UG-Vm
	for netdev@vger.kernel.org; Sat, 03 Aug 2013 14:20:53 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds the interface group to the output of "ip link show".

It also makes "ip link" print _all_ devices if no group filter is specified;
previously, only interfaces of the default group (0) were shown.

Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
---
 include/rt_names.h |    1 +
 ip/ipaddress.c     |   10 ++++++++--
 lib/rt_names.c     |   19 +++++++++++++++++++
 3 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/include/rt_names.h b/include/rt_names.h
index 37adbd3..56b649a 100644
--- a/include/rt_names.h
+++ b/include/rt_names.h
@@ -8,6 +8,7 @@ const char *rtnl_rtscope_n2a(int id, char *buf, int len);
 const char *rtnl_rttable_n2a(__u32 id, char *buf, int len);
 const char *rtnl_rtrealm_n2a(int id, char *buf, int len);
 const char *rtnl_dsfield_n2a(int id, char *buf, int len);
+const char *rtnl_group_n2a(int id, char *buf, int len);
 
 int rtnl_rtprot_a2n(__u32 *id, const char *arg);
 int rtnl_rtscope_a2n(__u32 *id, const char *arg);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 013b4cb..1c3e4da 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -418,7 +418,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 	if (tb[IFLA_GROUP]) {
 		int group = *(int*)RTA_DATA(tb[IFLA_GROUP]);
-		if (group != filter.group)
+		if (filter.group != -1 && group != filter.group)
 			return -1;
 	}
 
@@ -458,6 +458,12 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (do_link && tb[IFLA_LINKMODE])
 		print_linkmode(fp, tb[IFLA_LINKMODE]);
 
+	if (tb[IFLA_GROUP]) {
+		SPRINT_BUF(b1);
+		int group = *(int*)RTA_DATA(tb[IFLA_GROUP]);
+		fprintf(fp, "group %s ", rtnl_group_n2a(group, b1, sizeof(b1)));
+	}
+
 	if (filter.showqueue)
 		print_queuelen(fp, tb);
 
@@ -1050,7 +1056,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 	if (filter.family == AF_UNSPEC)
 		filter.family = preferred_family;
 
-	filter.group = INIT_NETDEV_GROUP;
+	filter.group = -1;
 
 	if (action == IPADD_FLUSH) {
 		if (argc <= 0) {
diff --git a/lib/rt_names.c b/lib/rt_names.c
index 02f1417..67e4c49 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -500,3 +500,22 @@ int rtnl_group_a2n(int *id, const char *arg)
 	*id = i;
 	return 0;
 }
+
+const char *rtnl_group_n2a(int id, char *buf, int len)
+{
+	struct rtnl_hash_entry *entry;
+	int i;
+
+	if (!rtnl_group_init)
+		rtnl_group_initialize();
+
+	for (i=0; i<256; i++) {
+		entry = rtnl_group_hash[i];
+		if (entry && entry->id == id) {
+			return entry->name;
+		}
+	}
+
+	snprintf(buf, len, "%d", id);
+	return buf;
+}
-- 
1.7.10.4
