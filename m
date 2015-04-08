From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [PATCH v2] iputils ping: add (non-raw) ICMP socket support
Date: Wed, 08 Apr 2015 15:24:37 +0200
Message-ID: <1838220.edslgOLZpu@msg-id>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Vasiliy Kulikov <segooon@gmail.com>,
	Tyler Hicks <tyhicks@canonical.com>,
	Salvatore Mesoraca <s.mesoraca16@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:34156 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753354AbbDHNYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 09:24:52 -0400
Received: by widjs5 with SMTP id js5so33030289wid.1
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 06:24:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasiliy Kulikov <segooon@gmail.com>

This patch adds non-raw IPPROTO_ICMP socket kind support that was added
to the Linux 3.0.  The patch is backward-compatible: if ICMP socket kind
is not enabled in the kernel (either in case of an old kernel or
explicitly disabled via /proc/sys/net/ipv4/ping_group_range), ping uses
old privileged raw sockets as a fall-back.

The distributions are free to choose whether ping binary is setgid and
owned by a special group or is just a normal binary.

This patch is based on the original work of Vasiliy Kulikov, but
Tyler Hicks and me did some little modifications.

Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
[tyhicks@canonical.com: changed write() to write_stdout()]
Signed-off-by: Tyler Hicks <tyhicks@canonical.com>
[s.mesoraca16@gmail.com: changed a comment]
Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>

---
V1->V2:
    removed the printf's colon aesthetic fix

This patch is going to be included in Ubuntu 15.10 and it's already
included in Gentoo stable tree (at the moment of the writing ping has
CAP_NET_RAW still enabled by default) it is also included in OpenWall
since 2011.
I've tested it on Linux 3.17.7 and it worked without issues.
---
 ping.c        | 114 ++++++++++++++++++++++++++++++++++++++++++++++------------
 ping_common.c |   3 +-
 2 files changed, 93 insertions(+), 24 deletions(-)

diff --git a/ping.c b/ping.c
index c0366cd..987f357 100644
--- a/ping.c
+++ b/ping.c
@@ -55,7 +55,8 @@ char copyright[] =
  *	Public Domain.  Distribution Unlimited.
  * Bugs -
  *	More statistics could always be gathered.
- *	This program has to run SUID to ROOT to access the ICMP socket.
+ *	This program has to run SUID to ROOT to access the ICMP socket only
+ *	if the kernel does not support non-raw ICMP socket.
  */

 #include "ping_common.h"
@@ -91,6 +92,7 @@ struct sockaddr_in whereto;	/* who to ping */
 int optlen = 0;
 int settos = 0;			/* Set TOS, Precendence or other QOS options */
 int icmp_sock;			/* socket file descriptor */
+int using_ping_socket = 0;
 u_char outpack[0x10000];
 int maxpacket = sizeof(outpack);

@@ -139,7 +141,11 @@ main(int argc, char **argv)

 	enable_capability_raw();

-	icmp_sock = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
+	icmp_sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP);
+	if (icmp_sock != -1)
+		using_ping_socket = 1;
+	else
+		icmp_sock = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
 	socket_errno = errno;

 	disable_capability_raw();
@@ -453,13 +459,35 @@ main(int argc, char **argv)
 		}
 	}

-	if ((options&F_STRICTSOURCE) &&
-	    bind(icmp_sock, (struct sockaddr*)&source, sizeof(source)) == -1) {
-		perror("bind");
-		exit(2);
+	if (!using_ping_socket) {
+		if ((options&F_STRICTSOURCE) &&
+		    bind(icmp_sock, (struct sockaddr*)&source, sizeof(source)) == -1) {
+			perror("bind");
+			exit(2);
+		}
+	} else {
+		struct sockaddr_in sa;
+		socklen_t sl;
+
+		sa.sin_family = AF_INET;
+		sa.sin_port = 0;
+		sa.sin_addr.s_addr = (options&F_STRICTSOURCE) ?
+			source.sin_addr.s_addr : 0;
+		sl = sizeof(sa);
+
+		if (bind(icmp_sock, (struct sockaddr *) &sa, sl) == -1) {
+			perror("bind");
+			exit(2);
+		}
+
+		if (getsockname(icmp_sock, (struct sockaddr *) &sa, &sl) == -1) {
+			perror("getsockname");
+			exit(2);
+		}
+		ident = sa.sin_port;
 	}

-	if (1) {
+	if (!using_ping_socket) {
 		struct icmp_filter filt;
 		filt.data = ~((1<<ICMP_SOURCE_QUENCH)|
 			      (1<<ICMP_DEST_UNREACH)|
@@ -474,6 +502,12 @@ main(int argc, char **argv)
 	hold = 1;
 	if (setsockopt(icmp_sock, SOL_IP, IP_RECVERR, (char *)&hold, sizeof(hold)))
 		fprintf(stderr, "WARNING: your kernel is veeery old. No problems.\n");
+	if (using_ping_socket) {
+		if (setsockopt(icmp_sock, SOL_IP, IP_RECVTTL, (char *)&hold, sizeof(hold)))
+			perror("WARNING: setsockopt(IP_RECVTTL)");
+		if (setsockopt(icmp_sock, SOL_IP, IP_RETOPTS, (char *)&hold, sizeof(hold)))
+			perror("WARNING: setsockopt(IP_RETOPTS)");
+	}

 	/* record route option */
 	if (options & F_RROUTE) {
@@ -642,6 +676,7 @@ int receive_error_msg()
 		nerrors++;
 	} else if (e->ee_origin == SO_EE_ORIGIN_ICMP) {
 		struct sockaddr_in *sin = (struct sockaddr_in*)(e+1);
+		int error_pkt;

 		if (res < sizeof(icmph) ||
 		    target.sin_addr.s_addr != whereto.sin_addr.s_addr ||
@@ -652,9 +687,18 @@ int receive_error_msg()
 			goto out;
 		}

-		acknowledge(ntohs(icmph.un.echo.sequence));
+		error_pkt = (e->ee_type != ICMP_REDIRECT &&
+			     e->ee_type != ICMP_SOURCE_QUENCH);
+		if (error_pkt) {
+			acknowledge(ntohs(icmph.un.echo.sequence));
+			net_errors++;
+			nerrors++;
+		}
+		else {
+			saved_errno = 0;
+		}

-		if (!working_recverr) {
+		if (!using_ping_socket && !working_recverr) {
 			struct icmp_filter filt;
 			working_recverr = 1;
 			/* OK, it works. Add stronger filter. */
@@ -665,12 +709,11 @@ int receive_error_msg()
 				perror("\rWARNING: setsockopt(ICMP_FILTER)");
 		}

-		net_errors++;
-		nerrors++;
 		if (options & F_QUIET)
 			goto out;
 		if (options & F_FLOOD) {
-			write_stdout("\bE", 2);
+			if (error_pkt)
+				write_stdout("\bE", 2);
 		} else {
 			print_timestamp();
 			printf("From %s icmp_seq=%u ", pr_addr(sin->sin_addr.s_addr), ntohs(icmph.un.echo.sequence));
@@ -765,15 +808,41 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 	struct iphdr *ip;
 	int hlen;
 	int csfailed;
+	struct cmsghdr *cmsg;
+	int ttl;
+	__u8 *opts;
+	int optlen;

 	/* Check the IP header */
 	ip = (struct iphdr *)buf;
-	hlen = ip->ihl*4;
-	if (cc < hlen + 8 || ip->ihl < 5) {
-		if (options & F_VERBOSE)
-			fprintf(stderr, "ping: packet too short (%d bytes) from %s\n", cc,
-				pr_addr(from->sin_addr.s_addr));
-		return 1;
+	if (!using_ping_socket) {
+		hlen = ip->ihl*4;
+		if (cc < hlen + 8 || ip->ihl < 5) {
+			if (options & F_VERBOSE)
+				fprintf(stderr, "ping: packet too short (%d bytes) from %s\n", cc,
+					pr_addr(from->sin_addr.s_addr));
+			return 1;
+		}
+		ttl = ip->ttl;
+		opts = buf + sizeof(struct iphdr);
+		optlen = hlen - sizeof(struct iphdr);
+	} else {
+		hlen = 0;
+		ttl = 0;
+		opts = buf;
+		optlen = 0;
+		for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+			if (cmsg->cmsg_level != SOL_IP)
+				continue;
+			if (cmsg->cmsg_type == IP_TTL) {
+				if (cmsg->cmsg_len < sizeof(int))
+					continue;
+				ttl = *(int *) CMSG_DATA(cmsg);
+			} else if (cmsg->cmsg_type == IP_RETOPTS) {
+				opts = (__u8 *) CMSG_DATA(cmsg);
+				optlen = cmsg->cmsg_len;
+			}
+		}
 	}

 	/* Now the ICMP part */
@@ -786,7 +855,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 			return 1;			/* 'Twas not our ECHO */
 		if (gather_statistics((__u8*)icp, sizeof(*icp), cc,
 				      ntohs(icp->un.echo.sequence),
-				      ip->ttl, 0, tv, pr_addr(from->sin_addr.s_addr),
+				      ttl, 0, tv, pr_addr(from->sin_addr.s_addr),
 				      pr_echo_reply))
 			return 0;
 	} else {
@@ -877,7 +946,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 	}

 	if (!(options & F_FLOOD)) {
-		pr_options(buf + sizeof(struct iphdr), hlen);
+		pr_options(opts, optlen + sizeof(struct iphdr));

 		if (options & F_AUDIBLE)
 			putchar('\a');
@@ -1022,8 +1091,7 @@ void pr_icmph(__u8 type, __u8 code, __u32 info, struct icmphdr *icp)
 			printf("Redirect, Bad Code: %d", code);
 			break;
 		}
-		if (icp)
-			printf("(New nexthop: %s)\n", pr_addr(icp->un.gateway));
+		printf("(New nexthop: %s)\n", pr_addr(icp ? icp->un.gateway : info));
 		if (icp && (options & F_VERBOSE))
 			pr_iph((struct iphdr*)(icp + 1));
 		break;
@@ -1339,7 +1407,7 @@ void install_filter(void)
 		insns
 	};

-	if (once)
+	if (once || using_ping_socket)
 		return;
 	once = 1;

diff --git a/ping_common.c b/ping_common.c
index 8d6b145..0342e1a 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -677,7 +677,8 @@ void setup(int icmp_sock)
 			*p++ = i;
 	}

-	ident = htons(getpid() & 0xFFFF);
+	if (!ident)
+		ident = htons(getpid() & 0xFFFF);

 	set_signal(SIGINT, sigexit);
 	set_signal(SIGALRM, sigexit);
--
2.0.5
