From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 03/10] MLSXFRM-v02: Add security sid to sock
Date: Tue, 18 Jul 2006 12:24:20 -0500
Message-ID: <44BD1944.50104@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:63112 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932326AbWGRRZz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 13:25:55 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds security for IP sockets at the sock level. Security at the
sock level is needed to enforce the SELinux security policy for security
associations even when a sock is orphaned (such as in the TCP LAST_ACK state).

This will also be used to enforce SELinux controls over data arriving at
or leaving a child socket while it's still waiting to be accepted.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---

 include/linux/security.h          |   12 ++++++++
 include/net/sock.h                |   13 +++++++++
 net/core/sock.c                   |    2 -
 security/dummy.c                  |    5 +++
 security/selinux/hooks.c          |   38 +++++++++++++++-------------
 security/selinux/include/objsec.h |    1 
 6 files changed, 53 insertions(+), 18 deletions(-)

--- linux-2.6.17.mls/include/linux/security.h	2006-07-14 09:28:22.000000000 -0500
+++ linux-2.6.17/include/linux/security.h	2006-07-17 10:35:54.000000000 -0500
@@ -812,6 +812,8 @@ struct swap_info_struct;
  *      which is used to copy security attributes between local stream sockets.
  * @sk_free_security:
  *	Deallocate security structure.
+ * @sk_clone_security:
+ *	Clone/copy security structure.
  * @sk_getsid:
  *	Retrieve the LSM-specific sid for the sock to enable caching of network
  *	authorizations.
@@ -1320,6 +1322,7 @@ struct security_operations {
 	int (*socket_getpeersec_dgram) (struct sk_buff *skb, char **secdata, u32 *seclen);
 	int (*sk_alloc_security) (struct sock *sk, int family, gfp_t priority);
 	void (*sk_free_security) (struct sock *sk);
+	void (*sk_clone_security) (const struct sock *sk, struct sock *newsk);
 	unsigned int (*sk_getsid) (struct sock *sk, struct flowi *fl, u8 dir);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
@@ -2856,6 +2859,11 @@ static inline void security_sk_free(stru
 	return security_ops->sk_free_security(sk);
 }
 
+static inline void security_sk_clone(const struct sock *sk, struct sock *newsk)
+{
+	return security_ops->sk_clone_security(sk, newsk);
+}
+
 static inline unsigned int security_sk_sid(struct sock *sk, struct flowi *fl, u8 dir)
 {
 	return security_ops->sk_getsid(sk, fl, dir);
@@ -2983,6 +2991,10 @@ static inline void security_sk_free(stru
 {
 }
 
+static inline void security_sk_clone(const struct sock *sk, struct sock *newsk)
+{
+}
+
 static inline unsigned int security_sk_sid(struct sock *sk, struct flowi *fl, u8 dir)
 {
 	return 0;
--- linux-2.6.17.mls/include/net/sock.h	2006-07-14 09:57:15.000000000 -0500
+++ linux-2.6.17/include/net/sock.h	2006-07-17 10:35:54.000000000 -0500
@@ -971,6 +971,19 @@ static inline void sock_graft(struct soc
 	write_unlock_bh(&sk->sk_callback_lock);
 }
 
+static inline void sock_copy(struct sock *nsk, const struct sock *osk)
+{
+#ifdef CONFIG_SECURITY_NETWORK
+	void *sptr = nsk->sk_security;
+#endif
+
+	memcpy(nsk, osk, osk->sk_prot->obj_size);
+#ifdef CONFIG_SECURITY_NETWORK
+	nsk->sk_security = sptr;
+	security_sk_clone(osk, nsk);
+#endif
+}
+
 extern int sock_i_uid(struct sock *sk);
 extern unsigned long sock_i_ino(struct sock *sk);
 
--- linux-2.6.17.mls/security/dummy.c	2006-07-14 09:28:40.000000000 -0500
+++ linux-2.6.17/security/dummy.c	2006-07-17 10:35:54.000000000 -0500
@@ -806,6 +806,10 @@ static inline void dummy_sk_free_securit
 {
 }
 
+static inline void dummy_sk_clone_security (const struct sock *sk, struct sock *newsk)
+{
+}
+
 static unsigned int dummy_sk_getsid(struct sock *sk, struct flowi *fl, u8 dir)
 {
 	return 0;
@@ -1050,6 +1054,7 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, socket_getpeersec_dgram);
 	set_to_dummy_if_null(ops, sk_alloc_security);
 	set_to_dummy_if_null(ops, sk_free_security);
+	set_to_dummy_if_null(ops, sk_clone_security);
 	set_to_dummy_if_null(ops, sk_getsid);
  #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef  CONFIG_SECURITY_NETWORK_XFRM
--- linux-2.6.17.mls/security/selinux/hooks.c	2006-07-14 09:57:25.000000000 -0500
+++ linux-2.6.17/security/selinux/hooks.c	2006-07-17 10:44:54.000000000 -0500
@@ -269,15 +269,13 @@ static int sk_alloc_security(struct sock
 {
 	struct sk_security_struct *ssec;
 
-	if (family != PF_UNIX)
-		return 0;
-
 	ssec = kzalloc(sizeof(*ssec), priority);
 	if (!ssec)
 		return -ENOMEM;
 
 	ssec->sk = sk;
 	ssec->peer_sid = SECINITSID_UNLABELED;
+	ssec->sid = SECINITSID_UNLABELED;
 	sk->sk_security = ssec;
 
 	return 0;
@@ -287,9 +285,6 @@ static void sk_free_security(struct sock
 {
 	struct sk_security_struct *ssec = sk->sk_security;
 
-	if (sk->sk_family != PF_UNIX)
-		return;
-
 	sk->sk_security = NULL;
 	kfree(ssec);
 }
@@ -3068,6 +3063,7 @@ static void selinux_socket_post_create(s
 {
 	struct inode_security_struct *isec;
 	struct task_security_struct *tsec;
+	struct sk_security_struct *sksec;
 	u32 newsid;
 
 	isec = SOCK_INODE(sock)->i_security;
@@ -3078,6 +3074,11 @@ static void selinux_socket_post_create(s
 	isec->sid = kern ? SECINITSID_KERNEL : newsid;
 	isec->initialized = 1;
 
+	if (sock->sk) {
+		sksec = sock->sk->sk_security;
+		sksec->sid = isec->sid;
+	}
+
 	return;
 }
 
@@ -3555,22 +3556,24 @@ static void selinux_sk_free_security(str
 	sk_free_security(sk);
 }
 
-static unsigned int selinux_sk_getsid_security(struct sock *sk, struct flowi *fl, u8 dir)
+static void selinux_sk_clone_security(const struct sock *sk, struct sock *newsk)
 {
-	struct inode_security_struct *isec;
-	u32 sock_sid = SECINITSID_ANY_SOCKET;
+	struct sk_security_struct *ssec = sk->sk_security;
+	struct sk_security_struct *newssec = newsk->sk_security;
 
+	newssec->sid = ssec->sid;
+	newssec->peer_sid = ssec->peer_sid;
+}
+
+static unsigned int selinux_sk_getsid_security(struct sock *sk, struct flowi *fl, u8 dir)
+{
 	if (!sk)
 		return selinux_no_sk_sid(fl);
+	else {
+		struct sk_security_struct *sksec = sk->sk_security;
 
-	read_lock_bh(&sk->sk_callback_lock);
-	isec = get_sock_isec(sk);
-
-	if (isec)
-		sock_sid = isec->sid;
-
-	read_unlock_bh(&sk->sk_callback_lock);
-	return sock_sid;
+		return sksec->sid;
+	}
 }
 
 static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
@@ -4608,6 +4611,7 @@ static struct security_operations selinu
 	.socket_getpeersec_dgram =	selinux_socket_getpeersec_dgram,
 	.sk_alloc_security =		selinux_sk_alloc_security,
 	.sk_free_security =		selinux_sk_free_security,
+	.sk_clone_security =		selinux_sk_clone_security,
 	.sk_getsid = 			selinux_sk_getsid_security,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
--- linux-2.6.17.mls/security/selinux/include/objsec.h	2006-07-14 09:57:25.000000000 -0500
+++ linux-2.6.17/security/selinux/include/objsec.h	2006-07-17 10:35:54.000000000 -0500
@@ -99,6 +99,7 @@ struct netif_security_struct {
 
 struct sk_security_struct {
 	struct sock *sk;		/* back pointer to sk object */
+	u32 sid;			/* SID of this object */
 	u32 peer_sid;			/* SID of peer */
 };
 
--- linux-2.6.17.mls/net/core/sock.c	2006-07-14 09:28:31.000000000 -0500
+++ linux-2.6.17/net/core/sock.c	2006-07-17 10:35:54.000000000 -0500
@@ -911,7 +911,7 @@ struct sock *sk_clone(const struct sock 
 	if (newsk != NULL) {
 		struct sk_filter *filter;
 
-		memcpy(newsk, sk, sk->sk_prot->obj_size);
+		sock_copy(newsk, sk);
 
 		/* SANITY */
 		sk_node_init(&newsk->sk_node);
