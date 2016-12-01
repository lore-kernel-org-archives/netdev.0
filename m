From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Wed, 30 Nov 2016 16:27:39 -0800
Message-ID: <1480552059.18162.239.camel@edumazet-glaptop3.roam.corp.google.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Achiad Shochat <achiad@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Tom Herbert <tom@herbertland.com>,
        Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35271 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755322AbcLAA2m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 19:28:42 -0500
Received: by mail-pf0-f196.google.com with SMTP id i88so1466330pfk.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 16:28:41 -0800 (PST)
In-Reply-To: <1480534200.18162.203.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Another issue I found during my tests last days, is a problem with BQL,
and more generally when driver stops/starts the queue.

When under stress and BQL stops the queue, driver TX completion does a
lot of work, and servicing CPU also takes over further qdisc_run().

The work-flow is :

1) collect up to 64 (or 256 packets for mlx4) packets from TX ring, and
unmap things, queue skbs for freeing.

2) Calls netdev_tx_completed_queue(ring->tx_queue, packets, bytes); 

if (test_and_clear_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state))
     netif_schedule_queue(dev_queue);

This leaves a very tiny window where other cpus could grab __QDISC_STATE_SCHED
(They absolutely have no chance to grab it)

So we end up with one cpu doing the ndo_start_xmit() and TX completions,
and RX work.

This problem is magnified when XPS is used, if one mono-threaded application deals with
thousands of TCP sockets.

We should use an additional bit (__QDISC_STATE_PLEASE_GRAB_ME) or some way
to allow another cpu to service the qdisc and spare us.
