From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Wed, 04 Mar 2015 16:31:21 -0800
Message-ID: <54F7A3D9.60805@cumulusnetworks.com>
References: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bArwsNUdtNM25Zm=ZccrmVqC8e45E6qsjMdO3s0FrOVog@mail.gmail.com> <54F6C788.2010201@cumulusnetworks.com> <CAE4R7bC_okmfXSSYe3YKoHwKWOjPO1xju06LsSvNgZzsymBqCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:44930 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623AbbCEAbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 19:31:22 -0500
Received: by pdjz10 with SMTP id z10so10630207pdj.11
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 16:31:22 -0800 (PST)
In-Reply-To: <CAE4R7bC_okmfXSSYe3YKoHwKWOjPO1xju06LsSvNgZzsymBqCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/4/15, 8:24 AM, Scott Feldman wrote:
> On Wed, Mar 4, 2015 at 12:51 AM, roopa <roopa@cumulusnetworks.com> wrote:
>> On 3/3/15, 11:02 PM, Scott Feldman wrote:
>>> On Tue, Mar 3, 2015 at 4:15 PM,  <roopa@cumulusnetworks.com> wrote:
>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>
>>>> With the recent addition of the NETIF_F_HW_SWITCH_OFFLOAD flag
>>>> on rocker ports, the second command (bridge link set) below will turn off
>>>> learning in the rocker hw (Scott/Jiri, need some confirmation from
>>>> you that this is indeed a problem and if the below patch is ok).
>>>>
>>>> ip link set dev swp1 master br0
>>>> bridge link set dev swp1 learning off master
>>>> bridge link set dev swp1 learning_sync on self
>>>>
>>>> This patch fixes rocker to ignore learning setting when 'master'
>>>> is set. This makes it possible to set/unset learning in kernel and bridge
>>>> driver independently.
>>>>
>>>> The below command will continue to set learning on in both kernel and
>>>> rocker
>>>> hw:
>>>> bridge link set dev swp1 learning on
>>>>
>>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>> ---
>>>>    drivers/net/ethernet/rocker/rocker.c |    3 +++
>>>>    1 file changed, 3 insertions(+)
>>>>
>>>> diff --git a/drivers/net/ethernet/rocker/rocker.c
>>>> b/drivers/net/ethernet/rocker/rocker.c
>>>> index e5a15a4..d7c31d2 100644
>>>> --- a/drivers/net/ethernet/rocker/rocker.c
>>>> +++ b/drivers/net/ethernet/rocker/rocker.c
>>>> @@ -3769,6 +3769,9 @@ static int rocker_port_bridge_setlink(struct
>>>> net_device *dev,
>>>>           struct nlattr *attr;
>>>>           int err;
>>>>
>>>> +       if (flags && !(flags & BRIDGE_FLAGS_SELF))
>>>> +               return 0;
>>>> +
>>>>           protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
>>>>                                      IFLA_PROTINFO);
>>>>           if (protinfo) {
>>>
>>> NACK on this patch.  This is the problem with netlink creeping into
>>> ndo ops: it's too tempting to push work-arounds down to driver.
>> netlink has already crept into the driver. You do parse the netlink message
>> right below.
>> The patch actually does not touch the message. It is just using one of the
>> args already passed to the handler.
>>
>>> In this case, you're making the driver check to see if it's SELF when
>>> it's already SELF by definition.
>>>
>>> Rocker setlink wasn't broken prior to the NETIF_F_HW_SWITCH_OFFLOAD
>>> patches.
>>>    Now it is,
>> sure, I can submit a patch to remove the flag on rocker ports if thats what
>> you prefer.
> I don't want that either.  I haven't figured out why I need
> NETIF_F_HW_SWITCH_OFFLOAD at the moment, but if this is supposed to be
> a flag that's set on switchdev driver ports, then it should be set on
> rocker ports.
Its not mandatory. Only If you need it. If you want the user to drive 
rocker explicitly using 'self',
then you dont need the OFFLOAD flag.

>
>
>>> but this isn't the right fix.
>>>
>>> Can we revisit this so these two commands only hit MASTER:
>>>
>>>      bridge link set dev swp1 learning on
>>>      bridge link set dev swp1 learning on master
>>>
>>> And this one hits SELF:
>>>
>>>       bridge link set dev swp1 learning on self
>>
>> For the above to work you just need to remove the feature flag in the driver
>> (i can submit a patch).
>>
>> The reason why it is useful to have it the way it currently is:
>>
>> the setlink request does not always only contain the 'learning' flag.
>> It handles vlans too. I dont see rocker parsing vlans yet ie IFLA_AF_SPEC
>> (or did i miss it ?)
> Yes, you missed it.  See
> br_setlink->br_afspec->br_vlan_info->nbp_vlan_add->__vlan_add->__vlan_vid_add
ok thanks for the clarification. I thought you were using 
ndo_bridge_setlink to pass the vlan info to the driver (because that is 
one way to pass vlans for the vlan filtering bridge). And the switch 
port driver already implements ndo_bridge_setlink.

>
> The bridge is already calling into the driver to tell it which vlans
> are on which port.
>
> This works when doing vlans outside of bridge driver also.  One
> interface for both bridge and stand-alone vlans.
agreed, however, i would have thought you also need the vinfo flags 
(struct bridge_vlan_info).
>
> I see no reason to parse netlink in the driver's setlink/dellink other
> than getting the SELF flags.
hmm.., the driver is already doing this to parse learning and learning 
sync flags. And bridge setlink flags is passed in the ndo op.

Let me know if you have other ideas to fix this (one approach is to not 
advertise the OFFLOAD flag on rocker ports).
