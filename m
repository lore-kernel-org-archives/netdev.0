From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: Header length compution function
Date: Wed, 30 Jul 2014 09:00:44 +0200
Message-ID: <1406703644.3178.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406542451-8857-1-git-send-email-amirv@mellanox.com>
	 <1406542451-8857-2-git-send-email-amirv@mellanox.com>
	 <20140729.215853.2058634690190963314.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, idos@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:48633 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbaG3HAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 03:00:49 -0400
Received: by mail-wg0-f44.google.com with SMTP id m15so701981wgh.3
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 00:00:47 -0700 (PDT)
In-Reply-To: <20140729.215853.2058634690190963314.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-29 at 21:58 -0700, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Mon, 28 Jul 2014 13:14:10 +0300
> 
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > 
> > This commit is based on Eric Dumazet suggestion.
> > Use flow dissector to calculate header length.
> > Tested the following with a mlx4, and it indeed speeds up GRE traffic,
> > as GRO packets can now contain 17 MSS instead of 8.
> > (Pulling payload means GRO had to use 2 'frags' per MSS)
> > 
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Signed-off-by: Amir Vadai <amirv@mellanox.com>
> 
> So I decided to see how bad it would be if we tried to avoid making
> that funky on-stack SKB and came up with the patch below.
> 
> With this you can make __skb_get_poff() take "data" and "hlen" too,
> pass it onward to __skb_flow_dissect(), and then your new function is
> just:
> 
> u32 eth_frame_headlen(void *data, unsigned int len)
> {
> 	if (unlikely(len < ETH_HLEN))
> 		return len;
> 	return __skb_get_poff(NULL, data, hlen) + ETH_HLEN;
> }

Yep, this was basically what I got when I tried it as well, and I was
not convinced it was the way to go.

This adds quite large number of conditional jumps, as
skb_header_pointer() is heavily used in the stack.

If we want to restrict flow dissection to a 'fake linear skb',
needed fields from this fake skb are well known :

skb->data,		(data)
skb->len,	        (len)
skb->data_len		(0)   // this is a fake linear skb ...

Then skb_flow_dissect() needs 2 additional parts, because it assumed
ethernet header was already pulled (from eth_type_trans())

skb->network_header     (ETH_HLEN)
skb->protocol		(eth->h_proto)

This solution, admittedly a bit hacky, do not add more complexity into
fast path.

The last 2 fields (network_header and protocol) could even be passed as
__skb_flow_dissect() parameters.

By nature, skb_flow_dissect() should not access any information outside
of the frame itself.

Apparently, Alexander never trusted this core function and decided to
implement its own limited flow dissector in igb/ixgbe...

skb layout regarding how linear data is attached wont change anytime
soon.

We certainly can add a fat comment, but then any code using skb->data &
skb->len should get a fat comment as well.
