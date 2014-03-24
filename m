From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [RFC v2 1/1] iproute2: Add support to configure SR-IOV VF minimum and maximum Tx rate through ip tool.
Date: Mon, 24 Mar 2014 00:58:58 -0400
Message-ID: <1395637138-29852-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Dept-HSGLinuxNICDev@qlogic.com>, <ben@decadent.org.uk>,
	<gregory.v.rose@intel.com>, <linux-net-drivers@solarflare.com>,
	<Ariel.Elior@qlogic.com>, <amirv@mellanox.com>, <mkubecek@suse.cz>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:18448 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750760AbaCXFkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 01:40:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o "min_tx_rate" option has been added for minimum Tx rate. Hence, for
  consistent naming, "max_tx_rate" option has been introduced for maximum
  Tx rate. And plan is to deprecate "rate" option of ip tool in future.

o Change in v2: "rate" can be used along with "max_tx_rate".
  When both are specified, "max_tx_rate" should override.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 include/linux/if_link.h |    9 ++++++++-
 ip/ipaddress.c          |    6 ++++++
 ip/iplink.c             |   42 +++++++++++++++++++++++++++++++++++++++++-
 man/man8/ip-link.8.in   |   24 ++++++++++++++++++++++--
 4 files changed, 77 insertions(+), 4 deletions(-)

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
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 14d1720..2c033fc 100644
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
+		fprintf(fp, ", max tx rate %d (Mbps)", vf_rate->max_tx_rate);
+	if (vf_rate->min_tx_rate)
+		fprintf(fp, ", min tx rate %d (Mbps)", vf_rate->min_tx_rate);
 	if (vf_spoofchk && vf_spoofchk->setting != -1) {
 		if (vf_spoofchk->setting)
 			fprintf(fp, ", spoof checking on");
diff --git a/ip/iplink.c b/ip/iplink.c
index 6a62cc0..753a50d 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -217,14 +217,31 @@ struct iplink_req {
 static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			   struct iplink_req *req)
 {
+	struct ifla_vf_rate tivt;
 	int len, argc = *argcp;
 	char **argv = *argvp;
 	struct rtattr *vfinfo;
+	char flag = 0, new_rate_flag = -1, count = 0;
+
+	tivt.min_tx_rate = -1;
+	tivt.max_tx_rate = -1;
 
 	vfinfo = addattr_nest(&req->n, sizeof(*req), IFLA_VF_INFO);
 
 	while (NEXT_ARG_OK()) {
 		NEXT_ARG();
+		count++;
+		if (!matches(*argv, "max_tx_rate")) {
+			new_rate_flag = 0;
+			break;
+		}
+	}
+
+	while (count--)
+		PREV_ARG();
+
+	while (NEXT_ARG_OK()) {
+		NEXT_ARG();
 		if (matches(*argv, "mac") == 0) {
 			struct ifla_vf_mac ivm;
 			NEXT_ARG();
@@ -256,12 +273,31 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			addattr_l(&req->n, sizeof(*req), IFLA_VF_VLAN, &ivv, sizeof(ivv));
 		} else if (matches(*argv, "rate") == 0) {
 			struct ifla_vf_tx_rate ivt;
+			fprintf(stderr, "WARN: \"rate\" option will be deprecated. Use \"min_tx_rate\" and \"max_tx_rate\" option.\n");
 			NEXT_ARG();
 			if (get_unsigned(&ivt.rate, *argv, 0)) {
 				invarg("Invalid \"rate\" value\n", *argv);
 			}
 			ivt.vf = vf;
-			addattr_l(&req->n, sizeof(*req), IFLA_VF_TX_RATE, &ivt, sizeof(ivt));
+			if (new_rate_flag)
+				addattr_l(&req->n, sizeof(*req),
+					  IFLA_VF_TX_RATE, &ivt, sizeof(ivt));
+
+		} else if (matches(*argv, "max_tx_rate") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&tivt.max_tx_rate, *argv, 0))
+				invarg("Invalid \"max tx rate\" value\n",
+				       *argv);
+			tivt.vf = vf;
+			flag = 1;
+
+		} else if (matches(*argv, "min_tx_rate") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&tivt.min_tx_rate, *argv, 0))
+				invarg("Invalid \"min tx rate\" value\n",
+				       *argv);
+			tivt.vf = vf;
+			flag = 1;
 
 		} else if (matches(*argv, "spoofchk") == 0) {
 			struct ifla_vf_spoofchk ivs;
@@ -295,6 +331,10 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 		}
 	}
 
+	if (flag)
+		addattr_l(&req->n, sizeof(*req), IFLA_VF_RATE, &tivt,
+			  sizeof(tivt));
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
