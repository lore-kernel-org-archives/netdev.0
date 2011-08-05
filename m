From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 2/3] net: Cap number of elements for sendmmsg
Date: Fri, 5 Aug 2011 14:46:19 +1000
Message-ID: <20110805144619.729c631a@kryten>
References: <20110805000737.743684961@samba.org>
	<20110805000822.327910762@samba.org>
	<201108050429.p754TTBa030939@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, davem@davemloft.net,
	eparis@parisplace.org, casey@schaufler-ca.com, mjt@tls.msk.ru
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201108050429.p754TTBa030939@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

> I think 1024 is a reasonable value.
> But I also worry that programmers may wish to send more.
> 
> 
> Apart from the upper limit for vlen argument of sendmmsg()/recvmmsg(),
> we need to deal with stall problem (described below).

Capping vlen at 1024 should prevent that. Your patch does a signed
comparison which just reduces the maximum value by 1 bit doesn't it?

Keep in mind each element could have up to 1024 iovec entries at worst
case, so I think 1024 is a sane upper max.

Anton

> It may be possible to abuse sendmmsg() which was introduced in Linux
> 3.0 and recvmmsg() which was introduced in Linux 2.6.33 for
> triggering CPU stall warning.
> 
> I ran below program
> 
> ---------- Test program start ----------
> #include <string.h>
> #include <stdlib.h>
> #include <stdio.h>
> #include <unistd.h>
> #include <netdb.h>
> #include <sys/types.h>
> #include <sys/ioctl.h>
> #include <sys/socket.h>
> #include <asm/unistd.h>
> #include <errno.h>
> 
> #ifndef __NR_sendmmsg
> #if defined( __PPC__)
> #define __NR_sendmmsg	349
> #elif defined(__x86_64__)
> #define __NR_sendmmsg	307
> #elif defined(__i386__)
> #define __NR_sendmmsg	345
> #else
> #error __NR_sendmmsg not defined
> #endif
> #endif
> 
> struct mmsghdr {
> 	struct msghdr msg_hdr;
> 	unsigned int msg_len;
> };
> 
> static inline int sendmmsg(int fd, struct mmsghdr *mmsg, unsigned
> vlen, unsigned flags)
> {
> 	return syscall(__NR_sendmmsg, fd, mmsg, vlen, flags, NULL);
> }
> 
> #define NUMBATCH (1048576 * 64)
> 
> int main(int argc, char *argv[])
> {
> 	const int fd = socket(AF_INET, SOCK_DGRAM, 0);
> 	struct mmsghdr *datagrams;
> 	unsigned int i;
> 	struct iovec iovec = { };
> 	struct sockaddr_in addr = { };
> 	addr.sin_family = AF_INET;
> 	addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
> 	addr.sin_port = htons(10000);
> 	datagrams = calloc(sizeof(*datagrams), NUMBATCH);
> 	for (i = 0; i < NUMBATCH; ++i) {
> 		datagrams[i].msg_hdr.msg_iov = &iovec;
> 		datagrams[i].msg_hdr.msg_iovlen = 1;
> 		datagrams[i].msg_hdr.msg_name = &addr;
> 		datagrams[i].msg_hdr.msg_namelen = sizeof(addr);
> 	}
> 	printf("Calling sendmmsg()\n");
> 	printf("%d\n", sendmmsg(fd, datagrams, NUMBATCH, 0));
> 	printf("Done\n");
> 	return 0;
> }
> ---------- Test program end ----------
> 
> and got below output.
> 
> # time ./a.out
> Calling sendmmsg()
> INFO: rcu_sched_state detected stall on CPU 0 (t=15000 jiffies)
> 67108864
> Done
> 
> real    2m48.736s
> user    0m0.128s
> sys     0m16.489s
> 
> 
> 
> If this application created threads that matches number of CPUs
> available, and entered into sendmmsg(), the machine will hang for
> many seconds.
> 
> Also, signals are ignored when this application is in sendmmsg().
> That is, if this application is holding much RAM (like above program)
> and is selected by OOM-killer, this application cannot be killed
> until returns from sendmmsg().
> 
> Applying below patch solves the stall message and signal delaying
> problem. ----------------------------------------
> [PATCH] net: Fix sendmmsg() stall problem.
> 
> If the caller passed a huge value (e.g. 64M) to vlen argument of
> sendmmsg(), the caller triggers "INFO: rcu_sched_state detected stall
> on CPU X" message because there is no chance to call scheduler. Thus
> give a chance to call scheduler and also check for pending signal.
> 
> Also, if the caller passed a value where IS_ERR() returns true (e.g.
> UINT_MAX), the caller will get EOF and errno will be set to (e.g.)
> EPERM when all datagrams are successfully sent. Thus, limit the max
> value of vlen to INT_MAX.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: stable <stable@kernel.org> [3.0+]
> ---
>  net/socket.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> --- linux-3.0.orig/net/socket.c
> +++ linux-3.0/net/socket.c
> @@ -1999,6 +1999,8 @@ int __sys_sendmmsg(int fd, struct mmsghd
>  	struct compat_mmsghdr __user *compat_entry;
>  	struct msghdr msg_sys;
>  
> +	if ((int) vlen < 0)
> +		return -EINVAL;
>  	datagrams = 0;
>  
>  	sock = sockfd_lookup_light(fd, &err, &fput_needed);
> @@ -2035,6 +2037,9 @@ int __sys_sendmmsg(int fd, struct mmsghd
>  		if (err)
>  			break;
>  		++datagrams;
> +		cond_resched();
> +		if (signal_pending(current))
> +			break;
>  	}
>  
>  out_put:
> ----------------------------------------
> 
> The situation is similar regaring recvmmsg(). Although recvmmsg()
> less likely stalls than sendmmsg() does, it could happen if a huge
> number of datagrams are in the socket's receive queue and the caller
> attempted to fetch all of them at once. Thus, we may want below patch
> as well.
> 
> ----------------------------------------
> [PATCH] net: Fix recvmmsg() stall problem.
> 
> If the caller passed a huge value to vlen argument of recvmmsg() and
> there are enough datagrams in the socket's receive queue, trying to
> pick up all at once may trigger "INFO: rcu_sched_state detected stall
> on CPU X" message because there is no chance to call scheduler. Thus
> give a chance to call scheduler and also check for pending signal.
> 
> Also, if the caller passed a value where IS_ERR() returns true (e.g.
> UINT_MAX), the caller will get EOF and errno will be set to (e.g.)
> EPERM when all datagrams are successfully received. Thus, limit the
> max value of vlen to INT_MAX.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: stable <stable@kernel.org> [2.6.33+]
> ---
>  net/socket.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> --- linux-3.0.orig/net/socket.c
> +++ linux-3.0/net/socket.c
> @@ -2204,6 +2204,8 @@ int __sys_recvmmsg(int fd, struct mmsghd
>  	struct msghdr msg_sys;
>  	struct timespec end_time;
>  
> +	if ((int) vlen < 0)
> +		return -EINVAL;
>  	if (timeout &&
>  	    poll_select_set_timeout(&end_time, timeout->tv_sec,
>  				    timeout->tv_nsec))
> @@ -2247,6 +2249,9 @@ int __sys_recvmmsg(int fd, struct mmsghd
>  		if (err)
>  			break;
>  		++datagrams;
> +		cond_resched();
> +		if (signal_pending(current))
> +			break;
>  
>  		/* MSG_WAITFORONE turns on MSG_DONTWAIT after one
> packet */ if (flags & MSG_WAITFORONE)
> ----------------------------------------
> 

