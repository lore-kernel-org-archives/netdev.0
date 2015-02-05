From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 29/29] iproute2: Add vrf option to ip link command
Date: Wed,  4 Feb 2015 18:34:30 -0700
Message-ID: <1423100070-31848-30-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:51930 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756325AbbBEBgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:19 -0500
Received: by mail-ig0-f169.google.com with SMTP id hl2so35357202igb.0
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:18 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add option to ip link to change the vrf context on a netdevice.
e.g., ip link set dev eth4 vrf 99

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 bridge/link.c           | 3 +++
 include/linux/if_link.h | 2 ++
 ip/ipaddress.c          | 2 ++
 ip/iplink.c             | 9 +++++++++
 4 files changed, 16 insertions(+)

diff --git a/bridge/link.c b/bridge/link.c
index c8555f82d5b4..520e656f3bf8 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -146,6 +146,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 	print_link_flags(fp, ifi->ifi_flags);
 
+	if (tb[IFLA_VRF])
+		fprintf(fp, "vrf %u ", rta_getattr_u32(tb[IFLA_VRF]));
+
 	if (tb[IFLA_MTU])
 		fprintf(fp, "mtu %u ", rta_getattr_u32(tb[IFLA_MTU]));
 
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 167ec34bab73..c261d3040b88 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -146,6 +146,8 @@ enum {
 	IFLA_PHYS_PORT_ID,
 	IFLA_CARRIER_CHANGES,
 	IFLA_PHYS_SWITCH_ID,
+	IFLA_LINK_NETNSID,
+	IFLA_VRF,
 	__IFLA_MAX
 };
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index d5e863dd1f12..f4001e0ef8cb 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -625,6 +625,8 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 	if (tb[IFLA_MTU])
 		fprintf(fp, "mtu %u ", *(int*)RTA_DATA(tb[IFLA_MTU]));
+	if (tb[IFLA_VRF])
+		fprintf(fp, "vrf %u ", *(int*)RTA_DATA(tb[IFLA_VRF]));
 	if (tb[IFLA_QDISC])
 		fprintf(fp, "qdisc %s ", rta_getattr_str(tb[IFLA_QDISC]));
 	if (tb[IFLA_MASTER]) {
diff --git a/ip/iplink.c b/ip/iplink.c
index c93d1dc3d5f6..0474293527c5 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -72,6 +72,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ mtu MTU ]\n");
 	fprintf(stderr, "	                  [ netns PID ]\n");
 	fprintf(stderr, "	                  [ netns NAME ]\n");
+	fprintf(stderr, "	                  [ vrf ID]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
@@ -383,6 +384,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	int mtu = -1;
 	int netns = -1;
 	int vf = -1;
+	int vrf = -1;
 	int numtxqueues = -1;
 	int numrxqueues = -1;
 	int dev_index = 0;
@@ -447,6 +449,13 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				addattr_l(&req->n, sizeof(*req), IFLA_NET_NS_PID, &netns, 4);
 			else
 				invarg("Invalid \"netns\" value\n", *argv);
+		} else if (strcmp(*argv, "vrf") == 0) {
+			NEXT_ARG();
+			if (vrf != -1)
+				duparg("vrf", *argv);
+			if (get_integer(&vrf, *argv, 0))
+				invarg("Invalid \"vrf\" value\n", *argv);
+			addattr_l(&req->n, sizeof(*req), IFLA_VRF, &vrf, 4);
 		} else if (strcmp(*argv, "multicast") == 0) {
 			NEXT_ARG();
 			req->i.ifi_change |= IFF_MULTICAST;
-- 
1.9.3 (Apple Git-50)
