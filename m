From: roy.qing.li@gmail.com
Subject: [PATCH net-next v2] ipv6: move IPV6_TCLASS_SHIFT into ipv6.h
Date: Fri, 10 Jan 2014 18:03:18 +0800
Message-ID: <1389348199-5855-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:46221 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbaAJKDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 05:03:44 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so4269959pbc.38
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 02:03:44 -0800 (PST)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id sg1sm16150156pbb.16.2014.01.10.02.03.38
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 02:03:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Two places defined IPV6_TCLASS_SHIFT, so we should move it into ipv6.h,
and use this macro as possible.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 Sorry, version 1 has bug in fib6_rule_match it should be frist
mask flowlabel with IPV6_TCLASS_MASK, then call ntohl 

 include/net/ipv6.h       |    1 +
 net/ipv6/fib6_rules.c    |    4 +++-
 net/ipv6/ip6_gre.c       |    2 --
 net/ipv6/ip6_tunnel.c    |    2 --
 net/ipv6/ipv6_sockglue.c |    4 +++-
 5 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 12079c6..d819f7a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -239,6 +239,7 @@ struct ip6_flowlabel {
 #define IPV6_FLOWINFO_MASK	cpu_to_be32(0x0FFFFFFF)
 #define IPV6_FLOWLABEL_MASK	cpu_to_be32(0x000FFFFF)
 #define IPV6_TCLASS_MASK (IPV6_FLOWINFO_MASK & ~IPV6_FLOWLABEL_MASK)
+#define IPV6_TCLASS_SHIFT	20
 
 struct ipv6_fl_socklist {
 	struct ipv6_fl_socklist	__rcu	*next;
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 3fd0a57..d50c5ca 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -150,6 +150,8 @@ static int fib6_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 {
 	struct fib6_rule *r = (struct fib6_rule *) rule;
 	struct flowi6 *fl6 = &fl->u.ip6;
+	u8 tclass = ntohl(fl6->flowlabel & IPV6_TCLASS_MASK) >>
+		    IPV6_TCLASS_SHIFT;
 
 	if (r->dst.plen &&
 	    !ipv6_prefix_equal(&fl6->daddr, &r->dst.addr, r->dst.plen))
@@ -169,7 +171,7 @@ static int fib6_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 			return 0;
 	}
 
-	if (r->tclass && r->tclass != ((ntohl(fl6->flowlabel) >> 20) & 0xff))
+	if (r->tclass && r->tclass != tclass)
 		return 0;
 
 	return 1;
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index e7a440d..f3ffb43 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -61,8 +61,6 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
-#define IPV6_TCLASS_SHIFT 20
-
 #define HASH_SIZE_SHIFT  5
 #define HASH_SIZE (1 << HASH_SIZE_SHIFT)
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 1e5e240..5db8d31 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -69,8 +69,6 @@ MODULE_ALIAS_NETDEV("ip6tnl0");
 #define IP6_TNL_TRACE(x...) do {;} while(0)
 #endif
 
-#define IPV6_TCLASS_SHIFT 20
-
 #define HASH_SIZE_SHIFT  5
 #define HASH_SIZE (1 << HASH_SIZE_SHIFT)
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index af0ecb9..1c9aa35 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1019,7 +1019,9 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 				put_cmsg(&msg, SOL_IPV6, IPV6_HOPLIMIT, sizeof(hlim), &hlim);
 			}
 			if (np->rxopt.bits.rxtclass) {
-				int tclass = ntohl(np->rcv_flowinfo & IPV6_TCLASS_MASK) >> 20;
+				int tclass = ntohl(np->rcv_flowinfo &
+						   IPV6_TCLASS_MASK) >>
+					     IPV6_TCLASS_SHIFT;
 				put_cmsg(&msg, SOL_IPV6, IPV6_TCLASS, sizeof(tclass), &tclass);
 			}
 			if (np->rxopt.bits.rxoinfo) {
-- 
1.7.10.4
