From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/2] iplink: Check address length via netlink
Date: Thu, 16 Jun 2016 16:19:40 +0200
Message-ID: <1466086780-5613-3-git-send-email-phil@nwl.cc>
References: <1466086780-5613-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36168 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754763AbcFPOUA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 10:20:00 -0400
In-Reply-To: <1466086780-5613-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a feature which was lost during the conversion to netlink
interface: If the device exists and a user tries to change the link
layer address, query the kernel for the old address first and reject the
new one if sizes differ.

This patch adds the same check when setting VF address by assuming same
length as PF device.

Note that at least for VFs the check can't be done in kernel space since
struct ifla_vf_mac lacks a length field and due to netlink padding the
exact size can't be communicated to the kernel.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 50 insertions(+), 2 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 4cb9bab66b916..68e5faea3581d 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -237,6 +237,36 @@ struct iplink_req {
 	char			buf[1024];
 };
 
+static int nl_get_ll_addr_len(unsigned int dev_index)
+{
+	int len;
+	struct iplink_req req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
+			.nlmsg_type = RTM_GETLINK,
+			.nlmsg_flags = NLM_F_REQUEST
+		},
+		.i = {
+			.ifi_family = preferred_family,
+			.ifi_index = dev_index,
+		}
+	};
+	struct rtattr *tb[IFLA_MAX+1];
+
+	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
+		return -1;
+
+	len = req.n.nlmsg_len - NLMSG_LENGTH(sizeof(req.i));
+	if (len < 0)
+		return -1;
+
+	parse_rtattr_flags(tb, IFLA_MAX, IFLA_RTA(&req.i), len, NLA_F_NESTED);
+	if (!tb[IFLA_ADDRESS])
+		return -1;
+
+	return RTA_PAYLOAD(tb[IFLA_ADDRESS]);
+}
+
 static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			   struct iplink_req *req, int dev_index)
 {
@@ -274,12 +304,19 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 		NEXT_ARG();
 		if (matches(*argv, "mac") == 0) {
 			struct ifla_vf_mac ivm = { 0 };
+			int halen = nl_get_ll_addr_len(dev_index);
 
 			NEXT_ARG();
 			ivm.vf = vf;
 			len = ll_addr_a2n((char *)ivm.mac, 32, *argv);
 			if (len < 0)
 				return -1;
+			if (halen > 0 && len != halen) {
+				fprintf(stderr,
+					"Invalid address length %d - must be %d bytes\n",
+					len, halen);
+				return -1;
+			}
 			addattr_l(&req->n, sizeof(*req), IFLA_VF_MAC, &ivm, sizeof(ivm));
 		} else if (matches(*argv, "vlan") == 0) {
 			struct ifla_vf_vlan ivv;
@@ -428,6 +465,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	int numrxqueues = -1;
 	int dev_index = 0;
 	int link_netnsid = -1;
+	int addr_len = 0;
 
 	*group = -1;
 	ret = argc;
@@ -452,10 +490,10 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			*link = *argv;
 		} else if (matches(*argv, "address") == 0) {
 			NEXT_ARG();
-			len = ll_addr_a2n(abuf, sizeof(abuf), *argv);
+			addr_len = ll_addr_a2n(abuf, sizeof(abuf), *argv);
 			if (len < 0)
 				return -1;
-			addattr_l(&req->n, sizeof(*req), IFLA_ADDRESS, abuf, len);
+			addattr_l(&req->n, sizeof(*req), IFLA_ADDRESS, abuf, addr_len);
 		} else if (matches(*argv, "broadcast") == 0 ||
 			   strcmp(*argv, "brd") == 0) {
 			NEXT_ARG();
@@ -677,6 +715,16 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		argc--; argv++;
 	}
 
+	if (dev_index && addr_len) {
+		int halen = nl_get_ll_addr_len(dev_index);
+		if (halen >= 0 && halen != addr_len) {
+			fprintf(stderr,
+			        "Invalid address length %d - must be %d bytes\n",
+			        addr_len, halen);
+			return -1;
+		}
+	}
+
 	return ret - argc;
 }
 
-- 
2.8.2
