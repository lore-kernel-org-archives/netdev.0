From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ucc_geth: Reduce IRQ off in xmit path
Date: Thu, 20 Sep 2012 17:08:52 -0400 (EDT)
Message-ID: <20120920.170852.391382615902951147.davem@davemloft.net>
References: <20120919223416.GA16087@electric-eye.fr.zoreil.com>
	<1348129021-28333-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: Joakim.Tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678Ab2ITVIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 17:08:54 -0400
In-Reply-To: <1348129021-28333-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Thu, 20 Sep 2012 10:17:01 +0200

> Currently ucc_geth_start_xmit wraps IRQ off for the
> whole body just to be safe.
> Reduce the IRQ off period to a minimum.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
> 
>  v2: Move assignment of ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]]
>      inside IRQ off section to prevent racing against
>      ucc_geth_tx(). Spotted by Francois Romieu <romieu@fr.zoreil.com>

I agree with Francois's initial analysis, and disagree with you're
response to him, wrt. the suggest to remove all locking entirely.

Unlike what you claim, there isn't much of a gain at all from merely
make the window of lock holding smaller, especially on the scale
in which you are doing it here.

Whereas removing the lock and the atomic completely, as tg3 does,
will give very significant performance gains.

The locking cost of grabbing the spinlock, and the memory transactions
associated with it, dominate.

Furthermore, even if the gains of your change are non-trivial, you
haven't documented it.  So unless you should some noticable gains from
this, it's just code masterbation as far as I'm concerned and I'm
therefore inclined to not apply patches like this.

TG3's core interrupt locking is not that difficult to understand and
replicate in other drivers, so I dismiss your attempts to avoid that
approach on difficulty grounds as well.
