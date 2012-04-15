From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: RFC6298 supersedes RFC2988bis
Date: Sun, 15 Apr 2012 17:40:06 +0200
Message-ID: <1334504406.28012.17.camel@edumazet-glaptop>
References: <1334296120.5300.8404.camel@edumazet-glaptop>
	 <20120414.154724.636922650012404380.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hkchu@google.com, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:47212 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754644Ab2DOPkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 11:40:11 -0400
Received: by wibhq7 with SMTP id hq7so4438322wib.1
        for <netdev@vger.kernel.org>; Sun, 15 Apr 2012 08:40:09 -0700 (PDT)
In-Reply-To: <20120414.154724.636922650012404380.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-04-14 at 15:47 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>

> > BTW, one side effect of the TCP_TIMEOUT_INIT change (3 -> 1) is
> > inet_csk_reqsk_queue_prune() latency is 200% worse:
> > 
> > It fires every 200ms and scans 40% of hash table each time, listener
> > socket held.
> 
> That's rather unfortunate, but I can't see an easy way around it.  We
> have to process the whole table within the timeout quantum.

I am currently working on this issue (and more generally to provide
better scalable LISTEN/SYN_RECV processing)

1) convert inet_csk_reqsk_queue_prune() to work queue instead of timer
2) use hashed spinlocks to protect syn_table[]
3) use RCU and dont hold parent socket lock to allow parallelism for
multiqueue NICS (or RPS ...)
4) use 32bit instead of 16bit for sk_max_ack_backlog/sk_ack_backlog

It occured to me that on my 12 cores machine (24 threads) and IXGBE card
(24 queues per link), a moderate SYN packets load could basically freeze
whole machine, 23 cpus waiting one cpu is done with the listener lock.

TCP processing on ESTABLISHED/TIME_WAIT sockets has RCU and all goodies,
time has come to address the LISTEN/SYN_RECV states as well.
