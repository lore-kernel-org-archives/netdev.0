From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Slab Corruption with ipv6 and tcp6fuzz
Date: Fri, 25 Apr 2008 17:09:46 +0400
Message-ID: <20080425130946.GA1019@2ka.mipt.ru>
References: <20080424142727.GA24025@alice> <20080424211320.GA13695@2ka.mipt.ru> <20080425125230.GA12343@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	ilpo.jarvinen@helsinki.fi
To: Eric Sesterhenn <snakebyte@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60920 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755268AbYDYNKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 09:10:24 -0400
Content-Disposition: inline
In-Reply-To: <20080425125230.GA12343@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2008 at 02:52:30PM +0200, Eric Sesterhenn (snakebyte@gmx.de) wrote:
> > > [  215.103103]  [<c0671e3b>] tcp_v6_do_rcv+0x33b/0xcd0
> > 
> > So far can you run kernel with debug turned on and provide output of
> > gdb ./vmlinux
> > l *(tcp_v6_do_rcv+0x33b)
> 
> l *(tcp_v6_do_rcv+0x33b)
> Using host libthread_db library "/lib/tls/i686/cmov/libthread_db.so.1".
> (gdb) l *(tcp_v6_do_rcv+0x33b)
> 0xc0671e3b is in tcp_v6_do_rcv (net/ipv6/tcp_ipv6.c:1670).
> 1665    reset:
> 1666            tcp_v6_send_reset(sk, skb);
> 1667    discard:
> 1668            if (opt_skb)
> 1669                    __kfree_skb(opt_skb);
> 1670            kfree_skb(skb);
> 1671            return 0;
> 1672    csum_err:
> 1673            TCP_INC_STATS_BH(TCP_MIB_INERRS);
> 1674            goto discard;

Well, first possible error path:

tcp_v6_do_rcv()->tcp_rcv_established(), the latter goes to step5, where
eventually skb can be freed via tcp_data_queue() (drop: label), then if
check for tcp_defer_accept_check() returns true and thus
tcp_rcv_established() returns -1, which forces tcp_v6_do_rcv() to jump
to reset: label, which in turn will pass through discard: label and free
the same skb again.
 
> Here is the programm itself...

I will work on this this weekend, thank you.

-- 
	Evgeniy Polyakov
