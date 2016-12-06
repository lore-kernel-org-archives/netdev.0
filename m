From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Tue, 06 Dec 2016 09:47:14 -0800
Message-ID: <1481046434.18162.599.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481020451.6225.38.camel@redhat.com> <1481044098.7129.7.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35344 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751277AbcLFRsQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 12:48:16 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so20483192pga.2
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 09:48:16 -0800 (PST)
In-Reply-To: <1481044098.7129.7.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-06 at 18:08 +0100, Paolo Abeni wrote:
> On Tue, 2016-12-06 at 11:34 +0100, Paolo Abeni wrote:
> > On Mon, 2016-12-05 at 09:57 -0800, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > In UDP recvmsg() path we currently access 3 cache lines from an skb
> > > while holding receive queue lock, plus another one if packet is
> > > dequeued, since we need to change skb->next->prev
> > > 
> > > 1st cache line (contains ->next/prev pointers, offsets 0x00 and 0x08)
> > > 2nd cache line (skb->len & skb->peeked, offsets 0x80 and 0x8e)
> > > 3rd cache line (skb->truesize/users, offsets 0xe0 and 0xe4)
> > > 
> > > skb->peeked is only needed to make sure 0-length packets are properly
> > > handled while MSG_PEEK is operated.
> > > 
> > > I had first the intent to remove skb->peeked but the "MSG_PEEK at
> > > non-zero offset" support added by Sam Kumar makes this not possible.
> > > 
> > > This patch avoids one cache line miss during the locked section, when
> > > skb->len and skb->peeked do not have to be read.
> > > 
> > > It also avoids the skb_set_peeked() cost for non empty UDP datagrams.
> > > 
> > > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > 
> > Thank you for all the good work.
> > 
> > After all your improvement, I see the cacheline miss in inet_recvmsg()
> > as a major perf offender for the user space process in the udp flood
> > scenario due to skc_rxhash sharing the same sk_drops cacheline.
> > 
> > Using an udp-specific drop counter (and an sk_drops accessor to wrap
> > sk_drops access where needed), we could avoid such cache miss. With that
> > - patch for udp.h only below - I get 3% improvement on top of all the
> > pending udp patches, and the gain should be more relevant after the 2
> > queues rework. What do you think ?
> 
> Here follow what I'm experimenting. 

Well, new socket layout makes this kind of patches not really needed ?

	/* --- cacheline 2 boundary (128 bytes) was 8 bytes ago --- */
	socket_lock_t              sk_lock;              /*  0x88  0x20 */
	atomic_t                   sk_drops;             /*  0xa8   0x4 */
	int                        sk_rcvlowat;          /*  0xac   0x4 */
	struct sk_buff_head        sk_error_queue;       /*  0xb0  0x18 */
	/* --- cacheline 3 boundary (192 bytes) was 8 bytes ago --- */

Nothing in UDP fast path needs to access a field from this cache line, but sk_drops.

So wherever we put sk_drops (even in a cache line of its own), we will still have
false sharing on it.

And really this should be fine.
Eventually we could have per NUMA node counter to help a bit.

I mentioned at some point that we can very easily instruct 
sock_skb_set_dropcount() to not read sk_drops if application
does not care about getting sk_drops ;)

https://patchwork.kernel.org/patch/9405677/

Now sk_drops was moved, the plan is to submit this patch in an official way.

Thanks !

 
