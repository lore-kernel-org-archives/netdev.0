From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [RFC v2] net: Introduce recvmmsg socket syscall
Date: Thu, 11 Jun 2009 00:40:22 -0300
Message-ID: <20090611034022.GC22424@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
Content-Transfer-Encoding: 8bit
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
Received: from mx2.redhat.com ([66.187.237.31]:58321 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757149AbZFKDmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2009 23:42:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Meaning receive multiple messages, reducing the number of syscalls and
net stack entry/exit operations.

Next patches will introduce mechanisms where protocols that want to
optimize this operation will provide an unlocked_recvmsg operation.

This takes into account comments made by:

. Paul Moore: sock_recvmsg is called only for the first datagram,
  sock_recvmsg_nosec is used for the rest.

. Caitlin Bestler: recvmmsg now has a struct timespec timeout, that
  works in the same fashion as the ppoll one.

  If the underlying protocol returns a datagram with MSG_OOB set, this
  will make recvmmsg return right away with as many datagrams (+ the OOB
  one) it has received so far.

. Rémi Denis-Courmont & Steven Whitehouse: If we receive N < vlen
  datagrams and then recvmsg returns an error, recvmmsg will return
  the successfully received datagrams, store the error and return it
  in the next call.

I'll defer work on the subsequent optimization
(sk_prot->unlocked_recvmmsg) till we get the syscall API sorted out.

One thing to think about is if programs that provide a timeout for the
recvmmsg operation that is smaller than the one set (or the default) for
SO_RCVTIMEO should get their neck broken by inproper rope usage.

I thought about checking that and doing the equivalent to
sock_set_timeout(&sk->sk_rcvtimeo, recvmmsg_timeout), but felt like
recvmmsg was getting too many lines of code, opinions?

Also details such as adding the syscall to all the other archs syscall
tables and providing a socketcall interface for those that want it will
be addressed before final submission.

Attached also goes the updated recvmmsg canonical usage tool.

Thanks for all the comments so far and keep them coming! :-)

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
index 421afb4..5aaa78a 100644
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
index 5bbf8bf..bcde814 100644
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
+					   struct compat_timespec __user *);
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
index 8d73905..4fab14c 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -743,6 +743,15 @@ asmlinkage long compat_sys_recvmsg(int fd, struct compat_msghdr __user *msg, uns
 	return sys_recvmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
+asmlinkage long compat_sys_recvmmsg(int fd, struct compat_mmsghdr __user *mmsg,
+				    unsigned vlen, unsigned int flags,
+				    struct compat_timespec __user *timeout)
+{
+	return sys_recvmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
+			    flags | MSG_CMSG_COMPAT,
+			    (struct timespec __user *)timeout);
+}
+
 asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 {
 	int ret;
diff --git a/net/socket.c b/net/socket.c
index 791d71a..f9f1e20 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -702,6 +702,28 @@ int sock_recvmsg(struct socket *sock, struct msghdr *msg,
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
+
+	siocb.sock = sock;
+	siocb.scm = NULL;
+	siocb.msg = msg;
+	siocb.size = size;
+	siocb.flags = flags;
+
+	ret = sock->ops->recvmsg(&iocb, sock, msg, size, flags);
+	if (-EIOCBQUEUED == ret)
+		ret = wait_on_sync_kiocb(&iocb);
+	return ret;
+}
+
 int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
 		   struct kvec *vec, size_t num, size_t size, int flags)
 {
@@ -1965,22 +1987,15 @@ out:
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
@@ -1990,27 +2005,23 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
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
@@ -2018,46 +2029,47 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
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
@@ -2066,12 +2078,141 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
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
+SYSCALL_DEFINE5(recvmmsg, int, fd, struct mmsghdr __user *, mmsg,
+		unsigned int, vlen, unsigned int, flags,
+		struct timespec __user *, timeout)
+{
+	int fput_needed, err, datagrams;
+	struct socket *sock;
+	struct mmsghdr __user *entry;
+	struct msghdr msg_sys;
+	struct timespec end_time, delta;
+	struct compat_timespec *timeout_compat =
+		(struct compat_timespec *)timeout;
+
+	if (timeout) {
+		/* Doesn't make much sense */
+		if (flags & MSG_DONTWAIT)
+			return -EINVAL;
+
+		if (flags & MSG_CMSG_COMPAT) {
+			if (get_user(delta.tv_sec, &timeout_compat->tv_sec) ||
+			    get_user(delta.tv_nsec, &timeout_compat->tv_nsec))
+				return -EFAULT;
+		} else if (get_user(delta.tv_sec, &timeout->tv_sec) ||
+			 get_user(delta.tv_nsec, &timeout->tv_nsec))
+				return -EFAULT;
+
+		if (poll_select_set_timeout(&end_time, delta.tv_sec,
+					    delta.tv_nsec))
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
+			ktime_get_ts(&delta);
+			delta = timespec_sub(end_time, delta);
+			if (delta.tv_sec < 0)
+				delta.tv_sec = delta.tv_nsec = 0;
+
+			/* Timeout, return less than vlen datagrams */
+			if (delta.tv_sec == 0 && delta.tv_nsec == 0)
+				break;
+		}
+
+		/* Out of band data, return right away */
+		if (msg_sys.msg_flags & MSG_OOB)
+			break;
+	}
+
+	if (timeout) {
+		if (flags & MSG_CMSG_COMPAT) {
+			if (put_user(delta.tv_sec, &timeout_compat->tv_sec) ||
+			    put_user(delta.tv_nsec, &timeout_compat->tv_nsec))
+				err = -EFAULT;
+		} else if (put_user(delta.tv_sec, &timeout->tv_sec) ||
+			   put_user(delta.tv_nsec, &timeout->tv_nsec))
+				err = -EFAULT;
+	}
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
 #ifdef __ARCH_WANT_SYS_SOCKETCALL
 
 /* Argument list sizes for sys_socketcall */

--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="recvmmsg.c"

#include <stdlib.h>
#include <syscall.h>
#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <poll.h>
#include <string.h>

struct mmsghdr {
	struct msghdr	msg_hdr;
	unsigned	msg_len;
};

#if defined(__x86_64__) || defined(__i386__)
#include "linux-2.6-tip/arch/x86/include/asm/unistd.h"
#endif

#ifndef NSEC_PER_MSEC
#define NSEC_PER_MSEC	1000000UL
#endif

static inline int recvmmsg(int fd, struct mmsghdr *mmsg,
			   unsigned vlen, unsigned flags,
			   struct timespec *timeout)
{
	return syscall(__NR_recvmmsg, fd, mmsg, vlen, flags, timeout);
}

static void print_stats_peer(struct mmsghdr *datagram, int count, int bytes)
{
	char peer[1024];
	int err = getnameinfo(datagram->msg_hdr.msg_name,
			      datagram->msg_hdr.msg_namelen,
			      peer, sizeof(peer), NULL, 0, 0);
	if (err != 0) {
		fprintf(stderr, "error using getnameinfo: %s\n",
			gai_strerror(err));
			return;
		}
	printf("    %d bytes received from %s in %d datagrams\n",
	       bytes, peer, count);
}

int main(int argc, char *argv[])
{
	struct addrinfo *host;
	struct addrinfo hints = {
		.ai_family   = AF_INET,
		.ai_socktype = SOCK_DGRAM,
		.ai_protocol = IPPROTO_UDP,
		.ai_flags    = AI_PASSIVE,
	};
	const char *port = "5001";
	int batch_size = 8;
	long timeout = 10 * NSEC_PER_MSEC;
	int err, fd;
	int i;

	if (argc > 1)
		port = argv[1];

	if (argc > 2)
		batch_size = atoi(argv[2]);

	if (argc > 3)
		timeout = atol(argv[3]) * NSEC_PER_MSEC;

	char buf[batch_size][256];
	struct iovec iovec[batch_size][1];
	struct sockaddr addr[batch_size];
	struct mmsghdr datagrams[batch_size];

	printf("usage: recvmmsg <port(def 5001)> <batch_size(def 8)> "
	       "<timeout(def 10ms>\n\nWaiting for datagrams...\n");

	err = getaddrinfo(NULL, port, &hints, &host);
	if (err != 0) {
		fprintf(stderr, "error using getaddrinfo: %s\n",
			gai_strerror(err));
		goto out;
	}
	
	fd = socket(host->ai_family, host->ai_socktype, host->ai_protocol);
	if (fd < 0) {
		perror("socket: ");
		goto out_freeaddrinfo;
	}

	if (bind(fd, host->ai_addr, host->ai_addrlen) < 0) {
		perror("bind: ");
		goto out_close_server;
	}

	for (i = 0; i < batch_size; ++i) {
		iovec[i][0].iov_base = buf[i];
		iovec[i][0].iov_len  = sizeof(buf[i]);
		datagrams[i].msg_hdr.msg_iov	 = iovec[i];
		datagrams[i].msg_hdr.msg_iovlen	 = 1;
		datagrams[i].msg_hdr.msg_name	 = &addr[i];
		datagrams[i].msg_hdr.msg_namelen = sizeof(addr[i]);
	}

	struct pollfd pfds[1] = {
		[0] = {
			.fd = fd,
			.events = POLLIN,
		},
	};

	while (1) {
		struct timespec timeout = { .tv_nsec = 10 * NSEC_PER_MSEC, };

		if (poll(pfds, 1, -1) < 0) {
			perror("poll: ");
			return EXIT_FAILURE;
		}

		int nr_datagrams = recvmmsg(fd, datagrams, batch_size,
					    0, &timeout);

		if (nr_datagrams == 0) {
			perror("recvmmsg: ");
			return EXIT_FAILURE;
		}

		printf("nr_datagrams received: %d, remaining: %luns\n",
		       nr_datagrams, timeout.tv_nsec);
		int peer_count = 1;
		int peer_bytes = datagrams[0].msg_len;
		for (i = 1; i < nr_datagrams; ++i) {
			if (memcmp(datagrams[i - 1].msg_hdr.msg_name,
				   datagrams[i].msg_hdr.msg_name,
				   datagrams[i].msg_hdr.msg_namelen) == 0) {
				++peer_count;
				peer_bytes += datagrams[i].msg_len;
				continue;
			}
			
			print_stats_peer(&datagrams[i - 1],
					 peer_count, peer_bytes);
			peer_bytes = datagrams[i].msg_len;
			peer_count = 1;
		}

		print_stats_peer(&datagrams[nr_datagrams - 1],
				 peer_count, peer_bytes);
	}
out_close_server:
	close(fd);
out_freeaddrinfo:
	freeaddrinfo(host);
out:
	return err;
}

--VS++wcV0S1rZb1Fb--
