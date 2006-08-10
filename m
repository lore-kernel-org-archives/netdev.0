From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE]: Support IPv6 routing table filter
Date: Thu, 10 Aug 2006 22:42:58 +0200
Message-ID: <44DB9A52.5020501@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010004060207020000030700"
Cc: Thomas Graf <tgraf@suug.ch>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34527 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751071AbWHJUnC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 16:43:02 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010004060207020000030700
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Support IPv6 routing table filter in presence of multiple tables,
f.e. "ip -6 route list table 123". Compatibility is preserved for
kernels not supporting multiple IPv6 tables.



--------------010004060207020000030700
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPROUTE]: Support IPv6 routing table filter

The current behaviour for IPv6 routing table filters is to derive the
table from the route type. This doesn't really work anymore now that IPv6
supports multiple tables. Add detection for IPv6 multiple table support
(relying on the fact that the first routes dumped belong to the local table
and have rtm_table == RT_TABLE_LOCAL with multiple tables) and handle it
like other protocols.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 14d210c56edd67973439acd67d916de84a6e0384
tree 5678d9dba5c1b8a0b25133a89bce5d4e473a1160
parent e81c1a22cd2408a8b490ce39bf6ece2d19919a3b
author Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 22:39:21 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 22:39:21 +0200

 ip/iproute.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 8f4a55d..1645f0b 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -138,6 +138,7 @@ int print_route(const struct sockaddr_nl
 	inet_prefix prefsrc;
 	inet_prefix via;
 	int host_len = -1;
+	static int ip6_multiple_tables;
 	SPRINT_BUF(b1);
 	
 
@@ -163,7 +164,10 @@ int print_route(const struct sockaddr_nl
 	else if (r->rtm_family == AF_IPX)
 		host_len = 80;
 
-	if (r->rtm_family == AF_INET6) {
+	if (r->rtm_family == AF_INET6 && r->rtm_table != RT_TABLE_MAIN)
+		ip6_multiple_tables = 1;
+
+	if (r->rtm_family == AF_INET6 && !ip6_multiple_tables) {
 		if (filter.tb) {
 			if (filter.tb < 0) {
 				if (!(r->rtm_flags&RTM_F_CLONED))

--------------010004060207020000030700--
