From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH iproute2 1/3] tcp_metrics: Rename addr to daddr and add local variable
Date: Thu,  6 Feb 2014 23:15:02 +0100
Message-ID: <1391724904-30504-2-git-send-email-christoph.paasch@uclouvain.be>
References: <1391724904-30504-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:61637 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbaBFWPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 17:15:19 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so1162535eei.35
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 14:15:18 -0800 (PST)
In-Reply-To: <1391724904-30504-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Renaming addr to daddr, because we will introduce saddr later.

The local variable is necessary to store RTA_PAYLOAD(a) temporarily.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 ip/tcp_metrics.c | 51 ++++++++++++++++++++++++++-------------------------
 1 file changed, 26 insertions(+), 25 deletions(-)

diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
index c6be3c94415f..4b30771ae3a8 100644
--- a/ip/tcp_metrics.c
+++ b/ip/tcp_metrics.c
@@ -74,7 +74,7 @@ static struct
 	int flushp;
 	int flushe;
 	int cmd;
-	inet_prefix addr;
+	inet_prefix daddr;
 } f;
 
 static int flush_update(void)
@@ -95,8 +95,8 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	struct rtattr *attrs[TCP_METRICS_ATTR_MAX + 1], *a;
 	int len = n->nlmsg_len;
 	char abuf[256];
-	inet_prefix addr;
-	int family, i, atype;
+	inet_prefix daddr;
+	int family, i, atype, dlen = 0;
 
 	if (n->nlmsg_type != genl_family)
 		return -1;
@@ -114,35 +114,37 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 	a = attrs[TCP_METRICS_ATTR_ADDR_IPV4];
 	if (a) {
-		if (f.addr.family && f.addr.family != AF_INET)
+		if (f.daddr.family && f.daddr.family != AF_INET)
 			return 0;
-		memcpy(&addr.data, RTA_DATA(a), 4);
-		addr.bytelen = 4;
+		memcpy(&daddr.data, RTA_DATA(a), 4);
+		daddr.bytelen = 4;
 		family = AF_INET;
 		atype = TCP_METRICS_ATTR_ADDR_IPV4;
+		dlen = RTA_PAYLOAD(a);
 	} else {
 		a = attrs[TCP_METRICS_ATTR_ADDR_IPV6];
 		if (a) {
-			if (f.addr.family && f.addr.family != AF_INET6)
+			if (f.daddr.family && f.daddr.family != AF_INET6)
 				return 0;
-			memcpy(&addr.data, RTA_DATA(a), 16);
-			addr.bytelen = 16;
+			memcpy(&daddr.data, RTA_DATA(a), 16);
+			daddr.bytelen = 16;
 			family = AF_INET6;
 			atype = TCP_METRICS_ATTR_ADDR_IPV6;
+			dlen = RTA_PAYLOAD(a);
 		} else
 			return 0;
 	}
 
-	if (f.addr.family && f.addr.bitlen >= 0 &&
-	    inet_addr_match(&addr, &f.addr, f.addr.bitlen))
+	if (f.daddr.family && f.daddr.bitlen >= 0 &&
+	    inet_addr_match(&daddr, &f.daddr, f.daddr.bitlen))
 		return 0;
 
 	if (f.flushb) {
 		struct nlmsghdr *fn;
 		TCPM_REQUEST(req2, 128, TCP_METRICS_CMD_DEL, NLM_F_REQUEST);
 
-		addattr_l(&req2.n, sizeof(req2), atype, &addr.data,
-			  addr.bytelen);
+		addattr_l(&req2.n, sizeof(req2), atype, &daddr.data,
+			  daddr.bytelen);
 
 		if (NLMSG_ALIGN(f.flushp) + req2.n.nlmsg_len > f.flushe) {
 			if (flush_update())
@@ -161,8 +163,7 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		fprintf(fp, "Deleted ");
 
 	fprintf(fp, "%s",
-		format_host(family, RTA_PAYLOAD(a), &addr.data,
-			    abuf, sizeof(abuf)));
+		format_host(family, dlen, &daddr.data, abuf, sizeof(abuf)));
 
 	a = attrs[TCP_METRICS_ATTR_AGE];
 	if (a) {
@@ -260,8 +261,8 @@ static int tcpm_do_cmd(int cmd, int argc, char **argv)
 	int ack;
 
 	memset(&f, 0, sizeof(f));
-	f.addr.bitlen = -1;
-	f.addr.family = preferred_family;
+	f.daddr.bitlen = -1;
+	f.daddr.family = preferred_family;
 
 	switch (preferred_family) {
 	case AF_UNSPEC:
@@ -283,14 +284,14 @@ static int tcpm_do_cmd(int cmd, int argc, char **argv)
 		}
 		if (matches(*argv, "help") == 0)
 			usage();
-		if (f.addr.bitlen >= 0)
+		if (f.daddr.bitlen >= 0)
 			duparg2(who, *argv);
 
-		get_prefix(&f.addr, *argv, preferred_family);
-		if (f.addr.bytelen && f.addr.bytelen * 8 == f.addr.bitlen) {
-			if (f.addr.family == AF_INET)
+		get_prefix(&f.daddr, *argv, preferred_family);
+		if (f.daddr.bytelen && f.daddr.bytelen * 8 == f.daddr.bitlen) {
+			if (f.daddr.family == AF_INET)
 				atype = TCP_METRICS_ATTR_ADDR_IPV4;
-			else if (f.addr.family == AF_INET6)
+			else if (f.daddr.family == AF_INET6)
 				atype = TCP_METRICS_ATTR_ADDR_IPV6;
 		}
 		if ((CMD_DEL & cmd) && atype < 0) {
@@ -310,7 +311,7 @@ static int tcpm_do_cmd(int cmd, int argc, char **argv)
 		cmd = CMD_DEL;
 
 	/* flush for all addresses ? Single del without address */
-	if (cmd == CMD_FLUSH && f.addr.bitlen <= 0 &&
+	if (cmd == CMD_FLUSH && f.daddr.bitlen <= 0 &&
 	    preferred_family == AF_UNSPEC) {
 		cmd = CMD_DEL;
 		req.g.cmd = TCP_METRICS_CMD_DEL;
@@ -338,8 +339,8 @@ static int tcpm_do_cmd(int cmd, int argc, char **argv)
 		if (ack)
 			req.n.nlmsg_flags |= NLM_F_ACK;
 		if (atype >= 0)
-			addattr_l(&req.n, sizeof(req), atype, &f.addr.data,
-				  f.addr.bytelen);
+			addattr_l(&req.n, sizeof(req), atype, &f.daddr.data,
+				  f.daddr.bytelen);
 	} else {
 		req.n.nlmsg_flags |= NLM_F_DUMP;
 	}
-- 
1.8.3.2
