From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] bonding: Offloading bonds to hardware
Date: Mon, 16 Nov 2015 08:24:25 -0800
Message-ID: <564A0339.5050708@gmail.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com> <20151114093920.GA2188@nanopsycho.orion> <56481D60.10209@gmail.com> <20151115090109.GA2193@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Premkumar Jonnala <pjonnala@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, andrew@lunn.ch,
	f.fainelli@gmail.com, idosch@mellanox.com,
	nikolay@cumulusnetworks.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33926 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611AbbKPQYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 11:24:42 -0500
Received: by padhx2 with SMTP id hx2so179652410pad.1
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 08:24:42 -0800 (PST)
In-Reply-To: <20151115090109.GA2193@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-11-15 01:01 AM, Jiri Pirko wrote:
> Sun, Nov 15, 2015 at 06:51:28AM CET, john.fastabend@gmail.com wrote:
>> On 15-11-14 01:39 AM, Jiri Pirko wrote:
>>> Thu, Nov 12, 2015 at 05:02:18PM CET, pjonnala@broadcom.com wrote:
>>>> Packet forwarding to/from bond interfaces is done in software.
>>>>
>>>> This patch enables certain platforms to bridge traffic to/from
>>>> bond interfaces in hardware.  Notifications are sent out when 
>>>> the "active" slave set for a bond interface is updated in 
>>>> software.  Platforms use the notifications to program the 
>>>> hardware accordingly.  The changes have been verified to work 
>>>> with configured and 802.3ad bond interfaces.
>>>>
>>>> Signed-off-by: Premkumar Jonnala <pjonnala@broadcom.com>
>>>
>>> This patch is wrong, in many different acpects. Leaving the submission
>>> style, and no in-tree consumer aside, adding ndos for this thing is
>>> unacceptable. It should be handled as a part of switchdev attrs.
>>
>> Why is it unacceptable? I think its at least worth debating. If I
>> have a nic that can do bonding but none of the other switchdev
>> things then implementing another ndo is certainly more straight
>> forward. As it is heading many of the 10+Gbps nics may need to
>> implement just enough of the switchdev infrastructure to get things
>> like bonding up and working. Not necessarily a bad thing if we make
>> the switchdev infrastructure light but does sort of make the name
>> confusing if my nic is not doing any switching ;)
> 
> Can you please describe what exaclty such a NIC functionality would look
> like? If there's not switching/forwarding, then the packets would go
> trought slow-path (kernel bonding/team driver). So why would we need to
> tell anything to driver/hw?
> 

Mostly I was thinking about direct assigned functions into a container
or VM. In this case the hardware may be able to create a virtual
function or physical function that does bonding in hardware and exposes
this to the OS.

This seems a bit different then switchdev at the moment because
functions are a PCIe concept and we don't have netdev for each VF
necessarily in the host/hypervisor. Also the traffic endpoint is the
host albeit a VM/container.

The current situation is to create a ndo op to manage every knob on
the functions by passing an index,

> 
>       int                     (*ndo_set_vf_mac)(struct net_device *dev,
>                                                   int queue, u8 *mac);
>       int                     (*ndo_set_vf_vlan)(struct net_device *dev,
>                                                    int queue, u16 vlan, u8 qos);
>	[...]

at linux plumbers conference in Seattle some of us kicked around an
idea to create "management" netdevs similar in style to what Florian(?)
proposed with his L2 only netdevs. This might provide a mechanism to
bring SR-IOV into the switchdev fold. But on the other hand I don't
want to manage an edge NIC the same way as a switch but this doesn't
necessarily mean the low level driver API can't be the same.

So I think it needs more thought is all and also to your point SR-IOV
does really imply some sort of switching/forwarding logic. It might be a
good topic for netdev conference in Seville.

Thanks!
John




> Thanks.
> 
