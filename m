From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next 6/8] ipv4: fib: Add an API to request a FIB dump
Date: Thu, 17 Nov 2016 20:03:03 +0100
Message-ID: <61ef623b-3e10-2ea4-a8de-ba5f31d208e5@stressinduktion.org>
References: <e2e0eaaf-30f0-e825-29c7-920115742301@stressinduktion.org>
 <20161117.114529.1851585222876647915.davem@davemloft.net>
 <f58c008f-c23a-4950-2975-3c1b4c3b8692@stressinduktion.org>
 <20161117.131609.164578639844581895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: idosch@idosch.org, jiri@resnulli.us, netdev@vger.kernel.org,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        nogahf@mellanox.com, arkadis@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, andy@greyhouse.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:42117 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933672AbcKQTDL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 14:03:11 -0500
In-Reply-To: <20161117.131609.164578639844581895.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.11.2016 19:16, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 17 Nov 2016 18:20:39 +0100
> 
>> Hi,
>>
>> On 17.11.2016 17:45, David Miller wrote:
>>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>> Date: Thu, 17 Nov 2016 15:36:48 +0100
>>>
>>>> The other way is the journal idea I had, which uses an rb-tree with
>>>> timestamps as keys (can be lamport timestamps). You insert into the tree
>>>> until the dump is finished and use it as queue later to shuffle stuff
>>>> into the hardware.
>>>
>>> If you have this "place" where pending inserts are stored, you have
>>> a policy decision to make.
>>>
>>> First of all what do other lookups see when there are pending entires?
>>
>> I think this is a problem with the current approach already, as the
>> delayed work queue already postpones the insert for an undecidable
>> amount of time (and reorders depending on which CPU the entry was
>> inserted and the fib notifier was called).
>>
>> For user space queries we would still query the in-kernel table.
> 
> Ok, I think I might misunderstand something.
> 
> What is going into this journal exactly?  The actual full software and
> hardware insert operation, or just the notification to the hardware
> device driver notifiers?

The journal is only used as a timely ordered queue for updating the
hardware in correct order.

The enqueue side is the fib notifier only. If no fib notifier is
registered we don't use this code at all (and also don't hit the lock
protecting this journal in fib insertion/deletion path - fast in-kernel
path is untouched - otherwise just a spin_lock already under rtnl_lock
in slow path).

The fib notifier enqueues the packet with a timestamp into this journal
and can also merge entries while they are in the queue, e.g. we got a
delete from the fib notifier but the rcu walk indicated an addition of
the entry, so we can merge that at this point and depending on the
timestamp remove the entry or drop the deletion event.

We start dequeueing the fib entries into the hardware as soon as the rcu
dump is finished, at this point we are up-to-date in the queue with all
events. New events can be added to the journal (with appropriate
locking) during this time, as the queue was once in proper synced state
we stay proper synchronized. We keep up with the queue in steady state
after the dump, so syncing happens ASAP. Maybe we can also drop the
journal then.

Something alike this described queue is implemented here (haven't
checked if it exactly matches the specification, certainly it provides
more features):
https://github.com/bus1/bus1/blob/master/ipc/bus1/util/queue.h
https://github.com/bus1/bus1/blob/master/ipc/bus1/util/queue.c

For this to work the config path needs to add timestamps to the
fib_infos or fib_aliases.

> The "lookup" I'm mostly concerned with is the fast path where the
> packets being processed actually look up a route.

This doesn't change at all. All code will be hidden in a library that
gets attached to the fib notifier, which is configuration code path.

> I do not think we can return success on the insert to the user yet
> have the route lookup dataplace not return that route on a lookup.

We don't change kernel fast path at all.

If we add/delete a route in software and hardware, kernel indicates
success as soon as software has the entry added. It also gets queued up
in the journal. Journal will be lazily processed, if error happens
during that (e.g. hardware signals table full), abort is called and all
packets go to user space ASAP. User space will always show the route as
it is added to in the first place and after the driver called abort also
process the packets accordingly.

I can imagine this can get very complicated. David's approach with a
counter to check for modifications and a limited number of retries
probably works too, especially because the hardware will probably be
initialized before routing daemons start up and will be synced up
hopefully all the time.

So maybe this is over engineered, but I have no idea how long hardware
needs to sync up a e.g. full IPv4 routing table into hardware (if that
is actually the current goal of this).

Bye,
Hannes
