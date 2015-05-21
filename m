From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH net-next] tcp: add tcpi_segs_in and tcpi_segs_out to
 tcp_info
Date: Thu, 21 May 2015 18:53:14 -0300
Message-ID: <20150521215314.GB2566@localhost.localdomain>
References: <1430260098-14127-1-git-send-email-edumazet@google.com>
 <20150512130855.GA29412@localhost.localdomain>
 <1431462713.566.95.camel@edumazet-glaptop2.roam.corp.google.com>
 <1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAK6E8=ebJDpUZeM=JHmqxgjcFEr1WLee2UeaKUjPg5vQwVL0tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Matt Mathis <mattmathis@google.com>,
	Craig Gallek <cgallek@google.com>, Martin Lau <kafai@fb.com>,
	Chris Rapier <rapier@psc.edu>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39905 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161104AbbEUVx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 17:53:26 -0400
Content-Disposition: inline
In-Reply-To: <CAK6E8=ebJDpUZeM=JHmqxgjcFEr1WLee2UeaKUjPg5vQwVL0tA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015 at 12:41:21PM -0700, Yuchung Cheng wrote:
> On Wed, May 20, 2015 at 4:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
...
> > diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> > index b6575d6655681e8e84993a5db929c7309d47d4d3..beac6bf840b9a9d1e2f281d2b1c71b5a3414b824 100644
> > --- a/net/ipv6/tcp_ipv6.c
> > +++ b/net/ipv6/tcp_ipv6.c
> > @@ -1421,6 +1421,7 @@ process:
> >         skb->dev = NULL;
> >
> >         bh_lock_sock_nested(sk);
> > +       tcp_sk(sk)->segs_in += max_t(u16, 1, skb_shinfo(skb)->gso_segs);
> some helper like e.g. tcp_event_pkt_recv() for v4/v6?
> i am curious why use max instead of the ternary op?

Just because it was based this line, nothing else:

ip_rcv()
   ...
        IP_ADD_STATS_BH(dev_net(dev),                                     
                        IPSTATS_MIB_NOECTPKTS + (iph->tos & INET_ECN_MASK),
                        max_t(unsigned short, 1, skb_shinfo(skb)->gso_segs));

Including these new lines, this calculation is being done 5 times now,
being just these 2 on tcp, then ip_input.c, ip_output and
ip_tunnel_core.c. I'd rather wait some more to add a helper as coming to
a reasonable name is hard at this point. For iptunnel, it's used at
iptunnel_xmit() for example. Or perhaps you have another suggestion of
a name?

Thanks,
Marcelo

> >         ret = 0;
> >         if (!sock_owned_by_user(sk)) {
> >                 if (!tcp_prequeue(sk, skb))
> >
> >
> 
