From: Andrey Volkov <andrey.volkov@nexvision.fr>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Thu, 26 Feb 2015 02:18:11 +0100
Message-ID: <54EE7453.5060602@nexvision.fr>
References: <54EAAEBC.6080609@roeck-us.net> <CAGVrzcYnuV6raXSrAETctwX5dwX3S=2-=ySewCFdx=iM7bPaDg@mail.gmail.com> <20150223133454.GB23581@lunn.ch> <54EB37C7.3090209@roeck-us.net> <20150223160109.GB27057@lunn.ch> <54EB6BF5.2020600@gmail.com> <20150223183537.GA23456@roeck-us.net> <54EDD172.4010606@nexvision.fr> <54EDDB72.1090706@roeck-us.net> <54EDF2B8.8020200@nexvision.fr> <20150225174125.GB2400@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	jerome.oufella@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1.mo2.mail-out.ovh.net ([46.105.63.121]:44102 "EHLO
	1.mo2.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369AbbBZChO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 21:37:14 -0500
Received: from mail99.ha.ovh.net (b6.ovh.net [213.186.33.56])
	by mo2.mail-out.ovh.net (Postfix) with SMTP id 1CF1AFFB197
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 02:18:15 +0100 (CET)
In-Reply-To: <20150225174125.GB2400@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guenter,

Le 25/02/2015 18:41, Guenter Roeck wrote :
> Andrey,
>
> On Wed, Feb 25, 2015 at 05:05:12PM +0100, Andrey Volkov wrote:
>>> Does removing a port from a fid clean up the entries associated with it
>>> in the database ?
>>>
>> It doesn't, sorry that I didn't described it clearly: I've tried to point to that fact that
>> changing FID will cause 2 things:
>>   - learn/discard/... process for all following packets will begin from scratch (as it should be)
>>   - we could start (potentially) slow database cleanup process in dedicated thread/work, and we may not
>>     care about appearing of new ATU rules for the removed port, since packets now will be rejected
>>     by port's logic.
>>
> Any idea what happens if a packet is received which has an fdb entry
> pointing to port X, which was just removed from the bridge group ?
I have some ideas (looks like it must be filtered out), but not sure,
I will do some experiments tomorrow.

>>>> seen any mutichip bridges/hardwared "trunks" support (in the Marvell's sense), did anyone, except me, use it?
>>>>
>>> Not me. That would be difficult to test without real hardware.
>> Not a problem for me :), I've already monster switch containing three different types of Marvell's chips
>> just before me on my table.
>>
> Lucky (or unlucky ;-) you.
M-m-m, how about undocumented 'PPU enable' 14'th bit and other such
gifts :D?

>>> The above suggests that you have a HW bridge implementation for Marvell chips as well.
>>> Would it make sense to merge our implementations, or just use yours if it is better ?
>> I've implemented same thing almost by same way, so for me it will be easer to rebase on top of your jobs,
>> especially due to the fact that I've enforced to use very old kernel: proprietary binary blobs...
>>
> Can you by any chance share your code, and or do you plan
> to submit it ?
Yes, sure, I plan to start submitting it in the first half of the March.

>
> I'll have to look into multi-bridge implementations at some point
> in the future, so that would help a lot.
>
>>>> Btw your current FID implementation contain funny security problem: same ports in the different chips,
>>>> interconnected by DSA, will have same FID and as result they will treated as bridged together by
>>>> internal switch logic...
>>>>
>>> You mean if multiple switch chips are used ? Those ports are configured to only send
>>> data to the CPU port. Doesn't that take care of the problem ? Granted, I have not
>>> looked into multi-chip applications, so there may well be some problems.
>> My current project is to implement support of something like:
>>
>>         .----------.    .--------.
>>         |  CPU1    |    |  CPU2  |
>>   .DSA--o (master) |    |        |
>>   |     '----------'    'o-------'
>>   |                  .---'
>>   | .-----.       .--o--.       .-----.
>>   '-o SW1 o--DSA--o SW2 o==DSA==o SW3 |
>>     '-----'       '-----'       '-----'
>>       |             |              |
>>     ports         ports          ports
>>
>> Where SW2 and SW3 are interconnected by "trunk", everything managed by CPU1,
>> some ports of SW1-SW3 are bridged with CPU2, some with CPU1, and some bridged
>> independently of CPUs. Also, as I told before, all SWs are from
>> different chips families, so I'm using all, except 88e6060 and 6171, Marvell's drivers.
>>
> Sounds like a lot of fun, especially if/when both CPUs start messing
> with switch configuration.
Yeah, the toy is really interesting and powerful, and fortunately not so terrible:
CPU2  connected like "normal" client, meanwhile mixture of trunk/bridge/normal ports
connected through mixture of PHYs still "little bit" disturbing me :).

>
>>> Maybe
>>> it is possible to merge a chip ID into the fid to solve it.
>> Will not work IMHO, since to support interswitch bridges, some ports must have common id's,
>> so we should have some enumeration management at level of the DSA tree.
>> I've already implemented it as a free running counter, but implementation is wrong, terrible
>> and must be redesigned by hlists or alike.
>>
> Maybe use ida to get a well defined id for each bridge group touched
> by dsa ? This id could then be used by the driver to identify a bridge.
Hmm, probably you are right, I need thinking about it little bit more.
Just for any case: these shared ids must be unique not only for bridges,
but for the Marvell's trunks (hidden from user space) and normal ports too.

Florian, I suspect that Broadcom have same document's policy as Marvell,
so you can not tell us too much, but is the trunk/multiswitch stuff will be
interesting for your too?

Andrey
