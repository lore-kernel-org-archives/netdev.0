From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/34] netfilter: ipset: Add skbinfo extension kernel support for the hash set types.
Date: Mon, 29 Sep 2014 14:38:57 +0200
Message-ID: <1411994363-8451-9-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34122 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754051AbaI2Mic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:38:32 -0400
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Danilov <littlesmilingcloud@gmail.com>

Add skbinfo extension kernel support for the hash set types.
Inroduce the new revisions of all hash set types.

Signed-off-by: Anton Danilov <littlesmilingcloud@gmail.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h        |    5 +++++
 net/netfilter/ipset/ip_set_hash_ip.c         |   14 ++++++++++++--
 net/netfilter/ipset/ip_set_hash_ipmark.c     |   14 ++++++++++++--
 net/netfilter/ipset/ip_set_hash_ipport.c     |   14 ++++++++++++--
 net/netfilter/ipset/ip_set_hash_ipportip.c   |   14 ++++++++++++--
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |   14 ++++++++++++--
 net/netfilter/ipset/ip_set_hash_net.c        |   16 +++++++++++++---
 net/netfilter/ipset/ip_set_hash_netiface.c   |   16 +++++++++++++---
 net/netfilter/ipset/ip_set_hash_netnet.c     |   16 +++++++++++++---
 net/netfilter/ipset/ip_set_hash_netport.c    |   16 +++++++++++++---
 net/netfilter/ipset/ip_set_hash_netportnet.c |   16 +++++++++++++---
 11 files changed, 130 insertions(+), 25 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 8a38890..ac3a268 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -720,6 +720,8 @@ reuse_slot:
 		ip_set_init_counter(ext_counter(data, set), ext);
 	if (SET_WITH_COMMENT(set))
 		ip_set_init_comment(ext_comment(data, set), ext);
+	if (SET_WITH_SKBINFO(set))
+		ip_set_init_skbinfo(ext_skbinfo(data, set), ext);
 
 out:
 	rcu_read_unlock_bh();
@@ -797,6 +799,9 @@ mtype_data_match(struct mtype_elem *data, const struct ip_set_ext *ext,
 	if (SET_WITH_COUNTER(set))
 		ip_set_update_counter(ext_counter(data, set),
 				      ext, mext, flags);
+	if (SET_WITH_SKBINFO(set))
+		ip_set_get_skbinfo(ext_skbinfo(data, set),
+				   ext, mext, flags);
 	return mtype_do_data_match(data);
 }
 
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index e527399..76959d7 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -26,7 +26,8 @@
 #define IPSET_TYPE_REV_MIN	0
 /*				1	   Counters support */
 /*				2	   Comments support */
-#define IPSET_TYPE_REV_MAX	3	/* Forceadd support */
+/*				3	   Forceadd support */
+#define IPSET_TYPE_REV_MAX	4	/* skbinfo support  */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -111,7 +112,10 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)   ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -247,6 +251,9 @@ hash_ip6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
@@ -295,6 +302,9 @@ static struct ip_set_type hash_ip_type __read_mostly = {
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index 4eff0a2..7abf978 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -25,7 +25,8 @@
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
 #define IPSET_TYPE_REV_MIN	0
-#define IPSET_TYPE_REV_MAX	1	/* Forceadd support */
+/*				1	   Forceadd support */
+#define IPSET_TYPE_REV_MAX	2	/* skbinfo support  */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Vytas Dauksa <vytas.dauksa@smoothwall.net>");
@@ -113,7 +114,10 @@ hash_ipmark4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_MARK) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -244,6 +248,9 @@ hash_ipmark6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
@@ -301,6 +308,9 @@ static struct ip_set_type hash_ipmark_type __read_mostly = {
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index f37a5ae..dcbcceb 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -28,7 +28,8 @@
 /*				1    SCTP and UDPLITE support added */
 /*				2    Counters support added */
 /*				3    Comments support added */
-#define IPSET_TYPE_REV_MAX	4 /* Forceadd support added */
+/*				4    Forceadd support added */
+#define IPSET_TYPE_REV_MAX	5 /* skbinfo support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -122,7 +123,10 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -287,6 +291,9 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
@@ -370,6 +377,9 @@ static struct ip_set_type hash_ipport_type __read_mostly = {
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 41ef00e..7ef93fc 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -28,7 +28,8 @@
 /*				1    SCTP and UDPLITE support added */
 /*				2    Counters support added */
 /*				3    Comments support added */
-#define IPSET_TYPE_REV_MAX	4 /* Forceadd support added */
+/*				4    Forceadd support added */
+#define IPSET_TYPE_REV_MAX	5 /* skbinfo support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -124,7 +125,10 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -295,6 +299,9 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
@@ -382,6 +389,9 @@ static struct ip_set_type hash_ipportip_type __read_mostly = {
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 7308d84..b6012ad 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -30,7 +30,8 @@
 /*				3    nomatch flag support added */
 /*				4    Counters support added */
 /*				5    Comments support added */
-#define IPSET_TYPE_REV_MAX	6 /* Forceadd support added */
+/*				6    Forceadd support added */
+#define IPSET_TYPE_REV_MAX	7 /* skbinfo support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -179,7 +180,10 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -432,6 +436,9 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
@@ -541,6 +548,9 @@ static struct ip_set_type hash_ipportnet_type __read_mostly = {
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 4c7d495..6b3ac10 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -27,7 +27,8 @@
 /*				2    nomatch flag support added */
 /*				3    Counters support added */
 /*				4    Comments support added */
-#define IPSET_TYPE_REV_MAX	5 /* Forceadd support added */
+/*				5    Forceadd support added */
+#define IPSET_TYPE_REV_MAX	6 /* skbinfo mapping support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -150,7 +151,10 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -318,7 +322,10 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
@@ -377,6 +384,9 @@ static struct ip_set_type hash_net_type __read_mostly = {
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index db26068..03cdb69 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -28,7 +28,8 @@
 /*				2    /0 support added */
 /*				3    Counters support added */
 /*				4    Comments support added */
-#define IPSET_TYPE_REV_MAX	5 /* Forceadd support added */
+/*				5    Forceadd support added */
+#define IPSET_TYPE_REV_MAX	6 /* skbinfo support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -281,7 +282,10 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -514,7 +518,10 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
@@ -590,6 +597,9 @@ static struct ip_set_type hash_netiface_type __read_mostly = {
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index 96b1313..da00284 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -24,7 +24,8 @@
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
 #define IPSET_TYPE_REV_MIN	0
-#define IPSET_TYPE_REV_MAX	1	/* Forceadd support added */
+/*				1	   Forceadd support added */
+#define IPSET_TYPE_REV_MAX	2	/* skbinfo support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>");
@@ -171,7 +172,10 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -394,7 +398,10 @@ hash_netnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_IP2_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
@@ -462,6 +469,9 @@ static struct ip_set_type hash_netnet_type __read_mostly = {
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 1c645fb..c0ddb58 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -29,7 +29,8 @@
 /*				3    nomatch flag support added */
 /*				4    Counters support added */
 /*				5    Comments support added */
-#define IPSET_TYPE_REV_MAX	6 /* Forceadd support added */
+/*				6    Forceadd support added */
+#define IPSET_TYPE_REV_MAX	7 /* skbinfo support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -172,7 +173,10 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -389,7 +393,10 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
@@ -489,6 +496,9 @@ static struct ip_set_type hash_netport_type __read_mostly = {
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index 2f00343..b8053d6 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -26,7 +26,8 @@
 
 #define IPSET_TYPE_REV_MIN	0
 /*				0    Comments support added */
-#define IPSET_TYPE_REV_MAX	1 /* Forceadd support added */
+/*				1    Forceadd support added */
+#define IPSET_TYPE_REV_MAX	2 /* skbinfo support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>");
@@ -189,7 +190,10 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -460,7 +464,10 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_IP2_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
@@ -569,6 +576,9 @@ static struct ip_set_type hash_netportnet_type __read_mostly = {
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
 	},
 	.me		= THIS_MODULE,
 };
-- 
1.7.10.4
