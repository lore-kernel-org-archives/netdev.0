From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Fwd: Cross thread shutdown of connected UDP socket, unexpected recvfrom behavior
Date: Fri, 15 Nov 2013 05:05:56 +0100
Message-ID: <20131115040556.GE26901@order.stressinduktion.org>
References: <CAApbN=Jm=zuDaVYALmGg5z_QfJJ3q13e9tshb7OpAtPQ8Ema1w@mail.gmail.com> <CAApbN=K8j+XQG+pQF2fxBSrDEPcjD242e9uP72azD9XWBzHcGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: mpb <mpb.mail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44229 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755084Ab3KOEF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 23:05:57 -0500
Content-Disposition: inline
In-Reply-To: <CAApbN=K8j+XQG+pQF2fxBSrDEPcjD242e9uP72azD9XWBzHcGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 12:07:20PM -0800, mpb wrote:
> I have a C/pthreads program with two threads ("main" and "thread").
> "thread" calls recvfrom on a connected UDP socket and blocks, waiting
> for input.  "main" then calls shutdown SHUT_RD on the socket.  In
> "thread", recvfrom returns, apparently successfully, returning a zero
> length string, and setting src_addr to a bogus(?) address family,
> port, and source address.
> 
> Is the above the correct behavior for recvfrom?
> 
> Here is output from my program.  "main" sends "hello\0", then "" (the
> empty string), then calls shutdown.  "thread" receives "hello\0", "",
> and then finally receives an empty string that was never sent!
> 
> thread  recvfrom: Success
>   rv 6  addrlen 16  fam 2  port 8000  addr 100007f
> 
> thread  recvfrom: Success
>   rv 0  addrlen 16  fam 2  port 8000  addr 100007f
> 
> main    shutdown: Success
>   rv 0
> 
> thread  recvfrom: Success
>   rv 0  addrlen 16  fam 59060  port 44237  addr deaadef0
> 
> The source code (2k) for the porgram is attached.  I'm running Ubuntu
> 13.04, kernel 3.8.0-19-generic #30-Ubuntu, on 32-bit i686.
> 
> For reference, this June 2000 LKML thread discusses calling close in a
> similar situation.
> http://www.gossamer-threads.com/lists/linux/kernel/144379
> 
> Please CC me if you have questions, otherwise I'll try to watch for
> answers in the list archives.

Changing such errno values is often brittle e.g. returning -EPIPE instead of
an EOF marker. It is coded very demonstrative to not return an error in
wait_for_more_packets, so I guess there will be a reason.

But at least we should not return uninitialized data from the stack:

diff --git a/net/socket.c b/net/socket.c
index c226ace..44499db 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1834,6 +1834,7 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
 	if (!sock)
 		goto out;
 
+	memset(&address, 0, sizeof(address));
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
 	msg.msg_iovlen = 1;
@@ -2228,6 +2229,8 @@ static int ___sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
 
 	uaddr = (__force void __user *)msg_sys->msg_name;
 	uaddr_len = COMPAT_NAMELEN(msg);
+	if (uaddr != NULL)
+		memset(&addr, 0, sizeof(addr));
 	if (MSG_CMSG_COMPAT & flags) {
 		err = verify_compat_iovec(msg_sys, iov, &addr, VERIFY_WRITE);
 	} else


I'll test and submit the above patch if no one else speaks up.

Greetings,

  Hannes
