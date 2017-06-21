From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v2] net: introduce SO_PEERGROUPS getsockopt
Date: Wed, 21 Jun 2017 10:47:15 +0200
Message-ID: <20170621084715.17772-1-dh.herrmann@gmail.com>
Cc: Tom Gundersen <teg@jklm.no>, David Miller <davem@davemloft.net>,
        David Herrmann <dh.herrmann@gmail.com>,
        Michal Sekletar <msekleta@redhat.com>,
        Simon McVittie <simon.mcvittie@collabora.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34208 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdFUIrw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 04:47:52 -0400
Received: by mail-wr0-f195.google.com with SMTP id y25so22387978wrd.1
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 01:47:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the new getsockopt(2) option SO_PEERGROUPS on SOL_SOCKET to
retrieve the auxiliary groups of the remote peer. It is designed to
naturally extend SO_PEERCRED. That is, the underlying data is from the
same credentials. Regarding its syntax, it is based on SO_PEERSEC. That
is, if the provided buffer is too small, ERANGE is returned and @optlen
is updated. Otherwise, the information is copied, @optlen is set to the
actual size, and 0 is returned.

While SO_PEERCRED (and thus `struct ucred') already returns the primary
group, it lacks the auxiliary group vector. However, nearly all access
controls (including kernel side VFS and SYSVIPC, but also user-space
polkit, DBus, ...) consider the entire set of groups, rather than just
the primary group. But this is currently not possible with pure
SO_PEERCRED. Instead, user-space has to work around this and query the
system database for the auxiliary groups of a UID retrieved via
SO_PEERCRED.

Unfortunately, there is no race-free way to query the auxiliary groups
of the PID/UID retrieved via SO_PEERCRED. Hence, the current user-space
solution is to use getgrouplist(3p), which itself falls back to NSS and
whatever is configured in nsswitch.conf(3). This effectively checks
which groups we *would* assign to the user if it logged in *now*. On
normal systems it is as easy as reading /etc/group, but with NSS it can
resort to quering network databases (eg., LDAP), using IPC or network
communication.

Long story short: Whenever we want to use auxiliary groups for access
checks on IPC, we need further IPC to talk to the user/group databases,
rather than just relying on SO_PEERCRED and the incoming socket. This
is unfortunate, and might even result in dead-locks if the database
query uses the same IPC as the original request.

So far, those recursions / dead-locks have been avoided by using
primitive IPC for all crucial NSS modules. However, we want to avoid
re-inventing the wheel for each NSS module that might be involved in
user/group queries. Hence, we would preferably make DBus (and other IPC
that supports access-management based on groups) work without resorting
to the user/group database. This new SO_PEERGROUPS ioctl would allow us
to make dbus-daemon work without ever calling into NSS.

Cc: Michal Sekletar <msekleta@redhat.com>
Cc: Simon McVittie <simon.mcvittie@collabora.co.uk>
Reviewed-by: Tom Gundersen <teg@jklm.no>
Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
v2:
 - rebase on net-next
 - powerpc uapi header now uses asm-generic

 arch/alpha/include/uapi/asm/socket.h   |  2 ++
 arch/frv/include/uapi/asm/socket.h     |  2 ++
 arch/ia64/include/uapi/asm/socket.h    |  2 ++
 arch/m32r/include/uapi/asm/socket.h    |  2 ++
 arch/mips/include/uapi/asm/socket.h    |  2 ++
 arch/mn10300/include/uapi/asm/socket.h |  2 ++
 arch/parisc/include/uapi/asm/socket.h  |  2 ++
 arch/s390/include/uapi/asm/socket.h    |  2 ++
 arch/sparc/include/uapi/asm/socket.h   |  2 ++
 arch/xtensa/include/uapi/asm/socket.h  |  2 ++
 include/uapi/asm-generic/socket.h      |  2 ++
 net/core/sock.c                        | 33 +++++++++++++++++++++++++++++++++
 12 files changed, 55 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 0926de63a62b..7b285dd4fe05 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -107,4 +107,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_PEERGROUPS		59
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index e491ff08b9a9..f1e3b20dce9f 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -100,5 +100,7 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_PEERGROUPS		59
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 869372413333..5dd5c5d0d642 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -109,4 +109,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_PEERGROUPS		59
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 5d97890a8704..f8f7b47e247f 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -100,4 +100,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_PEERGROUPS		59
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 365ff51f033a..882823bec153 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -118,4 +118,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_PEERGROUPS		59
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index d013c0da0256..c710db354ff2 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -100,4 +100,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_PEERGROUPS		59
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index b893ca14fade..a0d4dc9f4eb2 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -99,4 +99,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	0x4033
 
+#define SO_PEERGROUPS		0x4034
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index fb9769d7e74e..52a63f4175cb 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -106,4 +106,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_PEERGROUPS		59
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 5d673302fd41..186fd8199f54 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -96,6 +96,8 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	0x003c
 
+#define SO_PEERGROUPS		0x003d
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 982c2533f912..3eed2761c149 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -111,4 +111,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_PEERGROUPS		59
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index a5f6e819fafd..9861be8da65e 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -102,4 +102,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_PEERGROUPS		59
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index ad8a4bc84126..6f4b090241c1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1078,6 +1078,18 @@ static void cred_to_ucred(struct pid *pid, const struct cred *cred,
 	}
 }
 
+static int groups_to_user(gid_t __user *dst, const struct group_info *src)
+{
+	struct user_namespace *user_ns = current_user_ns();
+	int i;
+
+	for (i = 0; i < src->ngroups; i++)
+		if (put_user(from_kgid_munged(user_ns, src->gid[i]), dst + i))
+			return -EFAULT;
+
+	return 0;
+}
+
 int sock_getsockopt(struct socket *sock, int level, int optname,
 		    char __user *optval, int __user *optlen)
 {
@@ -1231,6 +1243,27 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		goto lenout;
 	}
 
+	case SO_PEERGROUPS:
+	{
+		int ret, n;
+
+		if (!sk->sk_peer_cred)
+			return -ENODATA;
+
+		n = sk->sk_peer_cred->group_info->ngroups;
+		if (len < n * sizeof(gid_t)) {
+			len = n * sizeof(gid_t);
+			return put_user(len, optlen) ? -EFAULT : -ERANGE;
+		}
+		len = n * sizeof(gid_t);
+
+		ret = groups_to_user((gid_t __user *)optval,
+				     sk->sk_peer_cred->group_info);
+		if (ret)
+			return ret;
+		goto lenout;
+	}
+
 	case SO_PEERNAME:
 	{
 		char address[128];
-- 
2.13.1
