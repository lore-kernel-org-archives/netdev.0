From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next] bridge: vlan: add support to display per-vlan statistics
Date: Mon, 20 Jun 2016 12:13:19 +0200
Message-ID: <1466417599-12940-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35125 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbcFTKOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 06:14:11 -0400
Received: by mail-wm0-f52.google.com with SMTP id v199so62532657wmv.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 03:13:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the -statistics (-s) argument to the bridge
vlan show command which will display the per-vlan statistics and the bridge
device each vlan belongs to. The show command filtering options are both
supported, also the man page is updated to explain the new option.
This patch uses the new RTM_GETSTATS interface with a filter_mask to dump
only the bridge vlans. Later we can add support for using the per-device
dump and filter it in the kernel instead.

Example:
$ bridge -s vlan
port	vlan id	stats
br0	 1	 RX: 33724730 bytes 492075 packets TX: 67409922 bytes 984029 packets
	 100	 RX: 0 bytes 0 packets TX: 0 bytes 0 packets
	 200	 RX: 0 bytes 0 packets TX: 0 bytes 0 packets
	 300	 RX: 0 bytes 0 packets TX: 0 bytes 0 packets
	 301	 RX: 169562135 bytes 790877 packets TX: 169550926 bytes 790824 packets
br1	 1	 RX: 0 bytes 0 packets TX: 0 bytes 0 packets

Note that it will print the per-vlan statistics for all vlans in a bridge
even if the vlan is only added to ports. Later when we add per-port
per-vlan statistics support, we'll be able to print the exact ports each
vlan belongs to, not only the bridge.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 bridge/vlan.c        | 103 ++++++++++++++++++++++++++++++++++++++++++++-------
 include/libnetlink.h |   8 ++++
 lib/libnetlink.c     |  20 ++++++++++
 man/man8/bridge.8    |   6 +++
 4 files changed, 123 insertions(+), 14 deletions(-)

diff --git a/bridge/vlan.c b/bridge/vlan.c
index 717025ae6eec..b94630c17021 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -17,7 +17,7 @@ static unsigned int filter_index, filter_vlan;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge vlan { add | del } vid VLAN_ID dev DEV [ pvid] [ untagged ]\n");
+	fprintf(stderr, "Usage: bridge vlan { add | del } vid VLAN_ID dev DEV [ pvid ] [ untagged ]\n");
 	fprintf(stderr, "                                                     [ self ] [ master ]\n");
 	fprintf(stderr, "       bridge vlan { show } [ dev DEV ] [ vid VLAN_ID ]\n");
 	exit(-1);
@@ -236,6 +236,63 @@ static int print_vlan(const struct sockaddr_nl *who,
 	return 0;
 }
 
+static void print_one_vlan_stats(FILE *fp,
+				 const struct bridge_vlan_xstats *vstats,
+				 int ifindex)
+{
+	if (filter_vlan) {
+		if (filter_vlan != vstats->vid)
+			return;
+		fprintf(fp, "%s", ll_index_to_name(ifindex));
+	}
+	fprintf(fp, "\t %hu\t RX: %llu bytes %llu packets TX: %llu bytes %llu packets\n",
+		vstats->vid, vstats->rx_bytes, vstats->rx_packets,
+		vstats->tx_bytes, vstats->tx_packets);
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
+	if (!filter_vlan)
+		fprintf(fp, "%s", ll_index_to_name(ifsm->ifindex));
+	for (i = RTA_DATA(list); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		if (i->rta_type != BRIDGE_XSTATS_VLAN)
+			continue;
+		print_one_vlan_stats(fp, RTA_DATA(i), ifsm->ifindex);
+	}
+	fflush(fp);
+	return 0;
+}
+
 static int vlan_show(int argc, char **argv)
 {
 	char *filter_dev = NULL;
@@ -263,24 +320,41 @@ static int vlan_show(int argc, char **argv)
 		}
 	}
 
-	if (rtnl_wilddump_req_filter(&rth, PF_BRIDGE, RTM_GETLINK,
-				    (compress_vlans ?
-				    RTEXT_FILTER_BRVLAN_COMPRESSED :
-				    RTEXT_FILTER_BRVLAN)) < 0) {
-		perror("Cannont send dump request");
-		exit(1);
-	}
+	if (!show_stats) {
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
+		printf("port\tvlan id\tstats\n");
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
@@ -296,8 +370,9 @@ int do_vlan(int argc, char **argv)
 			return vlan_show(argc-1, argv+1);
 		if (matches(*argv, "help") == 0)
 			usage();
-	} else
+	} else {
 		return vlan_show(0, NULL);
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
index 08e8a5bf5a08..dd7905db97e9 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -565,6 +565,12 @@ flags are ignored.
 
 This command displays the current VLAN filter table.
 
+.PP
+With the
+.B -statistics
+option, the command displays per-vlan traffic statistics and the bridge device
+each vlan belongs to.
+
 .SH bridge monitor - state monitoring
 
 The
-- 
2.1.4
