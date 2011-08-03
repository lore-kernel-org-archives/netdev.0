From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Wed, 3 Aug 2011 23:29:57 +1000
Message-ID: <20110803232957.5e7a5d0a@kryten>
References: <20110802.050115.1714327089688495866.davem@davemloft.net>
	<201108022211.BJI69291.QLFFJMOOtOHVSF@I-love.SAKURA.ne.jp>
	<201108030325.p733Pplb030986@www262.sakura.ne.jp>
	<20110802.203836.40056483416201909.davem@davemloft.net>
	<20110803134752.31347b64@kryten>
	<201108032120.CHC60420.OVOFQFHMJLSOtF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eparis@parisplace.org, casey@schaufler-ca.com,
	mjt@tls.msk.ru, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201108032120.CHC60420.OVOFQFHMJLSOtF@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > I much prefer to make the error handling more correct, rather than
> > making sendmmsg() have fundamentally different semantics depending
> > upon the underlying LSM.
> 
> Well, the way how sendmmsg() returns error code is tricky. But
> recvmmsg() has been doing in this way for a while. So, for symmetry
> reason, maybe sendmmsg() should do as with recvmmsg() since it is too
> late to change recvmmsg()'s way.
> 
> So, programmers should be warned (in the man pages) that they should
> always call getsockopt(SO_ERROR) (in order to clear the error code)
> if sendmmsg() or recvmmsg() returned less than requested.

As you suggest, I wanted to mirror how recvmmsg returns errors. But I
now agree with Dave, we should not return an error if we managed to send
any datagrams.

Perhaps we need to modify recvmmsg to do the same?

> By the way, don't we want integer overflow check and/or
> cond_resched() here? I don't know whether there is an arch where
> userspace can allocate (1 << BITS_PER_INT) * sizeof(struct msghdr)
> bytes using malloc() and kernel can allocate huge memory for the
> socket buffer.
> 
> #include <stdio.h>
> int main(int argc, char *argv[])
> {
>         int datagrams = 0;
>         unsigned int vlen = 4294967290U;
>         while (datagrams < vlen)
>                 datagrams++;
>         printf("%u\n", datagrams);
>         return 0;
> }
> 
> I think this program (on x86_32) will print an IS_ERR() value upon
> success.

Good catch. I wonder if we can do something similar to read/write where
we just truncate the length. What value should we use? One option is to
reuse UIO_MAXIOV (1024).

The following patch is compiled tested only so far.

Anton
--

[PATCH] net: Cap number of elements for recvmmsg and sendmmsg 

To limit the amount of time we can spend in recvmmsg and sendmmsg,
cap the number of elements to UIO_MAXIOV (currently 1024). 
       
Signed-off-by: Anton Blanchard <anton@samba.org>
Cc: <stable@kernel.org>
---

diff --git a/net/socket.c b/net/socket.c
index b1cbbcd..ad345b1 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1999,6 +1999,9 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	struct compat_mmsghdr __user *compat_entry;
 	struct msghdr msg_sys;
 
+	if (vlen > UIO_MAXIOV)
+		vlen = UIO_MAXIOV;
+
 	datagrams = 0;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
@@ -2199,6 +2202,9 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	struct msghdr msg_sys;
 	struct timespec end_time;
 
+	if (vlen > UIO_MAXIOV)
+		vlen = UIO_MAXIOV;
+
 	if (timeout &&
 	    poll_select_set_timeout(&end_time, timeout->tv_sec,
 				    timeout->tv_nsec))
