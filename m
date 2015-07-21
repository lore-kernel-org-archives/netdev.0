From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/5] switchdev: avoid duplicate packet
 forwarding
Date: Mon, 20 Jul 2015 18:33:32 -0700 (PDT)
Message-ID: <20150720.183332.1920862744765151513.davem@davemloft.net>
References: <1437269092-17669-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, simon.horman@netronome.com,
	nicolas.dichtel@6wind.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026AbbGUBdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 21:33:33 -0400
In-Reply-To: <1437269092-17669-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Sat, 18 Jul 2015 18:24:47 -0700

> With switchdev support for offloading L2/L3 forwarding data path to a
> switch device, we have a general problem where both the device and the
> kernel may forward the packet, resulting in duplicate packets on the wire.
> Anytime a packet is forwarded by the device and a copy is sent to the CPU,
> there is potential for duplicate forwarding, as the kernel may also do a
> forwarding lookup and send the packet on the wire.
> 
> The specific problem this patch series is interested in solving is avoiding
> duplicate packets on bridged ports.  There was a previous RFC from Roopa
> (http://marc.info/?l=linux-netdev&m=142687073314252&w=2) to address this
> problem, but didn't solve the problem of mixed ports in the bridge from
> different devices; there was no way to exclude some ports from forwarding
> and include others.  This RFC solves that problem by tagging the ingressing
> packet with a unique mark, and then comparing the packet mark with the
> egress port mark, and skip forwarding when there is a match.  For the mixed
> ports bridge case, only those ports with matching marks are skipped.
> 
> The switchdev port driver must do two things:
> 
> 1) Generate a fwd_mark for each switch port, using some unique key of the
>    switch device (and optionally port).  This is done when the port netdev
>    is registered or if the port's group membership changes (joins/leaves
>    a bridge, for example).
> 
> 2) On packet ingress from port, mark the skb with the ingress port's
>    fwd_mark.  If the device supports it, it's useful to only mark skbs
>    which were already forwarded by the device.  If the device does not
>    support such indication, all skbs can be marked, even if they're
>    local dst.
> 
> Two new 32-bit fields are added to struct sk_buff and struct netdevice to
> hold the fwd_mark.  I've wrapped these with CONFIG_NET_SWITCHDEV for now. I
> tried using skb->mark for this purpose, but ebtables can overwrite the
> skb->mark before the bridge gets it, so that will not work.
> 
> In general, this fwd_mark can be used for any case where a packet is
> forwarded by the device and a copy is sent to the CPU, to avoid the kernel
> re-forwarding the packet.  sFlow is another use-case that comes to mind,
> but I haven't explored the details.

Series applied, thanks Scott.
