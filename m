From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 00/17] fib_trie: Reduce time spent in fib_table_lookup
 by 35 to 75%
Date: Fri, 02 Jan 2015 08:28:00 -0800
Message-ID: <54A6C710.6000702@gmail.com>
References: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>	<20141231.184610.1802958694945952516.davem@davemloft.net>	<54A4B1D4.1030506@gmail.com> <20150101.210841.1269406605009943743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:40182 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbABQ2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 11:28:03 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so24295804pab.34
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 08:28:02 -0800 (PST)
In-Reply-To: <20150101.210841.1269406605009943743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/01/2015 06:08 PM, David Miller wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Wed, 31 Dec 2014 18:32:52 -0800
>
>> On 12/31/2014 03:46 PM, David Miller wrote:
>>> This knocks about 35 cpu cycles off of a lookup that ends up using the
>>> default route on sparc64.  From about ~438 cycles to ~403.
>> Did that 438 value include both fib_table_lookup and check_leaf?  Just
>> curious as the overall gain seems smaller than what I have been seeing
>> on the x86 system I was testing with, but then again it could just be a
>> sparc64 thing.
> This is just a default run of my kbench_mod.ko from the net_test_tools
> repo.  You can try it as well on x86-86 or similar.

Okay.  I was hoping to find some good benchmarks for this work so that
will be useful.

>> I've started work on a second round of patches.  With any luck they
>> should be ready by the time the next net-next opens.  My hope is to cut
>> the look-up time by another 30 to 50%, though it will take some time as
>> I have to go though and drop the leaf_info structure, and look at
>> splitting the tnode in half to break the key/pos/bits and child pointer
>> dependency chain which will hopefully allow for a significant reduction
>> in memory read stalls.
> I'm very much looking forward to this.
>
>> I am also planning to take a look at addressing the memory waste that
>> occurs on nodes larger than 256 bytes due to the way kmalloc allocates
>> memory as powers of 2.  I'm thinking I might try encouraging the growth
>> of smaller nodes, and discouraging anything over 256 by implementing a
>> "truesize" type logic that can be used in the inflate/halve functions so
>> that the memory usage is more accurately reflected.
> Wouldn't this result in a deeper tree?  The whole point is to keep the
> tree as shallow as possible to minimize the memory refs on a lookup
> right?

I'm hoping that growing smaller nodes will help offset the fact that we
have to restrict the larger nodes.  For backtracing these large nodes
come at a significant price as each bit value beyond what can be fit in
a cache-line means one additional cache line being read when
backtracking.  So for example two 3 bit nodes on 64b require 4
cache-lines when backtracking an all 1s value, but one 6 bit node will
require reading 5 cache-lines.

Also I hope to reduce the memory accesses/dependencies to half of what
they currently are so hopefully the two will offset each other in the
case where there were performance gains from having nodes larger than
256B that cannot reach the necessary value to inflate after the change. 
If nothing else I figure I can tune the utilization values based on the
truesize so that we get the best memory utilization/performance ratio. 
If necessary I might relax the value from the 50% it is now as we pretty
much have to be all full nodes in order to inflate based on the truesize
beyond 256B.

- Alex
