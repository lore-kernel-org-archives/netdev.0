From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [PATCH] phy state machine: failsafe leave invalid RUNNING state
Date: Wed, 4 Jan 2017 17:10:14 +0100
Message-ID: <8521b51f-04f7-aeef-f862-bb150257cfa4@neratec.com>
References: <1483542298-9747-1-git-send-email-zefir.kurtisi@neratec.com>
 <6845805d-4dae-0a3a-c56c-6feb86f4b553@gmail.com>
 <82ffbb43-9345-c47d-596c-73c175ac7e7f@neratec.com>
 <16a741c1-7005-b1df-f2e6-afdbe9d086c8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:26821 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967325AbdADQK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 11:10:27 -0500
In-Reply-To: <16a741c1-7005-b1df-f2e6-afdbe9d086c8@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2017 04:30 PM, Florian Fainelli wrote:
> 
> 
> On 01/04/2017 07:27 AM, Zefir Kurtisi wrote:
>> On 01/04/2017 04:13 PM, Florian Fainelli wrote:
>>>
>>>
>>> On 01/04/2017 07:04 AM, Zefir Kurtisi wrote:
>>>> While in RUNNING state, phy_state_machine() checks for link changes by
>>>> comparing phydev->link before and after calling phy_read_status().
>>>> This works as long as it is guaranteed that phydev->link is never
>>>> changed outside the phy_state_machine().
>>>>
>>>> If in some setups this happens, it causes the state machine to miss
>>>> a link loss and remain RUNNING despite phydev->link being 0.
>>>>
>>>> This has been observed running a dsa setup with a process continuously
>>>> polling the link states over ethtool each second (SNMPD RFC-1213
>>>> agent). Disconnecting the link on a phy followed by a ETHTOOL_GSET
>>>> causes dsa_slave_get_settings() / dsa_slave_get_link_ksettings() to
>>>> call phy_read_status() and with that modify the link status - and
>>>> with that bricking the phy state machine.
>>>
>>> That's the interesting part of the analysis, how does this brick the PHY
>>> state machine? Is the PHY driver changing the link status in the
>>> read_status callback that it implements?
>>>
>> phydev->read_status points to genphy_read_status(), where the first call goes to
>> genphy_update_link() which updates the link status.
>>
>> Thereafter phy_state_machine():RUNNING won't be able to detect the link loss
>> anymore unless the link state changes again.
>>
>>
>> I was trying to figure out if there is a rule that forbids changing phydev->link
>> from outside the state machine, but found several places where it happens (either
>> directly, or over genphy_read_status() or over genphy_update_link()).
>>
>> Curious how this did not show up before, since within the dsa setup it is very
>> easy to trigger:
>> a) physically disconnect link
>> b) within one second run ethtool ethX
> 
> You need to be more specific here about what "the dsa setup" is, drivers
> involved, which ports of the switch you are seeing this with (user
> facing, CPU port, DSA port?) etc.
> 
I am working on top of LEDE and with that at kernel 4.4.21 - alas I checked the
related source files and believe the effect should be reproducible with HEAD.

The setup is as follows:
mv88e6321:
* ports 0+1 connected to fibre-optics transceivers at fixed 100 Mbps
* port 4 is CPU port
* custom phy driver (replacement for marvell.ko) only populated with
  * .config_init to
    * set fixed speed for ports 0+1 (when in FO mode)
    * run genphy_config_init() for all other modes (here: CPU port)
  * .config_aneg=genphy_config_aneg, .read_status=genphy_read_status


To my understanding, the exact setup is irrelevant - to reproduce the issue it is
enough to have a means of running genphy_update_link() (as done in e.g.
mediatek/mtk_eth_soc.c, dsa/slave.c), or genphy_read_status() (as done in e.g.
hisilicon/hns/hns_enet.c) or phy_read_status() (as done in e.g.
ethernet/ti/netcp_ethss.c, ethernet/aeroflex/greth.c, etc.). In the observed
drivers it is mostly implemented in the ETHTOOL_GSET execution path.

Once you get the link state updated outside the phy state machine, it remains in
invalid RUNNING. To prevent that invalid state, to my understanding upper layer
drivers (Ethernet, dsa) must not modify link-states in any case (including calling
the functions noted above), or we need the proposed fail-safe mechanism to prevent
getting stuck.


Thanks,
Zefir
