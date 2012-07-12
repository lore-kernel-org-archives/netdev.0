From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: Update alloc frag to reduce get/put page
 usage and recycle pages
Date: Thu, 12 Jul 2012 07:06:41 +0200
Message-ID: <1342069601.3265.8218.camel@edumazet-glaptop>
References: <20120712001804.26542.2889.stgit@gitlad.jf.intel.com>
	 <20120712001810.26542.61967.stgit@gitlad.jf.intel.com>
	 <1342052967.3265.8210.camel@edumazet-glaptop>  <4FFE303F.8070902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, Eric Dumazet <edumazet@google.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:43721 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710Ab2GLFGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 01:06:47 -0400
Received: by wgbdr13 with SMTP id dr13so1699101wgb.1
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 22:06:46 -0700 (PDT)
In-Reply-To: <4FFE303F.8070902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-11 at 19:02 -0700, Alexander Duyck wrote:

> The gain will be minimal if any with the 1500 byte allocations, however 
> there shouldn't be a performance degradation.
> 
> I was thinking more of the ixgbe case where we are working with only 256 
> byte allocations and can recycle pages in the case of GRO or TCP.  For 
> ixgbe the advantages are significant since we drop a number of the 
> get_page calls and get the advantage of the page recycling.  So for 
> example with GRO enabled we should only have to allocate 1 page for 
> headers every 16 buffers, and the 6 slots we use in that page have a 
> good likelihood of being warm in the cache since we just keep looping on 
> the same page.
> 

Its not possible to get 16 buffers per 4096 bytes page.

sizeof(struct skb_shared_info)=0x140 320

Add 192 bytes (NET_SKB_PAD + 128)

Thats a minimum of 512 bytes (but ixgbe uses more) per skb.

In practice for ixgbe, its :

#define IXGBE_RXBUFFER_512   512    /* Used for packet split */
#define IXGBE_RX_HDR_SIZE IXGBE_RXBUFFER_512 

skb = netdev_alloc_skb_ip_align(rx_ring->netdev, IXGBE_RX_HDR_SIZE)

So 4 buffers per PAGE

Maybe you plan to use IXGBE_RXBUFFER_256 or IXGBE_RXBUFFER_128 ?
