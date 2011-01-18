From: Casey Schaufler <casey@schaufler-ca.com>
Subject: [PATCH] scm: provide full privilege set via SCM_PRIVILEGE
Date: Mon, 17 Jan 2011 16:34:16 -0800
Message-ID: <4D34E008.2020701@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Casey Schaufler <casey@schaufler-ca.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp106.prem.mail.ac4.yahoo.com ([76.13.13.45]:33374 "HELO
	smtp106.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752575Ab1ARAk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 19:40:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Subject: [PATCH] scm: provide full privilege set via SCM_PRIVILEGE

The SCM mechanism currently provides interfaces for delivering
the uid/gid and the "security context" (LSM information) of the
peer on a UDS socket. All of the security credential information
is available, but there is no interface available to obtain it.
Further, the existing interfaces require that the user chose
between the uid/gid and the context as the existing interfaces
are exclusive.

This patch introduces an additional interface that provides
a complete set of security information from the peer credential.
No additional work is required to provide the information
internally, it is all being passed, just not exposed.

Also sent to LKML and LSM lists. 

Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>
---

 include/asm-generic/socket.h |    1 +
 include/linux/net.h          |    1 +
 include/linux/socket.h       |    1 +
 include/net/scm.h            |   80 +++++++++++++++++++++++++++++++++++++++++-
 net/core/sock.c              |   11 ++++++
 5 files changed, 93 insertions(+), 1 deletions(-)
diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 9a6115e..7aa8e84 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -64,4 +64,5 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+#define SO_PASSPRIV		41
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/linux/net.h b/include/linux/net.h
index 16faa13..159a929 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -71,6 +71,7 @@ struct net;
 #define SOCK_NOSPACE		2
 #define SOCK_PASSCRED		3
 #define SOCK_PASSSEC		4
+#define SOCK_PASSPRIV		5
 
 #ifndef ARCH_HAS_SOCKET_TYPES
 /**
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 86b652f..e9cfd68 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -147,6 +147,7 @@ static inline struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct cmsghdr
 #define	SCM_RIGHTS	0x01		/* rw: access rights (array of int) */
 #define SCM_CREDENTIALS 0x02		/* rw: struct ucred		*/
 #define SCM_SECURITY	0x03		/* rw: security label		*/
+#define SCM_PRIVILEGES  0x04		/* rw: privilege set		*/
 
 struct ucred {
 	__u32	pid;
diff --git a/include/net/scm.h b/include/net/scm.h
index 3165650..4b8db21 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -101,6 +101,83 @@ static inline void scm_passec(struct socket *sock, struct msghdr *msg, struct sc
 { }
 #endif /* CONFIG_SECURITY_NETWORK */
 
+static __inline__ void scm_passpriv(struct socket *sock, struct msghdr *msg,
+				struct scm_cookie *scm)
+{
+	const struct cred *credp = scm->cred;
+	const struct group_info *gip;
+	char *result;
+	char *cp;
+	int i;
+#ifdef CONFIG_SECURITY_NETWORK
+	char *secdata;
+	u32 seclen;
+	int err;
+#endif /* CONFIG_SECURITY_NETWORK */
+
+	if (!test_bit(SOCK_PASSPRIV, &sock->flags))
+		return;
+
+	gip = credp->group_info;
+
+	/*
+	 * uid + euid + gid + egid + group-list + capabilities
+	 *     + "uid=" + "euid=" + "gid=" + "egid=" + "grps="
+	 *     + "cap-e=" + "cap-p=" + "cap-i="
+	 * 10  + 10   + 10  + 10   + (ngrps * 10) + ecap + pcap + icap
+	 *     + 4 + 5 + 4 + 5 + 5 + 6 + 6 + 6
+	 */
+	i = ((4 + gip->ngroups) * 11) + (3 * (_KERNEL_CAPABILITY_U32S * 8 + 1))
+		+ 41;
+
+#ifdef CONFIG_SECURITY_NETWORK
+	err = security_secid_to_secctx(scm->secid, &secdata, &seclen);
+	if (!err)
+		/*
+		 * " context="
+		 */
+		i += seclen + 10;
+#endif /* CONFIG_SECURITY_NETWORK */
+
+	result = kzalloc(i, GFP_KERNEL);
+	if (result == NULL)
+		return;
+
+	cp = result + sprintf(result, "euid=%d uid=%d egid=%d gid=%d",
+				credp->euid, credp->uid,
+				credp->egid, credp->gid);
+
+	if (gip != NULL && gip->ngroups > 0) {
+		cp += sprintf(cp, " grps=%d", GROUP_AT(gip, 0));
+		for (i = 1 ; i < gip->ngroups; i++)
+			cp += sprintf(cp, ",%d", GROUP_AT(gip, i));
+	}
+
+	cp += sprintf(cp, " cap-e=");
+	CAP_FOR_EACH_U32(i)
+		cp += sprintf(cp, "%08x", credp->cap_effective.cap[i]);
+	cp += sprintf(cp, " cap-p=");
+	CAP_FOR_EACH_U32(i)
+		cp += sprintf(cp, "%08x", credp->cap_permitted.cap[i]);
+	cp += sprintf(cp, " cap-i=");
+	CAP_FOR_EACH_U32(i)
+		cp += sprintf(cp, "%08x", credp->cap_inheritable.cap[i]);
+
+#ifdef CONFIG_SECURITY_NETWORK
+	cp += sprintf(cp, " context=");
+	strncpy(cp, secdata, seclen);
+	cp += seclen;
+	*cp = '\0';
+
+	security_release_secctx(secdata, seclen);
+#endif /* CONFIG_SECURITY_NETWORK */
+
+	put_cmsg(msg, SOL_SOCKET, SCM_PRIVILEGES, strlen(result)+1, result);
+
+	kfree(result);
+}
+
+
 static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 				struct scm_cookie *scm, int flags)
 {
@@ -114,6 +191,8 @@ static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 	if (test_bit(SOCK_PASSCRED, &sock->flags))
 		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(scm->creds), &scm->creds);
 
+	scm_passpriv(sock, msg, scm);
+
 	scm_destroy_cred(scm);
 
 	scm_passec(sock, msg, scm);
@@ -124,6 +203,5 @@ static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 	scm_detach_fds(msg, scm);
 }
 
-
 #endif /* __LINUX_NET_SCM_H */
 
diff --git a/net/core/sock.c b/net/core/sock.c
index fb60801..f134126 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -725,6 +725,13 @@ set_rcvbuf:
 		else
 			clear_bit(SOCK_PASSSEC, &sock->flags);
 		break;
+
+	case SO_PASSPRIV:
+		if (valbool)
+			set_bit(SOCK_PASSPRIV, &sock->flags);
+		else
+			clear_bit(SOCK_PASSPRIV, &sock->flags);
+		break;
 	case SO_MARK:
 		if (!capable(CAP_NET_ADMIN))
 			ret = -EPERM;
@@ -950,6 +957,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = test_bit(SOCK_PASSSEC, &sock->flags) ? 1 : 0;
 		break;
 
+	case SO_PASSPRIV:
+		v.val = test_bit(SOCK_PASSPRIV, &sock->flags) ? 1 : 0;
+		break;
+
 	case SO_PEERSEC:
 		return security_socket_getpeersec_stream(sock, optval, optlen, len);
 



