From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next 6/8] ipv4: fib: Add an API to request a FIB dump
Date: Thu, 17 Nov 2016 18:20:39 +0100
Message-ID: <f58c008f-c23a-4950-2975-3c1b4c3b8692@stressinduktion.org>
References: <56d2179d-00ff-bcc5-e365-845179cbe672@stressinduktion.org>
 <20161117131049.pevkla5os75h4zlc@splinter.mtl.com>
 <e2e0eaaf-30f0-e825-29c7-920115742301@stressinduktion.org>
 <20161117.114529.1851585222876647915.davem@davemloft.net>
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
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:58208 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S938935AbcKQRUq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:20:46 -0500
In-Reply-To: <20161117.114529.1851585222876647915.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 17.11.2016 17:45, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 17 Nov 2016 15:36:48 +0100
> 
>> The other way is the journal idea I had, which uses an rb-tree with
>> timestamps as keys (can be lamport timestamps). You insert into the tree
>> until the dump is finished and use it as queue later to shuffle stuff
>> into the hardware.
> 
> If you have this "place" where pending inserts are stored, you have
> a policy decision to make.
> 
> First of all what do other lookups see when there are pending entires?

I think this is a problem with the current approach already, as the
delayed work queue already postpones the insert for an undecidable
amount of time (and reorders depending on which CPU the entry was
inserted and the fib notifier was called).

For user space queries we would still query the in-kernel table.

> If, once inserted into the pending queue, you return success to the
> inserting entity, then you must make those pending entries visible
> to lookups.

I think this same problem is in this patch set already. The way I
understood it, is, that if a problem during insert emerges, the driver
calls abort and every packet will be send to user space, as the routing
table cannot be offloaded and it won't try it again, Ido?

Probably this is an artifact of the mellanox implementation and we can
implement this differently for other cards, but the schema to abort all
if the modification doesn't work, seems to be fundamental (I think we
require the all-or-nothing approach for now).

> If you block the inserting entity, well that doesn't make a lot of
> sense.  If blocking is a workable solution, then we can just block the
> entire insert while this FIB dump to the device driver is happening.

I don't think we should really block (as in kernel-block) at any time.

I was suggesting something like:

rtnl_lock();
synchronize_rcu_expedited(); // barrier, all rounting modifications are
stable and no new can be added due to rtnl_lock
register notifier(); // notifier adds entries also into journal();
rtnl_unlock();
walk_fib_tree_rcu_into_journal();
// walk finished
start_syncing_journal_to_hw(); // if new entries show up we sync them
asap after this point

The journal would need a spin lock to protect its internal state and
order events correctly.

> But I am pretty sure the idea of blocking modifications for so long
> was considered undesirable.

Yes, this is also still my opinion.

Bye,
Hannes
