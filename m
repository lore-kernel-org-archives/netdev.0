From: Jonas Johansson <jonasj76@gmail.com>
Subject: Re: Using a waiting MDIO does not go well with a spinlocked bridge
Date: Mon, 23 Mar 2015 16:42:46 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1503231641440.21270@hellgate.skynet>
References: <alpine.LNX.2.03.1503201321050.27020@hellgate.skynet> <CAE4R7bA4pzSrZfn1W198kMKnYeJEofLsrgPzq_8xJR7KjCewPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jonas Johansson <jonasj76@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	=?ISO-8859-2?Q?Ji=F8=ED_P=EDrko?= <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:32796 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485AbbCWPrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 11:47:24 -0400
Received: by labto5 with SMTP id to5so29833056lab.0
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 08:47:23 -0700 (PDT)
In-Reply-To: <CAE4R7bA4pzSrZfn1W198kMKnYeJEofLsrgPzq_8xJR7KjCewPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 20 Mar 2015, Scott Feldman wrote:

> On Fri, Mar 20, 2015 at 5:22 AM, Jonas Johansson <jonasj76@gmail.com> wrote:
>> The bridge code will sometimes hold a spinlock and the code following must
>> therefore be atomic. If using a MDIO call which uses a wait/sleep in this
>> contex, the kernel will not be very happy.
>>
>> I'm using a switch device and wants to flush its FDB when the linux bridge
>> FDB is flushed. I've implemented some hooks for this task.
>> In short:
>>      bridge    - br_fdb_flush() & br_fdb_delete_by_port
>>   -> switchdev - switch_flush()
>>   -> dsa       - slave_flush()
>>   -> mv88e6xxx - mv88_flush()
>
> I think we need to hook switchdev in fdb_delete(), then it'll get
> called from flush and ageing out operations, rather than adding a new
> switch_flush().  But, that's an aside for your main issue that the
> bridge will hold a spinlock for most (all?) FDB delete operations.  I
> don't see a way around relaxing that, on the bridge side, since it's
> doing things like walking lists while deleting list elements.  So that
> means the call into switchdev will be spinlocked, so switchdev driver
> needs to deal with that.  Scheduling to work queue is one option, as
> you mention, if FDB delete can't be done under the spinlock.
>
>
Thanks for the input.
My idea of using a switch_flush() was to take advantage of the HW to flush 
all FDB entries in one single operation. If I'm not mistaken, using 
fdb_delete() will result in a call for each FDB entry, which will result 
in a lot of overhead.

>> So, when a bridge port is flushed via e.g. sysfs, the mv88_flush() function
>> will at the end be called. The mv88_flush() will use MDIO calls to set the
>> proper registers and flush the device. But, due to that the MDIO on my
>> platform uses wait_for_completion() and a spinlock is held (in this case in
>> brport_store()) the process will not go very well.
>>
>> The only possible solutions that came into my mind is:
>>  1) Let mv88_flush() schedule a work queue to take care of the flush
>>     later on.
>>  2) Change the MDIO implementation to use polling.
>>  3) Dont use spinlock in bridge code.
>>
>> 1) Using this approach the the atomic part is missed, i.e. the switch device
>> isn't guaranteed to be flushed after the command has been issued. And, if a
>> FDB entry is added (atomic) to the switch device immediately after the flush
>> command, there will not be defined if the entry will be added before or
>> after the flush occurs. To solve this, all (FDB) operations must be added to
>> a work queue to assure that they are executed in the right order.
>
> We would loose the FDB add results if added to work queue.  On add,
> you could check work queue delete list for entry, and if there, remove
> from work queue list.
>
>>
>> 2) This will result in unsued CPU cycles.
>>
>> 3) Havent looked into this, but probably a lot of work.
>
> Can of worms...wouldn't recommend that option.
>
>> Any ideas?
>
