From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: Header length compution function
Date: Wed, 30 Jul 2014 18:34:10 -0700 (PDT)
Message-ID: <20140730.183410.2278759968683814587.davem@davemloft.net>
References: <1406542451-8857-2-git-send-email-amirv@mellanox.com>
	<20140729.215853.2058634690190963314.davem@davemloft.net>
	<1406703644.3178.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, idos@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaGaBeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 21:34:13 -0400
In-Reply-To: <1406703644.3178.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Jul 2014 09:00:44 +0200

> This adds quite large number of conditional jumps, as
> skb_header_pointer() is heavily used in the stack.

There is only one, in __skb_header_pointer(), testing "!skb" when we
have to take the slow path of copying from a non-linear area.

The NULL check could even be moved into skb_copy_bits() so that it
would not be inlined.  It should be unlikely() (or even WARN_ON()),
and thus terribly easily to be predicted properly all the time.

We could even pass around a "sentinel" global const SKB for these
cases that would simply make skb_copy_bits() return immediately (just
having skb->len == 0 would do the trick) even if we accidently got
there with one.

Then there would be no extra conditional jumps.
