From: Mark Trompell <mark@foresightlinux.org>
Subject: Re: bridge not getting ip since 3.11.5 and 3.4.66
Date: Tue, 26 Nov 2013 14:27:51 +0100
Message-ID: <CAEPa5ym4HWK9vo_BYYZbQsGZXG9r2kfYR2rFGaYjjJqDfkf2uQ@mail.gmail.com>
References: <CAEPa5ym2Xz3F19fJJqNawkRLOKk6Ao6oXrzSrHU051V7p=9otA@mail.gmail.com>
	<CAE3RKNng9A6Bp7wa4+6iCprwEQpzGueagLc8iob+aFabJW4nnw@mail.gmail.com>
	<CAEPa5y=tgdGpDMBGY0ijyWSgQ0m5SZW8EMP072OF=sZZUjqN1g@mail.gmail.com>
	<CAEPa5ym0+-_Q9zUidDfE2SD7XYZxAqqEUByBkkH1ZOmh9rmFHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, herbert@gondor.apana.org.au
To: Veaceslav Falico <veaceslav@falico.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:59385 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533Ab3KZN1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 08:27:53 -0500
Received: by mail-bk0-f51.google.com with SMTP id 6so2536385bkj.24
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 05:27:51 -0800 (PST)
In-Reply-To: <CAEPa5ym0+-_Q9zUidDfE2SD7XYZxAqqEUByBkkH1ZOmh9rmFHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Answering my own mail again and even top posting, sorry, but makes
more sense to me in that case).
I reverted bridge related patches from 3.11.5 and it boils down to
commit 0e308361d7ca0bf8b23fd472b90aae0fb10a1c32
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Thu Sep 12 17:12:05 2013 +1000

    bridge: Clamp forward_delay when enabling STP

    [ Upstream commit be4f154d5ef0ca147ab6bcd38857a774133f5450 ]

    At some point limits were added to forward_delay.  However, the
    limits are only enforced when STP is enabled.  This created a
    scenario where you could have a value outside the allowed range
    while STP is disabled, which then stuck around even after STP
    is enabled.

    This patch fixes this by clamping the value when we enable STP.

    I had to move the locking around a bit to ensure that there is
    no window where someone could insert a value outside the range
    while we're in the middle of enabling STP.

Causing the issue for me. Reverting that patch and br0 comes up again
and gets an ip.

On Tue, Nov 12, 2013 at 11:57 AM, Mark Trompell <mark@foresightlinux.org> wrote:
> On Mon, Nov 11, 2013 at 1:52 PM, Mark Trompell <mark@foresightlinux.org> wrote:
>> On Mon, Nov 11, 2013 at 12:07 PM, Veaceslav Falico <veaceslav@falico.eu> wrote:
>>> On Mon, Nov 11, 2013 at 11:29 AM, Mark Trompell <mark@foresightlinux.org> wrote:
>>>> my bridge br0 doesn't get an ip from dhcp anymore after 3.11.5 and 3.4.66,
>>>> What information would be helpful and required to find out what's going wrong.
>>>
>>> CC netdev
>>>
>>> First thing would be to provide the network scheme. Do you use vlans?
>>> Which network
>>> cards/drivers are you using? Do you use some kind of virtualization?
>>> Is bonding involved?
>>>
>> Actually this is my desktop machine using kvm for a virtual machine
>> that uses eth0 which is connected to the bridge
>> which is used as interface for the host.
>>
>> $ ip addr
>> 2. eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast
>> master br0 qlen 1000
>> ...
>> 3. br0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noqueue
>> ...
>>
>> Anything else?
>
> Okay more about my hardware and configuration:
> from lspci:
> 00:19.0 Ethernet controller: Intel Corporation 82579V Gigabit Network
> Connection (rev 04)
>
> /etc/sysconfig/network-scripts/ifcfg-br0
> DEVICE=br0
> ONBOOT=yes
> MACADDR=00:19:99:ac:b3:24
> TYPE=Bridge
> BOOTPROTO=dhcp
> STP=on
> NM_CONTROLLED=no
> DELAY=0
>
> /etc/sysconfig/network-scripts/ifcfg-eth0
> DEVICE=eth0
> HWADDR=00:19:99:cd:a5:e6
> #BOOTPROTO=dhcp
> ONBOOT=yes
> BRIDGE=br0
> TYPE=Ethernet
> NM_CONTROLLED=no
>
>
>> Greetings
>> Mark



-- 
Mark Trompell

Foresight Linux Xfce Edition
Cause your desktop should be freaking cool
(and Xfce)
