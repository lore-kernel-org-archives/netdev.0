From: Marc MERLIN <marc@merlins.org>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs copies out
Date: Mon, 18 Feb 2013 20:05:57 -0800
Message-ID: <20130219040557.GB4778@merlins.org>
References: <1333998672.3007.245.camel@edumazet-glaptop> <20120409.153452.1284163346306246866.davem@davemloft.net> <1334030180.13293.98.camel@edumazet-glaptop> <20120410051127.GA32048@merlins.org> <1334038263.2907.1.camel@edumazet-glaptop> <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org> <1342419529.3265.12217.camel@edumazet-glaptop> <20120716151826.GA10586@merlins.org> <1342455717.2830.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magic.merlins.org ([209.81.13.136]:46515 "EHLO
	mail1.merlins.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932107Ab3BSEGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 23:06:05 -0500
Content-Disposition: inline
In-Reply-To: <1342455717.2830.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 16, 2012 at 06:21:57PM +0200, Eric Dumazet wrote:
> > No, it's atually when I'm 'uploading' from my laptop to my server.
> > One interesting thing is that my server is running lvm2 with snapshots,
> > which makes writes slower than my laptop can push data over the network, so
> > it's definitely causing buffers to fill up.
> > I just did a download test and got 4.5MB/s sustained without problems.
> 
> Hmm, nfs apparently is able to push lot of data, try to reduce
> rsize/wsize to sane values, like 32K instead of 512K ?
> 
> gargamel:/mnt/dshelf2/ /net/gargamel/mnt/dshelf2 nfs4
> rw,nosuid,nodev,relatime,vers=4.0,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.205.7,local_lock=none,addr=192.168.205.3 0 0
> 
> You could trace svc_sock_setbufsize() and check how large is set
> sk_sndbuf

My apologies, I totally dropped the ball on this.

So, the problem was still there in more recent kernels.

TL;DR:
- reducing nfs buffers removes the full hang
- iwlwifi has a problem where lack of pages causes the whoe machine to hang
- NFS copies out, even with buffers down to 32K is very wonky and cp does not
  return until over 2mn after the copy is actually finished.
  (I have a trace of what's hung in cp/nfs when this happens)


Details:

It's still pretty severe because whatever blocks doesn't just end up
blocking disk IO, but actually blocking interrupts altogether since my mouse
can't move for a minute or more until some buffer flushes.

The last trace I got during this (I can't do sysrq because I have a broken 
Lenovo T530 without a sysrq key, and typing doesn't really work when
interrupts aren't firing).

Not sure if it's useful. First chrome had an issue, and then iwlwifi

chrome: page allocation failure: order:1, mode:0x4020
Pid: 8730, comm: chrome Tainted: G           O 3.7.8-amd64-preempt-20121226-fixwd #1
Call Trace:
 <IRQ>  [<ffffffff810d5f38>] warn_alloc_failed+0x117/0x12c
 [<ffffffff810d8cfd>] __alloc_pages_nodemask+0x66a/0x702
 [<ffffffff8108a948>] ? arch_local_irq_save+0x15/0x1b
 [<ffffffff811064af>] alloc_pages_current+0xcd/0xee
 [<ffffffffa039b579>] iwl_rx_allocate+0x8c/0x271 [iwlwifi]
 [<ffffffffa039c24e>] iwl_irq_tasklet+0x7e5/0x91c [iwlwifi]
 [<ffffffff8104805e>] tasklet_action+0x80/0xd2
 [<ffffffff81047c99>] __do_softirq+0xdf/0x1c5
 [<ffffffff814c1ed6>] ? _raw_spin_lock+0x1b/0x1f
 [<ffffffff810a7f37>] ? handle_irq_event+0x4d/0x62
 [<ffffffff814c7f5c>] call_softirq+0x1c/0x30
 [<ffffffff8101104e>] do_softirq+0x41/0x7f
 [<ffffffff81047e52>] irq_exit+0x3f/0xa7
 [<ffffffff81010d40>] do_IRQ+0x88/0x9f
 [<ffffffff814c246d>] common_interrupt+0x6d/0x6d
 <EOI> Mem-Info:

iwlwifi 0000:03:00.0: Failed to alloc_pages with GFP_ATOMIC.Only 1 free buffers remaining.
swapper/0: page allocation failure: order:1, mode:0x4020
Pid: 0, comm: swapper/0 Tainted: G           O 3.7.8-amd64-preempt-20121226-fixwd #1
Call Trace:
 <IRQ>  [<ffffffff810d5f38>] warn_alloc_failed+0x117/0x12c
 [<ffffffff810d8cfd>] __alloc_pages_nodemask+0x66a/0x702
 [<ffffffff8108a948>] ? arch_local_irq_save+0x15/0x1b
 [<ffffffff811064af>] alloc_pages_current+0xcd/0xee
 [<ffffffffa039b579>] iwl_rx_allocate+0x8c/0x271 [iwlwifi]
 [<ffffffffa039c24e>] iwl_irq_tasklet+0x7e5/0x91c [iwlwifi]
 [<ffffffff810af981>] ? rcu_irq_exit+0x6f/0x74
 [<ffffffff8104805e>] tasklet_action+0x80/0xd2
 [<ffffffff81047c99>] __do_softirq+0xdf/0x1c5
 [<ffffffff814c1ed6>] ? _raw_spin_lock+0x1b/0x1f
 [<ffffffff810a7f37>] ? handle_irq_event+0x4d/0x62
 [<ffffffff814c7f5c>] call_softirq+0x1c/0x30
 [<ffffffff8101104e>] do_softirq+0x41/0x7f
 [<ffffffff81047e52>] irq_exit+0x3f/0xa7
 [<ffffffff81010d40>] do_IRQ+0x88/0x9f
 [<ffffffff814c246d>] common_interrupt+0x6d/0x6d
 <EOI>  [<ffffffff810151f9>] ? paravirt_read_tsc+0x9/0xd
 [<ffffffff812daf10>] ? intel_idle+0xe6/0x112
 [<ffffffff812daeef>] ? intel_idle+0xc5/0x112
 [<ffffffff813c6440>] cpuidle_enter+0x12/0x14
 [<ffffffff813c68d9>] cpuidle_enter_state+0x10/0x3a
 [<ffffffff813c69fb>] cpuidle_idle_call+0xf8/0x180
 [<ffffffff81016c21>] cpu_idle+0x9b/0xf9
 [<ffffffff8149ec77>] rest_init+0x7b/0x7f
 [<ffffffff81ac4ba4>] start_kernel+0x3c8/0x3d5
 [<ffffffff81ac45e4>] ? repair_env_string+0x56/0x56
 [<ffffffff81ac42d3>] x86_64_start_reservations+0xae/0xb2
 [<ffffffff81ac4120>] ? early_idt_handlers+0x120/0x120
 [<ffffffff81ac43d9>] x86_64_start_kernel+0x102/0x111
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  21
CPU    1: hi:  186, btch:  31 usd:  43
CPU    2: hi:  186, btch:  31 usd:  59
CPU    3: hi:  186, btch:  31 usd:  35
Node 0 Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 150
CPU    1: hi:  186, btch:  31 usd:  29
CPU    2: hi:  186, btch:  31 usd:  61
CPU    3: hi:  186, btch:  31 usd:  32
active_anon:1147756 inactive_anon:211701 isolated_anon:0
 active_file:89633 inactive_file:132474 isolated_file:15
 unevictable:2444 dirty:28383 writeback:32015 unstable:5873
 free:29900 slab_reclaimable:22370 slab_unreclaimable:23443
 mapped:315414 shmem:80562 pagetables:32697 bounce:0
 free_cma:0
Node 0 DMA free:15900kB min:132kB low:164kB high:196kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 3257 7777 7777
Node 0 DMA32 free:54852kB min:28252kB low:35312kB high:42376kB active_anon:2187940kB inactive_anon:437600kB active_file:131500kB inactive_file:217816kB unevictable:2556kB isolated(anon):0kB isolated(file):0kB present:3335900kB mlocked:2556kB dirty:43628kB writeback:59292kB mapped:315320kB shmem:150940kB slab_reclaimable:21884kB slab_unreclaimable:29608kB kernel_stack:3648kB pagetables:36140kB unstable:5060kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:230 all_unreclaimable? no
lowmem_reserve[]: 0 0 4519 4519
Node 0 Normal free:48848kB min:39196kB low:48992kB high:58792kB active_anon:2403084kB inactive_anon:409204kB active_file:227328kB inactive_file:311920kB unevictable:7220kB isolated(anon):0kB isolated(file):60kB present:4627820kB mlocked:7220kB dirty:69904kB writeback:68768kB mapped:946336kB shmem:171308kB slab_reclaimable:67596kB slab_unreclaimable:64164kB kernel_stack:5704kB pagetables:94648kB unstable:18432kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:130 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 1*4kB 1*8kB 1*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15900kB
Node 0 DMA32: 12419*4kB 0*8kB 1*16kB 1*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 54652kB
Node 0 Normal: 11218*4kB 38*8kB 0*16kB 0*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 49016kB
440338 total pagecache pages
136996 pages in swap cache
Swap cache stats: add 3377120, delete 3240124, find 1032307/1258857
Free swap  = 6034228kB
Total swap = 10485756kB
2057712 pages RAM
341095 pages reserved
1654166 pages shared
1340354 pages non-shared
iwlwifi 0000:03:00.0: Failed to alloc_pages with GFP_ATOMIC.Only 1 free buffers remaining.


The good news is that the system unlocks itself, and I eventually get to a
root shell where I can killall -9 cp, which kills the copy from local disk
to remote nfs server after usually a minute of wait for more buffers to
flush.

Per your recommendation, I changed my NFS buffers and /etc/auto.master
now says:
/net	-hosts nointr,soft,rsize=32768,wsize=32768

This indeed does make things better: the copy still takes way way too long,
but the mouse or system doesn't hang anymore. 

I can however ls the file on the remote server a full 3mn before cp returns
completion on my laptop.
There definitely seems to be something wrong with NFS and buffering, and on my
laptop, when that happens, it seems to hang the intel wireless driver, maybe
because it's failing to allocate pages, and it just sits there, somehow with
interrupts turned off? (but I thought drivers don't turn off interrupts anymore
so I'm not sure what's really going on and why my mouse pointer and screen updates
just stop for a minute or more).

To be honest, the situation is bearable enough now with 32K buffers that I can catch
the slow copy, kill it, and use scp instead, but if you know if appropriate folks
who would want to know about this, let me know.

Just to check, I went back to a copy to remote nfs server using ethernet,
and the file was again copied 2mn before cp returned as complete. There
were however no hangs or problems with the copy.

ps wchan showed:
23267 merlin   cp -i grand.avia /net/garga rpc_wait_bit_killable

SysRq : Show Blocked State
  task                        PC stack   pid father
cp              D ffff8800ae554530     0 23267  11009 0x00000080
 ffff8800ae5a3cc8 0000000000000086 ffff88021e293c80 ffff8800ae554140
 ffff8800ae554140 ffff8800ae5a3fd8 ffff8800ae5a3fd8 0000000000013c80
 ffff88021551e380 ffff8800ae554140 ffff8800ae5a3cb8 ffff8800ae5a3d70
Call Trace:
 [<ffffffffa06f8676>] ? nfs_setattr_update_inode+0xdb/0xdb [nfs]
 [<ffffffff814c12b6>] schedule+0x5f/0x61
 [<ffffffffa06f86d4>] nfs_wait_bit_killable+0x5e/0x78 [nfs]
 [<ffffffff814c0059>] __wait_on_bit_lock+0x41/0x8a
 [<ffffffff814c010f>] out_of_line_wait_on_bit_lock+0x6d/0x78
 [<ffffffffa06f8676>] ? nfs_setattr_update_inode+0xdb/0xdb [nfs]
 [<ffffffff8105d4f0>] ? autoremove_wake_function+0x32/0x32
 [<ffffffffa0702699>] nfs_commit_inode+0x66/0x108 [nfs]
 [<ffffffffa06f6c95>] nfs_file_fsync_commit+0x74/0xb1 [nfs]
 [<ffffffffa099306c>] nfs4_file_fsync+0x6c/0xa3 [nfsv4]
 [<ffffffff81139f1e>] vfs_fsync_range+0x1e/0x20
 [<ffffffff81139f37>] vfs_fsync+0x17/0x19
 [<ffffffffa06f737d>] nfs_file_flush+0x95/0x9a [nfs]
 [<ffffffff81114bdf>] filp_close+0x42/0x75
 [<ffffffff8112b9b3>] __close_fd+0x7c/0x94
 [<ffffffff81114799>] sys_close+0x1b/0x45
 [<ffffffff814c6bed>] system_call_fastpath+0x1a/0x1f

Mount is like this:
gargamel:/mnt/dshelf1 /net/gargamel/mnt/dshelf1 nfs4 rw,nosuid,nodev,relatime,vers=4.0,rsize=32768,wsize=32768,namlen=255,soft,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.205.7,local_lock=none,addr=192.168.205.3 0 0

Can you comment on whether this should be a bug filed with the intel wireless folks?
As for NFS, is it known to be as probablematic as I'm seeing it, or is it just me?

Thanks,
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
