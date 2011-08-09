From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Tue, 9 Aug 2011 11:28:43 -0700
Message-ID: <CA+mtBx9DWop_HYU9H4X-9nuFZw8epJhqy9FPArz6evSY0=9Ohg@mail.gmail.com>
References: <20110808105529.4c8c52e1@nehalam.ftrdhcpuser.net>
	<CA+mtBx_bdCGvR+xBMq9px0vOV6a6kFn0wYyJH26+CdSPLtvgfw@mail.gmail.com>
	<20110808111917.4b2669de@nehalam.ftrdhcpuser.net>
	<20110809.004123.2080217558650594315.davem@davemloft.net>
	<1312877173.2371.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110809075454.5331dcac@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:1243 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab1HIS2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 14:28:47 -0400
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p79ISjht006020
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2011 11:28:45 -0700
Received: from iym5 (iym5.prod.google.com [10.241.52.5])
	by kpbe16.cbf.corp.google.com with ESMTP id p79IN1iF027763
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2011 11:28:43 -0700
Received: by iym5 with SMTP id 5so442509iym.37
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 11:28:43 -0700 (PDT)
In-Reply-To: <20110809075454.5331dcac@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ok. then we need to fix all NAPI drivers at once, and get more
> drivers converted over to NAPI. It is really annoying how there
> is just too much variation among network drivers.

Agreed this variation has created a mess and makes it difficult to add
this sort of functionality.  But I'm not sure what the "fix" would be.

For instance...

It seems like there are three primary points points where drivers
interact with stack to stop or wakeup queue:

1) On start-xmit, availability is checked and queue is stopped if no
space available queue is stopped.  Some drivers report an error if
there was no availability and queue had not been stopped as expected.
2) At the end of start-xmit availability is checked and queue is
stopped if necessary.
3) At end of completion processing, availability is checked and queue
is waked up if necessary.

Each of these are several lines of code in each driver, and seem to be
begging for a unified abstraction.  For instance in tg3 instead of:

if (unlikely(netif_tx_queue_stopped(txq) &&
                     (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi)))) {
                __netif_tx_lock(txq, smp_processor_id());
                if (netif_tx_queue_stopped(txq) &&
                    (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi)))
                        netif_tx_wake_queue(txq);
                __netif_tx_unlock(txq);
        }

we probably would want something like:

netif_tx_queue_complete_check(txq, pkts, bytes, tg3_tx_avail(tnapi) >
TG3_TX_WAKEUP_THRESH(tnapi))

which would do all the work to check for available space, wakeup the
queue, statistic, bql, etc...

I actually did consider abstracting these out as part of bql, but even
though drivers implemented these in similar ways, variations in each
driver might make introducing a unified abstraction nontrivial (like
where drivers need to insert memory barriers and variations in
locking).
