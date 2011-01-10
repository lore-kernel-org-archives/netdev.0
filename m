From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH 2/3] ip link: support listing devices by group
Date: Mon, 10 Jan 2011 13:39:18 +0200
Message-ID: <1294659559-22648-3-git-send-email-ddvlad@rosedu.org>
References: <1294659559-22648-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:33770 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753759Ab1AJLjY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 06:39:24 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1294659559-22648-1-git-send-email-ddvlad@rosedu.org>
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

User can specify device group to list by using the devgroup keyword:

	ip link lst devgroup 1

If no group is specified, 0 is implied.

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 include/linux/netdevice.h |    2 +-
 ip/ipaddress.c            |   14 ++++++++++++++
 ip/iplink.c               |    1 +
 3 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bec4e23..ad2e34d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -33,7 +33,7 @@
 
 #define MAX_ADDR_LEN	32		/* Largest hardware address length */
 
-
+#define INIT_NETDEV_GROUP	0	/* Initial group net devices belong to */
 
 /* Media selection options. */
 enum {
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index a775ecd..66e4350 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -49,6 +49,7 @@ static struct
 	char *flushb;
 	int flushp;
 	int flushe;
+	int group;
 } filter;
 
 static int do_link;
@@ -246,6 +247,12 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	    fnmatch(filter.label, RTA_DATA(tb[IFLA_IFNAME]), 0))
 		return 0;
 
+	if (tb[IFLA_GROUP]) {
+		int group = *(int*)RTA_DATA(tb[IFLA_GROUP]);
+		if (group != filter.group)
+			return -1;
+	}
+
 	if (n->nlmsg_type == RTM_DELLINK)
 		fprintf(fp, "Deleted ");
 
@@ -718,9 +725,12 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 	if (filter.family == AF_UNSPEC)
 		filter.family = preferred_family;
 
+	filter.group = INIT_NETDEV_GROUP;
+
 	if (flush) {
 		if (argc <= 0) {
 			fprintf(stderr, "Flush requires arguments.\n");
+
 			return -1;
 		}
 		if (filter.family == AF_PACKET) {
@@ -779,6 +789,10 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		} else if (strcmp(*argv, "label") == 0) {
 			NEXT_ARG();
 			filter.label = *argv;
+		} else if (strcmp(*argv, "devgroup") == 0) {
+			NEXT_ARG();
+			if (get_integer(&filter.group, *argv, 0))
+				invarg("Invalid \"devgroup\" value\n", *argv);
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
diff --git a/ip/iplink.c b/ip/iplink.c
index a7bad2c..c0378e7 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -66,6 +66,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ address LLADDR ]\n");
 	fprintf(stderr, "	                  [ broadcast LLADDR ]\n");
 	fprintf(stderr, "	                  [ mtu MTU ]\n");
+	fprintf(stderr, "	                  [ group GROUP ]\n");
 	fprintf(stderr, "	                  [ netns PID ]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
-- 
1.7.1

