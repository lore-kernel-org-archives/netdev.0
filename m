From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] bonding: correct the MAC address for "follow" fail_over_mac
 policy
Date: Thu, 16 Jul 2015 14:04:39 +0200
Message-ID: <55A79DD7.8050602@cumulusnetworks.com>
References: <55A76B8A.5040804@huawei.com> <55A77840.5010506@cumulusnetworks.com> <55A799F7.8080904@huawei.com> <55A79A7A.3000204@cumulusnetworks.com> <55A79B74.1000701@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>,
	"j.vosburgh@gmail.com >> Jay Vosburgh" <j.vosburgh@gmail.com>,
	"vfalico@gmail.com >> Veaceslav Falico" <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, fengtiantian@huawei.com,
	"hahaer.guo@huawei.com >> Guozhibin (Hahaer)" <hahaer.guo@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33130 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180AbbGPMEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 08:04:42 -0400
Received: by widic2 with SMTP id ic2so13342089wid.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 05:04:41 -0700 (PDT)
In-Reply-To: <55A79B74.1000701@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/2015 01:54 PM, Nikolay Aleksandrov wrote:
> On 07/16/2015 01:50 PM, Nikolay Aleksandrov wrote:
>> On 07/16/2015 01:48 PM, Ding Tianhong wrote:
>>> On 2015/7/16 17:24, Nikolay Aleksandrov wrote:
>>>> On 07/16/2015 10:30 AM, Ding Tianhong wrote:
>>>>> The "follow" fail_over_mac policy is useful for multiport devices that
>>>>> either become confused or incur a performance penalty when multiple
>>>>> ports are programmed with the same MAC address, but the same MAC
>>>>> address still may happened by this steps for this policy:
>>>>>
>>>>> 1) echo +eth0 > /sys/class/net/bond0/bonding/slaves
>>>>>    bond0 has the same mac address with eth0, it is MAC1.
>>>>>
>>>>> 2) echo +eth1 > /sys/class/net/bond0/bonding/slaves
>>>>>    eth1 is backup, eth1 has MAC2.
>>>>>
>>>>> 3) ifconfig eth0 down
>>>>>    eth1 became active slave, bond will swap MAC for eth0 and eth1,
>>>>>    so eth1 has MAC1, and eth0 has MAC2.
>>>>>
>>>>> 4) ifconfig eth1 down
>>>>>    there is no active slave, and eth1 still has MAC1, eth2 has MAC2.
>>>>>
>>>>> 5) ifconfig eth0 up
>>>>>    the eth0 became active slave again, the bond set eth0 to MAC1.
>>>>>
>>>>> Something wrong here, then if you set eth1 up, the eth0 and eth1 will have the same
>>>>> MAC address, it will break this policy for ACTIVE_BACKUP mode.
>>>>>
>>>>> This patch will fix this problem by finding the old active slave and
>>>>> swap them MAC address before change active slave.
>>>>>
>>>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>>>> ---
>>>>>  drivers/net/bonding/bond_main.c | 20 ++++++++++++++++++++
>>>>>  1 file changed, 20 insertions(+)
>>>>>
>>>>
>>>> This doesn't seem to be true:
>>>> ~# cat /sys/class/net/bond0/bonding/fail_over_mac 
>>>> follow 2
>>>> root@debian:~# ip l sh eth1
>>>> 3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP mode DEFAULT group default qlen 1000
>>>>     link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff
>>>> root@debian:~# ip l sh eth2
>>>> 4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP mode DEFAULT group default qlen 1000
>>>>     link/ether 52:54:00:4f:a5:99 brd ff:ff:ff:ff:ff:ff
>>>> root@debian:~# ip l sh bond0
>>>> 26: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
>>>>     link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff
>>>>
>>>> *eth1 is the first and active slave and bond0 has taken its mac.
>>>> Now trying your steps:
>>>> Step 3) (bringing down the active eth1)
>>>> root@debian:~# ip l set eth1 down
>>>> root@debian:~# ip l sh bond0
>>>> 26: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
>>>>     link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff
>>>> root@debian:~# ip l sh eth1
>>>> 3: eth1: <BROADCAST,MULTICAST,SLAVE> mtu 1500 qdisc pfifo_fast master bond0 state DOWN mode DEFAULT group default qlen 1000
>>>>     link/ether 52:54:00:4f:a5:99 brd ff:ff:ff:ff:ff:ff
>>>> root@debian:~# ip l sh eth2
>>>> 4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP mode DEFAULT group default qlen 1000
>>>>     link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff
>>>>
>>>> *The mac addresses of eth1 and eth2 are correctly swapped, so far so good.
>>>>
>>>> Step 4) (bringing down the active eth2)
>>>> root@debian:~# ip l set eth2 down
>>>> 3: eth1: <BROADCAST,MULTICAST,SLAVE> mtu 1500 qdisc pfifo_fast master bond0 state DOWN mode DEFAULT group default qlen 1000
>>>>     link/ether 52:54:00:4f:a5:99 brd ff:ff:ff:ff:ff:ff
>>>> 4: eth2: <BROADCAST,MULTICAST,SLAVE> mtu 1500 qdisc pfifo_fast master bond0 state DOWN mode DEFAULT group default qlen 1000
>>>>     link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff
>>>> 26: bond0: <NO-CARRIER,BROADCAST,MULTICAST,MASTER,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default 
>>>>     link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff
>>>>
>>>> *eth2 has kept the mac address of the bond and they're both down now
>>>>
>>>> Step 5) (bring eth1 up again and observe the macs)
>>>> ~# ip l set eth1 up
>>>> 3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP mode DEFAULT group default qlen 1000
>>>>     link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff
>>>> 4: eth2: <BROADCAST,MULTICAST,SLAVE> mtu 1500 qdisc pfifo_fast master bond0 state DOWN mode DEFAULT group default qlen 1000
>>>>     link/ether 52:54:00:4f:a5:99 brd ff:ff:ff:ff:ff:ff
>>>> 26: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
>>>>     link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff
>>>>
>>>> *The macs are correctly swapped and there's no such bug. 
>>>>
>>>> Step 6(?) bring eth2 up
>>>> ~# ip l set eth2 up
>>>> 3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP mode DEFAULT group default qlen 1000
>>>>     link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff
>>>> 4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP mode DEFAULT group default qlen 1000
>>>>     link/ether 52:54:00:4f:a5:99 brd ff:ff:ff:ff:ff:ff
>>>> 26: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
>>>>     link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff
>>>>
>>>> *Still correct.
>>>>
>>>> Also the mac address that gets set is dev_addr which is changed when
>>>> the swapping is done, if you'd like to get the original mac address
>>>> you should be using slave->perm_hwaddr.
>>>>
>>>
>>> Hi Nik:
>>>
>>> Which kernel version do you use, I test this on kernel 3.19.8 and 4.2-rc2, this problem exist on both version,
>>> maybe I miss something?
>>>
>>> Ding
>>>
>>>
>>
>> It's current net-next.
>> ~# uname -a
>> Linux debian 4.2.0-rc2+ #8 SMP Wed Jul 15 21:22:14 CEST 2015 x86_64 GNU/Linux
>>
> 
> Ah this is my bad, my setup was polluted from previous tests and the bonding wasn't
> clean, you're right - this does reproduce.
> Sorry about that
> 

Just tried it and it fixes it for me so
Tested-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
