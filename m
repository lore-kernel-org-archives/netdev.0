From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Fri, 12 Aug 2011 11:20:25 -0700
Message-ID: <20110812112025.5788de0b@nehalam.ftrdhcpuser.net>
References: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53078 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379Ab1HLSUR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 14:20:17 -0400
In-Reply-To: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 7 Aug 2011 21:43:13 -0700 (PDT)
Tom Herbert <therbert@google.com> wrote:

> Changes from last version:
> - Simplified and generalized driver interface.  Drivers need to
>   implement two functions:
>     netdev_tx_completed_queue: Called at end of transmit completion
>       to inform stack of number of bytes and packets processed.
>     netdev_tx_sent_queue: Called to inform stack when packets are
>       queued.
> 
>     netdev_tx_reset_queue: is optional to reset state in the stack
> 
> - Added new per queue flags that allow stack to stop a queue
>   separately from driver doing this.  Driver continue using the
>   same functions to stop queues, but there are two functions that
>   the stack calls (to check if queue has been stopped by driver or
>   stack:
> 
>   netif_xmit_stopped,netif_xmit_frozen_or_stopped
> 
> - Added example support for bnx2x and sfc (demonstrates operation over
>   multi-queue)
> 
> - Removed BQL being under CONFIG_RPS (didn't add CONFIG_BQL)
> 
> - Still needs some more testing, including ishowing benfits to high
>   priority packets in QoS.
> ----
> 
> This patch series implements byte queue limits (bql) for NIC TX queues.
> 
> Byte queue limits are a mechanism to limit the size of the transmit
> hardware queue on a NIC by number of bytes. The goal of these byte
> limits is too reduce latency caused by excessive queuing in hardware
> without sacrificing throughput.
> 
> Hardware queuing limits are typically specified in terms of a number
> hardware descriptors, each of which has a variable size. The variability
> of the size of individual queued items can have a very wide range. For
> instance with the e1000 NIC the size could range from 64 bytes to 4K
> (with TSO enabled). This variability makes it next to impossible to
> choose a single queue limit that prevents starvation and provides lowest
> possible latency.
> 
> The objective of byte queue limits is to set the limit to be the
> minimum needed to prevent starvation between successive transmissions to
> the hardware. The latency between two transmissions can be variable in a
> system. It is dependent on interrupt frequency, NAPI polling latencies,
> scheduling of the queuing discipline, lock contention, etc. Therefore we
> propose that byte queue limits should be dynamic and change in
> iaccordance with networking stack latencies a system encounters.

A couple of other related points:

1. Need a way to configure the values.  My preference would be new
   netlink attribute and via 'ip link set' ...

2. Does this need to know the speed of the link (autonegotiation) or
   is it self clocking?


