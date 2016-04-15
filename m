From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 05/11] devlink: introduce helper to print out nice names (ifnames)
Date: Fri, 15 Apr 2016 09:51:47 +0200
Message-ID: <1460706713-5942-6-git-send-email-jiri@resnulli.us>
References: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37917 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbcDOHwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 03:52:04 -0400
Received: by mail-wm0-f51.google.com with SMTP id u206so20028764wme.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 00:52:03 -0700 (PDT)
In-Reply-To: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

By default, ifnames will be printed out. User can turn that off using
"-n" option on the command line.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c       | 90 +++++++++++++++++++++++++++++++++++++++++++------
 man/man8/devlink-dev.8  |  1 +
 man/man8/devlink-port.8 |  1 +
 man/man8/devlink.8      |  5 +++
 4 files changed, 86 insertions(+), 11 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index 0904e07..5e08666 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -114,6 +114,7 @@ struct dl {
 	struct list_head ifname_map_list;
 	int argc;
 	char **argv;
+	bool no_nice_names;
 };
 
 static int dl_argc(struct dl *dl)
@@ -290,6 +291,23 @@ static int ifname_map_lookup(struct dl *dl, const char *ifname,
 	return -ENOENT;
 }
 
+static int ifname_map_rev_lookup(struct dl *dl, const char *bus_name,
+				 const char *dev_name, uint32_t port_index,
+				 char **p_ifname)
+{
+	struct ifname_map *ifname_map;
+
+	list_for_each_entry(ifname_map, &dl->ifname_map_list, list) {
+		if (strcmp(bus_name, ifname_map->bus_name) == 0 &&
+		    strcmp(dev_name, ifname_map->dev_name) == 0 &&
+		    port_index == ifname_map->port_index) {
+			*p_ifname = ifname_map->ifname;
+			return 0;
+		}
+	}
+	return -ENOENT;
+}
+
 static unsigned int strslashcount(char *str)
 {
 	unsigned int count = 0;
@@ -517,16 +535,62 @@ static void cmd_dev_help(void)
 	pr_out("Usage: devlink dev show [ DEV ]\n");
 }
 
+static void __pr_out_handle(const char *bus_name, const char *dev_name)
+{
+	pr_out("%s/%s", bus_name, dev_name);
+}
+
 static void pr_out_handle(struct nlattr **tb)
 {
-	pr_out("%s/%s", mnl_attr_get_str(tb[DEVLINK_ATTR_BUS_NAME]),
+	__pr_out_handle(mnl_attr_get_str(tb[DEVLINK_ATTR_BUS_NAME]),
 			mnl_attr_get_str(tb[DEVLINK_ATTR_DEV_NAME]));
 }
 
+static void __pr_out_port_handle(const char *bus_name, const char *dev_name,
+				 uint32_t port_index)
+{
+	__pr_out_handle(bus_name, dev_name);
+	pr_out("/%d", port_index);
+}
+
 static void pr_out_port_handle(struct nlattr **tb)
 {
-	pr_out_handle(tb);
-	pr_out("/%d", mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_INDEX]));
+	__pr_out_port_handle(mnl_attr_get_str(tb[DEVLINK_ATTR_BUS_NAME]),
+			     mnl_attr_get_str(tb[DEVLINK_ATTR_DEV_NAME]),
+			     mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_INDEX]));
+}
+
+static void __pr_out_port_handle_nice(struct dl *dl, const char *bus_name,
+				      const char *dev_name, uint32_t port_index)
+{
+	char *ifname;
+	int err;
+
+	if (dl->no_nice_names)
+		goto no_nice_names;
+
+	err = ifname_map_rev_lookup(dl, bus_name, dev_name,
+				    port_index, &ifname);
+	if (err)
+		goto no_nice_names;
+	pr_out("%s", ifname);
+	return;
+
+no_nice_names:
+	__pr_out_port_handle(bus_name, dev_name, port_index);
+}
+
+static void pr_out_port_handle_nice(struct dl *dl, struct nlattr **tb)
+{
+	const char *bus_name;
+	const char *dev_name;
+	uint32_t port_index;
+
+	bus_name = mnl_attr_get_str(tb[DEVLINK_ATTR_BUS_NAME]);
+	dev_name = mnl_attr_get_str(tb[DEVLINK_ATTR_DEV_NAME]);
+	port_index = mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_INDEX]);
+
+	__pr_out_port_handle_nice(dl, bus_name, dev_name, port_index);
 }
 
 static void pr_out_dev(struct nlattr **tb)
@@ -867,7 +931,7 @@ static void help(void)
 {
 	pr_out("Usage: devlink [ OPTIONS ] OBJECT { COMMAND | help }\n"
 	       "where  OBJECT := { dev | port | monitor }\n"
-	       "       OPTIONS := { -V[ersion] }\n");
+	       "       OPTIONS := { -V[ersion] | -n[no-nice-names] }\n");
 }
 
 static int dl_cmd(struct dl *dl)
@@ -939,6 +1003,7 @@ int main(int argc, char **argv)
 {
 	static const struct option long_options[] = {
 		{ "Version",		no_argument,		NULL, 'V' },
+		{ "no-nice-names",	no_argument,		NULL, 'n' },
 		{ NULL, 0, NULL, 0 }
 	};
 	struct dl *dl;
@@ -946,13 +1011,22 @@ int main(int argc, char **argv)
 	int err;
 	int ret;
 
-	while ((opt = getopt_long(argc, argv, "V",
+	dl = dl_alloc();
+	if (!dl) {
+		pr_err("Failed to allocate memory for devlink\n");
+		return EXIT_FAILURE;
+	}
+
+	while ((opt = getopt_long(argc, argv, "Vn",
 				  long_options, NULL)) >= 0) {
 
 		switch (opt) {
 		case 'V':
 			printf("devlink utility, iproute2-ss%s\n", SNAPSHOT);
 			return EXIT_SUCCESS;
+		case 'n':
+			dl->no_nice_names = true;
+			break;
 		default:
 			pr_err("Unknown option.\n");
 			help();
@@ -963,12 +1037,6 @@ int main(int argc, char **argv)
 	argc -= optind;
 	argv += optind;
 
-	dl = dl_alloc();
-	if (!dl) {
-		pr_err("Failed to allocate memory for devlink\n");
-		return EXIT_FAILURE;
-	}
-
 	err = dl_init(dl, argc, argv);
 	if (err) {
 		ret = EXIT_FAILURE;
diff --git a/man/man8/devlink-dev.8 b/man/man8/devlink-dev.8
index 7878d89..af96a29 100644
--- a/man/man8/devlink-dev.8
+++ b/man/man8/devlink-dev.8
@@ -16,6 +16,7 @@ devlink-dev \- devlink device configuration
 .ti -8
 .IR OPTIONS " := { "
 \fB\-V\fR[\fIersion\fR] |
+\fB\-n\fR[\fIno-nice-names\fR] }
 
 .ti -8
 .B devlink dev show
diff --git a/man/man8/devlink-port.8 b/man/man8/devlink-port.8
index e6ae686..d78837c 100644
--- a/man/man8/devlink-port.8
+++ b/man/man8/devlink-port.8
@@ -16,6 +16,7 @@ devlink-port \- devlink port configuration
 .ti -8
 .IR OPTIONS " := { "
 \fB\-V\fR[\fIersion\fR] |
+\fB\-n\fR[\fIno-nice-names\fR] }
 
 .ti -8
 .BR "devlink port set "
diff --git a/man/man8/devlink.8 b/man/man8/devlink.8
index f608ccc..df00f4f 100644
--- a/man/man8/devlink.8
+++ b/man/man8/devlink.8
@@ -19,6 +19,7 @@ devlink \- Devlink tool
 .ti -8
 .IR OPTIONS " := { "
 \fB\-V\fR[\fIersion\fR] |
+\fB\-n\fR[\fIno-nice-names\fR] }
 
 .SH OPTIONS
 
@@ -28,6 +29,10 @@ Print the version of the
 .B devlink
 utility and exit.
 
+.TP
+.BR "\-n" , " -no-nice-names"
+Turn off printing out nice names, for example netdevice ifnames instead of devlink port identification.
+
 .SS
 .I OBJECT
 
-- 
2.5.5
