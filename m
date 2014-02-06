From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH iproute2 3/3] tcp_metrics: Allow removal based on the source-IP
Date: Thu,  6 Feb 2014 23:15:04 +0100
Message-ID: <1391724904-30504-4-git-send-email-christoph.paasch@uclouvain.be>
References: <1391724904-30504-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:61932 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753742AbaBFWPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 17:15:30 -0500
Received: by mail-ee0-f50.google.com with SMTP id d17so1174457eek.23
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 14:15:28 -0800 (PST)
In-Reply-To: <1391724904-30504-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows adding the source-IP attribute to the netlink-command.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 ip/tcp_metrics.c | 87 ++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 62 insertions(+), 25 deletions(-)

diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
index a7215c86379f..e0f03449e94b 100644
--- a/ip/tcp_metrics.c
+++ b/ip/tcp_metrics.c
@@ -75,6 +75,7 @@ static struct
 	int flushe;
 	int cmd;
 	inet_prefix daddr;
+	inet_prefix saddr;
 } f;
 
 static int flush_update(void)
@@ -157,6 +158,12 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 	if (f.daddr.family && f.daddr.bitlen >= 0 &&
 	    inet_addr_match(&daddr, &f.daddr, f.daddr.bitlen))
+	       return 0;
+	/* Only check for the source-address if the kernel supports it,
+	 * meaning slen != 0.
+	 */
+	if (slen && f.saddr.family && f.saddr.bitlen >= 0 &&
+	    inet_addr_match(&saddr, &f.saddr, f.saddr.bitlen))
 		return 0;
 
 	if (f.flushb) {
@@ -165,6 +172,9 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 		addattr_l(&req2.n, sizeof(req2), atype, &daddr.data,
 			  daddr.bytelen);
+		if (slen)
+			addattr_l(&req2.n, sizeof(req2), stype, &saddr.data,
+				  saddr.bytelen);
 
 		if (NLMSG_ALIGN(f.flushp) + req2.n.nlmsg_len > f.flushe) {
 			if (flush_update())
@@ -283,12 +293,14 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 static int tcpm_do_cmd(int cmd, int argc, char **argv)
 {
 	TCPM_REQUEST(req, 1024, TCP_METRICS_CMD_GET, NLM_F_REQUEST);
-	int atype = -1;
+	int atype = -1, stype = -1;
 	int ack;
 
 	memset(&f, 0, sizeof(f));
 	f.daddr.bitlen = -1;
 	f.daddr.family = preferred_family;
+	f.saddr.bitlen = -1;
+	f.saddr.family = preferred_family;
 
 	switch (preferred_family) {
 	case AF_UNSPEC:
@@ -301,31 +313,53 @@ static int tcpm_do_cmd(int cmd, int argc, char **argv)
 	}
 
 	for (; argc > 0; argc--, argv++) {
-		char *who = "address";
-
-		if (strcmp(*argv, "addr") == 0 ||
-		    strcmp(*argv, "address") == 0) {
-			who = *argv;
+		if (strcmp(*argv, "src") == 0 ||
+		    strcmp(*argv, "source") == 0) {
+			char *who = *argv;
 			NEXT_ARG();
-		}
-		if (matches(*argv, "help") == 0)
-			usage();
-		if (f.daddr.bitlen >= 0)
-			duparg2(who, *argv);
-
-		get_prefix(&f.daddr, *argv, preferred_family);
-		if (f.daddr.bytelen && f.daddr.bytelen * 8 == f.daddr.bitlen) {
-			if (f.daddr.family == AF_INET)
-				atype = TCP_METRICS_ATTR_ADDR_IPV4;
-			else if (f.daddr.family == AF_INET6)
-				atype = TCP_METRICS_ATTR_ADDR_IPV6;
-		}
-		if ((CMD_DEL & cmd) && atype < 0) {
-			fprintf(stderr, "Error: a specific IP address is expected rather than \"%s\"\n",
-				*argv);
-			return -1;
-		}
+			if (matches(*argv, "help") == 0)
+				usage();
+			if (f.saddr.bitlen >= 0)
+				duparg2(who, *argv);
+
+			get_prefix(&f.saddr, *argv, preferred_family);
+			if (f.saddr.bytelen && f.saddr.bytelen * 8 == f.saddr.bitlen) {
+				if (f.saddr.family == AF_INET)
+					stype = TCP_METRICS_ATTR_SADDR_IPV4;
+				else if (f.saddr.family == AF_INET6)
+					stype = TCP_METRICS_ATTR_SADDR_IPV6;
+			}
 
+			if (stype < 0) {
+				fprintf(stderr, "Error: a specific IP address is expected rather than \"%s\"\n",
+					*argv);
+				return -1;
+			}
+		} else {
+			char *who = "address";
+			if (strcmp(*argv, "addr") == 0 ||
+			    strcmp(*argv, "address") == 0) {
+				who = *argv;
+				NEXT_ARG();
+			}
+			if (matches(*argv, "help") == 0)
+				usage();
+			if (f.daddr.bitlen >= 0)
+				duparg2(who, *argv);
+
+			get_prefix(&f.daddr, *argv, preferred_family);
+			if (f.daddr.bytelen && f.daddr.bytelen * 8 == f.daddr.bitlen) {
+				if (f.daddr.family == AF_INET)
+					atype = TCP_METRICS_ATTR_ADDR_IPV4;
+				else if (f.daddr.family == AF_INET6)
+					atype = TCP_METRICS_ATTR_ADDR_IPV6;
+			}
+			if ((CMD_DEL & cmd) && atype < 0) {
+				fprintf(stderr, "Error: a specific IP address is expected rather than \"%s\"\n",
+					*argv);
+				return -1;
+			}
+		}
 		argc--; argv++;
 	}
 
@@ -338,7 +372,7 @@ static int tcpm_do_cmd(int cmd, int argc, char **argv)
 
 	/* flush for all addresses ? Single del without address */
 	if (cmd == CMD_FLUSH && f.daddr.bitlen <= 0 &&
-	    preferred_family == AF_UNSPEC) {
+	    f.saddr.bitlen <= 0 && preferred_family == AF_UNSPEC) {
 		cmd = CMD_DEL;
 		req.g.cmd = TCP_METRICS_CMD_DEL;
 		ack = 1;
@@ -367,6 +401,9 @@ static int tcpm_do_cmd(int cmd, int argc, char **argv)
 		if (atype >= 0)
 			addattr_l(&req.n, sizeof(req), atype, &f.daddr.data,
 				  f.daddr.bytelen);
+		if (stype >= 0)
+			addattr_l(&req.n, sizeof(req), stype, &f.saddr.data,
+				  f.saddr.bytelen);
 	} else {
 		req.n.nlmsg_flags |= NLM_F_DUMP;
 	}
-- 
1.8.3.2
