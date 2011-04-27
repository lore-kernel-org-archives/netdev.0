From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 5/5 v2] sctp: clean up route lookup calls
Date: Wed, 27 Apr 2011 15:54:17 +0800
Message-ID: <4DB7CBA9.8040104@cn.fujitsu.com>
References: <4DB7C73D.3000406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57944 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752252Ab1D0Hyf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 03:54:35 -0400
In-Reply-To: <4DB7C73D.3000406@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>

Change the call to take the transport parameter and set the
cached 'dst' appropriately inside the get_dst() function calls.

This will allow us in the future  to clean up source address
storage as well.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 include/net/sctp/structs.h |    3 +--
 net/sctp/ipv6.c            |   17 ++++++++---------
 net/sctp/protocol.c        |   12 +++++-------
 net/sctp/transport.c       |   23 ++++++++++-------------
 4 files changed, 24 insertions(+), 31 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index bb2f43b..ff3e8cc 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -564,8 +564,7 @@ struct sctp_af {
 					 int optname,
 					 char __user *optval,
 					 int __user *optlen);
-	struct dst_entry *(*get_dst)	(struct sctp_association *asoc,
-					 union sctp_addr *daddr,
+	void		(*get_dst)	(struct sctp_transport *t,
 					 union sctp_addr *saddr,
 					 struct flowi *fl,
 					 struct sock *sk);
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index a1913a4..500875f 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -247,17 +247,16 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 /* Returns the dst cache entry for the given source and destination ip
  * addresses.
  */
-static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
-					 union sctp_addr *daddr,
-					 union sctp_addr *saddr,
-					 struct flowi *fl,
-					 struct sock *sk)
+static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
+			    struct flowi *fl, struct sock *sk)
 {
+	struct sctp_association *asoc = t->asoc;
 	struct dst_entry *dst = NULL;
 	struct flowi6 *fl6 = &fl->u.ip6;
 	struct sctp_bind_addr *bp;
 	struct sctp_sockaddr_entry *laddr;
 	union sctp_addr *baddr = NULL;
+	union sctp_addr *daddr = &t->ipaddr;
 	union sctp_addr dst_saddr;
 	__u8 matchlen = 0;
 	__u8 bmatchlen;
@@ -270,7 +269,6 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
 		fl6->flowi6_oif = daddr->v6.sin6_scope_id;
 
-
 	SCTP_DEBUG_PRINTK("%s: DST=%pI6 ", __func__, &fl6->daddr);
 
 	if (asoc)
@@ -343,12 +341,13 @@ out:
 	if (!IS_ERR(dst)) {
 		struct rt6_info *rt;
 		rt = (struct rt6_info *)dst;
+		t->dst = dst;
 		SCTP_DEBUG_PRINTK("rt6_dst:%pI6 rt6_src:%pI6\n",
 			&rt->rt6i_dst.addr, &fl6->saddr);
-		return dst;
+	} else {
+		t->dst = NULL;
+		SCTP_DEBUG_PRINTK("NO ROUTE\n");
 	}
-	SCTP_DEBUG_PRINTK("NO ROUTE\n");
-	return NULL;
 }
 
 /* Returns the number of consecutive initial bits that match in the 2 ipv6
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 68b4c43..9d3f159 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -463,17 +463,16 @@ static sctp_scope_t sctp_v4_scope(union sctp_addr *addr)
  * addresses. If an association is passed, trys to get a dst entry with a
  * source address that matches an address in the bind address list.
  */
-static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
-					 union sctp_addr *daddr,
-					 union sctp_addr *saddr,
-					 struct flowi *fl,
-					 struct sock *sk)
+static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
+				struct flowi *fl, struct sock *sk)
 {
+	struct sctp_association *asoc = t->asoc;
 	struct rtable *rt;
 	struct flowi4 *fl4 = &fl->u.ip4;
 	struct sctp_bind_addr *bp;
 	struct sctp_sockaddr_entry *laddr;
 	struct dst_entry *dst = NULL;
+	union sctp_addr *daddr = &t->ipaddr;
 	union sctp_addr dst_saddr;
 
 	memset(fl4, 0x0, sizeof(struct flowi4));
@@ -548,13 +547,12 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 out_unlock:
 	rcu_read_unlock();
 out:
+	t->dst = dst;
 	if (dst)
 		SCTP_DEBUG_PRINTK("rt_dst:%pI4, rt_src:%pI4\n",
 				  &rt->rt_dst, &rt->rt_src);
 	else
 		SCTP_DEBUG_PRINTK("NO ROUTE\n");
-
-	return dst;
 }
 
 /* For v4, the source address is cached in the route entry(dst). So no need
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 1fbb920..d8595dd 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -213,17 +213,17 @@ void sctp_transport_set_owner(struct sctp_transport *transport,
 /* Initialize the pmtu of a transport. */
 void sctp_transport_pmtu(struct sctp_transport *transport, struct sock *sk)
 {
-	struct dst_entry *dst;
 	struct flowi fl;
 
-	dst = transport->af_specific->get_dst(transport->asoc,
-					      &transport->ipaddr,
-					      &transport->saddr,
+	/* If we don't have a fresh route, look one up */
+	if (!transport->dst || transport->dst->obsolete > 1) {
+		dst_release(transport->dst);
+		transport->af_specific->get_dst(transport, &transport->saddr,
 					      &fl, sk);
+	}
 
-	if (dst) {
-		transport->pathmtu = dst_mtu(dst);
-		dst_release(dst);
+	if (transport->dst) {
+		transport->pathmtu = dst_mtu(transport->dst);
 	} else
 		transport->pathmtu = SCTP_DEFAULT_MAXSEGMENT;
 }
@@ -274,12 +274,9 @@ void sctp_transport_route(struct sctp_transport *transport,
 {
 	struct sctp_association *asoc = transport->asoc;
 	struct sctp_af *af = transport->af_specific;
-	union sctp_addr *daddr = &transport->ipaddr;
-	struct dst_entry *dst;
 	struct flowi fl;
 
-	dst = af->get_dst(asoc, daddr, saddr, &fl, sctp_opt2sk(opt));
-	transport->dst = dst;
+	af->get_dst(transport, saddr, &fl, sctp_opt2sk(opt));
 
 	if (saddr)
 		memcpy(&transport->saddr, saddr, sizeof(union sctp_addr));
@@ -289,8 +286,8 @@ void sctp_transport_route(struct sctp_transport *transport,
 	if ((transport->param_flags & SPP_PMTUD_DISABLE) && transport->pathmtu) {
 		return;
 	}
-	if (dst) {
-		transport->pathmtu = dst_mtu(dst);
+	if (transport->dst) {
+		transport->pathmtu = dst_mtu(transport->dst);
 
 		/* Initialize sk->sk_rcv_saddr, if the transport is the
 		 * association's active path for getsockname().
-- 
1.6.5.2


