From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next 0/4] switchdev: avoid duplicate packet forwarding
Date: Tue, 16 Jun 2015 09:47:47 -0700
Message-ID: <CAE4R7bDEw0JVkwagps1eBVGuZuK58eEfTX+0GU-2U1UKGCYyKQ@mail.gmail.com>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
 <20150615.162551.805611215439524288.davem@davemloft.net> <20150616060427.GA2135@nanopsycho.orion>
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
Received: from mail-oi0-f43.google.com ([209.85.218.43]:36697 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756584AbbFPQsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 12:48:08 -0400
Received: by oial131 with SMTP id l131so15590665oia.3
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 09:48:08 -0700 (PDT)
In-Reply-To: <20150616060427.GA2135@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2015 at 11:04 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Jun 16, 2015 at 01:25:51AM CEST, davem@davemloft.net wrote:
>>From: sfeldma@gmail.com
>>Date: Sat, 13 Jun 2015 11:04:26 -0700
>>
>>> The switchdev port driver must do two things:
>>>
>>> 1) Generate a fwd_mark for each switch port, using some unique key of the
>>>    switch device (and optionally port).  This is a one-time operation done
>>>    when port's netdev is setup.
>>>
>>> 2) On packet ingress from port, mark the skb with the ingress port's
>>>    fwd_mark.  If the device supports it, it's useful to only mark skbs
>>>    which were already forwarded by the device.  If the device does not
>>>    support such indication, all skbs can be marked, even if they're
>>>    local dst.
>>>
>>> Two new 32-bit fields are added to struct sk_buff and struct netdevice to
>>> hold the fwd_mark.  I've wrapped these with CONFIG_NET_SWITCHDEV for now. I
>>> tried using skb->mark for this purpose, but ebtables can overwrite the
>>> skb->mark before the bridge gets it, so that will not work.
>>>
>>> In general, this fwd_mark can be used for any case where a packet is
>>> forwarded by the device and a copy is sent to the CPU, to avoid the kernel
>>> re-forwarding the packet.  sFlow is another use-case that comes to mind,
>>> but I haven't explored the details.
>>
>>Generally I'm against adding new fields fo sk_buff but I'm trying to be
>>open minded. :-)
>>
>>About the per-device fwd_mark, if the key attribute is uniqueness,
>>let's just do it right and use something like lib/idr.c to generate
>>truly unique indices at probe time for all devices using this
>>facility.  I like that better than having them be unique by a happy
>>accident.
>
> We already have per-device uniqueue key. dev->ifindex.
> That should be good for fwd_mark purposes I believe.

It would be great if we could use dev->index, but fwd_mark is really
to mark device ports that belong to a group.  In the case of a bridge,
the device ports in the bridge should all have the same mark.  And
another device's ports in the same bridge would have a different mark
(so we can't use the bridge's dev->ifindex).  On ingress, the skb is
marked with the ingress port's mark.  If the skb is to be forwarded
out an egress port, the skb mark is compared with egress port's mark.
If marks compare, then the device has already forwarded the pkt so the
kernel can consume_skb to avoid duplicate pkts on the wire.

So what we need is a unique mark for device ports within a fwding
group, such as a bridge.

I'm investigating Dave's suggestion to use IDR.  I think this will work...
