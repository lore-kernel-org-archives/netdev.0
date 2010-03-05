From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: Fix race condition on receive path.
Date: Fri, 5 Mar 2010 15:48:12 -0800
Message-ID: <20100305154812.55a59038@nehalam>
References: <1267817699.30393.8.camel@c-dwalke-linux.qualcomm.com>
	<20100305132118.1855617a@nehalam>
	<E7C319BA4F818B4BA98B1D6626E5321603261A1F03@NASANEXMB10.na.qualcomm.com>
	<1267832667.30393.16.camel@c-dwalke-linux.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Harford, Jim" <c_jharfo@quicinc.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Smith, Alan" <agsmith@quicinc.com>
To: Daniel Walker <dwalker@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44409 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754797Ab0CEXsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Mar 2010 18:48:31 -0500
In-Reply-To: <1267832667.30393.16.camel@c-dwalke-linux.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 05 Mar 2010 15:44:27 -0800
Daniel Walker <dwalker@codeaurora.org> wrote:

> On Fri, 2010-03-05 at 15:41 -0800, Harford, Jim wrote:
> > It appears that this patch is no longer necessary.  It was made against 2.6.29, but I see that more recent kernel versions don't have the problem code.  For a more detailed explanation, see below.  All code references are in routine process_backlog(), file net/core/dev.c.
> > 
> > In kernel version 2.6.27.45, __napi_complete() is invoked BEFORE interrupts are re-enabled.  Thus, the receive queue status is cleaned up before another interrupt (due to a receive packet) can occur.  This is good design.
> > 
> > In kernel version 2.6.29, git commit ID 303c6a025 inverts this ordering.  Routine napi_complete() is invoked AFTER interrupts are re-enabled.  We observed interrupts taken after interrupts were re-enabled, but before napi_complete cleaned up the receive queue.  This would then shut down the processing of subsequent received packets.
> > 
> > In kernel versions 2.6.30.10 and later, the sequence of operations is identical to 2.6.27.45, so there is no problem.
> > 
> > Jim Harford
> > Qualcomm Innovation Center
> 
> Ok, I guess we can ignore this one then.
> 
> Daniel
> 

It was fixed by:

commit 8f1ead2d1a626ed0c85b3d2c2046a49081d5933f
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Thu Mar 26 00:59:10 2009 -0700

    GRO: Disable GRO on legacy netif_rx path
    
    When I fixed the GRO crash in the legacy receive path I used
    napi_complete to replace __napi_complete.  Unfortunately they're
    not the same when NETPOLL is enabled, which may result in us
    not calling __napi_complete at all.
    
    What's more, we really do need to keep the __napi_complete call
    within the IRQ-off section since in theory an IRQ can occur in
    between and fill up the backlog to the maximum, causing us to
    lock up.
    
    Since we can't seem to find a fix that works properly right now,
    this patch reverts all the GRO support from the netif_rx path.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>
