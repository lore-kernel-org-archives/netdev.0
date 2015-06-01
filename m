From: Arun Parameswaran <aparames@broadcom.com>
Subject: Re: [PATCH 1/1] net: core: 'ethtool' issue with querying phy settings
Date: Mon, 1 Jun 2015 14:41:43 -0700
Message-ID: <556CD197.8070401@broadcom.com>
References: <1432157730-26865-2-git-send-email-aparames@broadcom.com>	 <20150522.161511.1791346966770946099.davem@davemloft.net>	 <1433102046.6319.103.camel@decadent.org.uk>	 <20150531.171940.1635713770956335110.davem@davemloft.net> <1433181931.6319.176.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<bcm-kernel-feedback-list@broadcom.com>, <rjui@broadcom.com>,
	<sbranden@broadcom.com>, <jdzheng@broadcom.com>,
	<aparames@broadcom.com>
To: Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:37065 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbbFAVlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 17:41:47 -0400
In-Reply-To: <1433181931.6319.176.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-06-01 11:05 AM, Ben Hutchings wrote:
> On Sun, 2015-05-31 at 17:19 -0700, David Miller wrote:
>> From: Ben Hutchings <ben@decadent.org.uk>
>> Date: Sun, 31 May 2015 20:54:06 +0100
>>
>>> On Fri, 2015-05-22 at 16:15 -0400, David Miller wrote:
>>>> From: Arun Parameswaran <aparames@broadcom.com>
>>>> Date: Wed, 20 May 2015 14:35:30 -0700
>>>>
>>>>> When trying to configure the settings for PHY1, using commands
>>>>> like 'ethtool -s eth0 phyad 1 speed 100', the 'ethtool' seems to
>>>>> modify other settings apart from the speed of the PHY1, in the
>>>>> above case.
>>>>>
>>>>> The ethtool seems to query the settings for PHY0, and use this
>>>>> as the base to apply the new settings to the PHY1. This is
>>>>> causing the other settings of the PHY 1 to be wrongly
>>>>> configured.
>>>>>
>>>>> The issue is caused by the '_ethtool_get_settings()' API, which
>>>>> gets called because of the 'ETHTOOL_GSET' command, is clearing
>>>>> the 'cmd' pointer (of type 'struct ethtool_cmd') by calling
>>>>> memset. This clears all the parameters (if any) passed for the
>>>>> 'ETHTOOL_GSET' cmd. So the driver's callback is always invoked
>>>>> with 'cmd->phy_address' as '0'.
>>>>>
>>>>> The '_ethtool_get_settings()' is called from other files in the
>>>>> 'net/core'. So the fix is applied to the 'ethtool_get_settings()'
>>>>> which is only called in the context of the 'ethtool'.
>>>>>
>>>>> Signed-off-by: Arun Parameswaran <aparames@broadcom.com>
>>>>> Reviewed-by: Ray Jui <rjui@broadcom.com>
>>>>> Reviewed-by: Scott Branden <sbranden@broadcom.com>
>>>>
>>>> Applied and queued up for -stable, thanks.
>>>
>>> Please revert this.  This is an incompatible API change, not a bug fix.
>>> The established semantics are that 'phyad' is filled in by the driver;
>>> it is not a parameter to the ETHTOOL_GSET command.
>>
>> But then how in the world can the user specify specific PHY ADs for
>> a device that will respond to more than one?
> 
> ETHTOOL_SSET sets the current PHY address and ETHTOOL_GSET gets it.
> 
> If multiple PHYs need to be configured for a single link then the driver
> should configure them all at the same time rather than making it the
> administrator's problem.
> 
> What we can't support with the current API are:
> - multiple physical links behind a single net device (different
>   configuration possible for each link)
> - multiple PHYs are needed for a single link, and the driver can't
>   automatically decide which to use (multiple addresses to set)
> 
> Ben.
> 
The patch doesn't affect the current functionality except that the
programs/'ethtool' using the interface needs to ensure the command
structure integrity.

Kernel should transport the data to and from the driver and let the
programs/ethtool handle the data/command. It is better if the Kernel
doesn't manipulate the command/data being requested/passed, in this
case it is the hard-coding of PHY id (by the memset). This adds
flexibility to the interface.

This patch along with the change suggested in the 'ethtool' app
(separate patch set sent for the app), provides the flexibility to be
able to query/set a specific PHY irrespective of the driver design.

In our SoC, we have one MAC connected to multiple PHYs with an internal
switch in between.
We have only one net device as we can have only one MAC address and this
better reflects the hardware state.

It would be nice for the 'ethtool' to be flexible to support querying
specific PHY irrespective of the net implementation, but that is being
discussed in the other thread.


Thanks
Arun
