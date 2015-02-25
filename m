From: Andrey Volkov <andrey.volkov@nexvision.fr>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Wed, 25 Feb 2015 17:05:12 +0100
Message-ID: <54EDF2B8.8020200@nexvision.fr>
References: <54EA8E7C.90401@roeck-us.net> <20150223031447.GA19267@lunn.ch> <54EAA767.6060105@roeck-us.net> <20150223042220.GA20063@lunn.ch> <54EAAEBC.6080609@roeck-us.net> <CAGVrzcYnuV6raXSrAETctwX5dwX3S=2-=ySewCFdx=iM7bPaDg@mail.gmail.com> <20150223133454.GB23581@lunn.ch> <54EB37C7.3090209@roeck-us.net> <20150223160109.GB27057@lunn.ch> <54EB6BF5.2020600@gmail.com> <20150223183537.GA23456@roeck-us.net> <54EDD172.4010606@nexvision.fr> <54EDDB72.1090706@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	jerome.oufella@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 9.mo5.mail-out.ovh.net ([178.32.96.204]:49031 "EHLO
	9.mo5.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbbBYQoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 11:44:39 -0500
Received: from mail414.ha.ovh.net (b6.ovh.net [213.186.33.56])
	by mo5.mail-out.ovh.net (Postfix) with SMTP id 16DA7FF9936
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 17:05:16 +0100 (CET)
In-Reply-To: <54EDDB72.1090706@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/02/2015 15:25, Guenter Roeck wrote:
> Andrey,
> 
> On 02/25/2015 05:43 AM, Andrey Volkov wrote:
>> Gunter, Florian,
>>
>> Le 23/02/2015 19:35, Guenter Roeck a wrote :
>>> On Mon, Feb 23, 2015 at 10:05:41AM -0800, Florian Fainelli wrote:
>>>> On 23/02/15 08:01, Andrew Lunn wrote:
>>>>>> I currently use ATU command 110 (flush all non-static entries in a
>>>>>> particular FID). I see means to flush either all entries or all
>>>>>> non-static entries, but no means to only flush unicast or multicast
>>>>>> entries. Does any of the standards distinguish between learned unicast
>>>>>> and multicast addresses ? Flushing those selectively might be a
>>>>>> challenge.
>>>> Lucky you, on Broadcom switches you have to issue an ARL search, get the
>>>> results (there are all valid MAC entries, fortunately), and invalidate
>>>> the entries one by one for your particular ports of interest, there is
>>>> no "flush all non-static entries".
>>>>
>>>>> You might need to walk the table and flush records individually if you
>>>>> are only interested in one type.
>>>>>
>>>>> We should also consider do we need to make these flush operations
>>>>> atomic with respect to other operations? Do we need to disable
>>>>> learning, flush, change the port STP status, and then enable learning?
>>> Wonder what if anything RSTP specifies for flush operation details.
>>>
>>>> I think we may have to do this to guarantee no race conditions between
>>>> flushing the switch's FDB, although it would look like only "joining" a
>>>> bridge needs to be a more controlled operation, on leave we can probably
>>>> just leave the bridge, flush entries and the switch port will start
>>>> learning new MAC addresses, right?
>>>>
>>>> Alternatively, would not setting a very low aging timeout and
>>>> maintaining HW learning still allow us to simplify these operations?
>>> That is what STP specifies. With RSTP, the expectation is that the database
>>> is flushed immediately on port status changes. Also, the minimum aging
>>> period on Marvell switches is 15 seconds, which is way too long for RSTP.
>>>
>>> Guenter
>>>
>> I simply modify port's fid to the new one in the leave routine and set to common bridge FID in enter
>> (I'm using Marvell's chips). So the port's database will cleaned up automatically for the leave and will
>> contain something useful at the enter time. Also I've look through yours patches and I haven't
> 
> Does removing a port from a fid clean up the entries associated with it
> in the database ?
> 
It doesn't, sorry that I didn't described it clearly: I've tried to point to that fact that 
changing FID will cause 2 things:
 - learn/discard/... process for all following packets will begin from scratch (as it should be)
 - we could start (potentially) slow database cleanup process in dedicated thread/work, and we may not
   care about appearing of new ATU rules for the removed port, since packets now will be rejected 
   by port's logic.

>> seen any mutichip bridges/hardwared "trunks" support (in the Marvell's sense), did anyone, except me, use it?
>>
> Not me. That would be difficult to test without real hardware.
Not a problem for me :), I've already monster switch containing three different types of Marvell's chips 
just before me on my table.

> 
> The above suggests that you have a HW bridge implementation for Marvell chips as well.
> Would it make sense to merge our implementations, or just use yours if it is better ?
I've implemented same thing almost by same way, so for me it will be easer to rebase on top of your jobs,
especially due to the fact that I've enforced to use very old kernel: proprietary binary blobs...

> 
>> Btw your current FID implementation contain funny security problem: same ports in the different chips,
>> interconnected by DSA, will have same FID and as result they will treated as bridged together by
>> internal switch logic...
>>
> You mean if multiple switch chips are used ? Those ports are configured to only send
> data to the CPU port. Doesn't that take care of the problem ? Granted, I have not
> looked into multi-chip applications, so there may well be some problems.

My current project is to implement support of something like:

       .----------.    .--------.
       |  CPU1    |    |  CPU2  |
 .DSA--o (master) |    |        |
 |     '----------'    'o-------'
 |                  .---'
 | .-----.       .--o--.       .-----.
 '-o SW1 o--DSA--o SW2 o==DSA==o SW3 |
   '-----'       '-----'       '-----'
     |             |              |
   ports         ports          ports

Where SW2 and SW3 are interconnected by "trunk", everything managed by CPU1,
some ports of SW1-SW3 are bridged with CPU2, some with CPU1, and some bridged 
independently of CPUs. Also, as I told before, all SWs are from 
different chips families, so I'm using all, except 88e6060 and 6171, Marvell's drivers.

> Maybe
> it is possible to merge a chip ID into the fid to solve it.
Will not work IMHO, since to support interswitch bridges, some ports must have common id's,
so we should have some enumeration management at level of the DSA tree.
I've already implemented it as a free running counter, but implementation is wrong, terrible
and must be redesigned by hlists or alike.

Regards
Andrey
