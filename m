From: David Miller <davem@davemloft.net>
Subject: Re: Gaah: selinux_socket_unix_stream_connect oops
Date: Wed, 05 Jan 2011 14:25:40 -0800 (PST)
Message-ID: <20110105.142540.245404254.davem@davemloft.net>
References: <AANLkTikPvJLEZetB-CbVSO0VuYLnAQz5y8D_F0HGML=5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeremy@goop.org, jmorris@namei.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52757
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751429Ab1AEWZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 17:25:09 -0500
In-Reply-To: <AANLkTikPvJLEZetB-CbVSO0VuYLnAQz5y8D_F0HGML=5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 5 Jan 2011 08:27:01 -0800

> So I wonder if there is some subtle race that happens when one end of
> a unix domain socket attaches just as another end disconnects?
> Especially as "security_unix_stream_connect()" is called before the
> whole connect sequence is really final. It's generally
> "unix_release()" that sets 'sock->sk' to NULL.
> 
> Btw, why do we pass in "sock" and "other->sk_socket" ("struct
> socket"), when it appears that what the security code really wants to
> get "struct sock" (which would be "sk" and "other" in the caller)? The
> calling convention seems to result in (a) this NULL pointer thing and
> (b) all these extra dereferences.
> 
> Comments? Ideas?

There is nothing which blocks that unix_release() code which sets
socket->sk to NULL, it runs asynchronously to this connect code.

The reason it passes in the socket pointer instead of the pointer to
struct sock is because that's what SMACK wants to use, as it needs to
get at SOCK_INODE().

See, even you think the whole world is SELINUX :-)))

More seriously, we can get at the struct socket via sk->sk_socket in
the SMACK code.  sk->sk_socket, unlike socket->sk, has it's state
change to NULL (via sock_orphen()) protected by unix_state_lock(),
which we hold for "other" in this unix connect code path.

Therefore I propose we fix this like so:

--------------------
af_unix: Avoid socket->sk NULL OOPS in stream connect security hooks.

unix_release() can asynchornously set socket->sk to NULL, and
it does so without holding the unix_state_lock() on "other"
during stream connects.

However, the reverse mapping, sk->sk_socket, is only transitioned
to NULL under the unix_state_lock().

Therefore make the security hooks follow the reverse mapping instead
of the forward mapping.

Reported-by: Jeremy Fitzhardinge <jeremy@goop.org>
Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/security.h b/include/linux/security.h
index fd4d55f..d47a4c2 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -796,8 +796,9 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  * @unix_stream_connect:
  *	Check permissions before establishing a Unix domain stream connection
  *	between @sock and @other.
- *	@sock contains the socket structure.
- *	@other contains the peer socket structure.
+ *	@sock contains the sock structure.
+ *	@other contains the peer sock structure.
+ *	@newsk contains the new sock structure.
  *	Return 0 if permission is granted.
  * @unix_may_send:
  *	Check permissions before connecting or sending datagrams from @sock to
@@ -1568,8 +1569,7 @@ struct security_operations {
 	int (*inode_getsecctx)(struct inode *inode, void **ctx, u32 *ctxlen);
 
 #ifdef CONFIG_SECURITY_NETWORK
-	int (*unix_stream_connect) (struct socket *sock,
-				    struct socket *other, struct sock *newsk);
+	int (*unix_stream_connect) (struct sock *sock, struct sock *other, struct sock *newsk);
 	int (*unix_may_send) (struct socket *sock, struct socket *other);
 
 	int (*socket_create) (int family, int type, int protocol, int kern);
@@ -2525,8 +2525,7 @@ static inline int security_inode_getsecctx(struct inode *inode, void **ctx, u32
 
 #ifdef CONFIG_SECURITY_NETWORK
 
-int security_unix_stream_connect(struct socket *sock, struct socket *other,
-				 struct sock *newsk);
+int security_unix_stream_connect(struct sock *sock, struct sock *other, struct sock *newsk);
 int security_unix_may_send(struct socket *sock,  struct socket *other);
 int security_socket_create(int family, int type, int protocol, int kern);
 int security_socket_post_create(struct socket *sock, int family,
@@ -2567,8 +2566,8 @@ void security_tun_dev_post_create(struct sock *sk);
 int security_tun_dev_attach(struct sock *sk);
 
 #else	/* CONFIG_SECURITY_NETWORK */
-static inline int security_unix_stream_connect(struct socket *sock,
-					       struct socket *other,
+static inline int security_unix_stream_connect(struct sock *sock,
+					       struct sock *other,
 					       struct sock *newsk)
 {
 	return 0;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 417d7a6..dd419d2 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1157,7 +1157,7 @@ restart:
 		goto restart;
 	}
 
-	err = security_unix_stream_connect(sock, other->sk_socket, newsk);
+	err = security_unix_stream_connect(sk, other, newsk);
 	if (err) {
 		unix_state_unlock(sk);
 		goto out_unlock;
diff --git a/security/capability.c b/security/capability.c
index c773635..2a5df2b 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -548,7 +548,7 @@ static int cap_sem_semop(struct sem_array *sma, struct sembuf *sops,
 }
 
 #ifdef CONFIG_SECURITY_NETWORK
-static int cap_unix_stream_connect(struct socket *sock, struct socket *other,
+static int cap_unix_stream_connect(struct sock *sock, struct sock *other,
 				   struct sock *newsk)
 {
 	return 0;
diff --git a/security/security.c b/security/security.c
index 1b798d3..e5fb07a 100644
--- a/security/security.c
+++ b/security/security.c
@@ -977,8 +977,7 @@ EXPORT_SYMBOL(security_inode_getsecctx);
 
 #ifdef CONFIG_SECURITY_NETWORK
 
-int security_unix_stream_connect(struct socket *sock, struct socket *other,
-				 struct sock *newsk)
+int security_unix_stream_connect(struct sock *sock, struct sock *other, struct sock *newsk)
 {
 	return security_ops->unix_stream_connect(sock, other, newsk);
 }
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index c82538a..6f637d2 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3921,18 +3921,18 @@ static int selinux_socket_shutdown(struct socket *sock, int how)
 	return sock_has_perm(current, sock->sk, SOCKET__SHUTDOWN);
 }
 
-static int selinux_socket_unix_stream_connect(struct socket *sock,
-					      struct socket *other,
+static int selinux_socket_unix_stream_connect(struct sock *sock,
+					      struct sock *other,
 					      struct sock *newsk)
 {
-	struct sk_security_struct *sksec_sock = sock->sk->sk_security;
-	struct sk_security_struct *sksec_other = other->sk->sk_security;
+	struct sk_security_struct *sksec_sock = sock->sk_security;
+	struct sk_security_struct *sksec_other = other->sk_security;
 	struct sk_security_struct *sksec_new = newsk->sk_security;
 	struct common_audit_data ad;
 	int err;
 
 	COMMON_AUDIT_DATA_INIT(&ad, NET);
-	ad.u.net.sk = other->sk;
+	ad.u.net.sk = other;
 
 	err = avc_has_perm(sksec_sock->sid, sksec_other->sid,
 			   sksec_other->sclass,
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 489a85a..ccb71a0 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -2408,22 +2408,22 @@ static int smack_setprocattr(struct task_struct *p, char *name,
 
 /**
  * smack_unix_stream_connect - Smack access on UDS
- * @sock: one socket
- * @other: the other socket
+ * @sock: one sock
+ * @other: the other sock
  * @newsk: unused
  *
  * Return 0 if a subject with the smack of sock could access
  * an object with the smack of other, otherwise an error code
  */
-static int smack_unix_stream_connect(struct socket *sock,
-				     struct socket *other, struct sock *newsk)
+static int smack_unix_stream_connect(struct sock *sock,
+				     struct sock *other, struct sock *newsk)
 {
-	struct inode *sp = SOCK_INODE(sock);
-	struct inode *op = SOCK_INODE(other);
+	struct inode *sp = SOCK_INODE(sock->sk_socket);
+	struct inode *op = SOCK_INODE(other->sk_socket);
 	struct smk_audit_info ad;
 
 	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_NET);
-	smk_ad_setfield_u_net_sk(&ad, other->sk);
+	smk_ad_setfield_u_net_sk(&ad, other);
 	return smk_access(smk_of_inode(sp), smk_of_inode(op),
 				 MAY_READWRITE, &ad);
 }
