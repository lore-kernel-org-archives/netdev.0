From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 1/3] iproute2: distinguish permanent and temporary
	mdb entries
Date: Thu, 20 Dec 2012 22:31:53 +0800
Message-ID: <1356013915-20835-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bridge@lists.linux-foundation.org, Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This patch adds a flag to mdb entries so that we can distinguish
permanent entries with temporary ones.

Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 bridge/mdb.c              |   24 +++++++++++++++---------
 include/linux/if_bridge.h |    3 +++
 2 files changed, 18 insertions(+), 9 deletions(-)

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
-- 
1.7.7.6
