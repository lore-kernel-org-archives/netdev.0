From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch iproute2 2/4] iplink: implement setting of master device
Date: Sun, 13 Feb 2011 20:32:09 +0100
Message-ID: <20110213193208.GE2740@psychotron.redhat.com>
References: <20110213193105.GD2740@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754762Ab1BMTcQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 14:32:16 -0500
Content-Disposition: inline
In-Reply-To: <20110213193105.GD2740@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 ip/iplink.c   |   16 ++++++++++++++++
 man/man8/ip.8 |   15 ++++++++++++++-
 2 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index cb2c4f5..7a1722c 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -71,6 +71,8 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
 	fprintf(stderr, "				   [ rate TXRATE ] ] \n");
+	fprintf(stderr, "			  [ master DEVICE ]\n");
+	fprintf(stderr, "			  [ nomaster ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
 
 	if (iplink_have_newlink()) {
@@ -361,6 +363,20 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			if (len < 0)
 				return -1;
 			addattr_nest_end(&req->n, vflist);
+#ifdef IFLA_MASTER
+		} else if (matches(*argv, "master") == 0) {
+			int ifindex;
+			NEXT_ARG();
+			ifindex = ll_name_to_index(*argv);
+			if (!ifindex)
+				invarg("Device does not exist\n", *argv);
+			addattr_l(&req->n, sizeof(*req), IFLA_MASTER,
+				  &ifindex, 4);
+		} else if (matches(*argv, "nomaster") == 0) {
+			int ifindex = 0;
+			addattr_l(&req->n, sizeof(*req), IFLA_MASTER,
+				  &ifindex, 4);
+#endif
 #ifdef IFF_DYNAMIC
 		} else if (matches(*argv, "dynamic") == 0) {
 			NEXT_ARG();
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 8d55fa9..a473868 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -95,7 +95,12 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .B qos
 .IR VLAN-QOS " ] ] ["
 .B rate
-.IR TXRATE " ]"
+.IR TXRATE " ] |"
+.br
+.B master
+.IR DEVICE
+.br
+.B nomaster
 
 .ti -8
 .B ip link show
@@ -1038,6 +1043,14 @@ Setting this parameter to 0 disables rate limiting. The
 parameter must be specified.
 .in -8
 
+.TP
+.BI master " DEVICE"
+set master device of the device (enslave device).
+
+.TP
+.BI nomaster
+unset master device of the device (release device).
+
 .PP
 .B Warning:
 If multiple parameter changes are requested,
-- 
1.7.3.4

