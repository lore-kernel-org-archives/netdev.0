From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH 0/2] Coalesce MMIO writes for transmits
Date: Thu, 12 Jul 2012 10:23:31 -0700
Message-ID: <20120712102331.42a7b041@nehalam.linuxnetplumber.net>
References: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	bhutchings@solarflare.com, therbert@google.com,
	alexander.duyck@gmail.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50968 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932586Ab2GLRXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 13:23:50 -0400
In-Reply-To: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Jul 2012 17:25:58 -0700
Alexander Duyck <alexander.h.duyck@intel.com> wrote:

> This patch set is meant to address recent issues I found with ixgbe
> performance being bound by Tx tail writes.  With these changes in place
> and the dispatch_limit set to 1 or more I see a significant increase in
> performance.
> 
> In the case of one of my systems I saw the routing rate for 7 queues jump
> from 10.5 to 11.7Mpps.  The overall increase I have seen on most systems is
> something on the order of about 15%.  In the case of pktgen I have also
> seen a noticeable increase as the previous limit for transmits was
> ~12.5Mpps, but with this patch set in place and the dispatch_limit enabled
> the value increases to ~14.2Mpps.
> 
> I expected there to be an increase in latency, however so far I have not
> ran into that.  I have tried running NPtcp tests for latency and seen no
> difference in the coalesced and non-coalesced transaction times.  I welcome
> any suggestions for tests I might run that might expose any latency issues
> as a result of this patch.
> 
> ---
> 
> Alexander Duyck (2):
>       ixgbe: Add functionality for delaying the MMIO write for Tx
>       net: Add new network device function to allow for MMIO batching
> 
> 
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   22 +++++++-
>  include/linux/netdevice.h                     |   57 +++++++++++++++++++++
>  net/core/dev.c                                |   67 +++++++++++++++++++++++++
>  net/core/net-sysfs.c                          |   36 +++++++++++++
>  4 files changed, 180 insertions(+), 2 deletions(-)
> 

This is a good idea. I was thinking of adding a multi-skb operation
to netdevice_ops to allow this. Something like ndo_start_xmit_pkts but
the problem is how to deal with the boundary case where there is only
a limited number of slots in the ring.  Using a "that's all folks"
operation seems better.
