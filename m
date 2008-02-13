From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: Re: BUG: 2.6.25-rc1: iptables postrouting setup causes oops
Date: Wed, 13 Feb 2008 10:10:24 +0100
Message-ID: <20080213101024.39347322@dhcp-252-066.norway.atmel.com>
References: <1202816761.3299.19.camel@moss.renham>
	<20080213004829.fd8afdc7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Nizette <bn@niasdigital.com>, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:51270 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932493AbYBMJLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 04:11:12 -0500
In-Reply-To: <20080213004829.fd8afdc7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Feb 2008 00:48:29 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 12 Feb 2008 22:46:01 +1100 Ben Nizette <bn@niasdigital.com> wrote:
> 
> > 
> > On an AVR32, root over NFS, config attached, running (from a startup
> > script):
> > 
> > iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
> > 
> > Results in (dmesg extract including a bit of context for good measure):
> > -------------8<----------------
> > VFS: Mounted root (nfs filesystem).
> > Freeing init memory: 72K (90000000 - 90012000)
> > eth0: no IPv6 routers present
> > warning: `dnsmasq' uses 32-bit capabilities (legacy support in use)

Hmm. What does that mean? What size do capabilities normally have?

> > ip_tables: (C) 2000-2006 Netfilter Core Team
> > nf_conntrack version 0.5.0 (1024 buckets, 4096 max)
> > Unable to handle kernel paging request at virtual address d76a7138
> > ptbr = 91d3b000 pgd = 0000e5f3 pte = 00014370

Hmm. It actually found something in the pte? Looks like a swap
entry...but that doesn't make sense at that virtual address. Userspace
is below 0x80000000.

> > Oops: Kernel access of bad area, sig: 11 [#1]
> > FRAME_POINTER chip: 0x01f:0x1e82 rev 2
> > Modules linked in: nf_conntrack_ipv4(+) nf_conntrack ip_tables
> > PC is at kmem_cache_alloc+0x2c/0x54
> > LR is at nf_conntrack_l4proto_register+0x34/0x9c [nf_conntrack]
> 
> I take it that the above means that the crash is in kmem_cache_alloc()?

That's correct.

> If so, the bug could be almost anywhere - in slab, or in some random piece
> of code which scribbles on slab's data structures.

Yes, it looks like memory corruption, especially since the page table
appears to be corrupted as well. But I'll have a look and see if the
code that dumps the pte is doing something bogus...

> > Perfectly repeatable.
> 
> If my theory is correct, changing pretty much anything in the kernel config
> might just make it go away.  But still, it would be most valuable if you
> could try running a bisection search, as described in
> http://www.kernel.org/doc/local/git-quick.html, thanks.

Yes, that would be very valuable.

Haavard
