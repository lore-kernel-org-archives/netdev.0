From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 18/18] netvsc: call netif_receive_skb
Date: Tue, 24 Jan 2017 15:00:28 -0800
Message-ID: <20170124150028.4981db42@xeon-e3>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
        <20170124210615.18628-19-sthemmin@microsoft.com>
        <1485297559.16328.343.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kys@microsoft.com, netdev@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36620 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750914AbdAXXAi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 18:00:38 -0500
Received: by mail-pg0-f48.google.com with SMTP id t6so58495471pgt.3
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 15:00:38 -0800 (PST)
In-Reply-To: <1485297559.16328.343.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Jan 2017 14:39:19 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2017-01-24 at 13:06 -0800, Stephen Hemminger wrote:
> > To improve performance, netvsc can call network stack directly and
> > avoid the local backlog queue. This is safe since incoming packets are
> > handled in softirq context already because the receive function
> > callback is called from a tasklet.  
> 
> Is this tasklet implementing a limit or something ?

The ring only holds a fixed amount of data so there is a limit but
it is quite large.

> 
> netif_rx() queues packets to the backlog, which is processed later by
> net_rx_action() like other NAPI, with limit of 64 packets per round.

Since netvsc_receive has to copy all incoming data it is a bottleneck
unto itself. By the time net_rx_action is invoked the cache is stale.

> 
> Calling netif_receive_skb() means you can escape this ability to fairly
> distribute the cpu cycles among multiple NAPI.
> 
> I do not see range_cnt being capped in netvsc_receive()

There is no cap. NAPI is coming and will help.
