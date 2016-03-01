From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] IPv6: Use a 16 bit length field when
 computing a IPv6 UDP checksum
Date: Tue, 01 Mar 2016 15:09:02 -0500 (EST)
Message-ID: <20160301.150902.257372984527759080.davem@davemloft.net>
References: <20160226025738.16760.41163.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbcCAUJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 15:09:04 -0500
In-Reply-To: <20160226025738.16760.41163.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Thu, 25 Feb 2016 19:10:59 -0800

> This change makes it so that we only use a 16 bit length field instead of a
> 32 bit length field when computing a UDP checksum for IPv6.
> 
> This fixes an issue found with UDP tunnels over IPv6 where the total size
> exceeded 65536 for a frame that was to be segmented.  As a result the
> checksum being computed didn't match the frame data so we ended up being
> off by 1 for the final checksum value since we didn't cancel out the upper
> 16 bits of the length.
> 
> The reasoning behind this is that RFC2460 states that for protocols such as
> UDP that carry their own length field we should use that when computing the
> checksum for the pseudo-header.  As such we should be using a 16 bit value,
> not a 32 bit as is currently occurring when computing the UDP checksum for
> IPv6.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

What a can of worms. :-/

Reading RFC2460 over a few times, indeed using the truncated 16-bit length
is the thing to do for the pseudo-header checksum.

We have this mistake in a few places, for example ip6_compute_pseudo()
unconditionally uses skb->len, yet is used by UDP on receive.

Can you do a little audit and fix as many of these cases as you can find
and wrap them all into this patch?

Thanks!
