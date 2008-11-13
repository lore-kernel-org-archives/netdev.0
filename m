From: "Michael Kerrisk" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] reintroduce accept4
Date: Thu, 13 Nov 2008 16:51:56 -0500
Message-ID: <517f3f820811131351l1305b2d2u43ab4e0601d97f93@mail.gmail.com>
References: <200810261641.m9QGfotr024285@hs20-bc2-1.build.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Subrata Modak" <subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Ulrich Drepper" <drepper-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Davide Libenzi" <davidel-AhlLAIvw+VEjIGhXcJzhZg@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Roland McGrath" <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Oleg Nesterov" <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>,
	"Christoph Hellwig" <hch-jcswGhMUV9g@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "Alan Cox" <alan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Jakub Jelinek" <jakub-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Michael Kerrisk" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200810261641.m9QGfotr024285-sQhldQRnEDHy+ZiRM8QlFPXAX3CI6PSWQQ4Iyu8u01E@public.gmane.org>
Content-Disposition: inline
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andrew,

On 10/26/08, Ulrich Drepper <drepper-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> This patch reintroduces accept4, replacing paccept.  It's easy to see that
> the patch only removes code and then redirects existing code away from the
> removed functions.  Since the paccept code sans signal handling was never
> in question I think there is no reason to quarantine the patch first.

I see you accepted this patch into -mm.  I've finally got to looking
at and testing this, so:

Tested-by: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

In my tests, everything looks fine.  I'll forward my test program in a
follow-up mail.

I think Ulrich wanted to try to see this patch in for 2.6.28; it's
past the merge window of course, so it's up to you, but I have no
problem with that.  The API is the one that Ulrich initially proposed,
before taking a detour into paccept()
(http://thread.gmane.org/gmane.linux.kernel/671443 ), which I argued
against (http://thread.gmane.org/gmane.linux.kernel/723952,
http://thread.gmane.org/gmane.linux.network/106071/), since I (and
Roland) could see no reason for the added complexity of a signal set
argument (like pselect()/ppoll()/epoll_pwait()).  (In any case, if
someone does come up with a compelling reason to add a sigset
argument, then we can add it via the use of a new flag bit.)

My only argument is with the name of the new sysytem call.

> I've updated the test program which now looks as follows:

(I assume that there had been no testing on x86-32, since, the
__i386__ ifdef's notwithstanding,  the program below can't work on
x86-32 -- sys_socketcall() takes its arguments packaged into an array
on x86-32, not as an inline list.)

Andrew, you noted a lack of explanation accompanying the original
patch.  Here's something to fill the gap, and which may be suitable
for the changelog.

==
Introduce a new accept4() system call.  The addition of this system
call matches analogous changes in 2.6.27 (dup3(), evenfd2(),
signalfd4(), inotify_init1(), epoll_create1(), pipe2()) which added
new system calls that differed from analogous traditional system calls
in adding a flags argument that can be used to access additional
functionality. The accept4() system call is exactly the same as
accept(), except that it adds a flags bit-mask argument.  Two flags
are initially implemented.  (Most of the new system calls in 2.6.27
also had both of these flags.)  SOCK_CLOEXEC causes the close-on-exec
(FD_CLOEXEC) flag to be enabled for the new file descriptor returned
by accept4().  This is a useful security feature to avoid leaking
information in a multithreaded program where one thread is doing an
accept() at the same time as another thread is doing a fork() plus
exec().  (More details here:
http://udrepper.livejournal.com/20407.html "Secure File Descriptor
Handling", Ulrich Drepper)  The other flag is SOCK_NONBLOCK, which
causes the O_NONBLOCK flag to be enabled on the new open file
description created by accept4().  (This flag is merely a convenience,
saving the use of additional calls fcntl(F_GETFL) and fcntl (F_SETFL)
to achieve the same result.)
==

For the curious, some further background on accept4() and the new
system calls in 2.6.27 is at
http://linux-man-pages.blogspot.com/2008/10/recent-changes-in-file-descriptor.html
and http://lwn.net/Articles/281965/)

Cheers,

Michael

> #include <fcntl.h>
> #include <pthread.h>
> #include <stdio.h>
> #include <unistd.h>
> #include <netinet/in.h>
> #include <sys/socket.h>
> #include <sys/syscall.h>
>
> #ifdef __x86_64__
> #define __NR_accept4 288
> #define SOCK_CLOEXEC O_CLOEXEC
> #elif __i386__
> #define SYS_ACCEPT4     18
> #define USE_SOCKETCALL 1
> #define SOCK_CLOEXEC O_CLOEXEC
> #else
> #error "define syscall numbers for this architecture"
> #endif
>
> #define PORT 57392
>
> static pthread_barrier_t b;
>
> static void *
> tf (void *arg)
> {
>   pthread_barrier_wait (&b);
>   int s = socket (AF_INET, SOCK_STREAM, 0);
>   struct sockaddr_in sin;
>   sin.sin_family = AF_INET;
>   sin.sin_addr.s_addr = htonl (INADDR_LOOPBACK);
>   sin.sin_port = htons (PORT);
>   connect (s, (const struct sockaddr *) &sin, sizeof (sin));
>   close (s);
>   pthread_barrier_wait (&b);
>
>   pthread_barrier_wait (&b);
>   s = socket (AF_INET, SOCK_STREAM, 0);
>   sin.sin_family = AF_INET;
>   sin.sin_addr.s_addr = htonl (INADDR_LOOPBACK);
>   sin.sin_port = htons (PORT + 1);
>   connect (s, (const struct sockaddr *) &sin, sizeof (sin));
>   close (s);
>   return NULL;
> }
>
> int
> main (void)
> {
>   alarm (5);
>
>   int status = 0;
>
>   pthread_barrier_init (&b, NULL, 2);
>
>   pthread_t th;
>   if (pthread_create (&th, NULL, tf, NULL) != 0)
>     {
>       puts ("pthread_create failed");
>       status = 1;
>     }
>   else
>     {
>       int s = socket (AF_INET, SOCK_STREAM, 0);
>       int fl = 1;
>       setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &fl, sizeof (fl));
>       struct sockaddr_in sin;
>       sin.sin_family = AF_INET;
>       sin.sin_addr.s_addr = htonl (INADDR_LOOPBACK);
>       sin.sin_port = htons (PORT);
>       bind (s, (struct sockaddr *) &sin, sizeof (sin));
>       listen (s, SOMAXCONN);
>
>       pthread_barrier_wait (&b);
>
>       int s2 = accept (s, NULL, 0);
>       if (s2 < 0)
>         {
>           puts ("accept failed");
>           status = 1;
>         }
>       else
>         {
>           int fl = fcntl (s2, F_GETFD);
>           if ((fl & FD_CLOEXEC) != 0)
>             {
>               puts ("accept did set CLOEXEC");
>               status = 1;
>             }
>
>           close (s2);
>         }
>
>       close (s);
>
>       pthread_barrier_wait (&b);
>
>       sin.sin_family = AF_INET;
>       sin.sin_addr.s_addr = htonl (INADDR_LOOPBACK);
>       sin.sin_port = htons (PORT + 1);
>       s = socket (AF_INET, SOCK_STREAM, 0);
>       bind (s, (struct sockaddr *) &sin, sizeof (sin));
>       listen (s, SOMAXCONN);
>
>       pthread_barrier_wait (&b);
>
> #if USE_SOCKETCALL
>       s2 = syscall (__NR_socketcall, SYS_ACCEPT4, s, NULL, 0, SOCK_CLOEXEC);
> #else
>       s2 = syscall (__NR_accept4, s, NULL, 0, SOCK_CLOEXEC);
> #endif
>       if (s2 < 0)
>         {
>           puts ("accept4 failed");
>           status = 1;
>         }
>       else
>         {
>           int fl = fcntl (s2, F_GETFD);
>           if ((fl & FD_CLOEXEC) == 0)
>             {
>               puts ("accept4 did not set CLOEXEC");
>               status = 1;
>             }
>
>           close (s2);
>         }
>
>       close (s);
>     }
>
>   return status;
> }
>
>
>  arch/x86/include/asm/unistd_64.h |    4 -
>  include/linux/net.h              |    6 --
>  include/linux/syscalls.h         |    3 -
>  kernel/sys_ni.c                  |    2
>  net/compat.c                     |   50 ++----------------------
>  net/socket.c                     |   80
> ++++-----------------------------------
>  6 files changed, 21 insertions(+), 124 deletions(-)
>
>
> Signed-off-by: Ulrich Drepper <drepper-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>
> diff --git a/arch/x86/include/asm/unistd_64.h
> b/arch/x86/include/asm/unistd_64.h
> index 834b2c1..d2e415e 100644
> --- a/arch/x86/include/asm/unistd_64.h
> +++ b/arch/x86/include/asm/unistd_64.h
> @@ -639,8 +639,8 @@ __SYSCALL(__NR_fallocate, sys_fallocate)
>  __SYSCALL(__NR_timerfd_settime, sys_timerfd_settime)
>  #define __NR_timerfd_gettime			287
>  __SYSCALL(__NR_timerfd_gettime, sys_timerfd_gettime)
> -#define __NR_paccept				288
> -__SYSCALL(__NR_paccept, sys_paccept)
> +#define __NR_accept4				288
> +__SYSCALL(__NR_accept4, sys_accept4)
>  #define __NR_signalfd4				289
>  __SYSCALL(__NR_signalfd4, sys_signalfd4)
>  #define __NR_eventfd2				290
> diff --git a/include/linux/net.h b/include/linux/net.h
> index 6dc14a2..4515efa 100644
> --- a/include/linux/net.h
> +++ b/include/linux/net.h
> @@ -40,7 +40,7 @@
>  #define SYS_GETSOCKOPT	15		/* sys_getsockopt(2)		*/
>  #define SYS_SENDMSG	16		/* sys_sendmsg(2)		*/
>  #define SYS_RECVMSG	17		/* sys_recvmsg(2)		*/
> -#define SYS_PACCEPT	18		/* sys_paccept(2)		*/
> +#define SYS_ACCEPT4	18		/* sys_accept4(2)		*/
>
>  typedef enum {
>  	SS_FREE = 0,			/* not allocated		*/
> @@ -100,7 +100,7 @@ enum sock_type {
>   * remaining bits are used as flags. */
>  #define SOCK_TYPE_MASK 0xf
>
> -/* Flags for socket, socketpair, paccept */
> +/* Flags for socket, socketpair, accept4 */
>  #define SOCK_CLOEXEC	O_CLOEXEC
>  #ifndef SOCK_NONBLOCK
>  #define SOCK_NONBLOCK	O_NONBLOCK
> @@ -223,8 +223,6 @@ extern int 	     sock_map_fd(struct socket *sock, int
> flags);
>  extern struct socket *sockfd_lookup(int fd, int *err);
>  #define		     sockfd_put(sock) fput(sock->file)
>  extern int	     net_ratelimit(void);
> -extern long	     do_accept(int fd, struct sockaddr __user *upeer_sockaddr,
> -			       int __user *upeer_addrlen, int flags);
>
>  #define net_random()		random32()
>  #define net_srandom(seed)	srandom32((__force u32)seed)
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index d6ff145..04fb47b 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -410,8 +410,7 @@ asmlinkage long sys_getsockopt(int fd, int level, int
> optname,
>  asmlinkage long sys_bind(int, struct sockaddr __user *, int);
>  asmlinkage long sys_connect(int, struct sockaddr __user *, int);
>  asmlinkage long sys_accept(int, struct sockaddr __user *, int __user *);
> -asmlinkage long sys_paccept(int, struct sockaddr __user *, int __user *,
> -			    const __user sigset_t *, size_t, int);
> +asmlinkage long sys_accept4(int, struct sockaddr __user *, int __user *,
> int);
>  asmlinkage long sys_getsockname(int, struct sockaddr __user *, int __user
> *);
>  asmlinkage long sys_getpeername(int, struct sockaddr __user *, int __user
> *);
>  asmlinkage long sys_send(int, void __user *, size_t, unsigned);
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index a77b27b..e14a232 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -31,7 +31,7 @@ cond_syscall(sys_socketpair);
>  cond_syscall(sys_bind);
>  cond_syscall(sys_listen);
>  cond_syscall(sys_accept);
> -cond_syscall(sys_paccept);
> +cond_syscall(sys_accept4);
>  cond_syscall(sys_connect);
>  cond_syscall(sys_getsockname);
>  cond_syscall(sys_getpeername);
> diff --git a/net/compat.c b/net/compat.c
> index 67fb6a3..50ce0a9 100644
> --- a/net/compat.c
> +++ b/net/compat.c
> @@ -725,7 +725,7 @@ EXPORT_SYMBOL(compat_mc_getsockopt);
>  static unsigned char nas[19]={AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
>  				AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
>  				AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
> -				AL(6)};
> +				AL(4)};
>  #undef AL
>
>  asmlinkage long compat_sys_sendmsg(int fd, struct compat_msghdr __user
> *msg, unsigned flags)
> @@ -738,52 +738,13 @@ asmlinkage long compat_sys_recvmsg(int fd, struct
> compat_msghdr __user *msg, uns
>  	return sys_recvmsg(fd, (struct msghdr __user *)msg, flags |
> MSG_CMSG_COMPAT);
>  }
>
> -asmlinkage long compat_sys_paccept(int fd, struct sockaddr __user
> *upeer_sockaddr,
> -				   int __user *upeer_addrlen,
> -				   const compat_sigset_t __user *sigmask,
> -				   compat_size_t sigsetsize, int flags)
> -{
> -	compat_sigset_t ss32;
> -	sigset_t ksigmask, sigsaved;
> -	int ret;
> -
> -	if (sigmask) {
> -		if (sigsetsize != sizeof(compat_sigset_t))
> -			return -EINVAL;
> -		if (copy_from_user(&ss32, sigmask, sizeof(ss32)))
> -			return -EFAULT;
> -		sigset_from_compat(&ksigmask, &ss32);
> -
> -		sigdelsetmask(&ksigmask, sigmask(SIGKILL)|sigmask(SIGSTOP));
> -		sigprocmask(SIG_SETMASK, &ksigmask, &sigsaved);
> -	}
> -
> -	ret = do_accept(fd, upeer_sockaddr, upeer_addrlen, flags);
> -
> -	if (ret == -ERESTARTNOHAND) {
> -		/*
> -		 * Don't restore the signal mask yet. Let do_signal() deliver
> -		 * the signal on the way back to userspace, before the signal
> -		 * mask is restored.
> -		 */
> -		if (sigmask) {
> -			memcpy(&current->saved_sigmask, &sigsaved,
> -			       sizeof(sigsaved));
> -			set_restore_sigmask();
> -		}
> -	} else if (sigmask)
> -		sigprocmask(SIG_SETMASK, &sigsaved, NULL);
> -
> -	return ret;
> -}
> -
>  asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
>  {
>  	int ret;
>  	u32 a[6];
>  	u32 a0, a1;
>
> -	if (call < SYS_SOCKET || call > SYS_PACCEPT)
> +	if (call < SYS_SOCKET || call > SYS_ACCEPT4)
>  		return -EINVAL;
>  	if (copy_from_user(a, args, nas[call]))
>  		return -EFAULT;
> @@ -804,7 +765,7 @@ asmlinkage long compat_sys_socketcall(int call, u32
> __user *args)
>  		ret = sys_listen(a0, a1);
>  		break;
>  	case SYS_ACCEPT:
> -		ret = do_accept(a0, compat_ptr(a1), compat_ptr(a[2]), 0);
> +		ret = sys_accept4(a0, compat_ptr(a1), compat_ptr(a[2]), 0);
>  		break;
>  	case SYS_GETSOCKNAME:
>  		ret = sys_getsockname(a0, compat_ptr(a1), compat_ptr(a[2]));
> @@ -844,9 +805,8 @@ asmlinkage long compat_sys_socketcall(int call, u32
> __user *args)
>  	case SYS_RECVMSG:
>  		ret = compat_sys_recvmsg(a0, compat_ptr(a1), a[2]);
>  		break;
> -	case SYS_PACCEPT:
> -		ret = compat_sys_paccept(a0, compat_ptr(a1), compat_ptr(a[2]),
> -					 compat_ptr(a[3]), a[4], a[5]);
> +	case SYS_ACCEPT4:
> +		ret = sys_accept4(a0, compat_ptr(a1), compat_ptr(a[2]), a[3]);
>  		break;
>  	default:
>  		ret = -EINVAL;
> diff --git a/net/socket.c b/net/socket.c
> index 2b7a4b5..8e72806 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1427,8 +1427,8 @@ asmlinkage long sys_listen(int fd, int backlog)
>   *	clean when we restucture accept also.
>   */
>
> -long do_accept(int fd, struct sockaddr __user *upeer_sockaddr,
> -	       int __user *upeer_addrlen, int flags)
> +asmlinkage long sys_accept4(int fd, struct sockaddr __user *upeer_sockaddr,
> +			    int __user *upeer_addrlen, int flags)
>  {
>  	struct socket *sock, *newsock;
>  	struct file *newfile;
> @@ -1511,66 +1511,10 @@ out_fd:
>  	goto out_put;
>  }
>
> -#if 0
> -#ifdef HAVE_SET_RESTORE_SIGMASK
> -asmlinkage long sys_paccept(int fd, struct sockaddr __user *upeer_sockaddr,
> -			    int __user *upeer_addrlen,
> -			    const sigset_t __user *sigmask,
> -			    size_t sigsetsize, int flags)
> -{
> -	sigset_t ksigmask, sigsaved;
> -	int ret;
> -
> -	if (sigmask) {
> -		/* XXX: Don't preclude handling different sized sigset_t's.  */
> -		if (sigsetsize != sizeof(sigset_t))
> -			return -EINVAL;
> -		if (copy_from_user(&ksigmask, sigmask, sizeof(ksigmask)))
> -			return -EFAULT;
> -
> -		sigdelsetmask(&ksigmask, sigmask(SIGKILL)|sigmask(SIGSTOP));
> -		sigprocmask(SIG_SETMASK, &ksigmask, &sigsaved);
> -        }
> -
> -	ret = do_accept(fd, upeer_sockaddr, upeer_addrlen, flags);
> -
> -	if (ret < 0 && signal_pending(current)) {
> -		/*
> -		 * Don't restore the signal mask yet. Let do_signal() deliver
> -		 * the signal on the way back to userspace, before the signal
> -		 * mask is restored.
> -		 */
> -		if (sigmask) {
> -			memcpy(&current->saved_sigmask, &sigsaved,
> -			       sizeof(sigsaved));
> -			set_restore_sigmask();
> -		}
> -	} else if (sigmask)
> -		sigprocmask(SIG_SETMASK, &sigsaved, NULL);
> -
> -	return ret;
> -}
> -#else
> -asmlinkage long sys_paccept(int fd, struct sockaddr __user *upeer_sockaddr,
> -			    int __user *upeer_addrlen,
> -			    const sigset_t __user *sigmask,
> -			    size_t sigsetsize, int flags)
> -{
> -	/* The platform does not support restoring the signal mask in the
> -	 * return path.  So we do not allow using paccept() with a signal
> -	 * mask.  */
> -	if (sigmask)
> -		return -EINVAL;
> -
> -	return do_accept(fd, upeer_sockaddr, upeer_addrlen, flags);
> -}
> -#endif
> -#endif
> -
>  asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
>  			   int __user *upeer_addrlen)
>  {
> -	return do_accept(fd, upeer_sockaddr, upeer_addrlen, 0);
> +	return sys_accept4(fd, upeer_sockaddr, upeer_addrlen, 0);
>  }
>
>  /*
> @@ -2097,7 +2041,7 @@ static const unsigned char nargs[19]={
>  	AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
>  	AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
>  	AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
> -	AL(6)
> +	AL(4)
>  };
>
>  #undef AL
> @@ -2116,7 +2060,7 @@ asmlinkage long sys_socketcall(int call, unsigned long
> __user *args)
>  	unsigned long a0, a1;
>  	int err;
>
> -	if (call < 1 || call > SYS_PACCEPT)
> +	if (call < 1 || call > SYS_ACCEPT4)
>  		return -EINVAL;
>
>  	/* copy_from_user should be SMP safe. */
> @@ -2144,9 +2088,8 @@ asmlinkage long sys_socketcall(int call, unsigned long
> __user *args)
>  		err = sys_listen(a0, a1);
>  		break;
>  	case SYS_ACCEPT:
> -		err =
> -		    do_accept(a0, (struct sockaddr __user *)a1,
> -			      (int __user *)a[2], 0);
> +		err = sys_accept4(a0, (struct sockaddr __user *)a1,
> +				  (int __user *)a[2], 0);
>  		break;
>  	case SYS_GETSOCKNAME:
>  		err =
> @@ -2193,12 +2136,9 @@ asmlinkage long sys_socketcall(int call, unsigned
> long __user *args)
>  	case SYS_RECVMSG:
>  		err = sys_recvmsg(a0, (struct msghdr __user *)a1, a[2]);
>  		break;
> -	case SYS_PACCEPT:
> -		err =
> -		    sys_paccept(a0, (struct sockaddr __user *)a1,
> -			        (int __user *)a[2],
> -				(const sigset_t __user *) a[3],
> -				a[4], a[5]);
> +	case SYS_ACCEPT4:
> +		err = sys_accept4(a0, (struct sockaddr __user *)a1,
> +				  (int __user *)a[2], a[3]);
>  		break;
>  	default:
>  		err = -EINVAL;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/ Found a documentation bug?
http://www.kernel.org/doc/man-pages/reporting_bugs.html
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
