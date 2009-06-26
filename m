From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 08:03:02 +0000
Message-ID: <20090626080302.GB5204@ff.dom.local>
References: <4A43E9F1.90209@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:40130 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbZFZIDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 04:03:06 -0400
Received: by bwz9 with SMTP id 9so1860281bwz.37
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 01:03:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A43E9F1.90209@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25-06-2009 23:19, Eric Dumazet wrote:
> Pawe? Staszewski a ?crit :
>> Hello ALL
>>
>> Some time ago i report this:
>> http://bugzilla.kernel.org/show_bug.cgi?id=6648
>>
>> and now with 2.6.29 / 2.6.29.1 / 2.6.29.3 and 2.6.30 it back
>> dmesg output:
>> oprofile: using NMI interrupt.
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
>> Fix inflate_threshold_root. Now=15 size=11 bits
> 
> Curious, you seem to hit an old alloc_pages limit()... (MAX_ORDER allocation)
> 
> Your root node has 2^18 = 262144 pointers of 8 bytes -> 2097152 bytes (+ header -> 4194304 bytes)
> 
> But since following commit, we should use vmalloc() so this PAGE_SIZE<<10) limit
> should not anymore be applied.
> 

On the other hand, even if there is no problem with memory, it seems
because of hitting max_resize the threshold should be changed, e.g.
by reverting the patch below.

Jarek P.


commit 965ffea43d4ebe8cd7b9fee78d651268dd7d23c5
Author: Robert Olsson <robert.olsson@its.uu.se>
Date:   Mon Mar 19 16:29:58 2007 -0700

    [IPV4]: fib_trie root node settings
    
    The threshold for root node can be more aggressive set to get
    better tree compression. The new setting mekes the root grow
    from 16 to 19 bits and substansial improvemnt in Aver depth
    this with the current table of 214393 prefixes
    
    But really the dynamic resize should need more investigation
    both in terms convergence and performance and maybe it should
    be possible to change...
    
    Maybe just for the brave to start with or we may have to back
    this out.

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 5d2b43d..9be7da7 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -292,8 +292,8 @@ static inline void check_tnode(const struct tnode *tn)
 
 static int halve_threshold = 25;
 static int inflate_threshold = 50;
-static int halve_threshold_root = 15;
-static int inflate_threshold_root = 25;
+static int halve_threshold_root = 8;
+static int inflate_threshold_root = 15;
 
 
 static void __alias_free_mem(struct rcu_head *head)
