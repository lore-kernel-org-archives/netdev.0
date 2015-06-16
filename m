From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next 0/4] switchdev: avoid duplicate packet forwarding
Date: Tue, 16 Jun 2015 16:53:56 -0700
Message-ID: <CAE4R7bA2ruG5MbExqC=TUiZdP9xjTvhSZxNV1kv+C4MfcG_1gA@mail.gmail.com>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
 <20150615.162551.805611215439524288.davem@davemloft.net> <20150616060427.GA2135@nanopsycho.orion>
 <CAE4R7bDEw0JVkwagps1eBVGuZuK58eEfTX+0GU-2U1UKGCYyKQ@mail.gmail.com> <20150616211147.GB2135@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	davidch <davidch@broadcom.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:33691 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbbFPXyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 19:54:17 -0400
Received: by obcej4 with SMTP id ej4so22563711obc.0
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 16:54:16 -0700 (PDT)
In-Reply-To: <20150616211147.GB2135@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 16, 2015 at 2:11 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Jun 16, 2015 at 06:47:47PM CEST, sfeldma@gmail.com wrote:
>>On Mon, Jun 15, 2015 at 11:04 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Tue, Jun 16, 2015 at 01:25:51AM CEST, davem@davemloft.net wrote:
>>>>From: sfeldma@gmail.com
>>>>Date: Sat, 13 Jun 2015 11:04:26 -0700
>>>>
>>>>> The switchdev port driver must do two things:
>>>>>
>>>>> 1) Generate a fwd_mark for each switch port, using some unique key of the
>>>>>    switch device (and optionally port).  This is a one-time operation done
>>>>>    when port's netdev is setup.
>>>>>
>>>>> 2) On packet ingress from port, mark the skb with the ingress port's
>>>>>    fwd_mark.  If the device supports it, it's useful to only mark skbs
>>>>>    which were already forwarded by the device.  If the device does not
>>>>>    support such indication, all skbs can be marked, even if they're
>>>>>    local dst.
>>>>>
>>>>> Two new 32-bit fields are added to struct sk_buff and struct netdevice to
>>>>> hold the fwd_mark.  I've wrapped these with CONFIG_NET_SWITCHDEV for now. I
>>>>> tried using skb->mark for this purpose, but ebtables can overwrite the
>>>>> skb->mark before the bridge gets it, so that will not work.
>>>>>
>>>>> In general, this fwd_mark can be used for any case where a packet is
>>>>> forwarded by the device and a copy is sent to the CPU, to avoid the kernel
>>>>> re-forwarding the packet.  sFlow is another use-case that comes to mind,
>>>>> but I haven't explored the details.
>>>>
>>>>Generally I'm against adding new fields fo sk_buff but I'm trying to be
>>>>open minded. :-)
>>>>
>>>>About the per-device fwd_mark, if the key attribute is uniqueness,
>>>>let's just do it right and use something like lib/idr.c to generate
>>>>truly unique indices at probe time for all devices using this
>>>>facility.  I like that better than having them be unique by a happy
>>>>accident.
>>>
>>> We already have per-device uniqueue key. dev->ifindex.
>>> That should be good for fwd_mark purposes I believe.
>>
>>It would be great if we could use dev->index, but fwd_mark is really
>>to mark device ports that belong to a group.  In the case of a bridge,
>>the device ports in the bridge should all have the same mark.  And
>>another device's ports in the same bridge would have a different mark
>>(so we can't use the bridge's dev->ifindex).  On ingress, the skb is
>>marked with the ingress port's mark.  If the skb is to be forwarded
>>out an egress port, the skb mark is compared with egress port's mark.
>>If marks compare, then the device has already forwarded the pkt so the
>>kernel can consume_skb to avoid duplicate pkts on the wire.
>>
>>So what we need is a unique mark for device ports within a fwding
>>group, such as a bridge.
>
> Yep, have a group of netdevs, pick one of them and use it's ifindex for
> the whole group.

That will not work because ports from two switches in the same bridge
need different marks...that's how the bridge knows which ports to fwd
and which ones to skip.

Example:

br0
   sw1p1 (mark=3)
   sw1p2 (mark=3)
   sw2p2 (mark=7)
   sw2p2 (mark=7)

Two switches, sw1 and sw2, in bridge br0.  Let's say sw1 receives an
unknown unicast pkt. It'll flood the pkt to its other switch ports
(sw1p2, in this case) and send a copy to the CPU (the bridge), with
skb->mark=3.  The bridge will flood pkt to sw1p2, sw2p1, and sw2p2,
but our little check in dev.c will drop the pkt to sw1p2 just before
egress onto wire.  Pkt goes out on sw2p1 and sw2p2.  This is why we
can't use just the br0 ifindex to generate the mark.  We need
something unique about the switch port and the bridge ifindex to give
us a mark for a port.

I'm going to send v2 which uses switch port ppid + some group ifindex
to generate port mark.  Group ifindex could be bond ifindex or bridge
ifindex or even zero if ports are L3 router ports and we want to prune
any L3 forwarding by the kernel.  There is some flexibility here,
depending on what we're trying to do.  We have the switch port ppid,
so we might as well use it.

-scott
