From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp: under rx pressure, try to condense skbs
Date: Thu, 08 Dec 2016 07:30:15 -0800
Message-ID: <1481211015.4930.100.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481131173.4930.36.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161208104620.5fc691b8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36435 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752208AbcLHPbA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 10:31:00 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so27159160pgx.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 07:30:18 -0800 (PST)
In-Reply-To: <20161208104620.5fc691b8@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-08 at 10:46 +0100, Jesper Dangaard Brouer wrote:

> Hmmm... I'm not thrilled to have such heuristics, that change memory
> behavior when half of the queue size (sk->sk_rcvbuf) is reached.

Well, copybreak drivers do that unconditionally, even under no stress at
all, you really should complain then.

copybreak is interesting, not only for performance point of view, but
ability to handle DOS/DDOS : Attackers need to send bigger packets to
eventually force us to consume one page per packet.

My idea (which I already described in the past) is to perform the
(small) copy only in contexts we know packet might sit for a long time
in a socket queue, and only if we know we are in stress conditions.

ACK packets for example do not need copybreak, since they wont be queued
for a long time.

> 
> Most of the win comes from doing a local atomic page-refcnt decrement
> oppose to doing a remote CPU refcnf-dec.  And as you noticed the
> benefit is quite high saving 241 cycles (see [1]).  And you patch is
> "using" these cycles to copy the packet instead.

So, just to let you know, I have a patch series which achieve ~100 %
perf increase, without the 2nd queue I envisioned for linux-4.11

A single thread doing mere recvmsg() system calls can now read ~2Mpps.

This skb_condense() is done before producer cpus are competing using a
busylock array (not a per socket new spinlock, but a shared hashed
array, out of line).

I plan using it tcp_add_backlog() to replace the :

	if (!skb->data_len)
		skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));

> This might no be a win in the future.  I'm working on a more generic
> solution (page_pool) that (as one objective) target this remote recfnt.

Very well, when all drivers can use this, we might revert this patch if
proved not beneficial.

But make sure we can hold 1,000,000 pages in skbs stored in ~100,000
TCP/UDP sockets.

Your ideas sound fine in controlled environments, I am sure you will be
able to demonstrate their gains independently of the counter measures we
put in place in the protocol handlers.
