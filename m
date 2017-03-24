From: Stas Sergeev <stsp@list.ru>
Subject: Re: Problem: net: mvneta: auto-negotiation with disconnected network
 cable
Date: Sat, 25 Mar 2017 00:26:49 +0300
Message-ID: <75a7933f-a8ee-ed07-5912-1ce3334556f8@list.ru>
References: <DB6PR0501MB2712340C8CDC37F3038766AD943C0@DB6PR0501MB2712.eurprd05.prod.outlook.com>
 <c5e143f0-f6b4-ff74-4239-e64ca025821b@list.ru>
 <AM4PR0501MB270859E18A4D7F73F297AF64943F0@AM4PR0501MB2708.eurprd05.prod.outlook.com>
 <1fbc5e19-b8d9-86bc-8683-e433977e73f5@list.ru>
 <AM4PR0501MB2708DA6340C51F283C2E4AF7943E0@AM4PR0501MB2708.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>
To: Maxime Morin <maxime.morin@vitec.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp54.i.mail.ru ([217.69.128.34]:58122 "EHLO smtp54.i.mail.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753675AbdCXV06 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 17:26:58 -0400
In-Reply-To: <AM4PR0501MB2708DA6340C51F283C2E4AF7943E0@AM4PR0501MB2708.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

24.03.2017 17:39, Maxime Morin пишет:
>>>>> I did a "git bisect" to find when the regression was introduced, because it previously worked with kernel 4.4, but not with the recent ones. The commit that made appear the issue is this one: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=0c0744fc1dd5b
>>>>> If I remove on mvneta.c the part that was added on this commit on the function mvneta_ethtool_set_link_ksettings (mvneta_ethtool_set_settings at that time), I do not have the issue, but I can't call that a fix...
>>>>> So, could it be a driver issue, or maybe a wrong configuration somewhere? If you need additional information to reproduce the problem please ask me, I will be as responsive as possible.
>>>> It seems mvneta_set_autoneg() does some non-symmetric
>>>> things. It clears
>>>> MVNETA_GMAC_FORCE_LINK_PASS |
>>>> MVNETA_GMAC_FORCE_LINK_DOWN |
>>>> MVNETA_GMAC_AN_FLOW_CTRL_EN
>>>> when enabling autoneg, and does not restore these flags
>>>> when disabling it. Try to make it to set or to restore these
>>>> flags and see if that makes "ethtool -s eth0 autoneg off" to
>>>> get the network back alive> .
>>> As you suggested, I just set these three flags when the function is called with "enable" set to 0. And it works!
>> Am I right that it works only when you set autoneg
>> to "off", while "on" still does not give you any link detect?
>> So this is a partial fix, right?
> No. It actually works for both modes in this case.
You did something unexpected, didn't you?
The idea was to only change the "!enable" case in
mvneta_set_autoneg() to be more symmetric with
the "enable" case, like restoring the flags. You
likely changed both cases. Could you please change
only the "!enable" case and see what flags needs
to be set there for "off" to work? This should leave
"on" case still disfunctional for you, but one step at
a time.

>>> Actually, I did not even have to set autoneg to off. When the module is probed, the default param are applied (mvneta_defaults_set()), and mvneta_set_autoneg() is called with "enable" to 0, and it seems to fix everything.
>> It turns off SGMII-specific autoned and starts using
>> mdio autoneg instead... a great confusion.
>>
>>> I tested it then, by setting autoneg to off/on, booting with or without the cable plugged, and I failed to break it. It seems to be fixed. Should I submit a patch? (would be the first time...)
>> After looking up my other patches to this driver, I
>> can see that
>>
>> MVNETA_GMAC_FORCE_LINK_PASS |
>> MVNETA_GMAC_FORCE_LINK_DOWN
>>
>> are left cleared willingly. I suspect that MVNETA_GMAC_AN_FLOW_CTRL_EN
>> breaks things for you. Could you please try with setting
>> back only this flag?
> I tested it, but not only this case. There are three flags, so 8 possibilities (and already 2 tested), so I tested all of them one by one.
> And it shows that:
> - when MVNETA_GMAC_FORCE_LINK_PASS is not set,
> no matter the values of MVNETA_GMAC_FORCE_LINK_{PASS,DOWN}, the issue is reproduced
There are 2 problems, one with "on" and one with "off".
Since it is unclear which one do you mention, lets first
concentrate on the "off" case.
