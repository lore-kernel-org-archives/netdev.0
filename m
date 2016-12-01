From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next v3 11/12] mlxsw: spectrum_router: Request a dump
 of FIB tables during init
Date: Fri, 2 Dec 2016 00:27:25 +0100
Message-ID: <75d6f272-9320-8aed-4de2-3f69d9b3ea3c@stressinduktion.org>
References: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
 <1480500546-2544-12-git-send-email-jiri@resnulli.us>
 <eb7ddecd-d6b4-dfce-5990-9e933227c862@stressinduktion.org>
 <20161130163229.rkxvuwukgg35ktrx@splinter.mtl.com>
 <043a2ba9-1e19-c3cd-a930-59e8cb0d5f7a@stressinduktion.org>
 <20161130182243.cpoyoqvxuv2bnn4y@splinter.mtl.com>
 <ea2a8856-59d8-1b5f-9428-b16efa8f6979@stressinduktion.org>
 <20161201231445.vtx7mjxuxusar3mu@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kaber@trash.net
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:40233 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754712AbcLAX1a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 18:27:30 -0500
In-Reply-To: <20161201231445.vtx7mjxuxusar3mu@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.12.2016 00:14, Ido Schimmel wrote:

[...]

>> Basically, if you delete a node right now the kernel might simply do a
>> RCU_INIT_POINTER(ptr_location, NULL), which has absolutely no barriers
>> or synchronization with the reader side. Thus you might get a callback
>> from the notifier for a delete event on the one CPU and you end up
>> queueing this fib entry after the delete queue, because the RCU walk
>> isn't protected by any means.
>>
>> Looking closer at this series again, I overlooked the fact that you
>> fetch fib_seq using a rtnl_lock and rtnl_unlock pair, which first of all
>> orders fetching of fib_seq and thus the RCU dumping after any concurrent
>> executing fib table update, also the mutex_lock and unlock provide
>> proper acquire and release fences, so the CPU indeed sees the effect of
>> a RCU_INIT_POINTER update done on another CPU, because they pair with
>> the rtnl_unlock which might happen on the other CPU.
> 
> Yep, Exactly. I had a feeling this is the issue you were referring to,
> but then you were the one to suggest the use of RTNL, so I was quite
> confused.

At that time I actually had in mind that the fib_register would happen
under the sequence lock, so I didn't look closely to the memory barrier
pairings. I kinda still consider this to be a happy accident. ;)

>> My question is if this is a bit of luck and if we should make this
>> explicit by putting the registration itself under the protection of the
>> sequence counter. I favor the additional protection, e.g. if we some day
>> actually we optimize the fib_seq code? Otherwise we might probably
>> document this fact. :)
> 
> Well, some listeners don't require a dump, but only registration
> (rocker) and in the future we might only need a dump (e.g., port being
> moved to a different net namespace). So I'm not sure if bundling both
> together is a good idea.
> 
> Maybe we can keep register_fib_notifier() as-is and add 'bool register'
> to fib_notifier_dump() so that when set, 'nb' is also registered after
> RCU walk, but before we check if the dump is consistent (unregistered if
> inconsistent)?

I really like that. Would you mind adding this?

[...]

>> Quick follow-up question: How can I quickly find out the hw limitations
>> via the kernel api?
> 
> That's a good question. Currently, you can't. However, we already have a
> mechanism in place to read device's capabilities from the firmware and
> we can (and should) expose some of them to the user. The best API for
> that would be devlink, as it can represent the entire device as opposed
> to only a port netdev like other tools.
> 
> We're also working on making the pipeline more visible to the user, so
> that it would be easier for users to understand and debug their
> networks. I believe a colleague of mine (Matty) presented this during
> the last netdev conference.

Thanks, I will look it up!

Bye,
Hannes
