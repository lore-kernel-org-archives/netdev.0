From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 14:27:35 -0700 (PDT)
Message-ID: <20080819.142735.179034162.davem@davemloft.net>
References: <alpine.LFD.1.10.0808191341150.3324@nehalem.linux-foundation.org>
	<20080819.140458.236030589.davem@davemloft.net>
	<alpine.LFD.1.10.0808191411390.3324@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32891
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758785AbYHSV1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 17:27:35 -0400
In-Reply-To: <alpine.LFD.1.10.0808191411390.3324@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 19 Aug 2008 14:21:57 -0700 (PDT)

> 
> 
> On Tue, 19 Aug 2008, David Miller wrote:
> > 
> > Those fix a performance regression reported by a real user.
> 
> Since when?

Check the regression list entry you were pointed to in another
reply.

But I'll save you some time and I'll explain the problem for you.

We enabled GSO segmentation offload, which is a software variant of
TSO we've had in the tree for ages, when a card can do scatter-gather
and checksumming offloading in HW.  We do this because Lennert
Buytenhek validated with many tests that this consistently decreases
cpu utilization.

However, a user reported that if they NAT'd a remote destination port
using netfilter to a loopback addr:port, then there was a performance
degradation.

Herbert discovered the cause, which was multi-fold.  And smashing the
SKB checksum and not indicating TSO capability in loopback was the end
cause.

Loopback should enable TSO for other reasons, not just to fix this
bug.  If loopback says it can do TSO then the TSO packet gets passed
straight through to the receive side, and our entire stack has been
able to handle that for years.
