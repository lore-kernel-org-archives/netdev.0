From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH v7 14/17] selinux: Cache NetLabel secattrs in the socket's
	security struct
Date: Mon, 06 Oct 2008 15:21:23 -0400
Message-ID: <20081006192123.15686.71697.stgit@flek.lan>
References: <20081006191516.15686.80823.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20081006191516.15686.80823.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previous work enabled the use of address based NetLabel selectors, which
while highly useful, brought the potential for additional per-packet overhead
when used.  This patch attempts to mitigate some of that overhead by caching
the NetLabel security attribute struct within the SELinux socket security
structure.  This should help eliminate the need to recreate the NetLabel
secattr structure for each packet resulting in less overhead.

Signed-off-by: Paul Moore <paul.moore@hp.com>
Acked-by: James Morris <jmorris@namei.org>
---

 security/selinux/hooks.c            |    1 
 security/selinux/include/netlabel.h |    7 ++
 security/selinux/include/objsec.h   |    7 +-
 security/selinux/netlabel.c         |  115 ++++++++++++++++++++++++-----------
 4 files changed, 91 insertions(+), 39 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 632ac3e..3aa811e 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -291,6 +291,7 @@ static void sk_free_security(struct sock *sk)
 	struct sk_security_struct *ssec = sk->sk_security;
 
 	sk->sk_security = NULL;
+	selinux_netlbl_sk_security_free(ssec);
 	kfree(ssec);
 }
 
diff --git a/security/selinux/include/netlabel.h b/security/selinux/include/netlabel.h
index 982bac0..b913c8d 100644
--- a/security/selinux/include/netlabel.h
+++ b/security/selinux/include/netlabel.h
@@ -41,6 +41,7 @@ void selinux_netlbl_cache_invalidate(void);
 
 void selinux_netlbl_err(struct sk_buff *skb, int error, int gateway);
 
+void selinux_netlbl_sk_security_free(struct sk_security_struct *ssec);
 void selinux_netlbl_sk_security_reset(struct sk_security_struct *ssec,
 				      int family);
 
@@ -77,6 +78,12 @@ static inline void selinux_netlbl_err(struct sk_buff *skb,
 	return;
 }
 
+static inline void selinux_netlbl_sk_security_free(
+					       struct sk_security_struct *ssec)
+{
+	return;
+}
+
 static inline void selinux_netlbl_sk_security_reset(
 					       struct sk_security_struct *ssec,
 					       int family)
diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
index ad34787..f8be8d7 100644
--- a/security/selinux/include/objsec.h
+++ b/security/selinux/include/objsec.h
@@ -109,9 +109,6 @@ struct netport_security_struct {
 };
 
 struct sk_security_struct {
-	u32 sid;			/* SID of this object */
-	u32 peer_sid;			/* SID of peer */
-	u16 sclass;			/* sock security class */
 #ifdef CONFIG_NETLABEL
 	enum {				/* NetLabel state */
 		NLBL_UNSET = 0,
@@ -120,7 +117,11 @@ struct sk_security_struct {
 		NLBL_REQSKB,
 		NLBL_CONNLABELED,
 	} nlbl_state;
+	struct netlbl_lsm_secattr *nlbl_secattr; /* NetLabel sec attributes */
 #endif
+	u32 sid;			/* SID of this object */
+	u32 peer_sid;			/* SID of peer */
+	u16 sclass;			/* sock security class */
 };
 
 struct key_security_struct {
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index b22b7da..f58701a 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -68,6 +68,38 @@ static int selinux_netlbl_sidlookup_cached(struct sk_buff *skb,
 }
 
 /**
+ * selinux_netlbl_sock_genattr - Generate the NetLabel socket secattr
+ * @sk: the socket
+ *
+ * Description:
+ * Generate the NetLabel security attributes for a socket, making full use of
+ * the socket's attribute cache.  Returns a pointer to the security attributes
+ * on success, NULL on failure.
+ *
+ */
+static struct netlbl_lsm_secattr *selinux_netlbl_sock_genattr(struct sock *sk)
+{
+	int rc;
+	struct sk_security_struct *sksec = sk->sk_security;
+	struct netlbl_lsm_secattr *secattr;
+
+	if (sksec->nlbl_secattr != NULL)
+		return sksec->nlbl_secattr;
+
+	secattr = netlbl_secattr_alloc(GFP_ATOMIC);
+	if (secattr == NULL)
+		return NULL;
+	rc = security_netlbl_sid_to_secattr(sksec->sid, secattr);
+	if (rc != 0) {
+		netlbl_secattr_free(secattr);
+		return NULL;
+	}
+	sksec->nlbl_secattr = secattr;
+
+	return secattr;
+}
+
+/**
  * selinux_netlbl_sock_setsid - Label a socket using the NetLabel mechanism
  * @sk: the socket to label
  *
@@ -80,17 +112,15 @@ static int selinux_netlbl_sock_setsid(struct sock *sk)
 {
 	int rc;
 	struct sk_security_struct *sksec = sk->sk_security;
-	struct netlbl_lsm_secattr secattr;
+	struct netlbl_lsm_secattr *secattr;
 
 	if (sksec->nlbl_state != NLBL_REQUIRE)
 		return 0;
 
-	netlbl_secattr_init(&secattr);
-
-	rc = security_netlbl_sid_to_secattr(sksec->sid, &secattr);
-	if (rc != 0)
-		goto sock_setsid_return;
-	rc = netlbl_sock_setattr(sk, &secattr);
+	secattr = selinux_netlbl_sock_genattr(sk);
+	if (secattr == NULL)
+		return -ENOMEM;
+	rc = netlbl_sock_setattr(sk, secattr);
 	switch (rc) {
 	case 0:
 		sksec->nlbl_state = NLBL_LABELED;
@@ -101,8 +131,6 @@ static int selinux_netlbl_sock_setsid(struct sock *sk)
 		break;
 	}
 
-sock_setsid_return:
-	netlbl_secattr_destroy(&secattr);
 	return rc;
 }
 
@@ -137,6 +165,20 @@ void selinux_netlbl_err(struct sk_buff *skb, int error, int gateway)
 }
 
 /**
+ * selinux_netlbl_sk_security_free - Free the NetLabel fields
+ * @sssec: the sk_security_struct
+ *
+ * Description:
+ * Free all of the memory in the NetLabel fields of a sk_security_struct.
+ *
+ */
+void selinux_netlbl_sk_security_free(struct sk_security_struct *ssec)
+{
+	if (ssec->nlbl_secattr != NULL)
+		netlbl_secattr_free(ssec->nlbl_secattr);
+}
+
+/**
  * selinux_netlbl_sk_security_reset - Reset the NetLabel fields
  * @ssec: the sk_security_struct
  * @family: the socket family
@@ -209,7 +251,8 @@ int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
 				 u32 sid)
 {
 	int rc;
-	struct netlbl_lsm_secattr secattr;
+	struct netlbl_lsm_secattr secattr_storage;
+	struct netlbl_lsm_secattr *secattr = NULL;
 	struct sock *sk;
 
 	/* if this is a locally generated packet check to see if it is already
@@ -219,16 +262,21 @@ int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
 		struct sk_security_struct *sksec = sk->sk_security;
 		if (sksec->nlbl_state != NLBL_REQSKB)
 			return 0;
+		secattr = sksec->nlbl_secattr;
+	}
+	if (secattr == NULL) {
+		secattr = &secattr_storage;
+		netlbl_secattr_init(secattr);
+		rc = security_netlbl_sid_to_secattr(sid, secattr);
+		if (rc != 0)
+			goto skbuff_setsid_return;
 	}
 
-	netlbl_secattr_init(&secattr);
-	rc = security_netlbl_sid_to_secattr(sid, &secattr);
-	if (rc != 0)
-		goto skbuff_setsid_return;
-	rc = netlbl_skbuff_setattr(skb, family, &secattr);
+	rc = netlbl_skbuff_setattr(skb, family, secattr);
 
 skbuff_setsid_return:
-	netlbl_secattr_destroy(&secattr);
+	if (secattr == &secattr_storage)
+		netlbl_secattr_destroy(secattr);
 	return rc;
 }
 
@@ -245,18 +293,18 @@ void selinux_netlbl_inet_conn_established(struct sock *sk, u16 family)
 {
 	int rc;
 	struct sk_security_struct *sksec = sk->sk_security;
-	struct netlbl_lsm_secattr secattr;
+	struct netlbl_lsm_secattr *secattr;
 	struct inet_sock *sk_inet = inet_sk(sk);
 	struct sockaddr_in addr;
 
 	if (sksec->nlbl_state != NLBL_REQUIRE)
 		return;
 
-	netlbl_secattr_init(&secattr);
-	if (security_netlbl_sid_to_secattr(sksec->sid, &secattr) != 0)
-		goto inet_conn_established_return;
+	secattr = selinux_netlbl_sock_genattr(sk);
+	if (secattr == NULL)
+		return;
 
-	rc = netlbl_sock_setattr(sk, &secattr);
+	rc = netlbl_sock_setattr(sk, secattr);
 	switch (rc) {
 	case 0:
 		sksec->nlbl_state = NLBL_LABELED;
@@ -266,13 +314,13 @@ void selinux_netlbl_inet_conn_established(struct sock *sk, u16 family)
 		 * labeling protocols */
 		if (family != PF_INET) {
 			sksec->nlbl_state = NLBL_UNSET;
-			goto inet_conn_established_return;
+			return;
 		}
 
 		addr.sin_family = family;
 		addr.sin_addr.s_addr = sk_inet->daddr;
 		if (netlbl_conn_setattr(sk, (struct sockaddr *)&addr,
-					&secattr) != 0) {
+					secattr) != 0) {
 			/* we failed to label the connected socket (could be
 			 * for a variety of reasons, the actual "why" isn't
 			 * important here) so we have to go to our backup plan,
@@ -300,10 +348,6 @@ void selinux_netlbl_inet_conn_established(struct sock *sk, u16 family)
 		 * return an error code */
 		break;
 	}
-
-inet_conn_established_return:
-	netlbl_secattr_destroy(&secattr);
-	return;
 }
 
 /**
@@ -468,13 +512,12 @@ int selinux_netlbl_socket_connect(struct sock *sk, struct sockaddr *addr)
 {
 	int rc;
 	struct sk_security_struct *sksec = sk->sk_security;
-	struct netlbl_lsm_secattr secattr;
+	struct netlbl_lsm_secattr *secattr;
 
 	if (sksec->nlbl_state != NLBL_REQSKB &&
 	    sksec->nlbl_state != NLBL_CONNLABELED)
 		return 0;
 
-	netlbl_secattr_init(&secattr);
 	local_bh_disable();
 	bh_lock_sock_nested(sk);
 
@@ -487,17 +530,17 @@ int selinux_netlbl_socket_connect(struct sock *sk, struct sockaddr *addr)
 		rc = 0;
 		goto socket_connect_return;
 	}
-	rc = security_netlbl_sid_to_secattr(sksec->sid, &secattr);
-	if (rc != 0)
+	secattr = selinux_netlbl_sock_genattr(sk);
+	if (secattr == NULL) {
+		rc = -ENOMEM;
 		goto socket_connect_return;
-	rc = netlbl_conn_setattr(sk, addr, &secattr);
-	if (rc != 0)
-		goto socket_connect_return;
-	sksec->nlbl_state = NLBL_CONNLABELED;
+	}
+	rc = netlbl_conn_setattr(sk, addr, secattr);
+	if (rc == 0)
+		sksec->nlbl_state = NLBL_CONNLABELED;
 
 socket_connect_return:
 	bh_unlock_sock(sk);
 	local_bh_enable();
-	netlbl_secattr_destroy(&secattr);
 	return rc;
 }

