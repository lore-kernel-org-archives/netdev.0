From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 2/7] sctp: cache the ipv6 source after route
 lookup
Date: Tue, 26 Apr 2011 11:46:19 +0800
Message-ID: <4DB6400B.7070307@cn.fujitsu.com>
References: <4DB63F85.2090609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51076 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758098Ab1DZDqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 23:46:34 -0400
In-Reply-To: <4DB63F85.2090609@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>

The ipv6 routing lookup does give us a source address,
but instead of filling it into the dst, it's stored in
the flowi.  We can use that instead of going through the
entire source address selection again.  Now we pass
the flowi around to get at the source for ipv6, but let
ipv4 still deal with dst.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 include/net/sctp/structs.h |   13 ++--
 net/sctp/ipv6.c            |  163 +++++++++++++++++++++-----------------------
 net/sctp/protocol.c        |   50 +++++++-------
 net/sctp/socket.c          |    2 +-
 net/sctp/transport.c       |   15 +++--
 5 files changed, 119 insertions(+), 124 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 5c9bada..a98d36f 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -566,16 +566,17 @@ struct sctp_af {
 					 int __user *optlen);
 	struct dst_entry *(*get_dst)	(struct sctp_association *asoc,
 					 union sctp_addr *daddr,
-					 union sctp_addr *saddr);
+					 union sctp_addr *saddr,
+					 struct flowi *fl,
+					 struct sock *sk);
 	void		(*get_saddr)	(struct sctp_sock *sk,
-					 struct sctp_association *asoc,
-					 struct dst_entry *dst,
+					 struct sctp_transport *t,
 					 union sctp_addr *daddr,
-					 union sctp_addr *saddr);
+					 struct flowi *fl);
 	void		(*copy_addrlist) (struct list_head *,
 					  struct net_device *);
 	void		(*dst_saddr)	(union sctp_addr *saddr,
-					 struct dst_entry *dst,
+					 void *from,
 					 __be16 port);
 	int		(*cmp_addr)	(const union sctp_addr *addr1,
 					 const union sctp_addr *addr2);
@@ -1061,7 +1062,7 @@ void sctp_transport_set_owner(struct sctp_transport *,
 			      struct sctp_association *);
 void sctp_transport_route(struct sctp_transport *, union sctp_addr *,
 			  struct sctp_sock *);
-void sctp_transport_pmtu(struct sctp_transport *);
+void sctp_transport_pmtu(struct sctp_transport *, struct sock *sk);
 void sctp_transport_free(struct sctp_transport *);
 void sctp_transport_reset_timers(struct sctp_transport *);
 void sctp_transport_hold(struct sctp_transport *);
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 5adf585..cc9ea37 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -82,6 +82,10 @@
 
 static inline int sctp_v6_addr_match_len(union sctp_addr *s1,
 					 union sctp_addr *s2);
+static void sctp_v6_dst_saddr(union sctp_addr *addr, void *from,
+			      __be16 port);
+static int sctp_v6_cmp_addr(const union sctp_addr *addr1,
+			    const union sctp_addr *addr2);
 
 /* Event handler for inet6 address addition/deletion events.
  * The sctp_local_addr_list needs to be protocted by a spin lock since
@@ -245,69 +249,97 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
  */
 static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 					 union sctp_addr *daddr,
-					 union sctp_addr *saddr)
+					 union sctp_addr *saddr,
+					 struct flowi *fl,
+					 struct sock *sk)
 {
 	struct dst_entry *dst = NULL;
-	struct flowi6 fl6;
+	struct flowi6 *fl6 = &fl->u.ip6;
 	struct sctp_bind_addr *bp;
 	struct sctp_sockaddr_entry *laddr;
 	union sctp_addr *baddr = NULL;
+	union sctp_addr dst_saddr;
 	__u8 matchlen = 0;
 	__u8 bmatchlen;
 	sctp_scope_t scope;
+	int err = 0;
 
-	memset(&fl6, 0, sizeof(fl6));
-	ipv6_addr_copy(&fl6.daddr, &daddr->v6.sin6_addr);
+	memset(fl6, 0, sizeof(struct flowi6));
+	ipv6_addr_copy(&fl6->daddr, &daddr->v6.sin6_addr);
 	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
-		fl6.flowi6_oif = daddr->v6.sin6_scope_id;
+		fl6->flowi6_oif = daddr->v6.sin6_scope_id;
 
 
-	SCTP_DEBUG_PRINTK("%s: DST=%pI6 ", __func__, &fl6.daddr);
+	SCTP_DEBUG_PRINTK("%s: DST=%pI6 ", __func__, &fl6->daddr);
 
 	if (saddr) {
-		ipv6_addr_copy(&fl6.saddr, &saddr->v6.sin6_addr);
-		SCTP_DEBUG_PRINTK("SRC=%pI6 - ", &fl6.saddr);
+		ipv6_addr_copy(&fl6->saddr, &saddr->v6.sin6_addr);
+		SCTP_DEBUG_PRINTK("SRC=%pI6 - ", &fl6->saddr);
 	}
 
-	dst = ip6_route_output(&init_net, NULL, &fl6);
+	err = ip6_dst_lookup(sk, &dst, fl6);
 	if (!asoc || saddr)
 		goto out;
 
-	if (dst->error) {
-		dst_release(dst);
-		dst = NULL;
-		bp = &asoc->base.bind_addr;
-		scope = sctp_scope(daddr);
-		/* Walk through the bind address list and try to get a dst that
-		 * matches a bind address as the source address.
+	bp = &asoc->base.bind_addr;
+	scope = sctp_scope(daddr);
+	/* ip6_dst_lookup has filled in the fl6->saddr for us.  Check
+	 * to see if we can use it.
+	 */
+	if (!err) {
+		/* Walk through the bind address list and look for a bind
+		 * address that matches the source address of the returned dst.
 		 */
+		sctp_v6_dst_saddr(&dst_saddr, fl6, htons(bp->port));
 		rcu_read_lock();
 		list_for_each_entry_rcu(laddr, &bp->address_list, list) {
-			if (!laddr->valid)
+			if (!laddr->valid || (laddr->state != SCTP_ADDR_SRC))
 				continue;
-			if ((laddr->state == SCTP_ADDR_SRC) &&
-			    (laddr->a.sa.sa_family == AF_INET6) &&
-			    (scope <= sctp_scope(&laddr->a))) {
-				bmatchlen = sctp_v6_addr_match_len(daddr,
-								   &laddr->a);
-				if (!baddr || (matchlen < bmatchlen)) {
-					baddr = &laddr->a;
-					matchlen = bmatchlen;
-				}
+
+			/* Do not compare against v4 addrs */
+			if ((laddr->a.sa.sa_family == AF_INET6) &&
+			    (sctp_v6_cmp_addr(&dst_saddr, &laddr->a))) {
+				rcu_read_unlock();
+				goto out;
 			}
 		}
 		rcu_read_unlock();
-		if (baddr) {
-			ipv6_addr_copy(&fl6.saddr, &baddr->v6.sin6_addr);
-			dst = ip6_route_output(&init_net, NULL, &fl6);
+		/* None of the bound addresses match the source address of the
+		 * dst. So release it.
+		 */
+		dst_release(dst);
+		dst = NULL;
+	}
+
+	/* Walk through the bind address list and try to get the
+	 * best source address for a given destination.
+	 */
+	rcu_read_lock();
+	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
+		if (!laddr->valid)
+			continue;
+		if ((laddr->state == SCTP_ADDR_SRC) &&
+		    (laddr->a.sa.sa_family == AF_INET6) &&
+		    (scope <= sctp_scope(&laddr->a))) {
+			bmatchlen = sctp_v6_addr_match_len(daddr, &laddr->a);
+			if (!baddr || (matchlen < bmatchlen)) {
+				baddr = &laddr->a;
+				matchlen = bmatchlen;
+			}
 		}
 	}
+	rcu_read_unlock();
+	if (baddr) {
+		ipv6_addr_copy(&fl6->saddr, &baddr->v6.sin6_addr);
+		err = ip6_dst_lookup(sk, &dst, fl6);
+	}
+
 out:
-	if (!dst->error) {
+	if (dst) {
 		struct rt6_info *rt;
 		rt = (struct rt6_info *)dst;
 		SCTP_DEBUG_PRINTK("rt6_dst:%pI6 rt6_src:%pI6\n",
-			&rt->rt6i_dst.addr, &rt->rt6i_src.addr);
+			&rt->rt6i_dst.addr, &fl6->saddr);
 		return dst;
 	}
 	SCTP_DEBUG_PRINTK("NO ROUTE\n");
@@ -329,64 +361,21 @@ static inline int sctp_v6_addr_match_len(union sctp_addr *s1,
  * and asoc's bind address list.
  */
 static void sctp_v6_get_saddr(struct sctp_sock *sk,
-			      struct sctp_association *asoc,
-			      struct dst_entry *dst,
+			      struct sctp_transport *t,
 			      union sctp_addr *daddr,
-			      union sctp_addr *saddr)
+			      struct flowi *fl)
 {
-	struct sctp_bind_addr *bp;
-	struct sctp_sockaddr_entry *laddr;
-	sctp_scope_t scope;
-	union sctp_addr *baddr = NULL;
-	__u8 matchlen = 0;
-	__u8 bmatchlen;
+	struct flowi6 *fl6 = &fl->u.ip6;
+	union sctp_addr *saddr = &t->saddr;
 
 	SCTP_DEBUG_PRINTK("%s: asoc:%p dst:%p daddr:%pI6 ",
-			  __func__, asoc, dst, &daddr->v6.sin6_addr);
-
-	if (!asoc) {
-		ipv6_dev_get_saddr(sock_net(sctp_opt2sk(sk)),
-				   dst ? ip6_dst_idev(dst)->dev : NULL,
-				   &daddr->v6.sin6_addr,
-				   inet6_sk(&sk->inet.sk)->srcprefs,
-				   &saddr->v6.sin6_addr);
-		SCTP_DEBUG_PRINTK("saddr from ipv6_get_saddr: %pI6\n",
-				  &saddr->v6.sin6_addr);
-		return;
-	}
+			  __func__, t->asoc, t->dst, &daddr->v6.sin6_addr);
 
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
 
-	if (baddr) {
-		memcpy(saddr, baddr, sizeof(union sctp_addr));
-		SCTP_DEBUG_PRINTK("saddr: %pI6\n", &saddr->v6.sin6_addr);
-	} else {
-		pr_err("%s: asoc:%p Could not find a valid source "
-		       "address for the dest:%pI6\n",
-		       __func__, asoc, &daddr->v6.sin6_addr);
+	if (t->dst) {
+		saddr->v6.sin6_family = AF_INET6;
+		ipv6_addr_copy(&saddr->v6.sin6_addr, &fl6->saddr);
 	}
-
-	rcu_read_unlock();
 }
 
 /* Make a copy of all potential local addresses. */
@@ -508,14 +497,16 @@ static int sctp_v6_to_addr_param(const union sctp_addr *addr,
 	return length;
 }
 
-/* Initialize a sctp_addr from a dst_entry. */
-static void sctp_v6_dst_saddr(union sctp_addr *addr, struct dst_entry *dst,
+/* Initialize a sctp_addr from a dst_entry. Problem is that v6 dst
+ * entries do not carry the source, so we pass a flowi instead.
+ */
+static void sctp_v6_dst_saddr(union sctp_addr *addr, void *from,
 			      __be16 port)
 {
-	struct rt6_info *rt = (struct rt6_info *)dst;
+	struct flowi6 *fl6 = (struct flowi6 *)from;
 	addr->sa.sa_family = AF_INET6;
 	addr->v6.sin6_port = port;
-	ipv6_addr_copy(&addr->v6.sin6_addr, &rt->rt6i_src.addr);
+	ipv6_addr_copy(&addr->v6.sin6_addr, &fl6->saddr);
 }
 
 /* Compare addresses exactly.
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index d5bf91d..7be5df6 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -339,10 +339,10 @@ static int sctp_v4_to_addr_param(const union sctp_addr *addr,
 }
 
 /* Initialize a sctp_addr from a dst_entry. */
-static void sctp_v4_dst_saddr(union sctp_addr *saddr, struct dst_entry *dst,
+static void sctp_v4_dst_saddr(union sctp_addr *saddr, void *from,
 			      __be16 port)
 {
-	struct rtable *rt = (struct rtable *)dst;
+	struct rtable *rt = (struct rtable *)from;
 	saddr->v4.sin_family = AF_INET;
 	saddr->v4.sin_port = port;
 	saddr->v4.sin_addr.s_addr = rt->rt_src;
@@ -465,33 +465,35 @@ static sctp_scope_t sctp_v4_scope(union sctp_addr *addr)
  */
 static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 					 union sctp_addr *daddr,
-					 union sctp_addr *saddr)
+					 union sctp_addr *saddr,
+					 struct flowi *fl,
+					 struct sock *sk)
 {
 	struct rtable *rt;
-	struct flowi4 fl4;
+	struct flowi4 *fl4 = &fl->u.ip4;
 	struct sctp_bind_addr *bp;
 	struct sctp_sockaddr_entry *laddr;
 	struct dst_entry *dst = NULL;
 	union sctp_addr dst_saddr;
 
-	memset(&fl4, 0x0, sizeof(struct flowi4));
-	fl4.daddr  = daddr->v4.sin_addr.s_addr;
-	fl4.fl4_dport = daddr->v4.sin_port;
-	fl4.flowi4_proto = IPPROTO_SCTP;
+	memset(fl4, 0x0, sizeof(struct flowi4));
+	fl4->daddr  = daddr->v4.sin_addr.s_addr;
+	fl4->fl4_dport = daddr->v4.sin_port;
+	fl4->flowi4_proto = IPPROTO_SCTP;
 	if (asoc) {
-		fl4.flowi4_tos = RT_CONN_FLAGS(asoc->base.sk);
-		fl4.flowi4_oif = asoc->base.sk->sk_bound_dev_if;
-		fl4.fl4_sport = htons(asoc->base.bind_addr.port);
+		fl4->flowi4_tos = RT_CONN_FLAGS(asoc->base.sk);
+		fl4->flowi4_oif = asoc->base.sk->sk_bound_dev_if;
+		fl4->fl4_sport = htons(asoc->base.bind_addr.port);
 	}
 	if (saddr) {
-		fl4.saddr = saddr->v4.sin_addr.s_addr;
-		fl4.fl4_sport = saddr->v4.sin_port;
+		fl4->saddr = saddr->v4.sin_addr.s_addr;
+		fl4->fl4_sport = saddr->v4.sin_port;
 	}
 
 	SCTP_DEBUG_PRINTK("%s: DST:%pI4, SRC:%pI4 - ",
-			  __func__, &fl4.daddr, &fl4.saddr);
+			  __func__, &fl4->daddr, &fl4->saddr);
 
-	rt = ip_route_output_key(&init_net, &fl4);
+	rt = ip_route_output_key(&init_net, fl4);
 	if (!IS_ERR(rt))
 		dst = &rt->dst;
 
@@ -533,9 +535,9 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 			continue;
 		if ((laddr->state == SCTP_ADDR_SRC) &&
 		    (AF_INET == laddr->a.sa.sa_family)) {
-			fl4.saddr = laddr->a.v4.sin_addr.s_addr;
-			fl4.fl4_sport = laddr->a.v4.sin_port;
-			rt = ip_route_output_key(&init_net, &fl4);
+			fl4->saddr = laddr->a.v4.sin_addr.s_addr;
+			fl4->fl4_sport = laddr->a.v4.sin_port;
+			rt = ip_route_output_key(&init_net, fl4);
 			if (!IS_ERR(rt)) {
 				dst = &rt->dst;
 				goto out_unlock;
@@ -559,19 +561,15 @@ out:
  * to cache it separately and hence this is an empty routine.
  */
 static void sctp_v4_get_saddr(struct sctp_sock *sk,
-			      struct sctp_association *asoc,
-			      struct dst_entry *dst,
+			      struct sctp_transport *t,
 			      union sctp_addr *daddr,
-			      union sctp_addr *saddr)
+			      struct flowi *fl)
 {
-	struct rtable *rt = (struct rtable *)dst;
-
-	if (!asoc)
-		return;
+	union sctp_addr *saddr = &t->saddr;
+	struct rtable *rt = (struct rtable *)t->dst;
 
 	if (rt) {
 		saddr->v4.sin_family = AF_INET;
-		saddr->v4.sin_port = htons(asoc->base.bind_addr.port);
 		saddr->v4.sin_addr.s_addr = rt->rt_src;
 	}
 }
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f694ee1..33d9ee6 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2287,7 +2287,7 @@ static int sctp_apply_peer_addr_params(struct sctp_paddrparams *params,
 			trans->param_flags =
 				(trans->param_flags & ~SPP_PMTUD) | pmtud_change;
 			if (update) {
-				sctp_transport_pmtu(trans);
+				sctp_transport_pmtu(trans, sctp_opt2sk(sp));
 				sctp_assoc_sync_pmtu(asoc);
 			}
 		} else if (asoc) {
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index d3ae493..2544b9b 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -211,11 +211,15 @@ void sctp_transport_set_owner(struct sctp_transport *transport,
 }
 
 /* Initialize the pmtu of a transport. */
-void sctp_transport_pmtu(struct sctp_transport *transport)
+void sctp_transport_pmtu(struct sctp_transport *transport, struct sock *sk)
 {
 	struct dst_entry *dst;
+	struct flowi fl;
 
-	dst = transport->af_specific->get_dst(NULL, &transport->ipaddr, NULL);
+	dst = transport->af_specific->get_dst(transport->asoc,
+					      &transport->ipaddr,
+					      &transport->saddr,
+					      &fl, sk);
 
 	if (dst) {
 		transport->pathmtu = dst_mtu(dst);
@@ -272,15 +276,16 @@ void sctp_transport_route(struct sctp_transport *transport,
 	struct sctp_af *af = transport->af_specific;
 	union sctp_addr *daddr = &transport->ipaddr;
 	struct dst_entry *dst;
+	struct flowi fl;
 
-	dst = af->get_dst(asoc, daddr, saddr);
+	dst = af->get_dst(asoc, daddr, saddr, &fl, sctp_opt2sk(opt));
+	transport->dst = dst;
 
 	if (saddr)
 		memcpy(&transport->saddr, saddr, sizeof(union sctp_addr));
 	else
-		af->get_saddr(opt, asoc, dst, daddr, &transport->saddr);
+		af->get_saddr(opt, transport, daddr, &fl);
 
-	transport->dst = dst;
 	if ((transport->param_flags & SPP_PMTUD_DISABLE) && transport->pathmtu) {
 		return;
 	}
-- 
1.6.5.2


