From: Tom Herbert <therbert@google.com>
Subject: [PATCH iproute2 2/4] vxlan: Add support for remote checksum offload
Date: Thu, 29 Jan 2015 08:51:59 -0800
Message-ID: <1422550321-30901-3-git-send-email-therbert@google.com>
References: <1422550321-30901-1-git-send-email-therbert@google.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:41377 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623AbbA2QxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 11:53:20 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so13659941igj.4
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 08:53:20 -0800 (PST)
In-Reply-To: <1422550321-30901-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to remote checksum checksum offload
to VXLAN. This patch adds remcsumtx and remcsumrx to ip vxlan
configuration to enable remote checksum offload for transmit
and receive on the VXLAN tunnel.

https://tools.ietf.org/html/draft-herbert-vxlan-rco-00

Example:

ip link add name vxlan0 type vxlan id 42 group 239.1.1.1 dev eth0 \
    udpcsum remcsumtx remcsumrx

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/if_link.h |  2 ++
 ip/iplink_vxlan.c       | 21 +++++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 167ec34..11df025 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -368,6 +368,8 @@ enum {
 	IFLA_VXLAN_UDP_CSUM,
 	IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
 	IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
+	IFLA_VXLAN_REMCSUM_TX,
+	IFLA_VXLAN_REMCSUM_RX,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 9cc3ec3..8fb11df 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -30,6 +30,7 @@ static void print_explain(FILE *f)
 	fprintf(f, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
 	fprintf(f, "                 [ ageing SECONDS ] [ maxaddress NUMBER ]\n");
 	fprintf(f, "                 [ [no]udpcsum ] [ [no]udp6zerocsumtx ] [ [no]udp6zerocsumrx ]\n");
+	fprintf(f, "                 [ [no]remcsumtx ] [ [no]remcsumrx ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: VNI := 0-16777215\n");
 	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
@@ -68,6 +69,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 udpcsum = 0;
 	__u8 udp6zerocsumtx = 0;
 	__u8 udp6zerocsumrx = 0;
+	__u8 remcsumtx = 0;
+	__u8 remcsumrx = 0;
 	int dst_port_set = 0;
 	struct ifla_vxlan_port_range range = { 0, 0 };
 
@@ -197,6 +200,14 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			udp6zerocsumrx = 1;
 		} else if (!matches(*argv, "noudp6zerocsumrx")) {
 			udp6zerocsumrx = 0;
+		} else if (!matches(*argv, "remcsumtx")) {
+			remcsumtx = 1;
+		} else if (!matches(*argv, "noremcsumtx")) {
+			remcsumtx = 0;
+		} else if (!matches(*argv, "remcsumrx")) {
+			remcsumrx = 1;
+		} else if (!matches(*argv, "noremcsumrx")) {
+			remcsumrx = 0;
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -255,6 +266,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	addattr8(n, 1024, IFLA_VXLAN_UDP_CSUM, udpcsum);
 	addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_TX, udp6zerocsumtx);
 	addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_RX, udp6zerocsumrx);
+	addattr8(n, 1024, IFLA_VXLAN_REMCSUM_TX, remcsumtx);
+	addattr8(n, 1024, IFLA_VXLAN_REMCSUM_RX, remcsumrx);
 
 	if (noage)
 		addattr32(n, 1024, IFLA_VXLAN_AGEING, 0);
@@ -398,6 +411,14 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX] &&
 	    rta_getattr_u8(tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
 		fputs("udp6zerocsumrx ", f);
+
+	if (tb[IFLA_VXLAN_REMCSUM_TX] &&
+	    rta_getattr_u8(tb[IFLA_VXLAN_REMCSUM_TX]))
+		fputs("remcsumtx ", f);
+
+	if (tb[IFLA_VXLAN_REMCSUM_RX] &&
+	    rta_getattr_u8(tb[IFLA_VXLAN_REMCSUM_RX]))
+		fputs("remcsumrx ", f);
 }
 
 static void vxlan_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.2.0.rc0.207.ga3a616c
