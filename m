From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH net] at803x: insure minimum delay for SGMII link AN
 completion ckeck
Date: Tue, 14 Feb 2017 14:31:53 +0000
Message-ID: <AM5PR0401MB2561EFE479E6B2FCC508C9BD96580@AM5PR0401MB2561.eurprd04.prod.outlook.com>
References: <1486744943-12474-1-git-send-email-claudiu.manoil@nxp.com>
 <849590ef-2913-5c8e-56a7-a00d238d1235@neratec.com>
 <AM5PR0401MB25616E07222F4B854CB2247D96590@AM5PR0401MB2561.eurprd04.prod.outlook.com>
 <20170213173105.GE9946@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Florian Fainelli" <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0073.outbound.protection.outlook.com ([104.47.1.73]:22719
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753096AbdBNOb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 09:31:59 -0500
In-Reply-To: <20170213173105.GE9946@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Andrew Lunn [mailto:andrew@lunn.ch]
>Sent: Monday, February 13, 2017 7:31 PM
>Subject: Re: [PATCH net] at803x: insure minimum delay for SGMII link AN
>completion ckeck
>

[...]

>>
>> I can confirm that link status changes are signaled via interrupts ("phy=
_interrupt")
>> in this case.
>
>Is there a way to enable an interrupt when SGMII signalled link
>changes has happened? Maybe another interrupt enable bit somewhere?
>That would avoid having to sleep().
>

No, except for the interrupt lines coming from the external AR8033 PHYs the=
re's=20
nothing else (documentation on the SoC and board is available on nxp.com).
I think this question hints to the actual problem, that the internal SGMII =
link=20
should have a separate state (and state machine) apart from the external li=
nk's
state.  PHYLIB currently handles the state of the external link of a PHY, h=
ence=20
the aneg_done() hook should reflect the status of the external link. So, I =
think=20
there'll always be issues if the external PHY device's aneg_done() returns =
the AN=20
status of the internal SGMII link. Actually, the internal link is owned by =
an internal=20
(SoC) PHY device, TBI in this case (or something similar for other SoCs I'd=
 expect),=20
so, by a different phy device.  Moreover, the auto-negotiation on the exter=
nal link=20
is different from the AN on the internal SGMII link (different IEEE clauses=
: clause 27 vs=20
clause 37).
So, I think the way to go would be to drop the SGMII link state check from =
AR803x's
aneg_done() for now and try to address SGMII internal link potential issues=
 at SoC/MAC=20
level, on a case by case basis.

Claudiu
