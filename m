From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next RFC 0/6] Introduce devlink interface and first
 drivers to use it
Date: Mon, 8 Feb 2016 13:11:41 +0100
Message-ID: <56B885FD.2050305@stressinduktion.org>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
 <20160203143133.1b70bcb5@redhat.com> <20160203133356.GA2219@nanopsycho.orion>
 <56B219FA.7080208@iogearbox.net> <56B35089.4000707@stressinduktion.org>
 <20160204132622.GB2198@nanopsycho.orion>
 <56B472F2.6080101@stressinduktion.org>
 <20160205173841.GA23058@ast-mbp.thefacebook.com>
 <20160206194045.GA2282@nanopsycho.orion>
 <56B86ACA.1030704@stressinduktion.org>
 <20160208105529.GB2090@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:39320 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751459AbcBHMLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 07:11:49 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 81AC82095F
	for <netdev@vger.kernel.org>; Mon,  8 Feb 2016 07:11:48 -0500 (EST)
In-Reply-To: <20160208105529.GB2090@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 08.02.2016 11:55, Jiri Pirko wrote:
> Mon, Feb 08, 2016 at 11:15:38AM CET, hannes@stressinduktion.org wrote:
>> Hello,
>>
>> On 06.02.2016 20:40, Jiri Pirko wrote:
>>> Fri, Feb 05, 2016 at 06:38:42PM CET, alexei.starovoitov@gmail.com wrote:
>>>> On Fri, Feb 05, 2016 at 11:01:22AM +0100, Hannes Frederic Sowa wrote:
>>>>>
>>>>> Okay. I see it more as changing mode of operation of hardware and thus has
>>>>> not really anything to do with networking. If you say you change ethernet to
>>>>> infiniband it has something to do with networking, sure. But I am fine with
>>>>> this, I just thought the code size could be reduced by adding this to sysfs
>>>>> quite a lot. I don't have a strong opinion on this.
>>>>
>>>> there is already a way to change eth/ib via
>>>> echo 'eth' > /sys/bus/pci/drivers/mlx4_core/0000:02:00.0/mlx4_port1
>>>>
>>>> sounds like this is another way to achieve the same?
>>>
>>> It is. However the current way is driver-specific, not correct.
>>
>> Why is driver specific not correct? Actually it is very much a device
>> specific thing, isn't it?
>
> Well, adding driver specific sysfs file called "driver_name_port_type"
> does not seem correct to me.

Why? PHYs are debugged like that? I thought that especially sysfs is the 
right thing, it makes sure we can correctly identify a device. The logic 
in devlink_alloc by just incrementing a counter and having the naming 
policy be decided by driver registration time will introduce the same 
problems like identifying devices by interfaces had before.

>>> For mlx5, we need the same, it cannot be done in this way. Do devlink is
>>> the correct way to go.
>>
>> Do two drivers already justify a new complete netlink api? Doesn't this
>> create the same problems like netdevice naming problems which needed multiple
>> years to become stable in case we have multiple cards or some administrator
>
> The thing is, other driver would use it as well, but there's no way to
> do it :) So vendors have their proprietary configuration utils. Devlink
> objective is to avoid those, to introduce vendor-neutral interface.

Ok, agreed. But multiple driver reuse the phy-sysfs routines, too. I 
didn't see this to be a problem.

Anyway, I don't care if it is sysfs or something else, I am concerned 
about the atomic_inc_return based identification of those devices.

>> reorders the cards (biosdevorder, systemd/udev issues)? Are ports always
>> stable? How can we have a 1:1 relationship with ifindexes and how can they be
>> stable? It is impossible to use that in scripts?
>
> Port index is setup by driver always, they have stable internal
> numbering. devlink device name is not stable (as for example netdev
> name), but can be easily identified by bus name and device name. I don't
> see a reason why udev cannot rename it according to some rules. By the
> way, this is very similar to phyX wireless devices.

Ok, understood. It just seems to be duplication of code with another name.

>>>> Why not hide echo/cat in iproute2 instead of adding parallel netlink api?
>>>> Or this is for switches instead of nics?
>>>> Then why it's not adding to switchdev?
>>>
>>> Note this is not specific to switch ASICs. This is for all network devices.
>>
>> That's actually my fear. The relationship from "devlink-names" to ifindexes I
>> didn't understand at all architecturally.
>
> Again, this is very similar to phyX wireless devices.
> I don't understand the reason for your fear :)

If, as you said, this gets integrated by systemd/udev and will change 
names to stable ones before switching ports (so we don't accidentally 
switch a wrong port) I am all fine. This is basically how net_devices 
are handled.

Then my only argument is that this is too complex, but I can live with that.

Thanks,
Hannes
