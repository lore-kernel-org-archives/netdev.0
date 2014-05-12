From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] af_key: return error when meet errors on
 sendmsg() syscall
Date: Mon, 12 May 2014 01:11:41 -0400 (EDT)
Message-ID: <20140512.011141.74073195599318391.davem@davemloft.net>
References: <1399614455-10551-1-git-send-email-xufeng.zhang@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xufeng.zhang@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399614455-10551-1-git-send-email-xufeng.zhang@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xufeng Zhang <xufeng.zhang@windriver.com>
Date: Fri, 9 May 2014 13:47:35 +0800

> Current implementation for pfkey_sendmsg() always return success
> no matter whether or not error happens during this syscall,
> this is incompatible with the general send()/sendmsg() API:
>   man send
>     RETURN VALUE
>       On success, these calls return the number of characters sent.
>       On error, -1 is returned, and errno is set appropriately.
> 
> One side effect this problem introduces is that we can't determine
> when to resend the message when the previous send() fails because
> it was interrupted by signals.
> We detect such a problem when racoon is sending SADBADD message to
> add SAD entry in the kernel, but sometimes kernel is responding with
> "Interrupted system call"(-EINTR) error.
> 
> Check the send implementation of strongswan, it has below logic:
>   pfkey_send_socket()
>   {
>   	...
>   	while (TRUE)
>   	{
>         	len = send(socket, in, in_len, 0);
> 
>   		if (len != in_len)
>   		{
>   			case EINTR:
>   				/* interrupted, try again */
>   				continue;
>   			...
>   		}
>   	}
>   	...
> }
> So it makes sense to return errors for send() syscall.      
> 
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>

I disagree.

If pfkey_error() is successful, the error will be reported in the AF_KEY
message that is broadcast, there is no reason for sendmsg to return an
error.  The message was sucessfully sent, there was no problem with it's
passage into the AF_KEY layer.

Like netlink, operational responses come in packets, not error codes.

However, if pfkey_error() fails, we must do pass back the original
error code because it's a last ditch effort to prevent information
from being lost.

That's why 'err' must be preserved when pfkey_error() returns zero.
