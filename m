From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 4/4] sctp: Inherit all socket options from parent correctly.
Date: Fri, 13 Feb 2009 13:33:44 -0500
Message-ID: <1234550024-30915-5-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:12880 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739AbZBMSdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 13:33:51 -0500
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During peeloff/accept() sctp needs to save the parent socket state
into the new socket so that any options set on the parent are
inherited by the child socket.  This was found when the
parent/listener socket issues SO_BINDTODEVICE, but the
data was misrouted after a route cache flush.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/sctp.h |    2 +
 net/sctp/ipv6.c         |   33 +---------------------------
 net/sctp/protocol.c     |   29 +-----------------------
 net/sctp/socket.c       |   55 +++++++++++++++++++++++++++++++++++++++++------
 4 files changed, 53 insertions(+), 66 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index bbb7742..9e226be 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -138,6 +138,8 @@ void sctp_write_space(struct sock *sk);
 unsigned int sctp_poll(struct file *file, struct socket *sock,
 		poll_table *wait);
 void sctp_sock_rfree(struct sk_buff *skb);
+void sctp_copy_sock(struct sock *newsk, struct sock *sk,
+		    struct sctp_association *asoc);
 extern struct percpu_counter sctp_sockets_allocated;
 
 /*
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 7862275..a63de3f 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -627,9 +627,7 @@ static sctp_scope_t sctp_v6_scope(union sctp_addr *addr)
 static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 					     struct sctp_association *asoc)
 {
-	struct inet_sock *inet = inet_sk(sk);
 	struct sock *newsk;
-	struct inet_sock *newinet;
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct sctp6_sock *newsctp6sk;
 
@@ -639,17 +637,7 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 
 	sock_init_data(NULL, newsk);
 
-	newsk->sk_type = SOCK_STREAM;
-
-	newsk->sk_prot = sk->sk_prot;
-	newsk->sk_no_check = sk->sk_no_check;
-	newsk->sk_reuse = sk->sk_reuse;
-
-	newsk->sk_destruct = inet_sock_destruct;
-	newsk->sk_family = PF_INET6;
-	newsk->sk_protocol = IPPROTO_SCTP;
-	newsk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;
-	newsk->sk_shutdown = sk->sk_shutdown;
+	sctp_copy_sock(newsk, sk, asoc);
 	sock_reset_flag(sk, SOCK_ZAPPED);
 
 	newsctp6sk = (struct sctp6_sock *)newsk;
@@ -657,7 +645,6 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 
 	sctp_sk(newsk)->v4mapped = sctp_sk(sk)->v4mapped;
 
-	newinet = inet_sk(newsk);
 	newnp = inet6_sk(newsk);
 
 	memcpy(newnp, np, sizeof(struct ipv6_pinfo));
@@ -665,26 +652,8 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 	/* Initialize sk's sport, dport, rcv_saddr and daddr for getsockname()
 	 * and getpeername().
 	 */
-	newinet->sport = inet->sport;
-	newnp->saddr = np->saddr;
-	newnp->rcv_saddr = np->rcv_saddr;
-	newinet->dport = htons(asoc->peer.port);
 	sctp_v6_to_sk_daddr(&asoc->peer.primary_addr, newsk);
 
-	/* Init the ipv4 part of the socket since we can have sockets
-	 * using v6 API for ipv4.
-	 */
-	newinet->uc_ttl = -1;
-	newinet->mc_loop = 1;
-	newinet->mc_ttl = 1;
-	newinet->mc_index = 0;
-	newinet->mc_list = NULL;
-
-	if (ipv4_config.no_pmtu_disc)
-		newinet->pmtudisc = IP_PMTUDISC_DONT;
-	else
-		newinet->pmtudisc = IP_PMTUDISC_WANT;
-
 	sk_refcnt_debug_inc(newsk);
 
 	if (newsk->sk_prot->init(newsk)) {
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index cc0b592..c1e316e 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -589,46 +589,21 @@ static int sctp_v4_is_ce(const struct sk_buff *skb)
 static struct sock *sctp_v4_create_accept_sk(struct sock *sk,
 					     struct sctp_association *asoc)
 {
-	struct inet_sock *inet = inet_sk(sk);
-	struct inet_sock *newinet;
 	struct sock *newsk = sk_alloc(sock_net(sk), PF_INET, GFP_KERNEL,
 			sk->sk_prot);
+	struct inet_sock *newinet;
 
 	if (!newsk)
 		goto out;
 
 	sock_init_data(NULL, newsk);
 
-	newsk->sk_type = SOCK_STREAM;
-
-	newsk->sk_no_check = sk->sk_no_check;
-	newsk->sk_reuse = sk->sk_reuse;
-	newsk->sk_shutdown = sk->sk_shutdown;
-
-	newsk->sk_destruct = inet_sock_destruct;
-	newsk->sk_family = PF_INET;
-	newsk->sk_protocol = IPPROTO_SCTP;
-	newsk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;
+	sctp_copy_sock(newsk, sk, asoc);
 	sock_reset_flag(newsk, SOCK_ZAPPED);
 
 	newinet = inet_sk(newsk);
 
-	/* Initialize sk's sport, dport, rcv_saddr and daddr for
-	 * getsockname() and getpeername()
-	 */
-	newinet->sport = inet->sport;
-	newinet->saddr = inet->saddr;
-	newinet->rcv_saddr = inet->rcv_saddr;
-	newinet->dport = htons(asoc->peer.port);
 	newinet->daddr = asoc->peer.primary_addr.v4.sin_addr.s_addr;
-	newinet->pmtudisc = inet->pmtudisc;
-	newinet->id = asoc->next_tsn ^ jiffies;
-
-	newinet->uc_ttl = -1;
-	newinet->mc_loop = 1;
-	newinet->mc_ttl = 1;
-	newinet->mc_index = 0;
-	newinet->mc_list = NULL;
 
 	sk_refcnt_debug_inc(newsk);
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ff0a8f8..dea864f 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3939,7 +3939,6 @@ SCTP_STATIC int sctp_do_peeloff(struct sctp_association *asoc,
 {
 	struct sock *sk = asoc->base.sk;
 	struct socket *sock;
-	struct inet_sock *inetsk;
 	struct sctp_af *af;
 	int err = 0;
 
@@ -3954,18 +3953,18 @@ SCTP_STATIC int sctp_do_peeloff(struct sctp_association *asoc,
 	if (err < 0)
 		return err;
 
-	/* Populate the fields of the newsk from the oldsk and migrate the
-	 * asoc to the newsk.
-	 */
-	sctp_sock_migrate(sk, sock->sk, asoc, SCTP_SOCKET_UDP_HIGH_BANDWIDTH);
+	sctp_copy_sock(sock->sk, sk, asoc);
 
 	/* Make peeled-off sockets more like 1-1 accepted sockets.
 	 * Set the daddr and initialize id to something more random
 	 */
 	af = sctp_get_af_specific(asoc->peer.primary_addr.sa.sa_family);
 	af->to_sk_daddr(&asoc->peer.primary_addr, sk);
-	inetsk = inet_sk(sock->sk);
-	inetsk->id = asoc->next_tsn ^ jiffies;
+
+	/* Populate the fields of the newsk from the oldsk and migrate the
+	 * asoc to the newsk.
+	 */
+	sctp_sock_migrate(sk, sock->sk, asoc, SCTP_SOCKET_UDP_HIGH_BANDWIDTH);
 
 	*sockp = sock;
 
@@ -6700,6 +6699,48 @@ done:
 	sctp_skb_set_owner_r(skb, sk);
 }
 
+void sctp_copy_sock(struct sock *newsk, struct sock *sk,
+		    struct sctp_association *asoc)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct inet_sock *newinet = inet_sk(newsk);
+
+	newsk->sk_type = sk->sk_type;
+	newsk->sk_bound_dev_if = sk->sk_bound_dev_if;
+	newsk->sk_flags = sk->sk_flags;
+	newsk->sk_no_check = sk->sk_no_check;
+	newsk->sk_reuse = sk->sk_reuse;
+
+	newsk->sk_shutdown = sk->sk_shutdown;
+	newsk->sk_destruct = inet_sock_destruct;
+	newsk->sk_family = sk->sk_family;
+	newsk->sk_protocol = IPPROTO_SCTP;
+	newsk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;
+	newsk->sk_sndbuf = sk->sk_sndbuf;
+	newsk->sk_rcvbuf = sk->sk_rcvbuf;
+	newsk->sk_lingertime = sk->sk_lingertime;
+	newsk->sk_rcvtimeo = sk->sk_rcvtimeo;
+	newsk->sk_sndtimeo = sk->sk_sndtimeo;
+
+	newinet = inet_sk(newsk);
+
+	/* Initialize sk's sport, dport, rcv_saddr and daddr for
+	 * getsockname() and getpeername()
+	 */
+	newinet->sport = inet->sport;
+	newinet->saddr = inet->saddr;
+	newinet->rcv_saddr = inet->rcv_saddr;
+	newinet->dport = htons(asoc->peer.port);
+	newinet->pmtudisc = inet->pmtudisc;
+	newinet->id = asoc->next_tsn ^ jiffies;
+
+	newinet->uc_ttl = inet->uc_ttl;
+	newinet->mc_loop = 1;
+	newinet->mc_ttl = 1;
+	newinet->mc_index = 0;
+	newinet->mc_list = NULL;
+}
+
 /* Populate the fields of the newsk from the oldsk and migrate the assoc
  * and its messages to the newsk.
  */
-- 
1.5.4.3

