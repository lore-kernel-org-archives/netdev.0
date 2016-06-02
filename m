From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/2] tun: Configure Rx queues to default to RPS
 enabled
Date: Thu, 02 Jun 2016 06:12:24 -0700
Message-ID: <1464873144.5939.177.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160602010741.9319.56926.stgit@localhost.localdomain>
	 <20160602011724.9319.15659.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34352 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbcFBNM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 09:12:27 -0400
Received: by mail-pf0-f176.google.com with SMTP id 62so31366453pfd.1
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 06:12:27 -0700 (PDT)
In-Reply-To: <20160602011724.9319.15659.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-01 at 18:17 -0700, Alexander Duyck wrote:
> This patch enables tun/tap interfaces to use RPS by default.  The
> motivation behind this is to address the fact that the interfaces are
> currently using netif_rx_ni which in turn will queue packets on whatever
> CPU the function is called on, and when combined with load balancing this
> can result in packets being received out of order.

Hmm...

I do not believe this can be made the default, this would be a major
regression in some cases.

Some users want cpu isolation. This is their number one priority.

If they use one cpu to feed packets through tun device, they do not want
to spread a DDOS to all online cpus. Traffic from one VM would hurt all
others.

We have ways to avoid reorders already in  TX path (skb->ooo_okay) and
receive path in RFS layer.

tun could probably avoid reorders using a similar technique.

netif_rx_ni() could be extended to give a hint on the cpu that processed
prior packets.

(This would be a new function)

If the prior cpu is different than current cpu, we have to look at the
backlog of prior cpu.
If not empty, and prior cpu online, we need to queue the packet to prior
cpu queue.
If empty, we can 'switch' to the new cpu queue.
