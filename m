From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH net] at803x: insure minimum delay for SGMII link AN
 completion ckeck
Date: Mon, 13 Feb 2017 13:15:32 +0000
Message-ID: <AM5PR0401MB25616E07222F4B854CB2247D96590@AM5PR0401MB2561.eurprd04.prod.outlook.com>
References: <1486744943-12474-1-git-send-email-claudiu.manoil@nxp.com>
 <849590ef-2913-5c8e-56a7-a00d238d1235@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50078.outbound.protection.outlook.com ([40.107.5.78]:39088
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751950AbdBMNPg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 08:15:36 -0500
In-Reply-To: <849590ef-2913-5c8e-56a7-a00d238d1235@neratec.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Zefir Kurtisi [mailto:zefir.kurtisi@neratec.com]
>Sent: Monday, February 13, 2017 12:16 PM
>To: Claudiu Manoil <claudiu.manoil@nxp.com>
>Cc: netdev@vger.kernel.org; David S. Miller <davem@davemloft.net>; Florian
>Fainelli <f.fainelli@gmail.com>
>Subject: Re: [PATCH net] at803x: insure minimum delay for SGMII link AN
>completion ckeck
>
>On 02/10/2017 05:42 PM, Claudiu Manoil wrote:
>> Commit: f62265b "at803x: double check SGMII side autoneg"
>> introduced a regression for the p1010rdb board which has
>> two of the ethernet controllers (eTSEC) connected through
>> SGMII links to external Atheros SGMII AR8033 PHYs.
>> The issue consists in a dead link for these ports, and is
>> 100% reproducible on kernel 4.9 (and later):
>>

[...]

>>
>
>Could you confirm that you are using PHY_HAS_INTERRUPT? In polling mode th=
e
>effect would be very unlikely to happen, since you'd need to run the state=
 machine
>exactly between the two AN stages.
>

Hi Zefir.  Thanks for having a look at this issue.
Yes, the phy is operating in interrupt mode.
The phy nodes from the board's device tree have their interrupt properties =
set:
http://lxr.free-electrons.com/source/arch/powerpc/boot/dts/fsl/p1010rdb-pb.=
dts

I can confirm that link status changes are signaled via interrupts ("phy_in=
terrupt")=20
in this case.  And this is always desirable, right? Why would one want to w=
aste CPU=20
cycles by polling for link status changes periodically, if it can work with=
 interrupts.

>As for the 100us delay proposed, is this something Atheros suggested or is=
 it
>based on empirical considerations? Since ending up in a situation where th=
e
>double-check fails might left you with a permanent link loss, having a rel=
iable
>minimum required delay between first and second stage AN is essential - to=
 me
>100us look quite short.
>

The value was chosen based on experiments, so yes, it's empirical.  I don't=
 think=20
that detailed documentation for this phy is publicly available.  I was expe=
cting a=20
small delay and I was looking for the smallest power of 10 (10 us doesn't w=
ork).
But I'm also expecting that the SGMII specification is imposing a minimum d=
elay=20
between AN completion on the copper side and AN completion on the SGMII sid=
e.

>Same goes for the readout polling proposed: given that reading an MDIO reg=
ister
>takes ~16us (at assumed 2.5MHz MDC), delaying for 1us between reads is kin=
d of
>useless and ends up in storm-reading the register (and also extends the wa=
it-time
>by the same factor). Imo, it won't hurt to sleep for milliseconds between =
reads
>here (see phy_poll_reset() for reference).
>

I'm not fond of using udelay either, I'm also aware that the timeout loop i=
s not=20
exactly 100 us, given the delay involved by the phy register reads, but I w=
anted=20
to emphasize that there needs to be a minimum delay before establishing tha=
t
the SGMII AN is done.
Would you mind sending a v2 patch using msleep() instead of udelay()?
You have an idea now of the minimum delay needed in my case.

Thanks,
Claudiu
