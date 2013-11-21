From: David Miller <davem@davemloft.net>
Subject: Re: Get rxhash fixes and RFS support in tun
Date: Wed, 20 Nov 2013 19:02:52 -0500 (EST)
Message-ID: <20131120.190252.940036939480739452.davem@davemloft.net>
References: <alpine.DEB.2.02.1311201220510.19725@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, hkchu@google.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754975Ab3KUACz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 19:02:55 -0500
In-Reply-To: <alpine.DEB.2.02.1311201220510.19725@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 20 Nov 2013 12:25:48 -0800 (PST)

> This patch series fixes some subtle bugs in tun use of skb->rxhash, all
> rxhash hash not be cleared appropraitely, and adds support for tun flows
> to work with RFS.
> 
> Testing, in particular with tun, hasn't been completed yet.

I think this needs to be reworked slightly.

We really only have two boolean states:

1) Is the rxhash value in this SKB valid?

2) Is it a full L4 tuple hash?

You are adding a "this is a SW computed hash" boolean state but I do
not think you should distinguish sw vs. hw especially.  If the
hardware computed the rxhash on a tunneled packet in the
pre-decapsulated state, we very much want to recompute it, in
software, upon tunnel decapsulation in ip_tunnel_core.c

This is actually implemented in this patch set, by testing two states.
Both the "l4_rxhash" and "sw_rxhash".

Why don't we just do everything in a straightforward manner, where
nothing directly sets rxhash values.  Only helper routines do.

1) skb_set_rxhash(struct sk_buff *skb, __u32 rxhash, bool l4_rxhash)

   Update all drivers to call this.

2) Add "rxhash_valid" boolean to sk_buff, set it in skb_set_rxhash,
   test it in skb_get_rxhash(), propagate it in SKB copies.

3) Your skb_clear_rxhash() now just clears rxhash_valid.

Now, if the issue is that HW computed hashes sometimes do the tunnel
demux and look into the inner L4 headers to compute the hash, you'll
need a boolean to indicate _that_ rather than unconditionally treating
hardware that way.  Because not all of them will do this, and for
those that do not you do want to compute the hash in SW after tunnel
decapsulation.

Thoughts?
