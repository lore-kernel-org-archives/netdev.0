From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH] ip: iplink_vlan: add 802.1ad support
Date: Fri, 19 Apr 2013 14:09:51 +0200
Message-ID: <1366373391-10534-2-git-send-email-kaber@trash.net>
References: <1366373391-10534-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46162 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968257Ab3DSMJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 08:09:54 -0400
In-Reply-To: <1366373391-10534-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/if_link.h |  1 +
 ip/iplink_vlan.c        | 27 +++++++++++++++++++++++----
 lib/ll_proto.c          |  2 ++
 3 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 8ca3afe..8ffd1fd 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -246,6 +246,7 @@ enum {
 	IFLA_VLAN_FLAGS,
 	IFLA_VLAN_EGRESS_QOS,
 	IFLA_VLAN_INGRESS_QOS,
+	IFLA_VLAN_PROTOCOL,
 	__IFLA_VLAN_MAX,
 };
 
diff --git a/ip/iplink_vlan.c b/ip/iplink_vlan.c
index 97af8d6..c08f7ca 100644
--- a/ip/iplink_vlan.c
+++ b/ip/iplink_vlan.c
@@ -21,9 +21,11 @@
 static void explain(void)
 {
 	fprintf(stderr,
-		"Usage: ... vlan id VLANID [ FLAG-LIST ]\n"
-		"                          [ ingress-qos-map QOS-MAP ] [ egress-qos-map QOS-MAP ]\n"
+		"Usage: ... vlan [ protocol VLANPROTO ] id VLANID"
+		"                [ FLAG-LIST ]\n"
+		"                [ ingress-qos-map QOS-MAP ] [ egress-qos-map QOS-MAP ]\n"
 		"\n"
+		"VLANPROTO: [ 802.1Q / 802.1ad ]\n"
 		"VLANID := 0-4095\n"
 		"FLAG-LIST := [ FLAG-LIST ] FLAG\n"
 		"FLAG := [ reorder_hdr { on | off } ] [ gvrp { on | off } ]\n"
@@ -77,10 +79,15 @@ static int vlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			  struct nlmsghdr *n)
 {
 	struct ifla_vlan_flags flags = { 0 };
-	__u16 id;
+	__u16 id, proto;
 
 	while (argc > 0) {
-		if (matches(*argv, "id") == 0) {
+		if (matches(*argv, "protocol") == 0) {
+			NEXT_ARG();
+			if (ll_proto_a2n(&proto, *argv))
+				invarg("protocol is invalid", *argv);
+			addattr_l(n, 1024, IFLA_VLAN_PROTOCOL, &proto, 2);
+		} else if (matches(*argv, "id") == 0) {
 			NEXT_ARG();
 			if (get_u16(&id, *argv, 0))
 				invarg("id is invalid", *argv);
@@ -176,13 +183,25 @@ static void vlan_print_flags(FILE *fp, __u32 flags)
 static void vlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 {
 	struct ifla_vlan_flags *flags;
+	SPRINT_BUF(b1);
+
 	if (!tb)
 		return;
 
+	if (tb[IFLA_VLAN_PROTOCOL] &&
+	    RTA_PAYLOAD(tb[IFLA_VLAN_PROTOCOL]) < sizeof(__u16))
+		return;
 	if (!tb[IFLA_VLAN_ID] ||
 	    RTA_PAYLOAD(tb[IFLA_VLAN_ID]) < sizeof(__u16))
 		return;
 
+	if (tb[IFLA_VLAN_PROTOCOL])
+		fprintf(f, "protocol %s ",
+			ll_proto_n2a(rta_getattr_u16(tb[IFLA_VLAN_PROTOCOL]),
+				     b1, sizeof(b1)));
+	else
+		fprintf(f, "protocol 802.1q ");
+
 	fprintf(f, "id %u ", rta_getattr_u16(tb[IFLA_VLAN_ID]));
 
 	if (tb[IFLA_VLAN_FLAGS]) {
diff --git a/lib/ll_proto.c b/lib/ll_proto.c
index 3337b14..23d2a9b 100644
--- a/lib/ll_proto.c
+++ b/lib/ll_proto.c
@@ -78,6 +78,8 @@ __PF(IRDA,irda)
 __PF(ECONET,econet)
 __PF(TIPC,tipc)
 __PF(AOE,aoe)
+__PF(8021Q,802.1Q)
+__PF(8021AD,802.1ad)
 
 { 0x8100, "802.1Q" },
 { 0x88cc, "LLDP" },
-- 
1.8.1.4
