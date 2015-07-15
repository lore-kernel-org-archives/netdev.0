From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next] bridge: mdb: add support for vlans
Date: Wed, 15 Jul 2015 08:45:20 -0700
Message-ID: <1436975120-41319-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:32983 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbbGOPpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 11:45:34 -0400
Received: by pdbqm3 with SMTP id qm3so27085793pdb.0
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 08:45:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the user to specify the vlan of the mdb group being
added or deleted and adds support for displaying the vlan when
dumping mdb information or monitoring it. It also updates the man page
to reflect the new "vid" argument for mdb.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
note: the cast in print_mdb_entry() was necessary to shut the compiler

 bridge/mdb.c              | 31 +++++++++++++++++++------------
 include/linux/if_bridge.h |  1 +
 man/man8/bridge.8         |  8 +++++++-
 3 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/bridge/mdb.c b/bridge/mdb.c
index 9a8ed540ce64..ea169b9c2e4d 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -28,7 +28,7 @@ static unsigned int filter_index;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge mdb { add | del } dev DEV port PORT grp GROUP [permanent | temp]\n");
+	fprintf(stderr, "Usage: bridge mdb { add | del } dev DEV port PORT grp GROUP [permanent | temp] [vid VID]\n");
 	fprintf(stderr, "       bridge mdb {show} [ dev DEV ]\n");
 	exit(-1);
 }
@@ -51,17 +51,19 @@ static void br_print_router_ports(FILE *f, struct rtattr *attr)
 static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e)
 {
 	SPRINT_BUF(abuf);
-
-	if (e->addr.proto == htons(ETH_P_IP))
-		fprintf(f, "dev %s port %s grp %s %s\n", ll_index_to_name(ifindex),
-			ll_index_to_name(e->ifindex),
-			inet_ntop(AF_INET, &e->addr.u.ip4, abuf, sizeof(abuf)),
-			(e->state & MDB_PERMANENT) ? "permanent" : "temp");
-	else
-		fprintf(f, "dev %s port %s grp %s %s\n", ll_index_to_name(ifindex),
-			ll_index_to_name(e->ifindex),
-			inet_ntop(AF_INET6, &e->addr.u.ip6, abuf, sizeof(abuf)),
-			(e->state & MDB_PERMANENT) ? "permanent" : "temp");
+	const void *src;
+	int af;
+
+	af = e->addr.proto == htons(ETH_P_IP) ? AF_INET : AF_INET6;
+	src = af == AF_INET ? (const void *)&e->addr.u.ip4 :
+			      (const void *)&e->addr.u.ip6;
+	fprintf(f, "dev %s port %s grp %s %s", ll_index_to_name(ifindex),
+		ll_index_to_name(e->ifindex),
+		inet_ntop(af, src, abuf, sizeof(abuf)),
+		(e->state & MDB_PERMANENT) ? "permanent" : "temp");
+	if (e->vid)
+		fprintf(f, " vid %hu", e->vid);
+	fprintf(f, "\n");
 }
 
 static void br_print_mdb_entry(FILE *f, int ifindex, struct rtattr *attr)
@@ -165,6 +167,7 @@ static int mdb_modify(int cmd, int flags, int argc, char **argv)
 	} req;
 	struct br_mdb_entry entry;
 	char *d = NULL, *p = NULL, *grp = NULL;
+	short vid = 0;
 
 	memset(&req, 0, sizeof(req));
 	memset(&entry, 0, sizeof(entry));
@@ -189,6 +192,9 @@ static int mdb_modify(int cmd, int flags, int argc, char **argv)
 				entry.state |= MDB_PERMANENT;
 		} else if (strcmp(*argv, "temp") == 0) {
 			;/* nothing */
+		} else if (strcmp(*argv, "vid") == 0) {
+			NEXT_ARG();
+			vid = atoi(*argv);
 		} else {
 			if (matches(*argv, "help") == 0)
 				usage();
@@ -222,6 +228,7 @@ static int mdb_modify(int cmd, int flags, int argc, char **argv)
 	} else
 		entry.addr.proto = htons(ETH_P_IP);
 
+	entry.vid = vid;
 	addattr_l(&req.n, sizeof(req), MDBA_SET_ENTRY, &entry, sizeof(entry));
 
 	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 913bd8e3d406..f24050ba71bc 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -182,6 +182,7 @@ struct br_mdb_entry {
 #define MDB_TEMPORARY 0
 #define MDB_PERMANENT 1
 	__u8 state;
+	__u16 vid;
 	struct {
 		union {
 			__be32	ip4;
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 4135d01a08bc..8922bf6f332b 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -77,7 +77,9 @@ bridge \- show / manipulate bridge addresses and devices
 .IR PORT
 .B grp
 .IR GROUP " [ "
-.BR permanent " | " temp " ]"
+.BR permanent " | " temp " ] [ "
+.B vid
+.IR VID " ] "
 
 .ti -8
 .BR "bridge mdb show " [ "
@@ -426,6 +428,10 @@ the port.
 - the mdb entry is temporary (default)
 .sp
 
+.TP
+.BI vid " VID"
+the VLAN ID which is known to have members of this multicast group.
+
 .in -8
 .SS bridge mdb delete - delete a multicast group database entry
 This command removes an existing mdb entry.
-- 
1.9.3
