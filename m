From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [RFC v3] net: Introduce recvmmsg socket syscall
Date: Thu, 11 Jun 2009 19:58:21 -0300
Message-ID: <20090611225821.GH22424@ghostprotocols.net>
References: <20090611034022.GC22424@ghostprotocols.net> <20090611.024100.233245804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Paul Moore <paul.moore@hp.com>,
	Steven Whitehouse <steve@chygwyn.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nivedita Singhvi <niv@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59854 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755248AbZFKW6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 18:58:50 -0400
Content-Disposition: inline
In-Reply-To: <20090611.024100.233245804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Jun 11, 2009 at 02:41:00AM -0700, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Thu, 11 Jun 2009 00:40:22 -0300
> 
> > +	struct compat_timespec *timeout_compat =
> > +		(struct compat_timespec *)timeout;
> 
> In order for this to build on non-compat platforms, or when
> CONFIG_COMPAT is disabled, you'll need to avoid trying to
> reference compat_timespec.
> 
> We get away with compat_msghdr because we define it as a NOP
> in net/compat.h when necessary.
> 
> Doing the same, and cleanly, with this non-networking compat knob is
> unlikely to be straightforward.

Better now?

Paul, this one also has the sock_recvmsg_nosec rewrite
following your suggestion.

I'll write a proper changeset log once we get the more easy stuff out of
the way and people are confortable with it.

Ah, here is how things are being distributed now in a test setup with
two clients and running recvmmsg like this:

[acme@emilia git]$ perf record ./recvmmsg 5001 256 5000
usage: recvmmsg <port(def 5001)> <batch_size(def 8)> <timeout(def 10ms>

Waiting for datagrams...
nr_datagrams received: 256, remaining: 4416588ns
    5376 bytes received from filo.ghostprotocols.net in 21 datagrams
    768 bytes received from doppio.ghostprotocols.net in 3 datagrams
    256 bytes received from filo.ghostprotocols.net in 1 datagrams
    2304 bytes received from doppio.ghostprotocols.net in 9 datagrams
    256 bytes received from filo.ghostprotocols.net in 1 datagrams
    2560 bytes received from doppio.ghostprotocols.net in 10 datagrams
    256 bytes received from filo.ghostprotocols.net in 1 datagrams
<SNIP>

[acme@emilia git]$ perf report --sort comm,dso,symbol | head -30

#
# (4532588 samples)
#
# Overhead            Command  Shared Object     Symbol
# ........ .........  .........................  ......
#
     4.85%  recvmmsg  [kernel]                   [k] copy_user_generic_string
     3.17%  recvmmsg  [kernel]                   [k] _spin_lock_irqsave
     2.35%  recvmmsg  [kernel]                   [k] _spin_lock
     2.18%  recvmmsg  [kernel]                   [k] udp_recvmsg
     2.04%  recvmmsg  /lib64/libnss_files-2.5.so [.] internal_getent
     1.52%  recvmmsg  [kernel]                   [k] n_tty_write
     1.49%  recvmmsg  [kernel]                   [k] _spin_lock_bh
     1.44%  recvmmsg  [kernel]                   [k] __rcu_read_lock
     1.30%  recvmmsg  [kernel]                   [k] __skb_recv_datagram
     1.23%  recvmmsg  [kernel]                   [k] __rcu_read_unlock
     1.14%  recvmmsg  [kernel]                   [k] __cache_free
     1.14%  recvmmsg  [kernel]                   [k] avc_has_perm_noaudit
     1.12%  recvmmsg  /lib64/libc-2.5.so         [.] _IO_vfprintf_internal
     1.10%  recvmmsg  [kernel]                   [k] __sys_recvmsg
     1.06%  recvmmsg  ./recvmmsg                 [.] main
     1.04%  recvmmsg  [kernel]                   [k] csum_partial
     1.02%  recvmmsg  [kernel]                   [k] _spin_unlock_irqrestore
     0.98%  recvmmsg  [kernel]                   [k] n_tty_receive_buf
     0.88%  recvmmsg  /lib64/libc-2.5.so         [.] __GI_inet_pton
     0.87%  recvmmsg  [kernel]                   [k] system_call
     0.86%  recvmmsg  [kernel]                   [k] ktime_get_ts
     0.83%  recvmmsg  /lib64/libc-2.5.so         [.] __memchr
     0.76%  recvmmsg  /lib64/libc-2.5.so         [.] _IO_file_xsputn_internal
[acme@emilia git]$ 

We'll see after sk_prot->unlocked_recvmsg gets reintroduced and I remove silly
stuff such as fprintf from the test app... :-)

Thanks!

- Arnaldo

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index e590261..2a188e5 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -832,4 +832,5 @@ ia32_sys_call_table:
 	.quad compat_sys_pwritev
 	.quad compat_sys_rt_tgsigqueueinfo	/* 335 */
 	.quad sys_perf_counter_open
+	.quad compat_sys_recvmmsg
 ia32_syscall_end:
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index 732a307..3e72cae 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -342,6 +342,7 @@
 #define __NR_pwritev		334
 #define __NR_rt_tgsigqueueinfo	335
 #define __NR_perf_counter_open	336
+#define __NR_recvmmsg		337
 
 #ifdef __KERNEL__
 
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index 900e161..713a32a 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -661,6 +661,8 @@ __SYSCALL(__NR_pwritev, sys_pwritev)
 __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
 #define __NR_perf_counter_open			298
 __SYSCALL(__NR_perf_counter_open, sys_perf_counter_open)
+#define __NR_recvmmsg				299
+__SYSCALL(__NR_recvmmsg, sys_recvmmsg)
 
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index d51321d..4881b14 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -336,3 +336,4 @@ ENTRY(sys_call_table)
 	.long sys_pwritev
 	.long sys_rt_tgsigqueueinfo	/* 335 */
 	.long sys_perf_counter_open
+	.long sys_recvmmsg
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 421afb4..5ed3644 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -65,6 +65,12 @@ struct msghdr {
 	unsigned	msg_flags;
 };
 
+/* For recvmmsg/sendmmsg */
+struct mmsghdr {
+	struct msghdr   msg_hdr;
+	unsigned        msg_len;
+};
+
 /*
  *	POSIX 1003.1g - ancillary data object information
  *	Ancillary data consits of a sequence of pairs of
@@ -322,6 +328,10 @@ extern int move_addr_to_user(struct sockaddr *kaddr, int klen, void __user *uadd
 extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr *kaddr);
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
 
+struct timespec;
+
+extern int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
+			  unsigned int flags, struct timespec *timeout);
 #endif
 #endif /* not kernel and not glibc */
 #endif /* _LINUX_SOCKET_H */
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index c6c84ad..afefa61 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -25,6 +25,7 @@ struct linux_dirent64;
 struct list_head;
 struct msgbuf;
 struct msghdr;
+struct mmsghdr;
 struct msqid_ds;
 struct new_utsname;
 struct nfsctl_arg;
@@ -556,6 +557,9 @@ asmlinkage long sys_recv(int, void __user *, size_t, unsigned);
 asmlinkage long sys_recvfrom(int, void __user *, size_t, unsigned,
 				struct sockaddr __user *, int __user *);
 asmlinkage long sys_recvmsg(int fd, struct msghdr __user *msg, unsigned flags);
+asmlinkage long sys_recvmmsg(int fd, struct mmsghdr __user *msg,
+			     unsigned int vlen, unsigned flags,
+			     struct timespec __user *timeout);
 asmlinkage long sys_socket(int, int, int);
 asmlinkage long sys_socketpair(int, int, int, int __user *);
 asmlinkage long sys_socketcall(int call, unsigned long __user *args);
diff --git a/include/net/compat.h b/include/net/compat.h
index 5bbf8bf..96c38d8 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -18,6 +18,11 @@ struct compat_msghdr {
 	compat_uint_t	msg_flags;
 };
 
+struct compat_mmsghdr {
+	struct compat_msghdr msg_hdr;
+	compat_uint_t        msg_len;
+};
+
 struct compat_cmsghdr {
 	compat_size_t	cmsg_len;
 	compat_int_t	cmsg_level;
@@ -35,6 +40,9 @@ extern int get_compat_msghdr(struct msghdr *, struct compat_msghdr __user *);
 extern int verify_compat_iovec(struct msghdr *, struct iovec *, struct sockaddr *, int);
 extern asmlinkage long compat_sys_sendmsg(int,struct compat_msghdr __user *,unsigned);
 extern asmlinkage long compat_sys_recvmsg(int,struct compat_msghdr __user *,unsigned);
+extern asmlinkage long compat_sys_recvmmsg(int, struct compat_mmsghdr __user *,
+					   unsigned, unsigned,
+					   struct timespec __user *);
 extern asmlinkage long compat_sys_getsockopt(int, int, int, char __user *, int __user *);
 extern int put_cmsg_compat(struct msghdr*, int, int, int, void *);
 
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 68320f6..f581fb0 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -48,7 +48,9 @@ cond_syscall(sys_shutdown);
 cond_syscall(sys_sendmsg);
 cond_syscall(compat_sys_sendmsg);
 cond_syscall(sys_recvmsg);
+cond_syscall(sys_recvmmsg);
 cond_syscall(compat_sys_recvmsg);
+cond_syscall(compat_sys_recvmmsg);
 cond_syscall(sys_socketcall);
 cond_syscall(sys_futex);
 cond_syscall(compat_sys_futex);
diff --git a/net/compat.c b/net/compat.c
index 8d73905..6f04f2d 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -743,6 +743,29 @@ asmlinkage long compat_sys_recvmsg(int fd, struct compat_msghdr __user *msg, uns
 	return sys_recvmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
+asmlinkage long compat_sys_recvmmsg(int fd, struct compat_mmsghdr __user *mmsg,
+				    unsigned vlen, unsigned int flags,
+				    struct timespec __user *timeout)
+{
+	int datagrams;
+	struct timespec ktspec;
+	struct compat_timespec __user *utspec =
+			(struct compat_timespec __user *)timeout;
+
+	if (get_user(ktspec.tv_sec, &utspec->tv_sec) ||
+	    get_user(ktspec.tv_nsec, &utspec->tv_nsec))
+		return -EFAULT;
+
+	datagrams = __sys_recvmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
+				   flags | MSG_CMSG_COMPAT, &ktspec);
+	if (datagrams > 0 &&
+	    put_user(ktspec.tv_sec, &utspec->tv_sec) ||
+	    put_user(ktspec.tv_nsec, &utspec->tv_nsec))
+		datagrams = -EFAULT;
+
+	return datagrams;
+}
+
 asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 {
 	int ret;
diff --git a/net/socket.c b/net/socket.c
index 791d71a..1809a5e 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -668,10 +668,9 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
 
-static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-				 struct msghdr *msg, size_t size, int flags)
+static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
+				       struct msghdr *msg, size_t size, int flags)
 {
-	int err;
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
 	si->sock = sock;
@@ -680,13 +679,17 @@ static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	si->size = size;
 	si->flags = flags;
 
-	err = security_socket_recvmsg(sock, msg, size, flags);
-	if (err)
-		return err;
-
 	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
 }
 
+static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
+				 struct msghdr *msg, size_t size, int flags)
+{
+	int err = security_socket_recvmsg(sock, msg, size, flags);
+
+	return err ?: __sock_recvmsg_nosec(iocb, sock, msg, size, flags);
+}
+
 int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 		 size_t size, int flags)
 {
@@ -702,6 +705,21 @@ int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 	return ret;
 }
 
+static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
+			      size_t size, int flags)
+{
+	struct kiocb iocb;
+	struct sock_iocb siocb;
+	int ret;
+
+	init_sync_kiocb(&iocb, NULL);
+	iocb.private = &siocb;
+	ret = __sock_recvmsg_nosec(&iocb, sock, msg, size, flags);
+	if (-EIOCBQUEUED == ret)
+		ret = wait_on_sync_kiocb(&iocb);
+	return ret;
+}
+
 int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
 		   struct kvec *vec, size_t num, size_t size, int flags)
 {
@@ -1965,22 +1983,15 @@ out:
 	return err;
 }
 
-/*
- *	BSD recvmsg interface
- */
-
-SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
-		unsigned int, flags)
+static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
+			 struct msghdr *msg_sys, unsigned flags, int nosec)
 {
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
-	struct socket *sock;
 	struct iovec iovstack[UIO_FASTIOV];
 	struct iovec *iov = iovstack;
-	struct msghdr msg_sys;
 	unsigned long cmsg_ptr;
 	int err, iov_size, total_len, len;
-	int fput_needed;
 
 	/* kernel mode address */
 	struct sockaddr_storage addr;
@@ -1990,27 +2001,23 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
 	int __user *uaddr_len;
 
 	if (MSG_CMSG_COMPAT & flags) {
-		if (get_compat_msghdr(&msg_sys, msg_compat))
+		if (get_compat_msghdr(msg_sys, msg_compat))
 			return -EFAULT;
 	}
-	else if (copy_from_user(&msg_sys, msg, sizeof(struct msghdr)))
+	else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
 		return -EFAULT;
 
-	sock = sockfd_lookup_light(fd, &err, &fput_needed);
-	if (!sock)
-		goto out;
-
 	err = -EMSGSIZE;
-	if (msg_sys.msg_iovlen > UIO_MAXIOV)
-		goto out_put;
+	if (msg_sys->msg_iovlen > UIO_MAXIOV)
+		goto out;
 
 	/* Check whether to allocate the iovec area */
 	err = -ENOMEM;
-	iov_size = msg_sys.msg_iovlen * sizeof(struct iovec);
-	if (msg_sys.msg_iovlen > UIO_FASTIOV) {
+	iov_size = msg_sys->msg_iovlen * sizeof(struct iovec);
+	if (msg_sys->msg_iovlen > UIO_FASTIOV) {
 		iov = sock_kmalloc(sock->sk, iov_size, GFP_KERNEL);
 		if (!iov)
-			goto out_put;
+			goto out;
 	}
 
 	/*
@@ -2018,46 +2025,47 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
 	 *      kernel msghdr to use the kernel address space)
 	 */
 
-	uaddr = (__force void __user *)msg_sys.msg_name;
+	uaddr = (__force void __user *)msg_sys->msg_name;
 	uaddr_len = COMPAT_NAMELEN(msg);
 	if (MSG_CMSG_COMPAT & flags) {
-		err = verify_compat_iovec(&msg_sys, iov,
+		err = verify_compat_iovec(msg_sys, iov,
 					  (struct sockaddr *)&addr,
 					  VERIFY_WRITE);
 	} else
-		err = verify_iovec(&msg_sys, iov,
+		err = verify_iovec(msg_sys, iov,
 				   (struct sockaddr *)&addr,
 				   VERIFY_WRITE);
 	if (err < 0)
 		goto out_freeiov;
 	total_len = err;
 
-	cmsg_ptr = (unsigned long)msg_sys.msg_control;
-	msg_sys.msg_flags = flags & (MSG_CMSG_CLOEXEC|MSG_CMSG_COMPAT);
+	cmsg_ptr = (unsigned long)msg_sys->msg_control;
+	msg_sys->msg_flags = flags & (MSG_CMSG_CLOEXEC|MSG_CMSG_COMPAT);
 
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
-	err = sock_recvmsg(sock, &msg_sys, total_len, flags);
+	err = (nosec ? sock_recvmsg_nosec : sock_recvmsg)(sock, msg_sys,
+							  total_len, flags);
 	if (err < 0)
 		goto out_freeiov;
 	len = err;
 
 	if (uaddr != NULL) {
 		err = move_addr_to_user((struct sockaddr *)&addr,
-					msg_sys.msg_namelen, uaddr,
+					msg_sys->msg_namelen, uaddr,
 					uaddr_len);
 		if (err < 0)
 			goto out_freeiov;
 	}
-	err = __put_user((msg_sys.msg_flags & ~MSG_CMSG_COMPAT),
+	err = __put_user((msg_sys->msg_flags & ~MSG_CMSG_COMPAT),
 			 COMPAT_FLAGS(msg));
 	if (err)
 		goto out_freeiov;
 	if (MSG_CMSG_COMPAT & flags)
-		err = __put_user((unsigned long)msg_sys.msg_control - cmsg_ptr,
+		err = __put_user((unsigned long)msg_sys->msg_control - cmsg_ptr,
 				 &msg_compat->msg_controllen);
 	else
-		err = __put_user((unsigned long)msg_sys.msg_control - cmsg_ptr,
+		err = __put_user((unsigned long)msg_sys->msg_control - cmsg_ptr,
 				 &msg->msg_controllen);
 	if (err)
 		goto out_freeiov;
@@ -2066,12 +2074,147 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
 out_freeiov:
 	if (iov != iovstack)
 		sock_kfree_s(sock->sk, iov, iov_size);
-out_put:
+out:
+	return err;
+}
+
+/*
+ *	BSD recvmsg interface
+ */
+
+SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
+		unsigned int, flags)
+{
+	int fput_needed, err;
+	struct msghdr msg_sys;
+	struct socket *sock = sockfd_lookup_light(fd, &err, &fput_needed);
+
+	if (!sock)
+		goto out;
+
+	err = __sys_recvmsg(sock, msg, &msg_sys, flags, 0);
+
 	fput_light(sock->file, fput_needed);
 out:
 	return err;
 }
 
+/*
+ *     Linux recvmmsg interface
+ */
+
+int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
+		   unsigned int flags, struct timespec *timeout)
+{
+	int fput_needed, err, datagrams;
+	struct socket *sock;
+	struct mmsghdr __user *entry;
+	struct msghdr msg_sys;
+	struct timespec end_time;
+
+	if (timeout) {
+		/* Doesn't make much sense */
+		if (flags & MSG_DONTWAIT)
+			return -EINVAL;
+
+		if (poll_select_set_timeout(&end_time, timeout->tv_sec,
+					    timeout->tv_nsec))
+			return -EINVAL;
+	}
+
+	datagrams = 0;
+
+	sock = sockfd_lookup_light(fd, &err, &fput_needed);
+	if (!sock)
+		return err;
+
+	err = sock_error(sock->sk);
+	if (err)
+		goto out_put;
+
+	entry = mmsg;
+
+	while (datagrams < vlen) {
+		/*
+		 * No need to do ask LSM for more than the first datagram.
+		 */
+		err = __sys_recvmsg(sock, (struct msghdr __user *)entry,
+				    &msg_sys, flags, datagrams);
+		if (err < 0)
+			break;
+		err = put_user(err, &entry->msg_len);
+		if (err)
+			break;
+		++entry;
+		++datagrams;
+		
+		if (timeout) {
+			ktime_get_ts(timeout);
+			*timeout = timespec_sub(end_time, *timeout);
+			if (timeout->tv_sec < 0) {
+				timeout->tv_sec = timeout->tv_nsec = 0;
+				break;
+			}
+
+			/* Timeout, return less than vlen datagrams */
+			if (timeout->tv_nsec == 0 && timeout->tv_sec == 0)
+				break;
+		}
+
+		/* Out of band data, return right away */
+		if (msg_sys.msg_flags & MSG_OOB)
+			break;
+	}
+
+out_put:
+	fput_light(sock->file, fput_needed);
+
+	if (err == 0)
+		return datagrams;
+
+	if (datagrams != 0) {
+		/*
+		 * We may return less entries than requested (vlen) if the
+		 * sock is non block and there aren't enough datagrams...
+		 */
+		if (err != -EAGAIN) {
+			/*
+			 * ... or  if recvmsg returns an error after we
+			 * received some datagrams, where we record the
+			 * error to return on the next call or if the
+			 * app asks about it using getsockopt(SO_ERROR).
+			 */
+			sock->sk->sk_err = -err;
+		}
+
+		return datagrams;
+	}
+
+	return err;
+}
+
+SYSCALL_DEFINE5(recvmmsg, int, fd, struct mmsghdr __user *, mmsg,
+		unsigned int, vlen, unsigned int, flags,
+		struct timespec __user *, timeout)
+{
+	int datagrams;
+	struct timespec timeout_sys;
+
+	if (!timeout)
+		return __sys_recvmmsg(fd, mmsg, vlen, flags, NULL);
+
+	if (copy_from_user(&timeout_sys, timeout, sizeof(timeout_sys)))
+		return -EFAULT;
+
+	datagrams = __sys_recvmmsg(fd, mmsg, vlen, flags, &timeout_sys);
+
+	if (datagrams > 0 && 
+	    copy_to_user(timeout, &timeout_sys, sizeof(timeout_sys)))
+		datagrams = -EFAULT;
+
+	return datagrams;
+}
+
 #ifdef __ARCH_WANT_SYS_SOCKETCALL
 
 /* Argument list sizes for sys_socketcall */
