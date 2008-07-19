From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 3/7] sctp: Support ipv6only AF_INET6 sockets.
Date: Sat, 19 Jul 2008 00:26:48 -0400
Message-ID: <1216441616651-git-send-email-vladislav.yasevich@hp.com>
References: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:45814 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbYGSE2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 00:28:24 -0400
In-Reply-To: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    2 ++
 net/sctp/bind_addr.c       |   37 +++++++++++++++++++++++++++++++++++++
 net/sctp/ipv6.c            |   20 ++++++++++++++++----
 net/sctp/protocol.c        |    7 +++++++
 net/sctp/sm_make_chunk.c   |    7 ++++++-
 net/sctp/socket.c          |   30 +++++++++++++++++++++++++-----
 6 files changed, 93 insertions(+), 10 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 82116e8..70eb64a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1211,6 +1211,8 @@ int sctp_add_bind_addr(struct sctp_bind_addr *, union sctp_addr *,
 int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *);
 int sctp_bind_addr_match(struct sctp_bind_addr *, const union sctp_addr *,
 			 struct sctp_sock *);
+int sctp_bind_addr_conflict(struct sctp_bind_addr *, const union sctp_addr *,
+			 struct sctp_sock *, struct sctp_sock *);
 int sctp_bind_addr_state(const struct sctp_bind_addr *bp,
 			 const union sctp_addr *addr);
 union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 80e6df0..f62bc24 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -348,6 +348,43 @@ int sctp_bind_addr_match(struct sctp_bind_addr *bp,
 	return match;
 }
 
+/* Does the address 'addr' conflict with any addresses in
+ * the bp.
+ */
+int sctp_bind_addr_conflict(struct sctp_bind_addr *bp,
+			    const union sctp_addr *addr,
+			    struct sctp_sock *bp_sp,
+			    struct sctp_sock *addr_sp)
+{
+	struct sctp_sockaddr_entry *laddr;
+	int conflict = 0;
+	struct sctp_sock *sp;
+
+	/* Pick the IPv6 socket as the basis of comparison
+	 * since it's usually a superset of the IPv4.
+	 * If there is no IPv6 socket, then default to bind_addr.
+	 */
+	if (sctp_opt2sk(bp_sp)->sk_family == AF_INET6)
+		sp = bp_sp;
+	else if (sctp_opt2sk(addr_sp)->sk_family == AF_INET6)
+		sp = addr_sp;
+	else
+		sp = bp_sp;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
+		if (!laddr->valid)
+			continue;
+
+		conflict = sp->pf->cmp_addr(&laddr->a, addr, sp);
+		if (conflict)
+			break;
+	}
+	rcu_read_unlock();
+
+	return conflict;
+}
+
 /* Get the state of the entry in the bind_addr_list */
 int sctp_bind_addr_state(const struct sctp_bind_addr *bp,
 			 const union sctp_addr *addr)
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index a2f4d4d..a238d68 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -818,7 +818,7 @@ static int sctp_inet6_af_supported(sa_family_t family, struct sctp_sock *sp)
 		return 1;
 	/* v4-mapped-v6 addresses */
 	case AF_INET:
-		if (!__ipv6_only_sock(sctp_opt2sk(sp)) && sp->v4mapped)
+		if (!__ipv6_only_sock(sctp_opt2sk(sp)))
 			return 1;
 	default:
 		return 0;
@@ -840,6 +840,11 @@ static int sctp_inet6_cmp_addr(const union sctp_addr *addr1,
 
 	if (!af1 || !af2)
 		return 0;
+
+	/* If the socket is IPv6 only, v4 addrs will not match */
+	if (__ipv6_only_sock(sctp_opt2sk(opt)) && af1 != af2)
+		return 0;
+
 	/* Today, wildcard AF_INET/AF_INET6. */
 	if (sctp_is_any(addr1) || sctp_is_any(addr2))
 		return 1;
@@ -876,7 +881,11 @@ static int sctp_inet6_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
 				return 0;
 			}
 			dev_put(dev);
+		} else if (type == IPV6_ADDR_MAPPED) {
+			if (!opt->v4mapped)
+				return 0;
 		}
+
 		af = opt->pf->af;
 	}
 	return af->available(addr, opt);
@@ -919,9 +928,12 @@ static int sctp_inet6_send_verify(struct sctp_sock *opt, union sctp_addr *addr)
 static int sctp_inet6_supported_addrs(const struct sctp_sock *opt,
 				      __be16 *types)
 {
-	types[0] = SCTP_PARAM_IPV4_ADDRESS;
-	types[1] = SCTP_PARAM_IPV6_ADDRESS;
-	return 2;
+	types[0] = SCTP_PARAM_IPV6_ADDRESS;
+	if (!opt || !ipv6_only_sock(sctp_opt2sk(opt))) {
+		types[1] = SCTP_PARAM_IPV4_ADDRESS;
+		return 2;
+	}
+	return 1;
 }
 
 static const struct proto_ops inet6_seqpacket_ops = {
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index dd811a8..cdd8811 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -381,6 +381,10 @@ static int sctp_v4_addr_valid(union sctp_addr *addr,
 			      struct sctp_sock *sp,
 			      const struct sk_buff *skb)
 {
+	/* IPv4 addresses not allowed */
+	if (sp && ipv6_only_sock(sctp_opt2sk(sp)))
+		return 0;
+
 	/* Is this a non-unicast address or a unusable SCTP address? */
 	if (IS_IPV4_UNUSABLE_ADDRESS(addr->v4.sin_addr.s_addr))
 		return 0;
@@ -404,6 +408,9 @@ static int sctp_v4_available(union sctp_addr *addr, struct sctp_sock *sp)
 	   !sysctl_ip_nonlocal_bind)
 		return 0;
 
+	if (ipv6_only_sock(sctp_opt2sk(sp)))
+		return 0;
+
 	return 1;
 }
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index bbc7107..e8ca4e5 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2364,8 +2364,13 @@ static int sctp_process_param(struct sctp_association *asoc,
 	case SCTP_PARAM_IPV6_ADDRESS:
 		if (PF_INET6 != asoc->base.sk->sk_family)
 			break;
-		/* Fall through. */
+		goto do_addr_param;
+
 	case SCTP_PARAM_IPV4_ADDRESS:
+		/* v4 addresses are not allowed on v6-only socket */
+		if (ipv6_only_sock(asoc->base.sk))
+			break;
+do_addr_param:
 		af = sctp_get_af_specific(param_type2af(param.p->type));
 		af->from_addr_param(&addr, param.addr, htons(asoc->peer.port), 0);
 		scope = sctp_scope(peer_addr);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 6aba01b..a0e879b 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -308,9 +308,16 @@ static struct sctp_af *sctp_sockaddr_af(struct sctp_sock *opt,
 	if (len < sizeof (struct sockaddr))
 		return NULL;
 
-	/* Does this PF support this AF? */
-	if (!opt->pf->af_supported(addr->sa.sa_family, opt))
-		return NULL;
+	/* V4 mapped address are really of AF_INET family */
+	if (addr->sa.sa_family == AF_INET6 &&
+	    ipv6_addr_v4mapped(&addr->v6.sin6_addr)) {
+		if (!opt->pf->af_supported(AF_INET, opt))
+			return NULL;
+	} else {
+		/* Does this PF support this AF? */
+		if (!opt->pf->af_supported(addr->sa.sa_family, opt))
+			return NULL;
+	}
 
 	/* If we get this far, af is valid. */
 	af = sctp_get_af_specific(addr->sa.sa_family);
@@ -4395,6 +4402,11 @@ static int sctp_getsockopt_local_addrs_num_old(struct sock *sk, int len,
 				    (AF_INET6 == addr->a.sa.sa_family))
 					continue;
 
+				if ((PF_INET6 == sk->sk_family) &&
+				    inet_v6_ipv6only(sk) &&
+				    (AF_INET == addr->a.sa.sa_family))
+					continue;
+
 				cnt++;
 			}
 			rcu_read_unlock();
@@ -4435,6 +4447,10 @@ static int sctp_copy_laddrs_old(struct sock *sk, __u16 port,
 		if ((PF_INET == sk->sk_family) &&
 		    (AF_INET6 == addr->a.sa.sa_family))
 			continue;
+		if ((PF_INET6 == sk->sk_family) &&
+		    inet_v6_ipv6only(sk) &&
+		    (AF_INET == addr->a.sa.sa_family))
+			continue;
 		memcpy(&temp, &addr->a, sizeof(temp));
 		if (!temp.v4.sin_port)
 			temp.v4.sin_port = htons(port);
@@ -4470,6 +4486,10 @@ static int sctp_copy_laddrs(struct sock *sk, __u16 port, void *to,
 		if ((PF_INET == sk->sk_family) &&
 		    (AF_INET6 == addr->a.sa.sa_family))
 			continue;
+		if ((PF_INET6 == sk->sk_family) &&
+		    inet_v6_ipv6only(sk) &&
+		    (AF_INET == addr->a.sa.sa_family))
+			continue;
 		memcpy(&temp, &addr->a, sizeof(temp));
 		if (!temp.v4.sin_port)
 			temp.v4.sin_port = htons(port);
@@ -5568,8 +5588,8 @@ pp_found:
 			    sk2->sk_state != SCTP_SS_LISTENING)
 				continue;
 
-			if (sctp_bind_addr_match(&ep2->base.bind_addr, addr,
-						 sctp_sk(sk))) {
+			if (sctp_bind_addr_conflict(&ep2->base.bind_addr, addr,
+						 sctp_sk(sk2), sctp_sk(sk))) {
 				ret = (long)sk2;
 				goto fail_unlock;
 			}
-- 
1.5.2.5

