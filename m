From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc8 network problem.  Mem leak?  ip1000a?
Date: Sun, 30 Sep 2007 02:23:47 -0700
Message-ID: <20070930022347.37514be3.akpm@linux-foundation.org>
References: <20070928022051.a6f27b1e.akpm@linux-foundation.org>
	<20070930075956.11935.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44104 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751045AbXI3JYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 05:24:36 -0400
In-Reply-To: <20070930075956.11935.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30 Sep 2007 03:59:56 -0400 linux@horizon.com wrote:

> > ntpd.  Sounds like pps leaking to me.
> 
> That's what I'd think, except that pps does no allocation in the normal
> running state, so there's nothing to leak.  The interrupt path just
> records the time in some preallocated, static buffers and wakes up
> blocked readers.  The read path copies the latest data out of those
> static buffers.  There's allocation when the PPS device is created,
> and more when it's opened.

OK.  Did you try to reproduce it without the pps patch applied?

> >> Can anyone offer some diagnosis advice?
> 
> > CONFIG_DEBUG_SLAB_LEAK?
> 
> Ah, thanks you; I've been using SLUB which doesn't support this option.
> Here's what I've extracted.  I've only presented the top few
> slab_allocators and a small subset of the oom-killer messages, but I
> have full copies if desired.  Unfortunately, I've discovered that the
> machine doesn't live in this unhappy state forever.  Indeed, I'm not
> sure if killing ntpd "fixes" anything; my previous observations
> may have been optimistic ignorance.
> 
> (For my own personal reference looking for more oom-kill, I nuked ntpd
> at 06:46:56.  And the oom-kills are continuing, with the latest at
> 07:43:52.)
> 
> Anyway, I have a bunch of information from the slab_allocators file, but
> I'm not quire sure how to make sense of it.
> 
> 
> With a machine in the unhappy state and firing the OOM killer, the top
> 20 slab_allocators are:
> $ sort -rnk2 /proc/slab_allocators | head -20
> skbuff_head_cache: 1712746 __alloc_skb+0x31/0x121
> size-512: 1706572 tcp_send_ack+0x23/0x102
> skbuff_fclone_cache: 149113 __alloc_skb+0x31/0x121
> size-2048: 148500 tcp_sendmsg+0x1b5/0xae1
> sysfs_dir_cache: 5289 sysfs_new_dirent+0x4b/0xec
> size-512: 2613 sock_alloc_send_skb+0x93/0x1dd
> Acpi-Operand: 2014 acpi_ut_allocate_object_desc_dbg+0x34/0x6e
> size-32: 1995 sysfs_new_dirent+0x29/0xec
> vm_area_struct: 1679 mmap_region+0x18f/0x421
> size-512: 1618 tcp_xmit_probe_skb+0x1f/0xcd
> size-512: 1571 arp_create+0x4e/0x1cd
> vm_area_struct: 1544 copy_process+0x9f1/0x1108
> anon_vma: 1448 anon_vma_prepare+0x29/0x74
> filp: 1201 get_empty_filp+0x44/0xcd
> UDP: 1173 sk_alloc+0x25/0xaf
> size-128: 1048 r1bio_pool_alloc+0x23/0x3b
> size-128: 1024 nfsd_cache_init+0x2d/0xcf
> Acpi-Namespace: 973 acpi_ns_create_node+0x2c/0x45
> vm_area_struct: 717 split_vma+0x33/0xe5
> dentry: 594 d_alloc+0x24/0x177
> 
> I'm not sure quite what "normal" numbers are, but I do wonder why there
> are 1.7 million TCP acks buffered in the system.  Shouldn't they be
> transmitted and deallocated pretty quickly?

Yeah, that's an skbuff leak.

> This machine receives more data than it sends, so I'd expect acks to
> outnumber "real" packets.  Could the ip1000a driver's transmit path be
> leaking skbs somehow?

Absolutely.  Normally a driver's transmit completion interrupt handler will
run dev_kfree_skb_irq() against the skbs which have been fully sent.

However it'd be darned odd if the driver was leaking only tcp acks.

I can find no occurrence of "dev_kfree_skb" in drivers/net/ipg.c, which is
suspicious.

Where did you get your ipg.c from, btw?  davem's tree?  rc8-mm1? rc8-mm2??

>  that would also explain the "flailing" of the
> oom-killer; it can't associate the allocations with a process.
> 
> Here's /proc/meminfo:
> MemTotal:      1035756 kB
> MemFree:         43508 kB
> Buffers:         72920 kB
> Cached:         224056 kB
> SwapCached:     344916 kB
> Active:         664976 kB
> Inactive:       267656 kB
> SwapTotal:     4950368 kB
> SwapFree:      3729384 kB
> Dirty:            6460 kB
> Writeback:           0 kB
> AnonPages:      491708 kB
> Mapped:          79232 kB
> Slab:            41324 kB
> SReclaimable:    25008 kB
> SUnreclaim:      16316 kB
> PageTables:       8132 kB
> NFS_Unstable:        0 kB
> Bounce:              0 kB
> CommitLimit:   5468244 kB
> Committed_AS:  1946008 kB
> VmallocTotal:   253900 kB
> VmallocUsed:      2672 kB
> VmallocChunk:   251228 kB

I assume that meminfo was not captured when the system was ooming?  There
isn't much slab there.

