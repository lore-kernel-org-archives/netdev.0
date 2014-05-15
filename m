From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net V2] xen-netback: don't move event pointer in TX
 credit timeout callback
Date: Thu, 15 May 2014 17:53:58 +0100
Message-ID: <20140515165358.GA10525@zion.uk.xensource.com>
References: <1400155158-13527-1-git-send-email-wei.liu2@citrix.com>
 <5374BB64.1080407@jajcus.net>
 <20140515141322.GI1117@zion.uk.xensource.com>
 <5374D38A.2070709@citrix.com>
 <20140515153051.GJ1117@zion.uk.xensource.com>
 <5374EC81.1070808@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, Jacek Konieczny <jajcus@jajcus.net>,
	<xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Paul Durrant <paul.durrant@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:65031 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752252AbaEOQyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 12:54:00 -0400
Content-Disposition: inline
In-Reply-To: <5374EC81.1070808@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 05:34:09PM +0100, Zoltan Kiss wrote:
[...]
> >>>
> >>>  		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
> >>>-		if (!more_to_do)
> >>>+		if (!more_to_do || rate_limited)
> >>How about calling timer_pending(&vif->credit_timeout) instead?
> >
> >timer_pending(&vif->credit_timeout) covers only one of two senarios of
> >"credit exceeded", see tx_credit_exceeded.
> The other scenario is when the packet size exceeds the credit. There is no
> packet here actually, we just want to know if this vif ran out of credit and
> waiting for the timer to fire.
> 
> >

Which place are you referring to? There's packet in the ring, right? So
you're saying in xenvif_poll "more_to_do" is true and "timer_pending" is
also true when we come to xenvif_poll again?

> >>Also, can this __napi_complete and the callback's napi_schedule race with
> >>each other? When napi_complete is between removing from the list and
> >>clearing the bit, and napi_schedule is just test&set the bit, the latter
> >>won't add the instance to the list again
> >>
> >
> >I think it should be fine. How is it different from what we already have
> >now? Is this something similar to what David once posted?
> >
> >   <1395756505-21573-1-git-send-email-david.vrabel@citrix.com>
> Unfortunately that discussion stalled, and my question were not answered, so
> I bumped it again. But that's different a bit: it was about racing between
> the NAPI instance (running in softirq context) and the interrupt. Here the
> danger is that the NAPI instance and the softirq can race. They both run in
> softirq context, and even if they were originally on the same CPU, I'm sure
> if the instance move somewhere else, the timer doesn't follow it.
> 

This comes back to that original question, doesn't it? That's NAPI
running on CPU A and raised by CPU B.

Wei.

> Zoli
