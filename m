From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] NET: Multiple queue hardware support
Date: Thu, 21 Jun 2007 14:26:29 -0700
Message-ID: <20070621212629.31066.92148.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	kaber@trash.net, hadi@cyberus.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:31677 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753985AbXFUV0e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2007 17:26:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please consider these patches for 2.6.23 inclusion.

Updates since the last submission:

1. skb->queue_mapping moved into the iff cacheline.  I looked at moving
   iff and queue_mapping, but there wasn't enough room anywhere else to
   logically group these in a different cacheline that I could see.  Thanks
   Patrick McHardy.

2. netdev->egress_subqueue is now indexed thanks to Dave Miller.

3. sch_rr is now a MODULE_ALIAS of sch_prio.  Thanks Patrick McHardy.

4. Both sch_rr and multiqueue sch_prio expect the number of bands to
   equal the number of queues on the netdev.

This patchset is an updated version of previous multiqueue network device
support patches.  The general approach of introducing a new API for multiqueue
network devices to register with the stack has remained.  The changes include
adding a round-robin qdisc, heavily based on sch_prio, which will allow
queueing to hardware with no OS-enforced queuing policy.  sch_prio still has
the multiqueue code in it, but has a Kconfig option to compile it out of the
qdisc.  This allows people with hardware containing scheduling policies to
use sch_rr (round-robin), and others without scheduling policies in hardware
to continue using sch_prio if they wish to have some notion of scheduling
priority.

The patches being sent are split into Documentation, Qdisc changes, and
core stack changes.  The requested e1000 changes are still being resolved,
and will be sent at a later date.

I did not modify other users of netif_queue_stopped() in net/core/netpoll.c,
net/core/dev.c, or net/core/pktgen.c, since no classification occurs for
the skb being sent to the device.  Therefore, packets should always be
ending up in queue 0, so there's no need to check the subqueue status either.

The patches to iproute2 for tc will be sent separately, to support sch_rr.

-- 
PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
