From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 1/2] iproute2: implement add/del mdb entry
Date: Wed, 12 Dec 2012 16:23:09 +0800
Message-ID: <1355300590-2390-3-git-send-email-amwang@redhat.com>
References: <1355300590-2390-1-git-send-email-amwang@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>, Stephen Hemminger <shemminger@vyatta.com>,
	bridge@lists.linux-foundation.org, Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1355300590-2390-1-git-send-email-amwang@redhat.com>
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

From: Cong Wang <amwang@redhat.com>

This patch implements:

	bridge mdb { add | del } dev DEV port PORT grp GROUP

Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 bridge/mdb.c              |   76 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/if_bridge.h |    8 +++++
 include/linux/rtnetlink.h |    4 ++
 3 files changed, 88 insertions(+), 0 deletions(-)

diff --git a/bridge/mdb.c b/bridge/mdb.c
index 390d7f6..4d8a896 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -28,6 +28,7 @@ int filter_index;
 
 static void usage(void)
 {
+	fprintf(stderr, "Usage: bridge mdb { add | del } dev DEV port PORT grp GROUP\n");
 	fprintf(stderr, "       bridge mdb {show} [ dev DEV ]\n");
 	exit(-1);
 }
@@ -153,11 +154,86 @@ static int mdb_show(int argc, char **argv)
 	return 0;
 }
 
+static int mdb_modify(int cmd, int flags, int argc, char **argv)
+{
+	struct {
+		struct nlmsghdr 	n;
+		struct br_port_msg	bpm;
+		char   			buf[1024];
+	} req;
+	struct br_mdb_entry entry;
+	char *d = NULL, *p = NULL, *grp = NULL;
+
+	memset(&req, 0, sizeof(req));
+	memset(&entry, 0, sizeof(entry));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct br_port_msg));
+	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
+	req.n.nlmsg_type = cmd;
+	req.bpm.family = PF_BRIDGE;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			d = *argv;
+		} else if (strcmp(*argv, "grp") == 0) {
+			NEXT_ARG();
+			grp = *argv;
+		} else {
+			if (strcmp(*argv, "port") == 0) {
+				NEXT_ARG();
+				p = *argv;
+			}
+			if (matches(*argv, "help") == 0)
+				usage();
+		}
+		argc--; argv++;
+	}
+
+	if (d == NULL || grp == NULL || p == NULL) {
+		fprintf(stderr, "Device, group address and port name are required arguments.\n");
+		exit(-1);
+	}
+
+	req.bpm.ifindex = ll_name_to_index(d);
+	if (req.bpm.ifindex == 0) {
+		fprintf(stderr, "Cannot find device \"%s\"\n", d);
+		return -1;
+	}
+
+	entry.ifindex = ll_name_to_index(p);
+	if (entry.ifindex == 0) {
+		fprintf(stderr, "Cannot find device \"%s\"\n", p);
+		return -1;
+	}
+
+	if (!inet_pton(AF_INET, grp, &entry.addr.u.ip4)) {
+		if (!inet_pton(AF_INET6, grp, &entry.addr.u.ip6)) {
+			fprintf(stderr, "Invalid address \"%s\"\n", grp);
+			return -1;
+		} else
+			entry.addr.proto = htons(ETH_P_IPV6);
+	} else
+		entry.addr.proto = htons(ETH_P_IP);
+
+	addattr_l(&req.n, sizeof(req), MDBA_SET_ENTRY, &entry, sizeof(entry));
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+		exit(2);
+
+	return 0;
+}
+
 int do_mdb(int argc, char **argv)
 {
 	ll_init_map(&rth);
 
 	if (argc > 0) {
+		if (matches(*argv, "add") == 0)
+			return mdb_modify(RTM_NEWMDB, NLM_F_CREATE|NLM_F_EXCL, argc-1, argv+1);
+		if (matches(*argv, "delete") == 0)
+			return mdb_modify(RTM_DELMDB, 0, argc-1, argv+1);
+
 		if (matches(*argv, "show") == 0 ||
 		    matches(*argv, "lst") == 0 ||
 		    matches(*argv, "list") == 0)
diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 151a8bb..b3b6a67 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -157,6 +157,7 @@ enum {
 #define MDBA_ROUTER_MAX (__MDBA_ROUTER_MAX - 1)
 
 struct br_port_msg {
+	__u8  family;
 	__u32 ifindex;
 };
 
@@ -171,4 +172,11 @@ struct br_mdb_entry {
 	} addr;
 };
 
+enum {
+	MDBA_SET_ENTRY_UNSPEC,
+	MDBA_SET_ENTRY,
+	__MDBA_SET_ENTRY_MAX,
+};
+#define MDBA_SET_ENTRY_MAX (__MDBA_SET_ENTRY_MAX - 1)
+
 #endif /* _LINUX_IF_BRIDGE_H */
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index c82a159..3ea85dc 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -125,6 +125,10 @@ enum {
 	RTM_GETNETCONF = 82,
 #define RTM_GETNETCONF RTM_GETNETCONF
 
+	RTM_NEWMDB = 84,
+#define RTM_NEWMDB RTM_NEWMDB
+	RTM_DELMDB = 85,
+#define RTM_DELMDB RTM_DELMDB
 	RTM_GETMDB = 86,
 #define RTM_GETMDB RTM_GETMDB
 
-- 
1.7.7.6
