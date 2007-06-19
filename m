From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] NET: [CORE] Stack changes to add multiqueue
 hardware support API
Date: Tue, 19 Jun 2007 15:37:58 -0700 (PDT)
Message-ID: <20070619.153758.84956272.davem@davemloft.net>
References: <20070618.232843.111185541.davem@davemloft.net>
	<D5C1322C3E673F459512FB59E0DDC329031117B0@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	hadi@cyberus.ca, kaber@trash.net
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58496
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754137AbXFSWhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 18:37:40 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329031117B0@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Tue, 19 Jun 2007 13:01:18 -0700

> I've been thinking about this more today, so please bear with me if I'm
> missing something.  Right now, with how qdisc_restart() is running, we'd
> definitely call netif_subqueue_stopped(dev, skb->queue_mapping) for all
> multi-ring and single-ring devices.  However, with Jamal's and Krishna's
> qdisc_restart() rewrite patch, the checks for netif_queue_stopped() and
> netif_subqueue_stopped() would be pushed into the qdisc's ->dequeue()
> functions.  If that's the case, then the only checks on
> egress_subqueue[x] would be for multi-ring adapters, or if someone was
> silly enough to load sch_{rr|prio} onto a single-ring device with
> multiqueue hardware support compiled in.  Given all of that, I'm not
> sure allocating egress_subqueue[0] at compile time or runtime would make
> any difference either way.  If I'm missing something, please let me know
> - I'd like to reduce any unnecessary pointer dereferences if possible,
> but given the proposed qdisc_restart(), I think the code as-is would be
> ok.

It's not being allocated at "compile time", it's being allocated
linearly into one block of ram in order to avoid pointer
derefs but it's still "dynamic" in that the size isn't known
until the alloc_netdev() call.

We do this trick all over the networking, TCP sockets are 3 or 4
different structures, all allocated into a linear block of
memory so that:

1) only one memory allocation needs to be done for each object
   create, this is not relevant for the net_device case
   except in extreme examples bringing thousands of devices
   up and down which I suppose someone can give a realistic
   example of :-)

2) each part can be accessed as an offset from the other instead
   of a pointer deref which costs a cpu memory read

Please change the allocation strategy as I recommended, thanks.
