From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Use dev_kfree_skb_any() in bnx2_tx_int()
Date: Sat, 02 Nov 2013 01:06:42 -0400 (EDT)
Message-ID: <20131102.010642.1846904926665537525.davem@davemloft.net>
References: <CAM_iQpXPrEj619=PRaKN4PxgOoEB96U0mLFS65AzXOezSWvhxQ@mail.gmail.com>
	<20131101.180147.629210014672277622.davem@davemloft.net>
	<1383348890.1737.40.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, mchan@broadcom.com,
	tdmackey@booleanhaiku.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383348890.1737.40.camel@bwh-desktop.uk.level5networks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 1 Nov 2013 23:34:50 +0000

> As you've said, the ndo_start_xmit and NAPI poll operations are intended
> to be called in softirq context, so everything that interlocks with them
> will use spin_lock_bh().  Calling them from hardirq context obviously
> opens the possibility of a deadlock.  How do you expect anyone to solve
> that?

That's not what I said.

I did not say that it must be invoked in softirq context.

I said that it MUST LOOK like it is being invoked in softirq
context as far as the ->poll() code paths can tell.

But yes, that's hard.

The thing is, ->poll() is atomic.  You never will have poll calls
recurse into eachother.  This is why we strongly encourage all driver
authors to make their ->poll() implementations lockless.

And, wouldn't you know it, tg3 is a driver that does this
properly.

Therefore, there are no netpoll no locking problems, because the poll
implementation takes no locks and therefore doesn't care.

That's why tg3 doesn't have any of these netpoll issues.
