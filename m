From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: Debugging Ethernet issues
Date: Mon, 14 Nov 2016 19:00:43 +0000
Message-ID: <yw1xpolxga3o.fsf@unicorn.mansr.com>
References: <5827AD4A.7010908@free.fr> <20161113030919.GA2892@lunn.ch>
        <5828C452.6050808@free.fr>
        <9d1f28a7-959b-fdde-3403-f6da5f521125@gmail.com>
        <5829BBFC.7040800@free.fr> <20161114133428.GF26710@lunn.ch>
        <5829D10F.30206@free.fr> <5829D95C.6060509@free.fr>
        <3313424a-8d45-0883-5257-ffdc250dd45b@gmail.com>
        <5829FB6F.6090106@laposte.net>
        <2187db98-dc5a-7a3c-7965-7ccbeffc0fa1@gmail.com>
        <4d4f8bca-e084-2f49-1db8-56674debaf9c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Sebastian Frias <sf84@laposte.net>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
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
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:39132 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934090AbcKNTAu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 14:00:50 -0500
In-Reply-To: <4d4f8bca-e084-2f49-1db8-56674debaf9c@gmail.com> (Florian
        Fainelli's message of "Mon, 14 Nov 2016 10:42:38 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 11/14/2016 10:20 AM, Florian Fainelli wrote:
>> On 11/14/2016 09:59 AM, Sebastian Frias wrote:
>>> On 11/14/2016 06:32 PM, Florian Fainelli wrote:
>>>> On 11/14/2016 07:33 AM, Mason wrote:
>>>>> On 14/11/2016 15:58, Mason wrote:
>>>>>
>>>>>> nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
>>>>>> vs
>>>>>> nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control off
>>>>>>
>>>>>> I'm not sure whether "flow control" is relevant...
>>>>>
>>>>> Based on phy_print_status()
>>>>> phydev->pause ? "rx/tx" : "off"
>>>>> I added the following patch.
>>>>>
>>>>> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
>>>>> index defc22a15f67..4e758c1cfa4e 100644
>>>>> --- a/drivers/net/ethernet/aurora/nb8800.c
>>>>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>>>>> @@ -667,6 +667,8 @@ static void nb8800_link_reconfigure(struct net_device *dev)
>>>>>         struct phy_device *phydev = priv->phydev;
>>>>>         int change = 0;
>>>>>  
>>>>> +       printk("%s from %pf\n", __func__, __builtin_return_address(0));
>>>>> +
>>>>>         if (phydev->link) {
>>>>>                 if (phydev->speed != priv->speed) {
>>>>>                         priv->speed = phydev->speed;
>>>>> @@ -1274,9 +1276,9 @@ static int nb8800_hw_init(struct net_device *dev)
>>>>>         nb8800_writeb(priv, NB8800_PQ2, val & 0xff);
>>>>>  
>>>>>         /* Auto-negotiate by default */
>>>>> -       priv->pause_aneg = true;
>>>>> -       priv->pause_rx = true;
>>>>> -       priv->pause_tx = true;
>>>>> +       priv->pause_aneg = false;
>>>>> +       priv->pause_rx = false;
>>>>> +       priv->pause_tx = false;
>>>>>  
>>>>>         nb8800_mc_init(dev, 0);
>>>>>  
>>>>>

[...]

>>>> And the time difference is clearly accounted for auto-negotiation time
>>>> here, as you can see it takes about 3 seconds for Gigabit Ethernet to
>>>> auto-negotiate and that seems completely acceptable and normal to me
>>>> since it is a more involved process than lower speeds.
>>>>
>>>>>
>>>>>
>>>>> OK, so now it works (by accident?) even on 100 Mbps switch, but it still
>>>>> prints "flow control rx/tx"...
>>>>
>>>> Because your link partner advertises flow control, and that's what
>>>> phydev->pause and phydev->asym_pause report (I know it's confusing, but
>>>> that's what it is at the moment).
>>>
>>> Thanks.
>>> Could you confirm that Mason's patch is correct and/or that it does not
>>> has negative side-effects?
>> 
>> The patch is not correct nor incorrect per-se, it changes the default
>> policy of having pause frames advertised by default to not having them
>> advertised by default.

I was advised to advertise flow control by default back when I was
working on the driver, and I think it makes sense to do so.

>> This influences both your Ethernet MAC and the link partner in that
>> the result is either flow control is enabled (before) or it is not
>> (with the patch). There must be something amiss if you see packet
>> loss or some kind of problem like that with an early exchange such as
>> DHCP. Flow control tend to kick in under higher packet rates (at
>> least, that's what you expect).
>> 
>>>
>>> Right now we know that Mason's patch makes this work, but we do not
>>> understand why nor its implications.
>> 
>> You need to understand why, right now, the way this problem is
>> presented, you came up with a workaround, not with the root cause or the
>> solution. What does your link partner (switch?) reports, that is, what
>> is the ethtool output when you have a link up from  your nb8800 adapter?
>
> Actually, nb8800_pause_config() seems to be doing a complete MAC/DMA
> reconfiguration when pause frames get auto-negotiated while the link is
> UP,

This is due to a silly hardware limitation.  The register containing the
flow control bits can't be written while rx is enabled.

> and it does not differentiate being called from
> ethtool::set_pauseparam or the PHYLIB adjust_link callback (which it
> probably should),

Differentiate how?

> wondering if there is a not a remote chance you can get the reply to
> arrive right when you just got signaled a link UP?

If you're attempting to send or receive things before you get the link
up notification, you shouldn't expect anything to work reliably.

-- 
Måns Rullgård
