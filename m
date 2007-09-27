From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Zero-length write() does not generate a datagram on
 connected socket
Date: Thu, 27 Sep 2007 13:53:34 -0700 (PDT)
Message-ID: <20070927.135334.56943477.davem@davemloft.net>
References: <bug-5731-100@http.bugzilla.kernel.org/>
	<20070922094432.E9BEA108010@picon.linux-foundation.org>
	<20070924153435.14249225@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39221
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754582AbXI0Uxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 16:53:35 -0400
In-Reply-To: <20070924153435.14249225@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 24 Sep 2007 15:34:35 -0700

> The bug http://bugzilla.kernel.org/show_bug.cgi?id=5731
> describes an issue where write() can't be used to generate a zero-length
> datagram (but send, and sendto do work).
> 
> I think the following is needed:
> 
> --- a/net/socket.c	2007-08-20 09:54:28.000000000 -0700
> +++ b/net/socket.c	2007-09-24 15:31:25.000000000 -0700
> @@ -777,8 +777,11 @@ static ssize_t sock_aio_write(struct kio
>  	if (pos != 0)
>  		return -ESPIPE;
>  
> -	if (iocb->ki_left == 0)	/* Match SYS5 behaviour */
> -		return 0;
> +	if (unlikely(iocb->ki_left == 0)) {
> +		struct socket *sock = iocb->ki_filp->private_data;
> +		if (sock->type == SOCK_STREAM)
> +			return 0;
> +	}
>  
>  	x = alloc_sock_iocb(iocb, &siocb);
>  	if (!x)

We should simply remove the check completely.

There is no need to add special code for different types of protocols
and sockets.

As is hinted in the bugzilla, the exact same thing can happen with a
suitably constructed sendto() or sendmsg() call.  write() on a socket
is a sendmsg() with a NULL msg_control and a single entry iovec, plain
and simple.

It's how BSD and many other systems behave, and I double checked
Steven's Volume 2 just to make sure.

So I'm going to check in the following to fix this bugzilla.  There is
a similarly ugly test for len==0 in sys_read() on sockets.  If someone
would do some research on the validity of that thing I'd really
appreciate it :-)

diff --git a/net/socket.c b/net/socket.c
index 7d44453..b09eb90 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -777,9 +777,6 @@ static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
 	if (pos != 0)
 		return -ESPIPE;
 
-	if (iocb->ki_left == 0)	/* Match SYS5 behaviour */
-		return 0;
-
 	x = alloc_sock_iocb(iocb, &siocb);
 	if (!x)
 		return -ENOMEM;
