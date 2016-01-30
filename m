From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: bonding (IEEE 802.3ad) not working with qemu/virtio
Date: Sat, 30 Jan 2016 12:41:16 +0100
Message-ID: <56ACA15C.1080403@cumulusnetworks.com>
References: <56ABDA3D.8040100@cumulusnetworks.com> <28285.1454103900@famine>
 <56ABDE2A.7010301@cumulusnetworks.com>
 <20160129.225924.1343743091073159760.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jay.vosburgh@canonical.com, bjornar.ness@gmail.com,
	netdev@vger.kernel.org, vfalico@gmail.com,
	gospo@cumulusnetworks.com, jiri@resnulli.us, mst@redhat.com,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38533 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999AbcA3LlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 06:41:21 -0500
Received: by mail-wm0-f50.google.com with SMTP id p63so12353827wmp.1
        for <netdev@vger.kernel.org>; Sat, 30 Jan 2016 03:41:20 -0800 (PST)
In-Reply-To: <20160129.225924.1343743091073159760.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/30/2016 07:59 AM, David Miller wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Date: Fri, 29 Jan 2016 22:48:26 +0100
>=20
>> On 01/29/2016 10:45 PM, Jay Vosburgh wrote:
>>> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>>>
>>>> On 01/25/2016 05:24 PM, Bj=F8rnar Ness wrote:
>>>>> As subject says, 802.3ad bonding is not working with virtio netwo=
rk model.
>>>>>
>>>>> The only errors I see is:
>>>>>
>>>>> No 802.3ad response from the link partner for any adapters in the=
 bond.
>>>>>
>>>>> Dumping the network traffic shows that no LACP packets are sent f=
rom the
>>>>> host running with virtio driver, changing to for example e1000 so=
lves
>>>>> this problem
>>>>> with no configuration changes.
>>>>>
>>>>> Is this a known problem?
>>>>>
>>>> [Including bonding maintainers for comments]
>>>>
>>>> Hi,
>>>> Here's a workaround patch for virtio_net devices that "cheats" the
>>>> duplex test (which is the actual problem). I've tested this locall=
y
>>>> and it works for me.
>>>> I'd let the others comment on the implementation, there're other s=
igns
>>>> that can be used to distinguish a virtio_net device so I'm open to=
 suggestions.
>>>> Also feedback if this is at all acceptable would be appreciated.
>>>
>>> 	Should virtio instead provide an arbitrary speed and full duplex
>>> to ethtool, as veth does?
>>>
>>> 	Creating a magic whitelist of devices deep inside the 802.3ad
>>> implementation seems less desirable.
>>>
>> TBH, I absolutely agree. In fact here's what we've been doing:
>> add set_settings which allows the user to set any speed/duplex
>> and get_settings of course to retrieve that. This is also useful
>> for testing other stuff that requires speed and duplex, not only
>> for the bonding case.
>=20
> I also agree.  Having a whitelist is just rediculous.
>=20
> There should be a default speed/duplex setting for such devices as we=
ll.
> We can pick one that will be use universally for these kinds of devic=
es.
>=20
Yes, that's the other thing - the default setting, from a brief greppin=
g
I see that veth uses 10Gbps, tun uses 10Mbps and batman-adv uses 10Mbps=
=2E

If we add a default get_settings that can be used by virtual devices
in ethtool that returns 10Gbps with the settings set like veth does
sounds good to me. What do you think ?

In fact they all set the same settings (apart from speed) so we can
consolidate them in a single default setting init function and for the
ones using different speed do something like:
__ethtool_init_settings(); <- sets everything like veth would with 10Mb=
ps speed
__ethtool_cmd_speed_set(cmd, SPEED_10000);
And we're done.
