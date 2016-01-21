From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH net-next 2/2] tg3: Fix for tg3 transmit queue 0 timed
 out when too many gso_segs.
Date: Wed, 20 Jan 2016 21:07:54 -0800
Message-ID: <1453352874.6696.8.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1453290418-15331-1-git-send-email-siva.kallam@broadcom.com>
	 <1453290418-15331-3-git-send-email-siva.kallam@broadcom.com>
	 <1453351014.1223.353.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: skallam <siva.kallam@broadcom.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <prashant@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:34072 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbcAUFH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 00:07:56 -0500
In-Reply-To: <1453351014.1223.353.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-20 at 20:36 -0800, Eric Dumazet wrote: 
> On Wed, 2016-01-20 at 17:16 +0530, skallam wrote:
> > From: Siva Reddy Kallam <siva.kallam@broadcom.com>
> > 
> > There is an issue on the GSO path inside tg3_tso_bug() when we don't
> > have sufficient descriptors available, we stop the queue. This queue
> > may never get started again as there are no Tx completions pending.
> > 
> > For example if the tcp segment size is as low as 88 bytes and TSO packet
> > from the stack is quite big(<64 K), gso_segs exceeds the limit of
> > descriptors available.
> > 
> > tg3_tso_bug_gso_check() is implemented to verify if the total no. of
> > descriptors available for gso are sufficient or not. If not sufficient
> > we simply linearize the the skb and transmit it once again or drop the
> > skb.
> 
> I find this changelog misleading.
> 
> linearize wont change gso_segs
> 
> You are in fact segmenting the GSO packet, which is very different than
> linearizing it.

He is referring to linearizing it for the hardware to perform TSO.

There are 2 cases that this code is trying to handle:

1. The hardware has TSO bugs.  The code detects the condtions and then
falls back to GSO.

2. The hardware has DMA bugs (such as short DMA length, 4G DMA
boundaries, etc).  In this case, the hardware can still do TSO but
requires the SKB to be linearized.  Linearizing is expensive, so we also
try to do GSO if possible.  This patch will check whether it is possible
to do GSO or not.  If not, it will linearize the SKB and have the
hardware do TSO.

I will ask Siva to try to clarify the descriptions.
