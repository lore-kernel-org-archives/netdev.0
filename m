From: Vivek Goyal <vgoyal@redhat.com>
Subject: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing cgroup path
Date: Tue, 15 Apr 2014 17:15:46 -0400
Message-ID: <1397596546-10153-3-git-send-email-vgoyal@redhat.com>
References: <1397596546-10153-1-git-send-email-vgoyal@redhat.com>
Cc: tj@kernel.org, ssorce@redhat.com, lpoetter@redhat.com,
	kay@redhat.com, luto@amacapital.net, dwalsh@redhat.com,
	Vivek Goyal <vgoyal@redhat.com>
To: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397596546-10153-1-git-send-email-vgoyal@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements socket option SO_PASSCGROUP along the lines of
SO_PASSCRED.

If SO_PASSCGROUP is set, then recvmsg() will get a control message
SCM_CGROUP which will contain the cgroup path of sender. This cgroup
belongs to first mounted hierarchy in the sytem.

SCM_CGROUP control message can only be received and sender can not send
a SCM_CGROUP message. Kernel automatically generates one if receiver
chooses to receive one.

This works both for unix stream and datagram sockets.

cgroup information is passed only if either the sender or receiver has
SO_PASSCGROUP option set. This means for existing workloads they should
not see any significant performance impact of this change.

Signed-off-by: Vivek Goyal <vgoyal@redhat.com>
---
 arch/alpha/include/uapi/asm/socket.h   |   1 +
 arch/avr32/include/uapi/asm/socket.h   |   1 +
 arch/cris/include/uapi/asm/socket.h    |   1 +
 arch/frv/include/uapi/asm/socket.h     |   1 +
 arch/ia64/include/uapi/asm/socket.h    |   1 +
 arch/m32r/include/uapi/asm/socket.h    |   1 +
 arch/mips/include/uapi/asm/socket.h    |   1 +
 arch/mn10300/include/uapi/asm/socket.h |   1 +
 arch/parisc/include/uapi/asm/socket.h  |   1 +
 arch/powerpc/include/uapi/asm/socket.h |   1 +
 arch/s390/include/uapi/asm/socket.h    |   1 +
 arch/sparc/include/uapi/asm/socket.h   |   1 +
 arch/xtensa/include/uapi/asm/socket.h  |   1 +
 include/linux/net.h                    |   1 +
 include/linux/socket.h                 |   1 +
 include/net/af_unix.h                  |   1 +
 include/net/scm.h                      |  26 +++++--
 include/uapi/asm-generic/socket.h      |   1 +
 net/core/sock.c                        |   7 ++
 net/unix/af_unix.c                     | 122 +++++++++++++++++++++++++++++++++
 20 files changed, 167 insertions(+), 5 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 7178353..8e67ddb 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -88,4 +88,5 @@
 #define SO_BPF_EXTENSIONS	48
 
 #define SO_PEERCGROUP		49
+#define SO_PASSCGROUP		50
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 486212b..71e795a 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -81,4 +81,5 @@
 #define SO_BPF_EXTENSIONS	48
 
 #define SO_PEERCGROUP		49
+#define SO_PASSCGROUP		50
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index 89a09e3..b339e52 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -83,6 +83,7 @@
 #define SO_BPF_EXTENSIONS	48
 
 #define SO_PEERCGROUP		49
+#define SO_PASSCGROUP		50
 
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index c4d90bc..4fc46fb 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -81,5 +81,6 @@
 #define SO_BPF_EXTENSIONS	48
 
 #define SO_PEERCGROUP		49
+#define SO_PASSCGROUP		50
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 62c196d..5e77320 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -90,5 +90,6 @@
 #define SO_BPF_EXTENSIONS	48
 
 #define SO_PEERCGROUP		49
+#define SO_PASSCGROUP		50
 
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 6e04a7d..aec9a78 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -81,4 +81,5 @@
 #define SO_BPF_EXTENSIONS	48
 
 #define SO_PEERCGROUP		49
+#define SO_PASSCGROUP		50
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index cfbd84b..30354ea 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -99,4 +99,5 @@
 #define SO_BPF_EXTENSIONS	48
 
 #define SO_PEERCGROUP		49
+#define SO_PASSCGROUP		50
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 73467fe..c68786d 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -81,4 +81,5 @@
 #define SO_BPF_EXTENSIONS	48
 
 #define SO_PEERCGROUP		49
+#define SO_PASSCGROUP		50
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 24d8913..6d3447a 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -80,4 +80,5 @@
 #define SO_BPF_EXTENSIONS	0x4029
 
 #define SO_PEERCGROUP           0x402a
+#define SO_PASSCGROUP           0x402b
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index 50106be..89a55b8 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -88,4 +88,5 @@
 #define SO_BPF_EXTENSIONS	48
 
 #define SO_PEERCGROUP		49
+#define SO_PASSCGROUP		50
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 4ae2f3c..f5b10d8 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -87,4 +87,5 @@
 #define SO_BPF_EXTENSIONS	48
 
 #define SO_PEERCGROUP		49
+#define SO_PASSCGROUP		50
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 1056168..d1c5f33 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -77,6 +77,7 @@
 #define SO_BPF_EXTENSIONS	0x0032
 
 #define SO_PEERCGROUP           0x0033
+#define SO_PASSCGROUP           0x0034
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 947bc6e..47b3593 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -92,4 +92,5 @@
 #define SO_BPF_EXTENSIONS	48
 
 #define SO_PEERCGROUP		49
+#define SO_PASSCGROUP		50
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/linux/net.h b/include/linux/net.h
index 94734a6..5ec6d71 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -39,6 +39,7 @@ struct net;
 #define SOCK_PASSCRED		3
 #define SOCK_PASSSEC		4
 #define SOCK_EXTERNALLY_ALLOCATED 5
+#define SOCK_PASSCGROUP		6
 
 #ifndef ARCH_HAS_SOCKET_TYPES
 /**
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 8e98297..9993d65 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -130,6 +130,7 @@ static inline struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct cmsghdr
 #define	SCM_RIGHTS	0x01		/* rw: access rights (array of int) */
 #define SCM_CREDENTIALS 0x02		/* rw: struct ucred		*/
 #define SCM_SECURITY	0x03		/* rw: security label		*/
+#define SCM_CGROUP	0x04		/* r: cgroup path of sender	*/
 
 struct ucred {
 	__u32	pid;
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index a175ba4..7301371 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -36,6 +36,7 @@ struct unix_skb_parms {
 	u32			secid;		/* Security ID		*/
 #endif
 	u32			consumed;
+	char			*cgroup_path;
 };
 
 #define UNIXCB(skb) 	(*(struct unix_skb_parms *)&((skb)->cb))
diff --git a/include/net/scm.h b/include/net/scm.h
index 262532d..477c154 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -31,6 +31,7 @@ struct scm_cookie {
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Passed security ID 	*/
 #endif
+	char			*cgroup_path;
 };
 
 void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm);
@@ -64,11 +65,18 @@ static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
 	scm->pid  = NULL;
 }
 
+static __inline__ void scm_free_cgroup_path(struct scm_cookie *scm)
+{
+	kfree(scm->cgroup_path);
+	scm->cgroup_path = NULL;
+}
+
 static __inline__ void scm_destroy(struct scm_cookie *scm)
 {
 	scm_destroy_cred(scm);
 	if (scm->fp)
 		__scm_destroy(scm);
+	scm_free_cgroup_path(scm);
 }
 
 static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
@@ -110,7 +118,8 @@ static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 				struct scm_cookie *scm, int flags)
 {
 	if (!msg->msg_control) {
-		if (test_bit(SOCK_PASSCRED, &sock->flags) || scm->fp)
+		if (test_bit(SOCK_PASSCRED, &sock->flags) || scm->fp ||
+		    test_bit(SOCK_PASSCGROUP, &sock->flags))
 			msg->msg_flags |= MSG_CTRUNC;
 		scm_destroy(scm);
 		return;
@@ -130,10 +139,17 @@ static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 
 	scm_passec(sock, msg, scm);
 
-	if (!scm->fp)
-		return;
-	
-	scm_detach_fds(msg, scm);
+	if (scm->fp)
+		scm_detach_fds(msg, scm);
+
+	if (scm->cgroup_path) {
+		if (test_bit(SOCK_PASSCGROUP, &sock->flags)) {
+			int len = strlen(scm->cgroup_path) + 1;
+			put_cmsg(msg, SOL_SOCKET, SCM_CGROUP, len,
+				 scm->cgroup_path);
+		}
+		scm_free_cgroup_path(scm);
+	}
 }
 
 
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index e86be5b..aad9ddb 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -83,5 +83,6 @@
 #define SO_BPF_EXTENSIONS	48
 
 #define SO_PEERCGROUP		49
+#define SO_PASSCGROUP		50
 
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 2926774..76ff2a6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -779,6 +779,13 @@ set_rcvbuf:
 			clear_bit(SOCK_PASSCRED, &sock->flags);
 		break;
 
+	case SO_PASSCGROUP:
+		if (valbool)
+			set_bit(SOCK_PASSCGROUP, &sock->flags);
+		else
+			clear_bit(SOCK_PASSCGROUP, &sock->flags);
+		break;
+
 	case SO_TIMESTAMP:
 	case SO_TIMESTAMPNS:
 		if (valbool)  {
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 892ea50..85e1e4b 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -155,6 +155,23 @@ static inline void unix_set_secdata(struct scm_cookie *scm, struct sk_buff *skb)
 { }
 #endif /* CONFIG_SECURITY_NETWORK */
 
+#ifdef CONFIG_CGROUPS
+static inline void scm_set_cgroup_path(struct scm_cookie *scm,
+				       struct sk_buff *skb)
+{
+	if (!UNIXCB(skb).cgroup_path)
+		return;
+
+	/* Transfer the ownership of cgroup path buffer from skb to scm */
+	scm->cgroup_path = UNIXCB(skb).cgroup_path;
+	UNIXCB(skb).cgroup_path = NULL;
+}
+#else
+static inline void scm_set_cgroup_path(struct scm_cookie *scm,
+				       struct sk_buff *skb)
+{ }
+#endif
+
 /*
  *  SMP locking strategy:
  *    hash table is protected with spinlock unix_table_lock
@@ -1326,6 +1343,8 @@ static void unix_sock_inherit_flags(const struct socket *old,
 		set_bit(SOCK_PASSCRED, &new->flags);
 	if (test_bit(SOCK_PASSSEC, &old->flags))
 		set_bit(SOCK_PASSSEC, &new->flags);
+	if (test_bit(SOCK_PASSCGROUP, &old->flags))
+		set_bit(SOCK_PASSCGROUP, &new->flags);
 }
 
 static int unix_accept(struct socket *sock, struct socket *newsock, int flags)
@@ -1427,6 +1446,11 @@ static void unix_destruct_scm(struct sk_buff *skb)
 	if (UNIXCB(skb).fp)
 		unix_detach_fds(&scm, skb);
 
+	if (UNIXCB(skb).cgroup_path) {
+		scm.cgroup_path = UNIXCB(skb).cgroup_path;
+		UNIXCB(skb).cgroup_path = NULL;
+	}
+
 	/* Alas, it calls VFS */
 	/* So fscking what? fput() had been SMP-safe since the last Summer */
 	scm_destroy(&scm);
@@ -1480,6 +1504,7 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 	if (scm->fp && send_fds)
 		err = unix_attach_fds(scm, skb);
 
+	UNIXCB(skb).cgroup_path = NULL;
 	skb->destructor = unix_destruct_scm;
 	return err;
 }
@@ -1502,6 +1527,55 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
 	}
 }
 
+/* Should be called with "other" state spin lock held */
+static bool
+should_add_cgroup_path(const struct socket *sock, const struct sock *other)
+{
+#ifdef CONFIG_CGROUPS
+	/*
+	 * In stream sockets, it is possible that client starts sending
+	 * data (sendmsg()) before server has finished accept(). In that
+	 * case other->sk_socket will be null for a brief window and
+	 * will be set as soon as accept() completes.
+	 *
+	 * Send cgroup path for this small duration when other->sk_socket
+	 * is not set. Soon accept() should finish and
+	 * other->sk_socket->flags will decide whether to send cgroup
+	 * path or not.
+	 */
+	if (test_bit(SOCK_PASSCGROUP, &sock->flags) ||
+	    !other->sk_socket ||
+	    test_bit(SOCK_PASSCGROUP, &other->sk_socket->flags))
+		return true;
+#endif
+
+	return false;
+}
+
+static int skb_alloc_install_cgroup_path(struct sk_buff *skb)
+{
+
+#ifdef CONFIG_CGROUPS
+	char *cgroup_path, *path;
+
+	cgroup_path = kzalloc(PATH_MAX, GFP_KERNEL);
+	if (!cgroup_path)
+		return -ENOMEM;
+
+	path = task_cgroup_path(current, cgroup_path, PATH_MAX);
+	if (!path) {
+		kfree(cgroup_path);
+		return -ENAMETOOLONG;
+	}
+
+	if (path != cgroup_path)
+		memmove(cgroup_path, path, strlen(path) + 1);
+
+	UNIXCB(skb).cgroup_path = cgroup_path;
+#endif
+	return 0;
+}
+
 /*
  *	Send AF_UNIX data.
  */
@@ -1523,6 +1597,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct scm_cookie tmp_scm;
 	int max_level;
 	int data_len = 0;
+	bool need_cgroup_path = false;
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1600,7 +1675,20 @@ restart:
 		goto out_free;
 	}
 
+alloc_cgroup:
+	if (need_cgroup_path && !UNIXCB(skb).cgroup_path) {
+		err = skb_alloc_install_cgroup_path(skb);
+		if (err)
+			goto out_free;
+	}
+
 	unix_state_lock(other);
+	need_cgroup_path = should_add_cgroup_path(sock, other);
+	if (need_cgroup_path && !UNIXCB(skb).cgroup_path) {
+		unix_state_unlock(other);
+		goto alloc_cgroup;
+	}
+
 	err = -EPERM;
 	if (!unix_may_send(sk, other))
 		goto out_unlock;
@@ -1698,6 +1786,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	bool fds_sent = false;
 	int max_level;
 	int data_len;
+	bool need_cgroup_path = false;
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1759,12 +1848,26 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			goto out_err;
 		}
 
+alloc_cgroup:
+		if (need_cgroup_path && !UNIXCB(skb).cgroup_path) {
+			err = skb_alloc_install_cgroup_path(skb);
+			if (err) {
+				kfree_skb(skb);
+				goto out_err;
+			}
+		}
+
 		unix_state_lock(other);
 
 		if (sock_flag(other, SOCK_DEAD) ||
 		    (other->sk_shutdown & RCV_SHUTDOWN))
 			goto pipe_err_free;
 
+		need_cgroup_path = should_add_cgroup_path(sock, other);
+		if (need_cgroup_path && !UNIXCB(skb).cgroup_path) {
+			unix_state_unlock(other);
+			goto alloc_cgroup;
+		}
 		maybe_add_creds(skb, sock, other);
 		skb_queue_tail(&other->sk_receive_queue, skb);
 		if (max_level > unix_sk(other)->recursion_level)
@@ -1897,6 +2000,8 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 	scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
 	unix_set_secdata(siocb->scm, skb);
 
+	scm_set_cgroup_path(siocb->scm, skb);
+
 	if (!(flags & MSG_PEEK)) {
 		if (UNIXCB(skb).fp)
 			unix_detach_fds(siocb->scm, skb);
@@ -1982,6 +2087,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 	int copied = 0;
 	int noblock = flags & MSG_DONTWAIT;
 	int check_creds = 0;
+	bool check_cgroups = false;
 	int target;
 	int err = 0;
 	long timeo;
@@ -2081,6 +2187,22 @@ again:
 			check_creds = 1;
 		}
 
+		/* Don't glue messages from writers in different cgroups */
+		if (check_cgroups) {
+			/* Previous skb had cgroup path and this one does not */
+			if (UNIXCB(skb).cgroup_path == NULL)
+				break;
+
+			if (strcmp(UNIXCB(skb).cgroup_path,
+			    siocb->scm->cgroup_path))
+				break;
+		} else if (test_bit(SOCK_PASSCGROUP, &sock->flags) &&
+			   UNIXCB(skb).cgroup_path != NULL) {
+			/* Copy cgroup path */
+			scm_set_cgroup_path(siocb->scm, skb);
+			check_cgroups = true;
+		}
+
 		/* Copy address just once */
 		if (sunaddr) {
 			unix_copy_addr(msg, skb->sk);
-- 
1.9.0
