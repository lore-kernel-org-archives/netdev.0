From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] sfc: Reduce size of efx_rx_buffer by
 unionising skb and page
Date: Tue, 01 Mar 2011 20:47:04 +0000
Message-ID: <1299012424.2529.39.camel@bwh-desktop>
References: <1298942169.3069.179.camel@localhost>
	 <1298942490.3069.180.camel@localhost>
	 <20110301.122459.183051942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:23863 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757465Ab1CAUrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 15:47:12 -0500
In-Reply-To: <20110301.122459.183051942.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-01 at 12:24 -0800, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Tue, 01 Mar 2011 01:21:30 +0000
> 
> > From: Steve Hodgson <shodgson@solarflare.com>
> > 
> > [bwh: Forward-ported to net-next-2.6.]
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> I'm going to apply this, but you can take this further by making
> the buffer an "unsigned long" and encode the pointer plus a one-bit
> binary state there to indicate what it is.

We were primarily concerned with reducing the size of the software ring
for RX queues on 64-bit (DMA address & pointer) systems, where the
structure layout is:

Original:

struct efx_rx_buffer {
       dma_addr_t dma_addr;		// 0
       struct sk_buff *skb;		// 8
       struct page *page;		// 16
       char *data;			// 24
       unsigned int len;		// 32
};					// size = 40

Current:

struct efx_rx_buffer {
       dma_addr_t dma_addr;		// 0
       union {
               struct sk_buff *skb;	// 8
               struct page *page;	// 8
       } u;
       unsigned int len;		// 16
       bool is_page;			// 20
};					// size = 24

Combining the flag with the pointers wouldn't improve on this:

struct efx_rx_buffer {
       dma_addr_t dma_addr;		// 0
       unsigned long magic_pointer;	// 8
       unsigned int len;		// 16
};					// size = 24

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

