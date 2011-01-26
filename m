From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH v3 2/3] iproute2: support listing devices by group
Date: Wed, 26 Jan 2011 18:41:25 +0200
Message-ID: <1296060086-18777-3-git-send-email-ddvlad@rosedu.org>
References: <1296060086-18777-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:43648 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752588Ab1AZQla (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 11:41:30 -0500
In-Reply-To: <1296060086-18777-1-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

User can specify device group to list by using the devgroup keyword:

	ip link lst devgroup test

If no group is specified, 0 (default) is implied.

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 include/linux/netdevice.h |    2 +-
 ip/ipaddress.c            |   14 ++++++++++++++
 ip/iplink.c               |    3 ++-
 man/man8/ip.8             |   11 +++++++++--
 4 files changed, 26 insertions(+), 4 deletions(-)

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
index a775ecd..c634391 100644
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
+			if (lookup_map_id(*argv, &filter.group, GROUP_MAP))
+				invarg("Invalid \"group\" value\n", *argv);
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
diff --git a/ip/iplink.c b/ip/iplink.c
index 6c9df43..a781848 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -66,13 +66,14 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ address LLADDR ]\n");
 	fprintf(stderr, "	                  [ broadcast LLADDR ]\n");
 	fprintf(stderr, "	                  [ mtu MTU ]\n");
+	fprintf(stderr, "	                  [ group GROUP ]\n");
 	fprintf(stderr, "	                  [ netns PID ]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
 	fprintf(stderr, "			  [ group GROUP ]\n");
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
 	fprintf(stderr, "				   [ rate TXRATE ] ] \n");
-	fprintf(stderr, "       ip link show [ DEVICE ]\n");
+	fprintf(stderr, "       ip link show [ DEVICE | devgroup DEVGROUP ]\n");
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 77e03d8..5c42156 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -102,7 +102,9 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 
 .ti -8
 .B ip link show
-.RI "[ " DEVICE " ]"
+.RI "[ " DEVICE " | "
+.B devgroup
+.IR GROUP " ]"
 
 .ti -8
 .BR "ip addr" " { " add " | " del " } "
@@ -1065,7 +1067,12 @@ call.
 .BI dev " NAME " (default)
 .I NAME
 specifies the network device to show.
-If this argument is omitted all devices are listed.
+If this argument is omitted all devices in the default group are listed.
+
+.TP
+.BI devgroup " GROUP "
+.I GROUP
+specifies what group of devices to show.
 
 .TP
 .B up
-- 
1.7.1

