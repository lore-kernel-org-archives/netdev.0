From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 0/4] switchdev: avoid duplicate packet forwarding
Date: Mon, 15 Jun 2015 07:23:45 -0700
Message-ID: <557EDFF1.3040109@cumulusnetworks.com>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	simon.horman@netronome.com, ronen.arad@intel.com,
	john.r.fastabend@intel.com, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, davidch@broadcom.com,
	stephen@networkplumber.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35298 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbbFOOXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 10:23:47 -0400
Received: by pdbnf5 with SMTP id nf5so74264396pdb.2
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 07:23:47 -0700 (PDT)
In-Reply-To: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/13/15, 11:04 AM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> (RFC because we're at rc7+ now)
>
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
>     switch device (and optionally port).  This is a one-time operation done
>     when port's netdev is setup.
>
> 2) On packet ingress from port, mark the skb with the ingress port's
>     fwd_mark.  If the device supports it, it's useful to only mark skbs
>     which were already forwarded by the device.  If the device does not
>     support such indication, all skbs can be marked, even if they're
>     local dst.
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
>
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
