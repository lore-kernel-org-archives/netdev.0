From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: TCP small packets throughput and multiqueue virtio-net
Date: Mon, 11 Mar 2013 13:29:04 +0200
Message-ID: <20130311112904.GA23359@redhat.com>
References: <5139840A.6020204@redhat.com>
 <1362755115.15793.236.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	KVM <kvm@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jpirko@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24527 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753970Ab3CKL2r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Mar 2013 07:28:47 -0400
Content-Disposition: inline
In-Reply-To: <1362755115.15793.236.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 08, 2013 at 07:05:15AM -0800, Eric Dumazet wrote:
> On Fri, 2013-03-08 at 14:24 +0800, Jason Wang wrote:
> > Hello all:
> > 
> > I meet an issue when testing multiqueue virtio-net. When I testing guest
> > small packets stream sending performance with netperf. I find an
> > regression of multiqueue. When I run 2 sessions of TCP_STREAM test with
> > 1024 byte from guest to local host, I get following result:
> > 
> > 1q result: 3457.64
> > 2q result: 7781.45
> > 
> > Statistics shows that: compared with one queue, multiqueue tends to send
> > much more but smaller packets. Tcpdump shows single queue has a much
> > higher possibility to produce a 64K gso packet compared to multiqueue.
> > More but smaller packets will cause more vmexits and interrupts which
> > lead a degradation on throughput.
> > 
> > Then problem only exist for small packets sending. When I test with
> > larger size, multiqueue will gradually outperfrom single queue. And
> > multiqueue also outperfrom in both TCP_RR and pktgen test (even with
> > small packets). The problem disappear when I turn off both gso and tso.
> > 
> 
> This makes little sense to me : TCP_RR workload (assuming one byte
> payload) cannot use GSO or TSO anyway. Same for pktgen as it uses UDP.
> 
> > I'm not sure whether it's a bug or expected since anyway we get
> > improvement on latency. And if it's a bug, I suspect it was related to
> > TCP GSO batching algorithm who tends to batch less in this situation. (
> > Jiri Pirko suspect it was the defect of virtio-net driver, but I didn't
> > find any obvious clue on this). After some experiments, I find the it
> > maybe related to tcp_tso_should_defer(), after
> > 1) change the tcp_tso_win_divisor to 1
> > 2) the following changes
> > the throughput were almost the same (but still a little worse) as single
> > queue:
> > 
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index fd0cea1..dedd2a6 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -1777,10 +1777,12 @@ static bool tcp_tso_should_defer(struct sock
> > *sk, struct sk_buff *skb)
> >  
> >         limit = min(send_win, cong_win);
> >  
> > +#if 0
> >         /* If a full-sized TSO skb can be sent, do it. */
> >         if (limit >= min_t(unsigned int, sk->sk_gso_max_size,
> >                            sk->sk_gso_max_segs * tp->mss_cache))
> >                 goto send_now;
> > +#endif
> >  
> >         /* Middle in queue won't get any more data, full sendable
> > already? */
> >         if ((skb != tcp_write_queue_tail(sk)) && (limit >= skb->len))
> > 
> > Git history shows this check were added for both westwood and fasttcp,

Hmm yes,
http://www.mail-archive.com/netdev@vger.kernel.org/msg08738.html
How about we disable it for cubic,reno then?

> > I'm not familiar with tcp but looks like we can easily hit this check
> > under when multiqueue is enabled for virtio-net. Maybe I was wrong but I
> > wonder whether we can still do some batching here.
> > 
> > Any comments, thoughts are welcomed.
> > 
> 
> Well, the point is : if your app does write(1024) bytes, thats probably
> because it wants small packets from the very beginning. (See the TCP
> PUSH flag ?)

In that case the application typically won't have packets
in flight (e.g. like TCP_RR) so TSO won't trigger at all, no?

It would seem that packets in flight might rather indicate
that the application is trying to keep the socket buffer full
by giving the kernel data as fast as it becomes available.
At least, this is exactly what benchmark tools seem to be doing, right?

> If the transport is slow, TCP stack will automatically collapse several
> write into single skbs (assuming TSO or GSO is on), and you'll see big
> GSO packets with tcpdump [1]. So TCP will help you to get less overhead
> in this case.
> 
> But if transport is fast, you'll see small packets, and thats good for
> latency.

But is a large CWND really a good indicator of a low latency link?  Can't
CWND grow (depending on the protocol) as long as there's no packet loss
even if the latency is high?

So if a VM is using a 10G backend link in the host, it seems that (due
to vmexit overhead) the latency is high so we are not gaining much from
sending the packet a bit earlier, OTOH, the bandwidth is high so the
per packet overhead becomes measureable. Virt workloads are probably not
the only ones that are like that, it's just that it's easier for people
to observe the overhead.

> So my opinion is : its exactly behaving as expected.
> 
> If you want bigger packets either :
> - Make the application doing big write()
> - Slow the vmexit ;)
> 
> [1] GSO fools tcpdump : Actual packets sent to the wire are not 'big
> packets', but they hit dev_hard_start_xmit() as GSO packets.
> 

-- 
MST
