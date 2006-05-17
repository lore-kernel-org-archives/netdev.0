From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bug 6421] kernel 2.6.10-2.6.16 on alpha: arch/alpha/kernel/io.c, iowrite16_rep() BUG_ON((unsigned long)src & 0x1) triggered
Date: Wed, 17 May 2006 23:30:35 +1000
Message-ID: <20060517133035.GA7744@gondor.apana.org.au>
References: <200605170644.k4H6iHD8006479@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:64774 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932549AbWEQNax
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 09:30:53 -0400
To: bugme-daemon@bugzilla.kernel.org
Content-Disposition: inline
In-Reply-To: <200605170644.k4H6iHD8006479@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2006 at 11:44:17PM -0700, bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=6421
>
> ------- Additional Comments From tomri@gmx.net  2006-05-16 23:43 -------
> Another stack trace. skb_padto() is not called.
> 
> May 16 23:50:34 merlin kernel: ei_start_xmit(): entry: skb->data unaligned
> fffffc0009b5098b skb fffffc001e763a08 length 66
> May 16 23:50:34 merlin kernel: Badness in ei_start_xmit at drivers/net/8390.c:283

...

> May 16 23:50:34 merlin kernel: Trace:
> May 16 23:50:34 merlin kernel: [<fffffc00005670f8>] qdisc_restart+0x88/0x2b0
> May 16 23:50:34 merlin kernel: [<fffffc00005d64b4>] packet_rcv_spkt+0x1a4/0x3b0
> May 16 23:50:34 merlin kernel: [<fffffc00005566c0>] dev_queue_xmit_nit+0x1a0/0x1f0
> May 16 23:50:34 merlin kernel: [<fffffc0000567250>] qdisc_restart+0x1e0/0x2b0
> May 16 23:50:34 merlin kernel: [<fffffc0000558f48>] dev_queue_xmit+0xb8/0x3b0
> May 16 23:50:34 merlin kernel: [<fffffc0000560508>] neigh_resolve_output+0x128/0x370
> May 16 23:50:34 merlin kernel: [<fffffc00005815b4>] ip_output+0x224/0x430
> May 16 23:50:34 merlin kernel: [<fffffc00005800bc>] ip_queue_xmit+0x2dc/0x630
> May 16 23:50:34 merlin kernel: [<fffffc0000596068>] tcp_transmit_skb+0x588/0xa30
> May 16 23:50:34 merlin kernel: [<fffffc000059bb6c>] tcp_v4_send_check+0x11c/0x150
> May 16 23:50:34 merlin kernel: [<fffffc0000595f68>] tcp_transmit_skb+0x488/0xa30
> May 16 23:50:34 merlin kernel: [<fffffc0000597ab0>] tcp_retransmit_skb+0x730/0x7b0

OK, I think I have a suspect in sight.  The unaligned packet is
probably caused by tcp_trim_head.  To fix it we could just copy
the data instead of trimming if it is not paged.

However, I'd like you to confirm that this is indeed the cause
with a tcpdump.

So please take a tcpdump and show us the relevant packets that
show up about the time when you get the unaligned warnings.
What I'm expecting is a partial odd ACK just before the error.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
