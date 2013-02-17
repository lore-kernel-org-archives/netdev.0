From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tuntap: Overload handling
Date: Sun, 17 Feb 2013 09:43:18 -0800
Message-ID: <1361122998.19353.86.camel@edumazet-glaptop>
References: <CAGUzgdK9U3hreLxtc6eP3CSpLsfhkn2ZKpFp9_VJhWr2gz0uCQ@mail.gmail.com>
	 <CAGUzgdJOLmOyd9dd=Ht-qgZ9B-or59pDwaUY28DrbnL4BKFPcw@mail.gmail.com>
	 <1360859547.6884.51.camel@edumazet-glaptop>
	 <20130214164053.GB18721@redhat.com>
	 <1360861290.6884.55.camel@edumazet-glaptop>
	 <20130217132404.GA22552@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sebastian =?ISO-8859-1?Q?P=F6hn?=
	<sebastian.poehn@googlemail.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:43839 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357Ab3BQRnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 12:43:20 -0500
Received: by mail-pa0-f49.google.com with SMTP id kp6so2425677pab.8
        for <netdev@vger.kernel.org>; Sun, 17 Feb 2013 09:43:20 -0800 (PST)
In-Reply-To: <20130217132404.GA22552@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-02-17 at 15:24 +0200, Michael S. Tsirkin wrote:

> But, userspace is in no position to decide whether using
> the qdisc is a good or a bad thing.
> The issue I tried to solve is that with tun, it's trivially easy for
> userspace to lock up resources forever.
> Simply not stopping the qdisc is probably the simplest solution.
> 
> An alternative is to orphan the skbs before we queue them.
> At some point I posted a proposal doing exactly this
> subj of "net: orphan queued skbs if device tx can stall".
> Do you think it's worth revisiting this?


Its trivially easy for userspace to consume all resources, with or
without tuntap.

Say, a regular Gbps ethernet device.

We need some flow control at some point, unless we deal with device
with unlimited bandwidth.

If we orphan skbs too soon, how can we limit a single sender to flood
the device ? Even a single TCP flow could do that. TCP Small Queues
prevent this, but relies on proper skb orphaning.

If the tuntap problem is that skb can sit there and are never consumed,
its not a bug in the producer (the sender), but a problem with the
receiver (the consumer of the queue). Some kind of cleanup is needed.

Lets take the qdisc analogy :

Codel for instance is able to drop packets that are sitting too long in
queue. skbs are not orphaned until they are freed.
