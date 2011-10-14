From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [iproute2] iproute2: Add new command to ip link to enable/disable VF spoof check
Date: Thu, 13 Oct 2011 23:31:32 -0700
Message-ID: <1318573892-19093-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57804 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755084Ab1JNGbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 02:31:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Add ip link command parsing for VF spoof checking enable/disable

V2 - Fixed problem with parsing of dump info on kernels that don't
     support the spoof checking option and also wrapped the ifla_vf_info
     structure in #ifdef __KERNEL__ to prevent user space from directly
     accessing the structure
V3 - Improved parsing of vfinfo
V4 - Put Makefile back to proper list of subdirs
V5 - Remove struct ifla_vf_info, it is only used by the kernel
V6 - Make sure spoof check is reported by the driver - rtnl will set
     it to -1 to indicate driver didn't report a value.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/if_link.h |    8 +++-----
 ip/ipaddress.c          |   19 +++++++++++++++++++
 ip/iplink.c             |   15 +++++++++++++++
 man/man8/ip.8           |    4 +++-
 4 files changed, 40 insertions(+), 6 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 304c44f..d3bc04c 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -277,6 +277,7 @@ enum {
 	IFLA_VF_MAC,		/* Hardware queue specific attributes */
 	IFLA_VF_VLAN,
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
+	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
 	__IFLA_VF_MAX,
 };
 
@@ -298,12 +299,9 @@ struct ifla_vf_tx_rate {
 	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
 };
 
-struct ifla_vf_info {
+struct ifla_vf_spoofchk {
 	__u32 vf;
-	__u8 mac[32];
-	__u32 vlan;
-	__u32 qos;
-	__u32 tx_rate;
+	__u32 setting;
 };
 
 /* VF ports management section
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 85f05a2..2f2cabd 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -197,7 +197,9 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	struct ifla_vf_mac *vf_mac;
 	struct ifla_vf_vlan *vf_vlan;
 	struct ifla_vf_tx_rate *vf_tx_rate;
+	struct ifla_vf_spoofchk *vf_spoofchk;
 	struct rtattr *vf[IFLA_VF_MAX+1];
+	struct rtattr *tmp;
 	SPRINT_BUF(b1);
 
 	if (vfinfo->rta_type != IFLA_VF_INFO) {
@@ -211,6 +213,17 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	vf_vlan = RTA_DATA(vf[IFLA_VF_VLAN]);
 	vf_tx_rate = RTA_DATA(vf[IFLA_VF_TX_RATE]);
 
+	/* Check if the spoof checking vf info type is supported by
+	 * this kernel.
+	 */
+	tmp = (struct rtattr *)((char *)vf[IFLA_VF_TX_RATE] +
+			vf[IFLA_VF_TX_RATE]->rta_len);
+
+	if (tmp->rta_type != IFLA_VF_SPOOFCHK)
+		vf_spoofchk = NULL;
+	else
+		vf_spoofchk = RTA_DATA(vf[IFLA_VF_SPOOFCHK]);
+
 	fprintf(fp, "\n    vf %d MAC %s", vf_mac->vf,
 		ll_addr_n2a((unsigned char *)&vf_mac->mac,
 		ETH_ALEN, 0, b1, sizeof(b1)));
@@ -220,6 +233,12 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 		fprintf(fp, ", qos %d", vf_vlan->qos);
 	if (vf_tx_rate->rate)
 		fprintf(fp, ", tx rate %d (Mbps)", vf_tx_rate->rate);
+	if (vf_spoofchk && vf_spoofchk->setting != -1) {
+		if (vf_spoofchk->setting)
+			fprintf(fp, ", spoof checking on");
+		else
+			fprintf(fp, ", spoof checking off");
+	}
 }
 
 int print_linkinfo(const struct sockaddr_nl *who,
diff --git a/ip/iplink.c b/ip/iplink.c
index 35e6dc6..ca1aaeb 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -71,7 +71,10 @@ void iplink_usage(void)
 	fprintf(stderr, "			  [ alias NAME ]\n");
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
+
 	fprintf(stderr, "				   [ rate TXRATE ] ] \n");
+
+	fprintf(stderr, "				   [ spoofchk { on | off} ] ] \n");
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ]\n");
@@ -228,6 +231,18 @@ int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			ivt.vf = vf;
 			addattr_l(&req->n, sizeof(*req), IFLA_VF_TX_RATE, &ivt, sizeof(ivt));
 		
+		} else if (matches(*argv, "spoofchk") == 0) {
+			struct ifla_vf_spoofchk ivs;
+			NEXT_ARG();
+			if (matches(*argv, "on") == 0)
+				ivs.setting = 1;
+			else if (matches(*argv, "off") == 0)
+				ivs.setting = 0;
+			else
+				invarg("Invalid \"spoofchk\" value\n", *argv);
+			ivs.vf = vf;
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_SPOOFCHK, &ivs, sizeof(ivs));
+
 		} else {
 			/* rewind arg */
 			PREV_ARG();
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 36431b6..a20eca7 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -100,7 +100,9 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .B qos
 .IR VLAN-QOS " ] ] ["
 .B rate
-.IR TXRATE " ] |"
+.IR TXRATE " ] ["
+.B spoofchk { on | off }
+] |
 .br
 .B master
 .IR DEVICE
-- 
1.7.6.4
