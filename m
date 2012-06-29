From: Vincent Sanders <vincent.sanders@collabora.co.uk>
Subject: [PATCH net-next 04/15] security: Add Linux Security Modules hook for AF_BUS sockets
Date: Fri, 29 Jun 2012 17:45:43 +0100
Message-ID: <1340988354-26981-5-git-send-email-vincent.sanders@collabora.co.uk>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Cc: Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>

AF_BUS implements a security hook bus_connect() to be used by LSM to
enforce connectivity security policies.

Signed-off-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Signed-off-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
---
 include/linux/security.h |   11 +++++++++++
 security/capability.c    |    7 +++++++
 security/security.c      |    7 +++++++
 3 files changed, 25 insertions(+)

diff --git a/include/linux/security.h b/include/linux/security.h
index 4e5a73c..d30dc4a 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1578,6 +1578,8 @@ struct security_operations {
 
 #ifdef CONFIG_SECURITY_NETWORK
 	int (*unix_stream_connect) (struct sock *sock, struct sock *other, struct sock *newsk);
+	int (*bus_connect) (struct sock *sock, struct sock *other,
+			    struct sock *newsk);
 	int (*unix_may_send) (struct socket *sock, struct socket *other);
 
 	int (*socket_create) (int family, int type, int protocol, int kern);
@@ -2519,6 +2521,8 @@ static inline int security_inode_getsecctx(struct inode *inode, void **ctx, u32
 #ifdef CONFIG_SECURITY_NETWORK
 
 int security_unix_stream_connect(struct sock *sock, struct sock *other, struct sock *newsk);
+int security_bus_connect(struct sock *sock, struct sock *other,
+			 struct sock *newsk);
 int security_unix_may_send(struct socket *sock,  struct socket *other);
 int security_socket_create(int family, int type, int protocol, int kern);
 int security_socket_post_create(struct socket *sock, int family,
@@ -2566,6 +2570,13 @@ static inline int security_unix_stream_connect(struct sock *sock,
 	return 0;
 }
 
+static inline int security_bus_connect(struct socket *sock,
+				       struct sock *other,
+				       struct sock *newsk)
+{
+	return 0;
+}
+
 static inline int security_unix_may_send(struct socket *sock,
 					 struct socket *other)
 {
diff --git a/security/capability.c b/security/capability.c
index 61095df..ea57f2b 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -563,6 +563,12 @@ static int cap_unix_may_send(struct socket *sock, struct socket *other)
 	return 0;
 }
 
+static int cap_bus_connect(struct sock *sock, struct sock *other,
+			   struct sock *newsk)
+{
+	return 0;
+}
+
 static int cap_socket_create(int family, int type, int protocol, int kern)
 {
 	return 0;
@@ -1016,6 +1022,7 @@ void __init security_fixup_ops(struct security_operations *ops)
 #ifdef CONFIG_SECURITY_NETWORK
 	set_to_cap_if_null(ops, unix_stream_connect);
 	set_to_cap_if_null(ops, unix_may_send);
+	set_to_cap_if_null(ops, bus_connect);
 	set_to_cap_if_null(ops, socket_create);
 	set_to_cap_if_null(ops, socket_post_create);
 	set_to_cap_if_null(ops, socket_bind);
diff --git a/security/security.c b/security/security.c
index 3efc9b1..00ab7df 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1059,6 +1059,13 @@ int security_unix_may_send(struct socket *sock,  struct socket *other)
 }
 EXPORT_SYMBOL(security_unix_may_send);
 
+int security_bus_connect(struct sock *sock, struct sock *other,
+				struct sock *newsk)
+{
+	return security_ops->bus_connect(sock, other, newsk);
+}
+EXPORT_SYMBOL(security_bus_connect);
+
 int security_socket_create(int family, int type, int protocol, int kern)
 {
 	return security_ops->socket_create(family, type, protocol, kern);
-- 
1.7.10
