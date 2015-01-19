From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next] bridge: ability to disable forwarding on a port
Date: Sun, 18 Jan 2015 23:37:58 -0800
Message-ID: <CAE4R7bC=j-mT65TzFOhJL-Hd0GeHg3-k+=+VFHaj-m+h5PjMuQ@mail.gmail.com>
References: <1421479975-62049-1-git-send-email-roopa@cumulusnetworks.com>
	<CAE4R7bBeNojtj3Zyd6+zSJFGRjG4vejBObnS1XUFAfJDZJZYow@mail.gmail.com>
	<54BB7874.90201@cumulusnetworks.com>
	<54BC1DC5.1000401@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"Arad, Ronen" <ronen.arad@intel.com>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	Wilson Kok <wkok@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38997 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbbASHiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 02:38:00 -0500
Received: by mail-wi0-f181.google.com with SMTP id fb4so1878950wid.2
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 23:37:59 -0800 (PST)
In-Reply-To: <54BC1DC5.1000401@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2015 at 12:55 PM, roopa <roopa@cumulusnetworks.com> wrote:
> On 1/18/15, 1:10 AM, roopa wrote:
>>
>> On 1/17/15, 5:05 PM, Scott Feldman wrote:
>>>
>>> On Fri, Jan 16, 2015 at 11:32 PM, <roopa@cumulusnetworks.com> wrote:
>>>>
>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>
>>>> On a Linux bridge with bridge forwarding offloaded to a switch ASIC,
>>>> there is a need to not re-forward the frames that come up to the
>>>> kernel in software.
>>>>
>>>> Typically these are broadcast or multicast packets forwarded by the
>>>> hardware to multiple destination ports including sending a copy of
>>>> the packet to the kernel (e.g. an arp broadcast).
>>>> The bridge driver will try to forward the packet again, resulting in
>>>> two copies of the same packet.
>>>>
>>>> These packets can also come up to the kernel for logging when they hit
>>>> a LOG acl in hardware.
>>>>
>>>> This patch makes forwarding a flag on the port similar to
>>>> learn and flood and drops the packet just before forwarding.
>>>> (The forwarding disable on a bridge is tested to work on our boxes.
>>>> The bridge port flag addition is only compile tested.
>>>> This will need to be further refined to cover cases where a non-switch
>>>> port
>>>> is bridged to a switch port etc. We will submit more patches to cover
>>>> all cases if we agree on this approach).
>>>
>>> Good topic to bring up, thanks for proposing a patch.  There is indeed
>>> duplicate pkts sent out in the case where both the bridge and the
>>> offloaded device are flooding these non-unicast pkts, such as ARP
>>> requests.  We do have per-port control today over unicast flooding
>>> using BR_FLOOD (IFLA_BRPORT_UNICAST_FLOOD).
>>>
>>> As you point out, this doesn't solve the case for non-offloaded ports
>>> bridged with switch ports.  If this port setting is enabled on an
>>> offloaded switch port, for example, the non-offloaded port can't get
>>> an ARP request resolved, if the MAC is behind the offloaded switch
>>> port.  But do we care?  Is there a use-case for this one, mixing
>>> offloaded and non-offloaded ports in a bridge?
>>
>>
>> Not sure. I don't know the use case, but I think I might have heard that
>> there could be a case
>>  where a switch port could be bridged with a vm's port running on the
>> switch. (?)
>
>
> Ignoring the above usecase for a bit. And thinking through this again, It
> appears that this check should
> be only on the ingress port, no ?
>
> If the ingress bridge port is an offloaded port, don't flood or forward
> because hardware has already done it.
> And this is best done with the offload feature flag on the bridge port.

That's assuming hardware did the flood.  Maybe your other option to
mark the skb if already flooded by hw is best.  That's enough info for
the bridge driver to make a decision to flood or not to the other
ports, and it's an implementation decision for the driver/device to do
the flood offload, if desired, and mark the skb if it did.

Btw, you're still saying flood or forward, but in my mind we're
talking about flood only: flood of unknown unicast or flood of
bcast/mcast pkts.  Forwarding would be for known-unicast pkts, which
should even involve the bridge driver since that forwarding is
offloaded to the device.

>
> But, If we bring in the usecase, where a bridge has offloaded and
> non-offloaded ports mixed,
> there should be an option to disable this check and to achieve that its
> better for this to be a
> flag on the port maintained by the bridge driver like the one proposed by
> this patch (BR_FORWARD).
>
> Thanks,
> Roopa
>
