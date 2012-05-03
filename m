From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tcp: cleanup tcp_try_coalesce
Date: Thu, 03 May 2012 01:50:18 -0400 (EDT)
Message-ID: <20120503.015018.1396745597972676005.davem@davemloft.net>
References: <4FA21087.1080801@gmail.com>
	<1336022373.12425.24.camel@edumazet-glaptop>
	<4FA21A90.3010008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39993 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374Ab2ECFvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 01:51:21 -0400
In-Reply-To: <4FA21A90.3010008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 02 May 2012 22:41:36 -0700

> I think the part that has me confused is how being more precise about
> removing from truesize gets in the way of detecting abuses of
> truesize.  It seems like it should be more as good as or better then
> the original approach of just using skb->len.

You can only trim from truesize if you can be absolutely certain that
you have removed any reference in the fraglist, or the page'd head, to
the entire "block" of data.

If the skb still refers to even just one byte in a particular block,
we must still charge the entire block in the truesize.

For example, NIU has three pools of power-of-2 blocks of data it
maintainers and the device pulls from to build incoming packets.

So if the chip used one of the 2048 byte buffers, we charge the entire
2048 bytes even of the packet is much smaller.

Conversely this means we cannot trim the 2048 part of the truesize of
that SKB unless we had some mechanism to know for certain 1) what the
block size of the underlying data is and 2) that we've removed all
references to that.

Currently this is not really possible, so we therefore defer truesize
adjustments.

Behaving otherwise is dangerous, because then we'd potentially end up
with a lot of memory used, but not actually accounted for by anyone.
