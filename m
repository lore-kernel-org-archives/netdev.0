From: David Miller <davem@davemloft.net>
Subject: Re: kernel WARNING/BUG with IOMMU + skb_dma_map/unmap + pktgen
Date: Tue, 03 Nov 2009 18:32:31 -0800 (PST)
Message-ID: <20091103.183231.179783036.davem@davemloft.net>
References: <4AF0DC81.10305@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, emil.s.tantilov@intel.com,
	dwmw2@infradead.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49518
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750751AbZKDCcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 21:32:06 -0500
In-Reply-To: <4AF0DC81.10305@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 03 Nov 2009 17:44:33 -0800

> It looks like skb_dma_map/unmap plus trying to transmit multiple
> copies of the same skb via pktgen doesn't work when a hardware IOMMU
> is enabled.

This is just the tip of the iceburg as to why pktgen's scheme
to send the same SKB over and over again doesn't really work.

If it's referenced by a transmit, you really can't reuse it
again in the transmit path, even TCP has code that copies
when a SKB has a device reference on the transmit path.

I think we've just been lucky until now about this, as pktgen
doesn't usually attach other forms of shared state such as
netfilter conntrack info, and it doesn't care about the header
being mangled by the driver (since it emits pure UDP frames
this isn't likely to happen anyways).

But not with the SKB DMA map/unmap this becomes a real visible bug and
must be fixed.
