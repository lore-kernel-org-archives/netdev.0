From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net: solve a NAPI race
Date: Mon, 27 Feb 2017 21:08:10 -0500 (EST)
Message-ID: <20170227.210810.197044715013755200.davem@davemloft.net>
References: <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170227.111944.1725806340309799464.davem@davemloft.net>
        <1488213854.9415.198.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, saeedm@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52432 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdB1CIN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 21:08:13 -0500
In-Reply-To: <1488213854.9415.198.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Feb 2017 08:44:14 -0800

> Any point doing a napi_schedule() not from device hard irq handler
> is subject to the race for NIC using some kind of edge trigger
> interrupts.
> 
> Since we do not provide a ndo to disable device interrupts, the
> following can happen.

Ok, now I understand.

I think even without considering the race you are trying to solve,
this situation is really dangerous.

I am sure that every ->poll() handler out there was written by an
author who completely assumed that if they are executing then the
device's interrupts for that NAPI instance are disabled.  And this is
with very few, if any, exceptions.

So if we saw a driver doing something like:

	reg->irq_enable ^= value;

after napi_complete_done(), it would be quite understandable.

We really made a mistake taking the napi_schedule() call out of
the domain of the driver so that it could manage the interrupt
state properly.

I'm not against your missed bit fix as a short-term cure for now, it's
just that somewhere down the road we need to manage the interrupt
properly.
