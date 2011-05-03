From: Samir Bellabes <sam@synack.fr>
Subject: [RFC v3 01/10] lsm: add security_socket_closed()
Date: Tue,  3 May 2011 16:24:14 +0200
Message-ID: <1304432663-1575-2-git-send-email-sam@synack.fr>
References: <1304432663-1575-1-git-send-email-sam@synack.fr>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Grzegorz Nosek <root@localdomain.pl>,
	Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304432663-1575-1-git-send-email-sam@synack.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow a module to update security informations when a socket is closed.

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 include/linux/security.h |   10 ++++++++++
 net/socket.c             |    1 +
 security/capability.c    |    5 +++++
 security/security.c      |    5 +++++
 4 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index ca02f17..da0d59e 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -918,6 +918,9 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@sock contains the socket structure.
  *	@how contains the flag indicating how future sends and receives are handled.
  *	Return 0 if permission is granted.
+ * @socket_close:
+ *	Allow a module to update security informations when a socket is closed
+ *	@sock is closed.
  * @socket_sock_rcv_skb:
  *	Check permissions on incoming network packets.  This hook is distinct
  *	from Netfilter's IP input hooks since it is the first time that the
@@ -1593,6 +1596,7 @@ struct security_operations {
 	int (*socket_getsockopt) (struct socket *sock, int level, int optname);
 	int (*socket_setsockopt) (struct socket *sock, int level, int optname);
 	int (*socket_shutdown) (struct socket *sock, int how);
+	void (*socket_close) (struct socket *sock);
 	int (*socket_sock_rcv_skb) (struct sock *sk, struct sk_buff *skb);
 	int (*socket_getpeersec_stream) (struct socket *sock, char __user *optval, int __user *optlen, unsigned len);
 	int (*socket_getpeersec_dgram) (struct socket *sock, struct sk_buff *skb, u32 *secid);
@@ -2559,6 +2563,7 @@ int security_socket_getpeername(struct socket *sock);
 int security_socket_getsockopt(struct socket *sock, int level, int optname);
 int security_socket_setsockopt(struct socket *sock, int level, int optname);
 int security_socket_shutdown(struct socket *sock, int how);
+void security_socket_close(struct socket *sock);
 int security_sock_rcv_skb(struct sock *sk, struct sk_buff *skb);
 int security_socket_getpeersec_stream(struct socket *sock, char __user *optval,
 				      int __user *optlen, unsigned len);
@@ -2674,6 +2679,11 @@ static inline int security_socket_shutdown(struct socket *sock, int how)
 {
 	return 0;
 }
+
+static inline void security_socket_close(struct socket *sock)
+{
+}
+
 static inline int security_sock_rcv_skb(struct sock *sk,
 					struct sk_buff *skb)
 {
diff --git a/net/socket.c b/net/socket.c
index 310d16b..d588e9e 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1093,6 +1093,7 @@ static int sock_close(struct inode *inode, struct file *filp)
 		printk(KERN_DEBUG "sock_close: NULL inode\n");
 		return 0;
 	}
+	security_socket_close(SOCKET_I(inode));
 	sock_release(SOCKET_I(inode));
 	return 0;
 }
diff --git a/security/capability.c b/security/capability.c
index 2984ea4..1f8bbe2 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -629,6 +629,10 @@ static int cap_socket_shutdown(struct socket *sock, int how)
 	return 0;
 }
 
+static void cap_socket_close(struct socket *sock)
+{
+}
+
 static int cap_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	return 0;
@@ -1025,6 +1029,7 @@ void __init security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, socket_setsockopt);
 	set_to_cap_if_null(ops, socket_getsockopt);
 	set_to_cap_if_null(ops, socket_shutdown);
+	set_to_cap_if_null(ops, socket_close);
 	set_to_cap_if_null(ops, socket_sock_rcv_skb);
 	set_to_cap_if_null(ops, socket_getpeersec_stream);
 	set_to_cap_if_null(ops, socket_getpeersec_dgram);
diff --git a/security/security.c b/security/security.c
index 1011423..84187d8 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1074,6 +1074,11 @@ int security_socket_shutdown(struct socket *sock, int how)
 	return security_ops->socket_shutdown(sock, how);
 }
 
+void security_socket_close(struct socket *sock)
+{
+	return security_ops->socket_close(sock);
+}
+
 int security_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	return security_ops->socket_sock_rcv_skb(sk, skb);
-- 
1.7.4.1
