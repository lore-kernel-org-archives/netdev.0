From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH rfc 4/4] net-timestamp: expand txtimestamp test with payload and PKTINFO
Date: Tue, 25 Nov 2014 12:58:06 -0500
Message-ID: <1416938286-14147-5-git-send-email-willemb@google.com>
References: <1416938286-14147-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, luto@amacapital.net, richardcochran@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:36152 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbaKYR6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 12:58:15 -0500
Received: by mail-yh0-f43.google.com with SMTP id z6so525396yhz.30
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 09:58:15 -0800 (PST)
In-Reply-To: <1416938286-14147-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Test:
  new: flag -I requests and prints PKTINFO
  new: flag -x prints payload (possibly truncated)
  fix: remove pretty print that breaks common flag '-l 1'

Signed-off-by: Willem de Bruijn <willemb@google.com>

----

I did not modify the documentation yet, to avoid conflicting with
the other queued ee_info -> ee_data patch
---
 .../networking/timestamping/txtimestamp.c          | 89 +++++++++++++++++++---
 1 file changed, 77 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/timestamping/txtimestamp.c b/Documentation/networking/timestamping/txtimestamp.c
index b32fc2a..8946143 100644
--- a/Documentation/networking/timestamping/txtimestamp.c
+++ b/Documentation/networking/timestamping/txtimestamp.c
@@ -46,6 +46,7 @@
 #include <netpacket/packet.h>
 #include <poll.h>
 #include <stdarg.h>
+#include <stdbool.h>
 #include <stdint.h>
 #include <stdio.h>
 #include <stdlib.h>
@@ -58,6 +59,14 @@
 #include <time.h>
 #include <unistd.h>
 
+/* ugly hack to work around netinet/in.h and linux/ipv6.h conflicts */
+#ifndef in6_pktinfo
+struct in6_pktinfo {
+	struct in6_addr	ipi6_addr;
+	int		ipi6_ifindex;
+};
+#endif
+
 /* command line parameters */
 static int cfg_proto = SOCK_STREAM;
 static int cfg_ipproto = IPPROTO_TCP;
@@ -65,6 +74,8 @@ static int cfg_num_pkts = 4;
 static int do_ipv4 = 1;
 static int do_ipv6 = 1;
 static int cfg_payload_len = 10;
+static bool cfg_show_payload;
+static bool cfg_do_pktinfo;
 static uint16_t dest_port = 9000;
 
 static struct sockaddr_in daddr;
@@ -131,6 +142,30 @@ static void print_timestamp(struct scm_timestamping *tss, int tstype,
 	__print_timestamp(tsname, &tss->ts[0], tskey, payload_len);
 }
 
+/* TODO: convert to check_and_print payload once API is stable */
+static void print_payload(char *data, int len)
+{
+	int i;
+
+	if (len > 70)
+		len = 70;
+
+	fprintf(stderr, "payload: ");
+	for (i = 0; i < len; i++)
+		fprintf(stderr, "%02hhx ", data[i]);
+	fprintf(stderr, "\n");
+}
+
+static void print_pktinfo(int family, int ifindex, void *saddr, void *daddr)
+{
+	char sa[INET6_ADDRSTRLEN], da[INET6_ADDRSTRLEN];
+
+	fprintf(stderr, "pktinfo: ifindex=%u src=%s dst=%s\n",
+		ifindex,
+		saddr ? inet_ntop(family, saddr, sa, sizeof(sa)) : "unknown",
+		daddr ? inet_ntop(family, daddr, da, sizeof(da)) : "unknown");
+}
+
 static void __poll(int fd)
 {
 	struct pollfd pollfd;
@@ -156,10 +191,9 @@ static void __recv_errmsg_cmsg(struct msghdr *msg, int payload_len)
 		    cm->cmsg_type == SCM_TIMESTAMPING) {
 			tss = (void *) CMSG_DATA(cm);
 		} else if ((cm->cmsg_level == SOL_IP &&
-		     cm->cmsg_type == IP_RECVERR) ||
-		    (cm->cmsg_level == SOL_IPV6 &&
-		     cm->cmsg_type == IPV6_RECVERR)) {
-
+			    cm->cmsg_type == IP_RECVERR) ||
+			   (cm->cmsg_level == SOL_IPV6 &&
+			    cm->cmsg_type == IPV6_RECVERR)) {
 			serr = (void *) CMSG_DATA(cm);
 			if (serr->ee_errno != ENOMSG ||
 			    serr->ee_origin != SO_EE_ORIGIN_TIMESTAMPING) {
@@ -168,6 +202,16 @@ static void __recv_errmsg_cmsg(struct msghdr *msg, int payload_len)
 						serr->ee_origin);
 				serr = NULL;
 			}
+		} else if (cm->cmsg_level == SOL_IP &&
+			   cm->cmsg_type == IP_PKTINFO) {
+			struct in_pktinfo *info = (void *) CMSG_DATA(cm);
+			print_pktinfo(AF_INET, info->ipi_ifindex,
+				      &info->ipi_spec_dst, &info->ipi_addr);
+		} else if (cm->cmsg_level == SOL_IPV6 &&
+			   cm->cmsg_type == IPV6_PKTINFO) {
+			struct in6_pktinfo *info6 = (void *) CMSG_DATA(cm);
+			print_pktinfo(AF_INET6, info6->ipi6_ifindex,
+				      NULL, &info6->ipi6_addr);
 		} else
 			fprintf(stderr, "unknown cmsg %d,%d\n",
 					cm->cmsg_level, cm->cmsg_type);
@@ -206,7 +250,11 @@ static int recv_errmsg(int fd)
 	if (ret == -1 && errno != EAGAIN)
 		error(1, errno, "recvmsg");
 
-	__recv_errmsg_cmsg(&msg, ret);
+	if (ret > 0) {
+		__recv_errmsg_cmsg(&msg, ret);
+		if (cfg_show_payload)
+			print_payload(data, cfg_payload_len);
+	}
 
 	free(data);
 	return ret == -1;
@@ -215,9 +263,9 @@ static int recv_errmsg(int fd)
 static void do_test(int family, unsigned int opt)
 {
 	char *buf;
-	int fd, i, val, total_len;
+	int fd, i, val = 1, total_len;
 
-	if (family == IPPROTO_IPV6 && cfg_proto != SOCK_STREAM) {
+	if (family == AF_INET6 && cfg_proto != SOCK_STREAM) {
 		/* due to lack of checksum generation code */
 		fprintf(stderr, "test: skipping datagram over IPv6\n");
 		return;
@@ -239,7 +287,6 @@ static void do_test(int family, unsigned int opt)
 		error(1, errno, "socket");
 
 	if (cfg_proto == SOCK_STREAM) {
-		val = 1;
 		if (setsockopt(fd, IPPROTO_TCP, TCP_NODELAY,
 			       (char*) &val, sizeof(val)))
 			error(1, 0, "setsockopt no nagle");
@@ -253,6 +300,18 @@ static void do_test(int family, unsigned int opt)
 		}
 	}
 
+	if (cfg_do_pktinfo) {
+		if (family == AF_INET6) {
+			if (setsockopt(fd, SOL_IPV6, IPV6_RECVPKTINFO,
+				       &val, sizeof(val)))
+				error(1, errno, "setsockopt pktinfo ipv6");
+		} else {
+			if (setsockopt(fd, SOL_IP, IP_PKTINFO,
+				       &val, sizeof(val)))
+				error(1, errno, "setsockopt pktinfo ipv4");
+		}
+	}
+
 	opt |= SOF_TIMESTAMPING_SOFTWARE |
 	       SOF_TIMESTAMPING_OPT_ID;
 	if (setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING,
@@ -262,8 +321,6 @@ static void do_test(int family, unsigned int opt)
 	for (i = 0; i < cfg_num_pkts; i++) {
 		memset(&ts_prev, 0, sizeof(ts_prev));
 		memset(buf, 'a' + i, total_len);
-		buf[total_len - 2] = '\n';
-		buf[total_len - 1] = '\0';
 
 		if (cfg_proto == SOCK_RAW) {
 			struct udphdr *udph;
@@ -324,11 +381,13 @@ static void __attribute__((noreturn)) usage(const char *filepath)
 			"  -4:   only IPv4\n"
 			"  -6:   only IPv6\n"
 			"  -h:   show this message\n"
+			"  -I:   request PKTINFO\n"
 			"  -l N: send N bytes at a time\n"
 			"  -r:   use raw\n"
 			"  -R:   use raw (IP_HDRINCL)\n"
 			"  -p N: connect to port N\n"
-			"  -u:   use udp\n",
+			"  -u:   use udp\n"
+			"  -x:   show payload (up to 70 bytes)\n",
 			filepath);
 	exit(1);
 }
@@ -338,7 +397,7 @@ static void parse_opt(int argc, char **argv)
 	int proto_count = 0;
 	char c;
 
-	while ((c = getopt(argc, argv, "46hl:p:rRu")) != -1) {
+	while ((c = getopt(argc, argv, "46hIl:p:rRux")) != -1) {
 		switch (c) {
 		case '4':
 			do_ipv6 = 0;
@@ -346,6 +405,9 @@ static void parse_opt(int argc, char **argv)
 		case '6':
 			do_ipv4 = 0;
 			break;
+		case 'I':
+			cfg_do_pktinfo = true;
+			break;
 		case 'r':
 			proto_count++;
 			cfg_proto = SOCK_RAW;
@@ -367,6 +429,9 @@ static void parse_opt(int argc, char **argv)
 		case 'p':
 			dest_port = strtoul(optarg, NULL, 10);
 			break;
+		case 'x':
+			cfg_show_payload = true;
+			break;
 		case 'h':
 		default:
 			usage(argv[0]);
-- 
2.1.0.rc2.206.gedb03e5
