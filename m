From: Anton Blanchard <anton@samba.org>
Subject: Re: Warning in net/ipv4/af_inet.c:154
Date: Thu, 27 May 2010 13:56:17 +1000
Message-ID: <20100527035617.GB28295@kryten>
References: <20100525115813.GA28063@kryten>
 <1274801229.5020.80.camel@edumazet-laptop>
 <20100526031943.GA28295@kryten>
 <20100526.005634.48509140.davem@davemloft.net>
 <1274868776.2672.96.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46901 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757387Ab0E0D6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 23:58:00 -0400
Content-Disposition: inline
In-Reply-To: <1274868776.2672.96.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
Hi Eric,

> You are 100% right David, maybe we should add a test when changing
> sk_forward_alloc to test if socket is locked (lockdep only test), but
> that's for 2.6.36 :)

Thanks for the patch, unfortunately I can still hit the WARN_ON. I'm somewhat
confused by the two stage locking in the socket lock (ie sk_lock.slock and
sk_lock.owned).

What state should the socket lock be in for serialising updates of
sk_forward_alloc? In some cases we appear to update it with sk_lock.slock =
unlocked, sk_lock.owned = 1:

NIP [c0000000005b4ad0] .sock_queue_rcv_skb
LR [c0000000005b4acc] .sock_queue_rcv_skb
Call Trace:
[c0000000005f9fcc] .ip_queue_rcv_skb
[c00000000061d604] .__udp_queue_rcv_skb
[c0000000005b1a38] .release_sock
[c0000000006205f0] .udp_sendmsg
[c0000000006290d4] .inet_sendmsg
[c0000000005abfb4] .sock_sendmsg
[c0000000005ae9dc] .SyS_sendto
[c0000000005ab6c0] .SyS_send

And other times we update it with sk_lock.slock = locked, sk_lock.owned = 0:

NIP [c0000000005b2b6c] .sock_rfree
LR [c0000000005b2b68] .sock_rfree
Call Trace:
[c0000000005bca10] .skb_free_datagram_locked
[c00000000061fe88] .udp_recvmsg
[c0000000006285e8] .inet_recvmsg
[c0000000005abe0c] .sock_recvmsg
[c0000000005ae358] .SyS_recvfrom

I see we sometimes take sk_lock.slock then check the owned field, but we
aren't doing that all the time.

Anton
