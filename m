From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [PATCH v3 2/2] iputils ping/ping6: add (non-raw) ICMP socket support
Date: Tue, 14 Apr 2015 17:18:13 +0200
Message-ID: <29194500.DftZYYgPvL@msg-id>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	Vasiliy Kulikov <segooon@gmail.com>,
	Tyler Hicks <tyhicks@canonical.com>, s.mesoraca16@gmail.com,
	netdev@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:33285 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755643AbbDNPST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 11:18:19 -0400
Received: by wgin8 with SMTP id n8so15785824wgi.0
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 08:18:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows running ping and ping6 without root privileges on
kernels that support it. Almost identical to Lorenzo
Colitti's original patch except:

- Applies to latest git iputils.
- Prevent ICMP_FILTER from being applied to non-raw sockets
- Does not change code formatting
- Changes comments and doc to reflect the new behavior

N.B.
Some functionalities in ping6 still require raw sockets.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 doc/ping.sgml |  5 ++--
 ping.c        | 72 ++++++++++++++++++++++++++++++++++++++++++------------
 ping6.c       | 78 +++++++++++++++++++++++++++++++++++------------------------
 ping_common.c |  9 ++++---
 ping_common.h |  1 +
 5 files changed, 112 insertions(+), 53 deletions(-)

diff --git a/doc/ping.sgml b/doc/ping.sgml
index eec92a2..d005158 100644
--- a/doc/ping.sgml
+++ b/doc/ping.sgml
@@ -628,8 +628,9 @@ The version described here is its descendant specific to Linux.

 <refsect1><title>SECURITY</title>
 <para>
-<command/ping/ requires <constant/CAP_NET_RAW/ capability
-to be executed. It may be used as set-uid root.
+<command/ping/ doesn't require <constant/CAP_NET_RAW/ capability
+to be executed if kernel supports non-raw ICMP sockets.
+Otherwise it can also be used as set-uid root.
 </para>
 </refsect1>

diff --git a/ping.c b/ping.c
index aa6f19f..7610494 100644
--- a/ping.c
+++ b/ping.c
@@ -55,7 +55,9 @@ char copyright[] =
  *	Public Domain.  Distribution Unlimited.
  * Bugs -
  *	More statistics could always be gathered.
- *	This program has to run SUID to ROOT to access the ICMP socket.
+ *	If kernel does not support non-raw ICMP sockets,
+ *	this program has to run SUID to ROOT or with
+ *	net_cap_raw enabled.
  */

 #include "ping_common.h"
@@ -91,6 +93,7 @@ struct sockaddr_in whereto;	/* who to ping */
 int optlen = 0;
 int settos = 0;			/* Set TOS, Precendence or other QOS options */
 int icmp_sock;			/* socket file descriptor */
+extern int using_ping_socket;
 u_char outpack[0x10000];
 int maxpacket = sizeof(outpack);

@@ -138,11 +141,16 @@ main(int argc, char **argv)
 #endif

 	enable_capability_raw();
-
 	icmp_sock = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
+	disable_capability_raw();
+
+	if (icmp_sock < 0) {
+		icmp_sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP);
+		using_ping_socket = 1;
+		working_recverr = 1;
+	}
 	socket_errno = errno;

-	disable_capability_raw();

 	source.sin_family = AF_INET;

@@ -459,7 +467,7 @@ main(int argc, char **argv)
 		exit(2);
 	}

-	if (1) {
+	if (!using_ping_socket) {
 		struct icmp_filter filt;
 		filt.data = ~((1<<ICMP_SOURCE_QUENCH)|
 			      (1<<ICMP_DEST_UNREACH)|
@@ -474,6 +482,14 @@ main(int argc, char **argv)
 	hold = 1;
 	if (setsockopt(icmp_sock, SOL_IP, IP_RECVERR, (char *)&hold, sizeof(hold)))
 		fprintf(stderr, "WARNING: your kernel is veeery old. No problems.\n");
+	if (using_ping_socket) {
+		if (setsockopt(icmp_sock, SOL_IP, IP_RECVTTL,
+		    (char *)&hold, sizeof(hold)))
+			perror("WARNING: setsockopt(IP_RECVTTL)");
+		if (setsockopt(icmp_sock, SOL_IP, IP_RETOPTS,
+		    (char *)&hold, sizeof(hold)))
+			perror("WARNING: setsockopt(IP_RETOPTS)");
+	}

 	/* record route option */
 	if (options & F_RROUTE) {
@@ -654,7 +670,7 @@ int receive_error_msg()

 		acknowledge(ntohs(icmph.un.echo.sequence));

-		if (!working_recverr) {
+		if (!using_ping_socket && !working_recverr) {
 			struct icmp_filter filt;
 			working_recverr = 1;
 			/* OK, it works. Add stronger filter. */
@@ -765,15 +781,41 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
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
@@ -786,7 +828,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 			return 1;			/* 'Twas not our ECHO */
 		if (gather_statistics((__u8*)icp, sizeof(*icp), cc,
 				      ntohs(icp->un.echo.sequence),
-				      ip->ttl, 0, tv, pr_addr(from->sin_addr.s_addr),
+				      ttl, 0, tv, pr_addr(from->sin_addr.s_addr),
 				      pr_echo_reply))
 			return 0;
 	} else {
@@ -877,7 +919,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 	}

 	if (!(options & F_FLOOD)) {
-		pr_options(buf + sizeof(struct iphdr), hlen);
+		pr_options(opts, optlen + sizeof(struct iphdr));

 		if (options & F_AUDIBLE)
 			putchar('\a');
@@ -1022,8 +1064,8 @@ void pr_icmph(__u8 type, __u8 code, __u32 info, struct icmphdr *icp)
 			printf("Redirect, Bad Code: %d", code);
 			break;
 		}
-		if (icp)
-			printf("(New nexthop: %s)\n", pr_addr(icp->un.gateway));
+		printf("(New nexthop: %s)\n",
+		       pr_addr(icp ? icp->un.gateway : info));
 		if (icp && (options & F_VERBOSE))
 			pr_iph((struct iphdr*)(icp + 1));
 		break;
diff --git a/ping6.c b/ping6.c
index e8f581f..7085f31 100644
--- a/ping6.c
+++ b/ping6.c
@@ -64,7 +64,9 @@ char copyright[] =
  *	Public Domain.  Distribution Unlimited.
  * Bugs -
  *	More statistics could always be gathered.
- *	This program has to run SUID to ROOT to access the ICMP socket.
+ *	If kernel does not support non-raw ICMP sockets or
+ *	if -N option is used, this program has to run SUID to ROOT or
+ *	with net_cap_raw enabled.
  */
 #include "ping_common.h"

@@ -711,11 +713,16 @@ int main(int argc, char *argv[])
 #endif

 	enable_capability_raw();
-
 	icmp_sock = socket(AF_INET6, SOCK_RAW, IPPROTO_ICMPV6);
+	disable_capability_raw();
+
+	if (icmp_sock < 0) {
+		icmp_sock = socket(AF_INET6, SOCK_DGRAM, IPPROTO_ICMPV6);
+		using_ping_socket = 1;
+	}
+
 	socket_errno = errno;

-	disable_capability_raw();

 	source.sin6_family = AF_INET6;
 	memset(&firsthop, 0, sizeof(firsthop));
@@ -783,6 +790,10 @@ int main(int argc, char *argv[])
 			printf("ping6 utility, iputils-%s\n", SNAPSHOT);
 			exit(0);
 		case 'N':
+			if (using_ping_socket) {
+				fprintf(stderr, "ping: -N requires raw socket permissions\n");
+				exit(2);
+			}
 			if (niquery_option_handler(optarg) < 0) {
 				usage();
 				break;
@@ -1088,43 +1099,45 @@ int main(int argc, char *argv[])
 	hold += ((hold+511)/512)*(40+16+64+160);
 	sock_setbufs(icmp_sock, hold);

+	if (!using_ping_socket) {
 #ifdef __linux__
-	csum_offset = 2;
-	sz_opt = sizeof(int);
-
-	err = setsockopt(icmp_sock, SOL_RAW, IPV6_CHECKSUM, &csum_offset, sz_opt);
-	if (err < 0) {
-		/* checksum should be enabled by default and setting this
-		 * option might fail anyway.
-		 */
-		fprintf(stderr, "setsockopt(RAW_CHECKSUM) failed - try to continue.");
-	}
+		csum_offset = 2;
+		sz_opt = sizeof(int);
+
+		err = setsockopt(icmp_sock, SOL_RAW, IPV6_CHECKSUM, &csum_offset, sz_opt);
+		if (err < 0) {
+			/* checksum should be enabled by default and setting this
+			 * option might fail anyway.
+			 */
+			fprintf(stderr, "setsockopt(RAW_CHECKSUM) failed - try to continue.");
+		}
 #endif

-	/*
-	 *	select icmp echo reply as icmp type to receive
-	 */
+		/*
+		 *	select icmp echo reply as icmp type to receive
+		 */

-	ICMP6_FILTER_SETBLOCKALL(&filter);
+		ICMP6_FILTER_SETBLOCKALL(&filter);

-	if (!working_recverr) {
-		ICMP6_FILTER_SETPASS(ICMP6_DST_UNREACH, &filter);
-		ICMP6_FILTER_SETPASS(ICMP6_PACKET_TOO_BIG, &filter);
-		ICMP6_FILTER_SETPASS(ICMP6_TIME_EXCEEDED, &filter);
-		ICMP6_FILTER_SETPASS(ICMP6_PARAM_PROB, &filter);
-	}
+		if (!working_recverr) {
+			ICMP6_FILTER_SETPASS(ICMP6_DST_UNREACH, &filter);
+			ICMP6_FILTER_SETPASS(ICMP6_PACKET_TOO_BIG, &filter);
+			ICMP6_FILTER_SETPASS(ICMP6_TIME_EXCEEDED, &filter);
+			ICMP6_FILTER_SETPASS(ICMP6_PARAM_PROB, &filter);
+		}

-	if (niquery_is_enabled())
-		ICMP6_FILTER_SETPASS(ICMPV6_NI_REPLY, &filter);
-	else
-		ICMP6_FILTER_SETPASS(ICMP6_ECHO_REPLY, &filter);
+		if (niquery_is_enabled())
+			ICMP6_FILTER_SETPASS(ICMPV6_NI_REPLY, &filter);
+		else
+			ICMP6_FILTER_SETPASS(ICMP6_ECHO_REPLY, &filter);

-	err = setsockopt(icmp_sock, IPPROTO_ICMPV6, ICMP6_FILTER, &filter,
-			 sizeof(struct icmp6_filter));
+		err = setsockopt(icmp_sock, IPPROTO_ICMPV6, ICMP6_FILTER, &filter,
+				 sizeof(struct icmp6_filter));

-	if (err < 0) {
-		perror("setsockopt(ICMP6_FILTER)");
-		exit(2);
+		if (err < 0) {
+			perror("setsockopt(ICMP6_FILTER)");
+			exit(2);
+		}
 	}

 	if (options & F_NOLOOP) {
@@ -1600,6 +1613,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 	if (icmph->icmp6_type == ICMP6_ECHO_REPLY) {
 		if (!is_ours(icmph->icmp6_id))
 			return 1;
+
 		if (gather_statistics((__u8*)icmph, sizeof(*icmph), cc,
 				      ntohs(icmph->icmp6_seq),
 				      hops, 0, tv, pr_addr(&from->sin6_addr),
diff --git a/ping_common.c b/ping_common.c
index b0a14dc..2718a7e 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -13,6 +13,7 @@ int rtt_addend;
 __u16 acked;

 struct rcvd_table rcvd_tbl;
+int using_ping_socket = 0;


 /* counters */
@@ -677,7 +678,8 @@ void setup(int icmp_sock)
 			*p++ = i;
 	}

-	ident = htons(getpid() & 0xFFFF);
+	if (!using_ping_socket)
+		ident = htons(getpid() & 0xFFFF);

 	set_signal(SIGINT, sigexit);
 	set_signal(SIGALRM, sigexit);
@@ -836,7 +838,7 @@ void main_loop(int icmp_sock, __u8 *packet, int packlen)
 			}

 			/* See? ... someone runs another ping on this host. */
-			if (not_ours)
+			if (not_ours && !using_ping_socket)
 				install_filter();

 			/* If nothing is in flight, "break" returns us to pinger. */
@@ -1073,6 +1075,5 @@ void status(void)
 }

 inline int is_ours(uint16_t id) {
-       return id == ident;
+	return using_ping_socket || id == ident;
 }
-
diff --git a/ping_common.h b/ping_common.h
index a915b95..6add607 100644
--- a/ping_common.h
+++ b/ping_common.h
@@ -127,6 +127,7 @@ extern char *hostname;
 extern int uid;
 extern int ident;			/* process id to identify our packets */

+extern int using_ping_socket;
 extern int sndbuf;
 extern int ttl;

--
2.0.5
