From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH v4 1/2] iproute2: support listing devices by group
Date: Wed,  2 Feb 2011 20:23:40 +0200
Message-ID: <1296671021-24421-2-git-send-email-ddvlad@rosedu.org>
References: <1296671021-24421-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:48696 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754846Ab1BBSXp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 13:23:45 -0500
In-Reply-To: <1296671021-24421-1-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

User can specify device group to list by using the group keyword:

	ip link show group test

If no group is specified, 0 (default) is implied.

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 etc/iproute2/group        |    2 +
 include/linux/if_link.h   |    1 +
 include/linux/netdevice.h |    2 +-
 include/rt_names.h        |    1 +
 ip/ipaddress.c            |   14 ++++++++++++
 ip/iplink.c               |    2 +-
 lib/rt_names.c            |   50 +++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip.8             |   11 ++++++++-
 8 files changed, 79 insertions(+), 4 deletions(-)
 create mode 100644 etc/iproute2/group

diff --git a/etc/iproute2/group b/etc/iproute2/group
new file mode 100644
index 0000000..6f000b2
--- /dev/null
+++ b/etc/iproute2/group
@@ -0,0 +1,2 @@
+# device group names
+0	default
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index e87456c..54d05f9 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -135,6 +135,7 @@ enum {
 	IFLA_VF_PORTS,
 	IFLA_PORT_SELF,
 	IFLA_AF_SPEC,
+	IFLA_GROUP,
 	__IFLA_MAX
 };
 
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
diff --git a/include/rt_names.h b/include/rt_names.h
index 07a10e0..e5dbd45 100644
--- a/include/rt_names.h
+++ b/include/rt_names.h
@@ -13,6 +13,7 @@ int rtnl_rtscope_a2n(__u32 *id, char *arg);
 int rtnl_rttable_a2n(__u32 *id, char *arg);
 int rtnl_rtrealm_a2n(__u32 *id, char *arg);
 int rtnl_dsfield_a2n(__u32 *id, char *arg);
+int rtnl_group_a2n(int *id, char *arg);
 
 const char *inet_proto_n2a(int proto, char *buf, int len);
 int inet_proto_a2n(char *buf);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index a775ecd..e4748e3 100644
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
+		} else if (strcmp(*argv, "group") == 0) {
+			NEXT_ARG();
+			if (rtnl_group_a2n(&filter.group, *argv))
+				invarg("Invalid \"group\" value\n", *argv);
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
diff --git a/ip/iplink.c b/ip/iplink.c
index cb2c4f5..97a960b 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -71,7 +71,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
 	fprintf(stderr, "				   [ rate TXRATE ] ] \n");
-	fprintf(stderr, "       ip link show [ DEVICE ]\n");
+	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ]\n");
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
diff --git a/lib/rt_names.c b/lib/rt_names.c
index 52edfe3..30d43cd 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -447,3 +447,53 @@ int rtnl_dsfield_a2n(__u32 *id, char *arg)
 	return 0;
 }
 
+
+static struct rtnl_hash_entry dflt_group_entry  = { .id = 0, .name = "default" };
+
+static struct rtnl_hash_entry * rtnl_group_hash[256] = {
+	[0] = &dflt_group_entry,
+};
+
+static int rtnl_group_init;
+
+static void rtnl_group_initialize(void)
+{
+	rtnl_group_init = 1;
+	rtnl_hash_initialize("/etc/iproute2/group",
+			     rtnl_group_hash, 256);
+}
+
+int rtnl_group_a2n(int *id, char *arg)
+{
+	static char *cache = NULL;
+	static unsigned long res;
+	struct rtnl_hash_entry *entry;
+	char *end;
+	int i;
+
+	if (cache && strcmp(cache, arg) == 0) {
+		*id = res;
+		return 0;
+	}
+
+	if (!rtnl_group_init)
+		rtnl_group_initialize();
+
+	for (i=0; i<256; i++) {
+		entry = rtnl_group_hash[i];
+		while (entry && strcmp(entry->name, arg))
+			entry = entry->next;
+		if (entry) {
+			cache = entry->name;
+			res = entry->id;
+			*id = res;
+			return 0;
+		}
+	}
+
+	i = strtol(arg, &end, 0);
+	if (!end || end == arg || *end || i < 0)
+		return -1;
+	*id = i;
+	return 0;
+}
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 8d55fa9..730788a 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -99,7 +99,9 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 
 .ti -8
 .B ip link show
-.RI "[ " DEVICE " ]"
+.RI "[ " DEVICE " | "
+.B group
+.IR GROUP " ]"
 
 .ti -8
 .BR "ip addr" " { " add " | " del " } "
@@ -1056,7 +1058,12 @@ call.
 .BI dev " NAME " (default)
 .I NAME
 specifies the network device to show.
-If this argument is omitted all devices are listed.
+If this argument is omitted all devices in the default group are listed.
+
+.TP
+.BI group " GROUP "
+.I GROUP
+specifies what group of devices to show.
 
 .TP
 .B up
-- 
1.7.1

