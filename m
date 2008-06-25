From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Add the CPU id to skb->queue_mapping's upper
 8 bits
Date: Wed, 25 Jun 2008 16:37:28 -0700 (PDT)
Message-ID: <20080625.163728.59919248.davem@davemloft.net>
References: <20080624232545.11654.65805.stgit@localhost.localdomain>
	<20080624.163742.224488012.davem@davemloft.net>
	<D5C1322C3E673F459512FB59E0DDC329054E55AF@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40118
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751680AbYFYXh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 19:37:28 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329054E55AF@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Wed, 25 Jun 2008 11:31:01 -0700

> >Well:
> >
> >1) All of this multiqueue stuff is going away with my changes in
> >   net-tx-2.6
> 
> Do you have a guestimate of which kernel you'll be targeting these
> changes?  I'm very interested in this schedule.

I want it to hit 2.6.27

> The whole point is to identify the flow and redirect your Rx filtering
> to the CPU it came from.  So if you did this properly, the ACKs would be
> landing on the CPU that originally opened the TCP flow.  I don't follow
> why the scheduler would move the process if the Rx traffic is returning
> to that core.

The process scheduler monitors where wakeup events occur.
If predominantly they arrive on a difference cpu from where
the process is currently scheduled, the scheduler might decide
to move the process there.

This RX retargetting idea is also flawed from another perspective.

Let's say you have a server thread polling on a lot of
connections.  And let's say that all of these connections
become extremely active all of a sudden.

If you RX steer all of those flows to the same cpu we might
as well not do any RX hashing at all.  The whole point is
to distribute the network stack input processing across
the machine as much as possible.

If you try to steer RX traffic to cpus that processes are running
on, you will undo almost all of the intended benefit of RX hashing
in many common scnenerios.

Don't second guess the process scheduler we have, it will or
should do the right thing in these situations because it can
see what is going on in ways that the NIC and the networking
alone simply cannot.  It knows about cache effects and tradeoffs
of moving tasks between cores and NUMA nodes.

