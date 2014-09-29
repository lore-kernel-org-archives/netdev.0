From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/34] netfilter: ipset: Add skbinfo extension kernel support for the bitmap set types.
Date: Mon, 29 Sep 2014 14:38:56 +0200
Message-ID: <1411994363-8451-8-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34063 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754053AbaI2Mi0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:38:26 -0400
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Danilov <littlesmilingcloud@gmail.com>

Add skbinfo extension kernel support for the bitmap set types.
Inroduce the new revisions of bitmap_ip, bitmap_ipmac and bitmap_port set types.

Signed-off-by: Anton Danilov <littlesmilingcloud@gmail.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_bitmap_gen.h   |    4 ++++
 net/netfilter/ipset/ip_set_bitmap_ip.c    |   11 +++++++++--
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |   11 +++++++++--
 net/netfilter/ipset/ip_set_bitmap_port.c  |   11 +++++++++--
 4 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index f2c7d83..6f024a8 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -128,6 +128,8 @@ mtype_test(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		return 0;
 	if (SET_WITH_COUNTER(set))
 		ip_set_update_counter(ext_counter(x, set), ext, mext, flags);
+	if (SET_WITH_SKBINFO(set))
+		ip_set_get_skbinfo(ext_skbinfo(x, set), ext, mext, flags);
 	return 1;
 }
 
@@ -161,6 +163,8 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		ip_set_init_counter(ext_counter(x, set), ext);
 	if (SET_WITH_COMMENT(set))
 		ip_set_init_comment(ext_comment(x, set), ext);
+	if (SET_WITH_SKBINFO(set))
+		ip_set_init_skbinfo(ext_skbinfo(x, set), ext);
 	return 0;
 }
 
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index dafdb39..55b083e 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -27,7 +27,8 @@
 
 #define IPSET_TYPE_REV_MIN	0
 /*				1	   Counter support added */
-#define IPSET_TYPE_REV_MAX	2	/* Comment support added */
+/*				2	   Comment support added */
+#define IPSET_TYPE_REV_MAX	3	/* skbinfo support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -139,7 +140,10 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
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
@@ -357,6 +361,9 @@ static struct ip_set_type bitmap_ip_type __read_mostly = {
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index dbad505..8610474 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -27,7 +27,8 @@
 
 #define IPSET_TYPE_REV_MIN	0
 /*				1	   Counter support added */
-#define IPSET_TYPE_REV_MAX	2	/* Comment support added */
+/*				2	   Comment support added */
+#define IPSET_TYPE_REV_MAX	3	/* skbinfo support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -240,7 +241,10 @@ bitmap_ipmac_uadt(struct ip_set *set, struct nlattr *tb[],
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
@@ -394,6 +398,9 @@ static struct ip_set_type bitmap_ipmac_type = {
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index a4b65ae..005dd36 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -22,7 +22,8 @@
 
 #define IPSET_TYPE_REV_MIN	0
 /*				1	   Counter support added */
-#define IPSET_TYPE_REV_MAX	2	/* Comment support added */
+/*				2	   Comment support added */
+#define IPSET_TYPE_REV_MAX	3	/* skbinfo support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -139,7 +140,10 @@ bitmap_port_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)   ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -291,6 +295,9 @@ static struct ip_set_type bitmap_port_type = {
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
