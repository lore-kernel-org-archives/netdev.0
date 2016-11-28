From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/3] ethtool: (uapi) Add ETHTOOL_PHY_LOOPBACK to
 PHY tunables
Date: Mon, 28 Nov 2016 13:01:10 -0800
Message-ID: <fabb91cd-9fc5-d935-727e-ff57e441e919@gmail.com>
References: <1480339472-5823-1-git-send-email-allan.nielsen@microsemi.com>
 <1480339472-5823-2-git-send-email-allan.nielsen@microsemi.com>
 <20161128141410.GF4379@lunn.ch> <20161128192306.GA11474@microsemi.com>
 <20161128202114.GM17704@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, raju.lakkaraju@microsemi.com
To: Andrew Lunn <andrew@lunn.ch>,
        "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:32793 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753148AbcK1VBN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:01:13 -0500
Received: by mail-pg0-f68.google.com with SMTP id 3so14110705pgd.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 13:01:12 -0800 (PST)
In-Reply-To: <20161128202114.GM17704@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 12:21 PM, Andrew Lunn wrote:
> On Mon, Nov 28, 2016 at 08:23:06PM +0100, Allan W. Nielsen wrote:
>> Hi Andrew and Florian,
>>
>> On 28/11/16 15:14, Andrew Lunn wrote:
>>> On Mon, Nov 28, 2016 at 02:24:30PM +0100, Allan W. Nielsen wrote:
>>>> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
>>>>
>>>> 3 types of PHY loopback are supported.
>>>> i.e. Near-End Loopback, Far-End Loopback and External Loopback.
>>> Is this integrated with ethtool --test? You only want the PHY to go
>>> into loopback mode when running ethtool --test external_lb or maybe
>>> ethtool --test offline.
>> There are other use-cases for enabling PHY loopback:
>>
>> 1) If the PHY is connected to a switch then a loop-port is sometime
>>    used to "force/enable" one or more extra pass through the switch
>>    core. This "hack" can sometime be used to achieve new functionality
>>    with existing silicon.
> 
> With Linux, switches are managed via switchdev, or DSA. You will have
> to teach this infrastructure that something really odd is going on
> with one of its ports before you do anything like this in the PHY
> layer. I suggest you leave this use case alone until somebody
> really-really wants it. From my knowledge of the Marvell DSA driver,
> this is not easy.

Agree with Andrew here, this particular use case with switches does not
need to be solved now, but if we imagine we need to support that,
chances are that we will want the network device as a configuration
entry point, more than the PHY device itself.

> 
>> 2) Existing user-space application may expect to be able to do the
>>    testing on its own (generate/validate the test traffic).
> 
> Please can you reference some existing user-space application and the
> kernel API it uses to put the PHY into loopback mode?
> 
>> We are always happy to integrate with any existing functionality, but
>> as I understand "ethtool --test" then intention is to perform a test
>> and then bring back the PHY in to a "normal" state (I may be
>> wrong...).
> 
> Correct.
> 
>> The idea with this patch is to allow configuring loopback more
>> "permanently" (userspace can decide when to activate and when to
>> de-activate). I should properly have made that clear in the cover
>> letter.
> 
> Leaving it in loopback is a really bad idea. I've spent days once
> working out why an Ethernet did not work. Turned out the PHY powered
> up in loopback mode, and the embedded OS running on it did not
> initialise it to sensible defaults on probe. Packets we going out,
> dhcp server was replying but all incoming packets were discarded.
> 
> It is really not obvious when everything looks O.K, but nothing works,
> because the PHY is in loopback. There needs to be a big red flag to
> warn you.
> 
> If you really do what to do this, you should look at NETIF_F_LOOPBACK
> and consider how this concept can be applied at the PHY, not the MAC.
> But you need the full concept, so you see things like:
> 
> 2: eth0: <PHY_LOOPBACK,BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
>     link/ether 80:ee:73:83:60:27 brd ff:ff:ff:ff:ff:ff
> 
> Humm, i've no idea how you actually enable the MAC loopback
> NETIF_F_LOOPBACK represents. I don't see anything with ip link set.

I am afraid you lost me on this, NETIF_F_LOOPBACK is a netdev_features_t
bit, so it tells ethtool that this is a potential feature to be turned
on with ethtool -K <iface>. The semantics of this loopack feature are
not defined AFAICT, but a reasonable behavior from the driver is to put
itself in a mode where packets send by a socket-level application are
looped through the Ethernet adapter itself. Whether this happens at the
DMA level, the MII signals, or somewhere in the PHY, is driver specific
unfortunately.

Now, there is another way to toggle a loopback for a given Ethernet
adapter which is to actually set IFF_LOOPBACK in dev->flags for this
interface. Some drivers seem to be able to properly react to that as
well, although I see no way this can be done looking at the iproute2 or
ifconfig man pages..
-- 
Florian
