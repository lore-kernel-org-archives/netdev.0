From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: "TCP: eth0: Driver has suspect GRO implementation, TCP
 performance may be compromised." message with "ethtool -K eth0 gro off"
Date: Fri, 3 Feb 2017 11:53:55 -0200
Message-ID: <20170203135355.GA3413@localhost.localdomain>
References: <20170202115240.GH17590@x4>
 <1486038733.13103.21.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170202123427.GA7212@x4>
 <1486042270.13103.26.camel@edumazet-glaptop3.roam.corp.google.com>
 <1486043964.13103.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170203115457.GA5296@localhost.localdomain>
 <1486128246.21871.83.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39672 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753267AbdBCNx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 08:53:57 -0500
Content-Disposition: inline
In-Reply-To: <1486128246.21871.83.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 03, 2017 at 05:24:06AM -0800, Eric Dumazet wrote:
> On Fri, 2017-02-03 at 09:54 -0200, Marcelo Ricardo Leitner wrote:
> > On Thu, Feb 02, 2017 at 05:59:24AM -0800, Eric Dumazet wrote:
> > > On Thu, 2017-02-02 at 05:31 -0800, Eric Dumazet wrote:
> > > 
> > > > Anyway, I suspect the test is simply buggy ;)
> > > > 
> > > > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > > > index 41dcbd568cbe2403f2a9e659669afe462a42e228..5394a39fcce964a7fe7075b1531a8a1e05550a54 100644
> > > > --- a/net/ipv4/tcp_input.c
> > > > +++ b/net/ipv4/tcp_input.c
> > > > @@ -164,7 +164,7 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
> > > >  	if (len >= icsk->icsk_ack.rcv_mss) {
> > > >  		icsk->icsk_ack.rcv_mss = min_t(unsigned int, len,
> > > >  					       tcp_sk(sk)->advmss);
> > > > -		if (unlikely(icsk->icsk_ack.rcv_mss != len))
> > > > +		if (unlikely(icsk->icsk_ack.rcv_mss != len && skb_is_gso(skb)))
> > > >  			tcp_gro_dev_warn(sk, skb);
> > > >  	} else {
> > > >  		/* Otherwise, we make more careful check taking into account,
> > > 
> > > This wont really help.
> > > 
> > > Our tcp_sk(sk)->advmss can be lower than the MSS used by the remote
> > > peer.
> > > 
> > > ip ro add .... advmss 512
> > 
> > I don't follow. With a good driver, how can advmss be smaller than the
> > MSS used by the remote peer? Even with the route entry above, I get
> > segments just up to advmss, and no warning.
> > 
> 
> A TCP flow has two ends.

Indeed, though should be mostly about only one of them.

> 
> Common MTU = 1500
> 
> One can have advmss 500, the other one no advmss (or the standard 1460
> one)

Considering the rx side of peer A. Peer A advertises a given MSS to peer
B and should not receive any segment from peer B larger than so.
I'm failing to see how advmss can be smaller than the segment size just
received.

> 
> So if we compare apple and orange, result might be shocking ;)

Yes heh just not seeing the mix here..

> 
> If you want to reproduce this use the "ip ro add .... advmss 512" hint,
> and/or play with sysctl_tcp_mtu_probing

I tried the route with advmss, no luck so far.
Still digging..

  Marcelo
