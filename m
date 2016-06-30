From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next iproute2 3/3] ip: Add option to specify PF number associated with the VF
Date: Thu, 30 Jun 2016 21:04:44 +0530
Message-ID: <1467300884-32340-4-git-send-email-hariprasad@chelsio.com>
References: <1467300884-32340-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, leedom@chelsio.com,
	kumaras@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:35651 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932601AbcF3PiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 11:38:17 -0400
In-Reply-To: <1467300884-32340-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add options to specify PF number associated with the VF for MAC ACL.
The current API assumes that there is one to one mapping between
Network Ports, Physical Functions and the SR-IOV Virtual Function.
But that's not true in the case of Chelsio, our cards have SR-IOV
Capabilities on Physical Functions 0..3 and the PF Driver registers
ports on PF4.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 include/linux/if_link.h |    1 +
 ip/ipaddress.c          |    3 +++
 ip/iplink.c             |   21 ++++++++++++++-------
 man/man8/ip-link.8.in   |   15 +++++++++++++--
 4 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 15bbeb8..793c765 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -631,6 +631,7 @@ enum {
 #define IFLA_VF_MAX (__IFLA_VF_MAX - 1)
 
 struct ifla_vf_mac {
+	__u32 pf;
 	__u32 vf;
 	__u8 mac[32]; /* MAX_ADDR_LEN */
 };
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index df363b0..d67c89b 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -351,6 +351,9 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	fprintf(fp, "%s    vf %d MAC %s", _SL_, vf_mac->vf,
 		ll_addr_n2a((unsigned char *)&vf_mac->mac,
 			    ETH_ALEN, 0, b1, sizeof(b1)));
+	fprintf(fp, "%s    pf %d vf %d MAC %s", _SL_, vf_mac->pf,
+		vf_mac->pf, ll_addr_n2a((unsigned char *)&vf_mac->mac,
+		ETH_ALEN, 0, b1, sizeof(b1)));
 	if (vf_vlan->vlan)
 		fprintf(fp, ", vlan %d", vf_vlan->vlan);
 	if (vf_vlan->qos)
diff --git a/ip/iplink.c b/ip/iplink.c
index d2e586b..9c1b625 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -73,7 +73,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ netns { PID | NAME } ]\n");
 	fprintf(stderr, "	                  [ link-netnsid ID ]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
-	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
+	fprintf(stderr, "	                  [ pf NUM vf NUM [ mac LLADDR ]\n");
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
 
 	fprintf(stderr, "				   [ rate TXRATE ]\n");
@@ -237,7 +237,7 @@ struct iplink_req {
 	char			buf[1024];
 };
 
-static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
+static int iplink_parse_vf(int pf, int vf, int *argcp, char ***argvp,
 			   struct iplink_req *req, int dev_index)
 {
 	char new_rate_api = 0, count = 0, override_legacy_rate = 0;
@@ -276,6 +276,7 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			struct ifla_vf_mac ivm;
 
 			NEXT_ARG();
+			ivm.pf = pf;
 			ivm.vf = vf;
 			len = ll_addr_a2n((char *)ivm.mac, 32, *argv);
 			if (len < 0)
@@ -423,7 +424,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	int qlen = -1;
 	int mtu = -1;
 	int netns = -1;
-	int vf = -1;
+	int pf = -1, vf = -1;
 	int numtxqueues = -1;
 	int numrxqueues = -1;
 	int dev_index = 0;
@@ -540,19 +541,25 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				req->i.ifi_flags |= IFF_NOARP;
 			else
 				return on_off("arp", *argv);
-		} else if (strcmp(*argv, "vf") == 0) {
+		} else if (strcmp(*argv, "pf") == 0) {
 			struct rtattr *vflist;
 
 			NEXT_ARG();
-			if (get_integer(&vf,  *argv, 0))
-				invarg("Invalid \"vf\" value\n", *argv);
+			if (get_integer(&pf,  *argv, 0))
+				invarg("Invalid \"pf\" value\n", *argv);
+			NEXT_ARG();
+			if (strcmp(*argv, "vf") == 0) {
+				NEXT_ARG();
+				if (get_integer(&vf,  *argv, 0))
+					invarg("Invalid \"vf\" value\n", *argv);
+			}
 
 			vflist = addattr_nest(&req->n, sizeof(*req),
 					      IFLA_VFINFO_LIST);
 			if (dev_index == 0)
 				missarg("dev");
 
-			len = iplink_parse_vf(vf, &argc, &argv, req, dev_index);
+			len = iplink_parse_vf(pf, vf, &argc, &argv, req, dev_index);
 			if (len < 0)
 				return -1;
 			addattr_nest_end(&req->n, vflist);
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 8fcce5e..a47b0e6 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -119,7 +119,9 @@ ip-link \- network device configuration
 .RB "[ " alias
 .IR NAME  " ]"
 .br
-.RB "[ " vf
+.RB "[ " pf
+.IR NUM
+.B  vf
 .IR NUM " ["
 .B  mac
 .IR LLADDR " ]"
@@ -1096,15 +1098,24 @@ The available groups are listed in file
 .BR "@SYSCONFDIR@/group" .
 
 .TP
+.BI pf " NUM"
+specify the Physical Function of the VF device that needs to be configured.
+The associated VF device must be specified using the
+.B vf
+parameter.
+
+.TP
 .BI vf " NUM"
 specify a Virtual Function device to be configured. The associated PF device
 must be specified using the
-.B dev
+.B pf
 parameter.
 
 .in +8
 .BI mac " LLADDRESS"
 - change the station address for the specified VF. The
+.B pf
+and
 .B vf
 parameter must be specified.
 
-- 
1.7.3
