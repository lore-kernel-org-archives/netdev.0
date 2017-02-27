From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] net: solve a NAPI race
Date: Mon, 27 Feb 2017 08:44:14 -0800
Message-ID: <1488213854.9415.198.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170227.111944.1725806340309799464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, saeedm@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34687 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751421AbdB0QoQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 11:44:16 -0500
Received: by mail-pg0-f68.google.com with SMTP id s67so1581331pgb.1
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 08:44:16 -0800 (PST)
In-Reply-To: <20170227.111944.1725806340309799464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-27 at 11:19 -0500, David Miller wrote:

> Various rules were meant to protect these sequences, and make sure
> nothing like this race could happen.
> 
> Can you show the specific sequence that fails?
> 
> One of the basic protections is that the device IRQ is not re-enabled
> until napi_complete_done() is finished, most drivers do something like
> this:
> 
> 	napi_complete_done();
> 		- sets NAPI_STATE_SCHED
> 	enable device IRQ
> 
> So I don't understand how it is possible that "later an IRQ firing and
> finding this bit set, right before napi_complete_done() clears it".
> 
> While napi_complete_done() is running, the device's IRQ is still
> disabled, so there cannot be an IRQ firing before napi_complete_done()
> is finished.


Any point doing a napi_schedule() not from device hard irq handler
is subject to the race for NIC using some kind of edge trigger interrupts.

Since we do not provide a ndo to disable device interrupts,
the following can happen.

thread 1                                 thread 2 (could be on same cpu)

// busy polling or napi_watchdog()
napi_schedule();
...
napi->poll()

device polling:
read 2 packets from ring buffer
                                          Additional 3rd packet is available.
                                          device hard irq

                                          // does nothing because NAPI_STATE_SCHED bit is owned by thread 1
                                          napi_schedule();
                                          
napi_complete_done(napi, 2);
rearm_irq();


Note that rearm_irq() will not force the device to send an additional IRQ
for the packet it already signaled (3rd packet in my example)

At least for mlx4, only 4th packet will trigger the IRQ again.

In the old days, the race would not happen since napi->poll() was called
in direct response to a prior device IRQ :
Edge triggered hard irqs from the device for this queue were already disabled.
