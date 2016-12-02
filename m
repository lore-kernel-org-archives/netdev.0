From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Fri, 02 Dec 2016 10:16:30 -0800
Message-ID: <1480702590.18162.380.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
         <20161116131609.4e5726b4@redhat.com>
         <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
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
         <20161130123810.581ba21f@redhat.com>
         <1480521386.18162.189.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161130201711.2f353a76@redhat.com>
         <1480534200.18162.203.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480552059.18162.239.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALx6S35UZcD+kXTTGeML4DdDYaUoArSfEPeUoTuFEeRWKsM7sQ@mail.gmail.com>
         <1480559566.18162.253.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480560655.18162.255.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Willem de Bruijn <willemb@google.com>,
        Rick Jones <rick.jones2@hpe.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Achiad Shochat <achiad@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34241 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753629AbcLBSRd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:17:33 -0500
Received: by mail-pf0-f196.google.com with SMTP id y68so13964285pfb.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:17:33 -0800 (PST)
In-Reply-To: <1480560655.18162.255.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-30 at 18:50 -0800, Eric Dumazet wrote:
> On Wed, 2016-11-30 at 18:32 -0800, Eric Dumazet wrote:
> 
> > I simply suggest we try to queue the qdisc for further servicing as we
> > do today, from net_tx_action(), but we might use a different bit, so
> > that we leave the opportunity for another cpu to get __QDISC_STATE_SCHED
> > before we grab it from net_tx_action(), maybe 100 usec later (time to
> > flush all skbs queued in napi_consume_skb() and maybe RX processing,
> > since most NIC handle TX completion before doing RX processing from thei
> > napi poll handler.
> > 
> > Should be doable with few changes in __netif_schedule() and
> > net_tx_action(), plus some control paths that will need to take care of
> > the new bit at dismantle time, right ?
> 
> Hmm... this is silly. Code already implements a different bit.
> 
> qdisc_run() seems to run more often from net_tx_action(), I have to find
> out why.

After more analysis I believe TSQ was one of the bottlenecks.

I prepared a patch series that helped my use cases.
