From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Wed, 03 Aug 2011 12:25:51 +0900
Message-ID: <201108030325.p733Pplb030986@www262.sakura.ne.jp>
References: <20110802.041857.1325765319466840715.davem@davemloft.net> <20110802.042641.2122529993066553943.davem@davemloft.net> <201108022052.FBE56208.FLQHFtMOVOSOJF@I-love.SAKURA.ne.jp> <20110802.050115.1714327089688495866.davem@davemloft.net> <201108022211.BJI69291.QLFFJMOOtOHVSF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eparis@parisplace.org, casey@schaufler-ca.com,
	mjt@tls.msk.ru, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: anton@samba.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201108022211.BJI69291.QLFFJMOOtOHVSF@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa wrote:
> I see. Here is an updated version.
Oops, seems whitespace damaged. Resending.

Also, attaching kmalloc()-free version. If performance loss by kmalloc()-free
version is small enough, can it be a candidate?
----------------------------------------
[PATCH v2] net: Fix security_socket_sendmsg() bypass problem.

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

Also, it is not preferable to let next sendmmsg() return previous sendmmsg()'s
error code when some of requested entries were not sent, for the caller will
get confused by next sendmmsg(). Thus, ignore errors if one or more entries
were sent successfully.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [3.0+]
---
 include/linux/security.h   |   16 ++++++++--
 include/linux/socket.h     |    8 +++++
 net/socket.c               |   67 +++++++++++++++++++++++----------------------
 security/capability.c      |    3 +-
 security/security.c        |   52 +++++++++++++++++++++++++++++++++-
 security/selinux/hooks.c   |    5 ++-
 security/smack/smack_lsm.c |    5 ++-
 7 files changed, 114 insertions(+), 42 deletions(-)

--- linux-3.0-a.orig/include/linux/security.h
+++ linux-3.0-a/include/linux/security.h
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
--- linux-3.0-a.orig/include/linux/socket.h
+++ linux-3.0-a/include/linux/socket.h
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
--- linux-3.0-a.orig/net/socket.c
+++ linux-3.0-a/net/socket.c
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
@@ -2038,29 +2043,27 @@ int __sys_sendmmsg(int fd, struct mmsghd
 	}
 
 out_put:
-	fput_light(sock->file, fput_needed);
-
-	if (err == 0)
-		return datagrams;
-
-	if (datagrams != 0) {
-		/*
-		 * We may send less entries than requested (vlen) if the
-		 * sock is non blocking...
-		 */
-		if (err != -EAGAIN) {
-			/*
-			 * ... or if sendmsg returns an error after we
-			 * send some datagrams, where we record the
-			 * error to return on the next call or if the
-			 * app asks about it using getsockopt(SO_ERROR).
-			 */
-			sock->sk->sk_err = -err;
+#ifdef CONFIG_SECURITY_NETWORK
+	{ /* Clean up destination addresses. */
+		struct sendmmsg_dest_info *ptr;
+		struct sendmmsg_dest_info *tmp;
+
+		list_for_each_entry_safe(ptr, tmp, &list, list) {
+			list_del(&ptr->list);
+			kfree(ptr);
 		}
+	}
+#endif
+	fput_light(sock->file, fput_needed);
 
+	/*
+	 * We may send less entries than requested (vlen), but we ignore errors
+	 * if one or more entries were sent successfully.
+	 */
+	if (datagrams)
 		return datagrams;
-	}
 
+	/* Report errors only if no entry was sent. */
 	return err;
 }
 
--- linux-3.0-a.orig/security/capability.c
+++ linux-3.0-a/security/capability.c
@@ -593,7 +593,8 @@ static int cap_socket_accept(struct sock
 	return 0;
 }
 
-static int cap_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size)
+static int cap_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size,
+			      int datagrams, struct list_head *list)
 {
 	return 0;
 }
--- linux-3.0-a.orig/security/security.c
+++ linux-3.0-a/security/security.c
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
--- linux-3.0-a.orig/security/selinux/hooks.c
+++ linux-3.0-a/security/selinux/hooks.c
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
--- linux-3.0-a.orig/security/smack/smack_lsm.c
+++ linux-3.0-a/security/smack/smack_lsm.c
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
 
----------------------------------------
[PATCH] net: Fix security_socket_sendmsg() bypass problem.

The sendmmsg() introduced by commit 228e548e "net: Add sendmmsg socket system
call" is capable of sending to multiple different destination addresses.

SMACK is using destination's address for checking sendmsg() permission.
However, security_socket_sendmsg() is called for only once even if multiple
different destination addresses are passed to sendmmsg().

Therefore, we need to call security_socket_sendmsg() for each destination
address rather than only the first destination address.

Since calling security_socket_sendmsg() every time when only single destination
address was passed to sendmmsg() is a waste of time, omit calling
security_socket_sendmsg() unless destination address of previous datagram and
that of current datagram differs.

Also, it is not preferable to let next sendmmsg() return previous sendmmsg()'s
error code when some of requested entries were not sent, for the caller will
get confused by next sendmmsg(). Thus, ignore errors if one or more entries
were sent successfully.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [3.0+]
---
 net/socket.c |   71 ++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 42 insertions(+), 29 deletions(-)

--- linux-3.0-b.orig/net/socket.c
+++ linux-3.0-b/net/socket.c
@@ -580,7 +580,8 @@ int sock_sendmsg(struct socket *sock, st
 }
 EXPORT_SYMBOL(sock_sendmsg);
 
-int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg, size_t size)
+static int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg,
+			      size_t size)
 {
 	struct kiocb iocb;
 	struct sock_iocb siocb;
@@ -1871,8 +1872,14 @@ SYSCALL_DEFINE2(shutdown, int, fd, int, 
 #define COMPAT_NAMELEN(msg)	COMPAT_MSG(msg, msg_namelen)
 #define COMPAT_FLAGS(msg)	COMPAT_MSG(msg, msg_flags)
 
+struct used_address {
+	struct sockaddr_storage name;
+	unsigned int name_len;
+};
+
 static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
-			 struct msghdr *msg_sys, unsigned flags, int nosec)
+			 struct msghdr *msg_sys, unsigned flags,
+			 struct used_address *used_address)
 {
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
@@ -1953,8 +1960,28 @@ static int __sys_sendmsg(struct socket *
 
 	if (sock->file->f_flags & O_NONBLOCK)
 		msg_sys->msg_flags |= MSG_DONTWAIT;
-	err = (nosec ? sock_sendmsg_nosec : sock_sendmsg)(sock, msg_sys,
-							  total_len);
+	/*
+	 * If this is sendmmsg() and current destination address is same as
+	 * previously succeeded address, omit asking LSM's decision.
+	 * used_address->name_len is initialized to UINT_MAX so that the first
+	 * destination address never matches.
+	 */
+	if (used_address && used_address->name_len == msg_sys->msg_namelen &&
+	    !memcmp(&used_address->name, msg->msg_name,
+		    used_address->name_len)) {
+		err = sock_sendmsg_nosec(sock, msg_sys, total_len);
+		goto out_freectl;
+	}
+	err = sock_sendmsg(sock, msg_sys, total_len);
+	/*
+	 * If this is sendmmsg() and sending to current destination address was
+	 * successful, remember it.
+	 */
+	if (used_address && err >= 0) {
+		used_address->name_len = msg_sys->msg_namelen;
+		memcpy(&used_address->name, msg->msg_name,
+		       used_address->name_len);
+	}
 
 out_freectl:
 	if (ctl_buf != ctl)
@@ -1979,7 +2006,7 @@ SYSCALL_DEFINE3(sendmsg, int, fd, struct
 	if (!sock)
 		goto out;
 
-	err = __sys_sendmsg(sock, msg, &msg_sys, flags, 0);
+	err = __sys_sendmsg(sock, msg, &msg_sys, flags, NULL);
 
 	fput_light(sock->file, fput_needed);
 out:
@@ -1998,6 +2025,7 @@ int __sys_sendmmsg(int fd, struct mmsghd
 	struct mmsghdr __user *entry;
 	struct compat_mmsghdr __user *compat_entry;
 	struct msghdr msg_sys;
+	struct used_address used_address;
 
 	datagrams = 0;
 
@@ -2009,23 +2037,21 @@ int __sys_sendmmsg(int fd, struct mmsghd
 	if (err)
 		goto out_put;
 
+	used_address.name_len = UINT_MAX;
 	entry = mmsg;
 	compat_entry = (struct compat_mmsghdr __user *)mmsg;
 
 	while (datagrams < vlen) {
-		/*
-		 * No need to ask LSM for more than the first datagram.
-		 */
 		if (MSG_CMSG_COMPAT & flags) {
 			err = __sys_sendmsg(sock, (struct msghdr __user *)compat_entry,
-					    &msg_sys, flags, datagrams);
+					    &msg_sys, flags, &used_address);
 			if (err < 0)
 				break;
 			err = __put_user(err, &compat_entry->msg_len);
 			++compat_entry;
 		} else {
 			err = __sys_sendmsg(sock, (struct msghdr __user *)entry,
-					    &msg_sys, flags, datagrams);
+					    &msg_sys, flags, &used_address);
 			if (err < 0)
 				break;
 			err = put_user(err, &entry->msg_len);
@@ -2040,27 +2066,14 @@ int __sys_sendmmsg(int fd, struct mmsghd
 out_put:
 	fput_light(sock->file, fput_needed);
 
-	if (err == 0)
-		return datagrams;
-
-	if (datagrams != 0) {
-		/*
-		 * We may send less entries than requested (vlen) if the
-		 * sock is non blocking...
-		 */
-		if (err != -EAGAIN) {
-			/*
-			 * ... or if sendmsg returns an error after we
-			 * send some datagrams, where we record the
-			 * error to return on the next call or if the
-			 * app asks about it using getsockopt(SO_ERROR).
-			 */
-			sock->sk->sk_err = -err;
-		}
-
+	/*
+	 * We may send less entries than requested (vlen), but we ignore errors
+	 * if one or more entries were sent successfully.
+	 */
+	if (datagrams)
 		return datagrams;
-	}
 
+	/* Report errors only if no entry was sent. */
 	return err;
 }
 
