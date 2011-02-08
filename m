From: Casey Schaufler <casey@schaufler-ca.com>
Subject: [PATCH] net: provide capability and group sets via SCM
Date: Tue, 08 Feb 2011 14:28:27 -0800
Message-ID: <4D51C38B.1060902@schaufler-ca.com>
References: <4D3466BD.10500@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	"Sakkinen Jarkko.2 \(EXT-Tieto/Tampere\)"
	<ext-jarkko.2.sakkinen@nokia.com>,
	Janne Karhunen <Janne.Karhunen@nokia.com>,
	"Reshetova Elena \(Nokia-D/Helsinki\)" <elena.reshetova@nokia.com>
To: LKLM <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D3466BD.10500@schaufler-ca.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Subject: [PATCH] net: provide group lists and capability set via CMSG

Provide the namespace converted group list of the peer
process using the SCM mechanism. Provide the capability
set of the peer process. The capability set is not
namespace converted on the assumption that there is no
such conversion available or required.

Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>
---
 include/asm-generic/socket.h |    4 ++
 include/linux/net.h          |    2 +
 include/linux/socket.h       |   18 +++++++++
 include/net/scm.h            |   33 +++++++++++++++++
 net/core/sock.c              |   82 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 139 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 9a6115e..fc2d609 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -64,4 +64,8 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+
+#define SO_PASSGROUPS		41
+#define SO_PASSCAPS		42
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/linux/net.h b/include/linux/net.h
index 16faa13..929e241 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -71,6 +71,8 @@ struct net;
 #define SOCK_NOSPACE		2
 #define SOCK_PASSCRED		3
 #define SOCK_PASSSEC		4
+#define SOCK_PASSGROUPS		5
+#define SOCK_PASSCAPS		6
 
 #ifndef ARCH_HAS_SOCKET_TYPES
 /**
diff --git a/include/linux/socket.h b/include/linux/socket.h
index edbb1d0..63f64f0 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -23,6 +23,7 @@ struct __kernel_sockaddr_storage {
 #include <linux/uio.h>			/* iovec support		*/
 #include <linux/types.h>		/* pid_t			*/
 #include <linux/compiler.h>		/* __user			*/
+#include <linux/capability.h>		/* _KERNEL_CAPABILITY_U32S	*/
 
 struct pid;
 struct cred;
@@ -145,6 +146,8 @@ static inline struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct cmsghdr
 #define	SCM_RIGHTS	0x01		/* rw: access rights (array of int) */
 #define SCM_CREDENTIALS 0x02		/* rw: struct ucred		*/
 #define SCM_SECURITY	0x03		/* rw: security label		*/
+#define SCM_GROUPS	0x04		/* rw: group list		*/
+#define SCM_CAPS	0x05		/* rw: capability set		*/
 
 struct ucred {
 	__u32	pid;
@@ -152,6 +155,16 @@ struct ucred {
 	__u32	gid;
 };
 
+struct scm_groups {
+	__u32	count;
+	__u32	gids[0];
+};
+
+struct scm_capabilities {
+	struct __user_cap_data_struct caps[_KERNEL_CAPABILITY_U32S];
+};
+
+
 /* Supported address families. */
 #define AF_UNSPEC	0
 #define AF_UNIX		1	/* Unix domain sockets 		*/
@@ -313,6 +326,11 @@ struct ucred {
 #define IPX_TYPE	1
 
 extern void cred_to_ucred(struct pid *pid, const struct cred *cred, struct ucred *ucred);
+extern void cred_to_scm_groups(const struct cred *cred,
+				struct scm_groups **sgp, int *size);
+extern void cred_to_scm_capabilities(const struct cred *cred,
+					struct scm_capabilities **scp,
+					int *size);
 
 extern int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
 extern int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
diff --git a/include/net/scm.h b/include/net/scm.h
index 745460f..b263867 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -102,6 +102,36 @@ static inline void scm_passec(struct socket *sock, struct msghdr *msg, struct sc
 { }
 #endif /* CONFIG_SECURITY_NETWORK */
 
+static inline void scm_passgroups(struct socket *sock, struct msghdr *msg,
+					struct scm_cookie *scm)
+{
+	struct scm_groups *data;
+	int size = 0;
+
+	if (test_bit(SOCK_PASSGROUPS, &sock->flags)) {
+		cred_to_scm_groups(scm->cred, &data, &size);
+		if (size) {
+			put_cmsg(msg, SOL_SOCKET, SCM_GROUPS, size, data);
+			kfree(data);
+		}
+	}
+}
+
+static inline void scm_passcaps(struct socket *sock, struct msghdr *msg,
+				struct scm_cookie *scm)
+{
+	struct scm_capabilities *data;
+	int size = 0;
+
+	if (test_bit(SOCK_PASSCAPS, &sock->flags)) {
+		cred_to_scm_capabilities(scm->cred, &data, &size);
+		if (size) {
+			put_cmsg(msg, SOL_SOCKET, SCM_CAPS, size, data);
+			kfree(data);
+		}
+	}
+}
+
 static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 				struct scm_cookie *scm, int flags)
 {
@@ -115,6 +145,9 @@ static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 	if (test_bit(SOCK_PASSCRED, &sock->flags))
 		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(scm->creds), &scm->creds);
 
+	scm_passgroups(sock, msg, scm);
+	scm_passcaps(sock, msg, scm);
+
 	scm_destroy_cred(scm);
 
 	scm_passec(sock, msg, scm);
diff --git a/net/core/sock.c b/net/core/sock.c
index 7dfed79..80eb5d7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -648,6 +648,20 @@ set_rcvbuf:
 			clear_bit(SOCK_PASSCRED, &sock->flags);
 		break;
 
+	case SO_PASSGROUPS:
+		if (valbool)
+			set_bit(SOCK_PASSGROUPS, &sock->flags);
+		else
+			clear_bit(SOCK_PASSGROUPS, &sock->flags);
+		break;
+
+	case SO_PASSCAPS:
+		if (valbool)
+			set_bit(SOCK_PASSCAPS, &sock->flags);
+		else
+			clear_bit(SOCK_PASSCAPS, &sock->flags);
+		break;
+
 	case SO_TIMESTAMP:
 	case SO_TIMESTAMPNS:
 		if (valbool)  {
@@ -764,6 +778,66 @@ void cred_to_ucred(struct pid *pid, const struct cred *cred,
 }
 EXPORT_SYMBOL_GPL(cred_to_ucred);
 
+void cred_to_scm_groups(const struct cred *cred,
+			struct scm_groups **scm_groups, int *size)
+{
+	struct user_namespace *current_ns;
+	struct scm_groups *sgp;
+	struct group_info *gip;
+	int bytes;
+	int i;
+
+	if (!cred || !scm_groups)
+		return;
+
+	gip = cred->group_info;
+	if (gip == NULL)
+		return;
+
+	bytes = sizeof(struct scm_groups) + gip->ngroups * sizeof(__u32);
+	sgp = kmalloc(bytes, GFP_KERNEL);
+	if (sgp == NULL) {
+		*scm_groups = NULL;
+		*size = 0;
+		return;
+	}
+
+	current_ns = current_user_ns();
+
+	for (i = 0 ; i < gip->ngroups; i++)
+		sgp->gids[i] = user_ns_map_gid(current_ns, cred,
+						GROUP_AT(gip, i));
+	sgp->count = gip->ngroups;
+	*scm_groups = sgp;
+	*size = bytes;
+}
+EXPORT_SYMBOL_GPL(cred_to_scm_groups);
+
+void cred_to_scm_capabilities(const struct cred *cred,
+				struct scm_capabilities **scm_caps, int *size)
+{
+	struct scm_capabilities *scp;
+	int i;
+
+	if (!cred || !scm_caps)
+		return;
+
+	scp = kmalloc(sizeof(struct scm_capabilities), GFP_KERNEL);
+	if (!scp) {
+		*scm_caps = NULL;
+		*size = 0;
+		return;
+	}
+	for (i = 0; i < _LINUX_CAPABILITY_U32S_3; i++) {
+		scp->caps[i].permitted = cred->cap_permitted.cap[i];
+		scp->caps[i].effective = cred->cap_effective.cap[i];
+		scp->caps[i].inheritable = cred->cap_inheritable.cap[i];
+	}
+	*scm_caps = scp;
+	*size = sizeof(struct scm_capabilities);
+}
+EXPORT_SYMBOL_GPL(cred_to_scm_capabilities);
+
 int sock_getsockopt(struct socket *sock, int level, int optname,
 		    char __user *optval, int __user *optlen)
 {
@@ -915,6 +989,14 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = test_bit(SOCK_PASSCRED, &sock->flags) ? 1 : 0;
 		break;
 
+	case SO_PASSGROUPS:
+		v.val = test_bit(SOCK_PASSGROUPS, &sock->flags) ? 1 : 0;
+		break;
+
+	case SO_PASSCAPS:
+		v.val = test_bit(SOCK_PASSCAPS, &sock->flags) ? 1 : 0;
+		break;
+
 	case SO_PEERCRED:
 	{
 		struct ucred peercred;
