From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] inet: further fixes of possible seqlock deadlocks
Date: Thu, 28 Nov 2013 22:27:00 +0100
Message-ID: <20131128212700.GF24171@order.stressinduktion.org>
References: <13025162.118881385612276530.JavaMail.weblogic@epv6ml01> <1385659390.5352.20.camel@edumazet-glaptop2.roam.corp.google.com> <1385661082.5352.34.camel@edumazet-glaptop2.roam.corp.google.com> <20131128192231.GE24171@order.stressinduktion.org> <1385672502.5352.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jongman.heo@samsung.com, David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1385672502.5352.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 28, 2013 at 01:01:42PM -0800, Eric Dumazet wrote:
> On Thu, 2013-11-28 at 20:22 +0100, Hannes Frederic Sowa wrote:
> > This fixes more incorrect uses of *_STATS_BH in process context.
> > 
> > Cc: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >  net/ipv4/udp.c        | 8 ++++----
> >  net/ipv6/ip6_output.c | 8 ++++----
> >  net/ipv6/ping.c       | 4 ++--
> >  3 files changed, 10 insertions(+), 10 deletions(-)
> > 
> > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> > index 44e3884..f5cc018 100644
> > --- a/net/ipv4/udp.c
> > +++ b/net/ipv4/udp.c
> > @@ -1160,10 +1160,10 @@ static unsigned int first_packet_length(struct sock *sk)
> >  	spin_lock_bh(&rcvq->lock);
> 
> Here we block BH, because of spin_lock_bh()
> 
> >  	while ((skb = skb_peek(rcvq)) != NULL &&
> >  		udp_lib_checksum_complete(skb)) {
> > -		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS,
> > -				 IS_UDPLITE(sk));
> > -		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
> > -				 IS_UDPLITE(sk));
> 
> So this is the right thing, this change is not needed.

Oh yes, I was mechanically going through the a grep of _BH\( in ipv4
and ipv6 and missed that.

> > +		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_CSUMERRORS,
> > +				   IS_UDPLITE(sk));
> > +		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS,
> > +				   IS_UDPLITE(sk));
> >  		atomic_inc(&sk->sk_drops);
> >  		__skb_unlink(skb, rcvq);
> >  		__skb_queue_tail(&list_kill, skb);
> > diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> > index 59df872..e05cf0a 100644
> > --- a/net/ipv6/ip6_output.c
> > +++ b/j
> > @@ -116,8 +116,8 @@ static int ip6_finish_output2(struct sk_buff *skb)
> >  	}
> >  	rcu_read_unlock_bh();
> >  
> > -	IP6_INC_STATS_BH(dev_net(dst->dev),
> > -			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
> > +	IP6_INC_STATS(dev_net(dst->dev),
> > +		      ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
> 
> This is ipv6, not inet changes ;)

I always considered inet both for ipv4+ipv6, otherwise I would use ipv4
or ipv6 as patch prefix.

> 
> >  	kfree_skb(skb);
> >  	return -EINVAL;
> >  }
> > @@ -1524,8 +1524,8 @@ int ip6_push_pending_frames(struct sock *sk)
> >  	if (proto == IPPROTO_ICMPV6) {
> >  		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
> >  
> > -		ICMP6MSGOUT_INC_STATS_BH(net, idev, icmp6_hdr(skb)->icmp6_type);
> > -		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
> > +		ICMP6MSGOUT_INC_STATS(net, idev, icmp6_hdr(skb)->icmp6_type);
> > +		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
> 
> I am not sure we use a seqlock for ICMP stats.
> 
> seqlocks were used for 64bit IP stats

True, atomic longs get used here in both cases.

Will update the patch. Thanks, Eric!
