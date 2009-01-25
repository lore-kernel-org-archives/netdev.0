From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Sun, 25 Jan 2009 22:03:25 +0100
Message-ID: <20090125210325.GA31227@1wt.eu>
References: <20090119061420.GB12946@1wt.eu> <20090118.221908.47032075.davem@davemloft.net> <20090119101924.GA1881@gondor.apana.org.au> <20090119.125941.240930524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com, zbr@ioremap.net,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751759AbZAYVEN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090119.125941.240930524.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Mon, Jan 19, 2009 at 12:59:41PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 19 Jan 2009 21:19:24 +1100
> 
> > On Sun, Jan 18, 2009 at 10:19:08PM -0800, David Miller wrote:
> > > 
> > > Actually, I see, the myri10ge driver does put up to
> > > 64 bytes of the initial packet into the linear area.
> > > If the IPV4 + TCP headers are less than this, you will
> > > hit the corruption case even with the myri10ge driver.
> > 
> > I thought splice only mapped the payload areas, no?
> 
> And the difference between 64 and IPV4+TCP header len becomes the
> payload, don't you see? :-)
> 
> myri10ge just pulls min(64, skb->len) bytes from the SKB frags into
> the linear area, unconditionally.  So a small number of payload bytes
> can in fact end up there.
> 
> Otherwise Willy could never have triggered this bug.

Just FWIW, I've updated my tools in order to perform content checks more
easily. I cannot reproduce the issue at all with the myri10ge NICs, neither
with large frames nor with tiny ones (8 bytes).

However, I have noticed that the load is now sensible to the number of
concurrent sessions. I'm using 2.6.29-rc2 with the perfcounters patches,
and I'm not sure whether the difference in behaviour came with the data
corruption fixes or with the new kernel (which has some profiling options
turned on). Basically, below 800-1000 concurrent sessions, I have no
problem reaching 10 Gbps with LRO and MTU=1500, with about 60% CPU. Above
this number of session, the CPU suddenly jumps to 100% and the data rate
drops to about 6.7 Gbps.

I spent a long time trying to figure what it was, but I think that I
have found. Kerneltop reports different figures above and below the
limit.

1) below the limit :

            1429.00 - 00000000784a7840 : tcp_sendpage
             561.00 - 00000000784a6580 : tcp_read_sock
             485.00 - 00000000f87e13c0 : myri10ge_xmit  [myri10ge]
             433.00 - 00000000781a40c0 : sys_splice
             411.00 - 00000000784a6eb0 : tcp_poll
             344.00 - 000000007847bcf0 : dev_queue_xmit
             342.00 - 0000000078470be0 : __skb_splice_bits
             319.00 - 0000000078472950 : __alloc_skb
             310.00 - 0000000078185870 : kmem_cache_alloc
             285.00 - 00000000784b2260 : tcp_transmit_skb
             285.00 - 000000007850cac0 : _spin_lock
             250.00 - 00000000781afda0 : sys_epoll_ctl
             238.00 - 000000007810334c : system_call
             232.00 - 000000007850ac20 : schedule
             230.00 - 000000007850cc10 : _spin_lock_bh
             222.00 - 00000000784705f0 : __skb_clone
             220.00 - 000000007850cbc0 : _spin_lock_irqsave
             213.00 - 00000000784a08f0 : ip_queue_xmit
             211.00 - 0000000078185ea0 : __kmalloc_track_caller

2) above the limit :

            1778.00 - 00000000784a7840 : tcp_sendpage
            1281.00 - 0000000078472950 : __alloc_skb
             639.00 - 00000000784a6780 : sk_stream_alloc_skb
             507.00 - 0000000078185ea0 : __kmalloc_track_caller
             484.00 - 0000000078185870 : kmem_cache_alloc
             476.00 - 00000000784a6580 : tcp_read_sock
             451.00 - 00000000784a08f0 : ip_queue_xmit
             421.00 - 00000000f87e13c0 : myri10ge_xmit  [myri10ge]
             374.00 - 00000000781852e0 : __slab_alloc
             361.00 - 00000000781a40c0 : sys_splice
             273.00 - 0000000078470be0 : __skb_splice_bits
             231.00 - 000000007850cac0 : _spin_lock
             206.00 - 0000000078168b30 : get_pageblock_flags_group
             165.00 - 00000000784a0260 : ip_finish_output
             165.00 - 00000000784b2260 : tcp_transmit_skb
             161.00 - 0000000078470460 : __copy_skb_header
             153.00 - 000000007816d6d0 : put_page
             144.00 - 000000007850cbc0 : _spin_lock_irqsave
             137.00 - 0000000078189be0 : fget_light

The memory allocation clearly is the culprit here. I'll try Jarek's
patch which reduces memory allocation to see if that changes something,
as I'm sure we can do fairly better, given how it behaves with limited
sessions.

Regards,
Willy

PS: this thread is long, if some of the people in CC want to get off
    the thread, please complain.
