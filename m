From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next 2/3] iplink: bridge: add support for displaying xstats
Date: Wed, 15 Feb 2017 15:23:12 +0100
Message-ID: <1487168593-31321-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1487168593-31321-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38536 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751108AbdBOOX2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 09:23:28 -0500
Received: by mail-wm0-f43.google.com with SMTP id r141so41838356wmg.1
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 06:23:27 -0800 (PST)
In-Reply-To: <1487168593-31321-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the new parse/print_ifla_xstats callbacks and use them to
print the per-bridge multicast stats.
Example:
$ ip link xstats type bridge
br0
                    IGMP queries:
                      RX: v1 0 v2 0 v3 0
                      TX: v1 0 v2 0 v3 0
                    IGMP reports:
                      RX: v1 0 v2 0 v3 0
                      TX: v1 0 v2 0 v3 0
                    IGMP leaves: RX: 0 TX: 0
                    IGMP parse errors: 0
                    MLD queries:
                      RX: v1 0 v2 0
                      TX: v1 0 v2 0
                    MLD reports:
                      RX: v1 0 v2 0
                      TX: v1 0 v2 0
                    MLD leaves: RX: 0 TX: 0
                    MLD parse errors: 0

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 153 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 153 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index a17ff3555488..62ceee6b571e 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -12,13 +12,19 @@
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
+#include <netinet/in.h>
 #include <linux/if_link.h>
+#include <linux/if_bridge.h>
 #include <netinet/ether.h>
+#include <net/if.h>
 
 #include "rt_names.h"
 #include "utils.h"
 #include "ip_common.h"
 
+static unsigned int xstats_print_attr;
+static int filter_index;
+
 static void print_explain(FILE *f)
 {
 	fprintf(f,
@@ -582,10 +588,157 @@ static void bridge_print_help(struct link_util *lu, int argc, char **argv,
 	print_explain(f);
 }
 
+static void bridge_print_xstats_help(struct link_util *lu, FILE *f)
+{
+	fprintf(f, "Usage: ... %s [ igmp ] [ dev DEVICE ]\n", lu->id);
+}
+
+static void bridge_print_stats_attr(FILE *f, struct rtattr *attr, int ifindex)
+{
+	struct rtattr *brtb[LINK_XSTATS_TYPE_MAX+1];
+	struct br_mcast_stats *mstats;
+	struct rtattr *i, *list;
+	const char *ifname = "";
+	int rem;
+
+	parse_rtattr(brtb, LINK_XSTATS_TYPE_MAX, RTA_DATA(attr),
+	RTA_PAYLOAD(attr));
+	if (!brtb[LINK_XSTATS_TYPE_BRIDGE])
+		return;
+
+	list = brtb[LINK_XSTATS_TYPE_BRIDGE];
+	rem = RTA_PAYLOAD(list);
+	for (i = RTA_DATA(list); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		if (xstats_print_attr && i->rta_type != xstats_print_attr)
+			continue;
+		switch (i->rta_type) {
+		case BRIDGE_XSTATS_MCAST:
+			mstats = RTA_DATA(i);
+			ifname = ll_index_to_name(ifindex);
+			fprintf(f, "%-16s\n", ifname);
+			fprintf(f, "%-16s    IGMP queries:\n", "");
+			fprintf(f, "%-16s      RX: v1 %llu v2 %llu v3 %llu\n",
+				"",
+				mstats->igmp_v1queries[BR_MCAST_DIR_RX],
+				mstats->igmp_v2queries[BR_MCAST_DIR_RX],
+				mstats->igmp_v3queries[BR_MCAST_DIR_RX]);
+			fprintf(f, "%-16s      TX: v1 %llu v2 %llu v3 %llu\n",
+				"",
+				mstats->igmp_v1queries[BR_MCAST_DIR_TX],
+				mstats->igmp_v2queries[BR_MCAST_DIR_TX],
+				mstats->igmp_v3queries[BR_MCAST_DIR_TX]);
+
+			fprintf(f, "%-16s    IGMP reports:\n", "");
+			fprintf(f, "%-16s      RX: v1 %llu v2 %llu v3 %llu\n",
+				"",
+				mstats->igmp_v1reports[BR_MCAST_DIR_RX],
+				mstats->igmp_v2reports[BR_MCAST_DIR_RX],
+				mstats->igmp_v3reports[BR_MCAST_DIR_RX]);
+			fprintf(f, "%-16s      TX: v1 %llu v2 %llu v3 %llu\n",
+				"",
+				mstats->igmp_v1reports[BR_MCAST_DIR_TX],
+				mstats->igmp_v2reports[BR_MCAST_DIR_TX],
+				mstats->igmp_v3reports[BR_MCAST_DIR_TX]);
+
+			fprintf(f, "%-16s    IGMP leaves: RX: %llu TX: %llu\n",
+				"",
+				mstats->igmp_leaves[BR_MCAST_DIR_RX],
+				mstats->igmp_leaves[BR_MCAST_DIR_TX]);
+
+			fprintf(f, "%-16s    IGMP parse errors: %llu\n",
+				"", mstats->igmp_parse_errors);
+
+			fprintf(f, "%-16s    MLD queries:\n", "");
+			fprintf(f, "%-16s      RX: v1 %llu v2 %llu\n",
+				"",
+				mstats->mld_v1queries[BR_MCAST_DIR_RX],
+				mstats->mld_v2queries[BR_MCAST_DIR_RX]);
+			fprintf(f, "%-16s      TX: v1 %llu v2 %llu\n",
+				"",
+				mstats->mld_v1queries[BR_MCAST_DIR_TX],
+				mstats->mld_v2queries[BR_MCAST_DIR_TX]);
+
+			fprintf(f, "%-16s    MLD reports:\n", "");
+			fprintf(f, "%-16s      RX: v1 %llu v2 %llu\n",
+				"",
+				mstats->mld_v1reports[BR_MCAST_DIR_RX],
+				mstats->mld_v2reports[BR_MCAST_DIR_RX]);
+			fprintf(f, "%-16s      TX: v1 %llu v2 %llu\n",
+				"",
+				mstats->mld_v1reports[BR_MCAST_DIR_TX],
+				mstats->mld_v2reports[BR_MCAST_DIR_TX]);
+
+			fprintf(f, "%-16s    MLD leaves: RX: %llu TX: %llu\n",
+				"",
+				mstats->mld_leaves[BR_MCAST_DIR_RX],
+				mstats->mld_leaves[BR_MCAST_DIR_TX]);
+
+			fprintf(f, "%-16s    MLD parse errors: %llu\n",
+				"", mstats->mld_parse_errors);
+			break;
+		}
+	}
+}
+
+static int bridge_print_xstats(const struct sockaddr_nl *who,
+			       struct nlmsghdr *n, void *arg)
+{
+	struct if_stats_msg *ifsm = NLMSG_DATA(n);
+	struct rtattr *tb[IFLA_STATS_MAX+1];
+	int len = n->nlmsg_len;
+	FILE *fp = arg;
+
+	len -= NLMSG_LENGTH(sizeof(*ifsm));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+	if (filter_index && filter_index != ifsm->ifindex)
+		return 0;
+
+	parse_rtattr(tb, IFLA_STATS_MAX, IFLA_STATS_RTA(ifsm), len);
+	if (tb[IFLA_STATS_LINK_XSTATS])
+		bridge_print_stats_attr(fp, tb[IFLA_STATS_LINK_XSTATS],
+					ifsm->ifindex);
+
+	if (tb[IFLA_STATS_LINK_XSTATS_SLAVE])
+		bridge_print_stats_attr(fp, tb[IFLA_STATS_LINK_XSTATS_SLAVE],
+					ifsm->ifindex);
+
+	return 0;
+}
+
+static int bridge_parse_xstats(struct link_util *lu, int argc, char **argv)
+{
+	while (argc > 0) {
+		if (strcmp(*argv, "igmp") == 0 || strcmp(*argv, "mcast") == 0) {
+			xstats_print_attr = BRIDGE_XSTATS_MCAST;
+		} else if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			filter_index = if_nametoindex(*argv);
+			if (filter_index == 0) {
+				fprintf(stderr, "Cannot find device \"%s\"\n",
+					*argv);
+				return -1;
+			}
+		} else if (strcmp(*argv, "help") == 0) {
+			bridge_print_xstats_help(lu, stdout);
+			exit(0);
+		} else {
+			invarg("unknown attribute", *argv);
+		}
+		argc--; argv++;
+	}
+
+	return 0;
+}
+
 struct link_util bridge_link_util = {
 	.id		= "bridge",
 	.maxattr	= IFLA_BR_MAX,
 	.parse_opt	= bridge_parse_opt,
 	.print_opt	= bridge_print_opt,
 	.print_help     = bridge_print_help,
+	.parse_ifla_xstats = bridge_parse_xstats,
+	.print_ifla_xstats = bridge_print_xstats,
 };
-- 
2.1.4
