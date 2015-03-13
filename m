From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] xps: fix xps for stacked devices
Date: Thu, 12 Mar 2015 17:02:53 -0700
Message-ID: <1426204973.11398.177.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423036104.907.99.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7NQgYRG9oCXYB+H_7opcbebJCbpPq_UnYNf0bQ3fEWh+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:34285 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbbCMACz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 20:02:55 -0400
Received: by iecsl2 with SMTP id sl2so68691527iec.1
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 17:02:54 -0700 (PDT)
In-Reply-To: <CAHA+R7NQgYRG9oCXYB+H_7opcbebJCbpPq_UnYNf0bQ3fEWh+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-12 at 16:48 -0700, Cong Wang wrote:

> I am trying to understand this, and wondering how possible CPUC or the CPU
> whichever faster can dequeue P2 instead of P1? Since we always dequeue
> from root qdisc and take the root qdisc lock before dequeue, the order should
> be guaranteed?
> 
> Also, since CPUA enqueues P1 and P2, the root qdisc is supposed to schedule
> on CPUA too, in which case it is CPUB or CPUC which can run dequeue()?
> Looks like htb schedules the root qdisc by itself, but it schedules the work
> on the same cpu with dequeue(), the hrtimer is pinned as well, so I don't
> see the possibility.

The trick is that bond0 (qdisc_run()) can dequeue a bunch of packets,
that were queued by CPUX, CPUZ, CPUT, from CPUB.

So the next enqueues (to slaves) will appear to happen from CPUB.

We want XPS to respect the original cpu, not the victim servicing bond0
qdisc.
