From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2 iproute2-next 3/4] iplink: add support of IFLA_LINK_NETNSID attribute
Date: Wed, 28 Jan 2015 15:15:49 +0100
Message-ID: <1422454550-32222-3-git-send-email-nicolas.dichtel@6wind.com>
References: <54C8E3EB.8050904@6wind.com>
 <1422454550-32222-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:44110 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754899AbbA1UPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:15:15 -0500
In-Reply-To: <1422454550-32222-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new attribute is now advertised by the kernel for x-netns interfaces.
It's also possible to set it when an interface is created (and thus creating a
x-netns interface with one single message).

Example:
 $ ip netns add foo
 $ ip netns add bar
 $ ip -n foo netns set bar 15
 $ ip -n foo link add ipip1 link-netnsid 15 type ipip remote 10.16.0.121 local 10.16.0.249
 $ ip -n foo link ls ipip1
 3: ipip1@NONE: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT group default
     link/ipip 10.16.0.249 peer 10.16.0.121 link-netnsid 15

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: don't try to convert IFLA_LINK to the devname when IFLA_LINK_NETNSID is set

 ip/ipaddress.c | 20 +++++++++++++++++---
 ip/iplink.c    | 10 ++++++++++
 2 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index d5e863dd1f12..8bc28b8a12c8 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -28,6 +28,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/sockios.h>
+#include <linux/net_namespace.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -614,9 +615,13 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		if (iflink == 0)
 			fprintf(fp, "@NONE: ");
 		else {
-			fprintf(fp, "@%s: ", ll_idx_n2a(iflink, b1));
-			m_flag = ll_index_to_flags(iflink);
-			m_flag = !(m_flag & IFF_UP);
+			if (tb[IFLA_LINK_NETNSID])
+				fprintf(fp, "@if%d: ", iflink);
+			else {
+				fprintf(fp, "@%s: ", ll_idx_n2a(iflink, b1));
+				m_flag = ll_index_to_flags(iflink);
+				m_flag = !(m_flag & IFF_UP);
+			}
 		}
 	} else {
 		fprintf(fp, ": ");
@@ -678,6 +683,15 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		}
 	}
 
+	if (tb[IFLA_LINK_NETNSID]) {
+		int id = *(int*)RTA_DATA(tb[IFLA_LINK_NETNSID]);
+
+		if (id >= 0)
+			fprintf(fp, " link-netnsid %d", id);
+		else
+			fprintf(fp, " link-netnsid unknown");
+	}
+
 	if (tb[IFLA_PROMISCUITY] && show_details)
 		fprintf(fp, " promiscuity %u ",
 			*(int*)RTA_DATA(tb[IFLA_PROMISCUITY]));
diff --git a/ip/iplink.c b/ip/iplink.c
index c93d1dc3d5f6..5893ee401cf9 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -72,6 +72,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ mtu MTU ]\n");
 	fprintf(stderr, "	                  [ netns PID ]\n");
 	fprintf(stderr, "	                  [ netns NAME ]\n");
+	fprintf(stderr, "                         [ link-netnsid ID ]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
@@ -386,6 +387,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	int numtxqueues = -1;
 	int numrxqueues = -1;
 	int dev_index = 0;
+	int link_netnsid = -1;
 
 	*group = -1;
 	ret = argc;
@@ -588,6 +590,14 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			addattr8(&req->n, sizeof(*req), IFLA_INET6_ADDR_GEN_MODE, mode);
 			addattr_nest_end(&req->n, afs6);
 			addattr_nest_end(&req->n, afs);
+		} else if (matches(*argv, "link-netnsid") == 0) {
+			NEXT_ARG();
+			if (link_netnsid != -1)
+				duparg("link-netnsid", *argv);
+			if (get_integer(&link_netnsid, *argv, 0))
+				invarg("Invalid \"link-netnsid\" value\n", *argv);
+			addattr32(&req->n, sizeof(*req), IFLA_LINK_NETNSID,
+				  link_netnsid);
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
-- 
2.2.2
