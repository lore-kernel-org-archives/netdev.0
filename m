From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH v7 02/17] selinux: Cleanup the NetLabel glue code
Date: Mon, 06 Oct 2008 15:19:54 -0400
Message-ID: <20081006191954.15686.56760.stgit@flek.lan>
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

We were doing a lot of extra work in selinux_netlbl_sock_graft() what wasn't
necessary so this patch removes that code.  It also removes the redundant
second argument to selinux_netlbl_sock_setsid() which allows us to simplify a
few other functions.

Signed-off-by: Paul Moore <paul.moore@hp.com>
Acked-by: James Morris <jmorris@namei.org>
---

 security/selinux/netlabel.c |   38 ++++++++++----------------------------
 1 files changed, 10 insertions(+), 28 deletions(-)

diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index 89b4183..b9ce5fc 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -66,22 +66,24 @@ static int selinux_netlbl_sidlookup_cached(struct sk_buff *skb,
 /**
  * selinux_netlbl_sock_setsid - Label a socket using the NetLabel mechanism
  * @sk: the socket to label
- * @sid: the SID to use
  *
  * Description:
- * Attempt to label a socket using the NetLabel mechanism using the given
- * SID.  Returns zero values on success, negative values on failure.
+ * Attempt to label a socket using the NetLabel mechanism.  Returns zero values
+ * on success, negative values on failure.
  *
  */
-static int selinux_netlbl_sock_setsid(struct sock *sk, u32 sid)
+static int selinux_netlbl_sock_setsid(struct sock *sk)
 {
 	int rc;
 	struct sk_security_struct *sksec = sk->sk_security;
 	struct netlbl_lsm_secattr secattr;
 
+	if (sksec->nlbl_state != NLBL_REQUIRE)
+		return 0;
+
 	netlbl_secattr_init(&secattr);
 
-	rc = security_netlbl_sid_to_secattr(sid, &secattr);
+	rc = security_netlbl_sid_to_secattr(sksec->sid, &secattr);
 	if (rc != 0)
 		goto sock_setsid_return;
 	rc = netlbl_sock_setattr(sk, &secattr);
@@ -174,24 +176,10 @@ int selinux_netlbl_skbuff_getsid(struct sk_buff *skb,
  */
 void selinux_netlbl_sock_graft(struct sock *sk, struct socket *sock)
 {
-	struct sk_security_struct *sksec = sk->sk_security;
-	struct netlbl_lsm_secattr secattr;
-	u32 nlbl_peer_sid;
-
-	if (sksec->nlbl_state != NLBL_REQUIRE)
-		return;
-
-	netlbl_secattr_init(&secattr);
-	if (netlbl_sock_getattr(sk, &secattr) == 0 &&
-	    secattr.flags != NETLBL_SECATTR_NONE &&
-	    security_netlbl_secattr_to_sid(&secattr, &nlbl_peer_sid) == 0)
-		sksec->peer_sid = nlbl_peer_sid;
-	netlbl_secattr_destroy(&secattr);
-
 	/* Try to set the NetLabel on the socket to save time later, if we fail
 	 * here we will pick up the pieces in later calls to
 	 * selinux_netlbl_inode_permission(). */
-	selinux_netlbl_sock_setsid(sk, sksec->sid);
+	selinux_netlbl_sock_setsid(sk);
 }
 
 /**
@@ -205,13 +193,7 @@ void selinux_netlbl_sock_graft(struct sock *sk, struct socket *sock)
  */
 int selinux_netlbl_socket_post_create(struct socket *sock)
 {
-	struct sock *sk = sock->sk;
-	struct sk_security_struct *sksec = sk->sk_security;
-
-	if (sksec->nlbl_state != NLBL_REQUIRE)
-		return 0;
-
-	return selinux_netlbl_sock_setsid(sk, sksec->sid);
+	return selinux_netlbl_sock_setsid(sock->sk);
 }
 
 /**
@@ -246,7 +228,7 @@ int selinux_netlbl_inode_permission(struct inode *inode, int mask)
 	local_bh_disable();
 	bh_lock_sock_nested(sk);
 	if (likely(sksec->nlbl_state == NLBL_REQUIRE))
-		rc = selinux_netlbl_sock_setsid(sk, sksec->sid);
+		rc = selinux_netlbl_sock_setsid(sk);
 	else
 		rc = 0;
 	bh_unlock_sock(sk);

