From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Thu, 28 Jul 2011 12:36:30 +0900
Message-ID: <201107280336.p6S3aUY7004372@www262.sakura.ne.jp>
References: <20110725222010.0b284042@kryten> <201107252215.GBG95887.OQVMFOOJLSFFHt@I-love.SAKURA.ne.jp> <4E2D8F4D.2000009@schaufler-ca.com> <201107260143.CGH18263.FOOSVMOQFJFLHt@I-love.SAKURA.ne.jp> <20110726195557.5abcf96d@kryten> <201107262021.FCC34304.HMOOFQJVSFLFOt@I-love.SAKURA.ne.jp> <CACLa4pvJ2+eTRf3SRzoXgiW8H+U=BDH-2DKVZ7pGRrPem=JYgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: eparis@parisplace.org, anton@samba.org, casey@schaufler-ca.com,
	mjt@tls.msk.ru, davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CACLa4pvJ2+eTRf3SRzoXgiW8H+U=BDH-2DKVZ7pGRrPem=JYgg@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is an optimized version. Only compile tested.

Regarding SELinux, there should be little performance loss by this change.

Regarding SMACK, please test both functionality and performance improvement.
Unoptimized version will be measurable by applying
http://www.spinics.net/linux/fedora/linux-security-module/msg11504.html .

Regarding TOMOYO, I'll update tomoyo_socket_sendmsg() like SMACK does.

Regarding AppArmor, please update apparmor_socket_sendmsg() in Oneiric's patch
like SELinux does.

Regarding no-LSM case, there should be little performance loss by this change.
----------------------------------------
[PATCH] net: Fix security_socket_sendmsg() bypass problem.

The sendmmsg() introduced by commit 228e548e "net: Add sendmmsg socket system
call" is capable of sending to multiple different destinations. However,
security_socket_sendmsg() is called for only once even if multiple different
destination's addresses are passed to sendmmsg().

SMACK is using destination's address for checking sendmsg() permission.
Therefore, we need to call security_socket_sendmsg() for each destination
address rather than only the first destination address.

Fix this regression by
(1) passing "int datagrams" argument to security_socket_sendmsg() so that
    SELinux can omit sock_has_perm() checks on the 2nd or later.
(2) passing "struct list_head *list" argument to security_socket_sendmsg() so
    that SMACK can omit smack_netlabel_send() checks for duplicated destination
    address.
(3) letting __sys_sendmmsg() provide "struct list_head list" for
    security_socket_sendmsg() and clean it up before return.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [3.0+]
---
 include/linux/security.h   |   16 ++++++++++---
 include/linux/socket.h     |    8 ++++++
 net/socket.c               |   42 +++++++++++++++++++++++++-----------
 security/capability.c      |    3 +-
 security/security.c        |   52 +++++++++++++++++++++++++++++++++++++++++++--
 security/selinux/hooks.c   |    5 ++--
 security/smack/smack_lsm.c |    5 +++-
 7 files changed, 108 insertions(+), 23 deletions(-)

--- linux-3.0.orig/include/linux/security.h
+++ linux-3.0/include/linux/security.h
@@ -93,6 +93,7 @@ struct xfrm_policy;
 struct xfrm_state;
 struct xfrm_user_sec_ctx;
 struct seq_file;
+struct list_head;
 
 extern int cap_netlink_send(struct sock *sk, struct sk_buff *skb);
 extern int cap_netlink_recv(struct sk_buff *skb, int cap);
@@ -880,6 +881,10 @@ static inline void security_free_mnt_opt
  *	@sock contains the socket structure.
  *	@msg contains the message to be transmitted.
  *	@size contains the size of message.
+ *	@datagrams contains the index of messages in sendmmsg(). This is 0 if
+ *	not sendmmsg().
+ *	@list contains the list head which can be used for holding
+ *	already-checked destination address. This is NULL if not sendmmsg().
  *	Return 0 if permission is granted.
  * @socket_recvmsg:
  *	Check permission before receiving a message from a socket.
@@ -1584,8 +1589,8 @@ struct security_operations {
 			       struct sockaddr *address, int addrlen);
 	int (*socket_listen) (struct socket *sock, int backlog);
 	int (*socket_accept) (struct socket *sock, struct socket *newsock);
-	int (*socket_sendmsg) (struct socket *sock,
-			       struct msghdr *msg, int size);
+	int (*socket_sendmsg) (struct socket *sock, struct msghdr *msg,
+			       int size, int datagrams, struct list_head *list);
 	int (*socket_recvmsg) (struct socket *sock,
 			       struct msghdr *msg, int size, int flags);
 	int (*socket_getsockname) (struct socket *sock);
@@ -2551,7 +2556,9 @@ int security_socket_bind(struct socket *
 int security_socket_connect(struct socket *sock, struct sockaddr *address, int addrlen);
 int security_socket_listen(struct socket *sock, int backlog);
 int security_socket_accept(struct socket *sock, struct socket *newsock);
-int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size);
+bool security_sendmsg_uniq_address(struct msghdr *msg, struct list_head *list);
+int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size,
+			    int datagrams, struct list_head *list);
 int security_socket_recvmsg(struct socket *sock, struct msghdr *msg,
 			    int size, int flags);
 int security_socket_getsockname(struct socket *sock);
@@ -2636,7 +2643,8 @@ static inline int security_socket_accept
 }
 
 static inline int security_socket_sendmsg(struct socket *sock,
-					  struct msghdr *msg, int size)
+					  struct msghdr *msg, int size,
+					  int datagrams, struct list_head *list)
 {
 	return 0;
 }
--- linux-3.0.orig/include/linux/socket.h
+++ linux-3.0/include/linux/socket.h
@@ -23,6 +23,7 @@ struct __kernel_sockaddr_storage {
 #include <linux/uio.h>			/* iovec support		*/
 #include <linux/types.h>		/* pid_t			*/
 #include <linux/compiler.h>		/* __user			*/
+#include <linux/list.h>			/* struct list_head             */
 
 struct pid;
 struct cred;
@@ -75,6 +76,13 @@ struct mmsghdr {
 	unsigned        msg_len;
 };
 
+/* For remembering destination's address passed to sendmmsg(). */
+struct sendmmsg_dest_info {
+	struct list_head list;
+	unsigned int address_len;
+	struct sockaddr_storage address;
+};
+
 /*
  *	POSIX 1003.1g - ancillary data object information
  *	Ancillary data consits of a sequence of pairs of
--- linux-3.0.orig/net/socket.c
+++ linux-3.0/net/socket.c
@@ -558,9 +558,10 @@ static inline int __sock_sendmsg_nosec(s
 }
 
 static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-				 struct msghdr *msg, size_t size)
+				 struct msghdr *msg, size_t size,
+				 int datagrams, struct list_head *list)
 {
-	int err = security_socket_sendmsg(sock, msg, size);
+	int err = security_socket_sendmsg(sock, msg, size, datagrams, list);
 
 	return err ?: __sock_sendmsg_nosec(iocb, sock, msg, size);
 }
@@ -573,14 +574,16 @@ int sock_sendmsg(struct socket *sock, st
 
 	init_sync_kiocb(&iocb, NULL);
 	iocb.private = &siocb;
-	ret = __sock_sendmsg(&iocb, sock, msg, size);
+	ret = __sock_sendmsg(&iocb, sock, msg, size, 0, NULL);
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&iocb);
 	return ret;
 }
 EXPORT_SYMBOL(sock_sendmsg);
 
-int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg, size_t size)
+static int sock_send_datagrams(struct socket *sock, struct msghdr *msg,
+			       size_t size, int datagrams,
+			       struct list_head *list)
 {
 	struct kiocb iocb;
 	struct sock_iocb siocb;
@@ -588,7 +591,7 @@ int sock_sendmsg_nosec(struct socket *so
 
 	init_sync_kiocb(&iocb, NULL);
 	iocb.private = &siocb;
-	ret = __sock_sendmsg_nosec(&iocb, sock, msg, size);
+	ret = __sock_sendmsg(&iocb, sock, msg, size, datagrams, list);
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&iocb);
 	return ret;
@@ -888,7 +891,7 @@ static ssize_t do_sock_write(struct msgh
 	if (sock->type == SOCK_SEQPACKET)
 		msg->msg_flags |= MSG_EOR;
 
-	return __sock_sendmsg(iocb, sock, msg, size);
+	return __sock_sendmsg(iocb, sock, msg, size, 0, NULL);
 }
 
 static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
@@ -1872,7 +1875,8 @@ SYSCALL_DEFINE2(shutdown, int, fd, int, 
 #define COMPAT_FLAGS(msg)	COMPAT_MSG(msg, msg_flags)
 
 static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
-			 struct msghdr *msg_sys, unsigned flags, int nosec)
+			 struct msghdr *msg_sys, unsigned flags, int datagrams,
+			 struct list_head *list)
 {
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
@@ -1953,8 +1957,7 @@ static int __sys_sendmsg(struct socket *
 
 	if (sock->file->f_flags & O_NONBLOCK)
 		msg_sys->msg_flags |= MSG_DONTWAIT;
-	err = (nosec ? sock_sendmsg_nosec : sock_sendmsg)(sock, msg_sys,
-							  total_len);
+	err = sock_send_datagrams(sock, msg_sys, total_len, datagrams, list);
 
 out_freectl:
 	if (ctl_buf != ctl)
@@ -1979,7 +1982,7 @@ SYSCALL_DEFINE3(sendmsg, int, fd, struct
 	if (!sock)
 		goto out;
 
-	err = __sys_sendmsg(sock, msg, &msg_sys, flags, 0);
+	err = __sys_sendmsg(sock, msg, &msg_sys, flags, 0, NULL);
 
 	fput_light(sock->file, fput_needed);
 out:
@@ -1998,6 +2001,7 @@ int __sys_sendmmsg(int fd, struct mmsghd
 	struct mmsghdr __user *entry;
 	struct compat_mmsghdr __user *compat_entry;
 	struct msghdr msg_sys;
+	LIST_HEAD(list); /* List for finding duplicated destination address. */
 
 	datagrams = 0;
 
@@ -2014,18 +2018,19 @@ int __sys_sendmmsg(int fd, struct mmsghd
 
 	while (datagrams < vlen) {
 		/*
-		 * No need to ask LSM for more than the first datagram.
+		 * If datagrams == 0, LSM module will check. Otherwise, it will
+		 * check depending on its implementation.
 		 */
 		if (MSG_CMSG_COMPAT & flags) {
 			err = __sys_sendmsg(sock, (struct msghdr __user *)compat_entry,
-					    &msg_sys, flags, datagrams);
+					    &msg_sys, flags, datagrams, &list);
 			if (err < 0)
 				break;
 			err = __put_user(err, &compat_entry->msg_len);
 			++compat_entry;
 		} else {
 			err = __sys_sendmsg(sock, (struct msghdr __user *)entry,
-					    &msg_sys, flags, datagrams);
+					    &msg_sys, flags, datagrams, &list);
 			if (err < 0)
 				break;
 			err = put_user(err, &entry->msg_len);
@@ -2038,6 +2043,17 @@ int __sys_sendmmsg(int fd, struct mmsghd
 	}
 
 out_put:
+#ifdef CONFIG_SECURITY_NETWORK
+	{ /* Clean up destination addresses. */
+		struct sendmmsg_dest_info *ptr;
+		struct sendmmsg_dest_info *tmp;
+
+		list_for_each_entry_safe(ptr, tmp, &list, list) {
+			list_del(&ptr->list);
+			kfree(ptr);
+		}
+	}
+#endif
 	fput_light(sock->file, fput_needed);
 
 	if (err == 0)
--- linux-3.0.orig/security/capability.c
+++ linux-3.0/security/capability.c
@@ -593,7 +593,8 @@ static int cap_socket_accept(struct sock
 	return 0;
 }
 
-static int cap_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size)
+static int cap_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size,
+			      int datagrams, struct list_head *list)
 {
 	return 0;
 }
--- linux-3.0.orig/security/security.c
+++ linux-3.0/security/security.c
@@ -17,6 +17,7 @@
 #include <linux/kernel.h>
 #include <linux/security.h>
 #include <linux/ima.h>
+#include <linux/socket.h>
 
 /* Boot-time LSM user choice */
 static __initdata char chosen_lsm[SECURITY_NAME_MAX + 1] =
@@ -1036,9 +1037,56 @@ int security_socket_accept(struct socket
 	return security_ops->socket_accept(sock, newsock);
 }
 
-int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size)
+int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size,
+			    int datagrams, struct list_head *list)
 {
-	return security_ops->socket_sendmsg(sock, msg, size);
+	return security_ops->socket_sendmsg(sock, msg, size, datagrams, list);
+}
+
+/**
+ * security_sendmsg_uniq_address - Check for duplicated address.
+ *
+ * @msg:  Pointer to "struct msg".
+ * @list: Pointer to "struct list_head".
+ *
+ * Returns true if @msg->msg_name is already in @list, false otherwise.
+ * @msg->msg_name will be duplicated and added to @list (unless out-of-memory
+ * occurs) if this function returns true. __sys_sendmmsg() provides @list and
+ * will clean up allocated memory before return.
+ *
+ * Some LSM modules check permission based on destination address at
+ * security_socket_sendmsg(). But checking for duplicated destination
+ * address at common code path is waste of time unless such LSM module is
+ * selected. Therefore, let such LSM modules call this function if they want to
+ * check permission only once for each uniq destination address.
+ */
+bool security_sendmsg_uniq_address(struct msghdr *msg, struct list_head *list)
+{
+	struct sendmmsg_dest_info *ptr;
+
+	/* If not sendmmsg(), this address is uniq. */
+	if (!list)
+		return true;
+	/* If sendmmsg(), check if this address was already used. */
+	list_for_each_entry(ptr, list, list) {
+		if (ptr->address_len != msg->msg_namelen ||
+		    memcmp(&ptr->address, msg->msg_name, ptr->address_len))
+			continue;
+		return false;
+	}
+	/*
+	 * Remember this address so that subsequent call will return false.
+	 *
+	 * Out of memory error is not fatal here because checking more than
+	 * once should be harmless other than the performance loss.
+	 */
+	ptr = kmalloc(sizeof(*ptr), GFP_KERNEL);
+	if (ptr) {
+		ptr->address_len = msg->msg_namelen;
+		memcpy(&ptr->address, msg->msg_name, ptr->address_len);
+		list_add(&ptr->list, list);
+	}
+	return true;
 }
 
 int security_socket_recvmsg(struct socket *sock, struct msghdr *msg,
--- linux-3.0.orig/security/selinux/hooks.c
+++ linux-3.0/security/selinux/hooks.c
@@ -3967,9 +3967,10 @@ static int selinux_socket_accept(struct 
 }
 
 static int selinux_socket_sendmsg(struct socket *sock, struct msghdr *msg,
-				  int size)
+				  int size, int datagrams,
+				  struct list_head *list)
 {
-	return sock_has_perm(current, sock->sk, SOCKET__WRITE);
+	return datagrams ? 0 : sock_has_perm(current, sock->sk, SOCKET__WRITE);
 }
 
 static int selinux_socket_recvmsg(struct socket *sock, struct msghdr *msg,
--- linux-3.0.orig/security/smack/smack_lsm.c
+++ linux-3.0/security/smack/smack_lsm.c
@@ -2799,7 +2799,7 @@ static int smack_unix_may_send(struct so
  * label host.
  */
 static int smack_socket_sendmsg(struct socket *sock, struct msghdr *msg,
-				int size)
+				int size, int datagrams, struct list_head *list)
 {
 	struct sockaddr_in *sip = (struct sockaddr_in *) msg->msg_name;
 
@@ -2809,6 +2809,9 @@ static int smack_socket_sendmsg(struct s
 	if (sip == NULL || sip->sin_family != AF_INET)
 		return 0;
 
+	if (!security_sendmsg_uniq_address(msg, list))
+		return 0;
+
 	return smack_netlabel_send(sock->sk, sip);
 }
 
