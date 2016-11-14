From: Sebastian Frias <sf84@laposte.net>
Subject: Re: Debugging Ethernet issues
Date: Mon, 14 Nov 2016 18:59:11 +0100
Message-ID: <5829FB6F.6090106@laposte.net>
References: <5827AD4A.7010908@free.fr> <20161113030919.GA2892@lunn.ch>
 <5828C452.6050808@free.fr> <9d1f28a7-959b-fdde-3403-f6da5f521125@gmail.com>
 <5829BBFC.7040800@free.fr> <20161114133428.GF26710@lunn.ch>
 <5829D10F.30206@free.fr> <5829D95C.6060509@free.fr>
 <3313424a-8d45-0883-5257-ffdc250dd45b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
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
To: Florian Fainelli <f.fainelli@gmail.com>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz29.laposte.net ([194.117.213.104]:60372 "EHLO
        smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751532AbcKNR7Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 12:59:16 -0500
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout017 (Postfix) with ESMTP id A0AFFA04829
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 18:59:13 +0100 (CET)
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout017 (Postfix) with ESMTP id 92E5DA0482D
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 18:59:13 +0100 (CET)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.laposte [10.128.63.2])
        by lpn-prd-vrout017 (Postfix) with ESMTP id 90472A04829
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 18:59:13 +0100 (CET)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
        by lpn-prd-vrin001 (Postfix) with ESMTP id 6C1B5366D6A
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 18:59:13 +0100 (CET)
In-Reply-To: <3313424a-8d45-0883-5257-ffdc250dd45b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2016 06:32 PM, Florian Fainelli wrote:
> On 11/14/2016 07:33 AM, Mason wrote:
>> On 14/11/2016 15:58, Mason wrote:
>>
>>> nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
>>> vs
>>> nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control off
>>>
>>> I'm not sure whether "flow control" is relevant...
>>
>> Based on phy_print_status()
>> phydev->pause ? "rx/tx" : "off"
>> I added the following patch.
>>
>> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
>> index defc22a15f67..4e758c1cfa4e 100644
>> --- a/drivers/net/ethernet/aurora/nb8800.c
>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>> @@ -667,6 +667,8 @@ static void nb8800_link_reconfigure(struct net_device *dev)
>>         struct phy_device *phydev = priv->phydev;
>>         int change = 0;
>>  
>> +       printk("%s from %pf\n", __func__, __builtin_return_address(0));
>> +
>>         if (phydev->link) {
>>                 if (phydev->speed != priv->speed) {
>>                         priv->speed = phydev->speed;
>> @@ -1274,9 +1276,9 @@ static int nb8800_hw_init(struct net_device *dev)
>>         nb8800_writeb(priv, NB8800_PQ2, val & 0xff);
>>  
>>         /* Auto-negotiate by default */
>> -       priv->pause_aneg = true;
>> -       priv->pause_rx = true;
>> -       priv->pause_tx = true;
>> +       priv->pause_aneg = false;
>> +       priv->pause_rx = false;
>> +       priv->pause_tx = false;
>>  
>>         nb8800_mc_init(dev, 0);
>>  
>>
>> Connected to 1000 Mbps switch:
>>
>> # time udhcpc | while read LINE; do date; echo $LINE; done
>> Thu Jan  1 00:00:22 UTC 1970
>> udhcpc (v1.22.1) started
>> Thu Jan  1 00:00:22 UTC 1970
>> Sending discover...
>> [   24.565346] nb8800_link_reconfigure from phy_state_machine
>> Thu Jan  1 00:00:25 UTC 1970
>> Sending discover...
>> [   26.575402] nb8800_link_reconfigure from phy_state_machine
>> [   26.580972] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
>> Thu Jan  1 00:00:28 UTC 1970
>> Sending discover...
>> Thu Jan  1 00:00:29 UTC 1970
>> Sending select for 172.27.64.58...
>> Thu Jan  1 00:00:29 UTC 1970
>> Lease of 172.27.64.58 obtained, lease time 604800
>> Thu Jan  1 00:00:29 UTC 1970
>> deleting routers
>> Thu Jan  1 00:00:29 UTC 1970
>> adding dns 172.27.0.17
>>
>> real    0m7.388s
>> user    0m0.040s
>> sys     0m0.090s
>>
>>
>>
>> Connected to 100 Mbps switch:
>>
>> # time udhcpc | while read LINE; do date; echo $LINE; done
>> Thu Jan  1 00:00:14 UTC 1970
>> udhcpc (v1.22.1) started
>> Thu Jan  1 00:00:15 UTC 1970
>> Sending discover...
>> [   16.968621] nb8800_link_reconfigure from phy_state_machine
>> [   17.975359] nb8800_link_reconfigure from phy_state_machine
>> [   17.980923] nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
>> Thu Jan  1 00:00:18 UTC 1970
>> Sending discover...
>> Thu Jan  1 00:00:19 UTC 1970
>> Sending select for 172.27.64.58...
>> Thu Jan  1 00:00:19 UTC 1970
>> Lease of 172.27.64.58 obtained, lease time 604800
>> Thu Jan  1 00:00:19 UTC 1970
>> deleting routers
>> Thu Jan  1 00:00:19 UTC 1970
>> adding dns 172.27.0.17
>>
>> real    0m4.355s
>> user    0m0.043s
>> sys     0m0.083s
>>
> 
> And the time difference is clearly accounted for auto-negotiation time
> here, as you can see it takes about 3 seconds for Gigabit Ethernet to
> auto-negotiate and that seems completely acceptable and normal to me
> since it is a more involved process than lower speeds.
> 
>>
>>
>> OK, so now it works (by accident?) even on 100 Mbps switch, but it still
>> prints "flow control rx/tx"...
> 
> Because your link partner advertises flow control, and that's what
> phydev->pause and phydev->asym_pause report (I know it's confusing, but
> that's what it is at the moment).

Thanks.
Could you confirm that Mason's patch is correct and/or that it does not
has negative side-effects?

Right now we know that Mason's patch makes this work, but we do not understand
why nor its implications.

> 
>>
>> # ethtool -a eth0
>> Pause parameters for eth0:
>> Autonegotiate:  off
>> RX:             off
>> TX:             off
>>
>> These values make sense considering my changes in the driver.
>>
>> Are 100 Mbps switches supposed to support these pause features,
>> and are they supposed to be able to auto-negotiate them?
> 
> Yes, switches can support flow control aka pause frames, and unless they
> are configurable, they typically advertise what their EEPROM has defined
> for them, so most likely the full auto-negotiated spectrum:
> 10/100/1000Mbps and support for flow control, but your mileage may vary
> of course.
> 
