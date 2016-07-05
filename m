From: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Subject: Re: [PATCH net] bonding: fix 802.3ad aggregator reselection
Date: Tue, 5 Jul 2016 16:59:06 +0300
Message-ID: <CAKdSkDX=bf8bNvefjJae2zquEq5+PLDFsfDG--tZrdgzupg5NQ@mail.gmail.com>
References: <10542.1466716851@famine> <CAKdSkDVXe5jRgWU8WAvx43KvEuZvS4ak+a9qd9H4C3zy+OvkPQ@mail.gmail.com>
 <CAD=hENfHOVBzwrC2Yy371FvxRG9AyJpvAm+s4R6hzU_+o=tJYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:34442 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598AbcGEN7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 09:59:08 -0400
Received: by mail-oi0-f50.google.com with SMTP id s66so229878872oif.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 06:59:08 -0700 (PDT)
In-Reply-To: <CAD=hENfHOVBzwrC2Yy371FvxRG9AyJpvAm+s4R6hzU_+o=tJYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-07-01 12:03 GMT+03:00 zhuyj <zyjzyj2000@gmail.com>:
> "
> ...
> All testing was done with upstream version 4.6.2 with the patch
> applied. When there is no connection, /proc/net/bonding/bond0 still
> shows that there is an active aggregator that has a link up, but for
> some reason no traffic passes through. I added some debugging
> information in bond_procfs.c and the number of active ports seems to
> match the enabled ports on switches.
> ...
> "
> Would you like to let me know what method you used, the miimon or
> arp_interval? If miimon, would you like to use arp_interval to make tests?

I have understood that only miimon is available with 802.3ad:

bonding.txt:

802.3ad:
...
        Finally, the 802.3ad mode mandates the use of the MII monitor,
        therefore, the ARP monitor is not available in this mode.

Is there a way to enable ARP monitor somehow?

Veli-Matti


>
> Let me know the result.
> Zhu Yanjun
>
> On Tue, Jun 28, 2016 at 7:57 PM, Veli-Matti Lintu
> <veli-matti.lintu@opinsys.fi> wrote:
>>
>> 2016-06-24 0:20 GMT+03:00 Jay Vosburgh <jay.vosburgh@canonical.com>:
>> >
>> >         Since commit 7bb11dc9f59d ("bonding: unify all places where
>> > actor-oper key needs to be updated."), the logic in bonding to handle
>> > selection between multiple aggregators has not functioned.
>> >
>> >         This affects only configurations wherein the bonding slaves
>> > connect to two discrete aggregators (e.g., two independent switches,
>> > each
>> > with LACP enabled), thus creating two separate aggregation groups within
>> > a
>> > single bond.
>> >
>> >         The cause is a change in 7bb11dc9f59d to no longer set
>> > AD_PORT_BEGIN on a port after a link state change, which would cause the
>> > port to be reselected for attachment to an aggregator as if were newly
>> > added to the bond.  We cannot restore the prior behavior, as it
>> > contradicts IEEE 802.1AX 5.4.12, which requires ports that "become
>> > inoperable" (lose carrier, setting port_enabled=false as per 802.1AX
>> > 5.4.7) to remain selected (i.e., assigned to the aggregator).  As the
>> > port
>> > now remains selected, the aggregator selection logic is not invoked.
>> >
>> >         A side effect of this change is that aggregators in bonding will
>> > now contain ports that are link down.  The aggregator selection logic
>> > does not currently handle this situation correctly, causing incorrect
>> > aggregator selection.
>> >
>> >         This patch makes two changes to repair the aggregator selection
>> > logic in bonding to function as documented and within the confines of
>> > the
>> > standard:
>> >
>> >         First, the aggregator selection and related logic now utilizes
>> > the
>> > number of active ports per aggregator, not the number of selected ports
>> > (as some selected ports may be down).  The ad_select "bandwidth" and
>> > "count" options only consider ports that are link up.
>> >
>> >         Second, on any carrier state change of any slave, the aggregator
>> > selection logic is explicitly called to insure the correct aggregator is
>> > active.
>> >
>> > Reported-by: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
>> > Fixes: 7bb11dc9f59d ("bonding: unify all places where actor-oper key
>> > needs to be updated.")
>> > Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
>>
>>
>> Hi,
>>
>> Thanks for the patch. I have been now testing it and the reselection
>> seems to be working now in most cases, but I hit one case that seems
>> to consistently fail in my test environment.
>>
>> I've been doing most of testing with ad_select=count and this happens
>> with it. I haven't yet done extensive testing with
>> ad_select=stable/bandwidth.
>>
>> The sequence to trigger the failure seems to be:
>>
>>   Switch A (Agg ID 2)       Switch B (Agg ID 1)
>> enp5s0f0 ens5f0 ens6f0    enp5s0f1 ens5f1 ens6f1
>>     X       X      -           X      -       -     Connection works
>> (Agg ID 2 active)
>>     X       -      -           X      -       -     Connection works
>> (Agg ID 1 active)
>>     X       -      -           -      -       -     No connection (Agg
>> ID 2 active)
>>
>> I'm also wondering why link down event causes change of aggregator
>> when the active aggregator has the same number of active links than
>> the new aggregator.
>>
>> The situation here clears once a port comes up. Once I hit also
>> problems without disabling all ports on active switch:
>>
>>   Switch A (Agg ID 2)       Switch B (Agg ID 1)
>> enp5s0f0 ens5f0 ens6f0    enp5s0f1 ens5f1 ens6f1
>>     X       X      -           X      -       -     Connection works
>> (Agg ID 2 active)
>>     X       -      -           X      -       -     No connection (Agg
>> ID 1 active)
>>
>> The active switch does not seem to matter either when disabling ports:
>>
>>   Switch A (Agg ID 2)       Switch B (Agg ID 1)
>> enp5s0f0 ens5f0 ens6f0    enp5s0f1 ens5f1 ens6f1
>>     X       -      -           X      X       X     Connection works
>> (Agg ID 1 active)
>>     X       -      -           X      -       -     Connection works
>> (Agg ID 2 active)
>>     -       -      -           X      -       -     No connection (Agg
>> ID 1 active)
>>
>> All testing was done with upstream version 4.6.2 with the patch
>> applied. When there is no connection, /proc/net/bonding/bond0 still
>> shows that there is an active aggregator that has a link up, but for
>> some reason no traffic passes through. I added some debugging
>> information in bond_procfs.c and the number of active ports seems to
>> match the enabled ports on switches.
>>
>> I'll continue doing tests with different scenarios and I can also test
>> specific cases if needed.
>>
>>
>> Veli-Matti
>
>
