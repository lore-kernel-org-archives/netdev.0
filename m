From: Cong Wang <amwang@redhat.com>
Subject: [Patch] iproute2: distinguish permanent and temporary mdb entries
Date: Sat, 15 Dec 2012 16:09:52 +0800
Message-ID: <1355558992-32285-3-git-send-email-amwang@redhat.com>
References: <1355558992-32285-1-git-send-email-amwang@redhat.com>
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38787 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751057Ab2LOIiv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Dec 2012 03:38:51 -0500
In-Reply-To: <1355558992-32285-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/bridge/mdb.c b/bridge/mdb.c
index 121ce9c..6217c5f 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -28,7 +28,7 @@ int filter_index;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge mdb { add | del } dev DEV port PORT grp GROUP\n");
+	fprintf(stderr, "Usage: bridge mdb { add | del } dev DEV port PORT grp GROUP [permanent | temp]\n");
 	fprintf(stderr, "       bridge mdb {show} [ dev DEV ]\n");
 	exit(-1);
 }
@@ -53,13 +53,15 @@ static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e)
 	SPRINT_BUF(abuf);
 
 	if (e->addr.proto == htons(ETH_P_IP))
-		fprintf(f, "bridge %s port %s group %s\n", ll_index_to_name(ifindex),
+		fprintf(f, "bridge %s port %s group %s %s\n", ll_index_to_name(ifindex),
 			ll_index_to_name(e->ifindex),
-			inet_ntop(AF_INET, &e->addr.u.ip4, abuf, sizeof(abuf)));
+			inet_ntop(AF_INET, &e->addr.u.ip4, abuf, sizeof(abuf)),
+			(e->state & MDB_PERMANENT) ? "permanent" : "temp");
 	else
-		fprintf(f, "bridge %s port %s group %s\n", ll_index_to_name(ifindex),
+		fprintf(f, "bridge %s port %s group %s %s\n", ll_index_to_name(ifindex),
 			ll_index_to_name(e->ifindex),
-			inet_ntop(AF_INET6, &e->addr.u.ip6, abuf, sizeof(abuf)));
+			inet_ntop(AF_INET6, &e->addr.u.ip6, abuf, sizeof(abuf)),
+			(e->state & MDB_PERMANENT) ? "permanent" : "temp");
 }
 
 static void br_print_mdb_entry(FILE *f, int ifindex, struct rtattr *attr)
@@ -179,11 +181,15 @@ static int mdb_modify(int cmd, int flags, int argc, char **argv)
 		} else if (strcmp(*argv, "grp") == 0) {
 			NEXT_ARG();
 			grp = *argv;
+		} else if (strcmp(*argv, "port") == 0) {
+			NEXT_ARG();
+			p = *argv;
+		} else if (strcmp(*argv, "permanent") == 0) {
+			if (cmd == RTM_NEWMDB)
+				entry.state |= MDB_PERMANENT;
+		} else if (strcmp(*argv, "temp") == 0) {
+			;/* nothing */
 		} else {
-			if (strcmp(*argv, "port") == 0) {
-				NEXT_ARG();
-				p = *argv;
-			}
 			if (matches(*argv, "help") == 0)
 				usage();
 		}
diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index b3b6a67..aac8b8c 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -163,6 +163,9 @@ struct br_port_msg {
 
 struct br_mdb_entry {
 	__u32 ifindex;
+#define MDB_TEMPORARY 0
+#define MDB_PERMANENT 1
+	__u8 state;
 	struct {
 		union {
 			__be32	ip4;
