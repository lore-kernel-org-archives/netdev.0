From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [patch] iputils ping: add icmp socket support
Date: Thu, 9 Jun 2011 20:44:19 +0400
Message-ID: <20110609164419.GA29454@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>,
	Solar Designer <solar@openwall.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57341 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959Ab1FIQoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 12:44:22 -0400
Received: by fxm17 with SMTP id 17so1106757fxm.19
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2011 09:44:21 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds nonraw IPPROTO_ICMP socket kind support that was added
to the Linux 3.0.  The patch is backward-compatible: if icmp socket kind
is not enabled in the kernel (either in case of an old kernel or
explicitly disabled via /proc/sys/net/ipv4/ping_group_range), ping uses
old privileged raw sockets as a fallback.

The distributions are free to choose whether ping binary is setgid and
owned by a special group or is just a normal binary.

The patch is used in Owl-current since February (Owl-current had ping
sockets support before the mainline).

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>

diff -uNp -r iputils-s20101006.orig/ping.c iputils-s20101006/ping.c
--- iputils-s20101006.orig/ping.c	2010-10-06 11:59:20 +0000
+++ iputils-s20101006/ping.c	2011-03-24 12:21:30 +0000
@@ -88,6 +88,7 @@ struct sockaddr_in whereto;	/* who to pi
 int optlen = 0;
 int settos = 0;			/* Set TOS, Precendence or other QOS options */
 int icmp_sock;			/* socket file descriptor */
+int using_ping_socket = 0;
 u_char outpack[0x10000];
 int maxpacket = sizeof(outpack);
 
@@ -123,7 +124,11 @@ main(int argc, char **argv)
 	char *target, hnamebuf[MAX_HOSTNAMELEN];
 	char rspace[3 + 4 * NROUTES + 1];	/* record route space */
 
-	icmp_sock = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
+	icmp_sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP);
+	if (icmp_sock != -1)
+		using_ping_socket = 1;
+	else
+		icmp_sock = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
 	socket_errno = errno;
 
 	uid = getuid();
@@ -377,13 +382,35 @@ main(int argc, char **argv)
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
@@ -398,6 +425,12 @@ main(int argc, char **argv)
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
@@ -566,6 +599,7 @@ int receive_error_msg()
 		nerrors++;
 	} else if (e->ee_origin == SO_EE_ORIGIN_ICMP) {
 		struct sockaddr_in *sin = (struct sockaddr_in*)(e+1);
+		int error_pkt;
 
 		if (res < sizeof(icmph) ||
 		    target.sin_addr.s_addr != whereto.sin_addr.s_addr ||
@@ -576,9 +610,18 @@ int receive_error_msg()
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
@@ -589,15 +632,14 @@ int receive_error_msg()
 				perror("\rWARNING: setsockopt(ICMP_FILTER)");
 		}
 
-		net_errors++;
-		nerrors++;
 		if (options & F_QUIET)
 			goto out;
 		if (options & F_FLOOD) {
-			write(STDOUT_FILENO, "\bE", 2);
+			if (error_pkt)
+				write(STDOUT_FILENO, "\bE", 2);
 		} else {
 			print_timestamp();
-			printf("From %s icmp_seq=%u ", pr_addr(sin->sin_addr.s_addr), ntohs(icmph.un.echo.sequence));
+			printf("From %s: icmp_seq=%u ", pr_addr(sin->sin_addr.s_addr), ntohs(icmph.un.echo.sequence));
 			pr_icmph(e->ee_type, e->ee_code, e->ee_info, NULL);
 			fflush(stdout);
 		}
@@ -695,15 +737,41 @@ parse_reply(struct msghdr *msg, int cc, 
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
@@ -716,7 +784,7 @@ parse_reply(struct msghdr *msg, int cc, 
 			return 1;			/* 'Twas not our ECHO */
 		if (gather_statistics((__u8*)icp, sizeof(*icp), cc,
 				      ntohs(icp->un.echo.sequence),
-				      ip->ttl, 0, tv, pr_addr(from->sin_addr.s_addr),
+				      ttl, 0, tv, pr_addr(from->sin_addr.s_addr),
 				      pr_echo_reply))
 			return 0;
 	} else {
@@ -807,7 +875,7 @@ parse_reply(struct msghdr *msg, int cc, 
 	}
 
 	if (!(options & F_FLOOD)) {
-		pr_options(buf + sizeof(struct iphdr), hlen);
+		pr_options(opts, optlen + sizeof(struct iphdr));
 
 		if (options & F_AUDIBLE)
 			putchar('\a');
@@ -916,8 +984,7 @@ void pr_icmph(__u8 type, __u8 code, __u3
 			printf("Redirect, Bad Code: %d", code);
 			break;
 		}
-		if (icp)
-			printf("(New nexthop: %s)\n", pr_addr(icp->un.gateway));
+		printf("(New nexthop: %s)\n", pr_addr(icp ? icp->un.gateway : info));
 		if (icp && (options & F_VERBOSE))
 			pr_iph((struct iphdr*)(icp + 1));
 		break;
@@ -1217,7 +1284,7 @@ void install_filter(void)
 		insns
 	};
 
-	if (once)
+	if (once || using_ping_socket)
 		return;
 	once = 1;
 
diff -uNp -r iputils-s20101006.orig/ping_common.c iputils-s20101006/ping_common.c
--- iputils-s20101006.orig/ping_common.c	2010-10-06 11:59:20 +0000
+++ iputils-s20101006/ping_common.c	2011-03-24 12:22:20 +0000
@@ -515,7 +515,8 @@ void setup(int icmp_sock)
 			*p++ = i;
 	}
 
-	ident = htons(getpid() & 0xFFFF);
+	if (!ident)
+		ident = htons(getpid() & 0xFFFF);
 
 	set_signal(SIGINT, sigexit);
 	set_signal(SIGALRM, sigexit);
--
