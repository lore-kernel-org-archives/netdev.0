From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [RFC PATCH 02/17] fib_trie: Make leaf and tnode more uniform
Date: Mon, 22 Dec 2014 15:38:53 -0800
Message-ID: <5498AB8D.8070301@redhat.com>
References: <20141222174105.1119.71598.stgit@ahduyck-vm-fedora20>	<20141222.133353.2244861758408916536.davem@davemloft.net>	<54986915.6050906@redhat.com> <20141222.165015.1694288362513627826.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51451 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751162AbaLVXiz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 18:38:55 -0500
In-Reply-To: <20141222.165015.1694288362513627826.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/22/2014 01:50 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Mon, 22 Dec 2014 10:55:17 -0800
>
>> My real concern with all of this is the fact that we have to do 2
>> separate memory reads per node, one for the key info and one for the
>> child pointer.  I really think we need to get this down to 1 in order
>> to get there, but the overhead is the tricky part for that. What I
>> would look at doing is splitting the tnode into two parts. One would
>> be a key vector (key, pos, bits, seq) paired with a pointer to either
>> a tnode_info or leaf_info, the other would be something like a
>> tnode_info (rcu, parent pointer, full_children, empty_children, key
>> vector array[0]) that provides a means of backtracing and stores the
>> nodes.  The problem is it makes insertion/deletion and backtracking
>> more complicated and doubles (64b) or quadruples (32b) the memory
>> needed as such I am still just throwing the idea around and haven't
>> gotten into implementation yet.
> I think calling into this code twice for every non-local FIB lookup
> has costs as well.

Agreed.  I remember when you sent me the patch to test out merging the 
two tries a few years back that did make a significant difference.

By my math the difference with these patches is probably around 26ns 
extra, 113ns vs 87ns, to do the second table lookup.  The changes in 
adding/checking the suffix length and the fact that we validate the key 
is usable as a prefix before reading the leaf_info made the first table 
lookup much cheaper than it was before so merging the tables should 
provide less of a gain.

What it will come down to is if the cost to backtrack however many bits 
it takes to get to the route is greater than the cost to start the 
search over in the main trie.  In the case of subnets with a short 
prefix you may end up finding that the cost to backtrack will be more 
expensive for addresses at the end of the address range with a large 
number of bits set in the host identifier.

> And yes I agree with you that the memory references matter a lot.

Especially now.  Considering the loop for lookup is fairly small the 
only thing that is really holding it back is the memory access latency.  
That is why I am playing around with the idea of doubling the memory 
footprint for the trie just to make it so that the key and the pointer 
could co-exist in the same 16B region.  I'm hoping it would allow us to 
cut total memory access latency in half and double the speed at which we 
could process tnodes.

Thanks for the feedback.

- Alex
