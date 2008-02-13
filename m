From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: Re: BUG: 2.6.25-rc1: iptables postrouting setup causes oops
Date: Wed, 13 Feb 2008 12:29:47 +0100
Message-ID: <20080213122947.7345c7b7@dhcp-252-066.norway.atmel.com>
References: <1202816761.3299.19.camel@moss.renham>
	<20080213004829.fd8afdc7.akpm@linux-foundation.org>
	<20080213101024.39347322@dhcp-252-066.norway.atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ben Nizette <bn@niasdigital.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:52605 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755176AbYBMLaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 06:30:04 -0500
In-Reply-To: <20080213101024.39347322@dhcp-252-066.norway.atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Feb 2008 10:10:24 +0100
Haavard Skinnemoen <hskinnemoen@atmel.com> wrote:

> > > ip_tables: (C) 2000-2006 Netfilter Core Team
> > > nf_conntrack version 0.5.0 (1024 buckets, 4096 max)
> > > Unable to handle kernel paging request at virtual address d76a7138
> > > ptbr = 91d3b000 pgd = 0000e5f3 pte = 00014370  
> 
> Hmm. It actually found something in the pte? Looks like a swap
> entry...but that doesn't make sense at that virtual address. Userspace
> is below 0x80000000.

(...)

> > If so, the bug could be almost anywhere - in slab, or in some random piece
> > of code which scribbles on slab's data structures.  
> 
> Yes, it looks like memory corruption, especially since the page table
> appears to be corrupted as well. But I'll have a look and see if the
> code that dumps the pte is doing something bogus...

Yes, that code is indeed buggy. The below patch should fix it, although
the page tables probably won't contain anything interesting, and it
could still be a memory corruption issue. And it definitely won't fix
the real issue.

I have a couple of patches that will eliminate the need for this fixup
(and probably improve performance as well), but they are probably 2.6.26
material.

Haavard

diff --git a/arch/avr32/mm/fault.c b/arch/avr32/mm/fault.c
index 6560cb1..ce4e429 100644
--- a/arch/avr32/mm/fault.c
+++ b/arch/avr32/mm/fault.c
@@ -189,6 +189,8 @@ no_context:
 
 	page = sysreg_read(PTBR);
 	printk(KERN_ALERT "ptbr = %08lx", page);
+	if (address >= TASK_SIZE)
+		page = (unsigned long)swapper_pg_dir;
 	if (page) {
 		page = ((unsigned long *)page)[address >> 22];
 		printk(" pgd = %08lx", page);
