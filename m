From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 00/29] Phase 2 of fib_trie updates
Date: Tue, 24 Feb 2015 21:12:48 -0800
Message-ID: <54ED59D0.9010401@gmail.com>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20> <20150224.225300.107506639649235664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:40799 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703AbbBYFMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 00:12:50 -0500
Received: by paceu11 with SMTP id eu11so2376887pac.7
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 21:12:50 -0800 (PST)
In-Reply-To: <20150224.225300.107506639649235664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2015 07:53 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Tue, 24 Feb 2015 12:47:55 -0800
>
>> This patch series implements the second phase of the fib_trie changes.  I
>> presented on these and the previous changes at Netdev01 and netconf.  The
>> slides for the Netdev01 presentation can be found at
>> https://www.netdev01.org/docs/duyck-fib-trie.pdf.
>>
>> I'm currently debating if I should just submit the entire patch-set as-is
>> or if I should hold off on submitting the last 10 patches as they currently
>> have a potential performance impact in the case of a large number of
>> entries placed in the local table.  Specifically I have seen that removing
>> an interface in the case of 8K local subnets being configured on it
>> resulted in the time for a dummy interface being removed increasing from
>> about .6 seconds to 2.4 seconds.  I am not sure how common of a use-case
>> something like this would be.  I have not seen the same issue if I assign
>> 8K routes to the interface as I believe the fib_table_flush aggregates them
>> all in to one resize action.
>>
>> The entire series reduces the total look-up time by another 20-35% versus
>> what is currently in the 4.0-rc1 kernel.  So for example a set of routing
>> look-ups which took 140ns in the 4.0-rc1 kernel will now only take about
>> 105ns after these patches.
> I did a quick once-over for these changes and conceptually they look
> fine.
>
> Why are sequences of removals so much more costly now?  Is it because
> of the maintainence of the information in the parent when rebalancing?
>
> In any event, I'll say two things:
>
> 1) You should submit these changes in smaller batches anyways.
>    It's easier to review and get small sets of transformations
>    tested as a unit.

Yeah, these will probably be submitted as 3 sets.  The first being the
leaf_info removal, then the key_vector stuff, and finally reworking the
RCU and pushing everything up one level so the pointer and key info
occupy the same cache line.

> 2) For the device removal case, we can batch the inet addr removal
>    based route delete operations, and thus mitigate the rebalancing
>    costs.

The problem is that the tnodes are now split over 2 cache lines.  As a
result in order to resize a node, or replace it with the leaf contained
in the node you end up having to replace the parent of the node as well. 

As it turns out dropping a subnet from the local trie occurs in two
steps.  The first appears to drop the broadcast addresses and flush
them, this is causing some significant overhead since it means the
kernel to reallocate the 8K child tnode as each subnet/child is
collapsing from a 4 child tnode to just a leaf.  Then it looks like the
kernel is going though and deleting the local addresses that were there
for each subnet one at a time.  This was much cheaper in the old setup
since it was just a matter of swapping a pointer instead of having to
update a pointer and key information.

- Alex
