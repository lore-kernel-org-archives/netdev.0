From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 v2 2/3] bridge: mdb: add support to filter by vlan id
Date: Mon, 11 Apr 2016 17:45:15 +0200
Message-ID: <1460389516-1643-3-git-send-email-nikolay@cumulusnetworks.com>
References: <570BC2FD.8010201@cumulusnetworks.com>
 <1460389516-1643-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37986 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755417AbcDKPp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 11:45:26 -0400
Received: by mail-wm0-f52.google.com with SMTP id u206so110180879wme.1
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 08:45:25 -0700 (PDT)
In-Reply-To: <1460389516-1643-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the optional keyword "vid" to bridge mdb show so the user can
request filtering by a specific vlan id. Currently the filtering is
implemented only in user-space. The argument name has been chosen to match
the add/del one - "vid".

Example:
$ bridge mdb show vid 200
dev br0 port eth2 grp 239.0.0.1 permanent vid 200

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: no change

 bridge/mdb.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/bridge/mdb.c b/bridge/mdb.c
index 842536ec003c..6c904f8e6ae8 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -24,12 +24,12 @@
 	((struct rtattr *)(((char *)(r)) + NLMSG_ALIGN(sizeof(struct br_port_msg))))
 #endif
 
-static unsigned int filter_index;
+static unsigned int filter_index, filter_vlan;
 
 static void usage(void)
 {
 	fprintf(stderr, "Usage: bridge mdb { add | del } dev DEV port PORT grp GROUP [permanent | temp] [vid VID]\n");
-	fprintf(stderr, "       bridge mdb {show} [ dev DEV ]\n");
+	fprintf(stderr, "       bridge mdb {show} [ dev DEV ] [ vid VID ]\n");
 	exit(-1);
 }
 
@@ -92,6 +92,8 @@ static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e,
 	const void *src;
 	int af;
 
+	if (filter_vlan && e->vid != filter_vlan)
+		return;
 	af = e->addr.proto == htons(ETH_P_IP) ? AF_INET : AF_INET6;
 	src = af == AF_INET ? (const void *)&e->addr.u.ip4 :
 			      (const void *)&e->addr.u.ip6;
@@ -195,6 +197,11 @@ static int mdb_show(int argc, char **argv)
 			if (filter_dev)
 				duparg("dev", *argv);
 			filter_dev = *argv;
+		} else if (strcmp(*argv, "vid") == 0) {
+			NEXT_ARG();
+			if (filter_vlan)
+				duparg("vid", *argv);
+			filter_vlan = atoi(*argv);
 		}
 		argc--; argv++;
 	}
-- 
2.4.3
