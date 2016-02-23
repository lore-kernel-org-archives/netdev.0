From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/9] mlx4: Implement port type setting via
 devlink interface
Date: Tue, 23 Feb 2016 15:26:27 +0100
Message-ID: <20160223142626.GF2140@nanopsycho.orion>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <1456165924-14399-4-git-send-email-jiri@resnulli.us>
 <56CC41C8.10802@stressinduktion.org>
 <20160223122109.GD2140@nanopsycho.orion>
 <56CC5E65.40809@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33864 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139AbcBWO03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 09:26:29 -0500
Received: by mail-wm0-f54.google.com with SMTP id b205so201953305wmb.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 06:26:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56CC5E65.40809@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 23, 2016 at 02:28:05PM CET, hannes@stressinduktion.org wrote:
>On 23.02.2016 13:21, Jiri Pirko wrote:
>>Tue, Feb 23, 2016 at 12:26:00PM CET, hannes@stressinduktion.org wrote:
>>>Hi Jiri,
>>>
>>>On 22.02.2016 19:31, Jiri Pirko wrote:
>>>>From: Jiri Pirko <jiri@mellanox.com>
>>>>
>>>>So far, there has been an mlx4-specific sysfs file allowing user to
>>>>change port type to either Ethernet of InfiniBand. This is very
>>>>inconvenient.
>>>
>>>Again, I want to express my concerns regarding all of this until this will be
>>>integrated into udev/systemd for stable device names. While one can build
>>>wrapper code around devlink to have stable devlink ports, I don't see a
>>>reason to include kernel code which actually has more problems than the sysfs
>>>approach. This harms admins to use those devices and will additionally
>>>require user space to write boiler plate code.
>>
>>Sysfs is not the place to do this things. It was already discussed here
>>multiple times. There was and attempt to use configfs, which was also
>>refused. Netlink is the only place to go. For multiple reasons,
>>including well defined api and behaviour, notifications, etc.
>
>I am not against netlink at all. My fear with this interface is simply:
>
>1) we introduce another ifindex/name like identifiers. It took a long time
>until this stuff finally worked fine with linux. It needs persistent storage
>in userspace being applied at boot time. Why this complications for this
>probably lesser often used interface?

Lesser often where? On switches, this interface will be used all the
time. You have to have some handle to manipulate the chip-wide stuff. In
our case it is devlink0. Similar to wireless, they have phy0. I believe
it is completely legit.


>
>2) The actual devlink attributes get managed from inside devlink and not the
>driver. So driver need to modify devlink.c/devlink.h in core to add new
>attributes.

That is exactly the point! Vendors cannot add their own specific crap,
they have to do things in generic way and extend devlink iface
accordingly. That's what we do now with ASIC shared buffer configuration
via devlink for example (in addition to port type and splitter).


>
>1) is easily solvable, just drop the ifindex style attributes and always
>force the user to enter the bus and bus-topology id.

But why? Use can easily get that info and map it to devlink index. It
aligns with nl80211 iface.

Do you really want to do commands like:
myhost:~$ dl dev show pci_0000:01:00.0
?


>
>For 2) I don't really know what drivers want, not sure if it is easier to add
>some small helper functions to add sysfs attributes to kobjects without
>necessarily holding a net_device. Thus mellanox drivers can use it and I am
>not sure how many other networking cards allow switching ports between ib and
>eth type. Port splitting only happens for interfaces which already have a
>net_device, no?

Not necessarily. IB ports that has no net_device could be split as well.
Hannes, again, sysfs approach was refused couple of times in past for this
purpose. Please leave sysfs alone.


>
>>I think it is quite trivial to teach udev to name devlinkX devices
>>according to pci address (or any other address). That's all what is
>>needed here. I don't understand your concerns.
>
>I don't think that this interface needs the same complexity as network
>interfaces.

Again, it aligns nicely with what they to in wireless in nl80211
interface. I don't see any complexity.


>
>I am not sure, but one of the initial problems was that this information
>should already be there before the driver actually gets loaded, no? These
>changes don't solve this problem either?

This is planned to be implemented in near future. Basically there would
be possible to use DEVLINK_CMD_NEW to add devlink iface for specific device
even before the driver gets loaded to serve as a place holder to set values
of some predefined set of options. Once the driver registers, it can read
those and act accordingly. For example, we need that to set "profile" of
our asic. This is a substitute to module options which are completely
inappropriate for this usecase.
