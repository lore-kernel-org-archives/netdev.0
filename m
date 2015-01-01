From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 00/17] fib_trie: Reduce time spent in fib_table_lookup
 by 35 to 75%
Date: Wed, 31 Dec 2014 18:32:52 -0800
Message-ID: <54A4B1D4.1030506@gmail.com>
References: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20> <20141231.184610.1802958694945952516.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:50444 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbbAACcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 21:32:54 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so22110630pad.37
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 18:32:54 -0800 (PST)
In-Reply-To: <20141231.184610.1802958694945952516.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/31/2014 03:46 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Wed, 31 Dec 2014 10:55:23 -0800
>
>> These patches are meant to address several performance issues I have seen 
>> in the fib_trie implementation, and fib_table_lookup specifically.  With 
>> these changes in place I have seen a reduction of up to 35 to 75% for the 
>> total time spent in fib_table_lookup depending on the type of search being 
>> performed.
>  ...
>> Changes since RFC:
>>   Replaced this_cpu_ptr with correct call to this_cpu_inc in patch 1
>>   Changed test for leaf_info mismatch to (key ^ n->key) & li->mask_plen in patch 10
> As before, this looks awesome.

Thanks.

> All applied to net-next, thanks!
>
> This knocks about 35 cpu cycles off of a lookup that ends up using the
> default route on sparc64.  From about ~438 cycles to ~403.

Did that 438 value include both fib_table_lookup and check_leaf?  Just
curious as the overall gain seems smaller than what I have been seeing
on the x86 system I was testing with, but then again it could just be a
sparc64 thing.

I've started work on a second round of patches.  With any luck they
should be ready by the time the next net-next opens.  My hope is to cut
the look-up time by another 30 to 50%, though it will take some time as
I have to go though and drop the leaf_info structure, and look at
splitting the tnode in half to break the key/pos/bits and child pointer
dependency chain which will hopefully allow for a significant reduction
in memory read stalls.

I am also planning to take a look at addressing the memory waste that
occurs on nodes larger than 256 bytes due to the way kmalloc allocates
memory as powers of 2.  I'm thinking I might try encouraging the growth
of smaller nodes, and discouraging anything over 256 by implementing a
"truesize" type logic that can be used in the inflate/halve functions so
that the memory usage is more accurately reflected.

- Alex
