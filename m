From: Mark Trompell <mark@foresightlinux.org>
Subject: Re: bridge not getting ip since 3.11.5 and 3.4.66
Date: Wed, 27 Nov 2013 07:46:55 +0100
Message-ID: <CAEPa5y=PPO1PoaMqgB1ifc64GVK8NkGDtnOftTZ=n+-f-7e7xA@mail.gmail.com>
References: <CAEPa5ym2Xz3F19fJJqNawkRLOKk6Ao6oXrzSrHU051V7p=9otA@mail.gmail.com>
	<CAE3RKNng9A6Bp7wa4+6iCprwEQpzGueagLc8iob+aFabJW4nnw@mail.gmail.com>
	<CAEPa5y=tgdGpDMBGY0ijyWSgQ0m5SZW8EMP072OF=sZZUjqN1g@mail.gmail.com>
	<CAEPa5ym0+-_Q9zUidDfE2SD7XYZxAqqEUByBkkH1ZOmh9rmFHg@mail.gmail.com>
	<CAEPa5ym4HWK9vo_BYYZbQsGZXG9r2kfYR2rFGaYjjJqDfkf2uQ@mail.gmail.com>
	<5294BD63.7020905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Veaceslav Falico <veaceslav@falico.eu>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, herbert@gondor.apana.org.au
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5294BD63.7020905@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 26, 2013 at 4:25 PM, Vlad Yasevich <vyasevich@gmail.com> wrote:
> On 11/26/2013 08:27 AM, Mark Trompell wrote:
>> Answering my own mail again and even top posting, sorry, but makes
>> more sense to me in that case).
>> I reverted bridge related patches from 3.11.5 and it boils down to
>> commit 0e308361d7ca0bf8b23fd472b90aae0fb10a1c32
>> Author: Herbert Xu <herbert@gondor.apana.org.au>
>> Date:   Thu Sep 12 17:12:05 2013 +1000
>>
>>     bridge: Clamp forward_delay when enabling STP
>>
>>     [ Upstream commit be4f154d5ef0ca147ab6bcd38857a774133f5450 ]
>>
>>     At some point limits were added to forward_delay.  However, the
>>     limits are only enforced when STP is enabled.  This created a
>>     scenario where you could have a value outside the allowed range
>>     while STP is disabled, which then stuck around even after STP
>>     is enabled.
>>
>>     This patch fixes this by clamping the value when we enable STP.
>>
>>     I had to move the locking around a bit to ensure that there is
>>     no window where someone could insert a value outside the range
>>     while we're in the middle of enabling STP.
>>
>> Causing the issue for me. Reverting that patch and br0 comes up again
>> and gets an ip.
>
> yes, that patch introduced a bug where we always used the
> max_forward delay value.
>
> you have 2 options:
>  1) disable STP.  Since you are just running VMs and you have a single
>     physical connection on the bridge, you can safely disable STP since
>     your system is a leaf node.

disabling stp indeed helps here, but ...

>  2) Get the latest stable kernel.  The bug has been fixed there.

3.12.1 still doesn't work with stp enabled.
I guess you're talking about 4b6c7879d84ad06a2ac5b964808ed599187a188d
bridge: Correctly clamp MAX forward_delay when enabling STP
which should fix that?

> -vlad


Mark

>>
>> On Tue, Nov 12, 2013 at 11:57 AM, Mark Trompell <mark@foresightlinux.org> wrote:
>>> On Mon, Nov 11, 2013 at 1:52 PM, Mark Trompell <mark@foresightlinux.org> wrote:
>>>> On Mon, Nov 11, 2013 at 12:07 PM, Veaceslav Falico <veaceslav@falico.eu> wrote:
>>>>> On Mon, Nov 11, 2013 at 11:29 AM, Mark Trompell <mark@foresightlinux.org> wrote:
>>>>>> my bridge br0 doesn't get an ip from dhcp anymore after 3.11.5 and 3.4.66,
>>>>>> What information would be helpful and required to find out what's going wrong.
>>>>>
>>>>> CC netdev
>>>>>
>>>>> First thing would be to provide the network scheme. Do you use vlans?
>>>>> Which network
>>>>> cards/drivers are you using? Do you use some kind of virtualization?
>>>>> Is bonding involved?
>>>>>
>>>> Actually this is my desktop machine using kvm for a virtual machine
>>>> that uses eth0 which is connected to the bridge
>>>> which is used as interface for the host.
>>>>
>>>> $ ip addr
>>>> 2. eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast
>>>> master br0 qlen 1000
>>>> ...
>>>> 3. br0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noqueue
>>>> ...
>>>>
>>>> Anything else?
>>>
>>> Okay more about my hardware and configuration:
>>> from lspci:
>>> 00:19.0 Ethernet controller: Intel Corporation 82579V Gigabit Network
>>> Connection (rev 04)
>>>
>>> /etc/sysconfig/network-scripts/ifcfg-br0
>>> DEVICE=br0
>>> ONBOOT=yes
>>> MACADDR=00:19:99:ac:b3:24
>>> TYPE=Bridge
>>> BOOTPROTO=dhcp
>>> STP=on
>>> NM_CONTROLLED=no
>>> DELAY=0
>>>
>>> /etc/sysconfig/network-scripts/ifcfg-eth0
>>> DEVICE=eth0
>>> HWADDR=00:19:99:cd:a5:e6
>>> #BOOTPROTO=dhcp
>>> ONBOOT=yes
>>> BRIDGE=br0
>>> TYPE=Ethernet
>>> NM_CONTROLLED=no
>>>
>>>
>>>> Greetings
>>>> Mark
>>
>>
>>
>



-- 
Mark Trompell

Foresight Linux Xfce Edition
Cause your desktop should be freaking cool
(and Xfce)
