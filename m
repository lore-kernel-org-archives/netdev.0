From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/2] napi_synchronize: waiting for NAPI
Date: Thu, 18 Oct 2007 11:33:01 +1000
Message-ID: <1192671181.12879.13.camel@pasglop>
References: <20071017202640.171902388@linux-foundation.org>
	 <20071017202653.266566036@linux-foundation.org>
	 <1192667289.12879.0.camel@pasglop>
	 <20071017182628.6590fcdd@freepuppy.rosehill>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59151 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758595AbXJRBdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 21:33:13 -0400
In-Reply-To: <20071017182628.6590fcdd@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2007-10-17 at 18:26 -0700, Stephen Hemminger wrote:
> 
> Could you give a concrete example as to why it needs a smp barrier?
> The test_bit is going to get a consistent result. Are you worried about
> operations ordering before the test_bit()? In that case, one of those
> smp_mb__before_xxx functions is probably what is needed.

test_bit is just a read, without any ordering constraint. It can thus be
totally mixed with anything before.

we want to synchronize. Basically, make sure that whatever we did before
the call is visible to whatever we are synchronizing with (NAPI poll in
our case). That is, in our case, that a previous/concurrent NAPI poll
(that hasn't seen the effect of what we did before) is complete or any
new one will have seen that effect.

thus we need a barrier. At least a read barrier semantic to avoid the
test_bit to dance around and be speculated but I think a full barrier
also making sure that any previous store is visible before we preform
the read is also necessary in pretty much any usage scenario of this
function. I believe this is also a bug in synchronize_irq and possibly
even in napi_disable(). I sent a patch for synchronize_irq() a minute
ago.

Besides, it's not like this was a hot path :-)

Cheers,
Ben.


