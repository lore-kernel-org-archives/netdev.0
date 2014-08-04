From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Problems with TPACKET_V3 delivery of wakeups (and empty buffer
 blocks)
Date: Mon, 04 Aug 2014 10:07:32 +0200
Message-ID: <53DF3F44.6090804@redhat.com>
References: <FBF13AD0-7721-4CEF-94AE-A14C1B06E84C@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Chetan Loke <loke.chetan@gmail.com>
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29240 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750941AbaHDIHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2014 04:07:39 -0400
In-Reply-To: <FBF13AD0-7721-4CEF-94AE-A14C1B06E84C@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ cc'ing Chetan for TPACKET_V3 ]

On 07/26/2014 02:43 AM, Guy Harris wrote:
> Users of libpcap, which supports TPACKET_V3 as of libpcap 1.5.0, have reported problems that
 > turned out to be due to some oddities in TPACKET_V3's behavior.
>
> See, for example:
>
> 	https://github.com/the-tcpdump-group/libpcap/issues/335
>
> 	https://github.com/the-tcpdump-group/libpcap/issues/364
>
> 	http://thread.gmane.org/gmane.network.tcpdump.devel/6823
>
> To quote one of my comments for the first issue:
>
> It appears that PF_PACKET sockets deliver a wakeup when a packet is put in a buffer block or
 > dropped due to no buffer blocks being empty, but *not* when a buffer block is handed to userland.
>
> This means that if the kernel's timer expires, and there are no packets in the current buffer
 > block being filled by the kernel, that buffer block will be handed to userland, but userland
 > won't be woken up to tell it to consume that block.
>
> Thus, libpcap will consume that block only if either:
>
> 	1. a packet is put in a buffer block, meaning it must pass the filter *and* there must be
 >          a current buffer block, belonging to the kernel, into which to put it;
>
> 	2. a packet arrives and passes the filter, but there are *no* current buffer blocks
 >          belonging to the kernel, so it's dropped;
>
> 	3. the poll() times out.
>
> So, with a low packet acceptance rate (either because there isn't much network traffic or because
 > there is but most of it is rejected by the packet filter), and with a poll() timeout of -1, meaning
 > "block forever", 1) will happen infrequently, and 3) will never happen.  With an in-kernel timeout
 > rate significantly lower than the rate of packet acceptance, the timeout will often occur when
 > there are no packets in the current buffer block, in which case the kernel will hand an empty buffer
 > block to userland and *not* tell userland about it.
>
> If that happens often enough in sequence to cause *all* buffer blocks to be handed to userland
 > before any wakeups occur, the kernel now has no buffer blocks into which to put packets, and the
 > next time a packet arrives, it will be dropped, and a wakeup will finally occur.  libpcap will drain
 > the ring, handing all buffer blocks to the kernel, *but* it won't have any packets to process!
>
> So this is ultimately a problem with the TPACKET_V3 code in the kernel.  I personally think that
 > it should *not* deliver empty buffer blocks to userland, and that it also should *not* deliver a
 > wakeup when a packet is accepted, and *should* deliver a wakeup whenever a buffer block is handed
 > to userland.  I'll report this to somebody and let them decide which of those changes should be done.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
