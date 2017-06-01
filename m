From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Thu, 1 Jun 2017 13:45:19 +0200
Message-ID: <265ee4d4-ce24-9e0f-d7c5-fba4ed36ab96@neratec.com>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
 <20170522210927.GR29447@lunn.ch>
 <0d9b30e5-40f3-82ba-a44a-2eb25b8d3094@codeaurora.org>
 <20170522213206.GT29447@lunn.ch>
 <a8415b8b-1713-053d-41d3-2577c5a53c8b@codeaurora.org>
 <20170523160722.GC21169@lunn.ch>
 <3dc4f9cf-3172-0227-f03c-1ccfdad3e15e@codeaurora.org>
 <a87a7309-e15e-286f-08d0-83535c094358@neratec.com>
 <a88a111d-5e3a-0999-14ef-0ada06febb3f@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Timur Tabi <timur@codeaurora.org>,
        Matthias May <matthias.may@neratec.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:47917 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751056AbdFALy7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 07:54:59 -0400
In-Reply-To: <a88a111d-5e3a-0999-14ef-0ada06febb3f@codeaurora.org>
Content-Language: en-CA
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Timur, all,

sorry for being late to chime in here, as Matthias said I have been AFK while this
discussion took place.

The related patch I committed is meant to double check that the SGMII side is done
aneg when copper side is. Usually it does, but this expectation admittedly might
fail in interrupt mode. What seems to happen is: after a power-down-up cycle the
at803x restarts aneg at copper and SGMII sides. In polling mode, if you run into
the case where copper is up but the SGMII is not, you'll see the message and in
(one of) the next poll cycle(s) SGMII should be ready too and the situation
recovers. In interrupt mode, obviously once you hit into the partially done aneg,
you won't recover since no additional link-change interrupt is going to happen.

Wit that, Tamur is right claiming the double-check breaks the driver in interrupt
mode. I could think of several work-arounds to fix it, e.g.
1) check if there is an SGMII link-change interrupt source and enable it
2) when we run into partial aneg completion, temporary switch to polling mode and
back to interrupt mode when at803x_aneg_done() succeeds


Alas, we need to rewind back to whether these double-checks are required at all.
As Matthias explained, there is at least one combination of devices that have
documented issues establishing the SGMII link - in our case it was the at8031
attached to a P1010's eTSEC (errata A-004187, fixed with chip rev. 2.01). Chances
are high that our company is the only one using this exact early version of
problematic devices. Therefore, and since the problem is at ETH side, we moved our
local workarounds into the gianfar driver who on demand restarts SGMII to recover
from the stale link.

I guess we need to decide whether we generally need to handle permanent aneg
failures on the SGMII link. If we expect that it must not fail (like we assumed
until we saw it failing), I agree with Timur and support reverting of the related
commit f62265b53e. If otherwise we want this potential failure to be handled
correctly, things become arbitrary complex. Essentially, we need to handle such
PHYs as a combination of their two sides (copper + SGMII) as virtual sub-PHYs. The
phylib might support that in a future version, but for now this seems like a lot
of work required to handle a rare problem.



tl;dr: ACK with reverting f62265b53e


Cheers,
Zefir


On 05/24/2017 03:29 PM, Timur Tabi wrote:
> On 5/24/17 2:18 AM, Matthias May wrote:
>> With the patch: When the copper side is seen as up, it also checks if aneg of
>> the SGMII link is done.
>> As far as i know SGMII can not be run without aneg, since it is always Gbit with
>> aneg mandatory.
>> If SGMII aneg is not done, then, well aneg is not done and thus 0 is returned.
>>
>> Internally we have this patch extended so we don't only report that aneg is not
>> done but also reset the link.
>> Eventually aneg on the SGMII side can be completed and the link comes up.
> 
> I would really like to test this patch.
> 
>> Why do you think that frames are able to go through when aneg is reported as not
>> done by the PHY?
> 
> I have two theories:
> 
> 1. The warning message is bogus.  The link actually is okay, but the driver thinks
> that it isn't.
> 
> 2. The link is not okay, but it automatically fixes itself soon after the
> at803x_aneg_done() finishes.
> 
>> Since aneg is mandatory for SGMII this can as well be seen as "link not up", not?
> 
> The problem is that even though the link is up, the driver has returned "0", so
> the kernel thinks that autonegotiation has not finished. at803x_aneg_done() is
> never called again, and so I think the kernel is disabling the interface is some
> secret way.
> 
