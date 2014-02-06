From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] netpoll: fix netconsole IPv6 setup
Date: Thu,  6 Feb 2014 18:34:12 +0100
Message-ID: <1391708052-11188-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:46844 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752315AbaBFRe4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Feb 2014 12:34:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, to make netconsole start over IPv6, the source address
needs to be specified. Without a source address, netpoll_parse_options
assumes we're setting up over IPv4 and the destination IPv6 address is
rejected.

Check if the IP version has been forced by a source address before
checking for a version mismatch when parsing the destination address.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/core/netpoll.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index c03f3de..a664f78 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -948,6 +948,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 {
 	char *cur=opt, *delim;
 	int ipv6;
+	bool ipversion_set = false;
 
 	if (*cur != '@') {
 		if ((delim = strchr(cur, '@')) == NULL)
@@ -960,6 +961,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 	cur++;
 
 	if (*cur != '/') {
+		ipversion_set = true;
 		if ((delim = strchr(cur, '/')) == NULL)
 			goto parse_failed;
 		*delim = 0;
@@ -1002,7 +1004,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 	ipv6 = netpoll_parse_ip_addr(cur, &np->remote_ip);
 	if (ipv6 < 0)
 		goto parse_failed;
-	else if (np->ipv6 != (bool)ipv6)
+	else if (ipversion_set && np->ipv6 != (bool)ipv6)
 		goto parse_failed;
 	else
 		np->ipv6 = (bool)ipv6;
-- 
1.8.5.3
