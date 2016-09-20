From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH iproute2 net-next] iptnl: add support for collect_md flag in IPv4 and IPv6 tunnels
Date: Mon, 19 Sep 2016 17:03:14 -0700
Message-ID: <1474329794-639615-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        William Tu <u9012063@gmail.com>, <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:40104 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753117AbcITADQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 20:03:16 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8JNxEME032556
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 17:03:15 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25js018jyj-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 17:03:15 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 a04a71227ec511e684a10002c99293a0-a1ffda50 for <netdev@vger.kernel.org>;        Mon,
 19 Sep 2016 17:03:14 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
Stephen,
please sync include/uapi/linux/if_tunnel.h from the kernel tree
before applying.
Thanks
---
 ip/link_ip6tnl.c | 10 ++++++++++
 ip/link_iptnl.c  | 11 +++++++++++
 2 files changed, 21 insertions(+)

diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index 59162a33608f..051c89f4fe57 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -40,6 +40,7 @@ static void print_usage(FILE *f)
 	fprintf(f, "          [ noencap ] [ encap { fou | gue | none } ]\n");
 	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
 	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
+	fprintf(f, "          [ external ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: NAME      := STRING\n");
 	fprintf(f, "       ADDR      := IPV6_ADDRESS\n");
@@ -89,6 +90,7 @@ static int ip6tunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u16 encapflags = TUNNEL_ENCAP_FLAG_CSUM6;
 	__u16 encapsport = 0;
 	__u16 encapdport = 0;
+	__u8 metadata = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
@@ -141,6 +143,8 @@ static int ip6tunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 
 		if (iptuninfo[IFLA_IPTUN_PROTO])
 			proto = rta_getattr_u8(iptuninfo[IFLA_IPTUN_PROTO]);
+		if (iptuninfo[IFLA_IPTUN_COLLECT_METADATA])
+			metadata = 1;
 	}
 
 	while (argc > 0) {
@@ -277,12 +281,18 @@ static int ip6tunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 			encapflags |= TUNNEL_ENCAP_FLAG_REMCSUM;
 		} else if (strcmp(*argv, "noencap-remcsum") == 0) {
 			encapflags |= ~TUNNEL_ENCAP_FLAG_REMCSUM;
+		} else if (strcmp(*argv, "external") == 0) {
+			metadata = 1;
 		} else
 			usage();
 		argc--, argv++;
 	}
 
 	addattr8(n, 1024, IFLA_IPTUN_PROTO, proto);
+	if (metadata) {
+		addattr_l(n, 1024, IFLA_IPTUN_COLLECT_METADATA, NULL, 0);
+		return 0;
+	}
 	addattr_l(n, 1024, IFLA_IPTUN_LOCAL, &laddr, sizeof(laddr));
 	addattr_l(n, 1024, IFLA_IPTUN_REMOTE, &raddr, sizeof(raddr));
 	addattr8(n, 1024, IFLA_IPTUN_TTL, hop_limit);
diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index 7ec377791d88..1875348a268a 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -36,6 +36,7 @@ static void print_usage(FILE *f, int sit)
 		fprintf(f, "          [ mode { ip6ip | ipip | any } ]\n");
 		fprintf(f, "          [ isatap ]\n");
 	}
+	fprintf(f, "          [ external ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: NAME := STRING\n");
 	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
@@ -85,6 +86,7 @@ static int iptunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u16 encapflags = 0;
 	__u16 encapsport = 0;
 	__u16 encapdport = 0;
+	__u8 metadata = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
@@ -161,6 +163,8 @@ static int iptunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 		if (iptuninfo[IFLA_IPTUN_6RD_RELAY_PREFIXLEN])
 			ip6rdrelayprefixlen =
 				rta_getattr_u16(iptuninfo[IFLA_IPTUN_6RD_RELAY_PREFIXLEN]);
+		if (iptuninfo[IFLA_IPTUN_COLLECT_METADATA])
+			metadata = 1;
 	}
 
 	while (argc > 0) {
@@ -257,6 +261,8 @@ static int iptunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 			encapflags |= TUNNEL_ENCAP_FLAG_REMCSUM;
 		} else if (strcmp(*argv, "noencap-remcsum") == 0) {
 			encapflags &= ~TUNNEL_ENCAP_FLAG_REMCSUM;
+		} else if (strcmp(*argv, "external") == 0) {
+			metadata = 1;
 		} else if (strcmp(*argv, "6rd-prefix") == 0) {
 			inet_prefix prefix;
 
@@ -291,6 +297,11 @@ static int iptunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 		exit(-1);
 	}
 
+	if (metadata) {
+		addattr_l(n, 1024, IFLA_IPTUN_COLLECT_METADATA, NULL, 0);
+		return 0;
+	}
+
 	addattr32(n, 1024, IFLA_IPTUN_LINK, link);
 	addattr32(n, 1024, IFLA_IPTUN_LOCAL, laddr);
 	addattr32(n, 1024, IFLA_IPTUN_REMOTE, raddr);
-- 
2.8.0
