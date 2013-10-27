From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: extending ndo_add_rx_vxlan_port
Date: Sun, 27 Oct 2013 16:41:46 -0700
Message-ID: <526DA4BA.8050806@gmail.com>
References: <526D2F8F.1070204@mellanox.com> <alpine.LFD.2.03.1310271017120.19783@intel.com> <CAJZOPZ+S6ngqMjV-2ZMcpzkuWzzLWwCQMtd_1_SjDkqWh_tbYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Yan Burman <yanb@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:36185 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371Ab3J0XmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 19:42:12 -0400
Received: by mail-oa0-f46.google.com with SMTP id g12so2902586oah.19
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 16:42:10 -0700 (PDT)
In-Reply-To: <CAJZOPZ+S6ngqMjV-2ZMcpzkuWzzLWwCQMtd_1_SjDkqWh_tbYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2013 01:34 PM, Or Gerlitz wrote:
> On Sun, Oct 27, 2013 at 7:25 PM, Joseph Gasparakis
> <joseph.gasparakis@intel.com> wrote:
>>
>>
>> On Sun, 27 Oct 2013, Or Gerlitz wrote:
>>
>>> Hi,
>>>
>>> So with commit 53cf527513eed6e7170e9dceacd198f9267171b0 "vxlan: Notify drivers
>>> for listening UDP port changes" drivers that have HW offloads for vxlan can be
>>> notified on which UDP port to listen. Taking this further, some HW may need to
>>> know the multicast address and/or the VNID used by the vxlan instance/s set
>>> above them. In that respect, do we prefer to extend ndo_add_rx_vxlan_port() or
>>> introduce new ndo?
>>>
>>> Or.
>>>
>>
>> The way this patch works is to notify the drivers when a VXLAN UDP port
>> comes up or down. This way drivers do not need to do any sort of accounting. As
>
> Could you elaborate why do we want to notify all the netdev instances
> in the system (on a certain name-space)
> that vxlan instance/s are set to listen on certain UDP port and not
> only the device over which the
> vxlan device is being set? say the HW can listen limited amount of UDP
> ports and few vxlan instances are created
> one of top of each "real" netdev in the system and each on different
> port. Each netdevice will get all callbacks on port addition
> and at some point will start to fail adding them into the HW  when the
> HW limit is met.
>
> Or.
> --

The issue is how to determine "the device over which the vlan device is
being set". Because the vxlan device is a layer three device we do not
have a 1:1 binding between vxlan port and l2 net_device. In the
mentioned patches the work around for this was to add the UDP port to
every l2 net_device. I agree it is a bit of a big hammer.

It might be better to only add the UDP port to the default route if it
is specified then add the ndo call to the snooping logic (vxlan_snoop)
and the explicit added netlink fdb entries. This would be a bit more
precise than what we have today.

On the other hand the HW table will eventually be full and even with
this optimization may fail. At this point the user has no way to set
which ports are added and which are failed. Joseph, wanted this to
be automatic so users did not have to configure it so we end up with
this case. The other alternative is to provide a hook into the driver
via rtnetlink I'm not sure its worth the effort though. With this
and a feature flag you could let users manage the device manually.

But is this a problem in practice? My feeling is typically the
number of UDP ports in use is smaller than the number the HW supports.

Thanks,
.John


-- 
John Fastabend         Intel Corporation
