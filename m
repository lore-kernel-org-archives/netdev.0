From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 10/10] MLSXFRM-v02: Auto-labeling of child sockets
Date: Tue, 18 Jul 2006 12:25:00 -0500
Message-ID: <44BD196C.6000307@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:12100 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932323AbWGRRZN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 13:25:13 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This automatically labels the TCP, Unix stream, and dccp child sockets
as well as openreqs to be at the same MLS level as the peer. This will
result in the selection of appropriately labeled IPSec Security Associations.

This also uses the sock's sid (as opposed to the isec sid) in SELinux enforcement
of secmark in rcv_skb and postroute_last hooks.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h        |   55 ++++++++++++
 include/net/request_sock.h      |    1 
 include/net/sock.h              |    1 
 net/dccp/ipv4.c                 |    3 
 net/dccp/ipv6.c                 |    7 +
 net/ipv4/inet_connection_sock.c |    4 
 net/ipv4/syncookies.c           |    6 +
 net/ipv4/tcp_ipv4.c             |    3 
 net/ipv6/tcp_ipv6.c             |    6 -
 security/dummy.c                |   24 +++++
 security/selinux/hooks.c        |  137 ++++++++++++++++++++----------
 security/selinux/xfrm.c         |    1 
 12 files changed, 197 insertions(+), 51 deletions(-)

--- linux-2.6.17.sk_policy/include/linux/security.h	2006-07-17 16:51:22.000000000 -0500
+++ linux-2.6.17/include/linux/security.h	2006-07-18 08:46:00.000000000 -0500
@@ -90,6 +90,7 @@ extern int cap_netlink_recv(struct sk_bu
 struct nfsctl_arg;
 struct sched_param;
 struct swap_info_struct;
+struct request_sock;
 
 /* bprm_apply_creds unsafe reasons */
 #define LSM_UNSAFE_SHARE	1
@@ -819,6 +820,14 @@ struct swap_info_struct;
  * @sk_getsecid:
  *	Retrieve the LSM-specific secid for the sock to enable caching of network
  *	authorizations.
+ * @sock_graft:
+ *	Sets the socket's isec sid to the sock's sid.
+ * @inet_conn_request:
+ *	Sets the openreq's sid to socket's sid with MLS portion taken from peer sid.
+ * @inet_csk_clone:
+ *	Sets the new child socket's sid to the openreq sid.
+ * @req_classify_flow:
+ *	Sets the flow's sid to the openreq sid.
  *
  * Security hooks for XFRM operations.
  *
@@ -1346,6 +1355,11 @@ struct security_operations {
 	void (*sk_free_security) (struct sock *sk);
 	void (*sk_clone_security) (const struct sock *sk, struct sock *newsk);
 	void (*sk_getsecid) (struct sock *sk, u32 *secid);
+	void (*sock_graft)(struct sock* sk, struct socket *parent);
+	int (*inet_conn_request)(struct sock *sk, struct sk_buff *skb,
+					struct request_sock *req);
+	void (*inet_csk_clone)(struct sock *newsk, const struct request_sock *req);
+	void (*req_classify_flow)(const struct request_sock *req, struct flowi *fl);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -2897,6 +2911,28 @@ static inline void security_sk_classify_
 {
 	security_ops->sk_getsecid(sk, &fl->secid);
 }
+
+static inline void security_req_classify_flow(const struct request_sock *req, struct flowi *fl)
+{
+	security_ops->req_classify_flow(req, fl);
+}
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
@@ -3027,6 +3063,25 @@ static inline void security_sk_clone(con
 static inline void security_sk_classify_flow(struct sock *sk, struct flowi *fl)
 {
 }
+
+static inline void security_req_classify_flow(const struct request_sock *req, struct flowi *fl)
+{
+}
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
--- linux-2.6.17.sk_policy/include/net/sock.h	2006-07-17 10:35:54.000000000 -0500
+++ linux-2.6.17/include/net/sock.h	2006-07-17 20:07:41.000000000 -0500
@@ -968,6 +968,7 @@ static inline void sock_graft(struct soc
 	sk->sk_sleep = &parent->wait;
 	parent->sk = sk;
 	sk->sk_socket = parent;
+	security_sock_graft(sk, parent);
 	write_unlock_bh(&sk->sk_callback_lock);
 }
 
--- linux-2.6.17.sk_policy/include/net/request_sock.h	2006-06-17 20:49:35.000000000 -0500
+++ linux-2.6.17/include/net/request_sock.h	2006-07-17 20:07:41.000000000 -0500
@@ -53,6 +53,7 @@ struct request_sock {
 	unsigned long			expires;
 	struct request_sock_ops		*rsk_ops;
 	struct sock			*sk;
+	u32				secid;
 };
 
 static inline struct request_sock *reqsk_alloc(struct request_sock_ops *ops)
--- linux-2.6.17.sk_policy/security/dummy.c	2006-07-17 16:51:22.000000000 -0500
+++ linux-2.6.17/security/dummy.c	2006-07-18 08:51:47.000000000 -0500
@@ -813,6 +813,26 @@ static inline void dummy_sk_clone_securi
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
+
+static inline void dummy_req_classify_flow(const struct request_sock *req,
+			struct flowi *fl)
+{
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -1074,6 +1094,10 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, sk_free_security);
 	set_to_dummy_if_null(ops, sk_clone_security);
 	set_to_dummy_if_null(ops, sk_getsecid);
+	set_to_dummy_if_null(ops, sock_graft);
+	set_to_dummy_if_null(ops, inet_conn_request);
+	set_to_dummy_if_null(ops, inet_csk_clone);
+	set_to_dummy_if_null(ops, req_classify_flow);
  #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef  CONFIG_SECURITY_NETWORK_XFRM
 	set_to_dummy_if_null(ops, xfrm_policy_alloc_security);
--- linux-2.6.17.sk_policy/security/selinux/hooks.c	2006-07-17 16:07:42.000000000 -0500
+++ linux-2.6.17/security/selinux/hooks.c	2006-07-18 10:33:42.000000000 -0500
@@ -3328,8 +3328,9 @@ static int selinux_socket_unix_stream_co
 	/* server child socket */
 	ssec = newsk->sk_security;
 	ssec->peer_sid = isec->sid;
-	
-	return 0;
+	err = security_sid_mls_copy(other_isec->sid, ssec->peer_sid, &ssec->sid);
+
+	return err;
 }
 
 static int selinux_socket_unix_may_send(struct socket *sock,
@@ -3355,11 +3356,29 @@ static int selinux_socket_unix_may_send(
 }
 
 static int selinux_sock_rcv_skb_compat(struct sock *sk, struct sk_buff *skb,
-		struct avc_audit_data *ad, u32 sock_sid, u16 sock_class,
-		u16 family, char *addrp, int len)
+		struct avc_audit_data *ad, u16 family, char *addrp, int len)
 {
 	int err = 0;
 	u32 netif_perm, node_perm, node_sid, if_sid, recv_perm = 0;
+	struct socket *sock;
+	u16 sock_class = 0;
+	u32 sock_sid = 0;
+
+ 	read_lock_bh(&sk->sk_callback_lock);
+ 	sock = sk->sk_socket;
+ 	if (sock) {
+ 		struct inode *inode;
+ 		inode = SOCK_INODE(sock);
+ 		if (inode) {
+ 			struct inode_security_struct *isec;
+ 			isec = inode->i_security;
+ 			sock_sid = isec->sid;
+ 			sock_class = isec->sclass;
+ 		}
+ 	}
+ 	read_unlock_bh(&sk->sk_callback_lock);
+ 	if (!sock_sid)
+  		goto out;
 
 	if (!skb->dev)
 		goto out;
@@ -3419,12 +3438,10 @@ out:
 static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	u16 family;
-	u16 sock_class = 0;
 	char *addrp;
 	int len, err = 0;
-	u32 sock_sid = 0;
-	struct socket *sock;
 	struct avc_audit_data ad;
+	struct sk_security_struct *sksec = sk->sk_security;
 
 	family = sk->sk_family;
 	if (family != PF_INET && family != PF_INET6)
@@ -3434,22 +3451,6 @@ static int selinux_socket_sock_rcv_skb(s
 	if (family == PF_INET6 && skb->protocol == ntohs(ETH_P_IP))
 		family = PF_INET;
 
- 	read_lock_bh(&sk->sk_callback_lock);
- 	sock = sk->sk_socket;
- 	if (sock) {
- 		struct inode *inode;
- 		inode = SOCK_INODE(sock);
- 		if (inode) {
- 			struct inode_security_struct *isec;
- 			isec = inode->i_security;
- 			sock_sid = isec->sid;
- 			sock_class = isec->sclass;
- 		}
- 	}
- 	read_unlock_bh(&sk->sk_callback_lock);
- 	if (!sock_sid)
-  		goto out;
-
 	AVC_AUDIT_DATA_INIT(&ad, NET);
 	ad.u.net.netif = skb->dev ? skb->dev->name : "[unknown]";
 	ad.u.net.family = family;
@@ -3459,16 +3460,15 @@ static int selinux_socket_sock_rcv_skb(s
 		goto out;
 
 	if (selinux_compat_net)
-		err = selinux_sock_rcv_skb_compat(sk, skb, &ad, sock_sid,
-						  sock_class, family,
+		err = selinux_sock_rcv_skb_compat(sk, skb, &ad, family,
 						  addrp, len);
 	else
-		err = avc_has_perm(sock_sid, skb->secmark, SECCLASS_PACKET,
+		err = avc_has_perm(sksec->sid, skb->secmark, SECCLASS_PACKET,
 				   PACKET__RECV, &ad);
 	if (err)
 		goto out;
 
-	err = selinux_xfrm_sock_rcv_skb(sock_sid, skb, &ad);
+	err = selinux_xfrm_sock_rcv_skb(sksec->sid, skb, &ad);
 out:	
 	return err;
 }
@@ -3576,6 +3576,49 @@ static void selinux_sk_getsecid(struct s
 	}
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
+	err = selinux_xfrm_decode_session(skb, &peersid, 0);
+	BUG_ON(err);
+
+	err = security_sid_mls_copy(sksec->sid, peersid, &newsid);
+	if (err)
+		return err;
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
+void selinux_req_classify_flow(const struct request_sock *req, struct flowi *fl)
+{
+	fl->secid = req->secid;
+}
+
 static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
 {
 	int err = 0;
@@ -3615,12 +3658,24 @@ out:
 #ifdef CONFIG_NETFILTER
 
 static int selinux_ip_postroute_last_compat(struct sock *sk, struct net_device *dev,
-					    struct inode_security_struct *isec,
 					    struct avc_audit_data *ad,
 					    u16 family, char *addrp, int len)
 {
-	int err;
+	int err = 0;
 	u32 netif_perm, node_perm, node_sid, if_sid, send_perm = 0;
+	struct socket *sock;
+	struct inode *inode;
+	struct inode_security_struct *isec;
+
+	sock = sk->sk_socket;
+	if (!sock)
+		goto out;
+
+	inode = SOCK_INODE(sock);
+	if (!inode)
+		goto out;
+
+	isec = inode->i_security;
 	
 	err = sel_netif_sids(dev, &if_sid, NULL);
 	if (err)
@@ -3685,26 +3740,16 @@ static unsigned int selinux_ip_postroute
 	char *addrp;
 	int len, err = 0;
 	struct sock *sk;
-	struct socket *sock;
-	struct inode *inode;
 	struct sk_buff *skb = *pskb;
-	struct inode_security_struct *isec;
 	struct avc_audit_data ad;
 	struct net_device *dev = (struct net_device *)out;
+	struct sk_security_struct *sksec;
 
 	sk = skb->sk;
 	if (!sk)
 		goto out;
 
-	sock = sk->sk_socket;
-	if (!sock)
-		goto out;
-
-	inode = SOCK_INODE(sock);
-	if (!inode)
-		goto out;
-
-	isec = inode->i_security;
+	sksec = sk->sk_security;
 
 	AVC_AUDIT_DATA_INIT(&ad, NET);
 	ad.u.net.netif = dev->name;
@@ -3715,16 +3760,16 @@ static unsigned int selinux_ip_postroute
 		goto out;
 
 	if (selinux_compat_net)
-		err = selinux_ip_postroute_last_compat(sk, dev, isec, &ad,
+		err = selinux_ip_postroute_last_compat(sk, dev, &ad,
 						       family, addrp, len);
 	else
-		err = avc_has_perm(isec->sid, skb->secmark, SECCLASS_PACKET,
+		err = avc_has_perm(sksec->sid, skb->secmark, SECCLASS_PACKET,
 				   PACKET__SEND, &ad);
 
 	if (err)
 		goto out;
 
-	err = selinux_xfrm_postroute_last(isec->sid, skb, &ad);
+	err = selinux_xfrm_postroute_last(sksec->sid, skb, &ad);
 out:
 	return err ? NF_DROP : NF_ACCEPT;
 }
@@ -4613,6 +4658,10 @@ static struct security_operations selinu
 	.sk_free_security =		selinux_sk_free_security,
 	.sk_clone_security =		selinux_sk_clone_security,
 	.sk_getsecid = 			selinux_sk_getsecid,
+	.sock_graft =			selinux_sock_graft,
+	.inet_conn_request =		selinux_inet_conn_request,
+	.inet_csk_clone =		selinux_inet_csk_clone,
+	.req_classify_flow =		selinux_req_classify_flow,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
--- linux-2.6.17.sk_policy/security/selinux/xfrm.c	2006-07-17 16:51:22.000000000 -0500
+++ linux-2.6.17/security/selinux/xfrm.c	2006-07-17 20:07:41.000000000 -0500
@@ -271,7 +271,6 @@ not_from_user:
 		goto out;
 	}
 
-
 	ctx->ctx_doi = XFRM_SC_DOI_LSM;
 	ctx->ctx_alg = XFRM_SC_ALG_SELINUX;
 	ctx->ctx_sid = ctx_sid;
--- linux-2.6.17.sk_policy/net/dccp/ipv4.c	2006-07-17 16:05:38.000000000 -0500
+++ linux-2.6.17/net/dccp/ipv4.c	2006-07-17 20:07:41.000000000 -0500
@@ -501,6 +501,9 @@ int dccp_v4_conn_request(struct sock *sk
 
 	dccp_openreq_init(req, &dp, skb);
 
+	if (security_inet_conn_request(sk, skb, req))
+		goto drop_and_free;
+
 	ireq = inet_rsk(req);
 	ireq->loc_addr = daddr;
 	ireq->rmt_addr = saddr;
--- linux-2.6.17.sk_policy/net/dccp/ipv6.c	2006-07-17 16:05:38.000000000 -0500
+++ linux-2.6.17/net/dccp/ipv6.c	2006-07-17 20:17:45.000000000 -0500
@@ -423,7 +423,7 @@ static int dccp_v6_send_response(struct 
 	fl.oif = ireq6->iif;
 	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 	fl.fl_ip_sport = inet_sk(sk)->sport;
-	security_sk_classify_flow(sk, &fl);
+	security_req_classify_flow(req, &fl);
 
 	if (dst == NULL) {
 		opt = np->opt;
@@ -625,7 +625,7 @@ static void dccp_v6_reqsk_send_ack(struc
 	fl.oif = inet6_iif(rxskb);
 	fl.fl_ip_dport = dh->dccph_dport;
 	fl.fl_ip_sport = dh->dccph_sport;
-	security_skb_classify_flow(rxskb, &fl);
+	security_req_classify_flow(req, &fl);
 
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
--- linux-2.6.17.sk_policy/net/ipv4/inet_connection_sock.c	2006-07-17 16:05:38.000000000 -0500
+++ linux-2.6.17/net/ipv4/inet_connection_sock.c	2006-07-17 20:18:28.000000000 -0500
@@ -327,7 +327,7 @@ struct dst_entry* inet_csk_route_req(str
 				       { .sport = inet_sk(sk)->sport,
 					 .dport = ireq->rmt_port } } };
 
-	security_sk_classify_flow(sk, &fl);
+	security_req_classify_flow(req, &fl);
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
--- linux-2.6.17.sk_policy/net/ipv4/syncookies.c	2006-07-17 16:05:38.000000000 -0500
+++ linux-2.6.17/net/ipv4/syncookies.c	2006-07-17 20:20:23.000000000 -0500
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
@@ -259,7 +263,7 @@ struct sock *cookie_v4_check(struct sock
 				    .uli_u = { .ports =
 					       { .sport = skb->h.th->dest,
 						 .dport = skb->h.th->source } } };
-		security_sk_classify_flow(sk, &fl);
+		security_req_classify_flow(req, &fl);
 		if (ip_route_output_key(&rt, &fl)) {
 			reqsk_free(req);
 			goto out; 
--- linux-2.6.17.sk_policy/net/ipv4/tcp_ipv4.c	2006-07-14 09:57:21.000000000 -0500
+++ linux-2.6.17/net/ipv4/tcp_ipv4.c	2006-07-17 20:07:41.000000000 -0500
@@ -799,6 +799,9 @@ int tcp_v4_conn_request(struct sock *sk,
 
 	tcp_openreq_init(req, &tmp_opt, skb);
 
+	if (security_inet_conn_request(sk, skb, req))
+		goto drop_and_free;
+
 	ireq = inet_rsk(req);
 	ireq->loc_addr = daddr;
 	ireq->rmt_addr = saddr;
--- linux-2.6.17.sk_policy/net/ipv6/tcp_ipv6.c	2006-07-17 16:05:38.000000000 -0500
+++ linux-2.6.17/net/ipv6/tcp_ipv6.c	2006-07-17 20:22:21.000000000 -0500
@@ -471,7 +471,7 @@ static int tcp_v6_send_synack(struct soc
 	fl.oif = treq->iif;
 	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 	fl.fl_ip_sport = inet_sk(sk)->sport;
-	security_sk_classify_flow(sk, &fl);
+	security_req_classify_flow(req, &fl);
 
 	if (dst == NULL) {
 		opt = np->opt;
@@ -827,6 +827,8 @@ static int tcp_v6_conn_request(struct so
 
 	tcp_rsk(req)->snt_isn = isn;
 
+	security_inet_conn_request(sk, skb, req);
+
 	if (tcp_v6_send_synack(sk, req, NULL))
 		goto drop;
 
@@ -931,7 +933,7 @@ static struct sock * tcp_v6_syn_recv_soc
 		fl.oif = sk->sk_bound_dev_if;
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 		fl.fl_ip_sport = inet_sk(sk)->sport;
-		security_sk_classify_flow(sk, &fl);
+		security_req_classify_flow(req, &fl);
 
 		if (ip6_dst_lookup(sk, &dst, &fl))
 			goto out;
