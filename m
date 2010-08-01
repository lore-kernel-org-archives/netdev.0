From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] nf_nat: no IP_NAT_RANGE_MAP_IPS flags when alloc_null_binding()
Date: Sun,  1 Aug 2010 22:45:07 +0800
Message-ID: <1280673907-12619-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

when alloc_null_binding(), no IP_NAT_RNAGE_MAP_IPS in flags means no IP address
translation is needed. It isn't necessary to specify the address explicitly.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ipv4/netfilter/nf_nat_rule.c |   17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)
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
 
