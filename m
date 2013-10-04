From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/33] netfilter: ipset: Support comments in hash-type ipsets.
Date: Fri,  4 Oct 2013 10:33:09 +0200
Message-ID: <1380875598-5250-25-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55610 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754319Ab3JDIeG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:34:06 -0400
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>

This provides kernel support for creating ipsets with comment support.

This does incur a penalty to flushing/destroying an ipset since all
entries are walked in order to free the allocated strings, this penalty
is of course less expensive than the operation of listing an ipset to
userspace, so for general-purpose usage the overall impact is expected
to be little to none.

Signed-off-by: Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h       |   14 ++++++++------
 net/netfilter/ipset/ip_set_hash_ip.c        |    4 +++-
 net/netfilter/ipset/ip_set_hash_ipport.c    |    4 +++-
 net/netfilter/ipset/ip_set_hash_ipportip.c  |    4 +++-
 net/netfilter/ipset/ip_set_hash_ipportnet.c |    4 +++-
 net/netfilter/ipset/ip_set_hash_net.c       |    4 +++-
 net/netfilter/ipset/ip_set_hash_netiface.c  |    4 +++-
 net/netfilter/ipset/ip_set_hash_netnet.c    |    1 +
 net/netfilter/ipset/ip_set_hash_netport.c   |    4 +++-
 9 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 6bd2eef..6efb655 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -701,6 +701,8 @@ reuse_slot:
 		ip_set_timeout_set(ext_timeout(data, set), ext->timeout);
 	if (SET_WITH_COUNTER(set))
 		ip_set_init_counter(ext_counter(data, set), ext);
+	if (SET_WITH_COMMENT(set))
+		ip_set_init_comment(ext_comment(data, set), ext);
 
 out:
 	rcu_read_unlock_bh();
@@ -908,12 +910,9 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 		goto nla_put_failure;
 #endif
 	if (nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
-	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE, htonl(memsize)) ||
-	    ((set->extensions & IPSET_EXT_TIMEOUT) &&
-	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(set->timeout))) ||
-	    ((set->extensions & IPSET_EXT_COUNTER) &&
-	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS,
-			   htonl(IPSET_FLAG_WITH_COUNTERS))))
+	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE, htonl(memsize)))
+		goto nla_put_failure;
+	if (unlikely(ip_set_put_flags(skb, set)))
 		goto nla_put_failure;
 	ipset_nest_end(skb, nested);
 
@@ -970,6 +969,9 @@ mtype_list(const struct ip_set *set,
 			if (SET_WITH_COUNTER(set) &&
 			    ip_set_put_counter(skb, ext_counter(e, set)))
 				goto nla_put_failure;
+			if (SET_WITH_COMMENT(set) &&
+			    ip_set_put_comment(skb, ext_comment(e, set)))
+				goto nla_put_failure;
 			ipset_nest_end(skb, nested);
 		}
 	}
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index a111ffe..e65fc24 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -24,7 +24,8 @@
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
 #define IPSET_TYPE_REV_MIN	0
-#define IPSET_TYPE_REV_MAX	1	/* Counters support */
+/*				1	   Counters support */
+#define IPSET_TYPE_REV_MAX	2	/* Comments support */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -292,6 +293,7 @@ static struct ip_set_type hash_ip_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 5dc735c..525a595 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -26,7 +26,8 @@
 
 #define IPSET_TYPE_REV_MIN	0
 /*				1    SCTP and UDPLITE support added */
-#define IPSET_TYPE_REV_MAX	2 /* Counters support added */
+/*				2    Counters support added */
+#define IPSET_TYPE_REV_MAX	3 /* Comments support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -367,6 +368,7 @@ static struct ip_set_type hash_ipport_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 8c43dc7..f563663 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -26,7 +26,8 @@
 
 #define IPSET_TYPE_REV_MIN	0
 /*				1    SCTP and UDPLITE support added */
-#define IPSET_TYPE_REV_MAX	2 /* Counters support added */
+/*				2    Counters support added */
+#define IPSET_TYPE_REV_MAX	3 /* Comments support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -379,6 +380,7 @@ static struct ip_set_type hash_ipportip_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 3489045..5d87fe8 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -28,7 +28,8 @@
 /*				1    SCTP and UDPLITE support added */
 /*				2    Range as input support for IPv4 added */
 /*				3    nomatch flag support added */
-#define IPSET_TYPE_REV_MAX	4 /* Counters support added */
+/*				4    Counters support added */
+#define IPSET_TYPE_REV_MAX	5 /* Comments support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -538,6 +539,7 @@ static struct ip_set_type hash_ipportnet_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index d559855..8295cf4 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -25,7 +25,8 @@
 #define IPSET_TYPE_REV_MIN	0
 /*				1    Range as input support for IPv4 added */
 /*				2    nomatch flag support added */
-#define IPSET_TYPE_REV_MAX	3 /* Counters support added */
+/*				3    Counters support added */
+#define IPSET_TYPE_REV_MAX	4 /* Comments support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -374,6 +375,7 @@ static struct ip_set_type hash_net_type __read_mostly = {
 		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 26703e9..3f64a66 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -26,7 +26,8 @@
 #define IPSET_TYPE_REV_MIN	0
 /*				1    nomatch flag support added */
 /*				2    /0 support added */
-#define IPSET_TYPE_REV_MAX	3 /* Counters support added */
+/*				3    Counters support added */
+#define IPSET_TYPE_REV_MAX	4 /* Comments support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -606,6 +607,7 @@ static struct ip_set_type hash_netiface_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index 771ce2b..4260327 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -462,6 +462,7 @@ static struct ip_set_type hash_netnet_type __read_mostly = {
 		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 45b6e91..7097fb0 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -27,7 +27,8 @@
 /*				1    SCTP and UDPLITE support added */
 /*				2    Range as input support for IPv4 added */
 /*				3    nomatch flag support added */
-#define IPSET_TYPE_REV_MAX	4 /* Counters support added */
+/*				4    Counters support added */
+#define IPSET_TYPE_REV_MAX	5 /* Comments support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -486,6 +487,7 @@ static struct ip_set_type hash_netport_type __read_mostly = {
 		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
 	},
 	.me		= THIS_MODULE,
 };
-- 
1.7.10.4
