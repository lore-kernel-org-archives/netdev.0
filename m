From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Add the CPU id to skb->queue_mapping's upper
 8 bits
Date: Tue, 24 Jun 2008 16:37:42 -0700 (PDT)
Message-ID: <20080624.163742.224488012.davem@davemloft.net>
References: <20080624232545.11654.65805.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757407AbYFXXhz@vger.kernel.org>
In-Reply-To: <20080624232545.11654.65805.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 24 Jun 2008 16:27:12 -0700

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> This patch adds the CPU index to the upper 8 bits of the queue_mapping in
> the skb.  This will support 256 CPUs and 256 Tx queues.  The reason for
> this is the qdisc layer can obscure which CPU is generating a certain flow
> of packets, so network drivers don't have any insight which CPU generated a
> particular packet.  If the driver knows which CPU generated the packet,
> then it could adjust Rx filtering in the hardware to redirect the packet
> back to the CPU who owns the process that generated this packet.
> Preventing the cache miss and reschedule of a process to a different CPU is
> a big win in network performance, especially at 10 gigabit speeds.
> 
> Signed-off-by: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Well:

1) All of this multiqueue stuff is going away with my changes in
   net-tx-2.6

2) This CPU number is going to be wrong half of the time.

For #2, when TCP is processing ACKs, it sends packets out from
whichever CPU the ACK landed on.

So you could end up retargetting the RX flow back and forth between
cpus.  The cpu that sends the packet into the device layer is far
from the cpu that should be used to target the RX flow at.

So this idea is pretty seriously flawed and the infrastructure it's
using is going away anyways.

It also adds all sorts of arbitray limitations (256 queues and cpus? I
already have systems coming to me with more than 256 cpus)
