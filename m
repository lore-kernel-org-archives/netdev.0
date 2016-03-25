From: Ben Greear <greearb@candelatech.com>
Subject: =?UTF-8?Q?Re:_veth_regression_with_=22don=e2=80=99t_modify_ip=5fsum?=
 =?UTF-8?Q?med;_doing_so_treats_packets_with_bad_checksums_as_good.=22?=
Date: Thu, 24 Mar 2016 18:13:22 -0700
Message-ID: <56F490B2.3090603@candelatech.com>
References: <56F463D6.7080406@candelatech.com>
 <CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>
 <56F4810A.9060904@candelatech.com> <56F49036.8050902@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Vijay P <vijayp@vijayp.ca>, Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:56519 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbcCYBNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 21:13:24 -0400
In-Reply-To: <56F49036.8050902@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2016 06:11 PM, Ben Greear wrote:
> On 03/24/2016 05:06 PM, Ben Greear wrote:
>> On 03/24/2016 04:56 PM, Cong Wang wrote:
>>> On Thu, Mar 24, 2016 at 3:01 PM, Ben Greear <greearb@candelatech.com> wrote:
>>>> I have an application that creates two pairs of veth devices.
>>>>
>>>> a <-> b       c <-> d
>>>>
>>>> b and c have a raw packet socket opened on them and I 'bridge' frames
>>>> between b and c to provide network emulation (ie, configurable delay).
>>>>
>>>
>>> IIUC, you create two raw sockets in order to bridge these two veth pairs?
>>> That is, to receive packets on one socket and deliver packets on the other?
>>
>> Yes.
>>
>>>> I put IP 1.1.1.1/24 on a, 1.1.1.2/24 on d, and then create a UDP connection
>>>> (using policy based routing to ensure frames are sent on the appropriate
>>>> interfaces).
>>>>
>>>> This is user-space only app, and kernel in this case is completely
>>>> unmodified.
>>>>
>>>> The commit below breaks this feature:  UDP frames are sniffed on both a and
>>>> d ports
>>>> (in both directions), but the UDP socket does not receive frames.
>>>>
>>>> Using normal ethernet ports, this network emulation feature works fine, so
>>>> it is
>>>> specific to VETH.
>>>>
>>>> A similar test with just sending UDP between a single veth pair:  e <-> f
>>>> works fine.  Maybe it has something to do with raw packets?
>>>>
>>>
>>> Yeah, I have the same feeling. Could you trace kfree_skb() to see
>>> where these packets are dropped? At UDP layer?
>>
>> Since reverting the patch fixes this, it almost certainly has to be due to some
>> checksum checking logic.  Since UDP sockets (between single veth pair)
>> works, it would appear to be related to my packet bridge, so maybe
>> it is specific to raw packets and/or sendmmsg api.
>>
>> I'll investigate it better tomorrow.
>
> So, I found time to poke at it this evening:
>
> Sending between two veth pairs, no packet bridge involved.

Errrr, to be clear:  I mean sending between two ends of a single veth pair here.

>
> UDP:  ip_summed is 3 (CHECKSUM_PARTIAL)   # Works fine.
> raw packet frames, custom ether protocol (0x1111 type):  ip_summed is 0 (NONE) # Works fine.
>
> When I try to send UDP through the veth pairs & pkt bridge, I see this:

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
