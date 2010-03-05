From: "Harford, Jim" <c_jharfo@quicinc.com>
Subject: RE: [PATCH] net: Fix race condition on receive path.
Date: Fri, 5 Mar 2010 15:41:05 -0800
Message-ID: <E7C319BA4F818B4BA98B1D6626E5321603261A1F03@NASANEXMB10.na.qualcomm.com>
References: <1267817699.30393.8.camel@c-dwalke-linux.qualcomm.com>
 <20100305132118.1855617a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Smith, Alan" <agsmith@quicinc.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Daniel Walker <dwalker@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:65097 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374Ab0CEXlz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 18:41:55 -0500
In-Reply-To: <20100305132118.1855617a@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It appears that this patch is no longer necessary.  It was made against 2.6.29, but I see that more recent kernel versions don't have the problem code.  For a more detailed explanation, see below.  All code references are in routine process_backlog(), file net/core/dev.c.

In kernel version 2.6.27.45, __napi_complete() is invoked BEFORE interrupts are re-enabled.  Thus, the receive queue status is cleaned up before another interrupt (due to a receive packet) can occur.  This is good design.

In kernel version 2.6.29, git commit ID 303c6a025 inverts this ordering.  Routine napi_complete() is invoked AFTER interrupts are re-enabled.  We observed interrupts taken after interrupts were re-enabled, but before napi_complete cleaned up the receive queue.  This would then shut down the processing of subsequent received packets.

In kernel versions 2.6.30.10 and later, the sequence of operations is identical to 2.6.27.45, so there is no problem.

Jim Harford
Qualcomm Innovation Center


-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@vyatta.com] 
Sent: Friday, March 05, 2010 4:21 PM
To: Daniel Walker
Cc: David S. Miller; Harford, Jim; netdev@vger.kernel.org
Subject: Re: [PATCH] net: Fix race condition on receive path.

On Fri, 05 Mar 2010 11:34:59 -0800
Daniel Walker <dwalker@codeaurora.org> wrote:

> Fixes a race condition on the networking receive path that causes all
> received packets to be dropped after 15-60 minutes of heavy network usage.
> Function process_backlog() empties the receive queue, re-enables
> interrupts, then "completes" the softIRQ.  This provides a time window for
> netif_rx() to execute (in IRQ context) and enqueue a received packet
> without re-scheduling the softIRQ.  After this, the receive queue is never
> processed and the system eventually begins to drop all received packets.

I wonder why this hasn't shown up before?

Where exactly is the window between empty process_backlog and netif_rx?

Maybe it is ARM specific behavior of softirq?
