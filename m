From: Chris Wright <chrisw@sous-sol.org>
Subject: [PATCH] iproute2: rework SR-IOV VF support
Date: Tue, 18 May 2010 00:57:00 -0700
Message-ID: <20100518075700.GE8301@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:34635 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754101Ab0ERH5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 03:57:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel interface changed just before 2.6.34 was released.  This brings
iproute2 in line with the current changes.  The VF portion of setlink is
comprised of a set of nested attributes.

  IFLA_VFINFO_LIST (NESTED)
    IFLA_VF_INFO (NESTED)
      IFLA_VF_MAC
      IFLA_VF_VLAN
      IFLA_VF_TX_RATE

Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---
Didn't forget the doc updates, tomorrow.

 ip/ipaddress.c |   60 ++++++++++++++++++------------
 ip/iplink.c    |  113 +++++++++++++++++++++++++++++++++++--------------------
 2 files changed, 108 insertions(+), 65 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 48f7b1e..f6db183 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -187,6 +187,36 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 	}
 }
 
+static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
+{
+	struct ifla_vf_mac *vf_mac;
+	struct ifla_vf_vlan *vf_vlan;
+	struct ifla_vf_tx_rate *vf_tx_rate;
+	struct rtattr *vf[IFLA_VF_MAX+1];
+	SPRINT_BUF(b1);
+
+	if (vfinfo->rta_type != IFLA_VF_INFO) {
+		fprintf(stderr, "BUG: rta type is %d\n", vfinfo->rta_type);
+		return;
+	}
+
+	parse_rtattr_nested(vf, IFLA_VF_MAX, vfinfo);
+
+	vf_mac = RTA_DATA(vf[IFLA_VF_MAC]);
+	vf_vlan = RTA_DATA(vf[IFLA_VF_VLAN]);
+	vf_tx_rate = RTA_DATA(vf[IFLA_VF_TX_RATE]);
+
+	fprintf(fp, "\n    vf %d MAC %s", vf_mac->vf,
+		ll_addr_n2a((unsigned char *)&vf_mac->mac,
+		ETH_ALEN, 0, b1, sizeof(b1)));
+	if (vf_vlan->vlan)
+		fprintf(fp, ", vlan %d", vf_vlan->vlan);
+	if (vf_vlan->qos)
+		fprintf(fp, ", qos %d", vf_vlan->qos);
+	if (vf_tx_rate->rate)
+		fprintf(fp, ", tx rate %d (Mbps)", vf_tx_rate->rate);
+}
+
 int print_linkinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg)
 {
@@ -331,31 +361,13 @@ int print_linkinfo(const struct sockaddr_nl *who,
 				);
 		}
 	}
-	if (do_link && tb[IFLA_VFINFO] && tb[IFLA_NUM_VF]) {
-		SPRINT_BUF(b1);
-		struct rtattr *rta = tb[IFLA_VFINFO];
-		struct ifla_vf_info *ivi;
-		int i;
-		for (i = 0; i < *(int *)RTA_DATA(tb[IFLA_NUM_VF]); i++) {
-			if (rta->rta_type != IFLA_VFINFO) {
-				fprintf(stderr, "BUG: rta type is %d\n", rta->rta_type);
-				break;
-			}
-			ivi = RTA_DATA(rta);
-			fprintf(fp, "\n    vf %d: MAC %s",
-				ivi->vf,
-				ll_addr_n2a((unsigned char *)&ivi->mac,
-					    ETH_ALEN, 0, b1, sizeof(b1)));
-				if (ivi->vlan)
-					fprintf(fp, ", vlan %d", ivi->vlan);
-				if (ivi->qos)
-					fprintf(fp, ", qos %d", ivi->qos);
-				if (ivi->tx_rate)
-					fprintf(fp, ", tx rate %d (Mbps_",
-						ivi->tx_rate);
-			rta = (struct rtattr *)((char *)rta + RTA_ALIGN(rta->rta_len));
-		}
+	if (do_link && tb[IFLA_VFINFO_LIST] && tb[IFLA_NUM_VF]) {
+		struct rtattr *i, *vflist = tb[IFLA_VFINFO_LIST];
+		int rem = RTA_PAYLOAD(vflist);
+		for (i = RTA_DATA(vflist); RTA_OK(i, rem); i = RTA_NEXT(i, rem))
+			print_vfinfo(fp, i);
 	}
+
 	fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
diff --git a/ip/iplink.c b/ip/iplink.c
index 97fca8b..cb2c4f5 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -176,6 +176,73 @@ struct iplink_req {
 	char			buf[1024];
 };
 
+int iplink_parse_vf(int vf, int *argcp, char ***argvp,
+			   struct iplink_req *req)
+{
+	int len, argc = *argcp;
+	char **argv = *argvp;
+	struct rtattr *vfinfo;
+
+	vfinfo = addattr_nest(&req->n, sizeof(*req), IFLA_VF_INFO);
+
+	while (NEXT_ARG_OK()) {
+		NEXT_ARG();
+		if (matches(*argv, "mac") == 0) {
+			struct ifla_vf_mac ivm;
+			NEXT_ARG();
+			ivm.vf = vf;
+			len = ll_addr_a2n((char *)ivm.mac, 32, *argv);
+			if (len < 0)
+				return -1;
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_MAC, &ivm, sizeof(ivm));
+		} else if (matches(*argv, "vlan") == 0) {
+			struct ifla_vf_vlan ivv;
+			NEXT_ARG();
+			if (get_unsigned(&ivv.vlan, *argv, 0)) {
+				invarg("Invalid \"vlan\" value\n", *argv);
+			}
+			ivv.vf = vf;
+			ivv.qos = 0;
+			if (NEXT_ARG_OK()) {
+				NEXT_ARG();
+				if (matches(*argv, "qos") == 0) {
+					NEXT_ARG();
+					if (get_unsigned(&ivv.qos, *argv, 0)) {
+						invarg("Invalid \"qos\" value\n", *argv);
+					}
+				} else {
+					/* rewind arg */
+					PREV_ARG();
+				}
+			}
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_VLAN, &ivv, sizeof(ivv));
+		} else if (matches(*argv, "rate") == 0) {
+			struct ifla_vf_tx_rate ivt;
+			NEXT_ARG();
+			if (get_unsigned(&ivt.rate, *argv, 0)) {
+				invarg("Invalid \"rate\" value\n", *argv);
+			}
+			ivt.vf = vf;
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_TX_RATE, &ivt, sizeof(ivt));
+		
+		} else {
+			/* rewind arg */
+			PREV_ARG();
+			break;
+		}
+	}
+
+	if (argc == *argcp)
+		incomplete_command();
+
+	addattr_nest_end(&req->n, vfinfo);
+
+	*argcp = argc;
+	*argvp = argv;
+	return 0;
+}
+
+
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		char **name, char **type, char **link, char **dev)
 {
@@ -283,53 +350,17 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			} else
 				return on_off("noarp");
 		} else if (strcmp(*argv, "vf") == 0) {
+			struct rtattr *vflist;
 			NEXT_ARG();
 			if (get_integer(&vf,  *argv, 0)) {
 				invarg("Invalid \"vf\" value\n", *argv);
 			}
-		} else if (matches(*argv, "mac") == 0) {
-			struct ifla_vf_mac ivm;
-			NEXT_ARG();
-			if (vf < 0) {
-				missarg("vf");
-			}
-			ivm.vf = vf;
-			len = ll_addr_a2n((char *)ivm.mac, 32, *argv);
+			vflist = addattr_nest(&req->n, sizeof(*req),
+					      IFLA_VFINFO_LIST);
+			len = iplink_parse_vf(vf, &argc, &argv, req);
 			if (len < 0)
 				return -1;
-			addattr_l(&req->n, sizeof(*req), IFLA_VF_MAC, &ivm, sizeof(ivm));
-		} else if (matches(*argv, "vlan") == 0) {
-			struct ifla_vf_vlan ivv;
-			NEXT_ARG();
-			if (vf < 0) {
-				missarg("vf");
-			}
-			if (get_unsigned(&ivv.vlan, *argv, 0)) {
-				invarg("Invalid \"vlan\" value\n", *argv);
-			}
-			ivv.vf = vf;
-			ivv.qos = 0;
-			if (NEXT_ARG_OK()) {
-				NEXT_ARG();
-				if (matches(*argv, "qos") == 0) {
-					NEXT_ARG();
-					if (get_unsigned(&ivv.qos, *argv, 0)) {
-						invarg("Invalid \"qos\" value\n", *argv);
-					}
-				}
-			}
-			addattr_l(&req->n, sizeof(*req), IFLA_VF_VLAN, &ivv, sizeof(ivv));
-		} else if (matches(*argv, "rate") == 0) {
-			struct ifla_vf_tx_rate ivt;
-			NEXT_ARG();
-			if (vf < 0) {
-				missarg("vf");
-			}
-			if (get_unsigned(&ivt.rate, *argv, 0)) {
-				invarg("Invalid \"rate\" value\n", *argv);
-			}
-			ivt.vf = vf;
-			addattr_l(&req->n, sizeof(*req), IFLA_VF_TX_RATE, &ivt, sizeof(ivt));
+			addattr_nest_end(&req->n, vflist);
 #ifdef IFF_DYNAMIC
 		} else if (matches(*argv, "dynamic") == 0) {
 			NEXT_ARG();
