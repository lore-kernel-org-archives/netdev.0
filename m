From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Neterion and UFO handling [was: Re: [PATCH] ipv6: udp packets
 following an UFO enqueued packet need also be handled by UFO]
Date: Tue, 08 Oct 2013 06:00:11 -0700
Message-ID: <1381237211.12191.35.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131001105837.GA1424@minipsycho.brq.redhat.com>
	 <20131001120907.GH10771@order.stressinduktion.org>
	 <20131001123214.GI10771@order.stressinduktion.org>
	 <20131001214721.GJ10771@order.stressinduktion.org>
	 <20131001232534.GM10771@order.stressinduktion.org>
	 <20131002085842.GA1528@minipsycho.brq.redhat.com>
	 <1380710488.19002.67.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131002121207.GO10771@order.stressinduktion.org>
	 <20131002130329.GP10771@order.stressinduktion.org>
	 <1380726867.19002.104.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131002162730.GA3991@order.stressinduktion.org>
	 <CAPoiz9wxxvHfmmMOCvPstzT51BafGfU1u5umxBQ8kqqCE=OzbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	yoshfuji@linux-ipv6.org, David Miller <davem@davemloft.net>,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	herbert@gondor.apana.org.au
To: Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:53648 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538Ab3JHNAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 09:00:14 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so8629378pdj.18
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 06:00:13 -0700 (PDT)
In-Reply-To: <CAPoiz9wxxvHfmmMOCvPstzT51BafGfU1u5umxBQ8kqqCE=OzbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-08 at 01:07 -0700, Jon Mason wrote:
> On Wed, Oct 2, 2013 at 9:27 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > Hi!
> >
> > I have a question regarding UFO and the neterion driver, which as the only one
> > advertises hardware UFO support:
> >
> > The patch discusses in this thread
> > http://thread.gmane.org/gmane.linux.network/284348/focus=285405 could change
> > some semantics how packets are constructed before submitted to the driver.
> >
> > We currently guarantee that we have the MAC/IP/UDP header in skb->data and the
> > payload is attached in the skb's frags. With the changes discussed in this
> > thread it is possible that we also append to skb->data some amount of data
> > which is not targeted for the header. From reading the driver sources it seems
> > the hardware interprets the skb->data to skb_headlen as the header, so we
> > could include some data in the fragments more than once.
> 
> From my reading of the HW Spec and a quick look at the driver, it
> appears that the driver is using one entry in the TX ring for the
> header and another for the body of the packet to be fragmented (which
> is what the hardware wants).  I don't understand what you are saying,
> but if you are asking if simply appending a new header & data to the
> end of skb->data will get it out on the wire correct, I don't believe
> it will.
> 
> I do have hardware that I can try the patch on, if you can walk me
> through the use case (unless it is as easy as setup an IPv6 connection
> and ping).

I think this behavior is quite common. Driver should certainly already
do the right thing, as TCP frames can have the same property.

bnx2x for example splits skb->head if it contains payload after headers.

drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c

                if (unlikely(skb_headlen(skb) > hlen)) {
                        nbd++;
                        bd_prod = bnx2x_tx_split(bp, txdata, tx_buf,
                                                 &tx_start_bd, hlen,
                                                 bd_prod);
                }
