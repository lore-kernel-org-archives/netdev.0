From: Stas Sergeev <stsp@list.ru>
Subject: Re: Problem: net: mvneta: auto-negotiation with disconnected network
 cable
Date: Thu, 23 Mar 2017 00:34:51 +0300
Message-ID: <c5e143f0-f6b4-ff74-4239-e64ca025821b@list.ru>
References: <DB6PR0501MB2712340C8CDC37F3038766AD943C0@DB6PR0501MB2712.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>
To: Maxime Morin <maxime.morin@vitec.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback3.mail.ru ([94.100.181.189]:38202 "EHLO
        fallback3.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751606AbdCVV4b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:56:31 -0400
Received: from smtp46.i.mail.ru (smtp46.i.mail.ru [94.100.177.106])
        by fallback3.mail.ru (mPOP.Fallback_MX) with ESMTP id B27B72F3A5DB
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 00:35:04 +0300 (MSK)
In-Reply-To: <DB6PR0501MB2712340C8CDC37F3038766AD943C0@DB6PR0501MB2712.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

22.03.2017 16:23, Maxime Morin пишет:
> Hi all,
>
> I work on an embedded platform based on the Marvell Armada 88F6707, that is connected to a Marvell Alaska 88E1512 ethernet transceiver. A defect has appeared recently, and it turns out to be a regression on the network part. There is a complete lost of the network when following these steps:
>      1) boot the board with the network cable disconnected
>      2) run the following commands (or equivalent):
>          ip link set eth0 up
>          ip addr add 10.0.0.80/24 dev eth0
>          ethtool -s eth0 autoneg on #this is the command that really breaks the network
Why do you call it a regression, if previously
this command did nothing at all?

>      3) plug the network cable
>          => there is no network, and no way to have it back except by rebooting
> If I do not launch the "ethtool" command, when I plug the network cable it works, so it really seems to be related to the auto-negotiation set to "on" when the network cable has never been connected.
So if you do that with the cable plugged it, there
is no breakage?
When you do "ethtool -s eth0 autoneg off" it doesn't
revive?

> I did a "git bisect" to find when the regression was introduced, because it previously worked with kernel 4.4, but not with the recent ones. The commit that made appear the issue is this one: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=0c0744fc1dd5b
> If I remove on mvneta.c the part that was added on this commit on the function mvneta_ethtool_set_link_ksettings (mvneta_ethtool_set_settings at that time), I do not have the issue, but I can't call that a fix...
> So, could it be a driver issue, or maybe a wrong configuration somewhere? If you need additional information to reproduce the problem please ask me, I will be as responsive as possible.
It seems mvneta_set_autoneg() does some non-symmetric
things. It clears
MVNETA_GMAC_FORCE_LINK_PASS |
MVNETA_GMAC_FORCE_LINK_DOWN |
MVNETA_GMAC_AN_FLOW_CTRL_EN
when enabling autoneg, and does not restore these flags
when disabling it. Try to make it to set or to restore these
flags and see if that makes "ethtool -s eth0 autoneg off" to
get the network back alive.
