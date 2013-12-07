From: Kevin Wilson <wkevils@gmail.com>
Subject: Re: Fw: [Bug 66691] New: iproute2: macvlan: Wrong root device shown
 if in different netns
Date: Sat, 7 Dec 2013 11:18:52 +0200
Message-ID: <CAGXs5wXr-7vgmT39__cJ0xo3D4fFOkfmd4_C-5+zPAKGeWZugA@mail.gmail.com>
References: <20131206120543.0afaafb5@nehalam.linuxnetplumber.net>
	<CAGXs5wXC+eTZD3sXD4zFtkpY8tcU14Kr6AiA9=kugHups_KCHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:39120 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393Ab3LGJSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 04:18:53 -0500
Received: by mail-ob0-f182.google.com with SMTP id wp4so1836389obc.41
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 01:18:53 -0800 (PST)
In-Reply-To: <CAGXs5wXC+eTZD3sXD4zFtkpY8tcU14Kr6AiA9=kugHups_KCHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Shouldn't the macvlan be network nsmespace local device, like the vlan
and VXLAN device (which have NETIF_F_NETNS set)?
When a nework device has the NETIF_F_NETNS flag set, it cannot be
moved from one network namespace to another.

Kevin W.

On Sat, Dec 7, 2013 at 1:38 AM, Kevin Wilson <wkevils@gmail.com> wrote:
> Hi,
> Shouldnt the macvlan be network nsmespace local device, like the vlan and
> vxlan device (which have NETIF_F_NETNS set)?
>
>
> On Friday, December 6, 2013, Stephen Hemminger <stephen@networkplumber.org>
> wrote:
>> This isn't a iproute2 bug, it is only reporting what the kernel tells it
>>
>> Begin forwarded message:
>>
>> Date: Fri, 6 Dec 2013 00:07:15 -0800
>> From: "bugzilla-daemon@bugzilla.kernel.org"
>> <bugzilla-daemon@bugzilla.kernel.org>
>> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
>> Subject: [Bug 66691] New: iproute2: macvlan: Wrong root device shown if in
>> different netns
>>
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=66691
>>
>>             Bug ID: 66691
>>            Summary: iproute2: macvlan: Wrong root device shown if in
>>                     different netns
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: 3.10
>>           Hardware: All
>>                 OS: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Other
>>           Assignee: shemminger@linux-foundation.org
>>           Reporter: helmut.schaa@googlemail.com
>>         Regression: No
>>
>> In the root net namespace if have the following devices:
>>
>>> ip link
>> [...]
>> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state
>> UP
>> mode DEFAULT group default qlen 1000
>>     link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
>> 3: gre0: <NOARP> mtu 1476 qdisc noop state DOWN mode DEFAULT group default
>>     link/gre 0.0.0.0 brd 0.0.0.0
>> [...]
>>
>> Let's add a macvlan on top of eth0:
>>
>>> ip link
>> [...]
>> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state
>> UP
>> mode DEFAULT group default qlen 1000
>>     link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
>> 3: gre0: <NOARP> mtu 1476 qdisc noop state DOWN mode DEFAULT group default
>>     link/gre 0.0.0.0 brd 0.0.0.0
>> [...]
>> 17: mac0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
>> DEFAULT group default
>>     link/ether 46:aa:b4:fb:44:a6 brd ff:ff:ff:ff:ff:ff
>>
>> And now lets move it into its own net namespace and list the devices in
>> the new
>> namespace.
>>
>>> ip link set mac0 netns myns
>>> ip netns exec myns ip link
>> [...]
>> 2: gre0: <NOARP> mtu 1476 qdisc noop state DOWN mode DEFAULT group default
>>     link/gre 0.0.0.0 brd 0.0.0.0
>> [...]
>> 17: mac0@gre0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN
>> mode
>> DEFAULT group default
>>     link/ether 46:aa:b4:fb:44:a6 brd ff:ff:ff:ff:ff:ff
>>
>> mac0 shows gre0 as its base device which is not correct. However gre0 has
>> the
>> same ifindex in the new namespace as eth0 in the root namespace and the
>> ifindex
>> is used for finding the base device.
>>
>> commit aa79e66eee5d525e2fcbd2a5fcb87ae3dd4aa9e9 "net: Make ifindex
>> generation
>> per-net namespace" changed the ifindex generation to only be unique within
>> a
>> namespace.
>>
>> --
>> You are receiving this mail because:
>> You are the assignee for the bug.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
