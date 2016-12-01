From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Thu, 01 Dec 2016 14:04:51 -0800
Message-ID: <1480629891.18162.340.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
         <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
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
         <CAKgT0Uf_EeWYqGinyV6U1r-Jqd07R9gN-7GeA82emk4EoN=1mQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Rick Jones <rick.jones2@hpe.com>,
        Netdev <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36631 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755703AbcLAWFy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 17:05:54 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so5781996pgx.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 14:05:53 -0800 (PST)
In-Reply-To: <CAKgT0Uf_EeWYqGinyV6U1r-Jqd07R9gN-7GeA82emk4EoN=1mQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-01 at 13:32 -0800, Alexander Duyck wrote:

> A few years back when I did something like this on ixgbe I was told by
> you that the issue was that doing something like this would add too
> much latency.  I was just wondering what the latency impact is on a
> change like this and if this now isn't that much of an issue?

I believe it is clear that we can not use this trick without admin
choice.

In my experience, mlx4 can deliver way more interrupts than ixgbe.
(No idea why)

This "auto doorbell" is tied to proper "ethtool -c tx-usecs|tx-frames|
tx-frames-irq", or simply a choice for hosts dedicated to content
delivery (like video servers) with 40GBit+ cards.

Under stress, softirq can be handled by ksoftirqd, and might be delayed
by ~10 ms or even more.

This WIP was minimal, but we certainly need to add belts and suspenders.

1) <maybe> timestamps
  use a ktime_get_ns() to remember a timestamp for the last doorbell,
  and force a doorbell if it gets too old, checked in ndo_start_xmit()
  every time we would like to not send the doorbell.

2) <maybe> max numbers of packets not yet doorbelled.

But we can not rely on another high resolution timer, since they also
require softirq being processed timely.
