From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Using a waiting MDIO does not go well with a spinlocked bridge
Date: Mon, 23 Mar 2015 07:45:52 +0100
Message-ID: <20150323064552.GC2032@nanopsycho.orion>
References: <alpine.LNX.2.03.1503201321050.27020@hellgate.skynet>
 <CAE4R7bA4pzSrZfn1W198kMKnYeJEofLsrgPzq_8xJR7KjCewPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonas Johansson <jonasj76@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:34636 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbbCWGpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 02:45:55 -0400
Received: by wegp1 with SMTP id p1so129569120weg.1
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 23:45:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bA4pzSrZfn1W198kMKnYeJEofLsrgPzq_8xJR7KjCewPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 20, 2015 at 07:46:47PM CET, sfeldma@gmail.com wrote:
>On Fri, Mar 20, 2015 at 5:22 AM, Jonas Johansson <jonasj76@gmail.com> wrote:
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
>I think we need to hook switchdev in fdb_delete(), then it'll get
>called from flush and ageing out operations, rather than adding a new
>switch_flush().  But, that's an aside for your main issue that the
>bridge will hold a spinlock for most (all?) FDB delete operations.  I
>don't see a way around relaxing that, on the bridge side, since it's
>doing things like walking lists while deleting list elements.  So that
>means the call into switchdev will be spinlocked, so switchdev driver
>needs to deal with that.  Scheduling to work queue is one option, as
>you mention, if FDB delete can't be done under the spinlock.


I agree that removing/changing spinlock in bridge code is no-go. Driver
should deal with running callback in atomic context itself.

>
>
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
>We would loose the FDB add results if added to work queue.  On add,
>you could check work queue delete list for entry, and if there, remove
>from work queue list.
>
>>
>> 2) This will result in unsued CPU cycles.
>>
>> 3) Havent looked into this, but probably a lot of work.
>
>Can of worms...wouldn't recommend that option.
>
>> Any ideas?
