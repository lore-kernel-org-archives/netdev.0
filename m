From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net 3/3] inet_diag: avoid unsafe and nonsensical prefix matches in inet_diag_bc_run()
Date: Sun,  9 Dec 2012 00:43:23 -0500
Message-ID: <1355031803-14547-3-git-send-email-ncardwell@google.com>
References: <1355031803-14547-1-git-send-email-ncardwell@google.com>
Cc: edumazet@google.com, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f74.google.com ([209.85.214.74]:39495 "EHLO
	mail-bk0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756506Ab2LIFnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 00:43:31 -0500
Received: by mail-bk0-f74.google.com with SMTP id je9so107127bkc.1
        for <netdev@vger.kernel.org>; Sat, 08 Dec 2012 21:43:31 -0800 (PST)
In-Reply-To: <1355031803-14547-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add logic to check the address family of the user-supplied conditional
and the address family of the connection entry. We now do not do
prefix matching of addresses from different address families (AF_INET
vs AF_INET6), except for the previously existing support for having an
IPv4 prefix match an IPv4-mapped IPv6 address (which this commit
maintains as-is).

This change is needed for two reasons:

(1) The addresses are different lengths, so comparing a 128-bit IPv6
prefix match condition to a 32-bit IPv4 connection address can cause
us to unwittingly walk off the end of the IPv4 address and read
garbage or oops.

(2) The IPv4 and IPv6 address spaces are semantically distinct, so a
simple bit-wise comparison of the prefixes is not meaningful, and
would lead to bogus results (except for the IPv4-mapped IPv6 case,
which this commit maintains).

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/inet_diag.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 529747d..95f1a45 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -432,25 +432,31 @@ static int inet_diag_bc_run(const struct nlattr *_bc,
 				break;
 			}
 
-			if (cond->prefix_len == 0)
-				break;
-
 			if (op->code == INET_DIAG_BC_S_COND)
 				addr = entry->saddr;
 			else
 				addr = entry->daddr;
 
+			if (cond->family != AF_UNSPEC &&
+			    cond->family != entry->family) {
+				if (entry->family == AF_INET6 &&
+				    cond->family == AF_INET) {
+					if (addr[0] == 0 && addr[1] == 0 &&
+					    addr[2] == htonl(0xffff) &&
+					    bitstring_match(addr + 3,
+							    cond->addr,
+							    cond->prefix_len))
+						break;
+				}
+				yes = 0;
+				break;
+			}
+
+			if (cond->prefix_len == 0)
+				break;
 			if (bitstring_match(addr, cond->addr,
 					    cond->prefix_len))
 				break;
-			if (entry->family == AF_INET6 &&
-			    cond->family == AF_INET) {
-				if (addr[0] == 0 && addr[1] == 0 &&
-				    addr[2] == htonl(0xffff) &&
-				    bitstring_match(addr + 3, cond->addr,
-						    cond->prefix_len))
-					break;
-			}
 			yes = 0;
 			break;
 		}
-- 
1.7.7.3
