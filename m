From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: unsafe locks seen with netperf on net-2.6.29 tree
Date: Thu, 25 Dec 2008 22:26:58 +1100
Message-ID: <20081225112658.GA7260@gondor.apana.org.au>
References: <9929d2390812250225w19bcd2f7n11357ff26de78c52@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@elte.hu>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52055 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751723AbYLYL1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 06:27:06 -0500
Content-Disposition: inline
In-Reply-To: <9929d2390812250225w19bcd2f7n11357ff26de78c52@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 25, 2008 at 10:25:44AM +0000, Jeff Kirsher wrote:
>
> [ 1439.758437] ======================================================
> [ 1439.758724] [ INFO: soft-safe -> soft-unsafe lock order detected ]
> [ 1439.758868] 2.6.28-rc8-net-next-igb #13
> [ 1439.759007] ------------------------------------------------------
> [ 1439.759150] netperf/22302 [HC0[0]:SC0[1]:HE1:SE0] is trying to acquire:
> [ 1439.759293]  (&fbc->lock){--..}, at: [<ffffffff803691a6>]
> __percpu_counter_add+0x4a/0x6d
> [ 1439.759581]
> [ 1439.759582] and this task is already holding:
> [ 1439.759853]  (slock-AF_INET){-+..}, at: [<ffffffff804fdca6>]
> tcp_close+0x16c/0x2da
> [ 1439.760137] which would create a new lock dependency:
> [ 1439.762122]  (slock-AF_INET){-+..} -> (&fbc->lock){--..}

This is a false positive.  The lock slock is not a normal lock.
It's an ancient creature that's a spinlock in interrupt context
and a semaphore in process context.

In particular, holding slock in process context does not disable
softirqs and you're still allowed to take the spinlock portion of
slock on the same CPU through an interrupt.  What happens is that
the softirq will notice that the slock is already taken by process
context, and defer the work for later.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
