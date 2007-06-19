From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [CORE] Stack changes to add multiqueue hardware support API
Date: Tue, 19 Jun 2007 13:01:18 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329031117B0@orsmsx414.amr.corp.intel.com>
References: <20070618.232843.111185541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>,
	<kaber@trash.net>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:24215 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765117AbXFSUBV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 16:01:21 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070618.232843.111185541.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> Date: Mon, 18 Jun 2007 11:42:29 -0700
> 
> > +
> > + 	/* The TX queue control structures */
> > + 	struct net_device_subqueue	*egress_subqueue;
> > + 	int				egress_subqueue_count;
> 
> Since every net device will have at least one subqueue, I 
> would suggest that you do this as follows:
> 
> 1) In net_device change the quoted part of the patch above to:
> 
> 	int				egress_subqueue_count;
> 	struct net_device_subqueue	egress_subqueue[0];
> 
> 2) In alloc_netdev():
> 
>    Factor (sizeof(struct egress_subqueue) * num_subqueues) into
>    the net_device allocation size, place the "priv" area after
>    the subqueues.
> 
> This will save us pointer dereferences on all of these quite 
> common accesses.

I've been thinking about this more today, so please bear with me if I'm
missing something.  Right now, with how qdisc_restart() is running, we'd
definitely call netif_subqueue_stopped(dev, skb->queue_mapping) for all
multi-ring and single-ring devices.  However, with Jamal's and Krishna's
qdisc_restart() rewrite patch, the checks for netif_queue_stopped() and
netif_subqueue_stopped() would be pushed into the qdisc's ->dequeue()
functions.  If that's the case, then the only checks on
egress_subqueue[x] would be for multi-ring adapters, or if someone was
silly enough to load sch_{rr|prio} onto a single-ring device with
multiqueue hardware support compiled in.  Given all of that, I'm not
sure allocating egress_subqueue[0] at compile time or runtime would make
any difference either way.  If I'm missing something, please let me know
- I'd like to reduce any unnecessary pointer dereferences if possible,
but given the proposed qdisc_restart(), I think the code as-is would be
ok.

Thanks,
-PJ Waskiewicz
