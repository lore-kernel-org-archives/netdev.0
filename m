From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/33] netfilter: ipset: Support comments in the list-type ipset.
Date: Fri,  4 Oct 2013 10:33:08 +0200
Message-ID: <1380875598-5250-24-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>

This provides kernel support for creating list ipsets with the comment
annotation extension.

Signed-off-by: Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_list_set.c |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 30bf1dd..f9681dc 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -16,7 +16,8 @@
 #include <linux/netfilter/ipset/ip_set_list.h>
 
 #define IPSET_TYPE_REV_MIN	0
-#define IPSET_TYPE_REV_MAX	1 /* Counters support added */
+/*				1    Counters support added */
+#define IPSET_TYPE_REV_MAX	2 /* Comments support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -191,6 +192,8 @@ list_set_add(struct ip_set *set, u32 i, struct set_adt_elem *d,
 		ip_set_timeout_set(ext_timeout(e, set), ext->timeout);
 	if (SET_WITH_COUNTER(set))
 		ip_set_init_counter(ext_counter(e, set), ext);
+	if (SET_WITH_COMMENT(set) && ext->comment)
+		ip_set_init_comment(ext_comment(e, set), ext);
 	return 0;
 }
 
@@ -299,6 +302,8 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 			ip_set_timeout_set(ext_timeout(e, set), ext->timeout);
 		if (SET_WITH_COUNTER(set))
 			ip_set_init_counter(ext_counter(e, set), ext);
+		if (SET_WITH_COMMENT(set))
+			ip_set_init_comment(ext_comment(e, set), ext);
 		/* Set is already added to the list */
 		ip_set_put_byindex(d->id);
 		return 0;
@@ -461,15 +466,12 @@ list_set_head(struct ip_set *set, struct sk_buff *skb)
 	if (!nested)
 		goto nla_put_failure;
 	if (nla_put_net32(skb, IPSET_ATTR_SIZE, htonl(map->size)) ||
-	    (SET_WITH_TIMEOUT(set) &&
-	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(set->timeout))) ||
-	    (SET_WITH_COUNTER(set) &&
-	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS,
-			   htonl(IPSET_FLAG_WITH_COUNTERS))) ||
 	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
 	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
 			  htonl(sizeof(*map) + map->size * set->dsize)))
 		goto nla_put_failure;
+	if (unlikely(ip_set_put_flags(skb, set)))
+		goto nla_put_failure;
 	ipset_nest_end(skb, nested);
 
 	return 0;
@@ -516,6 +518,9 @@ list_set_list(const struct ip_set *set,
 		if (SET_WITH_COUNTER(set) &&
 		    ip_set_put_counter(skb, ext_counter(e, set)))
 			goto nla_put_failure;
+		if (SET_WITH_COMMENT(set) &&
+		    ip_set_put_comment(skb, ext_comment(e, set)))
+			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
 finish:
@@ -660,6 +665,7 @@ static struct ip_set_type list_set_type __read_mostly = {
 		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
 	},
 	.me		= THIS_MODULE,
 };
-- 
1.7.10.4

