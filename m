From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH iproute2] iplink: add support for afstats subcommand
Date: Thu, 9 Mar 2017 12:43:36 +0000
Message-ID: <1489063416-26930-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ahern <dsa@cumulusnetworks.com>,
        roopa <roopa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: <netdev@vger.kernel.org>, <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:52136 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750770AbdCIMpv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 07:45:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for new afstats subcommand. This uses the new
IFLA_STATS_AF_SPEC attribute of RTM_GETSTATS messages to show
per-device, AF-specific stats. At the moment the kernel only supports
MPLS AF stats, so that is all that's implemented here.

The print_num function is exposed from ipaddress.c to be used for
printing the new stats so that the human-readable option, if set, can
be respected.

Example of use:

    $ ./ip/ip -f mpls link afstats dev eth1
    3: eth1
        mpls:
            RX: bytes  packets  errors  dropped  noroute
            9016       98       0       0        0
            TX: bytes  packets  errors  dropped
            7232       113      0       0

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 ip/ip_common.h        |   2 +
 ip/ipaddress.c        |   2 +-
 ip/iplink.c           | 151 ++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip-link.8.in |  12 ++++
 4 files changed, 166 insertions(+), 1 deletion(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index abb2b8d5d537..5a39623aa21d 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -112,3 +112,5 @@ int name_is_vrf(const char *name);
 #ifndef LABEL_MAX_MASK
 #define     LABEL_MAX_MASK          0xFFFFFU
 #endif
+
+void print_num(FILE *fp, unsigned int width, uint64_t count);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 242c6ea0b4b3..b8d9c7d917fe 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -418,7 +418,7 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 		print_vf_stats64(fp, vf[IFLA_VF_STATS]);
 }
 
-static void print_num(FILE *fp, unsigned int width, uint64_t count)
+void print_num(FILE *fp, unsigned int width, uint64_t count)
 {
 	const char *prefix = "kMGTPE";
 	const unsigned int base = use_iec ? 1024 : 1000;
diff --git a/ip/iplink.c b/ip/iplink.c
index 00fed9006ea6..866ad723f4a2 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -28,6 +28,7 @@
 #include <sys/ioctl.h>
 #include <linux/sockios.h>
 #include <stdbool.h>
+#include <linux/mpls.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -99,6 +100,7 @@ void iplink_usage(void)
 		"       ip link show [ DEVICE | group GROUP ] [up] [master DEV] [vrf NAME] [type TYPE]\n");
 
 	fprintf(stderr, "\n       ip link xstats type TYPE [ ARGS ]\n");
+	fprintf(stderr, "\n       ip link afstats [ dev DEVICE ]\n");
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr,
@@ -1364,6 +1366,150 @@ static int do_set(int argc, char **argv)
 }
 #endif /* IPLINK_IOCTL_COMPAT */
 
+static void print_mpls_stats(FILE *fp, struct rtattr *attr)
+{
+	struct rtattr *mrtb[MPLS_STATS_MAX+1];
+	struct mpls_link_stats *stats;
+
+	parse_rtattr(mrtb, MPLS_STATS_MAX, RTA_DATA(attr),
+		     RTA_PAYLOAD(attr));
+	if (!mrtb[MPLS_STATS_LINK])
+		return;
+
+	stats = RTA_DATA(mrtb[MPLS_STATS_LINK]);
+
+	fprintf(fp, "    mpls:\n");
+	fprintf(fp, "        RX: bytes  packets  errors  dropped  noroute\n");
+	fprintf(fp, "        ");
+	print_num(fp, 10, stats->rx_bytes);
+	print_num(fp, 8, stats->rx_packets);
+	print_num(fp, 7, stats->rx_errors);
+	print_num(fp, 8, stats->rx_dropped);
+	print_num(fp, 7, stats->rx_noroute);
+	fprintf(fp, "\n");
+	fprintf(fp, "        TX: bytes  packets  errors  dropped\n");
+	fprintf(fp, "        ");
+	print_num(fp, 10, stats->tx_bytes);
+	print_num(fp, 8, stats->tx_packets);
+	print_num(fp, 7, stats->tx_errors);
+	print_num(fp, 7, stats->tx_dropped);
+	fprintf(fp, "\n");
+}
+
+static void print_af_stats_attr(FILE *fp, int ifindex, struct rtattr *attr)
+{
+	bool if_printed = false;
+	struct rtattr *i;
+	int rem;
+
+	rem = RTA_PAYLOAD(attr);
+	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		if (preferred_family != AF_UNSPEC &&
+		    i->rta_type != preferred_family)
+			continue;
+
+		if (!if_printed) {
+			fprintf(fp, "%u: %s\n", ifindex,
+				ll_index_to_name(ifindex));
+			if_printed = true;
+		}
+
+		switch (i->rta_type) {
+		case AF_MPLS:
+			print_mpls_stats(fp, i);
+			break;
+		default:
+			fprintf(fp, "    unknown af(%d)\n", i->rta_type);
+			break;
+		}
+	}
+}
+
+struct af_stats_ctx {
+	FILE *fp;
+	int ifindex;
+};
+
+static int print_af_stats(const struct sockaddr_nl *who,
+			  struct nlmsghdr *n,
+			  void *arg)
+{
+	struct if_stats_msg *ifsm = NLMSG_DATA(n);
+	struct rtattr *tb[IFLA_STATS_MAX+1];
+	int len = n->nlmsg_len;
+	struct af_stats_ctx *ctx = arg;
+	FILE *fp = ctx->fp;
+
+	len -= NLMSG_LENGTH(sizeof(*ifsm));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	if (ctx->ifindex && ifsm->ifindex != ctx->ifindex)
+		return 0;
+
+	parse_rtattr(tb, IFLA_STATS_MAX, IFLA_STATS_RTA(ifsm), len);
+
+	if (tb[IFLA_STATS_AF_SPEC])
+		print_af_stats_attr(fp, ifsm->ifindex, tb[IFLA_STATS_AF_SPEC]);
+
+	fflush(fp);
+	return 0;
+}
+
+static int iplink_afstats(int argc, char **argv)
+{
+	__u32 filt_mask = IFLA_STATS_FILTER_BIT(IFLA_STATS_AF_SPEC);
+	const char *filter_dev = NULL;
+	struct af_stats_ctx ctx = {
+		.fp = stdout,
+		.ifindex = 0,
+	};
+
+	while (argc > 0) {
+		if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			if (filter_dev)
+				duparg2("dev", *argv);
+			filter_dev = *argv;
+		} else if (matches(*argv, "help") == 0) {
+			usage();
+		} else {
+			fprintf(stderr,
+				"Command \"%s\" is unknown, try \"ip link help\".\n",
+				*argv);
+			exit(-1);
+		}
+
+		argv++; argc--;
+	}
+
+	if (filter_dev) {
+		ctx.ifindex = ll_name_to_index(filter_dev);
+		if (ctx.ifindex <= 0) {
+			fprintf(stderr,
+				"Device \"%s\" does not exist.\n",
+				filter_dev);
+			return -1;
+		}
+	}
+
+	if (rtnl_wilddump_stats_req_filter(&rth, AF_UNSPEC,
+					   RTM_GETSTATS,
+					   filt_mask) < 0) {
+		perror("Cannont send dump request");
+		return 1;
+	}
+
+	if (rtnl_dump_filter(&rth, print_af_stats, &ctx) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		return 1;
+	}
+
+	return 0;
+}
+
 static void do_help(int argc, char **argv)
 {
 	struct link_util *lu = NULL;
@@ -1416,6 +1562,11 @@ int do_iplink(int argc, char **argv)
 	if (matches(*argv, "xstats") == 0)
 		return iplink_ifla_xstats(argc-1, argv+1);
 
+	if (matches(*argv, "afstats") == 0) {
+		iplink_afstats(argc-1, argv+1);
+		return 0;
+	}
+
 	if (matches(*argv, "help") == 0) {
 		do_help(argc-1, argv+1);
 		return 0;
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index f2e182bdaff7..83ffb6357f7d 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -174,6 +174,11 @@ ip-link \- network device configuration
 .RI "[ " ARGS " ]"
 
 .ti -8
+.B ip link afstats
+.RB "[ " dev
+.IR DEVICE " ]"
+
+.ti -8
 .B ip link help
 .RI "[ " TYPE " ]"
 
@@ -1628,6 +1633,13 @@ output.
 .I TYPE
 specifies the type of devices to display extended statistics for.
 
+.SS  ip link afstats - display address-family specific statistics
+
+.TP
+.BI dev " DEVICE "
+.I DEVICE
+specifies the device to display address-family statistics for.
+
 .SS  ip link help - display help
 
 .PP
-- 
2.1.4
