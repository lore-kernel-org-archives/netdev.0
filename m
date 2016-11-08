From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sock: do not set sk_err in
 sock_dequeue_err_skb
Date: Mon, 07 Nov 2016 20:29:56 -0500 (EST)
Message-ID: <20161107.202956.378754457373863655.davem@davemloft.net>
References: <1478211867-24569-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, willemb@google.com,
        ncardwell@google.com, soheil@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47924 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbcKHB36 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 20:29:58 -0500
In-Reply-To: <1478211867-24569-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Thu,  3 Nov 2016 18:24:27 -0400

> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> Do not set sk_err when dequeuing errors from the error queue.
> Doing so results in:
> a) Bugs: By overwriting existing sk_err values, it possibly
>    hides legitimate errors. It is also incorrect when local
>    errors are queued with ip_local_error. That happens in the
>    context of a system call, which already returns the error
>    code.
> b) Inconsistent behavior: When there are pending errors on
>    the error queue, sk_err is sometimes 0 (e.g., for
>    the first timestamp on the error queue) and sometimes
>    set to an error code (after dequeuing the first
>    timestamp).
> c) Suboptimality: Setting sk_err to ENOMSG on simple
>    TX timestamps can abort parallel reads and writes.
> 
> Removing this line doesn't break userspace. This is because
> userspace code cannot rely on sk_err for detecting whether
> there is something on the error queue. Except for ICMP messages
> received for UDP and RAW, sk_err is not set at enqueue time,
> and as a result sk_err can be 0 while there are plenty of
> errors on the error queue.
> 
> For ICMP packets in UDP and RAW, sk_err is set when they are
> enqueued on the error queue, but that does not result in aborting
> reads and writes. For such cases, sk_err is only readable via
> getsockopt(SO_ERROR) which will reset the value of sk_err on
> its own. More importantly, prior to this patch,
> recvmsg(MSG_ERRQUEUE) has a race on setting sk_err (i.e.,
> sk_err is set by sock_dequeue_err_skb without atomic ops or
> locks) which can store 0 in sk_err even when we have ICMP
> messages pending. Removing this line from sock_dequeue_err_skb
> eliminates that race.
> 
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Ok, applied.
