From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [RFC PATCH] sctp: fix sctp to work with ipv6 source address routing
Date: Mon,  3 May 2010 12:50:03 -0400
Message-ID: <1272905403-5978-1-git-send-email-vladislav.yasevich@hp.com>
References: <4BCE68EE.8020500@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: Weixing.Shi@windriver.com, yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:21118 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758806Ab0ECQuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 12:50:05 -0400
In-Reply-To: <4BCE68EE.8020500@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weixing Shi <Weixing.Shi@windriver.com>

<vlad>
  So I've updated this patch with Wei's and my own suggestings.  Here is an
  update.  Please review and verify that in your environment this still works.
</vlad>

in the below test case, using the source address routing,
sctp can not work.
Node-A
1)ifconfig eth0 inet6 add 2001:1::1/64
2)ip -6 rule add from 2001:1::1 table 100 pref 100
3)ip -6 route add 2001:2::1 dev eth0 table 100
4)sctp_darn -H 2001:1::1 -P 250 -l &
Node-B
1)ifconfig eth0 inet6 add 2001:2::1/64
2)ip -6 rule add from 2001:2::1 table 100 pref 100
3)ip -6 route add 2001:1::1 dev eth0 table 100
4)sctp_darn -H 2001:2::1 -P 250 -h 2001:1::1 -p 250 -s

root cause:
Node-A and Node-B use the source address routing, and
at begining, source address will be NULL,sctp will
search the  routing table by the destination address,
because using the source address routing table, and
the result dst_entry will be NULL.

solution:
walk through the bind address list to get the source
address and then lookup the routing table again to get
the correct dst_entry.

Signed-off-by: Weixing Shi <Weixing.Shi@windriver.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/ipv6.c |  112 ++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 69 insertions(+), 43 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 7326891..2a987a2 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -77,6 +77,10 @@
 #include <net/sctp/sctp.h>
 
 #include <asm/uaccess.h>
+static void sctp_v6_dst_saddr(union sctp_addr *addr, struct dst_entry *dst,
+            __be16 port);
+static int sctp_v6_cmp_addr(const union sctp_addr *addr1,
+          const union sctp_addr *addr2);
 
 /* Event handler for inet6 address addition/deletion events.
  * The sctp_local_addr_list needs to be protocted by a spin lock since
@@ -242,8 +246,12 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 					 union sctp_addr *daddr,
 					 union sctp_addr *saddr)
 {
-	struct dst_entry *dst;
+	struct dst_entry *dst = NULL;
 	struct flowi fl;
+	struct sctp_bind_addr *bp;
+	struct sctp_sockaddr_entry *laddr;
+	union sctp_addr dst_saddr;
+	sctp_scope_t scope;
 
 	memset(&fl, 0, sizeof(fl));
 	ipv6_addr_copy(&fl.fl6_dst, &daddr->v6.sin6_addr);
@@ -259,16 +267,70 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 	}
 
 	dst = ip6_route_output(&init_net, NULL, &fl);
+	if (!asoc || saddr)
+		goto out;
+
+	bp = &asoc->base.bind_addr;
+	scope = sctp_scope(daddr);
+
 	if (!dst->error) {
+		/* Walk through the bind address list and look for a bind
+		 * address that matches the source address of the returned dst.
+		 */
+		sctp_v6_dst_saddr(&dst_saddr, dst, htons(bp->port));
+		rcu_read_lock();
+		list_for_each_entry_rcu(laddr, &bp->address_list, list) {
+			if (!laddr->valid || (laddr->state != SCTP_ADDR_SRC))
+				continue;
+
+			/* Do not compare against v4 addrs */
+			if ((laddr->a.sa.sa_family == AF_INET6) &&
+			   (sctp_v6_cmp_addr(&dst_saddr, &laddr->a)))
+				goto out_unlock;
+		}
+		rcu_read_unlock();
+
+		/* None of the bound addresses match the source address of the
+		 * dst. So release it.
+		 */
+		dst_release(dst);
+		dst = NULL;
+	}
+
+	/* Walk through the bind address list and try to get a dst that
+	 * matches a bind address as the source address.
+	 */
+	rcu_read_lock();
+	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
+		if (!laddr->valid || (laddr->state != SCTP_ADDR_SRC))
+			continue;
+
+		if ((laddr->a.sa.sa_family == AF_INET6) &&
+		    (scope <= sctp_scope(&laddr->a))) {
+			ipv6_addr_copy(&fl.fl6_src, &laddr->a.v6.sin6_addr);
+			dst = ip6_route_output(&init_net, NULL, &fl);
+			if (dst->error) {
+				dst_release(dst);
+				dst = NULL;
+			} else
+				break;
+		}
+	}
+
+out_unlock:
+	rcu_read_unlock();
+
+out:
+	if (dst) {
 		struct rt6_info *rt;
 		rt = (struct rt6_info *)dst;
 		SCTP_DEBUG_PRINTK("rt6_dst:%pI6 rt6_src:%pI6\n",
 			&rt->rt6i_dst.addr, &rt->rt6i_src.addr);
 		return dst;
-	}
-	SCTP_DEBUG_PRINTK("NO ROUTE\n");
-	dst_release(dst);
-	return NULL;
+	} else 
+		SCTP_DEBUG_PRINTK("NO ROUTE\n");
+
+	return dst;
 }
 
 /* Returns the number of consecutive initial bits that match in the 2 ipv6
@@ -289,13 +351,6 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 			      union sctp_addr *daddr,
 			      union sctp_addr *saddr)
 {
-	struct sctp_bind_addr *bp;
-	struct sctp_sockaddr_entry *laddr;
-	sctp_scope_t scope;
-	union sctp_addr *baddr = NULL;
-	__u8 matchlen = 0;
-	__u8 bmatchlen;
-
 	SCTP_DEBUG_PRINTK("%s: asoc:%p dst:%p daddr:%pI6 ",
 			  __func__, asoc, dst, &daddr->v6.sin6_addr);
 
@@ -310,38 +365,9 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 		return;
 	}
 
-	scope = sctp_scope(daddr);
-
-	bp = &asoc->base.bind_addr;
-
-	/* Go through the bind address list and find the best source address
-	 * that matches the scope of the destination address.
-	 */
-	rcu_read_lock();
-	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
-		if (!laddr->valid)
-			continue;
-		if ((laddr->state == SCTP_ADDR_SRC) &&
-		    (laddr->a.sa.sa_family == AF_INET6) &&
-		    (scope <= sctp_scope(&laddr->a))) {
-			bmatchlen = sctp_v6_addr_match_len(daddr, &laddr->a);
-			if (!baddr || (matchlen < bmatchlen)) {
-				baddr = &laddr->a;
-				matchlen = bmatchlen;
-			}
-		}
-	}
-
-	if (baddr) {
-		memcpy(saddr, baddr, sizeof(union sctp_addr));
-		SCTP_DEBUG_PRINTK("saddr: %pI6\n", &saddr->v6.sin6_addr);
-	} else {
-		printk(KERN_ERR "%s: asoc:%p Could not find a valid source "
-		       "address for the dest:%pI6\n",
-		       __func__, asoc, &daddr->v6.sin6_addr);
-	}
+	if (dst)
+		sctp_v6_dst_saddr(saddr, dst, htons(asoc->base.bind_addr.port));
 
-	rcu_read_unlock();
 }
 
 /* Make a copy of all potential local addresses. */
-- 
1.6.0.4

