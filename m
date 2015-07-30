From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 net-next] bridge: mdb: add deleted when monitoring delmdb event
Date: Thu, 30 Jul 2015 11:30:32 +0200
Message-ID: <1438248632-6270-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33063 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295AbbG3Jan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 05:30:43 -0400
Received: by wicmv11 with SMTP id mv11so13306553wic.0
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 02:30:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Before this patch both addmdb and delmdb events were printed the same,
now we'll get a "Deleted" string in front when delmdb is received.
Before:
$ bridge mdb add dev br0 port eth3 grp 239.0.0.1
(monitor) dev br0 port eth3 grp 239.0.0.1 temp
$ bridge mdb del dev br0 port eth3 grp 239.0.0.1
(monitor) dev br0 port eth3 grp 239.0.0.1 temp
^^ No way to differentiate between both events.

After:
$ bridge mdb add dev br0 port eth3 grp 239.0.0.1
(monitor) dev br0 port eth3 grp 239.0.0.1 temp
$ bridge mdb del dev br0 port eth3 grp 239.0.0.1
(monitor) Deleted dev br0 port eth3 grp 239.0.0.1 temp

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 bridge/mdb.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/bridge/mdb.c b/bridge/mdb.c
index 1b34f69b92d4..b14bd019c5c5 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -48,7 +48,8 @@ static void br_print_router_ports(FILE *f, struct rtattr *attr)
 	fprintf(f, "\n");
 }
 
-static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e)
+static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e,
+			    struct nlmsghdr *n)
 {
 	SPRINT_BUF(abuf);
 	const void *src;
@@ -57,6 +58,8 @@ static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e)
 	af = e->addr.proto == htons(ETH_P_IP) ? AF_INET : AF_INET6;
 	src = af == AF_INET ? (const void *)&e->addr.u.ip4 :
 			      (const void *)&e->addr.u.ip6;
+	if (n->nlmsg_type == RTM_DELMDB)
+		fprintf(f, "Deleted ");
 	fprintf(f, "dev %s port %s grp %s %s", ll_index_to_name(ifindex),
 		ll_index_to_name(e->ifindex),
 		inet_ntop(af, src, abuf, sizeof(abuf)),
@@ -66,7 +69,8 @@ static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e)
 	fprintf(f, "\n");
 }
 
-static void br_print_mdb_entry(FILE *f, int ifindex, struct rtattr *attr)
+static void br_print_mdb_entry(FILE *f, int ifindex, struct rtattr *attr,
+			       struct nlmsghdr *n)
 {
 	struct rtattr *i;
 	int rem;
@@ -75,7 +79,7 @@ static void br_print_mdb_entry(FILE *f, int ifindex, struct rtattr *attr)
 	rem = RTA_PAYLOAD(attr);
 	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
 		e = RTA_DATA(i);
-		print_mdb_entry(f, ifindex, e);
+		print_mdb_entry(f, ifindex, e, n);
 	}
 }
 
@@ -108,7 +112,7 @@ int print_mdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		int rem = RTA_PAYLOAD(tb[MDBA_MDB]);
 
 		for (i = RTA_DATA(tb[MDBA_MDB]); RTA_OK(i, rem); i = RTA_NEXT(i, rem))
-			br_print_mdb_entry(fp, r->ifindex, i);
+			br_print_mdb_entry(fp, r->ifindex, i, n);
 	}
 
 	if (tb[MDBA_ROUTER]) {
-- 
2.4.3
