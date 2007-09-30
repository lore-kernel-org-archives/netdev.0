From: linux@horizon.com
Subject: Re: 2.6.23-rc8 network problem.  Mem leak?  ip1000a?
Date: 30 Sep 2007 03:59:56 -0400
Message-ID: <20070930075956.11935.qmail@science.horizon.com>
References: <20070928022051.a6f27b1e.akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org, linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:15696 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753943AbXI3H77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 03:59:59 -0400
In-Reply-To: <20070928022051.a6f27b1e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> ntpd.  Sounds like pps leaking to me.

That's what I'd think, except that pps does no allocation in the normal
running state, so there's nothing to leak.  The interrupt path just
records the time in some preallocated, static buffers and wakes up
blocked readers.  The read path copies the latest data out of those
static buffers.  There's allocation when the PPS device is created,
and more when it's opened.

>> Can anyone offer some diagnosis advice?

> CONFIG_DEBUG_SLAB_LEAK?

Ah, thanks you; I've been using SLUB which doesn't support this option.
Here's what I've extracted.  I've only presented the top few
slab_allocators and a small subset of the oom-killer messages, but I
have full copies if desired.  Unfortunately, I've discovered that the
machine doesn't live in this unhappy state forever.  Indeed, I'm not
sure if killing ntpd "fixes" anything; my previous observations
may have been optimistic ignorance.

(For my own personal reference looking for more oom-kill, I nuked ntpd
at 06:46:56.  And the oom-kills are continuing, with the latest at
07:43:52.)

Anyway, I have a bunch of information from the slab_allocators file, but
I'm not quire sure how to make sense of it.


With a machine in the unhappy state and firing the OOM killer, the top
20 slab_allocators are:
$ sort -rnk2 /proc/slab_allocators | head -20
skbuff_head_cache: 1712746 __alloc_skb+0x31/0x121
size-512: 1706572 tcp_send_ack+0x23/0x102
skbuff_fclone_cache: 149113 __alloc_skb+0x31/0x121
size-2048: 148500 tcp_sendmsg+0x1b5/0xae1
sysfs_dir_cache: 5289 sysfs_new_dirent+0x4b/0xec
size-512: 2613 sock_alloc_send_skb+0x93/0x1dd
Acpi-Operand: 2014 acpi_ut_allocate_object_desc_dbg+0x34/0x6e
size-32: 1995 sysfs_new_dirent+0x29/0xec
vm_area_struct: 1679 mmap_region+0x18f/0x421
size-512: 1618 tcp_xmit_probe_skb+0x1f/0xcd
size-512: 1571 arp_create+0x4e/0x1cd
vm_area_struct: 1544 copy_process+0x9f1/0x1108
anon_vma: 1448 anon_vma_prepare+0x29/0x74
filp: 1201 get_empty_filp+0x44/0xcd
UDP: 1173 sk_alloc+0x25/0xaf
size-128: 1048 r1bio_pool_alloc+0x23/0x3b
size-128: 1024 nfsd_cache_init+0x2d/0xcf
Acpi-Namespace: 973 acpi_ns_create_node+0x2c/0x45
vm_area_struct: 717 split_vma+0x33/0xe5
dentry: 594 d_alloc+0x24/0x177

I'm not sure quite what "normal" numbers are, but I do wonder why there
are 1.7 million TCP acks buffered in the system.  Shouldn't they be
transmitted and deallocated pretty quickly?

This machine receives more data than it sends, so I'd expect acks to
outnumber "real" packets.  Could the ip1000a driver's transmit path be
leaking skbs somehow?  that would also explain the "flailing" of the
oom-killer; it can't associate the allocations with a process.

Here's /proc/meminfo:
MemTotal:      1035756 kB
MemFree:         43508 kB
Buffers:         72920 kB
Cached:         224056 kB
SwapCached:     344916 kB
Active:         664976 kB
Inactive:       267656 kB
SwapTotal:     4950368 kB
SwapFree:      3729384 kB
Dirty:            6460 kB
Writeback:           0 kB
AnonPages:      491708 kB
Mapped:          79232 kB
Slab:            41324 kB
SReclaimable:    25008 kB
SUnreclaim:      16316 kB
PageTables:       8132 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:   5468244 kB
Committed_AS:  1946008 kB
VmallocTotal:   253900 kB
VmallocUsed:      2672 kB
VmallocChunk:   251228 kB

I have a lot of oom-killer messages, that I have saved but am not
posting for size reasons, but here are some example backtraces.
They're not very helpful to me; do they enlighten anyone else?

02:50:20: apcupsd invoked oom-killer: gfp_mask=0xd0, order=1, oomkilladj=0
02:50:22: 
02:50:22: Call Trace:
02:50:22:  [<ffffffff80246053>] out_of_memory+0x71/0x1ba
02:50:22:  [<ffffffff8024755d>] __alloc_pages+0x255/0x2d7
02:50:22:  [<ffffffff8025cbd6>] cache_alloc_refill+0x2f4/0x60a
02:50:22:  [<ffffffff8040602c>] hiddev_ioctl+0x579/0x919
02:50:22:  [<ffffffff8025d0fc>] kmem_cache_alloc+0x57/0x95
02:50:22:  [<ffffffff8040602c>] hiddev_ioctl+0x579/0x919
02:50:22:  [<ffffffff80262511>] cp_new_stat+0xe5/0xfd
02:50:22:  [<ffffffff804058ff>] hiddev_read+0x199/0x1f6
02:50:22:  [<ffffffff80222fa0>] default_wake_function+0x0/0xe
02:50:22:  [<ffffffff80269bb5>] do_ioctl+0x45/0x50
02:50:22:  [<ffffffff80269db9>] vfs_ioctl+0x1f9/0x20b
02:50:22:  [<ffffffff80269e07>] sys_ioctl+0x3c/0x5d
02:50:22:  [<ffffffff8020b43e>] system_call+0x7e/0x83

02:52:18: postgres invoked oom-killer: gfp_mask=0xd0, order=1, oomkilladj=0
02:52:18: 
02:52:18: Call Trace:
02:52:18:  [<ffffffff80246053>] out_of_memory+0x71/0x1ba
02:52:18:  [<ffffffff8024755d>] __alloc_pages+0x255/0x2d7
02:52:18:  [<ffffffff8025be8a>] poison_obj+0x26/0x2f
02:52:18:  [<ffffffff8024761f>] __get_free_pages+0x40/0x79
02:52:18:  [<ffffffff80224d66>] copy_process+0xb0/0x1108
02:52:18:  [<ffffffff80233388>] alloc_pid+0x1f/0x27d
02:52:18:  [<ffffffff80225ed6>] do_fork+0xb1/0x1a7
02:52:18:  [<ffffffff802f0627>] copy_user_generic_string+0x17/0x40
02:52:18:  [<ffffffff8020b43e>] system_call+0x7e/0x83
02:52:18:  [<ffffffff8020b757>] ptregscall_common+0x67/0xb0

02:52:18: kthreadd invoked oom-killer: gfp_mask=0xd0, order=1, oomkilladj=0
02:52:18: 
02:52:18: Call Trace:
02:52:18:  [<ffffffff80246053>] out_of_memory+0x71/0x1ba
02:52:18:  [<ffffffff8024755d>] __alloc_pages+0x255/0x2d7
02:52:18:  [<ffffffff8024761f>] __get_free_pages+0x40/0x79
02:52:18:  [<ffffffff80224d66>] copy_process+0xb0/0x1108
02:52:18:  [<ffffffff80233388>] alloc_pid+0x1f/0x27d
02:52:18:  [<ffffffff80225ed6>] do_fork+0xb1/0x1a7
02:52:18:  [<ffffffff80222bb8>] update_curr+0xe6/0x10b
02:52:18:  [<ffffffff8022334d>] dequeue_entity+0x73/0x97
02:52:18:  [<ffffffff8020bd21>] kernel_thread+0x81/0xde
02:52:18:  [<ffffffff802e9c81>] cfq_may_queue+0x0/0xd2
02:52:18:  [<ffffffff802355db>] kthread+0x0/0x75
02:52:18:  [<ffffffff8020bd7e>] child_rip+0x0/0x12
02:52:18:  [<ffffffff802354ad>] kthreadd+0xb4/0xf5
02:52:18:  [<ffffffff8020bd88>] child_rip+0xa/0x12
02:52:18:  [<ffffffff802353f9>] kthreadd+0x0/0xf5
02:52:18:  [<ffffffff8020bd7e>] child_rip+0x0/0x12

02:54:53: apache2 invoked oom-killer: gfp_mask=0xd0, order=1, oomkilladj=0
02:54:53: 
02:54:53: Call Trace:
02:54:53:  [<ffffffff80246053>] out_of_memory+0x71/0x1ba
02:54:53:  [<ffffffff8024755d>] __alloc_pages+0x255/0x2d7
02:54:53:  [<ffffffff8025be8a>] poison_obj+0x26/0x2f
02:54:53:  [<ffffffff8024761f>] __get_free_pages+0x40/0x79
02:54:53:  [<ffffffff80224d66>] copy_process+0xb0/0x1108
02:54:53:  [<ffffffff80233388>] alloc_pid+0x1f/0x27d
02:54:53:  [<ffffffff80225ed6>] do_fork+0xb1/0x1a7
02:54:53:  [<ffffffff8020b43e>] system_call+0x7e/0x83
02:54:53:  [<ffffffff8020b757>] ptregscall_common+0x67/0xb0

02:55:45: ssh invoked oom-killer: gfp_mask=0x4d0, order=2, oomkilladj=0
02:55:45: 
02:55:45: Call Trace:
02:55:45:  [<ffffffff80246053>] out_of_memory+0x71/0x1ba
02:55:45:  [<ffffffff8024755d>] __alloc_pages+0x255/0x2d7
02:55:45:  [<ffffffff8025cbd6>] cache_alloc_refill+0x2f4/0x60a
02:55:45:  [<ffffffff8025be8a>] poison_obj+0x26/0x2f
02:55:45:  [<ffffffff8040e0df>] __alloc_skb+0x31/0x121
02:55:45:  [<ffffffff8040e0df>] __alloc_skb+0x31/0x121
02:55:45:  [<ffffffff8040ab8b>] sock_alloc_send_skb+0x93/0x1dd
02:55:45:  [<ffffffff8025d067>] __kmalloc_track_caller+0x9d/0xdb
02:55:45:  [<ffffffff8040e109>] __alloc_skb+0x5b/0x121
02:55:45:  [<ffffffff8040ab8b>] sock_alloc_send_skb+0x93/0x1dd
02:55:45:  [<ffffffff802f0627>] copy_user_generic_string+0x17/0x40
02:55:45:  [<ffffffff8048155c>] unix_stream_sendmsg+0x151/0x2ea
02:55:45:  [<ffffffff80408349>] sock_aio_write+0xe5/0xf0
02:55:45:  [<ffffffff802437d3>] find_get_page+0xe/0x36
02:55:45:  [<ffffffff8025f9b4>] do_sync_write+0xd1/0x118
02:55:45:  [<ffffffff802357f5>] autoremove_wake_function+0x0/0x2e
02:55:45:  [<ffffffff80222bb8>] update_curr+0xe6/0x10b
02:55:45:  [<ffffffff80260118>] vfs_write+0xc0/0x136
02:55:45:  [<ffffffff802605c2>] sys_write+0x45/0x6e
02:55:45:  [<ffffffff8020b43e>] system_call+0x7e/0x83

03:01:34: smbclient invoked oom-killer: gfp_mask=0x4d0, order=2, oomkilladj=0
03:01:34: 
03:01:34: Call Trace:
03:01:34:  [<ffffffff80246053>] out_of_memory+0x71/0x1ba
03:01:34:  [<ffffffff8024755d>] __alloc_pages+0x255/0x2d7
03:01:34:  [<ffffffff8025cbd6>] cache_alloc_refill+0x2f4/0x60a
03:01:34:  [<ffffffff8025be8a>] poison_obj+0x26/0x2f
03:01:34:  [<ffffffff8040e0df>] __alloc_skb+0x31/0x121
03:01:34:  [<ffffffff8040e0df>] __alloc_skb+0x31/0x121
03:01:34:  [<ffffffff8040ab8b>] sock_alloc_send_skb+0x93/0x1dd
03:01:34:  [<ffffffff8025d067>] __kmalloc_track_caller+0x9d/0xdb
03:01:34:  [<ffffffff8040e109>] __alloc_skb+0x5b/0x121
03:01:34:  [<ffffffff8040ab8b>] sock_alloc_send_skb+0x93/0x1dd
03:01:34:  [<ffffffff8040a8ab>] release_sock+0xe/0x7f
03:01:34:  [<ffffffff8048155c>] unix_stream_sendmsg+0x151/0x2ea
03:01:34:  [<ffffffff80408349>] sock_aio_write+0xe5/0xf0
03:01:34:  [<ffffffff8025f9b4>] do_sync_write+0xd1/0x118
03:01:34:  [<ffffffff802357f5>] autoremove_wake_function+0x0/0x2e
03:01:34:  [<ffffffff80222bb8>] update_curr+0xe6/0x10b
03:01:34:  [<ffffffff80260118>] vfs_write+0xc0/0x136
03:01:34:  [<ffffffff802605c2>] sys_write+0x45/0x6e
03:01:34:  [<ffffffff8020b43e>] system_call+0x7e/0x83

05:48:04: scp invoked oom-killer: gfp_mask=0x4d0, order=1, oomkilladj=0
05:48:04: 
05:48:04: Call Trace:
05:48:04:  [<ffffffff80246053>] out_of_memory+0x71/0x1ba
05:48:04:  [<ffffffff8024755d>] __alloc_pages+0x255/0x2d7
05:48:04:  [<ffffffff8025cbd6>] cache_alloc_refill+0x2f4/0x60a
05:48:04:  [<ffffffff8025be8a>] poison_obj+0x26/0x2f
05:48:04:  [<ffffffff8040e0df>] __alloc_skb+0x31/0x121
05:48:04:  [<ffffffff8040e0df>] __alloc_skb+0x31/0x121
05:48:04:  [<ffffffff8040ab8b>] sock_alloc_send_skb+0x93/0x1dd
05:48:04:  [<ffffffff8025d067>] __kmalloc_track_caller+0x9d/0xdb
05:48:04:  [<ffffffff8040e109>] __alloc_skb+0x5b/0x121
05:48:04:  [<ffffffff8040ab8b>] sock_alloc_send_skb+0x93/0x1dd
05:48:04:  [<ffffffff8048155c>] unix_stream_sendmsg+0x151/0x2ea
05:48:04:  [<ffffffff80243645>] file_read_actor+0x0/0x118
05:48:04:  [<ffffffff80408349>] sock_aio_write+0xe5/0xf0
05:48:04:  [<ffffffff8025f9b4>] do_sync_write+0xd1/0x118
05:48:04:  [<ffffffff802357f5>] autoremove_wake_function+0x0/0x2e
05:48:04:  [<ffffffff80260118>] vfs_write+0xc0/0x136
05:48:04:  [<ffffffff802605c2>] sys_write+0x45/0x6e
05:48:04:  [<ffffffff8020b43e>] system_call+0x7e/0x83

And here's the latest one, in full:

05:48:11: smbclient invoked oom-killer: gfp_mask=0x4d0, order=2, oomkilladj=0
05:48:12: 
05:48:12: Call Trace:
05:48:12:  [<ffffffff80246053>] out_of_memory+0x71/0x1ba
05:48:12:  [<ffffffff8024755d>] __alloc_pages+0x255/0x2d7
05:48:12:  [<ffffffff8025cbd6>] cache_alloc_refill+0x2f4/0x60a
05:48:12:  [<ffffffff8025be8a>] poison_obj+0x26/0x2f
05:48:12:  [<ffffffff8040e0df>] __alloc_skb+0x31/0x121
05:48:12:  [<ffffffff8040e0df>] __alloc_skb+0x31/0x121
05:48:12:  [<ffffffff8040ab8b>] sock_alloc_send_skb+0x93/0x1dd
05:48:12:  [<ffffffff8025d067>] __kmalloc_track_caller+0x9d/0xdb
05:48:12:  [<ffffffff8040e109>] __alloc_skb+0x5b/0x121
05:48:12:  [<ffffffff8040ab8b>] sock_alloc_send_skb+0x93/0x1dd
05:48:12:  [<ffffffff802f0627>] copy_user_generic_string+0x17/0x40
05:48:12:  [<ffffffff8048155c>] unix_stream_sendmsg+0x151/0x2ea
05:48:12:  [<ffffffff80408349>] sock_aio_write+0xe5/0xf0
05:48:12:  [<ffffffff8025f9b4>] do_sync_write+0xd1/0x118
05:48:12:  [<ffffffff802357f5>] autoremove_wake_function+0x0/0x2e
05:48:12:  [<ffffffff80222bb8>] update_curr+0xe6/0x10b
05:48:12:  [<ffffffff80260118>] vfs_write+0xc0/0x136
05:48:12:  [<ffffffff802605c2>] sys_write+0x45/0x6e
05:48:12:  [<ffffffff8020b43e>] system_call+0x7e/0x83
05:48:12: 
05:48:12: Mem-info:
05:48:12: DMA per-cpu:
05:48:12: CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
05:48:12: DMA32 per-cpu:
05:48:12: CPU    0: Hot: hi:  186, btch:  31 usd:  10   Cold: hi:   62, btch:  15 usd:  58
05:48:12: Active:67 inactive:1197 dirty:0 writeback:779 unstable:0
05:48:12:  free:39163 slab:464538 mapped:518 pagetables:1800 bounce:0
05:48:12: DMA free:8040kB min:28kB low:32kB high:40kB active:0kB inactive:0kB present:11132kB pages_scanned:0 all_unreclaimable? yes
05:48:12: lowmem_reserve[]: 0 2003 2003 2003
05:48:12: DMA32 free:148612kB min:5712kB low:7140kB high:8568kB active:268kB inactive:4788kB present:2051184kB pages_scanned:7841 all_unreclaimable? yes
05:48:12: lowmem_reserve[]: 0 0 0 0
05:48:12: DMA: 56*4kB 1*8kB 0*16kB 0*32kB 0*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8040kB
05:48:12: DMA32: 36459*4kB 55*8kB 2*16kB 0*32kB 0*64kB 0*128kB 1*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 148612kB
05:48:12: Swap cache: add 6853288, delete 6852498, find 1146430/2641691, race 0+0
05:48:12: Free swap  = 5213316kB
05:48:12: Total swap = 5855208kB
05:48:12: Free swap:       5213316kB
05:48:12: 524000 pages of RAM
05:48:12: 11264 reserved pages
05:48:12: 241 pages shared
05:48:12: 790 pages swap cached
05:48:12: Out of memory: kill process 9156 (apache2) score 83536 or a child
05:48:12: Killed process 9156 (apache2)

Oh, FWIW, a later snapshot of /proc/alab_allocators:

skbuff_head_cache: 1746940 __alloc_skb+0x31/0x121
size-512: 1740532 tcp_send_ack+0x23/0x102
skbuff_fclone_cache: 152230 __alloc_skb+0x31/0x121
size-2048: 151603 tcp_sendmsg+0x1b5/0xae1
sysfs_dir_cache: 5279 sysfs_new_dirent+0x4b/0xec
size-512: 2837 sock_alloc_send_skb+0x93/0x1dd
Acpi-Operand: 2014 acpi_ut_allocate_object_desc_dbg+0x34/0x6e
size-32: 1989 sysfs_new_dirent+0x29/0xec
size-512: 1678 arp_create+0x4e/0x1cd
size-512: 1619 tcp_xmit_probe_skb+0x1f/0xcd
UDP: 1217 sk_alloc+0x25/0xaf
size-128: 1024 r1bio_pool_alloc+0x23/0x3b
size-128: 1024 nfsd_cache_init+0x2d/0xcf
Acpi-Namespace: 973 acpi_ns_create_node+0x2c/0x45
vm_area_struct: 804 copy_process+0x9f1/0x1108
dentry: 488 d_alloc+0x24/0x177
size-2048: 480 tcp_fragment+0xdf/0x4aa
anon_vma: 463 anon_vma_prepare+0x29/0x74
filp: 442 get_empty_filp+0x44/0xcd
ip_dst_cache: 421 dst_alloc+0x29/0x76


I'm backing out the ip1000a driver and seeing what happens.
