From: Tom Lendacky <toml@us.ibm.com>
Subject: [PATCH] IPSec: IPv6 source address not set correctly in xfrm_state
Date: 21 Mar 2003 08:59:23 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1048258764.1214.28.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, toml@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Here is a patch that fixes the source address in an xfrm_state
structure.  I found this when the incorrect address was supplied
in a pfkey ACQUIRE message.  Also, I wasn't able to test the
xfrm6_find_acq path, but I believe the memcpy's in that function
were not correct and fixed those also.

Thanks, 
Tom 

diff -ur linux-2.5.65-orig/net/ipv4/xfrm_state.c linux-2.5.65/net/ipv4/xfrm_state.c
--- linux-2.5.65-orig/net/ipv4/xfrm_state.c	2003-03-17 15:44:21.000000000 -0600
+++ linux-2.5.65/net/ipv4/xfrm_state.c	2003-03-21 08:48:58.000000000 -0600
@@ -404,7 +404,7 @@
 			memcpy(&x->id.daddr, daddr, sizeof(x->sel.daddr));
 		memcpy(&x->props.saddr, &tmpl->saddr, sizeof(x->props.saddr));
 		if (ipv6_addr_any((struct in6_addr*)&x->props.saddr))
-			memcpy(&x->props.saddr, &saddr, sizeof(x->sel.saddr));
+			memcpy(&x->props.saddr, saddr, sizeof(x->props.saddr));
 		x->props.mode = tmpl->mode;
 		x->props.reqid = tmpl->reqid;
 		x->props.family = AF_INET6;
@@ -642,13 +642,13 @@
 	if (x0) {
 		atomic_inc(&x0->refcnt);
 	} else if (create && (x0 = xfrm_state_alloc()) != NULL) {
-		memcpy(x0->sel.daddr.a6, daddr, sizeof(struct in6_addr));
-		memcpy(x0->sel.saddr.a6, saddr, sizeof(struct in6_addr));
+		memcpy(&x0->sel.daddr.a6, daddr, sizeof(struct in6_addr));
+		memcpy(&x0->sel.saddr.a6, saddr, sizeof(struct in6_addr));
 		x0->sel.prefixlen_d = 128;
 		x0->sel.prefixlen_s = 128;
-		memcpy(x0->props.saddr.a6, saddr, sizeof(struct in6_addr));
+		memcpy(&x0->props.saddr.a6, saddr, sizeof(struct in6_addr));
 		x0->km.state = XFRM_STATE_ACQ;
-		memcpy(x0->id.daddr.a6, daddr, sizeof(struct in6_addr));
+		memcpy(&x0->id.daddr.a6, daddr, sizeof(struct in6_addr));
 		x0->id.proto = proto;
 		x0->props.family = AF_INET6;
 		x0->props.mode = mode;
