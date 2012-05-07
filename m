From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 1/4 (V3)] net: ethtool: add the EEE support
Date: Mon, 07 May 2012 07:25:03 +0200
Message-ID: <4FA75CAF.8070709@st.com>
References: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com>  <1333704559-11251-2-git-send-email-peppe.cavallaro@st.com>  <1334269598.2497.50.camel@bwh-desktop.uk.solarflarecom.com>  <4F8BB103.7020107@st.com> <4F900C08.5000906@st.com>  <1334849401.2426.73.camel@bwh-desktop.uk.solarflarecom.com>  <4F98FDCC.3040807@st.com>  <1335460660.2712.15.camel@bwh-desktop.uk.solarflarecom.com>  <4F9AA927.4080400@st.com> <4F9D07FB.1010208@broadcom.com> <1335736615.2424.42.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <yuvalmin@broadcom.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:42026 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752084Ab2EGFZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 01:25:36 -0400
In-Reply-To: <1335736615.2424.42.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben

On 4/29/2012 11:56 PM, Ben Hutchings wrote:
> On Sun, 2012-04-29 at 12:20 +0300, Yuval Mintz wrote:
>> On 04/27/2012 05:11 PM, Giuseppe CAVALLARO wrote:
>>
>>> On 4/26/2012 7:17 PM, Ben Hutchings wrote:
>>>> On Thu, 2012-04-26 at 09:48 +0200, Giuseppe CAVALLARO wrote:
>>>>> Hello Ben
>>>>>
>>>>> On 4/19/2012 5:30 PM, Ben Hutchings wrote:
>>>>> [snip]
>>>>>>> I'm changing the code for getting/setting the EEE capability and trying
>>>>>>> to follow your suggestions.
>>>>>>>
>>>>>>> The "get" will show the following things; this is a bit different of the
>>>>>>> points "a" "b" and "c" we had discussed. Maybe, this could also be a
>>>>>>> more complete (*) .
>>>>>>> The ethtool (see output below as example) could report the phy
>>>>>>> (supported/advertised/lp_advertised) and mac eee capabilities separately.
>>>>>> Sounds reasonable.
>>>>>>
>>>>>>> The "set" will be useful for some eth devices (like the stmmac) that can
>>>>>>> stop/enable internally the eee capability (at mac level).
>>>>>> I don't know much about EEE, but shouldn't the driver take care of
>>>>>> configuring the MAC for this whenever the PHY is set to advertise EEE
>>>>>> capability?
>>>>> Yes indeed this can be done at driver level. So could I definitely
>>>>> remove it from ethtool? What do you suggest?
>>>>>
>>>>> In case of the stmmac I could add a specific driver option via sys to
>>>>> enable/disable the eee and set timer.
>>>> Generally, ethtool doesn't distinguish MAC and PHY settings because they
>>>> have to be configured consistently for the device to do anything useful.
>>>> If there is some good use for enabling EEE in the MAC and not the PHY,
>>>> or vice versa, then this should be exposed in the ethtool interface.
>>>> But if not then I don't believe it needs to be in either an ethtool or a
>>>> driver-specific interface.
>>> Thanks Ben for this clarification: in case of the stmmac the option is
>>> useful to stop a timer to enter in lpi state for the tx.
>>> So it's worth having that and from ethtool.
> 
> I think I finally get it.  If we negotiate a 100BASE-TX link (or one of
> the various backplane modes) with EEE enabled, we allow the link partner
> to assert LPI but we might still not want to assert it in the transmit
> direction.  Right?  (Whereas for 1000BASE-T and 10GBASE-T this would be
> useless, since both sides must assert LPI before any transition can
> happen.)
> 
>> How will a user turn off EEE support using this implementation?
> 
> At the ethtool API level this would be done by clearing the EEE
> advertising mask.  At the command-line level there could be a shortcut
> for this, just as you can use 'autoneg on' and 'autoneg off' rather than
> specifying a mask of link modes.
> 
>> Are you suggesting a "set" that works similarly to the control of the pause
>> parameters - that is, a user could either shutdown EEE or only Tx, which
>> will mean to the driver "don't enter Tx LPI mode"?
>>
>> Keep in mind that if later an interface controlling the LPI timers would be
>> added (as a measure of user control to the power saving vs. latency issue),
>> it could make this 'partial' closure interface redundant.
>>
>> Perhaps "set" should only turn the EEE feature on/off entirely (adv. them or
>> not, since clearly the link will have to be re-established afterwards), and
>> we should have a different function that prevents entry into LPI mode in Tx
>> - one whose functionality could later on be extended.
> 
> It sounds like this might as well be included, even if not all
> drivers/hardware would allow the values to be changed.  So the command
> structure would have at least:
> 
> 1. EEE link mode supported flags (get-only)
> 2. EEE link mode advertising flags (get/set)
> 3. Ditto for link partner (get-only)
> 4. TX LPI enable flag (get/set)
> 5. TX LPI timer values (get/set but driver may reject changes)

Ok I'll try to rework all following the points above. Just a note for
the timer and point 5 below.

> But if it's not yet clear exactly what timer parameters will be useful,
> we could leave some reserved space and then later define them along with
> flags to indicate whether the driver understands them.

I can use and test the LPI timer parameters that I intends, in case of
the stmmac d.d., the values added in a mac core register. These two timers:
1) specify the minimum time for which the link-status from the PHY
   should be up. The default value 1 sec as defined in the IEEE
   standard.
2) specify the minimum time for which the MAC waits after it has
   stopped transmitting the LPI pattern to the PHY

Peppe

> 
> Ben.
> 
