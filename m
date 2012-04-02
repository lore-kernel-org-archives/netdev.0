From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 23/51] ipset: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:13 -0400
Message-ID: <1333335521-1348-24-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292Ab2DBC7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:54 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netfilter/ipset/ip_set.h       |   46 ++++++++++-------
 include/linux/netfilter/ipset/ip_set_ahash.h |   21 +++++---
 net/netfilter/ipset/ip_set_bitmap_ip.c       |   33 +++++++------
 net/netfilter/ipset/ip_set_bitmap_ipmac.c    |   43 +++++++++-------
 net/netfilter/ipset/ip_set_bitmap_port.c     |   29 ++++++-----
 net/netfilter/ipset/ip_set_core.c            |   43 +++++++++-------
 net/netfilter/ipset/ip_set_hash_ip.c         |   20 +++++---
 net/netfilter/ipset/ip_set_hash_ipport.c     |   37 +++++++------
 net/netfilter/ipset/ip_set_hash_ipportip.c   |   45 +++++++++--------
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |   69 +++++++++++++------------
 net/netfilter/ipset/ip_set_hash_net.c        |   45 +++++++++--------
 net/netfilter/ipset/ip_set_hash_netiface.c   |   52 ++++++++++---------
 net/netfilter/ipset/ip_set_hash_netport.c    |   61 ++++++++++++-----------
 net/netfilter/ipset/ip_set_list_set.c        |   23 +++++----
 14 files changed, 309 insertions(+), 258 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 2f8e18a..d6d549c 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -411,26 +411,32 @@ ip_set_get_h16(const struct nlattr *attr)
 #define ipset_nest_start(skb, attr) nla_nest_start(skb, attr | NLA_F_NESTED)
 #define ipset_nest_end(skb, start)  nla_nest_end(skb, start)
 
-#define NLA_PUT_IPADDR4(skb, type, ipaddr)			\
-do {								\
-	struct nlattr *__nested = ipset_nest_start(skb, type);	\
-								\
-	if (!__nested)						\
-		goto nla_put_failure;				\
-	NLA_PUT_NET32(skb, IPSET_ATTR_IPADDR_IPV4, ipaddr);	\
-	ipset_nest_end(skb, __nested);				\
-} while (0)
-
-#define NLA_PUT_IPADDR6(skb, type, ipaddrptr)			\
-do {								\
-	struct nlattr *__nested = ipset_nest_start(skb, type);	\
-								\
-	if (!__nested)						\
-		goto nla_put_failure;				\
-	NLA_PUT(skb, IPSET_ATTR_IPADDR_IPV6,			\
-		sizeof(struct in6_addr), ipaddrptr);		\
-	ipset_nest_end(skb, __nested);				\
-} while (0)
+static inline int nla_put_ipaddr4(struct sk_buff *skb, int type, __be32 ipaddr)
+{
+	struct nlattr *__nested = ipset_nest_start(skb, type);
+	int ret;
+
+	if (!__nested)
+		return -EMSGSIZE;
+	ret = nla_put_net32(skb, IPSET_ATTR_IPADDR_IPV4, ipaddr);
+	if (!ret)
+		ipset_nest_end(skb, __nested);
+	return ret;
+}
+
+static inline int nla_put_ipaddr6(struct sk_buff *skb, int type, const struct in6_addr *ipaddrptr)
+{
+	struct nlattr *__nested = ipset_nest_start(skb, type);
+	int ret;
+
+	if (!__nested)
+		return -EMSGSIZE;
+	ret = nla_put(skb, IPSET_ATTR_IPADDR_IPV6,
+		      sizeof(struct in6_addr), ipaddrptr);
+	if (!ret)
+		ipset_nest_end(skb, __nested);
+	return ret;
+}
 
 /* Get address from skbuff */
 static inline __be32
diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index 05a5d72..289b62d 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -594,17 +594,20 @@ type_pf_head(struct ip_set *set, struct sk_buff *skb)
 	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 	if (!nested)
 		goto nla_put_failure;
-	NLA_PUT_NET32(skb, IPSET_ATTR_HASHSIZE,
-		      htonl(jhash_size(h->table->htable_bits)));
-	NLA_PUT_NET32(skb, IPSET_ATTR_MAXELEM, htonl(h->maxelem));
+	if (nla_put_net32(skb, IPSET_ATTR_HASHSIZE,
+			  htonl(jhash_size(h->table->htable_bits))) ||
+	    nla_put_net32(skb, IPSET_ATTR_MAXELEM, htonl(h->maxelem)))
+		goto nla_put_failure;
 #ifdef IP_SET_HASH_WITH_NETMASK
-	if (h->netmask != HOST_MASK)
-		NLA_PUT_U8(skb, IPSET_ATTR_NETMASK, h->netmask);
+	if (h->netmask != HOST_MASK &&
+	    nla_put_u8(skb, IPSET_ATTR_NETMASK, h->netmask))
+		goto nla_put_failure;
 #endif
-	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1));
-	NLA_PUT_NET32(skb, IPSET_ATTR_MEMSIZE, htonl(memsize));
-	if (with_timeout(h->timeout))
-		NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT, htonl(h->timeout));
+	if (nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
+	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE, htonl(memsize)) ||
+	    (with_timeout(h->timeout) &&
+	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(h->timeout))))
+		goto nla_put_failure;
 	ipset_nest_end(skb, nested);
 
 	return 0;
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index a72a4df..7e1b061 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -109,8 +109,9 @@ bitmap_ip_list(const struct ip_set *set,
 			} else
 				goto nla_put_failure;
 		}
-		NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP,
-				htonl(map->first_ip + id * map->hosts));
+		if (nla_put_ipaddr4(skb, IPSET_ATTR_IP,
+				    htonl(map->first_ip + id * map->hosts)))
+			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
 	ipset_nest_end(skb, atd);
@@ -194,10 +195,11 @@ bitmap_ip_tlist(const struct ip_set *set,
 			} else
 				goto nla_put_failure;
 		}
-		NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP,
-				htonl(map->first_ip + id * map->hosts));
-		NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-			      htonl(ip_set_timeout_get(members[id])));
+		if (nla_put_ipaddr4(skb, IPSET_ATTR_IP,
+				    htonl(map->first_ip + id * map->hosts)) ||
+		    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+				  htonl(ip_set_timeout_get(members[id]))))
+			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
 	ipset_nest_end(skb, adt);
@@ -334,15 +336,16 @@ bitmap_ip_head(struct ip_set *set, struct sk_buff *skb)
 	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 	if (!nested)
 		goto nla_put_failure;
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, htonl(map->first_ip));
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP_TO, htonl(map->last_ip));
-	if (map->netmask != 32)
-		NLA_PUT_U8(skb, IPSET_ATTR_NETMASK, map->netmask);
-	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1));
-	NLA_PUT_NET32(skb, IPSET_ATTR_MEMSIZE,
-		      htonl(sizeof(*map) + map->memsize));
-	if (with_timeout(map->timeout))
-		NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout));
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, htonl(map->first_ip)) ||
+	    nla_put_ipaddr4(skb, IPSET_ATTR_IP_TO, htonl(map->last_ip)) ||
+	    (map->netmask != 32 &&
+	     nla_put_u8(skb, IPSET_ATTR_NETMASK, map->netmask)) ||
+	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
+	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
+			  htonl(sizeof(*map) + map->memsize)) ||
+	    (with_timeout(map->timeout) &&
+	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout))))
+		goto nla_put_failure;
 	ipset_nest_end(skb, nested);
 
 	return 0;
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 81324c1..0bb16c4 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -186,11 +186,12 @@ bitmap_ipmac_list(const struct ip_set *set,
 			} else
 				goto nla_put_failure;
 		}
-		NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP,
-				htonl(map->first_ip + id));
-		if (elem->match == MAC_FILLED)
-			NLA_PUT(skb, IPSET_ATTR_ETHER, ETH_ALEN,
-				elem->ether);
+		if (nla_put_ipaddr4(skb, IPSET_ATTR_IP,
+				    htonl(map->first_ip + id)) ||
+		    (elem->match == MAC_FILLED &&
+		     nla_put(skb, IPSET_ATTR_ETHER, ETH_ALEN,
+			     elem->ether)))
+			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
 	ipset_nest_end(skb, atd);
@@ -314,14 +315,16 @@ bitmap_ipmac_tlist(const struct ip_set *set,
 			} else
 				goto nla_put_failure;
 		}
-		NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP,
-				htonl(map->first_ip + id));
-		if (elem->match == MAC_FILLED)
-			NLA_PUT(skb, IPSET_ATTR_ETHER, ETH_ALEN,
-				elem->ether);
+		if (nla_put_ipaddr4(skb, IPSET_ATTR_IP,
+				    htonl(map->first_ip + id)) ||
+		    (elem->match == MAC_FILLED &&
+		     nla_put(skb, IPSET_ATTR_ETHER, ETH_ALEN,
+			     elem->ether)))
+		    goto nla_put_failure;
 		timeout = elem->match == MAC_UNSET ? elem->timeout
 				: ip_set_timeout_get(elem->timeout);
-		NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT, htonl(timeout));
+		if (nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(timeout)))
+		    goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
 	ipset_nest_end(skb, atd);
@@ -438,14 +441,16 @@ bitmap_ipmac_head(struct ip_set *set, struct sk_buff *skb)
 	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 	if (!nested)
 		goto nla_put_failure;
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, htonl(map->first_ip));
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP_TO, htonl(map->last_ip));
-	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1));
-	NLA_PUT_NET32(skb, IPSET_ATTR_MEMSIZE,
-		      htonl(sizeof(*map)
-			    + (map->last_ip - map->first_ip + 1) * map->dsize));
-	if (with_timeout(map->timeout))
-		NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout));
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, htonl(map->first_ip)) ||
+	    nla_put_ipaddr4(skb, IPSET_ATTR_IP_TO, htonl(map->last_ip)) ||
+	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
+	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
+			  htonl(sizeof(*map) +
+				((map->last_ip - map->first_ip + 1) *
+				 map->dsize))) ||
+	    (with_timeout(map->timeout) &&
+	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout))))
+		goto nla_put_failure;
 	ipset_nest_end(skb, nested);
 
 	return 0;
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index 382ec28..b9f1fce 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -96,8 +96,9 @@ bitmap_port_list(const struct ip_set *set,
 			} else
 				goto nla_put_failure;
 		}
-		NLA_PUT_NET16(skb, IPSET_ATTR_PORT,
-			      htons(map->first_port + id));
+		if (nla_put_net16(skb, IPSET_ATTR_PORT,
+				  htons(map->first_port + id)))
+			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
 	ipset_nest_end(skb, atd);
@@ -183,10 +184,11 @@ bitmap_port_tlist(const struct ip_set *set,
 			} else
 				goto nla_put_failure;
 		}
-		NLA_PUT_NET16(skb, IPSET_ATTR_PORT,
-			      htons(map->first_port + id));
-		NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-			      htonl(ip_set_timeout_get(members[id])));
+		if (nla_put_net16(skb, IPSET_ATTR_PORT,
+				  htons(map->first_port + id)) ||
+		    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+				  htonl(ip_set_timeout_get(members[id]))))
+			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
 	ipset_nest_end(skb, adt);
@@ -320,13 +322,14 @@ bitmap_port_head(struct ip_set *set, struct sk_buff *skb)
 	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 	if (!nested)
 		goto nla_put_failure;
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, htons(map->first_port));
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT_TO, htons(map->last_port));
-	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1));
-	NLA_PUT_NET32(skb, IPSET_ATTR_MEMSIZE,
-		      htonl(sizeof(*map) + map->memsize));
-	if (with_timeout(map->timeout))
-		NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout));
+	if (nla_put_net16(skb, IPSET_ATTR_PORT, htons(map->first_port)) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT_TO, htons(map->last_port)) ||
+	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
+	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
+			  htonl(sizeof(*map) + map->memsize)) ||
+	    (with_timeout(map->timeout) &&
+	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout))))
+		goto nla_put_failure;
 	ipset_nest_end(skb, nested);
 
 	return 0;
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index e6c1c96..eb66b97 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1092,19 +1092,21 @@ dump_last:
 			ret = -EMSGSIZE;
 			goto release_refcount;
 		}
-		NLA_PUT_U8(skb, IPSET_ATTR_PROTOCOL, IPSET_PROTOCOL);
-		NLA_PUT_STRING(skb, IPSET_ATTR_SETNAME, set->name);
+		if (nla_put_u8(skb, IPSET_ATTR_PROTOCOL, IPSET_PROTOCOL) ||
+		    nla_put_string(skb, IPSET_ATTR_SETNAME, set->name))
+			goto nla_put_failure;
 		if (dump_flags & IPSET_FLAG_LIST_SETNAME)
 			goto next_set;
 		switch (cb->args[2]) {
 		case 0:
 			/* Core header data */
-			NLA_PUT_STRING(skb, IPSET_ATTR_TYPENAME,
-				       set->type->name);
-			NLA_PUT_U8(skb, IPSET_ATTR_FAMILY,
-				   set->family);
-			NLA_PUT_U8(skb, IPSET_ATTR_REVISION,
-				   set->revision);
+			if (nla_put_string(skb, IPSET_ATTR_TYPENAME,
+					   set->type->name) ||
+			    nla_put_u8(skb, IPSET_ATTR_FAMILY,
+				       set->family) ||
+			    nla_put_u8(skb, IPSET_ATTR_REVISION,
+				       set->revision))
+				goto nla_put_failure;
 			ret = set->variant->head(set, skb);
 			if (ret < 0)
 				goto release_refcount;
@@ -1410,11 +1412,12 @@ ip_set_header(struct sock *ctnl, struct sk_buff *skb,
 			 IPSET_CMD_HEADER);
 	if (!nlh2)
 		goto nlmsg_failure;
-	NLA_PUT_U8(skb2, IPSET_ATTR_PROTOCOL, IPSET_PROTOCOL);
-	NLA_PUT_STRING(skb2, IPSET_ATTR_SETNAME, set->name);
-	NLA_PUT_STRING(skb2, IPSET_ATTR_TYPENAME, set->type->name);
-	NLA_PUT_U8(skb2, IPSET_ATTR_FAMILY, set->family);
-	NLA_PUT_U8(skb2, IPSET_ATTR_REVISION, set->revision);
+	if (nla_put_u8(skb2, IPSET_ATTR_PROTOCOL, IPSET_PROTOCOL) ||
+	    nla_put_string(skb2, IPSET_ATTR_SETNAME, set->name) ||
+	    nla_put_string(skb2, IPSET_ATTR_TYPENAME, set->type->name) ||
+	    nla_put_u8(skb2, IPSET_ATTR_FAMILY, set->family) ||
+	    nla_put_u8(skb2, IPSET_ATTR_REVISION, set->revision))
+		goto nla_put_failure;
 	nlmsg_end(skb2, nlh2);
 
 	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
@@ -1469,11 +1472,12 @@ ip_set_type(struct sock *ctnl, struct sk_buff *skb,
 			 IPSET_CMD_TYPE);
 	if (!nlh2)
 		goto nlmsg_failure;
-	NLA_PUT_U8(skb2, IPSET_ATTR_PROTOCOL, IPSET_PROTOCOL);
-	NLA_PUT_STRING(skb2, IPSET_ATTR_TYPENAME, typename);
-	NLA_PUT_U8(skb2, IPSET_ATTR_FAMILY, family);
-	NLA_PUT_U8(skb2, IPSET_ATTR_REVISION, max);
-	NLA_PUT_U8(skb2, IPSET_ATTR_REVISION_MIN, min);
+	if (nla_put_u8(skb2, IPSET_ATTR_PROTOCOL, IPSET_PROTOCOL) ||
+	    nla_put_string(skb2, IPSET_ATTR_TYPENAME, typename) ||
+	    nla_put_u8(skb2, IPSET_ATTR_FAMILY, family) ||
+	    nla_put_u8(skb2, IPSET_ATTR_REVISION, max) ||
+	    nla_put_u8(skb2, IPSET_ATTR_REVISION_MIN, min))
+		goto nla_put_failure;
 	nlmsg_end(skb2, nlh2);
 
 	pr_debug("Send TYPE, nlmsg_len: %u\n", nlh2->nlmsg_len);
@@ -1517,7 +1521,8 @@ ip_set_protocol(struct sock *ctnl, struct sk_buff *skb,
 			 IPSET_CMD_PROTOCOL);
 	if (!nlh2)
 		goto nlmsg_failure;
-	NLA_PUT_U8(skb2, IPSET_ATTR_PROTOCOL, IPSET_PROTOCOL);
+	if (nla_put_u8(skb2, IPSET_ATTR_PROTOCOL, IPSET_PROTOCOL))
+		goto nla_put_failure;
 	nlmsg_end(skb2, nlh2);
 
 	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 5139dea..507fe93 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -81,7 +81,8 @@ hash_ip4_data_zero_out(struct hash_ip4_elem *elem)
 static inline bool
 hash_ip4_data_list(struct sk_buff *skb, const struct hash_ip4_elem *data)
 {
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, data->ip);
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, data->ip))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -94,9 +95,10 @@ hash_ip4_data_tlist(struct sk_buff *skb, const struct hash_ip4_elem *data)
 	const struct hash_ip4_telem *tdata =
 		(const struct hash_ip4_telem *)data;
 
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, tdata->ip);
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(tdata->timeout)));
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, tdata->ip) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(tdata->timeout))))
+		goto nla_put_failure;
 
 	return 0;
 
@@ -262,7 +264,8 @@ ip6_netmask(union nf_inet_addr *ip, u8 prefix)
 static bool
 hash_ip6_data_list(struct sk_buff *skb, const struct hash_ip6_elem *data)
 {
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &data->ip);
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &data->ip.in6))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -275,9 +278,10 @@ hash_ip6_data_tlist(struct sk_buff *skb, const struct hash_ip6_elem *data)
 	const struct hash_ip6_telem *e =
 		(const struct hash_ip6_telem *)data;
 
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &e->ip);
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(e->timeout)));
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(e->timeout))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 9c27e24..68f284c 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -93,9 +93,10 @@ static bool
 hash_ipport4_data_list(struct sk_buff *skb,
 		       const struct hash_ipport4_elem *data)
 {
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, data->ip);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, data->ip) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -109,12 +110,12 @@ hash_ipport4_data_tlist(struct sk_buff *skb,
 	const struct hash_ipport4_telem *tdata =
 		(const struct hash_ipport4_telem *)data;
 
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, tdata->ip);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, tdata->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(tdata->timeout)));
-
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, tdata->ip) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, tdata->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(tdata->timeout))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -308,9 +309,10 @@ static bool
 hash_ipport6_data_list(struct sk_buff *skb,
 		       const struct hash_ipport6_elem *data)
 {
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &data->ip);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &data->ip.in6) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -324,11 +326,12 @@ hash_ipport6_data_tlist(struct sk_buff *skb,
 	const struct hash_ipport6_telem *e =
 		(const struct hash_ipport6_telem *)data;
 
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &e->ip);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(e->timeout)));
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(e->timeout))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 9134057..1eec4b9 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -94,10 +94,11 @@ static bool
 hash_ipportip4_data_list(struct sk_buff *skb,
 		       const struct hash_ipportip4_elem *data)
 {
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, data->ip);
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP2, data->ip2);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, data->ip) ||
+	    nla_put_ipaddr4(skb, IPSET_ATTR_IP2, data->ip2) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -111,13 +112,13 @@ hash_ipportip4_data_tlist(struct sk_buff *skb,
 	const struct hash_ipportip4_telem *tdata =
 		(const struct hash_ipportip4_telem *)data;
 
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, tdata->ip);
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP2, tdata->ip2);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, tdata->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(tdata->timeout)));
-
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, tdata->ip) ||
+	    nla_put_ipaddr4(skb, IPSET_ATTR_IP2, tdata->ip2) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, tdata->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(tdata->timeout))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -319,10 +320,11 @@ static bool
 hash_ipportip6_data_list(struct sk_buff *skb,
 			 const struct hash_ipportip6_elem *data)
 {
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &data->ip);
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP2, &data->ip2);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &data->ip.in6) ||
+	    nla_put_ipaddr6(skb, IPSET_ATTR_IP2, &data->ip2.in6) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -336,12 +338,13 @@ hash_ipportip6_data_tlist(struct sk_buff *skb,
 	const struct hash_ipportip6_telem *e =
 		(const struct hash_ipportip6_telem *)data;
 
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &e->ip);
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP2, &data->ip2);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(e->timeout)));
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
+	    nla_put_ipaddr6(skb, IPSET_ATTR_IP2, &data->ip2.in6) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(e->timeout))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 5d05e69..62d66ec 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -124,13 +124,14 @@ hash_ipportnet4_data_list(struct sk_buff *skb,
 {
 	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, data->ip);
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP2, data->ip2);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR2, data->cidr + 1);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, data->ip) ||
+	    nla_put_ipaddr4(skb, IPSET_ATTR_IP2, data->ip2) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR2, data->cidr + 1) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -145,16 +146,16 @@ hash_ipportnet4_data_tlist(struct sk_buff *skb,
 		(const struct hash_ipportnet4_telem *)data;
 	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, tdata->ip);
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP2, tdata->ip2);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, tdata->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR2, data->cidr + 1);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(tdata->timeout)));
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
-
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, tdata->ip) ||
+	    nla_put_ipaddr4(skb, IPSET_ATTR_IP2, tdata->ip2) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, tdata->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR2, data->cidr + 1) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(tdata->timeout))) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -436,13 +437,14 @@ hash_ipportnet6_data_list(struct sk_buff *skb,
 {
 	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &data->ip);
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP2, &data->ip2);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR2, data->cidr + 1);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &data->ip.in6) ||
+	    nla_put_ipaddr6(skb, IPSET_ATTR_IP2, &data->ip2.in6) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR2, data->cidr + 1) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -457,15 +459,16 @@ hash_ipportnet6_data_tlist(struct sk_buff *skb,
 		(const struct hash_ipportnet6_telem *)data;
 	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &e->ip);
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP2, &data->ip2);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR2, data->cidr + 1);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(e->timeout)));
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
+	    nla_put_ipaddr6(skb, IPSET_ATTR_IP2, &data->ip2.in6) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR2, data->cidr + 1) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(e->timeout))) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 7c3d945..6607a81 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -111,10 +111,11 @@ hash_net4_data_list(struct sk_buff *skb, const struct hash_net4_elem *data)
 {
 	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, data->ip);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, data->ip) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -128,13 +129,13 @@ hash_net4_data_tlist(struct sk_buff *skb, const struct hash_net4_elem *data)
 		(const struct hash_net4_telem *)data;
 	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, tdata->ip);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, tdata->cidr);
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(tdata->timeout)));
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
-
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, tdata->ip) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, tdata->cidr) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(tdata->timeout))) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -339,10 +340,11 @@ hash_net6_data_list(struct sk_buff *skb, const struct hash_net6_elem *data)
 {
 	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &data->ip);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &data->ip.in6) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -356,12 +358,13 @@ hash_net6_data_tlist(struct sk_buff *skb, const struct hash_net6_elem *data)
 		(const struct hash_net6_telem *)data;
 	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &e->ip);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, e->cidr);
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(e->timeout)));
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, e->cidr) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(e->timeout))) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index f24037f..6093f3d 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -252,11 +252,12 @@ hash_netiface4_data_list(struct sk_buff *skb,
 
 	if (data->nomatch)
 		flags |= IPSET_FLAG_NOMATCH;
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, data->ip);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
-	NLA_PUT_STRING(skb, IPSET_ATTR_IFACE, data->iface);
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, data->ip) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr) ||
+	    nla_put_string(skb, IPSET_ATTR_IFACE, data->iface) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -273,13 +274,14 @@ hash_netiface4_data_tlist(struct sk_buff *skb,
 
 	if (data->nomatch)
 		flags |= IPSET_FLAG_NOMATCH;
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, data->ip);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
-	NLA_PUT_STRING(skb, IPSET_ATTR_IFACE, data->iface);
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(tdata->timeout)));
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, data->ip) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr) ||
+	    nla_put_string(skb, IPSET_ATTR_IFACE, data->iface) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(tdata->timeout))))
+		goto nla_put_failure;
 
 	return 0;
 
@@ -555,11 +557,12 @@ hash_netiface6_data_list(struct sk_buff *skb,
 
 	if (data->nomatch)
 		flags |= IPSET_FLAG_NOMATCH;
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &data->ip);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
-	NLA_PUT_STRING(skb, IPSET_ATTR_IFACE, data->iface);
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &data->ip.in6) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr) ||
+	    nla_put_string(skb, IPSET_ATTR_IFACE, data->iface) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -576,13 +579,14 @@ hash_netiface6_data_tlist(struct sk_buff *skb,
 
 	if (data->nomatch)
 		flags |= IPSET_FLAG_NOMATCH;
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &e->ip);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
-	NLA_PUT_STRING(skb, IPSET_ATTR_IFACE, data->iface);
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(e->timeout)));
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr) ||
+	    nla_put_string(skb, IPSET_ATTR_IFACE, data->iface) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(e->timeout))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index ce2e771..ae3c644 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -124,12 +124,13 @@ hash_netport4_data_list(struct sk_buff *skb,
 {
 	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, data->ip);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr + 1);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, data->ip) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr + 1) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -144,15 +145,15 @@ hash_netport4_data_tlist(struct sk_buff *skb,
 		(const struct hash_netport4_telem *)data;
 	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
-	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, tdata->ip);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, tdata->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr + 1);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(tdata->timeout)));
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
-
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, tdata->ip) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, tdata->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr + 1) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(tdata->timeout))) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -402,12 +403,13 @@ hash_netport6_data_list(struct sk_buff *skb,
 {
 	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &data->ip);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr + 1);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &data->ip.in6) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr + 1) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -422,14 +424,15 @@ hash_netport6_data_tlist(struct sk_buff *skb,
 		(const struct hash_netport6_telem *)data;
 	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
-	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &e->ip);
-	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr + 1);
-	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
-	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-		      htonl(ip_set_timeout_get(e->timeout)));
-	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
+	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr + 1) ||
+	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
+	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			  htonl(ip_set_timeout_get(e->timeout))) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 7e095f9..6cb1225 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -402,12 +402,13 @@ list_set_head(struct ip_set *set, struct sk_buff *skb)
 	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 	if (!nested)
 		goto nla_put_failure;
-	NLA_PUT_NET32(skb, IPSET_ATTR_SIZE, htonl(map->size));
-	if (with_timeout(map->timeout))
-		NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout));
-	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1));
-	NLA_PUT_NET32(skb, IPSET_ATTR_MEMSIZE,
-		      htonl(sizeof(*map) + map->size * map->dsize));
+	if (nla_put_net32(skb, IPSET_ATTR_SIZE, htonl(map->size)) ||
+	    (with_timeout(map->timeout) &&
+	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout))) ||
+	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
+	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
+			  htonl(sizeof(*map) + map->size * map->dsize)))
+		goto nla_put_failure;
 	ipset_nest_end(skb, nested);
 
 	return 0;
@@ -442,13 +443,15 @@ list_set_list(const struct ip_set *set,
 			} else
 				goto nla_put_failure;
 		}
-		NLA_PUT_STRING(skb, IPSET_ATTR_NAME,
-			       ip_set_name_byindex(e->id));
+		if (nla_put_string(skb, IPSET_ATTR_NAME,
+				   ip_set_name_byindex(e->id)))
+			goto nla_put_failure;
 		if (with_timeout(map->timeout)) {
 			const struct set_telem *te =
 				(const struct set_telem *) e;
-			NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
-				      htonl(ip_set_timeout_get(te->timeout)));
+			__be32 to = htonl(ip_set_timeout_get(te->timeout));
+			if (nla_put_net32(skb, IPSET_ATTR_TIMEOUT, to))
+				goto nla_put_failure;
 		}
 		ipset_nest_end(skb, nested);
 	}
-- 
1.7.7.6
