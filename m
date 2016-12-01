From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Thu, 01 Dec 2016 06:24:34 -0800
Message-ID: <1480602274.18162.285.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
         <20161116234022.2bad179b@redhat.com>
         <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117091638.5fab8494@redhat.com>
         <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117144248.23500001@redhat.com>
         <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117155753.17b76f5a@redhat.com>
         <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117193021.580589ae@redhat.com>
         <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161121170351.50a09ee1@redhat.com>
         <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG_G3G-_jFFD0xiAOfR-k69rhb_2ia4LHZroE-oEFxApnQ@mail.gmail.com>
         <1480520661.18162.177.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG9iCWkk2WTGrkFhZ61Sx5R-JDCxANhLQZPO8E47QGwOmQ@mail.gmail.com>
         <20161201130505.0b4a5cd5@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Rick Jones <rick.jones2@hpe.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33557 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751364AbcLAOYg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 09:24:36 -0500
Received: by mail-pf0-f196.google.com with SMTP id 144so12049219pfv.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 06:24:36 -0800 (PST)
In-Reply-To: <20161201130505.0b4a5cd5@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-01 at 13:05 +0100, Jesper Dangaard Brouer wrote:
> On Wed, 30 Nov 2016 18:27:45 +0200
> Saeed Mahameed <saeedm@dev.mellanox.co.il> wrote:
> 
> > >> All in all, this is risky business :),  the right way to go is to
> > >> force the upper layer to use xmit-more and delay doorbells/use bulking
> > >> but from the same context (xmit routine).  For example see
> > >> Achiad's suggestion (attached in Jesper's response), he used stop
> > >> queue to force the stack to queue up packets (TX bulking)
> > >> which would set xmit-more and will use the next completion to
> > >> release the "stopped" ring TXQ rather than hit the doorbell on
> > >> behalf of it.  
> > >
> > > Well, you depend on having a higher level queue like a qdisc.
> > >
> > > Some users do not use a qdisc.
> > > If you stop the queue, they no longer can send anything -> drops.
> > >
> 
> You do have a point that stopping the device might not be the best way
> to create a push-back (to allow stack queue packets).
> 
>  netif_tx_stop_queue() / __QUEUE_STATE_DRV_XOFF
> 
> 
> > In this case, i think they should implement their own bulking (pktgen
> > is not a good example) but XDP can predict if it has more packets to
> > xmit  as long as all of them fall in the same NAPI cycle.
> > Others should try and do the same.
> 
> I actually agree with Saeed here.
> 
> Maybe we can come up with another __QUEUE_STATE_xxx that informs the
> upper layer what the driver is doing.  Then users not using a qdisc can
> use this indication (like the qdisc could).  (qdisc-bypass users already
> check the QUEUE_STATE flags e.g. via netif_xmit_frozen_or_drv_stopped).

Can you explain how this is going to help trafgen using AF_PACKET with
Qdisc bypass ?

Say trafgen wants to send 10 or 1000 packets back to back (as fast as
possible)

With my proposal, only the first is triggering a doorbell from
ndo_start_xmit(). Following ones are driven by TX completion logic, or
BQL if we can push packets faster than TX interrupt can be
delivered/handled.

If you stop the queue (with yet another atomic operations to stop/unstop
btw), packet_direct_xmit() will have to drop trafgen packets on the
floor.

We already have BQL stopping the queue at a fine granularity.
I suspect that Saeed proposal will interfere with BQL logic.
