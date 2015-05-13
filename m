From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink & rhashtable status
Date: Wed, 13 May 2015 09:18:04 -0700
Message-ID: <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431495036.566.126.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513054037.GA26595@gondor.apana.org.au>
	 <1431497740.566.129.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513062038.GA26944@gondor.apana.org.au>
	 <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34907 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965622AbbEMQSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 12:18:06 -0400
Received: by iebpz10 with SMTP id pz10so36869215ieb.2
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 09:18:06 -0700 (PDT)
In-Reply-To: <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-13 at 06:04 -0700, Eric Dumazet wrote:
> On Wed, 2015-05-13 at 14:20 +0800, Herbert Xu wrote:
> > On Tue, May 12, 2015 at 11:15:40PM -0700, Eric Dumazet wrote:
> > > 
> > > Trick is to start about 200 threads using getaddrinfo()
> > 
> > When it loses the kernel socket, is it permanent or intermittent?
> > 
> > I'm trying to figure out whether it's the hashtable reader missing
> > an entry that's there or whether the hashtable has been corrupted
> > and an entry is gone forever.
> > 
> > Cheers,
> 
> This is permanent. We have to reboot the host.
> 

For 4.0.3 I replaced the two rhashtable files by current Linus version,
and problem is gone, so the fix is not in net/netlink

 include/linux/rhashtable.h |   10 
 lib/rhashtable.c           |  582 ++++++++++++-----------------------
 2 files changed, 215 insertions(+), 377 deletions(-)

I did a bisection but ended to 

393619474ec0 rhashtable: Fix read-side crash during rehash

And simply backporting it does not solve the problem

$ git log --no-merges --oneline v4.0.3..master include/linux/rhashtable.h lib/rhashtable.c
1d8dc3d3c8f1 rhashtable: don't attempt to grow when at max_size
a87b9ebf1709 rhashtable: Do not schedule more than one rehash if we can't grow further
e2307ed6cbe7 rhashtable: Schedule async resize when sync realloc fails
49f7b33e63fe rhashtable: provide len to obj_hashfn
6b6f302ceda7 rhashtable: Add rhashtable_free_and_destroy()
b5e2c150ac91 rhashtable: Disable automatic shrinking by default
ac833bddb591 rhashtable: Mark internal/private inline functions as such
299e5c32a37a rhashtable: Use 'unsigned int' consistently
58be8a583d8d rhashtable: Extend RCU read lock into rhashtable_insert_rehash()
27ed44a5d6d8 rhashtable: Add comment on choice of elasticity value
ba7c95ea3870 rhashtable: Fix sleeping inside RCU critical section in walk_stop
ccd57b1bd324 rhashtable: Add immediate rehash during insertion
b9ecfdaa1090 rhashtable: Allow GFP_ATOMIC bucket table allocation
b824478b2145 rhashtable: Add multiple rehash support
18093d1c0d1e rhashtable: Shrink to fit
31ccde2dacea rhashtable: Allow hashfn to be unset
de91b25c8011 rhashtable: Eliminate unnecessary branch in rht_key_hashfn
d88252f9bb74 rhashtable: Add barrier to ensure we see new tables in walker
6626af692692 rhashtable: Fix undeclared EEXIST build error on ia64
dc0ee268d850 rhashtable: Rip out obsolete out-of-line interface
02fd97c3d4a8 rhashtable: Allow hash/comparison functions to be inlined
488fb86ee91d rhashtable: Make rhashtable_init params argument const
a998f712f77e rhashtable: Round up/down min/max_size to ensure we respect limit
e2e21c1c5808 rhashtable: Remove max_shift and min_shift
c2e213cff701 rhashtable: Introduce max_size/min_size
6aebd940840a rhashtable: Remove shift from bucket_table
617011e7d555 rhashtable: Avoid calculating hash again to unlock
db4374f48a6c rhashtable: Annotate RCU locking of walkers
565e86404e4c rhashtable: Fix rhashtable_remove failures
963ecbd41a10 rhashtable: Fix use-after-free in rhashtable_walk_stop
c4db8848af6a rhashtable: Move future_tbl into struct bucket_table
63d512d0cffc rhashtable: Add rehash counter to bucket_table
9d901bc05153 rhashtable: Free bucket tables asynchronously after rehash
5269b53da4d4 rhashtable: Move seed init into bucket_table_alloc
8f2484bdb55d rhashtable: Use SINGLE_DEPTH_NESTING
eddee5ba34eb rhashtable: Fix walker behaviour during rehash
393619474ec0 rhashtable: Fix read-side crash during rehash
a5b6846f9e1a rhashtable: kill ht->shift atomic operations
9497df88ab55 rhashtable: Fix reader/rehash race
ec9f71c59e00 rhashtable: Remove obj_raw_hashfn
cffaa9cb9224 rhashtable: Remove key length argument to key_hashfn
eca849333017 rhashtable: Use head_hashfn instead of obj_raw_hashfn
8d2b18793d16 rhashtable: Move masking back into key_hashfn
84ed82b74dcb rhashtable: Add annotation to nested lock
aa34a6cb0478 rhashtable: Add arbitrary rehash function
988dfbd795cf rhashtable: Move hash_rnd into bucket_table
