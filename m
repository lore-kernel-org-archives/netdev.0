From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next-2.6] macvtap: Add GSO/csum offload support
Date: Thu, 18 Feb 2010 21:47:57 +0100
Message-ID: <201002182147.57516.arnd@arndb.de>
References: <1266013667.6105.18.camel@w-sridhar.beaverton.ibm.com> <201002181710.45121.arnd@arndb.de> <1266523423.15681.24.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:63309 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850Ab0BRUsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 15:48:09 -0500
In-Reply-To: <1266523423.15681.24.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 18 February 2010, Sridhar Samudrala wrote:
> > 
> > macvtap is different from tun/tap here, because the data direction is the
> > opposite: reading from a macvtap chardev corresponds to receive, while
> > writing to it is a transmit in the network stack. In the tap driver, we
> > just set the GSO flags of the netdev and dev_queue_xmit will do the right
> > thing when forwarding data to the tap, but for macvtap, incoming frames
> > never go through dev_queue_xmit (they go through netif_rx), so if the
> > external device passes us GSO frames, we just pass them on unmodified
> > to the guest, even if that guest does not understand GSO.
> 
> If a guest is connected to a macvtap device attached to an underlying physical
> device with GRO enabled, it is possible to receive large SKBs and we don't handle
> them correctly. The current workaround is to disable GRO on the physical device.

Ok. 

> > In particular, when we have two guests using macvtap in bridge mode,
> > we don't even go through the network stack and just pass down the
> > SKB we got from the other side if the destination MAC address matches.
> > That means that a sender using virtio-net with GSO will send garbage
> > to another guest using a hardware emulated NIC that cannot receive
> > GSO (GRO?) frames.
> 
> Yes. I think we need to do something similar to dev_gso_segment() in
> macvtap_forward() if skb_is_gso() and IFF_VNET_HDR is not set in
> q->flags.
 
I think it needs to be more fine-grained than that, and take into account
the specific offload capabilities of the receiving guest that were
negotiated in TUNSETOFFLOAD, but other than that, this looks fine.

Regarding TUNSETOFFLOAD, the part I don't get is what the negotiation
really means for TX and RX respectively. Is it safe to assume that what
gets set is the common subset of features between guest and host for
RX *and* TX, or is it just one of them?

> > I hope you have an idea how to do this right or can convince me that
> > everything is ok, otherwise we'd have to defer this patch.
> 
> I would prefer getting this patch in as it helps peformance when both
> the guest and the physical device support offloads and also we have 
> workaround for other situations. In the meantime, I will start looking
> into addressing this specific case in macvtap_forward().

Ok, fair enough.

For the forwarding between ports, simply refusing TUNSETOFFLOAD for
any bridge mode ports should be fine and still let us use offloading
for vepa mode.

	Arnd
