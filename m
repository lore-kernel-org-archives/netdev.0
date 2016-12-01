From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Thu, 1 Dec 2016 14:24:25 -0500
Message-ID: <CAF=yD-+1ukXZoBq4L__8yA9f-OAJGU4=1WrJd9nH+uvkOy5ZLw@mail.gmail.com>
References: <20140903165943.372b897b@redhat.com> <20161116131609.4e5726b4@redhat.com>
 <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com> <20161116234022.2bad179b@redhat.com>
 <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117091638.5fab8494@redhat.com> <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117144248.23500001@redhat.com> <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117155753.17b76f5a@redhat.com> <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117193021.580589ae@redhat.com> <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161121170351.50a09ee1@redhat.com> <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161130123810.581ba21f@redhat.com> <1480521386.18162.189.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161130201711.2f353a76@redhat.com> <1480534200.18162.203.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480552059.18162.239.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S35UZcD+kXTTGeML4DdDYaUoArSfEPeUoTuFEeRWKsM7sQ@mail.gmail.com>
 <1480559566.18162.253.camel@edumazet-glaptop3.roam.corp.google.com> <CALx6S34ENTbUmCGx_4izNHoXbdy5UHuvUesbFGw+8kQSidesEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Willem de Bruijn <willemb@google.com>,
        Rick Jones <rick.jones2@hpe.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Achiad Shochat <achiad@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:34437 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbcLATZG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 14:25:06 -0500
Received: by mail-ua0-f194.google.com with SMTP id b35so22247454uaa.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 11:25:06 -0800 (PST)
In-Reply-To: <CALx6S34ENTbUmCGx_4izNHoXbdy5UHuvUesbFGw+8kQSidesEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> > So we end up with one cpu doing the ndo_start_xmit() and TX completions,
>>> > and RX work.

This problem is somewhat tangential to the doorbell avoidance discussion.

>>> >
>>> > This problem is magnified when XPS is used, if one mono-threaded application deals with
>>> > thousands of TCP sockets.
>>> >
>> We have thousands of applications, and some of them 'kind of multicast'
>> events to a broad number of TCP sockets.
>>
>> Very often, applications writers use a single thread for doing this,
>> when all they need is to send small packets to 10,000 sockets, and they
>> do not really care of doing this very fast. They also do not want to
>> hurt other applications sharing the NIC.
>>
>> Very often, process scheduler will also run this single thread in a
>> single cpu, ie avoiding expensive migrations if they are not needed.
>>
>> Problem is this behavior locks one TX queue for the duration of the
>> multicast, since XPS will force all the TX packets to go to one TX
>> queue.
>>
> The fact that XPS is forcing TX packets to go over one CPU is a result
> of how you've configured XPS. There are other potentially
> configurations that present different tradeoffs.

Right, XPS supports multiple txqueues mappings, using skb_tx_hash
to decide among them. Unfortunately cross-cpu is more expensive
than tx + completion on the same core, so this is suboptimal for
the common case where there is no excessive load imbalance.

> For instance, TX
> queues are plentiful now days to the point that we could map a number
> of queues to each CPU while respecting NUMA locality between the
> sending CPU and where TX completions occur. If the set is sufficiently
> large this would also helps to address device lock contention. The
> other thing I'm wondering is if Willem's concepts distributing DOS
> attacks in RPS might be applicable in XPS. If we could detect that a
> TX queue is "under attack" maybe we can automatically backoff to
> distributing the load to more queues in XPS somehow.

If only targeting states of imbalance, that indeed could work. For the
10,000 socket case, instead of load balancing qdisc servicing, we
could perhaps modify tx queue selection in __netdev_pick_tx to
choose another queue if the the initial choice is paused or otherwise
backlogged.
