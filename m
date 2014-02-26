From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: add suspend_halted module param
Date: Wed, 26 Feb 2014 10:30:39 -0800
Message-ID: <CAGVrzcYUfq84ryVET9qNJvyFCnhFdU4c0fOHbNN4eE8_w6qsAQ@mail.gmail.com>
References: <1393174719-20806-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <20140224191554.GC29288@lunn.ch> <530D1B7C.2090506@gmail.com> <20140226182117.GB14907@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33027 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbaBZSbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 13:31:20 -0500
In-Reply-To: <20140226182117.GB14907@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-26 10:21 GMT-08:00 Andrew Lunn <andrew@lunn.ch>:
> On Tue, Feb 25, 2014 at 11:38:52PM +0100, Sebastian Hesselbarth wrote:
>> On 02/24/2014 08:15 PM, Andrew Lunn wrote:
>> >On Sun, Feb 23, 2014 at 05:58:39PM +0100, Sebastian Hesselbarth wrote:
>> >>commit 1211ce53077164e0d34641d0ca5fb4d4a7574498
>> >>   ("net: phy: resume/suspend PHYs on attach/detach")
>> >>introduced a feature to suspend PHYs when entering halted state.
>> >>
>> >>Unfortunately, not all bootloaders properly power-up PHYs on reset
>> >>and fail to access ethernet because the PHY is still powered down.
>> >>
>> >>Therefore, we add a boolean module parameter suspend_halted with
>> >>default value of true. Disabling that parameter prevents PHYs from
>> >>being suspended when entering halted state.
>> >
>> >Am i doing something silly here?
>> >
>> >root@qnap:/sys/module/libphy/parameters# cat suspend_halted
>> >Y
>> >root@qnap:/sys/module/libphy/parameters# echo N > suspend_halted
>> >root@qnap:/sys/module/libphy/parameters# cat suspend_halted
>> >N
>> >root@qnap:/sys/module/libphy/parameters# reboot
>>
>> Just to be sure, can you ifconfig up the interface before reboot?
>> The PHY could already be powered-down, if the interface is down.
>>
>> >...
>> >...
>> >
>> >Net:   egiga0 [PRIME]
>> >Hit any key to stop autoboot:  0
>> >Send Cmd : 0x68 to UART1
>> >egiga0 no link
>> >Using egiga0 device
>> >TFTP from server 10.0.0.1; our IP address is 10.0.0.2
>> >Filename 'uImage-qnap'.
>> >Load address: 0x800000
>> >Loading: T T
>> >
>> >Does not seem to work.
>>
>> I tested the patch on Topkick (w/ 88E1318S, 0x0141 0x0e90) which
>> bootloader is also affected.
>>
>> Both, libphy.suspend_halted=0 as kernel boot parameter and sysfs
>> procedure above successfully prevent the PHY from being powered
>> down. After reboot, u-boot tftpboot works as expected.
>
> Hi Sebastian
>
> I tested again, and it seems like i made an error. This patch does
> actually fix the problem.
>
> The u-boot on this device is somewhat broken, when it comes to
> networking and tftpboot. It seems like if the auto negotiation is not
> complete before the TFTP starts, it never works. There are no
> retransmits of the RRQ message. If i ^C it and start again, it does
> work.

Sounds familiar, I saw that on other platforms as well, but never
really found the time to get that fix.

>
> As to the comment from davem about not using a kernel parameter. How
> about turning it all around. Put a boolean parameter into DT PHY node
> to indicate when it is safe to power down an idle phy?

Ah ah, nice try, but I do not think this belongs in DT, this is purely
a software issue here, powering up/down the PHY itself works as
expected.

How about we have this knob a sysfs parameter? This should be easy
enough to tweak at runtime and debug in case thing go wrong.
-- 
Florian
