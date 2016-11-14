From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Debugging Ethernet issues
Date: Mon, 14 Nov 2016 13:00:13 -0800
Message-ID: <1fd492b4-3c32-7939-791c-56cf6d8c0078@gmail.com>
References: <5827AD4A.7010908@free.fr> <20161113030919.GA2892@lunn.ch>
 <5828C452.6050808@free.fr> <9d1f28a7-959b-fdde-3403-f6da5f521125@gmail.com>
 <5829BBFC.7040800@free.fr> <20161114133428.GF26710@lunn.ch>
 <5829D10F.30206@free.fr> <5829D95C.6060509@free.fr>
 <3313424a-8d45-0883-5257-ffdc250dd45b@gmail.com>
 <5829FB6F.6090106@laposte.net>
 <2187db98-dc5a-7a3c-7965-7ccbeffc0fa1@gmail.com> <582A1E3F.8040908@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Sebastian Frias <sf84@laposte.net>, Andrew Lunn <andrew@lunn.ch>,
        netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Zach Brown <zach.brown@ni.com>,
        Shaohui Xie <shaohui.xie@nxp.com>,
        Tim Beale <tim.beale@alliedtelesis.co.nz>,
        Brian Hill <brian@houston-radar.com>,
        Vince Bridgers <vbridgers2013@gmail.com>,
        Balakumaran Kannan <kumaran.4353@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Kirill Kapranov <kapranoff@inbox.ru>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35176 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936214AbcKNVAR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 16:00:17 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so9830828pga.2
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 13:00:16 -0800 (PST)
In-Reply-To: <582A1E3F.8040908@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2016 12:27 PM, Mason wrote:
> On 14/11/2016 19:20, Florian Fainelli wrote:
> 
>> On 11/14/2016 09:59 AM, Sebastian Frias wrote:
>>
>>> Could you confirm that Mason's patch is correct and/or that it does not
>>> has negative side-effects?
>>
>> The patch is not correct nor incorrect per-se, it changes the default
>> policy of having pause frames advertised by default to not having them
>> advertised by default. This influences both your Ethernet MAC and the
>> link partner in that the result is either flow control is enabled
>> (before) or it is not (with the patch). There must be something amiss if
>> you see packet loss or some kind of problem like that with an early
>> exchange such as DHCP. Flow control tend to kick in under higher packet
>> rates (at least, that's what you expect).
> 
> Did you note that, without the change under discussion (i.e. with
> the eth driver as it is upstream), when the board is connected to
> a 100 Mbps switch, then *nothing* works *systematically (no ping,
> no DHCP; are there other relevant low-level network tools?).

No I missed that, way too many emails, really. So how about you compare
the register settings that could be (that is, all that could be modified
by the PHYLIB adjust_link function) and try to spot where things could
go wrong? Any other register that can be influenced by the link speed?

It seems like a possible (yet after re-reading, very unlikely) scenario,
considering that priv->speed, priv->duplex and priv->link are initially
zero-initialized (because nb8800_priv is zero initialized) may not force
a correct link transition and a full MAC reconfiguration in
nb8800_link_reconfigure() where some of the cached values are used.

NB: you will see most drivers initialize the previous link, speed,
duplex values to -1, because those are outside of the range of values
that PHYLIB would assign to phydev->{link,duplex,speed}, and therefore,
this is guaranteed to make the adjust_link callback that tries to
minimize these settings to force a transition.

> 
> Also, maybe this comment was lost in my own noise:
> 
> If I manually set the link up, then down, then run udhcpc
> => then nothing works, as if something is wedged somewhere
> (a kernel thread gets borked by a race condition?)

Well then start seriously debugging the problem: firs thing you need to
check is is the RUNNING flag set on the interface (which indicates a
carrier on?) without that, the networking stack won't even send packets.
If it is not set, why is not it set? Did nb8800_mac_config() get called
in the first place to configure the MAC wrt. the link settings?

When you transmit, do transmit counters increase? That would indicate
the TX DMA does its job. When transmission occurs, it is successful or
is it reporting errors? If the PHY supports it, can you access PHY
counters and look for success/error counters changing? Finally, try to
put another golden (working) host and if your switch supports it,
configure port mirroring to look at packets. If the switch does not
support it, then try different link partners.

> 
> Could not advertising pause frames result in making such a
> race condition impossible? (I don't really believe in a race,
> due to the 100% nature of the problem.)
> 
>>> Right now we know that Mason's patch makes this work, but we do not understand
>>> why nor its implications.
>>
>> You need to understand why, right now, the way this problem is
>> presented, you came up with a workaround, not with the root cause or the
>> solution. What does your link partner (switch?) reports, that is, what
>> is the ethtool output when you have a link up from your nb8800 adapter?
> 
> Isn't that what ethtool -a eth0 prints?

No, ethtool -a prints the local pause settings.

> How do I get the link partner information?

ethtool eth0:

# ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Supported pause frame use: Symmetric Receive-only
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Link partner advertised link modes:  10baseT/Half 10baseT/Full
                                             100baseT/Half 100baseT/Full

	^======================

        Link partner advertised pause frame use: Symmetric
        Link partner advertised auto-negotiation: Yes

	^========================

        Speed: 100Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: gs
        Wake-on: d
        SecureOn password: 00:00:00:00:00:00
        Current message level: 0x00000007 (7)
                               drv probe link
        Link detected: yes
#


> Just ethtool eth0?

Yes, just that.
-- 
Florian
