From: Dan Geist <dan@polter.net>
Subject: Re: [Bug 194749] New: kernel bonding does not work in a network
 nameservice in versions above 3.10.0-229.20.1
Date: Thu, 2 Mar 2017 15:39:59 -0500 (EST)
Message-ID: <1601587594.2278.1488487199506.JavaMail.zimbra@polter.net>
References: <20170302103219.74b675c5@xeon-e3> <CAM_iQpVm_WK9X+3Vsm0OrFCOd3Srn-s+xqe9fQtoT=30JZeVJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        chenweilong@huawei.com, Jiri Pirko <jiri@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from schnell.polter.net ([99.33.109.108]:52460 "EHLO
        schnell.polter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751255AbdCBWfg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 17:35:36 -0500
In-Reply-To: <CAM_iQpVm_WK9X+3Vsm0OrFCOd3Srn-s+xqe9fQtoT=30JZeVJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- On Mar 2, 2017, at 3:11 PM, Cong Wang xiyou.wangcong@gmail.com wrote

> On Thu, Mar 2, 2017 at 10:32 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>>
>>
>> Begin forwarded message:
>>
>> Date: Wed, 01 Mar 2017 21:08:01 +0000
>> From: bugzilla-daemon@bugzilla.kernel.org
>> To: stephen@networkplumber.org
>> Subject: [Bug 194749] New: kernel bonding does not work in a network nameservice
>> in versions above 3.10.0-229.20.1
>>
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=194749
>>
>>             Bug ID: 194749
>>            Summary: kernel bonding does not work in a network nameservice
>>                     in versions above 3.10.0-229.20.1
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: > 3.10.0-229.20.1
>>           Hardware: x86-64
>>                 OS: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: blocking
>>           Priority: P1
>>          Component: Other
>>           Assignee: stephen@networkplumber.org
>>           Reporter: dan@polter.net
>>         Regression: No
>>
>> bond interface is being used in active/standby mode with two physical NICs
>> inside a network nameservice to provide switchpath redundancy.
>>
>> netns is instantiated post-boot with the following:
>>
>> ip netns add vntp
>> ip link set p4p1 netns vntp
>> ip link set p4p2 netns vntp
>> ip link set bond0 netns vntp
>> ip netns exec vntp ip link set lo up
>> ip netns exec vntp ip link set p4p1 up
>> ip netns exec vntp ip link set p4p2 up
>> ip netns exec vntp ip link set bond0 up
>> ip netns exec vntp ifenslave bond0 p4p1 p4p2
> 
> This is due to the following commit:
> 
> commit f9399814927ad9bb995a6e109c2a5f9d8a848209
> Author: Weilong Chen <chenweilong@huawei.com>
> Date:   Wed Jan 22 17:16:30 2014 +0800
> 
>    bonding: Don't allow bond devices to change network namespaces.
> 
>    Like bridge, bonding as netdevice doesn't cross netns boundaries.
> 
>    Bonding ports and bonding itself live in same netns.
> 
>    Signed-off-by: Weilong Chen <chenweilong@huawei.com>
>    Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> 
> NETIF_F_NETNS_LOCAL was introduced for loopback device which
> is created for each netns, it is not clear why we need to add it to bond
> and bridge...

Thank you for tracking this down. Without digging through the code to figure it out, does this imply that the existence of a bond interface is not possible AT ALL within a netns or simply that it may not be "migrated" between the global scope and a netns?

In order for the CentOS network stack to init the interfaces, I've been creating them with the standard system configuration files:

[root@01 network-scripts]# cat ifcfg-p4p1 
TYPE=Ethernet
BOOTPROTO=none
DEVICE=p4p1
ONBOOT=yes
MASTER=bond0
SLAVE=yes
UUID=4e6c40ee-cc05-4f88-a851-b3185dbdcd0f
NAME=p4p1

[root@01 network-scripts]# cat ifcfg-p4p2
TYPE=Ethernet
BOOTPROTO=none
DEVICE=p4p2
ONBOOT=yes
MASTER=bond0
SLAVE=yes
UUID=15135328-12b8-4fe3-8940-db02b77b94d9
NAME=p4p2

[root@01 network-scripts]# cat ifcfg-bond0 
DEVICE=bond0
TYPE=Bond
BONDING_MASTER=yes
NAME=bond0
UUID=97674993-0e50-4a00-a210-c66d75481a84
ONBOOT=yes
BONDING_OPTS="updelay=0 resend_igmp=1 use_carrier=1 miimon=100 downdelay=0 xmit_hash_policy=0 primary_reselect=0 fail_over_mac=0 arp_validate=0 mode=active-backup lacp_rate=0 arp_interval=0 ad_select=0"
IPV6INIT=no


Perhaps by not instantiating the bond interface until after the netns is created, this situation can be avoided?

Thanks.
Dan

-- 
Dan Geist dan(@)polter.net
