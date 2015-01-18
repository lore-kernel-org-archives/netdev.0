From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next] bridge: ability to disable forwarding on
 a port
Date: Sun, 18 Jan 2015 12:55:33 -0800
Message-ID: <54BC1DC5.1000401@cumulusnetworks.com>
References: <1421479975-62049-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bBeNojtj3Zyd6+zSJFGRjG4vejBObnS1XUFAfJDZJZYow@mail.gmail.com> <54BB7874.90201@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:37816 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbbARUzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 15:55:35 -0500
Received: by mail-pd0-f179.google.com with SMTP id v10so14359060pde.10
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 12:55:35 -0800 (PST)
In-Reply-To: <54BB7874.90201@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/18/15, 1:10 AM, roopa wrote:
> On 1/17/15, 5:05 PM, Scott Feldman wrote:
>> On Fri, Jan 16, 2015 at 11:32 PM, <roopa@cumulusnetworks.com> wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> On a Linux bridge with bridge forwarding offloaded to a switch ASIC,
>>> there is a need to not re-forward the frames that come up to the
>>> kernel in software.
>>>
>>> Typically these are broadcast or multicast packets forwarded by the
>>> hardware to multiple destination ports including sending a copy of
>>> the packet to the kernel (e.g. an arp broadcast).
>>> The bridge driver will try to forward the packet again, resulting in
>>> two copies of the same packet.
>>>
>>> These packets can also come up to the kernel for logging when they hit
>>> a LOG acl in hardware.
>>>
>>> This patch makes forwarding a flag on the port similar to
>>> learn and flood and drops the packet just before forwarding.
>>> (The forwarding disable on a bridge is tested to work on our boxes.
>>> The bridge port flag addition is only compile tested.
>>> This will need to be further refined to cover cases where a 
>>> non-switch port
>>> is bridged to a switch port etc. We will submit more patches to cover
>>> all cases if we agree on this approach).
>> Good topic to bring up, thanks for proposing a patch.  There is indeed
>> duplicate pkts sent out in the case where both the bridge and the
>> offloaded device are flooding these non-unicast pkts, such as ARP
>> requests.  We do have per-port control today over unicast flooding
>> using BR_FLOOD (IFLA_BRPORT_UNICAST_FLOOD).
>>
>> As you point out, this doesn't solve the case for non-offloaded ports
>> bridged with switch ports.  If this port setting is enabled on an
>> offloaded switch port, for example, the non-offloaded port can't get
>> an ARP request resolved, if the MAC is behind the offloaded switch
>> port.  But do we care?  Is there a use-case for this one, mixing
>> offloaded and non-offloaded ports in a bridge?
>
> Not sure. I don't know the use case, but I think I might have heard 
> that there could be a case
>  where a switch port could be bridged with a vm's port running on the 
> switch. (?)

Ignoring the above usecase for a bit. And thinking through this again, 
It appears that this check should
be only on the ingress port, no ?

If the ingress bridge port is an offloaded port, don't flood or forward 
because hardware has already done it.
And this is best done with the offload feature flag on the bridge port.

But, If we bring in the usecase, where a bridge has offloaded and 
non-offloaded ports mixed,
there should be an option to disable this check and to achieve that its 
better for this to be a
flag on the port maintained by the bridge driver like the one proposed 
by this patch (BR_FORWARD).

Thanks,
Roopa
