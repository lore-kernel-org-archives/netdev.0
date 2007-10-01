From: "Denis V. Lunev" <dlunev@gmail.com>
Subject: Re: [PATCH] memory leak in netlink user->kernel processing
Date: Mon, 01 Oct 2007 18:58:15 +0400
Message-ID: <47010B07.5060009@gmail.com>
References: <20071001142907.GA10022@iris.sw.ru> <470105EA.3090209@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:7559 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbXJAO5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 10:57:08 -0400
Received: by ug-out-1314.google.com with SMTP id z38so1893624ugc
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2007 07:57:07 -0700 (PDT)
In-Reply-To: <470105EA.3090209@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Denis V. Lunev wrote:
>> netlink_kernel_create can be called with NULL as an input callback in several
>> places, f.e. in kobject_uevent_init. This means that if one sends packet from
>> user to kernel for such a socket, the packet will be leaked in the socket
>> queue forever.
>>
>> This patch adds a simple generic cleanup callback for these sockets.
> 
> 
> This should already be handled by netlink_getsockbypid:
> 
>         /* Don't bother queuing skb if kernel socket has no input
> function */
>         nlk = nlk_sk(sock);
>         if ((nlk->pid == 0 && !nlk->data_ready) ||
>             (sock->sk_state == NETLINK_CONNECTED &&
>              nlk->dst_pid != nlk_sk(ssk)->pid)) {
>                 sock_put(sock);
>                 return ERR_PTR(-ECONNREFUSED);
>         }
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Looks so...

By the way, Patrick, this looks like nlk->pid == 0 if and only if this
is a kernel socket. Right?

I have told with Alexey Kuznetsov and we have discrovered a way to get
rid of
        skb_queue_tail(&sk->sk_receive_queue, skb);
        sk->sk_data_ready(sk, len);
in netlink_sendskb/etc for kernel sockets and make user->kernel packets
processing truly synchronous.

The idea is simple, we should queue/wakeup in kernel->user direction and
simply call nlk->data_ready for user->kernel direction. This will remove
all the crap we have now. But we need a mark to determine the direction.
Which one will be better? (nlk->data_ready) or (nlk->pid == 0)

Regards,
	Den
