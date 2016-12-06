From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Tue, 06 Dec 2016 19:31:01 +0100
Message-ID: <1481049061.7129.18.camel@redhat.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481020451.6225.38.camel@redhat.com> <1481044098.7129.7.camel@redhat.com>
         <1481046434.18162.599.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57464 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752009AbcLFSbY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 13:31:24 -0500
In-Reply-To: <1481046434.18162.599.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-06 at 09:47 -0800, Eric Dumazet wrote:
> On Tue, 2016-12-06 at 18:08 +0100, Paolo Abeni wrote:
> > On Tue, 2016-12-06 at 11:34 +0100, Paolo Abeni wrote:
> > > On Mon, 2016-12-05 at 09:57 -0800, Eric Dumazet wrote:
> > > > From: Eric Dumazet <edumazet@google.com>
> > > > 
> > > > In UDP recvmsg() path we currently access 3 cache lines from an skb
> > > > while holding receive queue lock, plus another one if packet is
> > > > dequeued, since we need to change skb->next->prev
> > > > 
> > > > 1st cache line (contains ->next/prev pointers, offsets 0x00 and 0x08)
> > > > 2nd cache line (skb->len & skb->peeked, offsets 0x80 and 0x8e)
> > > > 3rd cache line (skb->truesize/users, offsets 0xe0 and 0xe4)
> > > > 
> > > > skb->peeked is only needed to make sure 0-length packets are properly
> > > > handled while MSG_PEEK is operated.
> > > > 
> > > > I had first the intent to remove skb->peeked but the "MSG_PEEK at
> > > > non-zero offset" support added by Sam Kumar makes this not possible.
> > > > 
> > > > This patch avoids one cache line miss during the locked section, when
> > > > skb->len and skb->peeked do not have to be read.
> > > > 
> > > > It also avoids the skb_set_peeked() cost for non empty UDP datagrams.
> > > > 
> > > > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > > 
> > > Thank you for all the good work.
> > > 
> > > After all your improvement, I see the cacheline miss in inet_recvmsg()
> > > as a major perf offender for the user space process in the udp flood
> > > scenario due to skc_rxhash sharing the same sk_drops cacheline.
> > > 
> > > Using an udp-specific drop counter (and an sk_drops accessor to wrap
> > > sk_drops access where needed), we could avoid such cache miss. With that
> > > - patch for udp.h only below - I get 3% improvement on top of all the
> > > pending udp patches, and the gain should be more relevant after the 2
> > > queues rework. What do you think ?
> > 
> > Here follow what I'm experimenting. 
> 
> Well, new socket layout makes this kind of patches not really needed ?
> 
> 	/* --- cacheline 2 boundary (128 bytes) was 8 bytes ago --- */
> 	socket_lock_t              sk_lock;              /*  0x88  0x20 */
> 	atomic_t                   sk_drops;             /*  0xa8   0x4 */
> 	int                        sk_rcvlowat;          /*  0xac   0x4 */
> 	struct sk_buff_head        sk_error_queue;       /*  0xb0  0x18 */
> 	/* --- cacheline 3 boundary (192 bytes) was 8 bytes ago --- */

cacheline 2 boundary (128 bytes) is 8 bytes before sk_lock: cacheline 2
includes also skc_refcnt and skc_rxhash from __sk_common (I use 'pahole
-E ...' to get the full blown output). skc_rxhash is read for each
packet in inet_recvmsg()/sock_rps_record_flow() if CONFIG_RPS is set. I
get a cache miss per packet there and inet_recvmsg() in my test takes
about 8% of the whole u/s processing time.

> I mentioned at some point that we can very easily instruct 
> sock_skb_set_dropcount() to not read sk_drops if application
> does not care about getting sk_drops ;)
> 
> https://patchwork.kernel.org/patch/9405677/
> 
> Now sk_drops was moved, the plan is to submit this patch in an official way.

Looking forward to that!

Thank you,

Paolo
