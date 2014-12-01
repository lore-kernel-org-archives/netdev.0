From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 3/3] net-timestamp: expand documentation and test
Date: Sun, 30 Nov 2014 22:22:35 -0500
Message-ID: <1417404155-28607-4-git-send-email-willemb@google.com>
References: <1417404155-28607-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, luto@amacapital.net, richardcochran@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:43477 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbaLADWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 22:22:43 -0500
Received: by mail-yk0-f169.google.com with SMTP id 79so4380706ykr.14
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 19:22:43 -0800 (PST)
In-Reply-To: <1417404155-28607-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Documentation:
  expand explanation of timestamp counter

Test:
  new: flag -I requests and prints PKTINFO
  new: flag -x prints payload (possibly truncated)
  fix: remove pretty print that breaks common flag '-l 1'

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 Documentation/networking/timestamping.txt          | 23 ++++--
 .../networking/timestamping/txtimestamp.c          | 90 +++++++++++++++++++---
 2 files changed, 93 insertions(+), 20 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index b08e272..a5c784c 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -130,19 +130,26 @@ SOF_TIMESTAMPING_OPT_ID:
   have multiple concurrent timestamping requests outstanding. Packets
   can be reordered in the transmit path, for instance in the packet
   scheduler. In that case timestamps will be queued onto the error
-  queue out of order from the original send() calls. This option
-  embeds a counter that is incremented at send() time, to order
-  timestamps within a flow.
+  queue out of order from the original send() calls. It is not always
+  possible to uniquely match timestamps to the original send() calls
+  based on timestamp order or payload inspection alone, then.
+
+  This option associates each packet at send() with a unique
+  identifier and returns that along with the timestamp. The identifier
+  is derived from a per-socket u32 counter (that wraps). For datagram
+  sockets, the counter increments with each sent packet. For stream
+  sockets, it increments with every byte.
+
+  The counter starts at zero. It is initialized the first time that
+  the socket option is enabled. It is reset each time the option is
+  enabled after having been disabled. Resetting the counter does not
+  change the identifiers of existing packets in the system.
 
   This option is implemented only for transmit timestamps. There, the
   timestamp is always looped along with a struct sock_extended_err.
   The option modifies field ee_data to pass an id that is unique
   among all possibly concurrently outstanding timestamp requests for
-  that socket. In practice, it is a monotonically increasing u32
-  (that wraps).
-
-  In datagram sockets, the counter increments on each send call. In
-  stream sockets, it increments with every byte.
+  that socket.
 
 
 SOF_TIMESTAMPING_OPT_CMSG:
diff --git a/Documentation/networking/timestamping/txtimestamp.c b/Documentation/networking/timestamping/txtimestamp.c
index b32fc2a..876f71c 100644
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
+	fprintf(stderr, "         pktinfo: ifindex=%u src=%s dst=%s\n",
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
@@ -253,7 +300,20 @@ static void do_test(int family, unsigned int opt)
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
+	       SOF_TIMESTAMPING_OPT_CMSG |
 	       SOF_TIMESTAMPING_OPT_ID;
 	if (setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING,
 		       (char *) &opt, sizeof(opt)))
@@ -262,8 +322,6 @@ static void do_test(int family, unsigned int opt)
 	for (i = 0; i < cfg_num_pkts; i++) {
 		memset(&ts_prev, 0, sizeof(ts_prev));
 		memset(buf, 'a' + i, total_len);
-		buf[total_len - 2] = '\n';
-		buf[total_len - 1] = '\0';
 
 		if (cfg_proto == SOCK_RAW) {
 			struct udphdr *udph;
@@ -324,11 +382,13 @@ static void __attribute__((noreturn)) usage(const char *filepath)
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
@@ -338,7 +398,7 @@ static void parse_opt(int argc, char **argv)
 	int proto_count = 0;
 	char c;
 
-	while ((c = getopt(argc, argv, "46hl:p:rRu")) != -1) {
+	while ((c = getopt(argc, argv, "46hIl:p:rRux")) != -1) {
 		switch (c) {
 		case '4':
 			do_ipv6 = 0;
@@ -346,6 +406,9 @@ static void parse_opt(int argc, char **argv)
 		case '6':
 			do_ipv4 = 0;
 			break;
+		case 'I':
+			cfg_do_pktinfo = true;
+			break;
 		case 'r':
 			proto_count++;
 			cfg_proto = SOCK_RAW;
@@ -367,6 +430,9 @@ static void parse_opt(int argc, char **argv)
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
2.2.0.rc0.207.ga3a616c
