From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: completely disable interrupts during netpoll
Date: Thu, 26 Jun 2008 02:16:58 -0700 (PDT)
Message-ID: <20080626.021658.126239340.davem@davemloft.net>
References: <20080625141511.GH22981@gospo.rdu.redhat.com>
	<20080625.152751.154176346.davem@davemloft.net>
	<36D9DB17C6DE9E40B059440DB8D95F52057B3FE5@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, jeffrey.t.kirsher@intel.com,
	bruce.w.allan@intel.com, john.ronciak@intel.com,
	netdev@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60198
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752277AbYFZJQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 05:16:58 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52057B3FE5@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Thu, 26 Jun 2008 00:23:59 -0700

> I think the deadlocks occur (only when using netpoll) because the tx
> cleanup (igb_clean_tx_irq) is being called simultaneously from two
> routines, which generally is guaranteed not to happen in regular
> everyday napi mode because of the bh_disable before calling dev->poll.

Thanks for the info, it's clear what the IGB driver bug is.

It's that the TX reclaim is not happening in the ->poll() handler.  If
you did that, all of this would work out correctly and you wouldn't
need to disable the IRQ with disable_irq() to prevent deadlocks.

Instead IGB what does is do TX reclaim inside of it's hw interrupt
handler.

And that is actually making much more work than if you did it properly
from a NAPI ->poll() context.  When igb_unmap_and_free_tx_resource()
runs from the HW interrupt it is going to queue these packet frees up
into the mid-layer's per-cpu TX free queue, and that will schedule yet
another software interrupt to actually run the kfree_skb()'s on all of
these liberated TX frames.

I moved the napi context out of the generic net device, use it! :-)
And then you can call dev_kfree_skb() directly from
igb_unmap_and_free_tx_resource() instead of dev_kfree_skb_any().
