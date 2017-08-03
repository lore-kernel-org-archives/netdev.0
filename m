From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 1/3] proto_ops: Add locked held versions of sendmsg
 and sendpage
Date: Thu, 03 Aug 2017 13:21:40 -0700
Message-ID: <598385D4.5050205@gmail.com>
References: <20170728232243.3040-1-tom@quantonium.net> <20170728232243.3040-2-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33265 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751948AbdHCUVz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 16:21:55 -0400
Received: by mail-pg0-f68.google.com with SMTP id u185so2429840pgb.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 13:21:55 -0700 (PDT)
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

[...]

>  
> +int kernel_sendpage_locked(struct sock *sk, struct page *page, int offset,
> +			   size_t size, int flags)
> +{
> +	struct socket *sock = sk->sk_socket;
> +
> +	if (sock->ops->sendpage_locked)
> +		return sock->ops->sendpage_locked(sk, page, offset, size,
> +						  flags);
> +
> +	return sock_no_sendpage_locked(sk, page, offset, size, flags);
> +}

How about just returning EOPNOTSUPP here and force implementations to do both
sendmsg and sendpage. The only implementation of these callbacks already does
this. And if its any other socket it will just wind its way through a few
layers of calls before returning EOPNOTSUPP.

.John
