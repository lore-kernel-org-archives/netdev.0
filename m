From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 10/10] MLSXFRM: Auto-labeling of child sockets
Date: Wed, 12 Jul 2006 16:15:01 -0500
Message-ID: <44B56655.9080303@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, tjaeger@cse.psu.edu,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:781 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932452AbWGLVPR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 17:15:17 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This automatically labels the TCP, Unix stream, and dccp child sockets
as well as openreqs to be at the same MLS level as the peer.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h        |   43 ++++++++++++++++++++++++++
 include/net/request_sock.h      |    1 
 include/net/sock.h              |    1 
 net/dccp/ipv4.c                 |    3 +
 net/dccp/ipv6.c                 |    7 +++-
 net/ipv4/inet_connection_sock.c |    4 +-
 net/ipv4/syncookies.c           |    6 +++
 net/ipv4/tcp_ipv4.c             |    3 +
 net/ipv6/tcp_ipv6.c             |    6 ++-
 security/dummy.c                |   18 +++++++++++
 security/selinux/hooks.c        |   49 +++++++++++++++++++++++++++++-
 security/selinux/xfrm.c         |    1 
 12 files changed, 134 insertions(+), 8 deletions(-)

--- linux-2.6.17.sk_policy/include/linux/security.h	2006-07-12 10:04:00.000000000 -0500
+++ linux-2.6.17/include/linux/security.h	2006-07-12 10:47:39.000000000 -0500
@@ -89,6 +89,7 @@ extern int cap_netlink_recv(struct sk_bu
 struct nfsctl_arg;
 struct sched_param;
 struct swap_info_struct;
+struct request_sock;
 
 /* bprm_apply_creds unsafe reasons */
 #define LSM_UNSAFE_SHARE	1
@@ -818,6 +819,12 @@ struct swap_info_struct;
  * @sk_getsecid:
  *	Retrieve the LSM-specific secid for the sock to enable caching of network
  *	authorizations.
+ * @sock_graft:
+ *	Sets the socket's isec sid to the sock's sid.
+ * @inet_conn_request:
+ *	Sets the openreq's sid to socket's sid with MLS portion taken from peer sid.
+ * @inet_csk_clone:
+ *	Sets the new child socket's sid to the openreq sid.
  *
  * Security hooks for XFRM operations.
  *
@@ -1345,6 +1352,10 @@ struct security_operations {
 	void (*sk_free_security) (struct sock *sk);
 	void (*sk_clone_security) (const struct sock *sk, struct sock *newsk);
 	void (*sk_getsecid) (struct sock *sk, u32 *secid);
+	void (*sock_graft)(struct sock* sk, struct socket *parent);
+	int (*inet_conn_request)(struct sock *sk, struct sk_buff *skb,
+					struct request_sock *req);
+	void (*inet_csk_clone)(struct sock *newsk, const struct request_sock *req);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -2896,6 +2907,23 @@ static inline void security_sk_secid(str
 {
 	security_ops->sk_getsecid(sk, secid);
 }
+
+static inline void security_sock_graft(struct sock* sk, struct socket *parent)
+{
+	security_ops->sock_graft(sk, parent);
+}
+
+static inline int security_inet_conn_request(struct sock *sk,
+			struct sk_buff *skb, struct request_sock *req)
+{
+	return security_ops->inet_conn_request(sk, skb, req);
+}
+
+static inline void security_inet_csk_clone(struct sock *newsk,
+			const struct request_sock *req)
+{
+	security_ops->inet_csk_clone(newsk, req);
+}
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct socket * sock,
 					       struct socket * other, 
@@ -3026,6 +3054,21 @@ static inline void security_sk_clone(con
 static inline void security_sk_secid(struct sock *sk, u32 *secid)
 {
 }
+
+static inline void security_sock_graft(struct sock* sk, struct socket *parent)
+{
+}
+
+static inline int security_inet_conn_request(struct sock *sk,
+			struct sk_buff *skb, struct request_sock *req)
+{
+	return 0;
+}
+
+static inline void security_inet_csk_clone(struct sock *newsk,
+			const struct request_sock *req)
+{
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
--- linux-2.6.17.sk_policy/include/net/sock.h	2006-07-11 19:14:14.000000000 -0500
+++ linux-2.6.17/include/net/sock.h	2006-07-12 10:41:53.000000000 -0500
@@ -968,6 +968,7 @@ static inline void sock_graft(struct soc
 	sk->sk_sleep = &parent->wait;
 	parent->sk = sk;
 	sk->sk_socket = parent;
+	security_sock_graft(sk, parent);
 	write_unlock_bh(&sk->sk_callback_lock);
 }
 
--- linux-2.6.17.sk_policy/include/net/request_sock.h	2006-06-17 20:49:35.000000000 -0500
+++ linux-2.6.17/include/net/request_sock.h	2006-07-12 10:41:53.000000000 -0500
@@ -53,6 +53,7 @@ struct request_sock {
 	unsigned long			expires;
 	struct request_sock_ops		*rsk_ops;
 	struct sock			*sk;
+	u32				secid;
 };
 
 static inline struct request_sock *reqsk_alloc(struct request_sock_ops *ops)
--- linux-2.6.17.sk_policy/security/dummy.c	2006-07-12 10:04:00.000000000 -0500
+++ linux-2.6.17/security/dummy.c	2006-07-12 11:27:51.000000000 -0500
@@ -813,6 +813,21 @@ static inline void dummy_sk_clone_securi
 static inline void dummy_sk_getsecid(struct sock *sk, u32 *secid)
 {
 }
+
+static inline void dummy_sock_graft(struct sock* sk, struct socket *parent)
+{
+}
+
+static inline int dummy_inet_conn_request(struct sock *sk,
+			struct sk_buff *skb, struct request_sock *req)
+{
+	return 0;
+}
+
+static inline void dummy_inet_csk_clone(struct sock *newsk,
+			const struct request_sock *req)
+{
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -1074,6 +1089,9 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, sk_free_security);
 	set_to_dummy_if_null(ops, sk_clone_security);
 	set_to_dummy_if_null(ops, sk_getsecid);
+	set_to_dummy_if_null(ops, sock_graft);
+	set_to_dummy_if_null(ops, inet_conn_request);
+	set_to_dummy_if_null(ops, inet_csk_clone);
  #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef  CONFIG_SECURITY_NETWORK_XFRM
 	set_to_dummy_if_null(ops, xfrm_policy_alloc_security);
--- linux-2.6.17.sk_policy/security/selinux/hooks.c	2006-07-12 09:18:59.000000000 -0500
+++ linux-2.6.17/security/selinux/hooks.c	2006-07-12 14:55:16.000000000 -0500
@@ -3324,7 +3324,12 @@ static int selinux_socket_unix_stream_co
 	/* server child socket */
 	ssec = newsk->sk_security;
 	ssec->peer_sid = isec->sid;
-	
+	err = security_sid_mls_copy(other_isec->sid, ssec->peer_sid, &ssec->sid);
+	if (err) {
+		printk(KERN_ERR "ERROR: security_sid_mls_copy failed.");
+		return err;
+	}
+
 	return 0;
 }
 
@@ -3586,6 +3591,45 @@ out:
 	return;
 }
 
+void selinux_sock_graft(struct sock* sk, struct socket *parent)
+{
+	struct inode_security_struct *isec = SOCK_INODE(parent)->i_security;
+	struct sk_security_struct *sksec = sk->sk_security;
+
+	isec->sid = sksec->sid;
+}
+
+int selinux_inet_conn_request(struct sock *sk, struct sk_buff *skb, 
+					   struct request_sock *req)
+{
+	struct sk_security_struct *sksec = sk->sk_security;
+	int err;
+	u32 newsid = 0;
+	u32 peersid;
+
+	BUG_ON(selinux_xfrm_decode_session(skb, &peersid, 0));
+
+	err = security_sid_mls_copy(sksec->sid, peersid, &newsid);
+	if (err) {
+		printk(KERN_ERR "ERROR: security_sid_mls_copy failed.");
+		return err;
+	}
+
+	req->secid = newsid;
+	return 0;
+}
+
+void selinux_inet_csk_clone(struct sock *newsk, const struct request_sock *req)
+{
+	struct sk_security_struct *newsksec = newsk->sk_security;
+
+	newsksec->sid = req->secid;
+	/* NOTE: Ideally, we should also get the isec->sid for the
+	   new socket in sync, but we don't have the isec available yet.
+	   So we will wait until sock_graft to do it, by which
+	   time it will have been created and available. */
+}
+
 static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
 {
 	int err = 0;
@@ -4623,6 +4667,9 @@ static struct security_operations selinu
 	.sk_free_security =		selinux_sk_free_security,
 	.sk_clone_security =		selinux_sk_clone_security,
 	.sk_getsecid = 			selinux_sk_getsecid,
+	.sock_graft =			selinux_sock_graft,
+	.inet_conn_request =		selinux_inet_conn_request,
+	.inet_csk_clone =		selinux_inet_csk_clone,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
--- linux-2.6.17.sk_policy/security/selinux/xfrm.c	2006-07-12 10:05:52.000000000 -0500
+++ linux-2.6.17/security/selinux/xfrm.c	2006-07-12 14:10:18.000000000 -0500
@@ -271,7 +271,6 @@ not_from_user:
 		goto out;
 	}
 
-
 	ctx->ctx_doi = XFRM_SC_DOI_LSM;
 	ctx->ctx_alg = XFRM_SC_ALG_SELINUX;
 	ctx->ctx_sid = ctx_sid;
--- linux-2.6.17.sk_policy/net/dccp/ipv4.c	2006-07-12 09:10:02.000000000 -0500
+++ linux-2.6.17/net/dccp/ipv4.c	2006-07-12 10:41:53.000000000 -0500
@@ -501,6 +501,9 @@ int dccp_v4_conn_request(struct sock *sk
 
 	dccp_openreq_init(req, &dp, skb);
 
+	if (security_inet_conn_request(sk, skb, req))
+		goto drop_and_free;
+
 	ireq = inet_rsk(req);
 	ireq->loc_addr = daddr;
 	ireq->rmt_addr = saddr;
--- linux-2.6.17.sk_policy/net/dccp/ipv6.c	2006-07-12 09:10:02.000000000 -0500
+++ linux-2.6.17/net/dccp/ipv6.c	2006-07-12 10:55:37.000000000 -0500
@@ -423,7 +423,7 @@ static int dccp_v6_send_response(struct 
 	fl.oif = ireq6->iif;
 	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 	fl.fl_ip_sport = inet_sk(sk)->sport;
-	security_sk_secid(sk, &fl.secid);
+	fl.secid = req->secid;
 
 	if (dst == NULL) {
 		opt = np->opt;
@@ -625,7 +625,7 @@ static void dccp_v6_reqsk_send_ack(struc
 	fl.oif = inet6_iif(rxskb);
 	fl.fl_ip_dport = dh->dccph_dport;
 	fl.fl_ip_sport = dh->dccph_sport;
-	security_xfrm_skb_secid(rxskb, &fl.secid);
+	fl.secid = req->secid;
 
 	if (!ip6_dst_lookup(NULL, &skb->dst, &fl)) {
 		if (xfrm_lookup(&skb->dst, &fl, NULL, 0) >= 0) {
@@ -708,6 +708,9 @@ static int dccp_v6_conn_request(struct s
 
 	dccp_openreq_init(req, &dp, skb);
 
+	if (security_inet_conn_request(sk, skb, req))
+		goto drop_and_free;
+
 	ireq6 = inet6_rsk(req);
 	ireq = inet_rsk(req);
 	ipv6_addr_copy(&ireq6->rmt_addr, &skb->nh.ipv6h->saddr);
--- linux-2.6.17.sk_policy/net/ipv4/inet_connection_sock.c	2006-07-12 09:10:02.000000000 -0500
+++ linux-2.6.17/net/ipv4/inet_connection_sock.c	2006-07-12 10:56:57.000000000 -0500
@@ -323,11 +323,11 @@ struct dst_entry* inet_csk_route_req(str
 					.saddr = ireq->loc_addr,
 					.tos = RT_CONN_FLAGS(sk) } },
 			    .proto = sk->sk_protocol,
+			    .secid = req->secid,
 			    .uli_u = { .ports =
 				       { .sport = inet_sk(sk)->sport,
 					 .dport = ireq->rmt_port } } };
 
-	security_sk_secid(sk, &fl.secid);
 	if (ip_route_output_flow(&rt, &fl, sk, 0)) {
 		IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
@@ -510,6 +510,8 @@ struct sock *inet_csk_clone(struct sock 
 
 		/* Deinitialize accept_queue to trap illegal accesses. */
 		memset(&newicsk->icsk_accept_queue, 0, sizeof(newicsk->icsk_accept_queue));
+
+		security_inet_csk_clone(newsk, req);
 	}
 	return newsk;
 }
--- linux-2.6.17.sk_policy/net/ipv4/syncookies.c	2006-07-12 09:10:02.000000000 -0500
+++ linux-2.6.17/net/ipv4/syncookies.c	2006-07-12 10:58:26.000000000 -0500
@@ -214,6 +214,10 @@ struct sock *cookie_v4_check(struct sock
 	if (!req)
 		goto out;
 
+	if (security_inet_conn_request(sk, skb, req)) {
+		reqsk_free(req);
+		goto out; 
+	}
 	ireq = inet_rsk(req);
 	treq = tcp_rsk(req);
 	treq->rcv_isn		= htonl(skb->h.th->seq) - 1;
@@ -256,10 +260,10 @@ struct sock *cookie_v4_check(struct sock
 						.saddr = ireq->loc_addr,
 						.tos = RT_CONN_FLAGS(sk) } },
 				    .proto = IPPROTO_TCP,
+				    .secid = req->secid,
 				    .uli_u = { .ports =
 					       { .sport = skb->h.th->dest,
 						 .dport = skb->h.th->source } } };
-		security_sk_secid(sk, &fl.secid);
 		if (ip_route_output_key(&rt, &fl)) {
 			reqsk_free(req);
 			goto out; 
--- linux-2.6.17.sk_policy/net/ipv4/tcp_ipv4.c	2006-07-11 16:04:20.000000000 -0500
+++ linux-2.6.17/net/ipv4/tcp_ipv4.c	2006-07-12 12:04:48.000000000 -0500
@@ -781,6 +781,9 @@ int tcp_v4_conn_request(struct sock *sk,
 
 	tcp_openreq_init(req, &tmp_opt, skb);
 
+	if (security_inet_conn_request(sk, skb, req))
+		goto drop_and_free;
+
 	ireq = inet_rsk(req);
 	ireq->loc_addr = daddr;
 	ireq->rmt_addr = saddr;
--- linux-2.6.17.sk_policy/net/ipv6/tcp_ipv6.c	2006-07-12 09:10:02.000000000 -0500
+++ linux-2.6.17/net/ipv6/tcp_ipv6.c	2006-07-12 11:00:58.000000000 -0500
@@ -471,7 +471,7 @@ static int tcp_v6_send_synack(struct soc
 	fl.oif = treq->iif;
 	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 	fl.fl_ip_sport = inet_sk(sk)->sport;
-	security_sk_secid(sk, &fl.secid);
+	fl.secid = req->secid;
 
 	if (dst == NULL) {
 		opt = np->opt;
@@ -809,6 +809,8 @@ static int tcp_v6_conn_request(struct so
 
 	tcp_rsk(req)->snt_isn = isn;
 
+	security_inet_conn_request(sk, skb, req);
+
 	if (tcp_v6_send_synack(sk, req, NULL))
 		goto drop;
 
@@ -913,7 +915,7 @@ static struct sock * tcp_v6_syn_recv_soc
 		fl.oif = sk->sk_bound_dev_if;
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 		fl.fl_ip_sport = inet_sk(sk)->sport;
-		security_sk_secid(sk, &fl.secid);
+		fl.secid = req->secid;
 
 		if (ip6_dst_lookup(sk, &dst, &fl))
 			goto out;
