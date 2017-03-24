From: Maxime Morin <maxime.morin@vitec.com>
Subject: Re: Problem: net: mvneta: auto-negotiation with disconnected network
 cable
Date: Fri, 24 Mar 2017 14:39:54 +0000
Message-ID: <AM4PR0501MB2708DA6340C51F283C2E4AF7943E0@AM4PR0501MB2708.eurprd05.prod.outlook.com>
References: <DB6PR0501MB2712340C8CDC37F3038766AD943C0@DB6PR0501MB2712.eurprd05.prod.outlook.com>
 <c5e143f0-f6b4-ff74-4239-e64ca025821b@list.ru>
 <AM4PR0501MB270859E18A4D7F73F297AF64943F0@AM4PR0501MB2708.eurprd05.prod.outlook.com>,<1fbc5e19-b8d9-86bc-8683-e433977e73f5@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>
To: Stas Sergeev <stsp@list.ru>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0051.outbound.protection.outlook.com ([104.47.1.51]:14266
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S964848AbdCXOj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 10:39:58 -0400
In-Reply-To: <1fbc5e19-b8d9-86bc-8683-e433977e73f5@list.ru>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>From: Stas Sergeev <stsp@list.ru>
>
>23.03.2017 14:30, Maxime Morin =D0=C9=DB=C5=D4:
>> Hi,
>> Thank you very much for your help and your reactivity! See my answer bel=
low:
>>
>>> 22.03.2017 16:23, Maxime Morin =D0=C9=DB=C5=D4:
>>>> Hi all,
>>>>
>>>> I work on an embedded platform based on the Marvell Armada 88F6707, th=
at is connected to a Marvell Alaska 88E1512 ethernet transceiver. A defect =
has appeared recently, and it turns out to be a regression on the network p=
art. There is a complete lost of the network when following these steps:
>>>>       1) boot the board with the network cable disconnected
>>>>       2) run the following commands (or equivalent):
>>>>           ip link set eth0 up
>>>>           ip addr add 10.0.0.80/24 dev eth0
>>>>           ethtool -s eth0 autoneg on #this is the command that really =
breaks the network
>>> Why do you call it a regression, if previously
>>> this command did nothing at all?
>> I called that a regression because we still pass through the function ph=
y_ethtool_sset(), which I though was also doing something about the auto-ne=
gotiation. But apparently not.
>It does, but with mdio.
>But in the MAC driver we have another autoneg
>now, which is a great confusion. mvneta_set_autoneg()
>could have been named mvneta_set_inband_autoneg(),
>which would already help a lot. If you prepare the patch-set,
>you can include such renaming
>
>>>> I did a "git bisect" to find when the regression was introduced, becau=
se it previously worked with kernel 4.4, but not with the recent ones. The =
commit that made appear the issue is this one: https://git.kernel.org/pub/s=
cm/linux/kernel/git/torvalds/linux.git/commit/?id=3D0c0744fc1dd5b
>>>> If I remove on mvneta.c the part that was added on this commit on the =
function mvneta_ethtool_set_link_ksettings (mvneta_ethtool_set_settings at =
that time), I do not have the issue, but I can't call that a fix...
>>>> So, could it be a driver issue, or maybe a wrong configuration somewhe=
re? If you need additional information to reproduce the problem please ask =
me, I will be as responsive as possible.
>>> It seems mvneta_set_autoneg() does some non-symmetric
>>> things. It clears
>>> MVNETA_GMAC_FORCE_LINK_PASS |
>>> MVNETA_GMAC_FORCE_LINK_DOWN |
>>> MVNETA_GMAC_AN_FLOW_CTRL_EN
>>> when enabling autoneg, and does not restore these flags
>>> when disabling it. Try to make it to set or to restore these
>>> flags and see if that makes "ethtool -s eth0 autoneg off" to
>>> get the network back alive> .
>> As you suggested, I just set these three flags when the function is call=
ed with "enable" set to 0. And it works!
>Am I right that it works only when you set autoneg
>to "off", while "on" still does not give you any link detect?
>So this is a partial fix, right?
No. It actually works for both modes in this case.

>> Actually, I did not even have to set autoneg to off. When the module is =
probed, the default param are applied (mvneta_defaults_set()), and mvneta_s=
et_autoneg() is called with "enable" to 0, and it seems to fix everything.
>It turns off SGMII-specific autoned and starts using
>mdio autoneg instead... a great confusion.
>
>> I tested it then, by setting autoneg to off/on, booting with or without =
the cable plugged, and I failed to break it. It seems to be fixed. Should I=
 submit a patch? (would be the first time...)
>After looking up my other patches to this driver, I
>can see that
>
>MVNETA_GMAC_FORCE_LINK_PASS |
>MVNETA_GMAC_FORCE_LINK_DOWN
>
>are left cleared willingly. I suspect that MVNETA_GMAC_AN_FLOW_CTRL_EN
>breaks things for you. Could you please try with setting
>back only this flag?
I tested it, but not only this case. There are three flags, so 8 possibilit=
ies (and already 2 tested), so I tested all of them one by one.
And it shows that:
- when MVNETA_GMAC_FORCE_LINK_PASS is not set,
no matter the values of MVNETA_GMAC_FORCE_LINK_{PASS,DOWN}, the issue is re=
produced
- when MVNETA_GMAC_FORCE_LINK_PASS is set,
no matter the values of MVNETA_GMAC_FORCE_LINK_{PASS,DOWN}, the network wor=
ks (autoneg set off/on, booting with cable plugged/unplugged, etc)
