From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 13617] New: GRO:__napi_complete from
 net_rx_action crash
Date: Fri, 26 Jun 2009 19:28:04 -0700 (PDT)
Message-ID: <20090626.192804.199785674.davem@davemloft.net>
References: <4A4501D7.8050301@qlogic.com>
	<20090626.102458.96012087.davem@davemloft.net>
	<20090627014900.GA19639@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhananjay.phadke@qlogic.com, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org, amit.salecha@qlogic.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42021
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755977AbZF0C2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 22:28:00 -0400
In-Reply-To: <20090627014900.GA19639@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 27 Jun 2009 09:49:00 +0800

> On Fri, Jun 26, 2009 at 10:24:58AM -0700, David Miller wrote:
>>
>> >>> In net_rx_action, there is check if napi_disable_pending then call
>> >>> __napi_complete.
>> >>> In __napi_complete, there is BUG_ON(n->gro_list);
>> >>> Which has hit in below bug dump.
>> >>> Why __napi_complete is called from net_rx_action instead of napi_complete.
>> >>> napi_complete flushes the gro list.
> 
> Indeed, it was an oversight.  Thanks for catching it!
> 
> gro: Flush GRO packets in napi_disable_pending path
> 
> When NAPI is disabled while we're in net_rx_action, we end up
> calling __napi_complete without flushing GRO packets.  This is
> a bug as it would cause the GRO packets to linger, of course it
> also literally BUGs to catch error like this :)
> 
> This patch changes it to napi_complete, with the obligatory IRQ
> reenabling.  This should be safe because we've only just disabled
> IRQs and it does not materially affect the test conditions in
> between.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.

I remembered that change where we had to disable GRO in the
legacy RX path and all the IRQ disabling problems we ran into
there.  So I went and had a look at that to make sure we won't
have similar issues here, luckily it seems not.

Thanks!
