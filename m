From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: [PATCH v2] sctp: Fixup v4mapped behaviour to comply with Sock API
Date: Wed, 30 Jul 2014 12:40:53 -0600
Message-ID: <20140730184053.GA28087@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:54097 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752501AbaG3SlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 14:41:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SCTP socket extensions API document describes the v4mapping option as
follows:

8.1.15.  Set/Clear IPv4 Mapped Addresses (SCTP_I_WANT_MAPPED_V4_ADDR)

   This socket option is a Boolean flag which turns on or off the
   mapping of IPv4 addresses.  If this option is turned on, then IPv4
   addresses will be mapped to V6 representation.  If this option is
   turned off, then no mapping will be done of V4 addresses and a user
   will receive both PF_INET6 and PF_INET type addresses on the socket.
   See [RFC3542] for more details on mapped V6 addresses.

This description isn't really in line with what the code does though.

Introduce addr_to_user (renamed addr_v4map), which should be called
before any sockaddr is passed back to user space. The new function
places the sockaddr into the correct format depending on the
SCTP_I_WANT_MAPPED_V4_ADDR option.

Audit all places that touched v4mapped and either sanely construct
a v4 or v6 address then call addr_to_user, or drop the
unnecessary v4mapped check entirely.

Audit all places that call addr_to_user and verify they are on a sycall
return path.

Add a custom getname that formats the address properly.

Several bugs are addressed:
 - SCTP_I_WANT_MAPPED_V4_ADDR=0 often returned garbage for
   addresses to user space
 - The addr_len returned from recvmsg was not correct when
   returning AF_INET on a v6 socket
 - flowlabel and scope_id were not zerod when promoting
   a v4 to v6
 - Some syscalls like bind and connect behaved differently
   depending on v4mapped

Tested bind, getpeername, getsockname, connect, and recvmsg for proper
behaviour in v4mapped = 1 and 0 cases.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Tested-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
---
 include/net/sctp/sctp.h    |   2 +
 include/net/sctp/structs.h |   8 +--
 net/sctp/ipv6.c            | 156 ++++++++++++++++++++++++---------------------
 net/sctp/protocol.c        |  12 ++--
 net/sctp/socket.c          |  33 +++++-----
 net/sctp/transport.c       |   4 +-
 net/sctp/ulpevent.c        |   2 +-
 7 files changed, 112 insertions(+), 105 deletions(-)

Changes since v1:
 - 0 initialize flowinfo/scope_id
 - Rename addr_v4map to addr_to_user for clarity on the
   correct usage
 - Have addr_to_user return the socket length, two places
   were getting this wrong
 - Change sctp_inet6_event_msgname and sctp_inet6_skb_msgname to
   directly construct a sockaddr in the natural format and then
   call addr_to_user rather than trying to open code the same thing.
 - sctp_getname can just call addr_to_user instead of open coding the
   same

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 8e4de46c052e..1b4e22384f1a 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -574,6 +574,8 @@ static inline void sctp_v6_map_v4(union sctp_addr *addr)
 static inline void sctp_v4_map_v6(union sctp_addr *addr)
 {
 	addr->v6.sin6_family = AF_INET6;
+	addr->v6.sin6_flowinfo = 0;
+	addr->v6.sin6_scope_id = 0;
 	addr->v6.sin6_port = addr->v4.sin_port;
 	addr->v6.sin6_addr.s6_addr32[3] = addr->v4.sin_addr.s_addr;
 	addr->v6.sin6_addr.s6_addr32[0] = 0;
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index f38588bf3462..5ec8250dc2ba 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -461,10 +461,6 @@ struct sctp_af {
 					 int saddr);
 	void		(*from_sk)	(union sctp_addr *,
 					 struct sock *sk);
-	void		(*to_sk_saddr)	(union sctp_addr *,
-					 struct sock *sk);
-	void		(*to_sk_daddr)	(union sctp_addr *,
-					 struct sock *sk);
 	void		(*from_addr_param) (union sctp_addr *,
 					    union sctp_addr_param *,
 					    __be16 port, int iif);
@@ -505,7 +501,9 @@ struct sctp_pf {
 	int  (*supported_addrs)(const struct sctp_sock *, __be16 *);
 	struct sock *(*create_accept_sk) (struct sock *sk,
 					  struct sctp_association *asoc);
-	void (*addr_v4map) (struct sctp_sock *, union sctp_addr *);
+	int (*addr_to_user)(struct sctp_sock *sk, union sctp_addr *addr);
+	void (*to_sk_saddr)(union sctp_addr *, struct sock *sk);
+	void (*to_sk_daddr)(union sctp_addr *, struct sock *sk);
 	struct sctp_af *af;
 };
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 1999592ba88c..0e4198ee2370 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -434,7 +434,7 @@ static void sctp_v6_from_sk(union sctp_addr *addr, struct sock *sk)
 /* Initialize sk->sk_rcv_saddr from sctp_addr. */
 static void sctp_v6_to_sk_saddr(union sctp_addr *addr, struct sock *sk)
 {
-	if (addr->sa.sa_family == AF_INET && sctp_sk(sk)->v4mapped) {
+	if (addr->sa.sa_family == AF_INET) {
 		sk->sk_v6_rcv_saddr.s6_addr32[0] = 0;
 		sk->sk_v6_rcv_saddr.s6_addr32[1] = 0;
 		sk->sk_v6_rcv_saddr.s6_addr32[2] = htonl(0x0000ffff);
@@ -448,7 +448,7 @@ static void sctp_v6_to_sk_saddr(union sctp_addr *addr, struct sock *sk)
 /* Initialize sk->sk_daddr from sctp_addr. */
 static void sctp_v6_to_sk_daddr(union sctp_addr *addr, struct sock *sk)
 {
-	if (addr->sa.sa_family == AF_INET && sctp_sk(sk)->v4mapped) {
+	if (addr->sa.sa_family == AF_INET) {
 		sk->sk_v6_daddr.s6_addr32[0] = 0;
 		sk->sk_v6_daddr.s6_addr32[1] = 0;
 		sk->sk_v6_daddr.s6_addr32[2] = htonl(0x0000ffff);
@@ -556,8 +556,6 @@ static int sctp_v6_available(union sctp_addr *addr, struct sctp_sock *sp)
 	if (IPV6_ADDR_ANY == type)
 		return 1;
 	if (type == IPV6_ADDR_MAPPED) {
-		if (sp && !sp->v4mapped)
-			return 0;
 		if (sp && ipv6_only_sock(sctp_opt2sk(sp)))
 			return 0;
 		sctp_v6_map_v4(addr);
@@ -587,8 +585,6 @@ static int sctp_v6_addr_valid(union sctp_addr *addr,
 		/* Note: This routine is used in input, so v4-mapped-v6
 		 * are disallowed here when there is no sctp_sock.
 		 */
-		if (!sp || !sp->v4mapped)
-			return 0;
 		if (sp && ipv6_only_sock(sctp_opt2sk(sp)))
 			return 0;
 		sctp_v6_map_v4(addr);
@@ -675,11 +671,23 @@ out:
 	return newsk;
 }
 
-/* Map v4 address to mapped v6 address */
-static void sctp_v6_addr_v4map(struct sctp_sock *sp, union sctp_addr *addr)
+/* Format a sockaddr for return to user space. This makes sure the return is
+ * AF_INET or AF_INET6 depending on the SCTP_I_WANT_MAPPED_V4_ADDR option.
+ */
+static int sctp_v6_addr_to_user(struct sctp_sock *sp, union sctp_addr *addr)
 {
-	if (sp->v4mapped && AF_INET == addr->sa.sa_family)
-		sctp_v4_map_v6(addr);
+	if (sp->v4mapped) {
+		if (addr->sa.sa_family == AF_INET)
+			sctp_v4_map_v6(addr);
+	} else {
+		if (addr->sa.sa_family == AF_INET6 &&
+		    ipv6_addr_v4mapped(&addr->v6.sin6_addr))
+			sctp_v6_map_v4(addr);
+	}
+
+	if (addr->sa.sa_family == AF_INET)
+		return sizeof(struct sockaddr_in);
+	return sizeof(struct sockaddr_in6);
 }
 
 /* Where did this skb come from?  */
@@ -706,82 +714,68 @@ static void sctp_v6_ecn_capable(struct sock *sk)
 	inet6_sk(sk)->tclass |= INET_ECN_ECT_0;
 }
 
-/* Initialize a PF_INET6 socket msg_name. */
-static void sctp_inet6_msgname(char *msgname, int *addr_len)
-{
-	struct sockaddr_in6 *sin6;
-
-	sin6 = (struct sockaddr_in6 *)msgname;
-	sin6->sin6_family = AF_INET6;
-	sin6->sin6_flowinfo = 0;
-	sin6->sin6_scope_id = 0; /*FIXME */
-	*addr_len = sizeof(struct sockaddr_in6);
-}
-
 /* Initialize a PF_INET msgname from a ulpevent. */
 static void sctp_inet6_event_msgname(struct sctp_ulpevent *event,
 				     char *msgname, int *addrlen)
 {
-	struct sockaddr_in6 *sin6, *sin6from;
-
-	if (msgname) {
-		union sctp_addr *addr;
-		struct sctp_association *asoc;
-
-		asoc = event->asoc;
-		sctp_inet6_msgname(msgname, addrlen);
-		sin6 = (struct sockaddr_in6 *)msgname;
-		sin6->sin6_port = htons(asoc->peer.port);
-		addr = &asoc->peer.primary_addr;
+	union sctp_addr *addr;
+	struct sctp_association *asoc;
+	union sctp_addr *paddr;
 
-		/* Note: If we go to a common v6 format, this code
-		 * will change.
-		 */
+	if (!msgname)
+		return;
 
-		/* Map ipv4 address into v4-mapped-on-v6 address.  */
-		if (sctp_sk(asoc->base.sk)->v4mapped &&
-		    AF_INET == addr->sa.sa_family) {
-			sctp_v4_map_v6((union sctp_addr *)sin6);
-			sin6->sin6_addr.s6_addr32[3] =
-				addr->v4.sin_addr.s_addr;
-			return;
-		}
+	addr = (union sctp_addr *)msgname;
+	asoc = event->asoc;
+	paddr = &asoc->peer.primary_addr;
 
-		sin6from = &asoc->peer.primary_addr.v6;
-		sin6->sin6_addr = sin6from->sin6_addr;
-		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-			sin6->sin6_scope_id = sin6from->sin6_scope_id;
+	if (paddr->sa.sa_family == AF_INET) {
+		addr->v4.sin_family = AF_INET;
+		addr->v4.sin_port = htons(asoc->peer.port);
+		addr->v4.sin_addr = paddr->v4.sin_addr;
+	} else {
+		addr->v6.sin6_family = AF_INET6;
+		addr->v6.sin6_flowinfo = 0;
+		if (ipv6_addr_type(&paddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
+			addr->v6.sin6_scope_id = paddr->v6.sin6_scope_id;
+		else
+			addr->v6.sin6_scope_id = 0;
+		addr->v6.sin6_port = htons(asoc->peer.port);
+		addr->v6.sin6_addr = paddr->v6.sin6_addr;
 	}
+
+	*addrlen = sctp_v6_addr_to_user(sctp_sk(asoc->base.sk), addr);
 }
 
 /* Initialize a msg_name from an inbound skb. */
 static void sctp_inet6_skb_msgname(struct sk_buff *skb, char *msgname,
 				   int *addr_len)
 {
+	union sctp_addr *addr;
 	struct sctphdr *sh;
-	struct sockaddr_in6 *sin6;
-
-	if (msgname) {
-		sctp_inet6_msgname(msgname, addr_len);
-		sin6 = (struct sockaddr_in6 *)msgname;
-		sh = sctp_hdr(skb);
-		sin6->sin6_port = sh->source;
-
-		/* Map ipv4 address into v4-mapped-on-v6 address. */
-		if (sctp_sk(skb->sk)->v4mapped &&
-		    ip_hdr(skb)->version == 4) {
-			sctp_v4_map_v6((union sctp_addr *)sin6);
-			sin6->sin6_addr.s6_addr32[3] = ip_hdr(skb)->saddr;
-			return;
-		}
 
-		/* Otherwise, just copy the v6 address. */
-		sin6->sin6_addr = ipv6_hdr(skb)->saddr;
-		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL) {
+	if (!msgname)
+		return;
+
+	addr = (union sctp_addr *)msgname;
+	sh = sctp_hdr(skb);
+
+	if (ip_hdr(skb)->version == 4) {
+		addr->v4.sin_family = AF_INET;
+		addr->v4.sin_port = sh->source;
+		addr->v4.sin_addr.s_addr =  ip_hdr(skb)->saddr;
+	} else {
+		addr->v6.sin6_family = AF_INET6;
+		addr->v6.sin6_flowinfo = 0;
+		addr->v6.sin6_port = sh->source;
+		addr->v6.sin6_addr = ipv6_hdr(skb)->saddr;
+		if (ipv6_addr_type(&addr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL) {
 			struct sctp_ulpevent *ev = sctp_skb2event(skb);
-			sin6->sin6_scope_id = ev->iif;
+			addr->v6.sin6_scope_id = ev->iif;
 		}
 	}
+
+	*addr_len = sctp_v6_addr_to_user(sctp_sk(skb->sk), addr);
 }
 
 /* Do we support this AF? */
@@ -857,9 +851,6 @@ static int sctp_inet6_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
 				return 0;
 			}
 			rcu_read_unlock();
-		} else if (type == IPV6_ADDR_MAPPED) {
-			if (!opt->v4mapped)
-				return 0;
 		}
 
 		af = opt->pf->af;
@@ -914,6 +905,23 @@ static int sctp_inet6_supported_addrs(const struct sctp_sock *opt,
 	return 1;
 }
 
+/* Handle SCTP_I_WANT_MAPPED_V4_ADDR for getpeername() and getsockname() */
+static int sctp_getname(struct socket *sock, struct sockaddr *uaddr,
+			int *uaddr_len, int peer)
+{
+	int rc;
+
+	rc = inet6_getname(sock, uaddr, uaddr_len, peer);
+
+	if (rc != 0)
+		return rc;
+
+	*uaddr_len = sctp_v6_addr_to_user(sctp_sk(sock->sk),
+					  (union sctp_addr *)uaddr);
+
+	return rc;
+}
+
 static const struct proto_ops inet6_seqpacket_ops = {
 	.family		   = PF_INET6,
 	.owner		   = THIS_MODULE,
@@ -922,7 +930,7 @@ static const struct proto_ops inet6_seqpacket_ops = {
 	.connect	   = inet_dgram_connect,
 	.socketpair	   = sock_no_socketpair,
 	.accept		   = inet_accept,
-	.getname	   = inet6_getname,
+	.getname	   = sctp_getname,
 	.poll		   = sctp_poll,
 	.ioctl		   = inet6_ioctl,
 	.listen		   = sctp_inet_listen,
@@ -974,8 +982,6 @@ static struct sctp_af sctp_af_inet6 = {
 	.copy_addrlist	   = sctp_v6_copy_addrlist,
 	.from_skb	   = sctp_v6_from_skb,
 	.from_sk	   = sctp_v6_from_sk,
-	.to_sk_saddr	   = sctp_v6_to_sk_saddr,
-	.to_sk_daddr	   = sctp_v6_to_sk_daddr,
 	.from_addr_param   = sctp_v6_from_addr_param,
 	.to_addr_param	   = sctp_v6_to_addr_param,
 	.cmp_addr	   = sctp_v6_cmp_addr,
@@ -1005,7 +1011,9 @@ static struct sctp_pf sctp_pf_inet6 = {
 	.send_verify   = sctp_inet6_send_verify,
 	.supported_addrs = sctp_inet6_supported_addrs,
 	.create_accept_sk = sctp_v6_create_accept_sk,
-	.addr_v4map    = sctp_v6_addr_v4map,
+	.addr_to_user  = sctp_v6_addr_to_user,
+	.to_sk_saddr   = sctp_v6_to_sk_saddr,
+	.to_sk_daddr   = sctp_v6_to_sk_daddr,
 	.af            = &sctp_af_inet6,
 };
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 6789d785e698..6240834f4b95 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -576,10 +576,10 @@ out:
 	return newsk;
 }
 
-/* Map address, empty for v4 family */
-static void sctp_v4_addr_v4map(struct sctp_sock *sp, union sctp_addr *addr)
+static int sctp_v4_addr_to_user(struct sctp_sock *sp, union sctp_addr *addr)
 {
-	/* Empty */
+	/* No address mapping for V4 sockets */
+	return sizeof(struct sockaddr_in);
 }
 
 /* Dump the v4 addr to the seq file. */
@@ -976,7 +976,9 @@ static struct sctp_pf sctp_pf_inet = {
 	.send_verify   = sctp_inet_send_verify,
 	.supported_addrs = sctp_inet_supported_addrs,
 	.create_accept_sk = sctp_v4_create_accept_sk,
-	.addr_v4map	= sctp_v4_addr_v4map,
+	.addr_to_user  = sctp_v4_addr_to_user,
+	.to_sk_saddr   = sctp_v4_to_sk_saddr,
+	.to_sk_daddr   = sctp_v4_to_sk_daddr,
 	.af            = &sctp_af_inet
 };
 
@@ -1047,8 +1049,6 @@ static struct sctp_af sctp_af_inet = {
 	.copy_addrlist	   = sctp_v4_copy_addrlist,
 	.from_skb	   = sctp_v4_from_skb,
 	.from_sk	   = sctp_v4_from_sk,
-	.to_sk_saddr	   = sctp_v4_to_sk_saddr,
-	.to_sk_daddr	   = sctp_v4_to_sk_daddr,
 	.from_addr_param   = sctp_v4_from_addr_param,
 	.to_addr_param	   = sctp_v4_to_addr_param,
 	.cmp_addr	   = sctp_v4_cmp_addr,
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 429899689408..1dcaeefc7d4b 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -254,7 +254,7 @@ static struct sctp_transport *sctp_addr_id2transport(struct sock *sk,
 	if (id_asoc && (id_asoc != addr_asoc))
 		return NULL;
 
-	sctp_get_pf_specific(sk->sk_family)->addr_v4map(sctp_sk(sk),
+	sctp_get_pf_specific(sk->sk_family)->addr_to_user(sctp_sk(sk),
 						(union sctp_addr *)addr);
 
 	return transport;
@@ -396,7 +396,7 @@ static int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 	/* Copy back into socket for getsockname() use. */
 	if (!ret) {
 		inet_sk(sk)->inet_sport = htons(inet_sk(sk)->inet_num);
-		af->to_sk_saddr(addr, sk);
+		sp->pf->to_sk_saddr(addr, sk);
 	}
 
 	return ret;
@@ -1053,7 +1053,6 @@ static int __sctp_connect(struct sock *sk,
 	struct sctp_association *asoc2;
 	struct sctp_transport *transport;
 	union sctp_addr to;
-	struct sctp_af *af;
 	sctp_scope_t scope;
 	long timeo;
 	int err = 0;
@@ -1081,6 +1080,8 @@ static int __sctp_connect(struct sock *sk,
 	/* Walk through the addrs buffer and count the number of addresses. */
 	addr_buf = kaddrs;
 	while (walk_size < addrs_size) {
+		struct sctp_af *af;
+
 		if (walk_size + sizeof(sa_family_t) > addrs_size) {
 			err = -EINVAL;
 			goto out_free;
@@ -1205,8 +1206,7 @@ static int __sctp_connect(struct sock *sk,
 
 	/* Initialize sk's dport and daddr for getpeername() */
 	inet_sk(sk)->inet_dport = htons(asoc->peer.port);
-	af = sctp_get_af_specific(sa_addr->sa.sa_family);
-	af->to_sk_daddr(sa_addr, sk);
+	sp->pf->to_sk_daddr(sa_addr, sk);
 	sk->sk_err = 0;
 
 	/* in-kernel sockets don't generally have a file allocated to them
@@ -4143,7 +4143,7 @@ static int sctp_getsockopt_sctp_status(struct sock *sk, int len,
 	memcpy(&status.sstat_primary.spinfo_address, &transport->ipaddr,
 			transport->af_specific->sockaddr_len);
 	/* Map ipv4 address into v4-mapped-on-v6 address.  */
-	sctp_get_pf_specific(sk->sk_family)->addr_v4map(sctp_sk(sk),
+	sctp_get_pf_specific(sk->sk_family)->addr_to_user(sctp_sk(sk),
 		(union sctp_addr *)&status.sstat_primary.spinfo_address);
 	status.sstat_primary.spinfo_state = transport->state;
 	status.sstat_primary.spinfo_cwnd = transport->cwnd;
@@ -4301,8 +4301,8 @@ static int sctp_getsockopt_autoclose(struct sock *sk, int len, char __user *optv
 int sctp_do_peeloff(struct sock *sk, sctp_assoc_t id, struct socket **sockp)
 {
 	struct sctp_association *asoc = sctp_id2assoc(sk, id);
+	struct sctp_sock *sp = sctp_sk(sk);
 	struct socket *sock;
-	struct sctp_af *af;
 	int err = 0;
 
 	if (!asoc)
@@ -4324,8 +4324,7 @@ int sctp_do_peeloff(struct sock *sk, sctp_assoc_t id, struct socket **sockp)
 	/* Make peeled-off sockets more like 1-1 accepted sockets.
 	 * Set the daddr and initialize id to something more random
 	 */
-	af = sctp_get_af_specific(asoc->peer.primary_addr.sa.sa_family);
-	af->to_sk_daddr(&asoc->peer.primary_addr, sk);
+	sp->pf->to_sk_daddr(&asoc->peer.primary_addr, sk);
 
 	/* Populate the fields of the newsk from the oldsk and migrate the
 	 * asoc to the newsk.
@@ -4709,8 +4708,8 @@ static int sctp_getsockopt_peer_addrs(struct sock *sk, int len,
 	list_for_each_entry(from, &asoc->peer.transport_addr_list,
 				transports) {
 		memcpy(&temp, &from->ipaddr, sizeof(temp));
-		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp, &temp);
-		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
+		addrlen = sctp_get_pf_specific(sk->sk_family)
+			      ->addr_to_user(sp, &temp);
 		if (space_left < addrlen)
 			return -ENOMEM;
 		if (copy_to_user(to, &temp, addrlen))
@@ -4754,9 +4753,9 @@ static int sctp_copy_laddrs(struct sock *sk, __u16 port, void *to,
 		if (!temp.v4.sin_port)
 			temp.v4.sin_port = htons(port);
 
-		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sctp_sk(sk),
-								&temp);
-		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
+		addrlen = sctp_get_pf_specific(sk->sk_family)
+			      ->addr_to_user(sctp_sk(sk), &temp);
+
 		if (space_left < addrlen) {
 			cnt =  -ENOMEM;
 			break;
@@ -4844,8 +4843,8 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 	 */
 	list_for_each_entry(addr, &bp->address_list, list) {
 		memcpy(&temp, &addr->a, sizeof(temp));
-		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp, &temp);
-		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
+		addrlen = sctp_get_pf_specific(sk->sk_family)
+			      ->addr_to_user(sp, &temp);
 		if (space_left < addrlen) {
 			err =  -ENOMEM; /*fixme: right error?*/
 			goto out;
@@ -4904,7 +4903,7 @@ static int sctp_getsockopt_primary_addr(struct sock *sk, int len,
 	memcpy(&prim.ssp_addr, &asoc->peer.primary_path->ipaddr,
 		asoc->peer.primary_path->af_specific->sockaddr_len);
 
-	sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp,
+	sctp_get_pf_specific(sk->sk_family)->addr_to_user(sp,
 			(union sctp_addr *)&prim.ssp_addr);
 
 	if (put_user(len, optlen))
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 7dd672fa651f..cf6c267a119c 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -289,8 +289,8 @@ void sctp_transport_route(struct sctp_transport *transport,
 		 */
 		if (asoc && (!asoc->peer.primary_path ||
 				(transport == asoc->peer.active_path)))
-			opt->pf->af->to_sk_saddr(&transport->saddr,
-						 asoc->base.sk);
+			opt->pf->to_sk_saddr(&transport->saddr,
+					     asoc->base.sk);
 	} else
 		transport->pathmtu = SCTP_DEFAULT_MAXSEGMENT;
 }
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 85c64658bd0b..1ca47f038f7c 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -341,7 +341,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_peer_addr_change(
 	memcpy(&spc->spc_aaddr, aaddr, sizeof(struct sockaddr_storage));
 
 	/* Map ipv4 address into v4-mapped-on-v6 address.  */
-	sctp_get_pf_specific(asoc->base.sk->sk_family)->addr_v4map(
+	sctp_get_pf_specific(asoc->base.sk->sk_family)->addr_to_user(
 					sctp_sk(asoc->base.sk),
 					(union sctp_addr *)&spc->spc_aaddr);
 
-- 
1.9.1
