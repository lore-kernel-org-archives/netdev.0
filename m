From: Masahide Nakamura <nakam@linux-ipv6.org>
Subject: [PATCH] [iproute2] XFRM: support ICMP/ICMPv6's type and code
Date: Mon, 6 Sep 2004 16:47:42 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040906164742.54795bf4@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch supports ICMP/ICMPv6's type and code in IPsec
selector. Kernel has supported this feature from 2.6.9-rc1.

The ChangeSet is also available at:
<bk://bk.skbuff.net:38000/iproute2-icmp/>


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/01 14:45:04+09:00 nakam@linux-ipv6.org 
#   support ICMP and ICMPv6's type/code for IPsec.
# 
# ip/xfrm_state.c
#   2004/09/01 14:44:59+09:00 nakam@linux-ipv6.org +3 -1
#   fix usage.
# 
# ip/xfrm_policy.c
#   2004/09/01 14:44:59+09:00 nakam@linux-ipv6.org +2 -1
#   fix usage.
# 
# ip/ipxfrm.c
#   2004/09/01 14:44:59+09:00 nakam@linux-ipv6.org +75 -4
#   ICMP and ICMPv6's type/code can be specified in selector.
#   fix to show sport/dport values when mask is specified.
# 
diff -Nru a/ip/ipxfrm.c b/ip/ipxfrm.c
--- a/ip/ipxfrm.c	2004-09-02 23:08:19 +09:00
+++ b/ip/ipxfrm.c	2004-09-02 23:08:19 +09:00
@@ -352,10 +352,25 @@
 
 	if (sel->proto)
 		fprintf(fp, "proto %s ", strxf_proto(sel->proto));
-	if (sel->sport)
-		fprintf(fp, "sport %u ", ntohs(sel->sport));
-	if (sel->dport)
-		fprintf(fp, "dport %u ", ntohs(sel->dport));
+	switch (sel->proto) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+	case IPPROTO_SCTP:
+	default: /* XXX */
+		if (sel->sport_mask)
+			fprintf(fp, "sport %u ", ntohs(sel->sport));
+		if (sel->dport_mask)
+			fprintf(fp, "dport %u ", ntohs(sel->dport));
+		break;
+	case IPPROTO_ICMP:
+	case IPPROTO_ICMPV6:
+		/* type/code is stored at sport/dport in selector */
+		if (sel->sport_mask)
+			fprintf(fp, "type %u ", ntohs(sel->sport));
+		if (sel->dport_mask)
+			fprintf(fp, "code %u ", ntohs(sel->dport));
+		break;
+	}
 
 	if (sel->ifindex > 0) {
 		char buf[IF_NAMESIZE];
@@ -653,6 +668,10 @@
 {
 	int argc = *argcp;
 	char **argv = *argvp;
+	char *sportp = NULL;
+	char *dportp = NULL;
+	char *typep = NULL;
+	char *codep = NULL;
 
 	while (1) {
 		if (strcmp(*argv, "proto") == 0) {
@@ -677,6 +696,8 @@
 			filter.upspec_proto_mask = XFRM_FILTER_MASK_FULL;
 
 		} else if (strcmp(*argv, "sport") == 0) {
+			sportp = *argv;
+
 			NEXT_ARG();
 
 			if (get_u16(&sel->sport, *argv, 0))
@@ -688,6 +709,8 @@
 			filter.upspec_sport_mask = XFRM_FILTER_MASK_FULL;
 
 		} else if (strcmp(*argv, "dport") == 0) {
+			dportp = *argv;
+
 			NEXT_ARG();
 
 			if (get_u16(&sel->dport, *argv, 0))
@@ -698,6 +721,33 @@
 
 			filter.upspec_dport_mask = XFRM_FILTER_MASK_FULL;
 
+		} else if (strcmp(*argv, "type") == 0) {
+			typep = *argv;
+
+			NEXT_ARG();
+
+			if (get_u16(&sel->sport, *argv, 0) ||
+			    (sel->sport & ~((__u16)0xff)))
+				invarg("\"type\" value is invalid", *argv);
+			sel->sport = htons(sel->sport);
+			sel->sport_mask = ~((__u16)0);
+
+			filter.upspec_sport_mask = XFRM_FILTER_MASK_FULL;
+
+
+		} else if (strcmp(*argv, "code") == 0) {
+			codep = *argv;
+
+			NEXT_ARG();
+
+			if (get_u16(&sel->dport, *argv, 0) ||
+			    (sel->dport & ~((__u16)0xff)))
+				invarg("\"code\" value is invalid", *argv);
+			sel->dport = htons(sel->dport);
+			sel->dport_mask = ~((__u16)0);
+
+			filter.upspec_dport_mask = XFRM_FILTER_MASK_FULL;
+
 		} else {
 			PREV_ARG(); /* back track */
 			break;
@@ -709,6 +759,27 @@
 	}
 	if (argc == *argcp)
 		missarg("UPSPEC");
+	if (sportp || dportp) {
+		switch (sel->proto) {
+		case IPPROTO_TCP:
+		case IPPROTO_UDP:
+		case IPPROTO_SCTP:
+			break;
+		default:
+			fprintf(stderr, "\"sport\" and \"dport\" are invalid with proto=%s\n", strxf_proto(sel->proto));
+			exit(1);
+		}
+	}
+	if (typep || codep) {
+		switch (sel->proto) {
+		case IPPROTO_ICMP:
+		case IPPROTO_ICMPV6:
+			break;
+		default:
+			fprintf(stderr, "\"type\" and \"code\" are invalid with proto=%s\n", strxf_proto(sel->proto));
+			exit(1);
+		}
+	}
 
 	*argcp = argc;
 	*argvp = argv;
diff -Nru a/ip/xfrm_policy.c b/ip/xfrm_policy.c
--- a/ip/xfrm_policy.c	2004-09-02 23:08:19 +09:00
+++ b/ip/xfrm_policy.c	2004-09-02 23:08:19 +09:00
@@ -62,7 +62,8 @@
 
 	fprintf(stderr, "SELECTOR := src ADDR[/PLEN] dst ADDR[/PLEN] [ UPSPEC ] [ dev DEV ]\n");
 
-	fprintf(stderr, "UPSPEC := proto PROTO [ sport PORT ] [ dport PORT ]\n");
+	fprintf(stderr, "UPSPEC := proto PROTO [ [ sport PORT ] [ dport PORT ] |\n");
+	fprintf(stderr, "                        [ type NUMBER ] [ code NUMBER ] ]\n");
 
 	//fprintf(stderr, "DEV - device name(default=none)\n");
 
diff -Nru a/ip/xfrm_state.c b/ip/xfrm_state.c
--- a/ip/xfrm_state.c	2004-09-02 23:08:19 +09:00
+++ b/ip/xfrm_state.c	2004-09-02 23:08:19 +09:00
@@ -91,7 +91,9 @@
 
 	fprintf(stderr, "SELECTOR := src ADDR[/PLEN] dst ADDR[/PLEN] [ upspec UPSPEC ] [ dev DEV ]\n");
 
-	fprintf(stderr, "UPSPEC := proto PROTO [ sport PORT ] [ dport PORT ]\n");
+	fprintf(stderr, "UPSPEC := proto PROTO [ [ sport PORT ] [ dport PORT ] |\n");
+	fprintf(stderr, "                        [ type NUMBER ] [ code NUMBER ] ]\n");
+
 
 	//fprintf(stderr, "DEV - device name(default=none)\n");
 	fprintf(stderr, "LIMIT-LIST := [ LIMIT-LIST ] | [ limit LIMIT ]\n");






-- 
Masahide NAKAMURA
