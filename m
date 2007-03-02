From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Fri, 2 Mar 2007 13:28:38 +0300
Message-ID: <20070302102837.GA13951@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <20070217131302.GA22732@2ka.mipt.ru> <20070302085246.GA30951@2ka.mipt.ru> <200703021056.24100.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47492 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933345AbXCBKel (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 05:34:41 -0500
Content-Disposition: inline
In-Reply-To: <200703021056.24100.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 02, 2007 at 10:56:23AM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> On Friday 02 March 2007 09:52, Evgeniy Polyakov wrote:
> 
> > Ok, I've ran an analysis of linked lists and trie traversals and found
> > that (at least on x86) optimized one list traversal is about 4 (!)
> > times faster than one bit lookup in trie traversal (or actually one
> > lookup in binary tree-like structure) - that is because of the fact
> > that trie traversal needs to have more instructions per lookup, and at
> > least one additional branch which can not be predicted.
> >
> > Tests with rdtsc shows that one bit lookup in trie (actually it is any
> > lookup in binary tree structures) is about 3-4 times slower than one
> > lookup in linked list.
> >
> > Since hash table usually has upto 4 elements in each hash entry,
> > competing binary tree/trie stucture must get an entry in one lookup,
> > which is essentially impossible with usual tree/trie implementations.
> >
> > Things dramatically change when linked list became too long, but it
> > should not happend with proper resizing of the hash table, wildcards
> > implementation also introduce additional requirements, which can not be
> > easily solved in hash tables.
> >
> > So I get my words about tree/trie implementation instead of hash table
> > for socket lookup back.
> >
> > Interested reader can find more details on tests, asm outputs and
> > conclusions at:
> > http://tservice.net.ru/~s0mbre/blog/2007/03/01#2007_03_01
> 
> Thank you for this report. (Still avoiding cache misses studies, while they 
> obviously are the limiting factor)
> 
> Anyqay, if data is in cache and you want optimum performance from your cpu,
> you may try to use an algorithm without conditional branches :
> (well 4 in this case for the whole 32 bits tests)

Tests were always for no-cache-miss case.
I also ran them in kenel mode (to eliminate tlb flushes per rescheduling
and to get into account that kernel tlb covers 8mb while userspace only
4k), but results were essentially the same (modulo several percents). I
only tested trie, in my impementation its memory usage is smaller than
hash table for 2^20 entries.

> gcc -O2 -S -march=i686 test1.c
> 

> struct node {
> 	struct node *left;
> 	struct node *right;
> 	int value;
> 	};
> struct node *head;
> int v1;
> 
> #define PASS2(bit) \
> 	n2 = n1->left; \
> 	right = n1->right; \
>     if (value & (1<<bit)) \
>         n2 = right; \
> 	n1 = n2->left; \
> 	right = n2->right; \
> 	if (value & (2<<bit)) \
> 		n1 = right;
> 
> main()
> {
> int j;
> unsigned int value = v1;
> struct node *n1 = head, *n2, *right;
> for (j=0; j<4; ++j) {
> 	PASS2(0)
> 	PASS2(2)
> 	PASS2(4)
> 	PASS2(6)
> 	value >>= 8;
> 	}
> printf("result=%p\n", n1);
> }

This one resulted in 10*4 and 2*4 branches per loop.
So total 32 branches (instead of 64 in simpler code) and 160
instructions (instead of 128 in simpler code).
Getting that branch is two times longer to execute (though it is quite
strange sentence, but I must admit, that I did not read x86 processor
manual at all (only ppc32)) according to tests, we do not get any gain
for 32bit value (32 lookups): 64*2+128 in old case, 32*2+160 in new one.

I also have advanced trie implementation, which caches values in nodes
if there are no child entries, and it _greatly_ decrease number of
lookups and memory usage for smaller sets, but in long run and huge 
amount of entries in trie, it does not matter since only the 
lowest layer caches values.

-- 
	Evgeniy Polyakov
