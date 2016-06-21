From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v2] bridge: vlan: add support to display per-vlan statistics
Date: Tue, 21 Jun 2016 20:07:10 +0200
Message-ID: <1466532430-29090-1-git-send-email-nikolay@cumulusnetworks.com>
References: <1466417599-12940-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33046 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbcFUSNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 14:13:32 -0400
Received: by mail-lf0-f47.google.com with SMTP id f6so35980356lfg.0
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 11:13:26 -0700 (PDT)
In-Reply-To: <1466417599-12940-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the stats argument to the bridge
vlan command which will display the per-vlan statistics and the bridge
device each vlan belongs to. The supported command filtering options are
dev and vid. Also the man page is updated to explain the new option.
This patch uses the new RTM_GETSTATS interface with a filter_mask to dump
only the bridge vlans. Later we can add support for using the per-device
dump and filter it in the kernel instead.

Example:
$ bridge vlan stats
port             vlan id
br0               1
                    RX: 34816114 bytes 495195 packets
                    TX: 68501306 bytes 987149 packets
                  100
                    RX: 0 bytes 0 packets
                    TX: 0 bytes 0 packets
                  200
                    RX: 0 bytes 0 packets
                    TX: 0 bytes 0 packets
                  300
                    RX: 0 bytes 0 packets
                    TX: 0 bytes 0 packets
                  301
                    RX: 169562135 bytes 790877 packets
                    TX: 169550926 bytes 790824 packets
br1               1
                    RX: 0 bytes 0 packets
                    TX: 0 bytes 0 packets

Note that it will print the per-vlan statistics for all vlans in a bridge
even if the vlan is only added to ports. Later when we add per-port
per-vlan statistics support, we'll be able to print the exact ports each
vlan belongs to, not only the bridge.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: Change the output format as per Stephen's comment and change the -s use
to a subcommand called stats in order to have a different format than show,
update the man page appropriately.

 bridge/vlan.c        | 117 +++++++++++++++++++++++++++++++++++++++++++--------
 include/libnetlink.h |   8 ++++
 lib/libnetlink.c     |  20 +++++++++
 man/man8/bridge.8    |  23 +++++++++-
 4 files changed, 150 insertions(+), 18 deletions(-)

diff --git a/bridge/vlan.c b/bridge/vlan.c
index 717025ae6eec..e251a5cae917 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -14,12 +14,14 @@
 #include "utils.h"
 
 static unsigned int filter_index, filter_vlan;
+static int last_ifidx = -1;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge vlan { add | del } vid VLAN_ID dev DEV [ pvid] [ untagged ]\n");
+	fprintf(stderr, "Usage: bridge vlan { add | del } vid VLAN_ID dev DEV [ pvid ] [ untagged ]\n");
 	fprintf(stderr, "                                                     [ self ] [ master ]\n");
 	fprintf(stderr, "       bridge vlan { show } [ dev DEV ] [ vid VLAN_ID ]\n");
+	fprintf(stderr, "       bridge vlan { stats } [ dev DEV ] [ vid VLAN_ID ]\n");
 	exit(-1);
 }
 
@@ -236,7 +238,67 @@ static int print_vlan(const struct sockaddr_nl *who,
 	return 0;
 }
 
-static int vlan_show(int argc, char **argv)
+static void print_one_vlan_stats(FILE *fp,
+				 const struct bridge_vlan_xstats *vstats,
+				 int ifindex)
+{
+	const char *ifname = "";
+
+	if (filter_vlan && filter_vlan != vstats->vid)
+		return;
+	if (last_ifidx != ifindex) {
+		ifname = ll_index_to_name(ifindex);
+		last_ifidx = ifindex;
+	}
+	fprintf(fp, "%-16s  %hu\n", ifname, vstats->vid);
+	fprintf(fp, "%-16s    RX: %llu bytes %llu packets\n",
+		"", vstats->rx_bytes, vstats->rx_packets);
+	fprintf(fp, "%-16s    TX: %llu bytes %llu packets\n",
+		"", vstats->tx_bytes, vstats->tx_packets);
+}
+
+static int print_vlan_stats(const struct sockaddr_nl *who,
+			    struct nlmsghdr *n,
+			    void *arg)
+{
+	struct rtattr *tb[IFLA_STATS_MAX+1], *brtb[LINK_XSTATS_TYPE_MAX+1];
+	struct if_stats_msg *ifsm = NLMSG_DATA(n);
+	struct rtattr *i, *list;
+	int len = n->nlmsg_len;
+	FILE *fp = arg;
+	int rem;
+
+	len -= NLMSG_LENGTH(sizeof(*ifsm));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	if (filter_index && filter_index != ifsm->ifindex)
+		return 0;
+
+	parse_rtattr(tb, IFLA_STATS_MAX, IFLA_STATS_RTA(ifsm), len);
+	if (!tb[IFLA_STATS_LINK_XSTATS])
+		return 0;
+
+	parse_rtattr(brtb, LINK_XSTATS_TYPE_MAX,
+		     RTA_DATA(tb[IFLA_STATS_LINK_XSTATS]),
+		     RTA_PAYLOAD(tb[IFLA_STATS_LINK_XSTATS]));
+	if (!brtb[LINK_XSTATS_TYPE_BRIDGE])
+		return 0;
+
+	list = brtb[LINK_XSTATS_TYPE_BRIDGE];
+	rem = RTA_PAYLOAD(list);
+	for (i = RTA_DATA(list); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		if (i->rta_type != BRIDGE_XSTATS_VLAN)
+			continue;
+		print_one_vlan_stats(fp, RTA_DATA(i), ifsm->ifindex);
+	}
+	fflush(fp);
+	return 0;
+}
+
+static int vlan_show(int argc, char **argv, bool do_show_stats)
 {
 	char *filter_dev = NULL;
 
@@ -263,24 +325,41 @@ static int vlan_show(int argc, char **argv)
 		}
 	}
 
-	if (rtnl_wilddump_req_filter(&rth, PF_BRIDGE, RTM_GETLINK,
-				    (compress_vlans ?
-				    RTEXT_FILTER_BRVLAN_COMPRESSED :
-				    RTEXT_FILTER_BRVLAN)) < 0) {
-		perror("Cannont send dump request");
-		exit(1);
-	}
+	if (!do_show_stats) {
+		if (rtnl_wilddump_req_filter(&rth, PF_BRIDGE, RTM_GETLINK,
+					    (compress_vlans ?
+					    RTEXT_FILTER_BRVLAN_COMPRESSED :
+					    RTEXT_FILTER_BRVLAN)) < 0) {
+			perror("Cannont send dump request");
+			exit(1);
+		}
 
-	printf("port\tvlan ids\n");
-	if (rtnl_dump_filter(&rth, print_vlan, stdout) < 0) {
-		fprintf(stderr, "Dump ternminated\n");
-		exit(1);
+		printf("port\tvlan ids\n");
+		if (rtnl_dump_filter(&rth, print_vlan, stdout) < 0) {
+			fprintf(stderr, "Dump terminated\n");
+			exit(1);
+		}
+	} else {
+		__u32 filt_mask;
+
+		filt_mask = IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_XSTATS);
+		if (rtnl_wilddump_stats_req_filter(&rth, AF_UNSPEC,
+						   RTM_GETSTATS,
+						   filt_mask) < 0) {
+			perror("Cannont send dump request");
+			exit(1);
+		}
+
+		printf("%-16s vlan id\n", "port");
+		if (rtnl_dump_filter(&rth, print_vlan_stats, stdout) < 0) {
+			fprintf(stderr, "Dump terminated\n");
+			exit(1);
+		}
 	}
 
 	return 0;
 }
 
-
 int do_vlan(int argc, char **argv)
 {
 	ll_init_map(&rth);
@@ -293,11 +372,15 @@ int do_vlan(int argc, char **argv)
 		if (matches(*argv, "show") == 0 ||
 		    matches(*argv, "lst") == 0 ||
 		    matches(*argv, "list") == 0)
-			return vlan_show(argc-1, argv+1);
+			return vlan_show(argc-1, argv+1, false);
+		if (matches(*argv, "stats") == 0 ||
+		    matches(*argv, "statistics") == 0)
+			return vlan_show(argc-1, argv+1, true);
 		if (matches(*argv, "help") == 0)
 			usage();
-	} else
-		return vlan_show(0, NULL);
+	} else {
+		return vlan_show(0, NULL, false);
+	}
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"bridge fdb help\".\n", *argv);
 	exit(-1);
diff --git a/include/libnetlink.h b/include/libnetlink.h
index f7b85dccef36..483509ca9635 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -44,6 +44,9 @@ typedef int (*req_filter_fn_t)(struct nlmsghdr *nlh, int reqlen);
 int rtnl_wilddump_req_filter_fn(struct rtnl_handle *rth, int fam, int type,
 				req_filter_fn_t fn)
 	__attribute__((warn_unused_result));
+int rtnl_wilddump_stats_req_filter(struct rtnl_handle *rth, int fam, int type,
+				   __u32 filt_mask)
+	__attribute__((warn_unused_result));
 int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req,
 			     int len)
 	__attribute__((warn_unused_result));
@@ -202,6 +205,11 @@ int rtnl_from_file(FILE *, rtnl_listen_filter_t handler,
 #define NETNS_PAYLOAD(n)	NLMSG_PAYLOAD(n, sizeof(struct rtgenmsg))
 #endif
 
+#ifndef IFLA_STATS_RTA
+#define IFLA_STATS_RTA(r) \
+	((struct rtattr *)(((char *)(r)) + NLMSG_ALIGN(sizeof(struct if_stats_msg))))
+#endif
+
 /* User defined nlmsg_type which is used mostly for logging netlink
  * messages from dump file */
 #define NLMSG_TSTAMP	15
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 0adcbf3f6e38..f78eea38cf4a 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -157,6 +157,26 @@ int rtnl_wilddump_req_filter_fn(struct rtnl_handle *rth, int family, int type,
 	return send(rth->fd, (void*)&req, sizeof(req), 0);
 }
 
+int rtnl_wilddump_stats_req_filter(struct rtnl_handle *rth, int fam, int type,
+				   __u32 filt_mask)
+{
+	struct {
+		struct nlmsghdr nlh;
+		struct if_stats_msg ifsm;
+	} req;
+
+	memset(&req, 0, sizeof(req));
+	req.nlh.nlmsg_len = NLMSG_LENGTH(sizeof(struct if_stats_msg));
+	req.nlh.nlmsg_type = type;
+	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
+	req.nlh.nlmsg_pid = 0;
+	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
+	req.ifsm.family = fam;
+	req.ifsm.filter_mask = filt_mask;
+
+	return send(rth->fd, (void *)&req, sizeof(req), 0);
+}
+
 int rtnl_send(struct rtnl_handle *rth, const void *buf, int len)
 {
 	return send(rth->fd, buf, len, 0);
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 08e8a5bf5a08..33a9b3d774ad 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -102,6 +102,13 @@ bridge \- show / manipulate bridge addresses and devices
 .IR DEV " ]"
 
 .ti -8
+.BR "bridge vlan stats " [ "
+.B dev
+.IR DEV " ] ["
+.B vid
+.IR VID " ]"
+
+.ti -8
 .BR "bridge monitor" " [ " all " | " neigh " | " link " | " mdb " ]"
 
 .SH OPTIONS
@@ -561,10 +568,24 @@ The
 .BR "pvid " and " untagged"
 flags are ignored.
 
-.SS bridge vlan show - list vlan configuration.
+.SS bridge vlan show - list vlan configuration
 
 This command displays the current VLAN filter table.
 
+.SS bridge vlan stats - list vlan statistics
+
+This command displays the current per-VLAN traffic statistics and the bridge device
+each vlan belongs to.
+
+.TP
+.BI dev " DEV"
+the interface only whose entries should be listed. Default is to list all
+bridge interfaces.
+
+.TP
+.BI vid " VID"
+the vlan with VLAN ID which should be listed. Default is to list all vlans.
+
 .SH bridge monitor - state monitoring
 
 The
-- 
2.1.4
