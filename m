From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 2/2] tun: Configure Rx queues to default to RPS enabled
Date: Thu, 2 Jun 2016 08:24:31 -0700
Message-ID: <CAKgT0UdbBfhdz1x=qC4s_s_RcL0xJuwj20yzMGZagKro3q3ayg@mail.gmail.com>
References: <20160602010741.9319.56926.stgit@localhost.localdomain>
	<20160602011724.9319.15659.stgit@localhost.localdomain>
	<1464873144.5939.177.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33669 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161167AbcFBPYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 11:24:33 -0400
Received: by mail-io0-f196.google.com with SMTP id p194so6980463iod.0
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 08:24:32 -0700 (PDT)
In-Reply-To: <1464873144.5939.177.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 2, 2016 at 6:12 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-06-01 at 18:17 -0700, Alexander Duyck wrote:
>> This patch enables tun/tap interfaces to use RPS by default.  The
>> motivation behind this is to address the fact that the interfaces are
>> currently using netif_rx_ni which in turn will queue packets on whatever
>> CPU the function is called on, and when combined with load balancing this
>> can result in packets being received out of order.
>
> Hmm...
>
> I do not believe this can be made the default, this would be a major
> regression in some cases.

Yeah, while thinking about it this morning I kind of realized the
solution is very x86-centric as well.  It assumes all CPUs are equal
and I know there are a few architectures where that is not the case.

> Some users want cpu isolation. This is their number one priority.
>
> If they use one cpu to feed packets through tun device, they do not want
> to spread a DDOS to all online cpus. Traffic from one VM would hurt all
> others.
>
> We have ways to avoid reorders already in  TX path (skb->ooo_okay) and
> receive path in RFS layer.
>
> tun could probably avoid reorders using a similar technique.
>
> netif_rx_ni() could be extended to give a hint on the cpu that processed
> prior packets.
>
> (This would be a new function)
>
> If the prior cpu is different than current cpu, we have to look at the
> backlog of prior cpu.
> If not empty, and prior cpu online, we need to queue the packet to prior
> cpu queue.
> If empty, we can 'switch' to the new cpu queue.

What I can probably do is look into borrowing some of the code from
the receive flow steering path.  I believe there was some logic there
that already did checks for packets in the backlog.  What I can
probably do is just make use of that in order to avoid reordering.

- Alex
