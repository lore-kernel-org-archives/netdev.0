From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 5/6][SCTP]: ADDIP: Don't use an address as source until it
	is ASCONF-ACKed
Date: Mon, 17 Jul 2006 17:25:35 -0700
Message-ID: <1153182335.4282.47.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:31970 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751265AbWGRA2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 20:28:10 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I0S7S1012053
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:28:09 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I0S79k276244
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:28:07 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I0S6ef026997
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:28:07 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: ADDIP: Don't use an address as source until it is ASCONF-ACKed

This implements Rules D1 and D4 of Sec 4.3 in the ADDIP draft.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/sctp/structs.h |    7 +---
 net/sctp/bind_addr.c       |    8 +++--
 net/sctp/ipv6.c            |    3 +-
 net/sctp/protocol.c        |    7 +++-
 net/sctp/sm_make_chunk.c   |   10 +++++-
 net/sctp/socket.c          |   72 +++++++++++++++++++++++++++++++++++---------
 6 files changed, 80 insertions(+), 27 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 268f2e1..e5aa7ff 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -731,13 +731,10 @@ void sctp_init_addrs(struct sctp_chunk *
 const union sctp_addr *sctp_source(const struct sctp_chunk *chunk);
 
 /* This is a structure for holding either an IPv6 or an IPv4 address.  */
-/* sin_family -- AF_INET or AF_INET6
- * sin_port -- ordinary port number
- * sin_addr -- cast to either (struct in_addr) or (struct in6_addr)
- */
 struct sctp_sockaddr_entry {
 	struct list_head list;
 	union sctp_addr a;
+	__u8 use_as_src;
 };
 
 typedef struct sctp_chunk *(sctp_packet_phandler_t)(struct sctp_association *);
@@ -1142,7 +1139,7 @@ int sctp_bind_addr_copy(struct sctp_bind
 			sctp_scope_t scope, gfp_t gfp,
 			int flags);
 int sctp_add_bind_addr(struct sctp_bind_addr *, union sctp_addr *,
-		       gfp_t gfp);
+		       __u8 use_as_src, gfp_t gfp);
 int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *);
 int sctp_bind_addr_match(struct sctp_bind_addr *, const union sctp_addr *,
 			 struct sctp_sock *);
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 2b96262..2b9c12a 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -146,7 +146,7 @@ void sctp_bind_addr_free(struct sctp_bin
 
 /* Add an address to the bind address list in the SCTP_bind_addr structure. */
 int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
-		       gfp_t gfp)
+		       __u8 use_as_src, gfp_t gfp)
 {
 	struct sctp_sockaddr_entry *addr;
 
@@ -163,6 +163,8 @@ int sctp_add_bind_addr(struct sctp_bind_
 	if (!addr->a.v4.sin_port)
 		addr->a.v4.sin_port = bp->port;
 
+	addr->use_as_src = use_as_src;
+
 	INIT_LIST_HEAD(&addr->list);
 	list_add_tail(&addr->list, &bp->address_list);
 	SCTP_DBG_OBJCNT_INC(addr);
@@ -274,7 +276,7 @@ int sctp_raw_to_bind_addrs(struct sctp_b
 		}
 
 		af->from_addr_param(&addr, rawaddr, port, 0);
-		retval = sctp_add_bind_addr(bp, &addr, gfp);
+		retval = sctp_add_bind_addr(bp, &addr, 1, gfp);
 		if (retval) {
 			/* Can't finish building the list, clean up. */
 			sctp_bind_addr_clean(bp);
@@ -367,7 +369,7 @@ static int sctp_copy_one_addr(struct sct
 		    (((AF_INET6 == addr->sa.sa_family) &&
 		      (flags & SCTP_ADDR6_ALLOWED) &&
 		      (flags & SCTP_ADDR6_PEERSUPP))))
-			error = sctp_add_bind_addr(dest, addr, gfp);
+			error = sctp_add_bind_addr(dest, addr, 1, gfp);
 	}
 
 	return error;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 8ef0807..99c0cef 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -290,7 +290,8 @@ static void sctp_v6_get_saddr(struct sct
 	sctp_read_lock(addr_lock);
 	list_for_each(pos, &bp->address_list) {
 		laddr = list_entry(pos, struct sctp_sockaddr_entry, list);
-		if ((laddr->a.sa.sa_family == AF_INET6) &&
+		if ((laddr->use_as_src) &&
+		    (laddr->a.sa.sa_family == AF_INET6) &&
 		    (scope <= sctp_scope(&laddr->a))) {
 			bmatchlen = sctp_v6_addr_match_len(daddr, &laddr->a);
 			if (!baddr || (matchlen < bmatchlen)) {
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 816c033..1ab03a2 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -240,7 +240,7 @@ int sctp_copy_local_addr_list(struct sct
 			    (((AF_INET6 == addr->a.sa.sa_family) &&
 			      (copy_flags & SCTP_ADDR6_ALLOWED) &&
 			      (copy_flags & SCTP_ADDR6_PEERSUPP)))) {
-				error = sctp_add_bind_addr(bp, &addr->a, 
+				error = sctp_add_bind_addr(bp, &addr->a, 1,
 							   GFP_ATOMIC);
 				if (error)
 					goto end_copy;
@@ -486,6 +486,8 @@ static struct dst_entry *sctp_v4_get_dst
 		list_for_each(pos, &bp->address_list) {
 			laddr = list_entry(pos, struct sctp_sockaddr_entry,
 					   list);
+			if (!laddr->use_as_src)
+				continue;
 			sctp_v4_dst_saddr(&dst_saddr, dst, bp->port);
 			if (sctp_v4_cmp_addr(&dst_saddr, &laddr->a))
 				goto out_unlock;
@@ -506,7 +508,8 @@ static struct dst_entry *sctp_v4_get_dst
 	list_for_each(pos, &bp->address_list) {
 		laddr = list_entry(pos, struct sctp_sockaddr_entry, list);
 
-		if (AF_INET == laddr->a.sa.sa_family) {
+		if ((laddr->use_as_src) &&
+		    (AF_INET == laddr->a.sa.sa_family)) {
 			fl.fl4_src = laddr->a.v4.sin_addr.s_addr;
 			if (!ip_route_output_key(&rt, &fl)) {
 				dst = &rt->u.dst;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 8134e8b..4f11f58 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1493,7 +1493,7 @@ no_hmac:
 
 	/* Also, add the destination address. */
 	if (list_empty(&retval->base.bind_addr.address_list)) {
-		sctp_add_bind_addr(&retval->base.bind_addr, &chunk->dest,
+		sctp_add_bind_addr(&retval->base.bind_addr, &chunk->dest, 1,
 				   GFP_ATOMIC);
 	}
 
@@ -2565,6 +2565,7 @@ static int sctp_asconf_param_success(str
 	union sctp_addr_param *addr_param;
 	struct list_head *pos;
 	struct sctp_transport *transport;
+	struct sctp_sockaddr_entry *saddr;
 	int retval = 0;
 
 	addr_param = (union sctp_addr_param *)
@@ -2578,7 +2579,11 @@ static int sctp_asconf_param_success(str
 	case SCTP_PARAM_ADD_IP:
 		sctp_local_bh_disable();
 		sctp_write_lock(&asoc->base.addr_lock);
-		retval = sctp_add_bind_addr(bp, &addr, GFP_ATOMIC);
+		list_for_each(pos, &bp->address_list) {
+			saddr = list_entry(pos, struct sctp_sockaddr_entry, list);
+			if (sctp_cmp_addr_exact(&saddr->a, &addr))
+				saddr->use_as_src = 1;
+		}
 		sctp_write_unlock(&asoc->base.addr_lock);
 		sctp_local_bh_enable();
 		break;
@@ -2591,6 +2596,7 @@ static int sctp_asconf_param_success(str
 		list_for_each(pos, &asoc->peer.transport_addr_list) {
 			transport = list_entry(pos, struct sctp_transport,
 						 transports);
+			dst_release(transport->dst);
 			sctp_transport_route(transport, NULL,
 					     sctp_sk(asoc->base.sk));
 		}
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 518c55a..94d2b52 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -369,7 +369,7 @@ SCTP_STATIC int sctp_do_bind(struct sock
 
 	/* Use GFP_ATOMIC since BHs are disabled.  */
 	addr->v4.sin_port = ntohs(addr->v4.sin_port);
-	ret = sctp_add_bind_addr(bp, addr, GFP_ATOMIC);
+	ret = sctp_add_bind_addr(bp, addr, 1, GFP_ATOMIC);
 	addr->v4.sin_port = htons(addr->v4.sin_port);
 	sctp_write_unlock(&ep->base.addr_lock);
 	sctp_local_bh_enable();
@@ -491,6 +491,7 @@ static int sctp_send_asconf_add_ip(struc
 	struct sctp_chunk		*chunk;
 	struct sctp_sockaddr_entry	*laddr;
 	union sctp_addr			*addr;
+	union sctp_addr			saveaddr;
 	void				*addr_buf;
 	struct sctp_af			*af;
 	struct list_head		*pos;
@@ -558,14 +559,26 @@ static int sctp_send_asconf_add_ip(struc
 		}
 
 		retval = sctp_send_asconf(asoc, chunk);
+		if (retval)
+			goto out;
 
-		/* FIXME: After sending the add address ASCONF chunk, we
-		 * cannot append the address to the association's binding
-		 * address list, because the new address may be used as the
-		 * source of a message sent to the peer before the ASCONF
-		 * chunk is received by the peer.  So we should wait until
-		 * ASCONF_ACK is received.
+		/* Add the new addresses to the bind address list with
+		 * use_as_src set to 0.
 		 */
+		sctp_local_bh_disable();
+		sctp_write_lock(&asoc->base.addr_lock);
+		addr_buf = addrs;
+		for (i = 0; i < addrcnt; i++) {
+			addr = (union sctp_addr *)addr_buf;
+			af = sctp_get_af_specific(addr->v4.sin_family);
+			memcpy(&saveaddr, addr, af->sockaddr_len);
+			saveaddr.v4.sin_port = ntohs(saveaddr.v4.sin_port);
+			retval = sctp_add_bind_addr(bp, &saveaddr, 0,
+						    GFP_ATOMIC);
+			addr_buf += af->sockaddr_len;
+		}
+		sctp_write_unlock(&asoc->base.addr_lock);
+		sctp_local_bh_enable();
 	}
 
 out:
@@ -676,12 +689,15 @@ static int sctp_send_asconf_del_ip(struc
 	struct sctp_sock	*sp;
 	struct sctp_endpoint	*ep;
 	struct sctp_association	*asoc;
+	struct sctp_transport	*transport;
 	struct sctp_bind_addr	*bp;
 	struct sctp_chunk	*chunk;
 	union sctp_addr		*laddr;
+	union sctp_addr		saveaddr;
 	void			*addr_buf;
 	struct sctp_af		*af;
-	struct list_head	*pos;
+	struct list_head	*pos, *pos1;
+	struct sctp_sockaddr_entry *saddr;
 	int 			i;
 	int 			retval = 0;
 
@@ -748,14 +764,42 @@ static int sctp_send_asconf_del_ip(struc
 			goto out;
 		}
 
-		retval = sctp_send_asconf(asoc, chunk);
+		/* Reset use_as_src flag for the addresses in the bind address
+		 * list that are to be deleted.
+		 */
+		sctp_local_bh_disable();
+		sctp_write_lock(&asoc->base.addr_lock);
+		addr_buf = addrs;
+		for (i = 0; i < addrcnt; i++) {
+			laddr = (union sctp_addr *)addr_buf;
+			af = sctp_get_af_specific(laddr->v4.sin_family);
+			memcpy(&saveaddr, laddr, af->sockaddr_len);
+			saveaddr.v4.sin_port = ntohs(saveaddr.v4.sin_port);
+			list_for_each(pos1, &bp->address_list) {
+				saddr = list_entry(pos1,
+						   struct sctp_sockaddr_entry,
+						   list);
+				if (sctp_cmp_addr_exact(&saddr->a, &saveaddr))
+					saddr->use_as_src = 0;
+			}
+			addr_buf += af->sockaddr_len;
+		}
+		sctp_write_unlock(&asoc->base.addr_lock);
+		sctp_local_bh_enable();
 
-		/* FIXME: After sending the delete address ASCONF chunk, we
-		 * cannot remove the addresses from the association's bind
-		 * address list, because there maybe some packet send to
-		 * the delete addresses, so we should wait until ASCONF_ACK
-		 * packet is received.
+		/* Update the route and saddr entries for all the transports
+		 * as some of the addresses in the bind address list are
+		 * about to be deleted and cannot be used as source addresses.
 		 */
+		list_for_each(pos1, &asoc->peer.transport_addr_list) {
+			transport = list_entry(pos1, struct sctp_transport,
+					       transports);
+			dst_release(transport->dst);
+			sctp_transport_route(transport, NULL,
+					     sctp_sk(asoc->base.sk));
+		}
+
+		retval = sctp_send_asconf(asoc, chunk);
 	}
 out:
 	return retval;


