From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [patch net-next 0/9] mlxsw: Support firmware flash
Date: Mon, 29 May 2017 11:33:30 +0300
Message-ID: <51e03c32-4ff8-9184-ab5c-247d8003f302@mellanox.com>
References: <ea7cf005-1f6c-aa87-db90-03d7c77c7d56@mellanox.com>
 <BLUPR0701MB2004EB2F32B4C8C42C5020458DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
 <fba5a440-ba1e-84bd-d2d2-d011406d3a4a@mellanox.com>
 <20170523.113859.1803057381093280239.davem@davemloft.net>
 <0daa5c5a-377c-767f-ea19-26c1f22bd30c@mellanox.com>
 <20170528171735.0e44878d@cakuba.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <Yuval.Mintz@cavium.com>,
        <jiri@resnulli.us>, <netdev@vger.kernel.org>,
        <idosch@mellanox.com>, <mlxsw@mellanox.com>,
        <bhutchings@solarflare.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10055.outbound.protection.outlook.com ([40.107.1.55]:14073
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750992AbdE2Idh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 04:33:37 -0400
In-Reply-To: <20170528171735.0e44878d@cakuba.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2017 03:17 AM, Jakub Kicinski wrote:
> On Sun, 28 May 2017 10:26:49 +0300, Yotam Gigi wrote:
>> On 05/23/2017 06:38 PM, David Miller wrote:
>>> From: Yotam Gigi <yotamg@mellanox.com>
>>> Date: Tue, 23 May 2017 18:14:15 +0300
>>>  
>>>> Sorry, I am not sure I understand. You think that drivers should not implement
>>>> ethtool's flash_device callback anymore? do you have an alternative for firmware
>>>> flash?  
>>> As stated, export an MTD device.  
>> So, after we have been going over MTD, it seems like it does not fit our needs
>> at all.
>>
>> MTD device provides (erasable-)block access to a flash storage, where in our
>> case the firmware burn process is just pouring a binary BLOB into the device.
>> The driver is not aware of the internal storage used for storing the firmware as
>> it is not defined in our driver-hardware API.
>>
>> Needless to say that block access has no meaning in our case, so any solution
>> that will involve MTD device to burn our firmware (if there is a solution at
>> all) will be a workaround and will not fit MTD purpose.
>>
>> Apart for boot time firmware flash, which we have already pushed we would really
>> like to allow the user to ask for a specific firmware version. Do you have any
>> other solution for us apart from "ethtool -f"?
> Could you elaborate on what the requirements are for "allowing users to
> ask for a specific firmware version"?  How do the FWs differ?  I'm
> asking because we are currently lacking ABI for selecting device
> "modes".  Netronome has this problem.  Cavium has recently posted a
> patch which used module parameter to flip between "OvS" and "basic NIC"
> firmwares.
>
> For Netronome we will definitely want a way to switch between at least
> three applications so far - basic, OvS and eBPF - but I also feel like
> we shouldn't limit that list, since anyone can write their own FW for
> programmable NICs.

Currently, both in the HCA and switch we only refer to FW images of different
versions which naturally include bug fixes and enhancements (new features), and
not configurations or hardware modes.
 
In the switch driver we use boot time firmware upgrade if the minimum required
version is not met, so it is true that the "ethtool -f" is not really required
for normal operation.

However, it is of much use for development, testing, QA, lab and PoC
environments when specific bug fixes or new features which are not yet present
in official FW releases and hence not yet posted to the upstream libfirmware.

I do agree, on the other hand, that the difference between firmware versions and
firmware configuration is semantic, and there is no code-enforcement on that,
but it will be of much convenience for the user to upgrade to a newer firmware
that includes more features.


>
> I think you were primarily concerned with writing persistent storage so
> far.  Does "allowing the user to ask..." means write flash and reboot or
> also a runtime switch?  I think we probably need both?


Currently the new firmware will be activated after reboot, but we may change it
in the future.


>
>> This problem is even more relevant in the Mellanox HCA driver team, which would
>> like to use that code in order to burn the HCA firmware, but not intend to
>> trigger it on boot time, which means that must have a way for the user to
>> trigger it.
> What would the requirements for the HCA team be?  Is it about loading
> different code or loading HW settings?
