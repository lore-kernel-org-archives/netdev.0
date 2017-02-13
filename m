From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [PATCH net] at803x: insure minimum delay for SGMII link AN
 completion ckeck
Date: Mon, 13 Feb 2017 16:35:15 +0100
Message-ID: <5afc3664-a1af-c83e-debb-0df7906c4275@neratec.com>
References: <1486744943-12474-1-git-send-email-claudiu.manoil@nxp.com>
 <849590ef-2913-5c8e-56a7-a00d238d1235@neratec.com>
 <AM5PR0401MB25616E07222F4B854CB2247D96590@AM5PR0401MB2561.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Claudiu Manoil <claudiu.manoil@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:11223 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753716AbdBMPfS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 10:35:18 -0500
In-Reply-To: <AM5PR0401MB25616E07222F4B854CB2247D96590@AM5PR0401MB2561.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/2017 02:15 PM, Claudiu Manoil wrote:
>> -----Original Message-----
>> From: Zefir Kurtisi [mailto:zefir.kurtisi@neratec.com]
>> Sent: Monday, February 13, 2017 12:16 PM
>> To: Claudiu Manoil <claudiu.manoil@nxp.com>
>> Cc: netdev@vger.kernel.org; David S. Miller <davem@davemloft.net>; Florian
>> Fainelli <f.fainelli@gmail.com>
>> Subject: Re: [PATCH net] at803x: insure minimum delay for SGMII link AN
>> completion ckeck
>>
>> On 02/10/2017 05:42 PM, Claudiu Manoil wrote:
>>> Commit: f62265b "at803x: double check SGMII side autoneg"
>>> introduced a regression for the p1010rdb board which has
>>> two of the ethernet controllers (eTSEC) connected through
>>> SGMII links to external Atheros SGMII AR8033 PHYs.
>>> The issue consists in a dead link for these ports, and is
>>> 100% reproducible on kernel 4.9 (and later):
>>>
> 
> [...]
> 
>>>
>>
>> Could you confirm that you are using PHY_HAS_INTERRUPT? In polling mode the
>> effect would be very unlikely to happen, since you'd need to run the state machine
>> exactly between the two AN stages.
>>
> 
> Hi Zefir.  Thanks for having a look at this issue.
> Yes, the phy is operating in interrupt mode.
> The phy nodes from the board's device tree have their interrupt properties set:
> http://lxr.free-electrons.com/source/arch/powerpc/boot/dts/fsl/p1010rdb-pb.dts
> 
> I can confirm that link status changes are signaled via interrupts ("phy_interrupt") 
> in this case.  And this is always desirable, right? Why would one want to waste CPU 
> cycles by polling for link status changes periodically, if it can work with interrupts.
> 
Sure, only wanted to double check, since we are polling and with that never run
(or at least never observed) into a situation where a first read fails but
subsequent ones succeed.

>> As for the 100us delay proposed, is this something Atheros suggested or is it
>> based on empirical considerations? Since ending up in a situation where the
>> double-check fails might left you with a permanent link loss, having a reliable
>> minimum required delay between first and second stage AN is essential - to me
>> 100us look quite short.
>>
> 
> The value was chosen based on experiments, so yes, it's empirical.  I don't think 
> that detailed documentation for this phy is publicly available.  I was expecting a 
> small delay and I was looking for the smallest power of 10 (10 us doesn't work).
> But I'm also expecting that the SGMII specification is imposing a minimum delay 
> between AN completion on the copper side and AN completion on the SGMII side.
> 
My bad, I assumed NXP is already part of Qualcomm and with that you had better
access to Atheros internal documentation than the typical open-source developer -
realized the merger is yet to come.

>> Same goes for the readout polling proposed: given that reading an MDIO register
>> takes ~16us (at assumed 2.5MHz MDC), delaying for 1us between reads is kind of
>> useless and ends up in storm-reading the register (and also extends the wait-time
>> by the same factor). Imo, it won't hurt to sleep for milliseconds between reads
>> here (see phy_poll_reset() for reference).
>>
> 
> I'm not fond of using udelay either, I'm also aware that the timeout loop is not 
> exactly 100 us, given the delay involved by the phy register reads, but I wanted 
> to emphasize that there needs to be a minimum delay before establishing that
> the SGMII AN is done.
> Would you mind sending a v2 patch using msleep() instead of udelay()?
> You have an idea now of the minimum delay needed in my case.
> 
Would make sense to me. It won't hurt to provide a significantly higher wait time
(e.g. 50ms) and sleep for 4ms between register reads. Since polling happens only
in the failure case, it is cheap for the typical one.

@Florian: sleeping in .aneg_done is ok, right?

> Thanks,
> Claudiu
> 

Thanks and great to hear that you are working with P1010 - that's maybe the root
cause for the workaround we are dealing with here, since the eTSEC has a known
problem with stalling SGMII link (errata A-004187). At least one more party that
might observe the issue.
