From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH iproute2] ip link: Add support to configure SR-IOV VF to vlan protocol 802.1ad (VST QinQ)
Date: Wed, 28 Sep 2016 10:58:59 +0300
Message-ID: <1475049539-25905-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Moshe Shemesh <moshe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56849 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750977AbcI1IAs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 04:00:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

Introduce a new API that exposes a list of vlans per VF (IFLA_VF_VLAN_LIST),
giving the ability for user-space application to specify it for the VF as
an option to support 802.1ad (VST QinQ).

We introduce struct vf_vlan_info, which extends struct vf_vlan and adds
an optional VF VLAN proto parameter.
Default VLAN-protocol is 802.1Q.

Add IFLA_VF_VLAN_LIST in addition to IFLA_VF_VLAN to keep backward
compatibility with older kernel versions.

Suitable ip link tool command examples:
 - Set vf vlan protocol 802.1ad (S-TAG)
	ip link set eth0 vf 1 vlan 100 proto 802.1ad
 - Set vf vlan S-TAG and vlan C-TAG (VST QinQ)
	ip link set eth0 vf 1 vlan 100 proto 802.1ad vlan 30 proto 802.1Q
 - Set vf to VST (802.1Q) mode
	ip link set eth0 vf 1 vlan 100 proto 802.1Q
 - Or by omitting the new parameter (backward compatible)
	ip link set eth0 vf 1 vlan 100

Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 include/linux/if_link.h |  18 ++++++++-
 ip/ipaddress.c          |  35 ++++++++++++++---
 ip/iplink.c             | 102 ++++++++++++++++++++++++++++++++++++++++--------
 man/man8/ip-link.8.in   |  30 ++++++++++++--
 4 files changed, 157 insertions(+), 28 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 1feb708902ac..d8d349fb120f 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -615,7 +615,7 @@ enum {
 enum {
 	IFLA_VF_UNSPEC,
 	IFLA_VF_MAC,		/* Hardware queue specific attributes */
-	IFLA_VF_VLAN,
+	IFLA_VF_VLAN,		/* VLAN ID and QoS */
 	IFLA_VF_TX_RATE,	/* Max TX Bandwidth Allocation */
 	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
 	IFLA_VF_LINK_STATE,	/* link state enable/disable/auto switch */
@@ -627,6 +627,7 @@ enum {
 	IFLA_VF_TRUST,		/* Trust VF */
 	IFLA_VF_IB_NODE_GUID,	/* VF Infiniband node GUID */
 	IFLA_VF_IB_PORT_GUID,	/* VF Infiniband port GUID */
+	IFLA_VF_VLAN_LIST,	/* nested list of vlans, option for QinQ */
 	__IFLA_VF_MAX,
 };
 
@@ -643,6 +644,21 @@ struct ifla_vf_vlan {
 	__u32 qos;
 };
 
+enum {
+	IFLA_VF_VLAN_INFO_UNSPEC,
+	IFLA_VF_VLAN_INFO,	/* VLAN ID, QoS and VLAN protocol */
+	__IFLA_VF_VLAN_INFO_MAX,
+};
+
+#define IFLA_VF_VLAN_INFO_MAX (__IFLA_VF_VLAN_INFO_MAX - 1)
+
+struct ifla_vf_vlan_info {
+	__u32 vf;
+	__u32 vlan; /* 0 - 4095, 0 disables VLAN filter */
+	__u32 qos;
+	__be16 vlan_proto; /* VLAN protocol either 802.1Q or 802.1ad */
+};
+
 struct ifla_vf_tx_rate {
 	__u32 vf;
 	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index fcc3c538d1bd..a12c34e03664 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -321,7 +321,6 @@ static void print_vf_stats64(FILE *fp, struct rtattr *vfstats);
 static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 {
 	struct ifla_vf_mac *vf_mac;
-	struct ifla_vf_vlan *vf_vlan;
 	struct ifla_vf_tx_rate *vf_tx_rate;
 	struct ifla_vf_spoofchk *vf_spoofchk;
 	struct ifla_vf_link_state *vf_linkstate;
@@ -338,7 +337,6 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	parse_rtattr_nested(vf, IFLA_VF_MAX, vfinfo);
 
 	vf_mac = RTA_DATA(vf[IFLA_VF_MAC]);
-	vf_vlan = RTA_DATA(vf[IFLA_VF_VLAN]);
 	vf_tx_rate = RTA_DATA(vf[IFLA_VF_TX_RATE]);
 
 	/* Check if the spoof checking vf info type is supported by
@@ -369,10 +367,35 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	fprintf(fp, "%s    vf %d MAC %s", _SL_, vf_mac->vf,
 		ll_addr_n2a((unsigned char *)&vf_mac->mac,
 			    ETH_ALEN, 0, b1, sizeof(b1)));
-	if (vf_vlan->vlan)
-		fprintf(fp, ", vlan %d", vf_vlan->vlan);
-	if (vf_vlan->qos)
-		fprintf(fp, ", qos %d", vf_vlan->qos);
+	if (vf[IFLA_VF_VLAN_LIST]) {
+		struct rtattr *i, *vfvlanlist = vf[IFLA_VF_VLAN_LIST];
+		int rem = RTA_PAYLOAD(vfvlanlist);
+
+		for (i = RTA_DATA(vfvlanlist);
+		      RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+			struct ifla_vf_vlan_info *vf_vlan_info =
+					RTA_DATA(i);
+			SPRINT_BUF(b2);
+
+			if (vf_vlan_info->vlan)
+				fprintf(fp, ", vlan %d", vf_vlan_info->vlan);
+			if (vf_vlan_info->qos)
+				fprintf(fp, ", qos %d", vf_vlan_info->qos);
+			if (vf_vlan_info->vlan_proto &&
+			    vf_vlan_info->vlan_proto != htons(ETH_P_8021Q))
+				fprintf(fp, ", vlan protocol %s",
+					ll_proto_n2a(vf_vlan_info->vlan_proto,
+						     b2, sizeof(b2)));
+
+		}
+	} else {
+		struct ifla_vf_vlan *vf_vlan = RTA_DATA(vf[IFLA_VF_VLAN]);
+
+		if (vf_vlan->vlan)
+			fprintf(fp, ", vlan %d", vf_vlan->vlan);
+		if (vf_vlan->qos)
+			fprintf(fp, ", qos %d", vf_vlan->qos);
+	}
 	if (vf_tx_rate->rate)
 		fprintf(fp, ", tx rate %d (Mbps)", vf_tx_rate->rate);
 
diff --git a/ip/iplink.c b/ip/iplink.c
index dec8268a0dbb..cbfc9f3342b0 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -76,7 +76,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ link-netnsid ID ]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
-	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
+	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] [ proto VLAN-PROTO ] ]\n");
 
 	fprintf(stderr, "				   [ rate TXRATE ]\n");
 	fprintf(stderr, "				   [ max_tx_rate TXRATE ]\n");
@@ -255,6 +255,60 @@ static int nl_get_ll_addr_len(unsigned int dev_index)
 	return RTA_PAYLOAD(tb[IFLA_ADDRESS]);
 }
 
+static void iplink_parse_vf_vlan_info(int vf, int *argcp, char ***argvp,
+				      struct ifla_vf_vlan_info *ivvip)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+
+	NEXT_ARG();
+	if (get_unsigned(&ivvip->vlan, *argv, 0))
+		invarg("Invalid \"vlan\" value\n", *argv);
+
+	ivvip->vf = vf;
+	ivvip->qos = 0;
+	ivvip->vlan_proto = htons(ETH_P_8021Q);
+	if (NEXT_ARG_OK()) {
+		NEXT_ARG();
+		if (matches(*argv, "qos") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&ivvip->qos, *argv, 0))
+				invarg("Invalid \"qos\" value\n", *argv);
+		} else {
+			/* rewind arg */
+			PREV_ARG();
+		}
+	}
+	if (NEXT_ARG_OK()) {
+		NEXT_ARG();
+		if (matches(*argv, "proto") == 0) {
+			NEXT_ARG();
+			if (ll_proto_a2n(&ivvip->vlan_proto, *argv))
+				invarg("protocol is invalid\n", *argv);
+			if (ivvip->vlan_proto != htons(ETH_P_8021AD) &&
+			    ivvip->vlan_proto != htons(ETH_P_8021Q)) {
+				SPRINT_BUF(b1);
+				SPRINT_BUF(b2);
+				char msg[64 + sizeof(b1) + sizeof(b2)];
+
+				sprintf(msg, "Invalid \"vlan protocol\""
+					" value - supported %s, %s\n",
+					ll_proto_n2a(htons(ETH_P_8021Q),
+					     b1, sizeof(b1)),
+					ll_proto_n2a(htons(ETH_P_8021AD),
+					     b2, sizeof(b2)));
+				invarg(msg, *argv);
+			}
+		} else {
+			/* rewind arg */
+			PREV_ARG();
+		}
+	}
+
+	*argcp = argc;
+	*argvp = argv;
+}
+
 static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			   struct iplink_req *req, int dev_index)
 {
@@ -308,27 +362,41 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			addattr_l(&req->n, sizeof(*req), IFLA_VF_MAC,
 				  &ivm, sizeof(ivm));
 		} else if (matches(*argv, "vlan") == 0) {
-			struct ifla_vf_vlan ivv;
+			struct ifla_vf_vlan_info ivvi;
 
-			NEXT_ARG();
-			if (get_unsigned(&ivv.vlan, *argv, 0))
-				invarg("Invalid \"vlan\" value\n", *argv);
+			iplink_parse_vf_vlan_info(vf, &argc, &argv, &ivvi);
+			/* support the old interface in case of older kernel*/
+			if (ivvi.vlan_proto == htons(ETH_P_8021Q)) {
+				struct ifla_vf_vlan ivv;
 
-			ivv.vf = vf;
-			ivv.qos = 0;
-			if (NEXT_ARG_OK()) {
-				NEXT_ARG();
-				if (matches(*argv, "qos") == 0) {
+				ivv.vf = ivvi.vf;
+				ivv.vlan = ivvi.vlan;
+				ivv.qos = ivvi.qos;
+				addattr_l(&req->n, sizeof(*req),
+					  IFLA_VF_VLAN, &ivv, sizeof(ivv));
+			} else {
+				struct rtattr *vfvlanlist;
+
+				vfvlanlist = addattr_nest(&req->n, sizeof(*req),
+							  IFLA_VF_VLAN_LIST);
+				addattr_l(&req->n, sizeof(*req),
+					  IFLA_VF_VLAN_INFO, &ivvi,
+					  sizeof(ivvi));
+
+				while (NEXT_ARG_OK()) {
 					NEXT_ARG();
-					if (get_unsigned(&ivv.qos, *argv, 0))
-						invarg("Invalid \"qos\" value\n", *argv);
-				} else {
-					/* rewind arg */
-					PREV_ARG();
+					if (matches(*argv, "vlan") != 0) {
+						PREV_ARG();
+						break;
+					}
+					iplink_parse_vf_vlan_info(vf, &argc,
+								  &argv, &ivvi);
+					addattr_l(&req->n, sizeof(*req),
+						  IFLA_VF_VLAN_INFO, &ivvi,
+						  sizeof(ivvi));
 				}
+				addattr_nest_end(&req->n, vfvlanlist);
 			}
-			addattr_l(&req->n, sizeof(*req), IFLA_VF_VLAN,
-				  &ivv, sizeof(ivv));
 		} else if (matches(*argv, "rate") == 0) {
 			struct ifla_vf_tx_rate ivt;
 
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ffc4160a1b6e..4dfa43fc14f5 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -102,10 +102,7 @@ ip-link \- network device configuration
 .IR LLADDR " ]"
 .br
 .in +9
-.RB "[ " vlan
-.IR VLANID " [ "
-.B qos
-.IR VLAN-QOS " ] ]"
+.RI "[ " VFVLAN-LIST " ]"
 .br
 .RB "[ " rate
 .IR TXRATE " ]"
@@ -191,6 +188,18 @@ ip-link \- network device configuration
 .IR ETYPE " := [ " TYPE " |"
 .BR bridge_slave " | " bond_slave " ]"
 
+.ti -8
+.IR VFVLAN-LIST " := [ "  VFVLAN-LIST " ] " VFVLAN
+
+.ti -8
+.IR VFVLAN " := "
+.RB "[ " vlan
+.IR VLANID " [ "
+.B qos
+.IR VLAN-QOS " ] ["
+.B proto
+.IR VLAN-PROTO " ] ]"
+
 .SH "DESCRIPTION"
 .SS ip link add - add virtual link
 
@@ -1238,6 +1247,19 @@ and
 as 0 disables VLAN tagging and filtering for the VF.
 
 .sp
+.BI proto " VLAN-PROTO"
+- assign VLAN PROTOCOL for the VLAN tag, either 802.1Q or 802.1ad.
+Setting to 802.1ad, all traffic sent from the VF will be tagged with VLAN S-Tag.
+Incoming traffic will have VLAN S-Tags stripped before being passed to the VF.
+Setting to 802.1ad also enables an option to concatenate another VLAN tag, so both
+S-TAG and C-TAG will be inserted/stripped for outgoing/incoming traffic, respectively.
+If not specified, the value is assumed to be 802.1Q. Both the
+.B vf
+and
+.B vlan
+parameters must be specified.
+
+.sp
 .BI rate " TXRATE"
 -- change the allowed transmit bandwidth, in Mbps, for the specified VF.
 Setting this parameter to 0 disables rate limiting.
-- 
1.8.3.1
