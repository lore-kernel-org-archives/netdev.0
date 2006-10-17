From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 9/13] [SCTP] Merge IPv4 and IPv6 versions of get_saddr() with
 their corresponding get_dst().
Date: Tue, 17 Oct 2006 03:19:57 +0300
Message-ID: <453421AD.1010906@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:10514 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422969AbWJQAT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 20:19:59 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


As the IPv6 route lookup now also returns the selected source address
there is no need for a separate source address lookup. In fact, the
source address selection needs to be moved to get_dst() because the
selected IPv6 source address isn't always stored in the route.
Sometimes this makes it impossible to guess the correct address later on.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 include/net/sctp/structs.h |    7 -
 net/sctp/ipv6.c            |  235 +++++++++++++++++++++++---------------------
 net/sctp/protocol.c        |   56 ++++------
 net/sctp/transport.c       |    8 +
 4 files changed, 148 insertions(+), 158 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index c6d93bb..e0973a3 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -529,15 +529,8 @@ struct sctp_af {
 	struct dst_entry *(*get_dst)	(struct sctp_association *asoc,
 					 union sctp_addr *daddr,
 					 union sctp_addr *saddr);
-	void		(*get_saddr)	(struct sctp_association *asoc,
-					 struct dst_entry *dst,
-					 union sctp_addr *daddr,
-					 union sctp_addr *saddr);
 	void		(*copy_addrlist) (struct list_head *,
 					  struct net_device *);
-	void		(*dst_saddr)	(union sctp_addr *saddr,
-					 struct dst_entry *dst,
-					 unsigned short port);
 	int		(*cmp_addr)	(const union sctp_addr *addr1,
 					 const union sctp_addr *addr2);
 	void		(*addr_copy)	(union sctp_addr *dst,
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 78071c6..68ead54 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -188,46 +188,6 @@ static int sctp_v6_xmit(struct sk_buff *
 	return ip6_xmit(sk, skb, &fl, np->opt, ipfragok);
 }

-/* Returns the dst cache entry for the given source and destination ip
- * addresses.
- */
-static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
-					 union sctp_addr *daddr,
-					 union sctp_addr *saddr)
-{
-	struct dst_entry *dst;
-	struct flowi fl;
-
-	memset(&fl, 0, sizeof(fl));
-	ipv6_addr_copy(&fl.fl6_dst, &daddr->v6.sin6_addr);
-	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
-		fl.oif = daddr->v6.sin6_scope_id;
-	
-
-	SCTP_DEBUG_PRINTK("%s: DST=" NIP6_FMT " ",
-			  __FUNCTION__, NIP6(fl.fl6_dst));
-
-	if (saddr) {
-		ipv6_addr_copy(&fl.fl6_src, &saddr->v6.sin6_addr);
-		SCTP_DEBUG_PRINTK(
-			"SRC=" NIP6_FMT " - ",
-			NIP6(fl.fl6_src));
-	}
-
-	dst = ip6_route_output(NULL, &fl);
-	if (!dst->error) {
-		struct rt6_info *rt;
-		rt = (struct rt6_info *)dst;
-		SCTP_DEBUG_PRINTK(
-			"rt6_dst:" NIP6_FMT " rt6_src:" NIP6_FMT "\n",
-			NIP6(rt->rt6i_dst.addr), NIP6(rt->rt6i_src.addr));
-		return dst;
-	}
-	SCTP_DEBUG_PRINTK("NO ROUTE\n");
-	dst_release(dst);
-	return NULL;
-}
-
 /* Returns the number of consecutive initial bits that match in the 2 ipv6
  * addresses.
  */
@@ -250,69 +210,6 @@ static inline int sctp_v6_addr_match_len
 	return (i*32);
 }

-/* Fills in the source address(saddr) based on the destination address(daddr)
- * and asoc's bind address list.
- */
-static void sctp_v6_get_saddr(struct sctp_association *asoc,
-			      struct dst_entry *dst,
-			      union sctp_addr *daddr,
-			      union sctp_addr *saddr)
-{
-	struct sctp_bind_addr *bp;
-	rwlock_t *addr_lock;
-	struct sctp_sockaddr_entry *laddr;
-	struct list_head *pos;
-	sctp_scope_t scope;
-	union sctp_addr *baddr = NULL;
-	__u8 matchlen = 0;
-	__u8 bmatchlen;
-
-	SCTP_DEBUG_PRINTK("%s: asoc:%p dst:%p "
-			  "daddr:" NIP6_FMT " ",
-			  __FUNCTION__, asoc, dst, NIP6(daddr->v6.sin6_addr));
-
-	if (!asoc) {
-		ipv6_get_saddr(dst, &daddr->v6.sin6_addr,&saddr->v6.sin6_addr);
-		SCTP_DEBUG_PRINTK("saddr from ipv6_get_saddr: " NIP6_FMT "\n",
-				  NIP6(saddr->v6.sin6_addr));
-		return;
-	}
-
-	scope = sctp_scope(daddr);
-
-	bp = &asoc->base.bind_addr;
-	addr_lock = &asoc->base.addr_lock;
-
-	/* Go through the bind address list and find the best source address
-	 * that matches the scope of the destination address.
-	 */
-	sctp_read_lock(addr_lock);
-	list_for_each(pos, &bp->address_list) {
-		laddr = list_entry(pos, struct sctp_sockaddr_entry, list);
-		if ((laddr->use_as_src) &&
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
-		SCTP_DEBUG_PRINTK("saddr: " NIP6_FMT "\n",
-				  NIP6(saddr->v6.sin6_addr));
-	} else {
-		printk(KERN_ERR "%s: asoc:%p Could not find a valid source "
-		       "address for the dest:" NIP6_FMT "\n",
-		       __FUNCTION__, asoc, NIP6(daddr->v6.sin6_addr));
-	}
-
-	sctp_read_unlock(addr_lock);
-}
-
 /* Make a copy of all potential local addresses. */
 static void sctp_v6_copy_addrlist(struct list_head *addrlist,
 				  struct net_device *dev)
@@ -431,14 +328,14 @@ static int sctp_v6_to_addr_param(const u
 	return length;
 }

-/* Initialize a sctp_addr from a dst_entry. */
-static void sctp_v6_dst_saddr(union sctp_addr *addr, struct dst_entry *dst,
-			      unsigned short port)
+/* Initialize a sctp_addr from a flowi. */
+static void sctp_v6_fl_saddr(union sctp_addr *addr, struct flowi *fl,
+			     unsigned short port)
 {
-	struct rt6_info *rt = (struct rt6_info *)dst;
 	addr->sa.sa_family = AF_INET6;
 	addr->v6.sin6_port = port;
-	ipv6_addr_copy(&addr->v6.sin6_addr, &rt->rt6i_src.addr);
+	ipv6_addr_copy(&addr->v6.sin6_addr, &fl->fl6_src);
+	addr->v6.sin6_scope_id = fl->oif;
 }

 /* Compare addresses exactly.
@@ -479,6 +376,126 @@ static int sctp_v6_cmp_addr(const union
 	return 1;
 }

+/* Returns the dst cache entry for the given source and destination ip
+ * addresses.
+ */
+static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
+					 union sctp_addr *daddr,
+					 union sctp_addr *saddr)
+{
+	struct dst_entry *dst;
+	struct flowi fl;
+	struct sctp_bind_addr *bp;
+	rwlock_t *addr_lock;
+	struct sctp_sockaddr_entry *laddr;
+	struct list_head *pos;
+	struct rt6_info *rt;
+	union sctp_addr baddr;
+	sctp_scope_t scope;
+	__u8 matchlen = 0;
+	__u8 bmatchlen;
+
+	memset(&fl, 0, sizeof(fl));
+	ipv6_addr_copy(&fl.fl6_dst, &daddr->v6.sin6_addr);
+	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
+		fl.oif = daddr->v6.sin6_scope_id;
+
+	ipv6_addr_copy(&fl.fl6_src, &saddr->v6.sin6_addr);
+	SCTP_DEBUG_PRINTK("%s: DST=" NIP6_FMT " SRC=" NIP6_FMT " ",
+			  __FUNCTION__, NIP6(fl.fl6_dst), NIP6(fl.fl6_src));
+
+	dst = ip6_route_output(NULL, &fl);
+	if (dst->error) {
+		dst_release(dst);
+		dst = NULL;
+	}
+	if (!ipv6_addr_any(&saddr->v6.sin6_addr))
+		goto out;
+	if (!asoc) {
+		if (dst)
+			ipv6_addr_copy(&saddr->v6.sin6_addr, &fl.fl6_src);
+		goto out;
+	}
+	bp = &asoc->base.bind_addr;
+	addr_lock = &asoc->base.addr_lock;
+
+	if (dst) {
+		/* Walk through the bind address list and look for a bind
+		 * address that matches the source address of the returned rt.
+		 */
+		sctp_v6_fl_saddr(&baddr, &fl, bp->port);
+		sctp_read_lock(addr_lock);
+		list_for_each(pos, &bp->address_list) {
+			laddr = list_entry(pos, struct sctp_sockaddr_entry,
+					   list);
+			if (!laddr->use_as_src)
+				continue;
+			if (sctp_v6_cmp_addr(&baddr, &laddr->a))
+				goto init_saddr;
+		}
+		sctp_read_unlock(addr_lock);
+
+		/* Invalid rt or none of the bound addresses match the source
+		 * address. So release it.
+		 */
+		dst_release(dst);
+		dst = NULL;
+	}
+
+	/* Go through the bind address list and find the best source address
+	 * that matches the scope of the destination address.
+	 */
+	memset(&baddr, 0, sizeof(union sctp_addr));
+	scope = sctp_scope(daddr);
+	sctp_read_lock(addr_lock);
+	list_for_each(pos, &bp->address_list) {
+		laddr = list_entry(pos, struct sctp_sockaddr_entry, list);
+		
+		if (!laddr->use_as_src ||
+		    laddr->a.sa.sa_family != AF_INET6 ||
+		    scope > sctp_scope(&laddr->a) ||
+		    (ipv6_addr_type(&laddr->a.v6.sin6_addr) &
+		     IPV6_ADDR_LINKLOCAL &&
+		     laddr->a.v6.sin6_scope_id != fl.oif))
+			continue;
+
+		bmatchlen = sctp_v6_addr_match_len(daddr, &laddr->a);
+		if (!dst || (matchlen < bmatchlen)) {
+			struct dst_entry *dst2;
+			ipv6_addr_copy(&fl.fl6_src, &laddr->a.v6.sin6_addr);
+			dst2 = ip6_route_output(NULL, &fl);
+			if (dst2->error) {
+				dst_release(dst2);
+				dst2 = NULL;
+				continue;
+			}
+			dst_release(dst);
+			dst = dst2;
+			memcpy(&baddr, &laddr->a, sizeof(union sctp_addr));
+			matchlen = bmatchlen;
+		}
+	}
+	if (dst)
+		goto init_saddr;
+out_unlock:
+	sctp_read_unlock(addr_lock);
+out:
+	if (dst) {
+		rt = (struct rt6_info *) dst;
+		SCTP_DEBUG_PRINTK("SRC=" NIP6_FMT
+				  " rt6_dst=" NIP6_FMT
+				  " rt6_src=" NIP6_FMT "\n",
+				  NIP6(saddr->v6.sin6_addr),
+				  NIP6(rt->rt6i_dst.addr),
+				  NIP6(rt->rt6i_src.addr));
+	} else
+		SCTP_DEBUG_PRINTK("NO ROUTE\n");
+	return dst;
+init_saddr:
+	memcpy(saddr, &baddr, sizeof(union sctp_addr));
+	goto out_unlock;
+}
+
 /* Initialize addr struct to INADDR_ANY. */
 static void sctp_v6_inaddr_any(union sctp_addr *addr, unsigned short port)
 {
@@ -922,7 +939,6 @@ static struct sctp_af sctp_ipv6_specific
 	.setsockopt	   = ipv6_setsockopt,
 	.getsockopt	   = ipv6_getsockopt,
 	.get_dst	   = sctp_v6_get_dst,
-	.get_saddr	   = sctp_v6_get_saddr,
 	.copy_addrlist	   = sctp_v6_copy_addrlist,
 	.from_skb	   = sctp_v6_from_skb,
 	.from_sk	   = sctp_v6_from_sk,
@@ -930,7 +946,6 @@ static struct sctp_af sctp_ipv6_specific
 	.to_sk_daddr	   = sctp_v6_to_sk_daddr,
 	.from_addr_param   = sctp_v6_from_addr_param,
 	.to_addr_param	   = sctp_v6_to_addr_param,
-	.dst_saddr	   = sctp_v6_dst_saddr,
 	.cmp_addr	   = sctp_v6_cmp_addr,
 	.scope		   = sctp_v6_scope,
 	.addr_valid	   = sctp_v6_addr_valid,
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index fac7674..d412ec0 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -313,11 +313,10 @@ static int sctp_v4_to_addr_param(const u
 	return length;
 }

-/* Initialize a sctp_addr from a dst_entry. */
-static void sctp_v4_dst_saddr(union sctp_addr *saddr, struct dst_entry *dst,
+/* Initialize a sctp_addr from a rtable. */
+static void sctp_v4_rt_saddr(union sctp_addr *saddr, struct rtable *rt,
 			      unsigned short port)
 {
-	struct rtable *rt = (struct rtable *)dst;
 	saddr->v4.sin_family = AF_INET;
 	saddr->v4.sin_port = port;
 	saddr->v4.sin_addr.s_addr = rt->rt_src;
@@ -451,39 +450,40 @@ static struct dst_entry *sctp_v4_get_dst
 		fl.fl4_tos = RT_CONN_FLAGS(asoc->base.sk);
 		fl.oif = asoc->base.sk->sk_bound_dev_if;
 	}
-	if (saddr)
-		fl.fl4_src = saddr->v4.sin_addr.s_addr;
-
+	fl.fl4_src = saddr->v4.sin_addr.s_addr;
 	SCTP_DEBUG_PRINTK("%s: DST:%u.%u.%u.%u, SRC:%u.%u.%u.%u - ",
 			  __FUNCTION__, NIPQUAD(fl.fl4_dst),
 			  NIPQUAD(fl.fl4_src));

-	if (!ip_route_output_key(&rt, &fl)) {
+	if (!ip_route_output_key(&rt, &fl))
 		dst = &rt->u.dst;
-	}

 	/* If there is no association or if a source address is passed, no
 	 * more validation is required.
 	 */
-	if (!asoc || saddr)
+	if (saddr->v4.sin_addr.s_addr != INADDR_ANY)
 		goto out;
-
+	if (!asoc) {
+		if (dst)
+			saddr->v4.sin_addr.s_addr = rt->rt_src;
+		goto out;
+	}
 	bp = &asoc->base.bind_addr;
 	addr_lock = &asoc->base.addr_lock;

 	if (dst) {
 		/* Walk through the bind address list and look for a bind
-		 * address that matches the source address of the returned dst.
+		 * address that matches the source address of the returned rt.
 		 */
+		sctp_v4_rt_saddr(&dst_saddr, rt, bp->port);
 		sctp_read_lock(addr_lock);
 		list_for_each(pos, &bp->address_list) {
 			laddr = list_entry(pos, struct sctp_sockaddr_entry,
 					   list);
 			if (!laddr->use_as_src)
 				continue;
-			sctp_v4_dst_saddr(&dst_saddr, dst, bp->port);
 			if (sctp_v4_cmp_addr(&dst_saddr, &laddr->a))
-				goto out_unlock;
+				goto init_saddr;
 		}
 		sctp_read_unlock(addr_lock);

@@ -506,11 +506,10 @@ static struct dst_entry *sctp_v4_get_dst
 			fl.fl4_src = laddr->a.v4.sin_addr.s_addr;
 			if (!ip_route_output_key(&rt, &fl)) {
 				dst = &rt->u.dst;
-				goto out_unlock;
+				goto init_saddr;
 			}
 		}
 	}
-
 out_unlock:
 	sctp_read_unlock(addr_lock);
 out:
@@ -521,26 +520,11 @@ out:
 		SCTP_DEBUG_PRINTK("NO ROUTE\n");

 	return dst;
-}
-
-/* For v4, the source address is cached in the route entry(dst). So no need
- * to cache it separately and hence this is an empty routine.
- */
-static void sctp_v4_get_saddr(struct sctp_association *asoc,
-			      struct dst_entry *dst,
-			      union sctp_addr *daddr,
-			      union sctp_addr *saddr)
-{
-	struct rtable *rt = (struct rtable *)dst;
-
-	if (!asoc)
-		return;
-
-	if (rt) {
-		saddr->v4.sin_family = AF_INET;
-		saddr->v4.sin_port = asoc->base.bind_addr.port;
-		saddr->v4.sin_addr.s_addr = rt->rt_src;
-	}
+init_saddr:
+	saddr->v4.sin_family = AF_INET;
+	saddr->v4.sin_port = dst_saddr.v4.sin_port;
+	saddr->v4.sin_addr.s_addr = dst_saddr.v4.sin_addr.s_addr;
+	goto out_unlock;
 }

 /* What interface did this skb arrive on? */
@@ -891,7 +875,6 @@ static struct sctp_af sctp_ipv4_specific
 	.setsockopt	   = ip_setsockopt,
 	.getsockopt	   = ip_getsockopt,
 	.get_dst	   = sctp_v4_get_dst,
-	.get_saddr	   = sctp_v4_get_saddr,
 	.copy_addrlist	   = sctp_v4_copy_addrlist,
 	.from_skb	   = sctp_v4_from_skb,
 	.from_sk	   = sctp_v4_from_sk,
@@ -899,7 +882,6 @@ static struct sctp_af sctp_ipv4_specific
 	.to_sk_daddr	   = sctp_v4_to_sk_daddr,
 	.from_addr_param   = sctp_v4_from_addr_param,
 	.to_addr_param	   = sctp_v4_to_addr_param,
-	.dst_saddr	   = sctp_v4_dst_saddr,
 	.cmp_addr	   = sctp_v4_cmp_addr,
 	.addr_valid	   = sctp_v4_addr_valid,
 	.inaddr_any	   = sctp_v4_inaddr_any,
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 3e5936a..e365e9c 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -232,7 +232,8 @@ void sctp_transport_pmtu(struct sctp_tra
 {
 	struct dst_entry *dst;

-	dst = transport->af_specific->get_dst(NULL, &transport->ipaddr, NULL);
+	dst = transport->af_specific->get_dst(NULL, &transport->ipaddr,
+					      &transport->saddr);

 	if (dst) {
 		transport->pathmtu = dst_mtu(dst);
@@ -252,12 +253,11 @@ void sctp_transport_route(struct sctp_tr
 	union sctp_addr *daddr = &transport->ipaddr;
 	struct dst_entry *dst;

-	dst = af->get_dst(asoc, daddr, saddr);
-
 	if (saddr)
 		memcpy(&transport->saddr, saddr, sizeof(union sctp_addr));
 	else
-		af->get_saddr(asoc, dst, daddr, &transport->saddr);
+		af->inaddr_any(&transport->saddr, transport->saddr.v4.sin_port);
+	dst = af->get_dst(asoc, daddr, &transport->saddr);

 	transport->dst = dst;
 	if ((transport->param_flags & SPP_PMTUD_DISABLE) && transport->pathmtu) {
-- 
1.4.2.3

