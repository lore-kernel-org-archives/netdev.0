From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH 1/1] iproute2: v4: Add support to configure SR-IOV VF minimum and maximum Tx rate through ip tool.
Date: Wed, 14 May 2014 01:55:35 -0400
Message-ID: <1400046935-13972-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Dept-HSGLinuxNICDev@qlogic.com>, <ben@decadent.org.uk>,
	<gregory.v.rose@intel.com>, <linux-net-drivers@solarflare.com>,
	<Ariel.Elior@qlogic.com>, <amirv@mellanox.com>, <mkubecek@suse.cz>,
	<stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:7375 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750998AbaENGYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 02:24:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o "min_tx_rate" option has been added for minimum Tx rate. Hence, for
  consistent naming, "max_tx_rate" option has been introduced for maximum
  Tx rate.

o Change in v2: "rate" can be used along with "max_tx_rate".
  When both are specified, "max_tx_rate" should override.

o Change in v3:
  * IFLA_VF_RATE: When IFLA_VF_RATE is used, and user has given only one of
    min_tx_rate or max_tx_rate, reading of previous rate limits is done in
    userspace instead of in kernel space before ndo_set_vf_rate.

  * IFLA_VF_TX_RATE: When IFLA_VF_TX_RATE is used, min_tx_rate is always read
    in kernel space. This takes care of below scenarios:
    (1) when old tool sends "rate" but kernel is new (expects min and max)
    (2) when new tool sends only "rate" but kernel is old (expects only "rate")

o Change in v4 as suggested by Stephen Hemminger:
  * As per iproute policy, input and output formats should match. Changing display
    of max_tx_rate and min_tx_rate options accordingly.
	./ip/ip link show p3p1
	8: p3p1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000
        link/ether 00:0e:1e:16:ce:40 brd ff:ff:ff:ff:ff:ff
        vf 0 MAC 2a:18:8f:4d:3d:d4, tx rate 700 (Mbps), max_tx_rate 700Mbps, min_tx_rate 200Mbps
        vf 1 MAC 72:dc:ba:f9:df:fd

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 include/linux/if_link.h |    9 ++++++-
 ip/ip_common.h          |    1 +
 ip/ipaddress.c          |   60 +++++++++++++++++++++++++++++++++++++++++++++++
 ip/iplink.c             |   57 +++++++++++++++++++++++++++++++++++++++++++-
 man/man8/ip-link.8.in   |   24 +++++++++++++++++-
 5 files changed, 147 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f08505c..4388f3e 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -396,9 +396,10 @@ enum {
 	IFLA_VF_UNSPEC,
 	IFLA_VF_MAC,		/* Hardware queue specific attributes */
 	IFLA_VF_VLAN,
-	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
+	IFLA_VF_TX_RATE,	/* Max TX Bandwidth Allocation */
 	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
 	IFLA_VF_LINK_STATE,	/* link state enable/disable/auto switch */
+	IFLA_VF_RATE,		/* Min and Max TX Bandwidth Allocation */
 	__IFLA_VF_MAX,
 };
 
@@ -420,6 +421,12 @@ struct ifla_vf_tx_rate {
 	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
 };
 
+struct ifla_vf_rate {
+	__u32 vf;
+	__u32 min_tx_rate; /* Min TX bandwidth in Mbps */
+	__u32 max_tx_rate; /* Max TX bandwidth in Mbps */
+};
+
 struct ifla_vf_spoofchk {
 	__u32 vf;
 	__u32 setting;
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 698dc7a..849ffff 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -17,6 +17,7 @@ extern int iproute_monitor(int argc, char **argv);
 extern void iplink_usage(void) __attribute__((noreturn));
 extern void iproute_reset_filter(void);
 extern void ipmroute_reset_filter(void);
+void ipaddr_get_vf_rate(int, int *, int *);
 extern void ipaddr_reset_filter(int);
 extern void ipneigh_reset_filter(void);
 extern void ipntable_reset_filter(void);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 14d1720..f7fd27b 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -245,6 +245,7 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 {
 	struct ifla_vf_mac *vf_mac;
 	struct ifla_vf_vlan *vf_vlan;
+	struct ifla_vf_rate *vf_rate;
 	struct ifla_vf_tx_rate *vf_tx_rate;
 	struct ifla_vf_spoofchk *vf_spoofchk;
 	struct ifla_vf_link_state *vf_linkstate;
@@ -262,6 +263,7 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	vf_mac = RTA_DATA(vf[IFLA_VF_MAC]);
 	vf_vlan = RTA_DATA(vf[IFLA_VF_VLAN]);
 	vf_tx_rate = RTA_DATA(vf[IFLA_VF_TX_RATE]);
+	vf_rate = RTA_DATA(vf[IFLA_VF_RATE]);
 
 	/* Check if the spoof checking vf info type is supported by
 	 * this kernel.
@@ -297,6 +299,10 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 		fprintf(fp, ", qos %d", vf_vlan->qos);
 	if (vf_tx_rate->rate)
 		fprintf(fp, ", tx rate %d (Mbps)", vf_tx_rate->rate);
+	if (vf_rate->max_tx_rate)
+		fprintf(fp, ", max_tx_rate %dMbps", vf_rate->max_tx_rate);
+	if (vf_rate->min_tx_rate)
+		fprintf(fp, ", min_tx_rate %dMbps", vf_rate->min_tx_rate);
 	if (vf_spoofchk && vf_spoofchk->setting != -1) {
 		if (vf_spoofchk->setting)
 			fprintf(fp, ", spoof checking on");
@@ -1252,6 +1258,60 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 	return 0;
 }
 
+static void
+ipaddr_loop_each_vf(struct rtattr *tb[], int vfnum, int *min, int *max)
+{
+	struct rtattr *vflist = tb[IFLA_VFINFO_LIST];
+	struct rtattr *i, *vf[IFLA_VF_MAX+1];
+	struct ifla_vf_rate *vf_rate;
+	int rem;
+
+	rem = RTA_PAYLOAD(vflist);
+
+	for (i = RTA_DATA(vflist); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		parse_rtattr_nested(vf, IFLA_VF_MAX, i);
+		vf_rate = RTA_DATA(vf[IFLA_VF_RATE]);
+		if (vf_rate->vf == vfnum) {
+			*min = vf_rate->min_tx_rate;
+			*max = vf_rate->max_tx_rate;
+			return;
+		}
+	}
+	fprintf(stderr, "Cannot find VF %d\n", vfnum);
+	exit(1);
+}
+
+void ipaddr_get_vf_rate(int vfnum, int *min, int *max)
+{
+	struct nlmsg_chain linfo = { NULL, NULL};
+	struct rtattr *tb[IFLA_MAX+1];
+	struct ifinfomsg *ifi;
+	struct nlmsg_list *l;
+	struct nlmsghdr *n;
+	int len;
+
+	if (rtnl_wilddump_request(&rth, AF_UNSPEC, RTM_GETLINK) < 0) {
+		perror("Cannot send dump request");
+		exit(1);
+	}
+	if (rtnl_dump_filter(&rth, store_nlmsg, &linfo) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		exit(1);
+	}
+	for (l = linfo.head; l; l = l->next) {
+		n = &l->h;
+		ifi = NLMSG_DATA(n);
+		len = n->nlmsg_len - NLMSG_LENGTH(sizeof(*ifi));
+
+		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
+
+		if ((tb[IFLA_VFINFO_LIST] && tb[IFLA_NUM_VF])) {
+			ipaddr_loop_each_vf(tb, vfnum, min, max);
+			return;
+		}
+	}
+}
+
 int ipaddr_list_link(int argc, char **argv)
 {
 	preferred_family = AF_PACKET;
diff --git a/ip/iplink.c b/ip/iplink.c
index 6a62cc0..a6bf283 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -217,14 +217,38 @@ struct iplink_req {
 static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			   struct iplink_req *req)
 {
+	char new_rate_api = 0, count = 0, override_legacy_rate = 0;
+	struct ifla_vf_rate tivt;
 	int len, argc = *argcp;
 	char **argv = *argvp;
 	struct rtattr *vfinfo;
 
+	tivt.min_tx_rate = -1;
+	tivt.max_tx_rate = -1;
+
 	vfinfo = addattr_nest(&req->n, sizeof(*req), IFLA_VF_INFO);
 
 	while (NEXT_ARG_OK()) {
 		NEXT_ARG();
+		count++;
+		if (!matches(*argv, "max_tx_rate")) {
+			/* new API in use */
+			new_rate_api = 1;
+			/* override legacy rate */
+			override_legacy_rate = 1;
+		} else if (!matches(*argv, "min_tx_rate")) {
+			/* new API in use */
+			new_rate_api = 1;
+		}
+	}
+
+	while (count--) {
+		/* rewind arg */
+		PREV_ARG();
+	}
+
+	while (NEXT_ARG_OK()) {
+		NEXT_ARG();
 		if (matches(*argv, "mac") == 0) {
 			struct ifla_vf_mac ivm;
 			NEXT_ARG();
@@ -261,7 +285,25 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 				invarg("Invalid \"rate\" value\n", *argv);
 			}
 			ivt.vf = vf;
-			addattr_l(&req->n, sizeof(*req), IFLA_VF_TX_RATE, &ivt, sizeof(ivt));
+			if (!new_rate_api)
+				addattr_l(&req->n, sizeof(*req),
+					  IFLA_VF_TX_RATE, &ivt, sizeof(ivt));
+			else if (!override_legacy_rate)
+				tivt.max_tx_rate = ivt.rate;
+
+		} else if (matches(*argv, "max_tx_rate") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&tivt.max_tx_rate, *argv, 0))
+				invarg("Invalid \"max tx rate\" value\n",
+				       *argv);
+			tivt.vf = vf;
+
+		} else if (matches(*argv, "min_tx_rate") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&tivt.min_tx_rate, *argv, 0))
+				invarg("Invalid \"min tx rate\" value\n",
+				       *argv);
+			tivt.vf = vf;
 
 		} else if (matches(*argv, "spoofchk") == 0) {
 			struct ifla_vf_spoofchk ivs;
@@ -295,6 +337,19 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 		}
 	}
 
+	if (new_rate_api) {
+		int tmin, tmax;
+		if (tivt.min_tx_rate == -1 || tivt.max_tx_rate == -1) {
+			ipaddr_get_vf_rate(tivt.vf, &tmin, &tmax);
+			if (tivt.min_tx_rate == -1)
+				tivt.min_tx_rate = tmin;
+			if (tivt.max_tx_rate == -1)
+				tivt.max_tx_rate = tmax;
+		}
+		addattr_l(&req->n, sizeof(*req), IFLA_VF_RATE, &tivt,
+			  sizeof(tivt));
+	}
+
 	if (argc == *argcp)
 		incomplete_command();
 
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 94d07fc..4a21e1d 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -124,6 +124,10 @@ ip-link \- network device configuration
 .IR VLAN-QOS " ] ] ["
 .B rate
 .IR TXRATE " ] ["
+.B max_tx_rate
+.IR TXRATE " ] ["
+.B min_tx_rate
+.IR TXRATE " ] ["
 .B spoofchk { on | off }
 ] |
 .br
@@ -568,8 +572,24 @@ as 0 disables VLAN tagging and filtering for the VF.
 
 .sp
 .BI rate " TXRATE"
-- change the allowed transmit bandwidth, in Mbps, for the specified VF.
-Setting this parameter to 0 disables rate limiting. The
+-- change the allowed transmit bandwidth, in Mbps, for the specified VF.
+Setting this parameter to 0 disables rate limiting.
+This option will be deprecated in future. Please use
+.B "max_tx_rate"
+option instead.
+.B vf
+parameter must be specified.
+
+.sp
+.BI max_tx_rate " TXRATE"
+- change the allowed maximum transmit bandwidth, in Mbps, for the specified VF.
+.B vf
+parameter must be specified.
+
+.sp
+.BI min_tx_rate " TXRATE"
+- change the allowed minimum transmit bandwidth, in Mbps, for the specified VF.
+Minimum TXRATE should be always <= Maximum TXRATE. The
 .B vf
 parameter must be specified.
 
-- 
1.7.1
