From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH 0/2] Coalesce MMIO writes for transmits
Date: Thu, 12 Jul 2012 12:01:18 -0700
Message-ID: <4FFF1EFE.7070002@intel.com>
References: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com> <20120712102331.42a7b041@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	bhutchings@solarflare.com, therbert@google.com,
	alexander.duyck@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54872 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932833Ab2GLTBT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 15:01:19 -0400
In-Reply-To: <20120712102331.42a7b041@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/2012 10:23 AM, Stephen Hemminger wrote:
> On Wed, 11 Jul 2012 17:25:58 -0700
> Alexander Duyck <alexander.h.duyck@intel.com> wrote:
>
>> This patch set is meant to address recent issues I found with ixgbe
>> performance being bound by Tx tail writes.  With these changes in place
>> and the dispatch_limit set to 1 or more I see a significant increase in
>> performance.
>>
>> In the case of one of my systems I saw the routing rate for 7 queues jump
>> from 10.5 to 11.7Mpps.  The overall increase I have seen on most systems is
>> something on the order of about 15%.  In the case of pktgen I have also
>> seen a noticeable increase as the previous limit for transmits was
>> ~12.5Mpps, but with this patch set in place and the dispatch_limit enabled
>> the value increases to ~14.2Mpps.
>>
>> I expected there to be an increase in latency, however so far I have not
>> ran into that.  I have tried running NPtcp tests for latency and seen no
>> difference in the coalesced and non-coalesced transaction times.  I welcome
>> any suggestions for tests I might run that might expose any latency issues
>> as a result of this patch.
>>
>> ---
>>
>> Alexander Duyck (2):
>>       ixgbe: Add functionality for delaying the MMIO write for Tx
>>       net: Add new network device function to allow for MMIO batching
>>
>>
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   22 +++++++-
>>  include/linux/netdevice.h                     |   57 +++++++++++++++++++++
>>  net/core/dev.c                                |   67 +++++++++++++++++++++++++
>>  net/core/net-sysfs.c                          |   36 +++++++++++++
>>  4 files changed, 180 insertions(+), 2 deletions(-)
>>
> This is a good idea. I was thinking of adding a multi-skb operation
> to netdevice_ops to allow this. Something like ndo_start_xmit_pkts but
> the problem is how to deal with the boundary case where there is only
> a limited number of slots in the ring.  Using a "that's all folks"
> operation seems better.
I had considered a multi-skb operation originally, but the problem was
in my case I would have had to come up with a more complex buffering
mechanism to generate a stream of skbs before handing them off to the
device.  By letting the transmit path proceed normally I shouldn't have
any effect on things like the byte queue limits for the transmit queues
and such.

The wierd bit is how this issue was showing up.  I don't know if you
recall my presentation from plumbers last year, but one of the things I
had brought up was the qdisc spinlock being an issue.  However it was
actually this MMIO write that was causing the problem because it was
posting a write to non-coherent memory and then the spinlock was getting
stalled behind the write and couldn't complete until the write was
completed.  With this change in place and the dispatch_limit set to
something like 31 I see the CPU utilization for spinlocks drop from 15%
(90% sch_direct_xmit / 10% dev_queue_xmit) to 5% (66% sch_direct_xmit /
33% dev_queue_xmit).  Makes me wonder what other hotspots we have in the
drivers  that can be resolved by avoiding MMIO followed by locked
operations.

Thanks,

Alex
