From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [iproute2 PATCH 3/4] ip: Add support for SR-IOV function link
	parameters
Date: Sat, 30 Jan 2010 02:43:07 -0800
Message-ID: <20100130104307.26719.64855.stgit@localhost.localdomain>
References: <20100130104226.26719.21774.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:46771 "EHLO
	qmta01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752620Ab0A3Kn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 05:43:26 -0500
In-Reply-To: <20100130104226.26719.21774.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Add support to 'ip' for setting and showing SR-IOV virtual function link
parameters.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 ip/ipaddress.c |   23 +++++++++++++++++++++++
 ip/iplink.c    |   39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+), 0 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 91c7b1b..d39a675 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -331,6 +331,29 @@ int print_linkinfo(const struct sockaddr_nl *who,
 				);
 		}
 	}
+	if (do_link && tb[IFLA_VFINFO] && tb[IFLA_NUM_VF]) {
+		SPRINT_BUF(b1);
+		struct rtattr *rta = tb[IFLA_VFINFO];
+		struct ifla_vf_info *ivi;
+		int i;
+		for (i = 0; i < *(int *)RTA_DATA(tb[IFLA_NUM_VF]); i++) {
+			if (rta->rta_type != IFLA_VFINFO) {
+				fprintf(stderr, "BUG: rta type is %d\n", rta->rta_type);
+				break;
+			}
+			ivi = RTA_DATA(rta);
+			fprintf(fp, "\n    vf %d: MAC %s",
+				ivi->vf,
+				ll_addr_n2a((unsigned char *)&ivi->mac,
+					    ETH_ALEN, 0, b1, sizeof(b1)));
+				if (ivi->vlan)
+					fprintf(fp, ", vlan %d", ivi->vlan);
+				if (ivi->tx_rate)
+					fprintf(fp, ", tx rate %d (Mbps_",
+						ivi->tx_rate);
+			rta = (struct rtattr *)((char *)rta + RTA_ALIGN(rta->rta_len));
+		}
+	}
 	fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
diff --git a/ip/iplink.c b/ip/iplink.c
index 32cce24..88a5606 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -68,6 +68,9 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ mtu MTU ]\n");
 	fprintf(stderr, "	                  [ netns PID ]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
+	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
+	fprintf(stderr, "				   [ vlan VLANID ] ] \n");
+	fprintf(stderr, "				   [ rate TXRATE ] ] \n");
 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
 
 	if (iplink_have_newlink()) {
@@ -181,6 +184,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	int qlen = -1;
 	int mtu = -1;
 	int netns = -1;
+	int vf = -1;
 
 	ret = argc;
 
@@ -278,6 +282,41 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				req->i.ifi_flags |= IFF_NOARP;
 			} else
 				return on_off("noarp");
+		} else if (strcmp(*argv, "vf") == 0) {
+			NEXT_ARG();
+			if (get_integer(&vf,  *argv, 0)) {
+				invarg("Invalid \"vf\" value\n", *argv);
+			}
+		} else if (matches(*argv, "mac") == 0) {
+			struct ifla_vf_mac ivm;
+			NEXT_ARG();
+			if (vf < 0)
+				missarg("vf");
+			ivm.vf = vf;
+			len = ll_addr_a2n((char *)ivm.mac, 32, *argv);
+			if (len < 0)
+				return -1;
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_MAC, &ivm, sizeof(ivm));
+		} else if (matches(*argv, "vlan") == 0) {
+			struct ifla_vf_vlan ivv;
+			NEXT_ARG();
+			if (vf < 0)
+				missarg("vf");
+			if (get_integer(&ivv.vlan, *argv, 0)) {
+				invarg("Invalid \"vlan\" value\n", *argv);
+			}
+			ivv.vf = vf;
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_VLAN, &ivv, sizeof(ivv));
+		} else if (matches(*argv, "rate") == 0) {
+			struct ifla_vf_tx_rate ivt;
+			NEXT_ARG();
+			if (vf < 0)
+				missarg("vf");
+			if (get_unsigned(&ivt.rate, *argv, 0)) {
+				invarg("Invalid \"rate\" value\n", *argv);
+			}
+			ivt.vf = vf;
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_TX_RATE, &ivt, sizeof(ivt));
 #ifdef IFF_DYNAMIC
 		} else if (matches(*argv, "dynamic") == 0) {
 			NEXT_ARG();

