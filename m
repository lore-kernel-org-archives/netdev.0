From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/2] vxlan: Group policy extension
Date: Thu, 15 Jan 2015 14:54:25 +0100
Message-ID: <f3475ea2a7c8ed8f0876e283172ad0b4c6a581b8.1421329802.git.tgraf@suug.ch>
References: <cover.1421329802.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:57918 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbbAONyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 08:54:32 -0500
In-Reply-To: <cover.1421329802.git.tgraf@suug.ch>
In-Reply-To: <cover.1421329802.git.tgraf@suug.ch>
References: <cover.1421329802.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 ip/iplink_vxlan.c     | 11 +++++++++++
 man/man8/ip-link.8.in | 45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 9cc3ec3..473ff97 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -30,6 +30,7 @@ static void print_explain(FILE *f)
 	fprintf(f, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
 	fprintf(f, "                 [ ageing SECONDS ] [ maxaddress NUMBER ]\n");
 	fprintf(f, "                 [ [no]udpcsum ] [ [no]udp6zerocsumtx ] [ [no]udp6zerocsumrx ]\n");
+	fprintf(f, "                 [ gbp ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: VNI := 0-16777215\n");
 	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
@@ -68,6 +69,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 udpcsum = 0;
 	__u8 udp6zerocsumtx = 0;
 	__u8 udp6zerocsumrx = 0;
+	__u8 gbp = 0;
 	int dst_port_set = 0;
 	struct ifla_vxlan_port_range range = { 0, 0 };
 
@@ -197,6 +199,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			udp6zerocsumrx = 1;
 		} else if (!matches(*argv, "noudp6zerocsumrx")) {
 			udp6zerocsumrx = 0;
+		} else if (!matches(*argv, "gbp")) {
+			gbp = 1;
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -268,6 +272,10 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	if (dstport)
 		addattr16(n, 1024, IFLA_VXLAN_PORT, htons(dstport));
 
+	if (gbp)
+		addattr_l(n, 1024, IFLA_VXLAN_GBP, NULL, 0);
+
+
 	return 0;
 }
 
@@ -398,6 +406,9 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX] &&
 	    rta_getattr_u8(tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
 		fputs("udp6zerocsumrx ", f);
+
+	if (tb[IFLA_VXLAN_GBP])
+		fputs("gbp ", f);
 }
 
 static void vxlan_print_help(struct link_util *lu, int argc, char **argv,
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 1209b55..be52ac6 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -276,6 +276,8 @@ the following additional arguments are supported:
 .BI ageing " SECONDS "
 .R " ] [ "
 .BI maxaddress " NUMBER "
+.R " ] [ "
+.B gbp
 .R " ]"
 
 .in +8
@@ -348,6 +350,49 @@ are entered into the VXLAN device forwarding database.
 .BI maxaddress " NUMBER"
 - specifies the maximum number of FDB entries.
 
+.sp
+.B gbp
+- enables the Group Policy extension (VXLAN-GBP).
+
+.in +4
+Allows to transport group policy context across VXLAN network peers.
+If enabled, includes the mark of a packet in the VXLAN header for outgoing
+packets and fills the packet mark based on the information found in the
+VXLAN header for incomming packets.
+
+Format of upper 16 bits of packet mark (flags);
+
+.in +2
++-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+.br
+|-|-|-|-|-|-|-|-|-|D|-|-|A|-|-|-|
+.br
++-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+
+.B D :=
+Don't Learn bit. When set, this bit indicates that the egress
+VTEP MUST NOT learn the source address of the encapsulated frame.
+
+.B A :=
+Indicates that the group policy has already been applied to
+this packet. Policies MUST NOT be applied by devices when the A bit is set.
+.in -2
+
+Format of lower 16 bits of packet mark (policy ID):
+
+.in +2
++-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+.br
+|        Group Policy ID        |
+.br
++-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+.in -2
+
+Example:
+  iptables -A OUTPUT [...] -j MARK --set-mark 0x800FF
+
+.in -4
+
 .in -8
 
 .TP
-- 
1.9.3
