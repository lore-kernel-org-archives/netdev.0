From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/5] net/socket: add helpers for recvmmsg
Date: Fri, 25 Nov 2016 14:30:22 -0800
Message-ID: <1480113022.8455.580.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1480086321.git.pabeni@redhat.com>
         <56ac598a3f8b677d58cc9fec5470df230c6d1f70.1480086321.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35825 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750776AbcKYWaZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 17:30:25 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so6480720pga.2
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 14:30:25 -0800 (PST)
In-Reply-To: <56ac598a3f8b677d58cc9fec5470df230c6d1f70.1480086321.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-11-25 at 16:39 +0100, Paolo Abeni wrote:
> _skb_try_recv_datagram_batch dequeues multiple skb's from the
> socket's receive queue, and runs the bulk_destructor callback under
> the receive queue lock.

...

> +	last = (struct sk_buff *)queue;
> +	first = (struct sk_buff *)queue->next;
> +	skb_queue_walk(queue, skb) {
> +		last = skb;
> +		totalsize += skb->truesize;
> +		if (++datagrams == batch)
> +			break;
> +	}

This is absolutely not good.

Walking through a list, bringing 2 cache lines per skb, is not the
proper way to deal with bulking.

And I do not see where 'batch' value coming from user space is capped ?

Is it really vlen argument coming from recvmmsg() system call ???

This code runs with BH masked, so you do not want to give user a way to
make you loop there 1000 times 

Bulking is nice, only if you do not compromise with system stability and
latency requirements from other users/applications.
