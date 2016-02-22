From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 net-next v2] bridge: mdb: add user-space support for extended attributes
Date: Mon, 22 Feb 2016 15:16:13 +0100
Message-ID: <1456150573-28641-1-git-send-email-razor@blackwall.org>
References: <1456149621-27335-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37270 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480AbcBVOQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 09:16:18 -0500
Received: by mail-wm0-f41.google.com with SMTP id g62so165691876wme.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 06:16:17 -0800 (PST)
In-Reply-To: <1456149621-27335-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Recently support was added to the kernel to be able to add more per-mdb
entry attributes via standard netlink attributes of type MDBA_MDB_EATTR_.
This patch adds support to iproute2 to parse and output these
attributes. The first exported attribute is the mdb "timer" value which
is shown only when the "-s" iproute2 arg is used.

Example:
$ bridge -s mdb show
dev br0 port eth1 grp 239.0.0.11 permanent   0.00
dev br0 port eth1 grp 239.0.0.10 temp 244.15
dev br0 port eth1 grp 239.0.0.1 temp 245.21
dev br0 port eth1 grp 239.0.0.5 temp 246.43
dev br0 port eth2 grp 239.0.0.5 temp 248.44
dev br0 port eth1 grp 239.0.0.2 temp 245.32

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
note: this patch needs updated linux/if_bridge.h header to compile

v2: use -s instead of -d and update bridge's man page

 bridge/br_common.h |  3 +++
 bridge/mdb.c       | 15 ++++++++++++---
 man/man8/bridge.8  |  5 +++++
 3 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/bridge/br_common.h b/bridge/br_common.h
index 169a162d0c01..41eb0dc38293 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -1,3 +1,6 @@
+#define MDB_RTA(r) \
+		((struct rtattr *)(((char *)(r)) + RTA_ALIGN(sizeof(struct br_mdb_entry))))
+
 extern int print_linkinfo(const struct sockaddr_nl *who,
 			  struct nlmsghdr *n,
 			  void *arg);
diff --git a/bridge/mdb.c b/bridge/mdb.c
index 24c4903542bf..09d4b2255857 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -49,7 +49,7 @@ static void br_print_router_ports(FILE *f, struct rtattr *attr)
 }
 
 static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e,
-			    struct nlmsghdr *n)
+			    struct nlmsghdr *n, struct rtattr **tb)
 {
 	SPRINT_BUF(abuf);
 	const void *src;
@@ -66,20 +66,29 @@ static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e,
 		(e->state & MDB_PERMANENT) ? "permanent" : "temp");
 	if (e->vid)
 		fprintf(f, " vid %hu", e->vid);
+	if (show_stats && tb && tb[MDBA_MDB_EATTR_TIMER]) {
+		struct timeval tv;
+
+		__jiffies_to_tv(&tv, rta_getattr_u32(tb[MDBA_MDB_EATTR_TIMER]));
+		fprintf(f, "%4i.%.2i", (int)tv.tv_sec, (int)tv.tv_usec/10000);
+	}
 	fprintf(f, "\n");
 }
 
 static void br_print_mdb_entry(FILE *f, int ifindex, struct rtattr *attr,
 			       struct nlmsghdr *n)
 {
+	struct rtattr *etb[MDBA_MDB_EATTR_MAX + 1];
+	struct br_mdb_entry *e;
 	struct rtattr *i;
 	int rem;
-	struct br_mdb_entry *e;
 
 	rem = RTA_PAYLOAD(attr);
 	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
 		e = RTA_DATA(i);
-		print_mdb_entry(f, ifindex, e, n);
+		parse_rtattr(etb, MDBA_MDB_EATTR_MAX, MDB_RTA(RTA_DATA(i)),
+			     RTA_PAYLOAD(i) - RTA_ALIGN(sizeof(*e)));
+		print_mdb_entry(f, ifindex, e, n, etb);
 	}
 }
 
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index efd416e71d55..0e98edf4762f 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -503,6 +503,11 @@ With the
 option, the command becomes verbose. It prints out the ports known to have
 a connected router.
 
+.PP
+With the
+.B -statistics
+option, the command displays timer values for mdb entries.
+
 .SH bridge vlan - VLAN filter list
 
 .B vlan
-- 
2.4.3
