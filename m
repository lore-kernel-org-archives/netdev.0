From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 1/3] proto_ops: Add locked held versions of sendmsg
 and sendpage
Date: Thu, 03 Aug 2017 12:49:30 -0700
Message-ID: <59837E4A.1010409@gmail.com>
References: <20170728232243.3040-1-tom@quantonium.net> <20170728232243.3040-2-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37725 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751251AbdHCTtq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 15:49:46 -0400
Received: by mail-pf0-f194.google.com with SMTP id p13so2378560pfd.4
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 12:49:46 -0700 (PDT)
In-Reply-To: <20170728232243.3040-2-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/2017 04:22 PM, Tom Herbert wrote:
> Add new proto_ops sendmsg_locked and sendpage_locked that can be
> called when the socket lock is already held. Correspondingly, add
> kernel_sendmsg_locked and kernel_sendpage_locked as front end
> functions.
> 
> These functions will be used in zero proxy so that we can take
> the socket lock in a ULP sendmsg/sendpage and then directly call the
> backend transport proto_ops functions.
> 
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---

[...]

> diff --git a/net/socket.c b/net/socket.c
> index 79d9bb964cd8..c0a12ad39610 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -652,6 +652,20 @@ int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
>  }
>  EXPORT_SYMBOL(kernel_sendmsg);
>  
> +int kernel_sendmsg_locked(struct sock *sk, struct msghdr *msg,
> +			  struct kvec *vec, size_t num, size_t size)
> +{
> +	struct socket *sock = sk->sk_socket;
> +
> +	if (!sock->ops->sendmsg_locked)
> +		sock_no_sendmsg_locked(sk, msg, size);
> +

Should be

		return sock_no_sendmsg_locked(sk, msg, size);


> +	iov_iter_kvec(&msg->msg_iter, WRITE | ITER_KVEC, vec, num, size);
> +
> +	return sock->ops->sendmsg_locked(sk, msg, msg_data_left(msg));

Otherwise this is a null ptr deref.

> +}
> +EXPORT_SYMBOL(kernel_sendmsg_locked);
> +


Thanks,
John
