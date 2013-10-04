From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/33] netfilter: ipset: Support comments in bitmap-type ipsets.
Date: Fri,  4 Oct 2013 10:33:07 +0200
Message-ID: <1380875598-5250-23-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>

This provides kernel support for creating bitmap ipsets with comment
support.

As is the case for hashes, this incurs a penalty when flushing or
destroying the entire ipset as the entries must first be walked in order
to free the comment strings. This penalty is of course far less than the
cost of listing an ipset to userspace. Any set created without support
for comments will be flushed/destroyed as before.

Signed-off-by: Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_bitmap_gen.h   |   14 ++++++++------
 net/netfilter/ipset/ip_set_bitmap_ip.c    |    4 +++-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |    4 +++-
 net/netfilter/ipset/ip_set_bitmap_port.c  |    4 +++-
 4 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index 4515fe8..6167fc9 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -101,12 +101,9 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
 			  htonl(sizeof(*map) +
 				map->memsize +
-				set->dsize * map->elements)) ||
-	    (SET_WITH_TIMEOUT(set) &&
-	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(set->timeout))) ||
-	    (SET_WITH_COUNTER(set) &&
-	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS,
-			   htonl(IPSET_FLAG_WITH_COUNTERS))))
+				set->dsize * map->elements)))
+		goto nla_put_failure;
+	if (unlikely(ip_set_put_flags(skb, set)))
 		goto nla_put_failure;
 	ipset_nest_end(skb, nested);
 
@@ -162,6 +159,8 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 
 	if (SET_WITH_COUNTER(set))
 		ip_set_init_counter(ext_counter(x, set), ext);
+	if (SET_WITH_COMMENT(set))
+		ip_set_init_comment(ext_comment(x, set), ext);
 	return 0;
 }
 
@@ -233,6 +232,9 @@ mtype_list(const struct ip_set *set,
 		if (SET_WITH_COUNTER(set) &&
 		    ip_set_put_counter(skb, ext_counter(x, set)))
 			goto nla_put_failure;
+		if (SET_WITH_COMMENT(set) &&
+		    ip_set_put_comment(skb, ext_comment(x, set)))
+			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
 	ipset_nest_end(skb, adt);
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 94d9854..faac124 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -26,7 +26,8 @@
 #include <linux/netfilter/ipset/ip_set_bitmap.h>
 
 #define IPSET_TYPE_REV_MIN	0
-#define IPSET_TYPE_REV_MAX	1	/* Counter support added */
+/*				1	   Counter support added */
+#define IPSET_TYPE_REV_MAX	2	/* Comment support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -354,6 +355,7 @@ static struct ip_set_type bitmap_ip_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 654a97b..fb4d163 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -26,7 +26,8 @@
 #include <linux/netfilter/ipset/ip_set_bitmap.h>
 
 #define IPSET_TYPE_REV_MIN	0
-#define IPSET_TYPE_REV_MAX	1	/* Counter support added */
+/*				1	   Counter support added */
+#define IPSET_TYPE_REV_MAX	2	/* Comment support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -403,6 +404,7 @@ static struct ip_set_type bitmap_ipmac_type = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index 1ef2f31..407a63c 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -21,7 +21,8 @@
 #include <linux/netfilter/ipset/ip_set_getport.h>
 
 #define IPSET_TYPE_REV_MIN	0
-#define IPSET_TYPE_REV_MAX	1	/* Counter support added */
+/*				1	   Counter support added */
+#define IPSET_TYPE_REV_MAX	2	/* Comment support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -288,6 +289,7 @@ static struct ip_set_type bitmap_port_type = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
 	},
 	.me		= THIS_MODULE,
 };
-- 
1.7.10.4

