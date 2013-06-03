From: Lorenzo Colitti <lorenzo@google.com>
Subject: [iputils PATCH 2/2] ping, ping6: Support the ping socket
Date: Mon,  3 Jun 2013 21:50:33 +0900
Message-ID: <1370263833-27271-2-git-send-email-lorenzo@google.com>
References: <1370263833-27271-1-git-send-email-lorenzo@google.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:45533 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755905Ab3FCMuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 08:50:39 -0400
Received: by mail-qc0-f202.google.com with SMTP id d1so362291qcz.1
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 05:50:38 -0700 (PDT)
In-Reply-To: <1370263833-27271-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows running ping and ping6 without root privileges on
kernels that support it (~2011 for IPv6, very recently for
IPv6). Almost identical to Vasiliy's original Openwall patch
for iputils-20101006, except:

- Applies to latest git iputils.
- Supports ping6 as well as ping.
- For compatibility reasons, does not use the ping socket by
  default, but only if creating a raw socket fails.
- A bit shorter because it omits an unrelated fix that affects
  IPv4 redirect and source quench.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 ping.c        | 66 ++++++++++++++++++++++++++++++++++++++++----------
 ping6.c       | 78 +++++++++++++++++++++++++++++++++++------------------------
 ping_common.c |  9 ++++---
 ping_common.h |  1 +
 4 files changed, 105 insertions(+), 49 deletions(-)

diff --git a/ping.c b/ping.c
index aa6f19f..b668b59 100644
--- a/ping.c
+++ b/ping.c
@@ -91,6 +91,7 @@ struct sockaddr_in whereto;	/* who to ping */
 int optlen = 0;
 int settos = 0;			/* Set TOS, Precendence or other QOS options */
 int icmp_sock;			/* socket file descriptor */
+extern int using_ping_socket;
 u_char outpack[0x10000];
 int maxpacket = sizeof(outpack);
 
@@ -138,11 +139,16 @@ main(int argc, char **argv)
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
 
@@ -459,7 +465,7 @@ main(int argc, char **argv)
 		exit(2);
 	}
 
-	if (1) {
+	if (!using_ping_socket) {
 		struct icmp_filter filt;
 		filt.data = ~((1<<ICMP_SOURCE_QUENCH)|
 			      (1<<ICMP_DEST_UNREACH)|
@@ -474,6 +480,14 @@ main(int argc, char **argv)
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
@@ -765,15 +779,41 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
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
@@ -786,7 +826,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 			return 1;			/* 'Twas not our ECHO */
 		if (gather_statistics((__u8*)icp, sizeof(*icp), cc,
 				      ntohs(icp->un.echo.sequence),
-				      ip->ttl, 0, tv, pr_addr(from->sin_addr.s_addr),
+				      ttl, 0, tv, pr_addr(from->sin_addr.s_addr),
 				      pr_echo_reply))
 			return 0;
 	} else {
@@ -877,7 +917,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 	}
 
 	if (!(options & F_FLOOD)) {
-		pr_options(buf + sizeof(struct iphdr), hlen);
+		pr_options(opts, optlen + sizeof(struct iphdr));
 
 		if (options & F_AUDIBLE)
 			putchar('\a');
@@ -1022,8 +1062,8 @@ void pr_icmph(__u8 type, __u8 code, __u32 info, struct icmphdr *icp)
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
index 019d9e4..96a997a 100644
--- a/ping6.c
+++ b/ping6.c
@@ -715,11 +715,16 @@ int main(int argc, char *argv[])
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
@@ -787,6 +792,10 @@ int main(int argc, char *argv[])
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
@@ -1092,49 +1101,53 @@ int main(int argc, char *argv[])
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
+		err = setsockopt(icmp_sock, SOL_RAW, IPV6_CHECKSUM,
+				 &csum_offset, sz_opt);
+		if (err < 0) {
+			/* checksum should be enabled by default and setting
+			 * this option might fail anyway.
+			 */
+			fprintf(stderr, "setsockopt(RAW_CHECKSUM) failed"
+				" - try to continue.");
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
+		err = setsockopt(icmp_sock, IPPROTO_ICMPV6, ICMP6_FILTER,
+				 &filter, sizeof(struct icmp6_filter));
 
-	if (err < 0) {
-		perror("setsockopt(ICMP6_FILTER)");
-		exit(2);
+		if (err < 0) {
+			perror("setsockopt(ICMP6_FILTER)");
+			exit(2);
+		}
 	}
 
 	if (options & F_NOLOOP) {
 		int loop = 0;
 		if (setsockopt(icmp_sock, IPPROTO_IPV6, IPV6_MULTICAST_LOOP,
-							&loop, sizeof(loop)) == -1) {
+				&loop, sizeof(loop)) == -1) {
 			perror ("can't disable multicast loopback");
 			exit(2);
 		}
@@ -1604,6 +1617,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
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
 
 inline int is_ours(uint8_t id) {
-       return id == ident;
+	return using_ping_socket || id == ident;
 }
-
diff --git a/ping_common.h b/ping_common.h
index d7513a2..f26462f 100644
--- a/ping_common.h
+++ b/ping_common.h
@@ -126,6 +126,7 @@ extern char *hostname;
 extern int uid;
 extern int ident;			/* process id to identify our packets */
 
+extern int using_ping_socket;
 extern int sndbuf;
 extern int ttl;
 
-- 
1.8.2.1
