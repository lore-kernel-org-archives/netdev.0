From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v3] bridge: vlan: add support to display per-vlan statistics
Date: Thu, 25 Aug 2016 14:28:55 +0200
Message-ID: <1472128135-17318-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35212 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbcHYMaw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 08:30:52 -0400
Received: by mail-wm0-f43.google.com with SMTP id f65so236205486wmi.0
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 05:29:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the stats argument to the bridge
vlan command which will display the per-vlan statistics and the device
each vlan belongs to with its flags. The supported command filtering
options are dev and vid. Also the man page is updated to explain the new
option.
The patch uses the new RTM_GETSTATS interface with a filter_mask to dump
all bridges and ports vlans. Later we can add support for using the
per-device dump and filter it in the kernel instead.

Example:
$ bridge -s vlan show
port             vlan id
br0               1 Egress Untagged
                    RX: 2536 bytes 20 packets
                    TX: 2536 bytes 20 packets
                  101
                    RX: 43158 bytes 50 packets
                    TX: 43158 bytes 50 packets
eth1              1 Egress Untagged
                    RX: 2536 bytes 20 packets
                    TX: 2536 bytes 20 packets
                  100
                    RX: 0 bytes 0 packets
                    TX: 0 bytes 0 packets
                  101
                    RX: 43158 bytes 50 packets
                    TX: 43158 bytes 50 packets
                  102
                    RX: 16897 bytes 93 packets
                    TX: 0 bytes 0 packets

The format is the same as bridge vlan show but with stats, even though
under the hood the calls done to the kernel are different.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v3: Make the output like "bridge vlan show" and extract vlan flags, this
is only possible with the latest net-next patches and slave vlan stats
dump support, thus target net-next tree. Revert back to use the "-s" switch
as we don't need a special command anymore.

v2: Change the output format as per Stephen's comment and change the -s use
to a subcommand called stats in order to have a different format than show,
update the man page appropriately.

 bridge/vlan.c             | 154 ++++++++++++++++++++++++++++++++++++++++------
 include/libnetlink.h      |   8 +++
 include/linux/if_bridge.h |   2 +-
 lib/libnetlink.c          |  20 ++++++
 man/man8/bridge.8         |   5 ++
 5 files changed, 168 insertions(+), 21 deletions(-)

diff --git a/bridge/vlan.c b/bridge/vlan.c
index d3505b59b6fc..0b6c69077160 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -15,14 +15,16 @@
 #include "utils.h"
 
 static unsigned int filter_index, filter_vlan;
+static int last_ifidx = -1;
 
 json_writer_t *jw_global = NULL;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge vlan { add | del } vid VLAN_ID dev DEV [ pvid] [ untagged ]\n");
+	fprintf(stderr, "Usage: bridge vlan { add | del } vid VLAN_ID dev DEV [ pvid ] [ untagged ]\n");
 	fprintf(stderr, "                                                     [ self ] [ master ]\n");
 	fprintf(stderr, "       bridge vlan { show } [ dev DEV ] [ vid VLAN_ID ]\n");
+	fprintf(stderr, "       bridge vlan { stats } [ dev DEV ] [ vid VLAN_ID ]\n");
 	exit(-1);
 }
 
@@ -298,6 +300,88 @@ static int print_vlan(const struct sockaddr_nl *who,
 	return 0;
 }
 
+static void print_one_vlan_stats(FILE *fp,
+				 const struct bridge_vlan_xstats *vstats,
+				 int ifindex)
+{
+	const char *ifname = "";
+
+	if (filter_vlan && filter_vlan != vstats->vid)
+		return;
+	/* skip pure port entries, they'll be dumped via the slave stats call */
+	if ((vstats->flags & BRIDGE_VLAN_INFO_MASTER) &&
+	    !(vstats->flags & BRIDGE_VLAN_INFO_BRENTRY))
+		return;
+
+	if (last_ifidx != ifindex) {
+		ifname = ll_index_to_name(ifindex);
+		last_ifidx = ifindex;
+	}
+	fprintf(fp, "%-16s  %hu", ifname, vstats->vid);
+	if (vstats->flags & BRIDGE_VLAN_INFO_PVID)
+		fprintf(fp, " PVID");
+	if (vstats->flags & BRIDGE_VLAN_INFO_UNTAGGED)
+		fprintf(fp, " Egress Untagged");
+	fprintf(fp, "\n");
+	fprintf(fp, "%-16s    RX: %llu bytes %llu packets\n",
+		"", vstats->rx_bytes, vstats->rx_packets);
+	fprintf(fp, "%-16s    TX: %llu bytes %llu packets\n",
+		"", vstats->tx_bytes, vstats->tx_packets);
+}
+
+static void print_vlan_stats_attr(FILE *fp, struct rtattr *attr, int ifindex)
+{
+	struct rtattr *brtb[LINK_XSTATS_TYPE_MAX+1];
+	struct rtattr *i, *list;
+	int rem;
+
+	parse_rtattr(brtb, LINK_XSTATS_TYPE_MAX, RTA_DATA(attr),
+		     RTA_PAYLOAD(attr));
+	if (!brtb[LINK_XSTATS_TYPE_BRIDGE])
+		return;
+
+	list = brtb[LINK_XSTATS_TYPE_BRIDGE];
+	rem = RTA_PAYLOAD(list);
+	for (i = RTA_DATA(list); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		if (i->rta_type != BRIDGE_XSTATS_VLAN)
+			continue;
+		print_one_vlan_stats(fp, RTA_DATA(i), ifindex);
+	}
+}
+
+static int print_vlan_stats(const struct sockaddr_nl *who,
+			    struct nlmsghdr *n,
+			    void *arg)
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
+
+	if (filter_index && filter_index != ifsm->ifindex)
+		return 0;
+
+	parse_rtattr(tb, IFLA_STATS_MAX, IFLA_STATS_RTA(ifsm), len);
+
+	/* We have to check if any of the two attrs are usable */
+	if (tb[IFLA_STATS_LINK_XSTATS])
+		print_vlan_stats_attr(fp, tb[IFLA_STATS_LINK_XSTATS],
+				      ifsm->ifindex);
+
+	if (tb[IFLA_STATS_LINK_XSTATS_SLAVE])
+		print_vlan_stats_attr(fp, tb[IFLA_STATS_LINK_XSTATS_SLAVE],
+				      ifsm->ifindex);
+
+	fflush(fp);
+	return 0;
+}
+
 static int vlan_show(int argc, char **argv)
 {
 	char *filter_dev = NULL;
@@ -325,28 +409,58 @@ static int vlan_show(int argc, char **argv)
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
+					     (compress_vlans ?
+						RTEXT_FILTER_BRVLAN_COMPRESSED :
+						RTEXT_FILTER_BRVLAN)) < 0) {
+			perror("Cannont send dump request");
+			exit(1);
+		}
+		if (json_output) {
+			jw_global = jsonw_new(stdout);
+			if (!jw_global) {
+				fprintf(stderr, "Error allocation json object\n");
+				exit(1);
+			}
+			jsonw_start_object(jw_global);
+		} else {
+			printf("port\tvlan ids\n");
+		}
 
-	if (json_output) {
-		jw_global = jsonw_new(stdout);
-		if (!jw_global) {
-			fprintf(stderr, "Error allocation json object\n");
+		if (rtnl_dump_filter(&rth, print_vlan, stdout) < 0) {
+			fprintf(stderr, "Dump ternminated\n");
 			exit(1);
 		}
-		jsonw_start_object(jw_global);
 	} else {
-		printf("port\tvlan ids\n");
-	}
+		__u32 filt_mask;
 
-	if (rtnl_dump_filter(&rth, print_vlan, stdout) < 0) {
-		fprintf(stderr, "Dump ternminated\n");
-		exit(1);
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
+
+		filt_mask = IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_XSTATS_SLAVE);
+		if (rtnl_wilddump_stats_req_filter(&rth, AF_UNSPEC,
+						   RTM_GETSTATS,
+						   filt_mask) < 0) {
+			perror("Cannont send slave dump request");
+			exit(1);
+		}
+
+		if (rtnl_dump_filter(&rth, print_vlan_stats, stdout) < 0) {
+			fprintf(stderr, "Dump terminated\n");
+			exit(1);
+		}
 	}
 
 	if (jw_global) {
@@ -357,7 +471,6 @@ static int vlan_show(int argc, char **argv)
 	return 0;
 }
 
-
 int do_vlan(int argc, char **argv)
 {
 	ll_init_map(&rth);
@@ -373,8 +486,9 @@ int do_vlan(int argc, char **argv)
 			return vlan_show(argc-1, argv+1);
 		if (matches(*argv, "help") == 0)
 			usage();
-	} else
+	} else {
 		return vlan_show(0, NULL);
+	}
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"bridge vlan help\".\n", *argv);
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
diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index d9c76fe7a13b..b7393dd2b540 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -140,7 +140,7 @@ struct bridge_vlan_xstats {
 	__u64 tx_bytes;
 	__u64 tx_packets;
 	__u16 vid;
-	__u16 pad1;
+	__u16 flags;
 	__u32 pad2;
 };
 
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index a02cf9f0d3bb..22799355ed7a 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -152,6 +152,26 @@ int rtnl_wilddump_req_filter_fn(struct rtnl_handle *rth, int family, int type,
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
index bb70442219c4..7bfb068b74fe 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -570,6 +570,11 @@ flags are ignored.
 
 This command displays the current VLAN filter table.
 
+.PP
+With the
+.B -statistics
+option, the command displays per-vlan traffic statistics.
+
 .SH bridge monitor - state monitoring
 
 The
-- 
2.1.4
