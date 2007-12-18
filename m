From: Vitaliy Gusev <vgusev@openvz.org>
Subject: [PATCH 2/2] Module for ip utility to support veth device
Date: Tue, 18 Dec 2007 15:15:38 +0300
Message-ID: <200712181515.38565.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:27006 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754189AbXLRMOP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 07:14:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


module link_veth

Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>

---

 link_veth.c |   76 +++++++++++++++++++-----------------------------------------
 veth.h      |    2 -
 2 files changed, 25 insertions(+), 53 deletions(-)

diff --git a/ip/link_veth.c b/ip/link_veth.c
index a4764f2..226b4ef 100644
--- a/ip/link_veth.c
+++ b/ip/link_veth.c
@@ -10,78 +10,52 @@
  *
  */
 
-#include <stdio.h>
 #include <string.h>
 
 #include "utils.h"
 #include "ip_common.h"
 #include "veth.h"
 
-#define ETH_ALEN	6
+#define	IFNAMSIZ	16
 
 static void usage(void)
 {
-	printf("Usage: ip link add ... type veth "
-			"[peer <peer-name>] [mac <mac>] [peer_mac <mac>]\n");
+	printf("Usage: ip link <options> type veth "
+		"[peer <options>]\nTo get <options> type "
+		"'ip link add help'\n");
 }
 
 static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 		struct nlmsghdr *hdr)
 {
-	__u8 mac[ETH_ALEN];
+	char *name, *type, *link, *dev;
+	int err, len;
+	struct rtattr * data;
 
-	for (; argc != 0; argv++, argc--) {
-		if (strcmp(*argv, "peer") == 0) {
-			argv++;
-			argc--;
-			if (argc == 0) {
-				usage();
-				return -1;
-			}
-
-			addattr_l(hdr, 1024, VETH_INFO_PEER,
-					*argv, strlen(*argv));
-
-			continue;
-		}
-
-		if (strcmp(*argv, "mac") == 0) {
-			argv++;
-			argc--;
-			if (argc == 0) {
-				usage();
-				return -1;
-			}
-
-			if (hexstring_a2n(*argv, mac, sizeof(mac)) == NULL)
-				return -1;
-
-			addattr_l(hdr, 1024, VETH_INFO_MAC,
-					mac, ETH_ALEN);
-			continue;
-		}
+	if (strcmp(argv[0], "peer") != 0) {
+		usage();
+		return -1;
+	}
 
-		if (strcmp(*argv, "peer_mac") == 0) {
-			argv++;
-			argc--;
-			if (argc == 0) {
-				usage();
-				return -1;
-			}
+	data = NLMSG_TAIL(hdr);
+	addattr_l(hdr, 1024, VETH_INFO_PEER, NULL, 0);
 
-			if (hexstring_a2n(*argv, mac, sizeof(mac)) == NULL)
-				return -1;
+	hdr->nlmsg_len += sizeof(struct ifinfomsg);
 
-			addattr_l(hdr, 1024, VETH_INFO_PEER_MAC,
-					mac, ETH_ALEN);
-			continue;
-		}
+	err = iplink_parse(argc - 1, argv + 1, (struct iplink_req *)hdr,
+			&name, &type, &link, &dev);
+	if (err < 0)
+		return err;
 
-		usage();
-		return -1;
+	if (name) {
+		len = strlen(name) + 1;
+		if (len > IFNAMSIZ)
+			invarg("\"name\" too long\n", *argv);
+		addattr_l(hdr, 1024, IFLA_IFNAME, name, len);
 	}
 
-	return 0;
+	data->rta_len = (void *)NLMSG_TAIL(hdr) - (void *)data;
+	return argc - 1 - err;
 }
 
 struct link_util veth_link_util = {
diff --git a/ip/veth.h b/ip/veth.h
index b84a530..aa2e6f9 100644
--- a/ip/veth.h
+++ b/ip/veth.h
@@ -3,9 +3,7 @@
 
 enum {
 	VETH_INFO_UNSPEC,
-	VETH_INFO_MAC,
 	VETH_INFO_PEER,
-	VETH_INFO_PEER_MAC,
 
 	__VETH_INFO_MAX
 #define VETH_INFO_MAX	(__VETH_INFO_MAX - 1)
-- 
Thank,
Vitaliy Gusev
