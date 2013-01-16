From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/3] Avoid making inappropriate requests of
 NETIF_F_V[46]_CSUM devices
Date: Wed, 16 Jan 2013 15:54:06 -0500 (EST)
Message-ID: <20130116.155406.351676228334066120.davem@davemloft.net>
References: <1358165431.27054.62.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756661Ab3APUyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 15:54:08 -0500
In-Reply-To: <1358165431.27054.62.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Mon, 14 Jan 2013 12:10:31 +0000

> Devices with the NETIF_F_V[46]_CSUM feature(s) are *only* required to
> handle checksumming of UDP and TCP.
> 
> In netif_skb_features() we attempt to filter out the capabilities which
> are inappropriate for the device that the skb will actually be sent
> from... but there we assume that NETIF_F_V4_CSUM devices can handle
> *all* Legacy IP, and that NETIF_F_V6_CSUM devices can handle *all* IPv6.
> 
> This may have been OK in the days when CHECKSUM_PARTIAL packets would
> *only* be produced by the local stack, and we knew the local stack
> didn't generate them for anything but UDP and TCP. But these days that's
> not true. When a tun device receives a packet from userspace with
> VIRTIO_NET_HDR_F_NEEDS_CSUM, that translates fairly directly into
> setting CHECKSUM_PARTIAL on the resulting skb. Since virtio_net
> advertises NETIF_F_HW_CSUM to its guests, we should expect to be asked
> to checksum *anything*.

My opinion on this is that the injectors of packets are responsible
for ensuring checksum types are set on SKBs in an appropriate way.

So we ensure this in the local protocol stacks that generate packets,
and if foreign alien entities can inject SKBs with these checksum
settings (like the tun device can) the burdon of verification falls
upon whatever layer allows that to happen.

So really, the fix is in the tun device and the virtio layer.
