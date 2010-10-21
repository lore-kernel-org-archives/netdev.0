From: kaber@trash.net
Subject: [PATCH 04/72] netfilter: nf_nat: no IP_NAT_RANGE_MAP_IPS flags when alloc_null_binding()
Date: Thu, 21 Oct 2010 17:18:51 +0200
Message-ID: <1287674399-31455-5-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59987 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129Ab0JUPUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:03 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

When alloc_null_binding(), no IP_NAT_RNAGE_MAP_IPS in flags means no IP address
translation is needed. It isn't necessary to specify the address explicitly.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_rule.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index ebbd319..21c3042 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -106,16 +106,15 @@ alloc_null_binding(struct nf_conn *ct, unsigned int hooknum)
 {
 	/* Force range to this IP; let proto decide mapping for
 	   per-proto parts (hence not IP_NAT_RANGE_PROTO_SPECIFIED).
-	   Use reply in case it's already been mangled (eg local packet).
 	*/
-	__be32 ip
-		= (HOOK2MANIP(hooknum) == IP_NAT_MANIP_SRC
-		   ? ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip
-		   : ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3.ip);
-	struct nf_nat_range range
-		= { IP_NAT_RANGE_MAP_IPS, ip, ip, { 0 }, { 0 } };
-
-	pr_debug("Allocating NULL binding for %p (%pI4)\n", ct, &ip);
+	struct nf_nat_range range;
+
+	range.flags = 0;
+	pr_debug("Allocating NULL binding for %p (%pI4)\n", ct,
+		 HOOK2MANIP(hooknum) == IP_NAT_MANIP_SRC ?
+		 &ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip :
+		 &ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3.ip);
+
 	return nf_nat_setup_info(ct, &range, HOOK2MANIP(hooknum));
 }
 
-- 
1.7.1

