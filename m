From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [RFC PATCH 02/17] fib_trie: Make leaf and tnode more uniform
Date: Mon, 22 Dec 2014 10:55:17 -0800
Message-ID: <54986915.6050906@redhat.com>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>	<20141222174105.1119.71598.stgit@ahduyck-vm-fedora20> <20141222.133353.2244861758408916536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34289 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754394AbaLVSzT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 13:55:19 -0500
In-Reply-To: <20141222.133353.2244861758408916536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/22/2014 10:33 AM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Mon, 22 Dec 2014 09:41:05 -0800
>
>> -#define IS_TNODE(n) (!(n->parent & T_LEAF))
>> -#define IS_LEAF(n) (n->parent & T_LEAF)
>> +struct tnode {
>> +	t_key key;
>> +	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
>> +	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
>> +	struct tnode __rcu *parent;
>> +	union {
>> +		struct rcu_head rcu;
>> +		struct tnode *tnode_free;
>> +	};
>> +	unsigned int full_children;	/* KEYLENGTH bits needed */
>> +	unsigned int empty_children;	/* KEYLENGTH bits needed */
>> +	struct rt_trie_node __rcu *child[0];
>> +};
> I wonder if we can compress this even further.
>
> The full_children and empty_children can probably both be a u16, right?
> If so, you can stick at least one of them after 'bits' and 'pos' and
> thus save 4 bytes on 32b.

The thing is I don't think we would actually be saving any space. The 
slub allocator will round us up anyway.  On a 32b system the size is 28B 
if I recall correctly.  Dropping it to 24B would mean only a 2 child 
node could be allocated from the 32B slab.  Anything larger than that it 
wouldn't matter.

My real concern with all of this is the fact that we have to do 2 
separate memory reads per node, one for the key info and one for the 
child pointer.  I really think we need to get this down to 1 in order to 
get there, but the overhead is the tricky part for that. What I would 
look at doing is splitting the tnode into two parts. One would be a key 
vector (key, pos, bits, seq) paired with a pointer to either a 
tnode_info or leaf_info, the other would be something like a tnode_info 
(rcu, parent pointer, full_children, empty_children, key vector 
array[0]) that provides a means of backtracing and stores the nodes.  
The problem is it makes insertion/deletion and backtracking more 
complicated and doubles (64b) or quadruples (32b) the memory needed as 
such I am still just throwing the idea around and haven't gotten into 
implementation yet.

- Alex
