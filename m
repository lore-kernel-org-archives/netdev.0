From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/2] xfrm: Remove ancient sleeping code
Date: Fri, 11 Oct 2013 15:01:24 -0400 (EDT)
Message-ID: <20131011.150124.527914076255487526.davem@davemloft.net>
References: <20131010063301.GO7660@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509Ab3JKTB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 15:01:26 -0400
In-Reply-To: <20131010063301.GO7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 10 Oct 2013 08:33:01 +0200

> Does anyone still rely on the ancient sleeping when the SA is in
> acquire state? It is disabled by default since more that five years,
> but can cause indefinite task hangs if enabled and the needed state
> does not get resolved.
> 
> We now queue packets to the policy if the states are not yet resolved
> if we are in a code path that can not sleep. We could do this even in
> the case we can sleep. As a bonus, we can remove the FLOWI_FLAG_CAN_SLEEP
> flag because the only thing this flag does, is to notify xfrm that we are
> in a codepath that can sleep.
> 
> The two RFC patches to remove the sleeping code are in reply to this
> mail. I'd add this to the ipsec-next tree if there are no objections.

The sleep path has the slight benefit that the TCP retransmit timers
for the initial SYN packet will not be started until the IPSEC rule
is resolved and the SYN actually goes out.

With the packet queue, if the IPSEC resolution is slow then we'll have
spurious SYN retransmits.

It makes no sense for TCP to keep queueing up SYNs if they will just
all get stuck in the packet queue.  The first one is enough.

On the other hand we do want TCP to timeout, we do want the user to
be able to "Ctrl-C" (ie. send a SIGINT) during a connect, etc.
