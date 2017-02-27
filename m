From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net: solve a NAPI race
Date: Mon, 27 Feb 2017 11:19:44 -0500 (EST)
Message-ID: <20170227.111944.1725806340309799464.davem@davemloft.net>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, saeedm@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdB0QVS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 11:21:18 -0500
In-Reply-To: <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Feb 2017 06:21:38 -0800

> A NAPI driver normally arms the IRQ after the napi_complete_done(),
> after NAPI_STATE_SCHED is cleared, so that the hard irq handler can grab
> it.
> 
> Problem is that if another point in the stack grabs NAPI_STATE_SCHED bit
> while IRQ are not disabled, we might have later an IRQ firing and
> finding this bit set, right before napi_complete_done() clears it.
> 
> This can happen with busy polling users, or if gro_flush_timeout is
> used. But some other uses of napi_schedule() in drivers can cause this
> as well.
> 
> This patch adds a new NAPI_STATE_MISSED bit, that napi_schedule_prep()
> can set if it could not grab NAPI_STATE_SCHED

Various rules were meant to protect these sequences, and make sure
nothing like this race could happen.

Can you show the specific sequence that fails?

One of the basic protections is that the device IRQ is not re-enabled
until napi_complete_done() is finished, most drivers do something like
this:

	napi_complete_done();
		- sets NAPI_STATE_SCHED
	enable device IRQ

So I don't understand how it is possible that "later an IRQ firing and
finding this bit set, right before napi_complete_done() clears it".

While napi_complete_done() is running, the device's IRQ is still
disabled, so there cannot be an IRQ firing before napi_complete_done()
is finished.
