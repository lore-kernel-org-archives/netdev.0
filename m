From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: gro: selective flush of packets
Date: Sun, 07 Oct 2012 07:29:47 +0200
Message-ID: <1349587787.21172.1908.camel@edumazet-glaptop>
References: <1348841041.5093.2477.camel@edumazet-glaptop>
	 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
	 <1349448747.21172.113.camel@edumazet-glaptop>
	 <20121006041155.GA27134@gondor.apana.org.au>
	 <1349500126.4883.4.camel@edumazet-laptop>
	 <20121006051407.GA27390@gondor.apana.org.au>
	 <1349504541.21172.183.camel@edumazet-glaptop>
	 <1349506825.21172.241.camel@edumazet-glaptop>
	 <20121006105618.GA28591@gondor.apana.org.au>
	 <1349546929.21172.1598.camel@edumazet-glaptop>
	 <20121007003208.GA31839@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:34222 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823Ab2JGF3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 01:29:53 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so2725230wgb.1
        for <netdev@vger.kernel.org>; Sat, 06 Oct 2012 22:29:51 -0700 (PDT)
In-Reply-To: <20121007003208.GA31839@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	On Sun, 2012-10-07 at 08:32 +0800, Herbert Xu wrote:
> On Sat, Oct 06, 2012 at 08:08:49PM +0200, Eric Dumazet wrote:
> >
> > @@ -3981,8 +3996,17 @@ static void net_rx_action(struct softirq_action *h)
> >  				local_irq_enable();
> >  				napi_complete(n);
> >  				local_irq_disable();
> > -			} else
> > +			} else {
> > +				if (n->gro_list) {
> > +					/* flush too old packets
> > +					 * If HZ < 1000, flush all packets.
> > +					 */
> > +					local_irq_enable();
> > +					napi_gro_flush(n, HZ >= 1000);
> > +					local_irq_disable();
> > +				}
> >  				list_move_tail(&n->poll_list, &sd->poll_list);
> > +			}
> 
> Why don't we just always flush everything?

This is what I tried first, but it lowered performance on several
typical workloads.

Using this simple heuristic increases performance.
