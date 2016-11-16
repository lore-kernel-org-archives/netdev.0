From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next 6/8] ipv4: fib: Add an API to request a FIB dump
Date: Wed, 16 Nov 2016 18:35:45 +0100
Message-ID: <dcbbcefa-3ca7-c0ed-09a7-1d0e6f96e256@stressinduktion.org>
References: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
 <1479305343-13167-7-git-send-email-jiri@resnulli.us>
 <e795e6e0-a680-a2c3-7d5e-afd966104a4a@stressinduktion.org>
 <20161116151829.h6kapbjes7xxxcyi@splinter.mtl.com>
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
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:46709 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751263AbcKPRfu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 12:35:50 -0500
In-Reply-To: <20161116151829.h6kapbjes7xxxcyi@splinter.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.11.2016 16:18, Ido Schimmel wrote:
> Hi Hannes,
> 
> On Wed, Nov 16, 2016 at 03:51:01PM +0100, Hannes Frederic Sowa wrote:
>> On 16.11.2016 15:09, Jiri Pirko wrote:
>>> From: Ido Schimmel <idosch@mellanox.com>
>>>
>>> Commit b90eb7549499 ("fib: introduce FIB notification infrastructure")
>>> introduced a new notification chain to notify listeners (f.e., switchdev
>>> drivers) about addition and deletion of routes.
>>>
>>> However, upon registration to the chain the FIB tables can already be
>>> populated, which means potential listeners will have an incomplete view
>>> of the tables.
>>>
>>> Solve that by adding an API to request a FIB dump. The dump itself it
>>> done using RCU in order not to starve consumers that need RTNL to make
>>> progress.
>>>
>>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>
>> Have you looked at potential inconsistencies resulting of RCU walking
>> the table and having concurrent inserts?
> 
> Yes. I did try to think about situations in which this approach will
> fail, but I could only find problems with concurrent removals, which I
> addressed in 5/8. In case of concurrent insertions, even if you missed
> the node, you would still get the ENTRY_ADD event to your listener.

Theoretically a node could still be installed while the deletion event
fired before registering the notifier. E.g. a synchronize_net before
dumping could help here?

I don't know how you prepare the data structures for inserting in into
the hardware, but if ordering matters, the notifier for a delete event
can be called before the dump installed the fib entry? E.g. you also
don't check what events are already queued in the delayed work queue so
far. I hope I understand the patches correctly?

Thanks,
Hannes
