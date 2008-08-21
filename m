From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v3 10/13] selinux: Cache NetLabel secattrs in the socket's
	security struct
Date: Thu, 21 Aug 2008 17:26:56 -0400
Message-ID: <20080821212656.7951.76138.stgit@flek.lan>
References: <20080821210239.7951.59652.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:40297 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755308AbYHUV1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 17:27:00 -0400
In-Reply-To: <20080821210239.7951.59652.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previous work enabled the use of address based NetLabel selectors, which
while highly useful, brought the potential for additional per-packet overhead
when used.  This patch attempts to mitigate some of that overhead by caching
the NetLabel security attribute struct within the SELinux socket security
structure.  This should help eliminate the need to recreate the NetLabel
secattr structure for each packet resulting in less overhead.

Signed-off-by: XXX
---

 security/selinux/hooks.c            |    1 
 security/selinux/include/netlabel.h |    7 ++
 security/selinux/include/objsec.h   |    7 +-
 security/selinux/netlabel.c         |  101 ++++++++++++++++++++++++++---------
 4 files changed, 86 insertions(+), 30 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index a78d64a..ecd449a 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -291,6 +291,7 @@ static void sk_free_security(struct sock *sk)
 	struct sk_security_struct *ssec = sk->sk_security;
 
 	sk->sk_security = NULL;
+	selinux_netlbl_sk_security_free(ssec);
 	kfree(ssec);
 }
 
diff --git a/security/selinux/include/netlabel.h b/security/selinux/include/netlabel.h
index 1f7cf39..ddec333 100644
--- a/security/selinux/include/netlabel.h
+++ b/security/selinux/include/netlabel.h
@@ -41,6 +41,7 @@ void selinux_netlbl_cache_invalidate(void);
 
 void selinux_netlbl_err(struct sk_buff *skb, int error, int gateway);
 
+void selinux_netlbl_sk_security_free(struct sk_security_struct *ssec);
 void selinux_netlbl_sk_security_reset(struct sk_security_struct *ssec,
 				      int family);
 
@@ -77,6 +78,12 @@ static inline void void selinux_netlbl_err(struct sk_buff *skb,
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
index 46fd1a4..5c9271a 100644
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
 		NLBL_CONNLABELED
 	} nlbl_state;
+	struct netlbl_lsm_secattr *nlbl_secattr; /* NetLabel sec attributes */
 #endif
+	u32 sid;			/* SID of this object */
+	u32 peer_sid;			/* SID of peer */
+	u16 sclass;			/* sock security class */
 };
 
 struct key_security_struct {
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index 30c49d2..5a1701c 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -64,6 +64,40 @@ static int selinux_netlbl_sidlookup_cached(struct sk_buff *skb,
 }
 
 /**
+ * selinux_netlbl_sock_getattr - Get the NetLabel socket security attributes
+ * @sk: the socket
+ * @sid: the socket's SID
+ *
+ * Description:
+ * Generate the NetLabel security attributes for a socket, making full use of
+ * the socket's attribute cache.  Returns a pointer to the security attributes
+ * on success, negative values on failure.
+ *
+ */
+static struct netlbl_lsm_secattr *selinux_netlbl_sock_getattr(struct sock *sk,
+							      u32 sid)
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
+	rc = security_netlbl_sid_to_secattr(sid, secattr);
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
  * @sid: the SID to use
@@ -77,14 +111,13 @@ static int selinux_netlbl_sock_setsid(struct sock *sk, u32 sid)
 {
 	int rc;
 	struct sk_security_struct *sksec = sk->sk_security;
-	struct netlbl_lsm_secattr secattr;
+	struct netlbl_lsm_secattr *secattr;
 
-	netlbl_secattr_init(&secattr);
+	secattr = selinux_netlbl_sock_getattr(sk, sid);
+	if (secattr == NULL)
+		return -ENOMEM;
 
-	rc = security_netlbl_sid_to_secattr(sid, &secattr);
-	if (rc != 0)
-		goto sock_setsid_return;
-	rc = netlbl_sock_setattr(sk, &secattr);
+	rc = netlbl_sock_setattr(sk, secattr);
 	switch (rc) {
 	case 0:
 		sksec->nlbl_state = NLBL_LABELED;
@@ -95,8 +128,6 @@ static int selinux_netlbl_sock_setsid(struct sock *sk, u32 sid)
 		break;
 	}
 
-sock_setsid_return:
-	netlbl_secattr_destroy(&secattr);
 	return rc;
 }
 
@@ -115,7 +146,7 @@ int selinux_netlbl_conn_setsid(struct sock *sk,
 {
 	int rc;
 	struct sk_security_struct *sksec = sk->sk_security;
-	struct netlbl_lsm_secattr secattr;
+	struct netlbl_lsm_secattr *secattr;
 
 	if (sksec->nlbl_state != NLBL_REQSKB ||
 	    sksec->nlbl_state != NLBL_CONNLABELED)
@@ -130,18 +161,14 @@ int selinux_netlbl_conn_setsid(struct sock *sk,
 		return 0;
 	}
 
-	netlbl_secattr_init(&secattr);
+	secattr = selinux_netlbl_sock_getattr(sk, sksec->sid);
+	if (secattr == NULL)
+		return -ENOMEM;
+
+	rc = netlbl_conn_setattr(sk, addr, secattr);
+	if (rc == 0)
+		sksec->nlbl_state = NLBL_CONNLABELED;
 
-	rc = security_netlbl_sid_to_secattr(sksec->sid, &secattr);
-	if (rc != 0)
-		goto conn_setsid_return;
-	rc = netlbl_conn_setattr(sk, addr, &secattr);
-	if (rc != 0)
-		goto conn_setsid_return;
-	sksec->nlbl_state = NLBL_CONNLABELED;
-	
-conn_setsid_return:
-	netlbl_secattr_destroy(&secattr);
 	return rc;
 }
 
@@ -176,6 +203,20 @@ void selinux_netlbl_err(struct sk_buff *skb, int error, int gateway)
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
@@ -248,7 +289,8 @@ int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
 				 u32 sid)
 {
 	int rc;
-	struct netlbl_lsm_secattr secattr;
+	struct netlbl_lsm_secattr secattr_storage;
+	struct netlbl_lsm_secattr *secattr = NULL;
 	struct sock *sk;
 
 	/* if this is a locally generated packet check to see if it is already
@@ -258,16 +300,21 @@ int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
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
 

