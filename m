From: Eli Cohen <eli@mellanox.com>
Subject: [PATCH v2] Add support for configuring Infiniband GUIDs
Date: Thu,  7 Jul 2016 16:09:03 -0500
Message-ID: <20160707210903.24260-1-eli@mellanox.com>
Cc: david.laight@aculab.com, netdev@vger.kernel.org,
	Eli Cohen <eli@mellanox.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45628 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752028AbcGGVOn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2016 17:14:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two NLA's that allow configuration of Infiniband node or port GUIDs
by referencing the IPoIB net device set over the physical function. The
format to be used is as follows:

ip link set dev ib0 vf 0 node_guid 00:02:c9:03:00:21:6e:70
ip link set dev ib0 vf 0 port_guid 00:02:c9:03:00:21:6e:78

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
Changes from v1:
Add range checking
Avoid using sscanf
Print error message in case of invalid string format

 include/utils.h       |  1 +
 ip/iplink.c           | 20 ++++++++++++++++++++
 lib/utils.c           | 35 +++++++++++++++++++++++++++++++++++
 man/man8/ip-link.8.in | 12 +++++++++++-
 4 files changed, 67 insertions(+), 1 deletion(-)

diff --git a/include/utils.h b/include/utils.h
index 27562a1c949c..82f1aa7de16a 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -248,5 +248,6 @@ int do_each_netns(int (*func)(char *nsname, void *arg), void *arg,
 		bool show_label);
 
 char *int_to_str(int val, char *buf);
+int get_guid(__u64 *guid, const char *arg);
 
 #endif /* __UTILS_H__ */
diff --git a/ip/iplink.c b/ip/iplink.c
index f2a2e13cf0c5..28a0a21cf055 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -420,6 +420,26 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 				invarg("Invalid \"state\" value\n", *argv);
 			ivl.vf = vf;
 			addattr_l(&req->n, sizeof(*req), IFLA_VF_LINK_STATE, &ivl, sizeof(ivl));
+		} else if (matches(*argv, "node_guid") == 0) {
+			struct ifla_vf_guid ivg;
+
+			NEXT_ARG();
+			ivg.vf = vf;
+			if (get_guid(&ivg.guid, *argv)) {
+				invarg("Invalid GUID format\n", *argv);
+				return -1;
+			}
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_IB_NODE_GUID, &ivg, sizeof(ivg));
+		} else if (matches(*argv, "port_guid") == 0) {
+			struct ifla_vf_guid ivg;
+
+			NEXT_ARG();
+			ivg.vf = vf;
+			if (get_guid(&ivg.guid, *argv)) {
+				invarg("Invalid GUID format\n", *argv);
+				return -1;
+			}
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_IB_PORT_GUID, &ivg, sizeof(ivg));
 		} else {
 			/* rewind arg */
 			PREV_ARG();
diff --git a/lib/utils.c b/lib/utils.c
index 7dceeb5805a0..966047460af1 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -1121,3 +1121,38 @@ char *int_to_str(int val, char *buf)
 	sprintf(buf, "%d", val);
 	return buf;
 }
+
+int get_guid(__u64 *guid, const char *arg)
+{
+	unsigned long int tmp;
+	char *endptr;
+	int i;
+
+#define GUID_STR_LEN 23
+	/* Verify strict format: format string must be
+	 * xx:xx:xx:xx:xx:xx:xx:xx where xx can be an arbitrary
+	 * hex digit
+	 */
+
+	if (strlen(arg) != GUID_STR_LEN)
+		return -1;
+
+	/* make sure columns are in place */
+	for (i = 0; i < 7; i++)
+		if (arg[2 + i * 3] != ':')
+			return -1;
+
+	*guid = 0;
+	for (i = 0; i < 8; i++) {
+		tmp = strtoul(arg + i * 3, &endptr, 16);
+		if (endptr != arg + i * 3 + 2)
+			return -1;
+
+		if (tmp > 255)
+			return -1;
+
+		 *guid |= tmp << (56 - 8 * i);
+	}
+
+	return 0;
+}
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ad18f7555d0a..95fef02c86ff 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -146,7 +146,11 @@ ip-link \- network device configuration
 .br
 .RB "[ " state " { " auto " | " enable " | " disable " } ]"
 .br
-.RB "[ " trust " { " on " | " off " } ] ]"
+.RB "[ " trust " { " on " | " off " } ]"
+.br
+.RB "[ " node_guid " eui64 ]"
+.br
+.RB "[ " port_guid " eui64 ] ]"
 .br
 .in -9
 .RB "[ " master
@@ -1196,6 +1200,12 @@ sent by the VF.
 .BI trust " on|off"
 - trust the specified VF user. This enables that VF user can set a specific feature
 which may impact security and/or performance. (e.g. VF multicast promiscuous mode)
+.sp
+.BI node_guid " eui64"
+- configure node GUID for the VF.
+.sp
+.BI port_guid " eui64"
+- configure port GUID for the VF.
 .in -8
 
 .TP
-- 
2.8.1
