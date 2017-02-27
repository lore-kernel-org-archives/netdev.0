From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: solve a NAPI race
Date: Mon, 27 Feb 2017 06:06:39 -0800
Message-ID: <1488204399.9415.177.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35540 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751583AbdB0OPJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 09:15:09 -0500
Received: by mail-pg0-f68.google.com with SMTP id 1so1178697pgz.2
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 06:14:57 -0800 (PST)
In-Reply-To: <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-02-26 at 19:31 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> While playing with mlx4 hardware timestamping of RX packets, I found
> that some packets were received by TCP stack with a ~200 ms delay...
> 
> Since the timestamp was provided by the NIC, and my probe was added
> in tcp_v4_rcv() while in BH handler, I was confident it was not
> a sender issue, or a drop in the network.
> 
> This would happen with a very low probability, but hurting RPC
> workloads.
> 
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
> 
> Then napi_complete_done() properly reschedules the napi to make sure
> we do not miss something.
> 
> Since we manipulate multiple bits at once, use cmpxchg() like in
> sk_busy_loop() to provide proper transactions.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/linux/netdevice.h |   29 +++++++----------------
>  net/core/dev.c            |   44 ++++++++++++++++++++++++++++++++++--
>  2 files changed, 51 insertions(+), 22 deletions(-)

I will send a v2 of this patch.

Points trying to grab NAPI_STATE_SCHED not from the device driver IRQ
handler should not set NAPI_STATE_MISSED if they fail, otherwise this
adds extra work for no purpose.

One of this point is napi_watchdog() which can fire pretty often.
