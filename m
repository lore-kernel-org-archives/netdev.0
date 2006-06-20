From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 03/06] MLSXFRM: Add security sid to sock
Date: Tue, 20 Jun 2006 13:23:50 -0500
Message-ID: <44983D36.8070609@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:51640 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1750772AbWFTSYC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 14:24:02 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds security for IP sockets at the sock level. Security at the
sock level is needed to enforce the SELinux security policy for security
associations even when a sock is orphaned (such as in the TCP LAST_ACK state).

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---

 include/linux/security.h          |   12 ++++++++++++
 include/net/sock.h                |    9 +++++++++
 net/core/sock.c                   |    2 +-
 security/dummy.c                  |    5 +++++
 security/selinux/hooks.c          |   26 ++++++++++++++++++++------
 security/selinux/include/objsec.h |    1 +
 6 files changed, 48 insertions(+), 7 deletions(-)

--- linux-2.6.16.vanilla/include/linux/security.h	2006-06-12 17:49:31.000000000 -0500
+++ linux-2.6.16/include/linux/security.h	2006-06-19 19:48:24.000000000 -0500
@@ -799,6 +800,8 @@ struct swap_info_struct;
  *      which is used to copy security attributes between local stream sockets.
  * @sk_free_security:
  *	Deallocate security structure.
+ * @sk_clone_security:
+ *	Clone/copy security structure.
  * @sk_getsid:
  *	Retrieve the LSM-specific sid for the sock to enable caching of network
  *	authorizations.
@@ -1303,6 +1323,7 @@ struct security_operations {
 	int (*socket_getpeersec_dgram) (struct sk_buff *skb, char **secdata, u32 *seclen);
 	int (*sk_alloc_security) (struct sock *sk, int family, gfp_t priority);
 	void (*sk_free_security) (struct sock *sk);
+	void (*sk_clone_security) (const struct sock *sk, struct sock *newsk);
 	unsigned int (*sk_getsid) (struct sock *sk, struct flowi *fl, u8 dir);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
@@ -2809,6 +2836,11 @@ static inline void security_sk_free(stru
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
@@ -2936,6 +2968,10 @@ static inline void security_sk_free(stru
 {
 }
 
+static inline void security_sk_clone(const struct sock *sk, struct sock *newsk)
+{
+}
+
 static inline unsigned int security_sk_sid(struct sock *sk, struct flowi *fl, u8 dir)
 {
 	return 0;
--- linux-2.6.16.vanilla/include/net/sock.h	2006-06-19 17:02:23.000000000 -0500
+++ linux-2.6.16/include/net/sock.h	2006-06-19 19:48:24.000000000 -0500
@@ -964,6 +964,15 @@ static inline void sock_graft(struct soc
 	write_unlock_bh(&sk->sk_callback_lock);
 }
 
+static inline void sock_copy(struct sock *nsk, const struct sock *osk)
+{
+	void *sptr = nsk->sk_security;
+
+	memcpy(nsk, osk, osk->sk_prot->obj_size);
+	nsk->sk_security = sptr;
+	security_sk_clone(osk, nsk);
+}
+
 extern int sock_i_uid(struct sock *sk);
 extern unsigned long sock_i_ino(struct sock *sk);
 
--- linux-2.6.16.vanilla/net/core/sock.c	2006-06-12 17:49:39.000000000 -0500
+++ linux-2.6.16/net/core/sock.c	2006-06-19 19:48:24.000000000 -0500
@@ -841,7 +841,7 @@ struct sock *sk_clone(const struct sock 
 	if (newsk != NULL) {
 		struct sk_filter *filter;
 
-		memcpy(newsk, sk, sk->sk_prot->obj_size);
+		sock_copy(newsk, sk);
 
 		/* SANITY */
 		sk_node_init(&newsk->sk_node);
--- linux-2.6.16.vanilla/security/dummy.c	2006-06-12 17:49:44.000000000 -0500
+++ linux-2.6.16/security/dummy.c	2006-06-19 19:50:12.000000000 -0500
@@ -794,6 +794,10 @@ static inline void dummy_sk_free_securit
 {
 }
 
+static inline void dummy_sk_clone_security (const struct sock *sk, struct sock *newsk)
+{
+}
+
 static unsigned int dummy_sk_getsid(struct sock *sk, struct flowi *fl, u8 dir)
 {
 	return 0;
@@ -1034,6 +1056,7 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, socket_getpeersec_dgram);
 	set_to_dummy_if_null(ops, sk_alloc_security);
 	set_to_dummy_if_null(ops, sk_free_security);
+	set_to_dummy_if_null(ops, sk_clone_security);
 	set_to_dummy_if_null(ops, sk_getsid);
  #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef  CONFIG_SECURITY_NETWORK_XFRM
--- linux-2.6.16.vanilla/security/selinux/hooks.c	2006-06-12 17:49:44.000000000 -0500
+++ linux-2.6.16/security/selinux/hooks.c	2006-06-19 19:48:24.000000000 -0500
@@ -268,15 +268,13 @@ static int sk_alloc_security(struct sock
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
@@ -286,9 +284,6 @@ static void sk_free_security(struct sock
 {
 	struct sk_security_struct *ssec = sk->sk_security;
 
-	if (sk->sk_family != PF_UNIX)
-		return;
-
 	sk->sk_security = NULL;
 	kfree(ssec);
 }
@@ -2939,6 +2934,7 @@ static void selinux_socket_post_create(s
 {
 	struct inode_security_struct *isec;
 	struct task_security_struct *tsec;
+	struct sk_security_struct *sksec;
 
 	isec = SOCK_INODE(sock)->i_security;
 
@@ -2947,6 +2943,10 @@ static void selinux_socket_post_create(s
 	isec->sid = kern ? SECINITSID_KERNEL : tsec->sid;
 	isec->initialized = 1;
 
+	if (sock->sk) {
+		sksec = sock->sk->sk_security;
+		sksec->sid = isec->sid;
+	}
 	return;
 }
 
@@ -3420,6 +3420,15 @@ static void selinux_sk_free_security(str
 	sk_free_security(sk);
 }
 
+static void selinux_sk_clone_security(const struct sock *sk, struct sock *newsk)
+{
+	struct sk_security_struct *ssec = sk->sk_security;
+	struct sk_security_struct *newssec = newsk->sk_security;
+
+	newssec->sid = ssec->sid;
+	newssec->peer_sid = ssec->peer_sid;
+}
+
 static unsigned int selinux_sk_getsid_security(struct sock *sk, struct flowi *fl, u8 dir)
 {
 	struct inode_security_struct *isec;
@@ -3433,6 +3442,10 @@ static unsigned int selinux_sk_getsid_se
 
 	if (isec)
 		sock_sid = isec->sid;
+	else {
+		struct sk_security_struct *sksec = sk->sk_security;
+		sock_sid = sksec->sid;
+	}
 
 	read_unlock_bh(&sk->sk_callback_lock);
 	return sock_sid;
@@ -4451,6 +4464,7 @@ static struct security_operations selinu
 	.socket_getpeersec_dgram =	selinux_socket_getpeersec_dgram,
 	.sk_alloc_security =		selinux_sk_alloc_security,
 	.sk_free_security =		selinux_sk_free_security,
+	.sk_clone_security =		selinux_sk_clone_security,
 	.sk_getsid = 			selinux_sk_getsid_security,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
--- linux-2.6.16.vanilla/security/selinux/include/objsec.h	2006-06-12 17:49:44.000000000 -0500
+++ linux-2.6.16/security/selinux/include/objsec.h	2006-06-19 19:48:24.000000000 -0500
@@ -96,6 +96,7 @@ struct netif_security_struct {
 
 struct sk_security_struct {
 	struct sock *sk;		/* back pointer to sk object */
+	u32 sid;			/* SID of this object */
 	u32 peer_sid;			/* SID of peer */
 };
 
