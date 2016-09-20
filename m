From: Anton Aksola <aakso@iki.fi>
Subject: [PATCH v3] iproute2: build nsid-name cache only for commands that
 need it
Date: Tue, 20 Sep 2016 06:01:27 +0000
Message-ID: <20160920060123.GA17211@toys.tundra.dog-lvm.novalocal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.dichtel@6wind.com, vadim4j@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-78.nebula.fi ([83.145.220.78]:47461 "EHLO smtp.nebula.fi"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753959AbcITGBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 02:01:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The calling of netns_map_init() before command parsing introduced
a performance issue with large number of namespaces.

As commands such as add, del and exec do not need to iterate through
/var/run/netns it would be good not no build the cache before executing
these commands.

Example:
unpatched:
time seq 1 1000 | xargs -n 1 ip netns add

real    0m16.832s
user    0m1.350s
sys    0m15.029s

patched:
time seq 1 1000 | xargs -n 1 ip netns add

real    0m3.859s
user    0m0.132s
sys    0m3.205s

Signed-off-by: Anton Aksola <aakso@iki.fi>
---
 ip/ip_common.h                            |  1 +
 ip/ipmonitor.c                            |  1 +
 ip/ipnetns.c                              | 31 ++++++++++++++++++++++---------
 testsuite/tests/ip/netns/set_nsid.t       | 22 ++++++++++++++++++++++
 testsuite/tests/ip/netns/set_nsid_batch.t | 18 ++++++++++++++++++
 5 files changed, 64 insertions(+), 9 deletions(-)
 create mode 100755 testsuite/tests/ip/netns/set_nsid.t
 create mode 100755 testsuite/tests/ip/netns/set_nsid_batch.t

diff --git a/ip/ip_common.h b/ip/ip_common.h
index 93ff5bc..fabc4b5 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -31,6 +31,7 @@ int print_netconf(const struct sockaddr_nl *who,
 		  struct rtnl_ctrl_data *ctrl,
 		  struct nlmsghdr *n, void *arg);
 void netns_map_init(void);
+void netns_nsid_socket_init(void);
 int print_nsid(const struct sockaddr_nl *who,
 	       struct nlmsghdr *n, void *arg);
 int do_ipaddr(int argc, char **argv);
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 2090a45..c892b8f 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -301,6 +301,7 @@ int do_ipmonitor(int argc, char **argv)
 		exit(1);
 
 	ll_init_map(&rth);
+	netns_nsid_socket_init();
 	netns_map_init();
 
 	if (rtnl_listen(&rth, accept_msg, stdout) < 0)
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index af87065..6b42751 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -194,6 +194,18 @@ static void netns_map_del(struct nsid_cache *c)
 	free(c);
 }
 
+void netns_nsid_socket_init(void)
+{
+	if (rtnsh.fd > -1 || !ipnetns_have_nsid())
+		return;
+
+	if (rtnl_open(&rtnsh, 0) < 0) {
+		fprintf(stderr, "Cannot open rtnetlink\n");
+		exit(1);
+	}
+
+}
+
 void netns_map_init(void)
 {
 	static int initialized;
@@ -204,11 +216,6 @@ void netns_map_init(void)
 	if (initialized || !ipnetns_have_nsid())
 		return;
 
-	if (rtnl_open(&rtnsh, 0) < 0) {
-		fprintf(stderr, "Cannot open rtnetlink\n");
-		exit(1);
-	}
-
 	dir = opendir(NETNS_RUN_DIR);
 	if (!dir)
 		return;
@@ -775,17 +782,23 @@ static int netns_monitor(int argc, char **argv)
 
 int do_netns(int argc, char **argv)
 {
-	netns_map_init();
+	netns_nsid_socket_init();
 
-	if (argc < 1)
+	if (argc < 1) {
+		netns_map_init();
 		return netns_list(0, NULL);
+	}
 
 	if ((matches(*argv, "list") == 0) || (matches(*argv, "show") == 0) ||
-	    (matches(*argv, "lst") == 0))
+	    (matches(*argv, "lst") == 0)) {
+		netns_map_init();
 		return netns_list(argc-1, argv+1);
+	}
 
-	if ((matches(*argv, "list-id") == 0))
+	if ((matches(*argv, "list-id") == 0)) {
+		netns_map_init();
 		return netns_list_id(argc-1, argv+1);
+	}
 
 	if (matches(*argv, "help") == 0)
 		return usage();
diff --git a/testsuite/tests/ip/netns/set_nsid.t b/testsuite/tests/ip/netns/set_nsid.t
new file mode 100755
index 0000000..606d45a
--- /dev/null
+++ b/testsuite/tests/ip/netns/set_nsid.t
@@ -0,0 +1,22 @@
+#!/bin/sh
+
+source lib/generic.sh
+
+ts_log "[Testing netns nsid]"
+
+NS=testnsid
+NSID=99
+
+ts_ip "$0" "Add new netns $NS" netns add $NS
+ts_ip "$0" "Set $NS nsid to $NSID" netns set $NS $NSID
+
+ts_ip "$0" "List netns" netns list
+test_on "$NS \(id: $NSID\)"
+
+ts_ip "$0" "List netns without explicit list or show" netns
+test_on "$NS \(id: $NSID\)"
+
+ts_ip "$0" "List nsid" netns list-id
+test_on "$NSID \(iproute2 netns name: $NS\)"
+
+ts_ip "$0" "Delete netns $NS" netns del $NS
diff --git a/testsuite/tests/ip/netns/set_nsid_batch.t b/testsuite/tests/ip/netns/set_nsid_batch.t
new file mode 100755
index 0000000..abb3f1b
--- /dev/null
+++ b/testsuite/tests/ip/netns/set_nsid_batch.t
@@ -0,0 +1,18 @@
+#!/bin/sh
+
+source lib/generic.sh
+
+ts_log "[Testing netns nsid in batch mode]"
+
+NS=testnsid
+NSID=99
+BATCHFILE=`mktemp`
+
+echo "netns add $NS" >> $BATCHFILE
+echo "netns set $NS $NSID" >> $BATCHFILE
+echo "netns list-id" >> $BATCHFILE
+ts_ip "$0" "Add ns, set nsid and list in batch mode" -b $BATCHFILE
+test_on "nsid $NSID \(iproute2 netns name: $NS\)"
+rm -f $BATCHFILE
+
+ts_ip "$0" "Delete netns $NS" netns del $NS
-- 
1.8.3.1
