From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] [NET] Size listen hash tables using backlog hint
Date: Thu, 19 Oct 2006 10:29:00 +0200
Message-ID: <200610191029.00720.dada1@cosmosbay.com>
References: <4537095A.9010705@cosmosbay.com> <45371C8D.20603@cosmosbay.com> <20061018.235747.74746971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:16066 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1030275AbWJSI3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 04:29:00 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061018.235747.74746971.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 19 October 2006 08:57, David Miller wrote:

> Switch to vmalloc() at the kmalloc() cut-off point, just like
> I did for the other hashes in the tree.

Yes, so you basically want option 4) :)


4) Use vmalloc() if size_lopt > PAGE_SIZE

keep a power_of two :
nr_table_entries = 2 ^ X;

size_lopt = sizeof(listen_sock) + nr_table_entries*sizeof(void*);
if (size > PAGE_SIZE)
  ptr = vmalloc(size_lopt);
else
  ptr = kmalloc(size_lopt);

Pros :
Only under one page is wasted (ie allocated but not used)
vmalloc() is nicer for NUMA, so I am pleased :)
vmalloc() has more chances to succeed when memory is fragmented
keep a power-of-two hash table size

Cons :
TLB cost

// for reference
struct listen_sock {
        u8                      max_qlen_log;
        /* 3 bytes hole, try to use */
        int                     qlen;
        int                     qlen_young;
        int                     clock_hand;
        u32                     hash_rnd;
        u32                     nr_table_entries;
        struct request_sock     *syn_table[0]; /* hash table follow this 
header */
};



> BTW, this all reminds me that we need to be careful that this
> isn't allowing arbitrary users to eat up a ton of unswappable
> ram.  It's pretty easy to open up a lot of listening sockets :)

With actual somaxconn=128 limit, my patch ends in allocating less ram (half of 
a page) than current x86_64 kernel (2 pages)

Thank you

