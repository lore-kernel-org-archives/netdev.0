From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 net] net: solve a NAPI race
Date: Mon, 27 Feb 2017 14:14:03 -0800
Message-ID: <20170227141403.714490f7@xeon-e3>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488226711.9415.204.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34486 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751419AbdB0WOo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 17:14:44 -0500
Received: by mail-pg0-f43.google.com with SMTP id p5so25409205pga.1
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 14:14:11 -0800 (PST)
In-Reply-To: <1488226711.9415.204.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Feb 2017 12:18:31 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> thread 1                                 thread 2 (could be on same cpu)
> 
> // busy polling or napi_watchdog()
> napi_schedule();
> ...
> napi->poll()
> 
> device polling:
> read 2 packets from ring buffer
>                                           Additional 3rd packet is available.
>                                           device hard irq
> 
>                                           // does nothing because NAPI_STATE_SCHED bit is owned by thread 1
>                                           napi_schedule();
>                                           
> napi_complete_done(napi, 2);
> rearm_irq();

The original design (as Davem mentioned) was that IRQ's must be disabled
during device polling. If that was true, then the race above
would be impossible. Also NAPI assumes interrupts are level triggered.
