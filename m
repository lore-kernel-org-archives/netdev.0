From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/5] rhashtable: Remove gfp_flags from insert and remove
 functions
Date: Mon, 15 Sep 2014 13:49:37 +0100
Message-ID: <20140915124937.GB21541@casper.infradead.org>
References: <cover.1410782841.git.tgraf@suug.ch>
 <bd3aa4282e89b022620225101ab491e344852f5f.1410782841.git.tgraf@suug.ch>
 <1410784535.7106.164.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, paulmck@linux.vnet.ibm.com,
	john.r.fastabend@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1410784535.7106.164.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/15/14 at 05:35am, Eric Dumazet wrote:
> On Mon, 2014-09-15 at 14:18 +0200, Thomas Graf wrote:
> > As the expansion/shrinking is moved to a worker thread, no allocations
> > will be performed anymore.
> > 
> 
> You meant : no GFP_ATOMIC allocations ?
> 
> I would rephrase using something like :
> 
> Because hash resizes are potentially time consuming, they'll be
> performed in process context where GFP_KERNEL allocations are preferred.

I meant to say no allocations in insert/remove anymore but your wording
is even clearer. I'll update it.

> > -	tbl = kzalloc(size, flags);
> > +	tbl = kzalloc(size, GFP_KERNEL);
> 
> Add __GFP_NOWARN, as you fallback to vzalloc ?

Good point.

> btw, inet hash table uses alloc_large_system_hash() which spreads the
> pages on all available NUMA nodes :
> 
> # dmesg | grep "TCP established"
> [    1.223046] TCP established hash table entries: 524288 (order: 10, 4194304 bytes)
> # grep alloc_large_system_hash /proc/vmallocinfo | grep pages=1024
> 0xffffc900181d6000-0xffffc900185d7000 4198400 alloc_large_system_hash+0x177/0x237 pages=1024 vmalloc vpages N0=512 N1=512
> 0xffffc900185d7000-0xffffc900189d8000 4198400 alloc_large_system_hash+0x177/0x237 pages=1024 vmalloc vpages N0=512 N1=512
> 0xffffc90028a01000-0xffffc90028e02000 4198400 alloc_large_system_hash+0x177/0x237 pages=1024 vmalloc vpages N0=512 N1=512
> 
> So we might keep in mind to keep this numa policy.

Agreed. Will introduce this through a table parameter option when
converting the inet hash table.
