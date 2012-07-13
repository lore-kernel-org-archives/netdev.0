From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/2] net: Add new network device function to allow
 for MMIO batching
Date: Fri, 13 Jul 2012 09:38:49 +0200
Message-ID: <1342165129.3265.8320.camel@edumazet-glaptop>
References: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>
	 <20120712002603.27846.23752.stgit@gitlad.jf.intel.com>
	 <1342077259.3265.8232.camel@edumazet-glaptop>  <4FFEEF99.7030707@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	bhutchings@solarflare.com, therbert@google.com,
	alexander.duyck@gmail.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37344 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab2GMHiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 03:38:55 -0400
Received: by bkwj10 with SMTP id j10so2883424bkw.19
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 00:38:54 -0700 (PDT)
In-Reply-To: <4FFEEF99.7030707@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 08:39 -0700, Alexander Duyck wrote:

> The problem is in both of the cases where I have seen the issue the
> qdisc is actually empty.
> 

You mean a router workload, with links of same bandwidth.
(BQL doesnt trigger)

Frankly what percentage of linux powered machines act as high perf
routers ?

> In the case of pktgen it does not use the qdisc layer at all.  It just
> directly calls ndo_start_xmit.

pktgen is in kernel, adding a complete() call in it is certainly ok,
if we can avoid kernel bloat.

I mean, pktgen represents less than 0.000001 % of real workloads.

> 
> In the standard networking case we never fill the qdisc because the MMIO
> write stalls the entire CPU so the application never gets a chance to
> get ahead of the hardware.  From what I can tell the only case in which
> the qdisc_run solution would work is if the ndo_start_xmit was called on
> a different CPU from the application that is doing the transmitting.

Hey, I can tell that qdisc is not empty on many workloads.
But BQL and TSO mean we only send one or two packets per qdisc run.

I understand this MMIO batching helps routers workloads, or workloads
using many small packets.

But on other workloads, this adds a significant latency source
(NET_TX_SOFTIRQ)

It would be good to instrument the extra delay on a single UDP send.

(entering do_softirq() path is not a few instructions...)
