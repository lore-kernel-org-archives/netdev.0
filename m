From: Marc MERLIN <marc@merlins.org>
Subject: 3.2.8/amd64 full interrupt hangs and deadlocks under big network copies (page allocation failure)
Date: Thu, 29 Mar 2012 09:38:00 -0700
Message-ID: <20120329163800.GH24933@merlins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from magic.merlins.org ([209.81.13.136]:57860 "EHLO
	mail1.merlins.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759027Ab2C2RPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 13:15:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Howdy,

I need some help narrowing this bug down so that I can give a better report.

First, the problem is not new to 3.2.8, it appeared after I upgraded
my laptop to a new distribution and switched from 32bits to 64bit kernel
and userland. This in turn seems to be causing memory allocation problems.

When I make a big NFS copy, apparently interrupts don't get serviced
after a while, and my X screen won't update itself (clock) and my mouse
cursor won't move.
Then, after maybe a minute or more, it usually recovers for a few
seconds, and then locks again. The copy usually finishes eventually
if I leave the laptop for a few hours on its own while the UI is
unresponsive.
I've had the problem with both wired and wireless copies, and tried
doing a copy with smbmount instead of nfs, and the issue was similar.

I first had a vol prempt kernel, and tried recompiling with preempt and
that did not help.
My kernel config is here: http://marc.merlins.org/tmp/config.txt

Last night, I started a big copy, and this morning found the copy half
hung. The laptop was responsive, but while I could ping, TCP connections
would put the process in unkillable kernel hung state.

Below are some sysreq dumps I took (syslog to local disk was still
working fine). I know I have Tainted 'G', and I have no idea where that
came from, sorry :-/

It looks like I may run out of some kind of memory which in turn is
deadlocking some drivers?
(actual total memory is fine, user apps do not get OOM'ed and 'free' looked fine)

I ran the relevant sysrq commands wihch are at 
http://marc.merlins.org/tmp/sysrq.txt
(too big to paste here) 

But lots of tasks are hung like so:
[28451.191115] WorkerPool/1248 D ffff88013bc93580     0 12483   3740 0x00000080
[28451.191115]  ffff8801189ba100 0000000000000082 0000000000000000 ffff880134f2e180
[28451.191115]  0000000000013580 ffff88001614bfd8 ffff88001614bfd8 ffff8801189ba100
[28451.191115]  ffffffff811b4b62 000000010164525a 0000000000000046 ffffffff8165a250
[28451.191115] Call Trace:
[28451.191115]  [<ffffffff811b4b62>] ? sha_transform+0x395/0x1209
[28451.191115]  [<ffffffff8134a9b4>] ? __mutex_lock_common.isra.6+0x13d/0x219
[28451.191115]  [<ffffffff81242714>] ? extract_buf+0x86/0xf2
[28451.191115]  [<ffffffff8134a7e6>] ? mutex_lock+0xf/0x1f
[28451.191115]  [<ffffffff81298979>] ? rtnetlink_rcv+0xe/0x28
[28451.191115]  [<ffffffff812ad007>] ? netlink_unicast+0xe6/0x14e
[28451.191115]  [<ffffffff812ad26b>] ? netlink_sendmsg+0x1fc/0x237
[28451.191115]  [<ffffffff8127c770>] ? sock_sendmsg+0xc1/0xde
[28451.191115]  [<ffffffff810eca23>] ? __cache_free.isra.40+0x19/0x1a7
[28451.191115]  [<ffffffff813496be>] ? nl_pid_hash_rehash+0xc8/0xef
[28451.191115]  [<ffffffff8103e0fa>] ? get_parent_ip+0x9/0x1b
[28451.191115]  [<ffffffff8103e0fa>] ? get_parent_ip+0x9/0x1b
[28451.191115]  [<ffffffff8134e1d2>] ? sub_preempt_count+0x83/0x94
[28451.191115]  [<ffffffff810fd81e>] ? fget_light+0x85/0x8d
[28451.191115]  [<ffffffff8127e0e3>] ? sys_sendto+0xf7/0x137
[28451.191115]  [<ffffffff8103e0fa>] ? get_parent_ip+0x9/0x1b
[28451.191115]  [<ffffffff8134e1d2>] ? sub_preempt_count+0x83/0x94
[28451.191115]  [<ffffffff8134b725>] ? _raw_spin_unlock+0x24/0x30
[28451.191115]  [<ffffffff8108d73e>] ? audit_syscall_entry+0x105/0x130
[28451.191115]  [<ffffffff8134fd52>] ? system_call_fastpath+0x16/0x1b



Below are lines I got in syslog during the copy.
Highlight is:
[ 4437.367046] kworker/1:1: page allocation failure: order:1, mode:0x20
and then:
[ 8640.516177] INFO: task flush-0:37:7122 blocked for more than 120 seconds.
and then 120,000 lines(!) of:
[ 9654.042164] ieee80211 phy0: failed to reallocate TX buffer

unedited lines below.

So, any idea of what I can try next?

Thanks,
Marc


[ 4437.367046] kworker/1:1: page allocation failure: order:1, mode:0x20
[ 4437.367053] Pid: 8067, comm: kworker/1:1 Tainted: G           O 3.2.8-amd64-volpreempt-noide-20120208 #1
[ 4437.367056] Call Trace:
[ 4437.367058]  <IRQ>  [<ffffffff810b9ec0>] ? warn_alloc_failed+0x11f/0x132
[ 4437.367074]  [<ffffffff810bcdaa>] ? __alloc_pages_nodemask+0x6b1/0x72f
[ 4437.367081]  [<ffffffff810ec911>] ? kmem_getpages+0x4c/0xd9
[ 4437.367086]  [<ffffffff810ec911>] ? kmem_getpages+0x4c/0xd9
[ 4437.367090]  [<ffffffff810edd21>] ? fallback_alloc+0x123/0x1c2
[ 4437.367096]  [<ffffffff812846db>] ? pskb_expand_head+0xe0/0x24a
[ 4437.367101]  [<ffffffff810ee215>] ? __kmalloc+0xb2/0x10a
[ 4437.367105]  [<ffffffff812846db>] ? pskb_expand_head+0xe0/0x24a
[ 4437.367139]  [<ffffffffa03e22c1>] ? ieee80211_skb_resize+0x64/0x9d [mac80211]
[ 4437.367154]  [<ffffffffa03e4252>] ? ieee80211_subif_start_xmit+0x705/0x883 [mac80211]
[ 4437.367175]  [<ffffffff8128e767>] ? dev_hard_start_xmit+0x40b/0x552
[ 4437.367179]  [<ffffffff812a4adc>] ? sch_direct_xmit+0x63/0x13a
[ 4437.367182]  [<ffffffff8128eb8e>] ? dev_queue_xmit+0x2e0/0x4b5
[ 4437.367185]  [<ffffffff812b764d>] ? ip_finish_output2+0x1c7/0x218
[ 4437.367188]  [<ffffffff812b86aa>] ? __ip_flush_pending_frames.isra.29+0x69/0x69
[ 4437.367191]  [<ffffffff812b8a6a>] ? ip_queue_xmit+0x2cd/0x30d
[ 4437.367195]  [<ffffffff81066be9>] ? getnstimeofday+0x4a/0x7b
[ 4437.367198]  [<ffffffff812ca1d2>] ? tcp_transmit_skb+0x6d7/0x70a
[ 4437.367201]  [<ffffffff812cac5f>] ? tcp_write_xmit+0x698/0x7a1
[ 4437.367204]  [<ffffffff812c77bf>] ? tcp_ack+0x14e3/0x1658
[ 4437.367207]  [<ffffffff812c89bd>] ? tcp_established_options+0x2b/0x9e
[ 4437.367210]  [<ffffffff812cada9>] ? __tcp_push_pending_frames+0x18/0x44
[ 4437.367213]  [<ffffffff812c4e27>] ? tcp_data_snd_check+0x2c/0xfd
[ 4437.367216]  [<ffffffff812c86c5>] ? tcp_rcv_established+0x4f0/0x549
[ 4437.367220]  [<ffffffff8103ec39>] ? select_task_rq_fair+0x67b/0x690
[ 4437.367223]  [<ffffffff812ce735>] ? tcp_v4_do_rcv+0x166/0x323
[ 4437.367226]  [<ffffffff812cfdce>] ? tcp_v4_rcv+0x404/0x65d
[ 4437.367230]  [<ffffffff812b4d55>] ? ip_local_deliver_finish+0x148/0x1ba
[ 4437.367233]  [<ffffffff8128cfa4>] ? __netif_receive_skb+0x3f2/0x43f
[ 4437.367236]  [<ffffffff8128d31d>] ? netif_receive_skb+0x7e/0x84
[ 4437.367239]  [<ffffffff8128d7dd>] ? napi_gro_receive+0x1c/0x29
[ 4437.367241]  [<ffffffff8128d398>] ? napi_skb_finish+0x1c/0x31
[ 4437.367253]  [<ffffffffa026bde3>] ? e1000_clean_rx_irq+0x1f3/0x290 [e1000e]
[ 4437.367261]  [<ffffffffa026c26c>] ? e1000_clean+0x69/0x208 [e1000e]
[ 4437.367264]  [<ffffffff8128d8fb>] ? net_rx_action+0xa4/0x1c0
[ 4437.367268]  [<ffffffff8104c581>] ? __do_softirq+0xc0/0x188
[ 4437.367272]  [<ffffffff81351fac>] ? call_softirq+0x1c/0x30
[ 4437.367276]  [<ffffffff8100f98d>] ? do_softirq+0x3c/0x7b
[ 4437.367278]  [<ffffffff8104c87c>] ? irq_exit+0x3d/0xa7
[ 4437.367281]  [<ffffffff8100f6b4>] ? do_IRQ+0x81/0x97
[ 4437.367285]  [<ffffffff8134ba2e>] ? common_interrupt+0x6e/0x6e
[ 4437.367287]  <EOI>  [<ffffffffa008b32c>] ? dec128+0x434/0x80c [aes_x86_64]
[ 4437.367307]  [<ffffffffa0085164>] ? crypt+0xae/0x101 [xts]
[ 4437.367313]  [<ffffffffa008b712>] ? aes_decrypt+0xe/0xe [aes_x86_64]
[ 4437.367320]  [<ffffffffa008b704>] ? dec128+0x80c/0x80c [aes_x86_64]
[ 4437.367327]  [<ffffffffa00851f6>] ? decrypt+0x3f/0x44 [xts]
[ 4437.367331]  [<ffffffff8118cdb3>] ? async_decrypt+0x37/0x3c
[ 4437.367338]  [<ffffffffa0105e2a>] ? crypt_convert+0x22f/0x2c4 [dm_crypt]
[ 4437.367342]  [<ffffffff8100d02f>] ? load_TLS+0x7/0xa
[ 4437.367348]  [<ffffffffa01061b8>] ? kcryptd_crypt+0x56/0x342 [dm_crypt]
[ 4437.367352]  [<ffffffff81038cd2>] ? finish_task_switch+0x86/0xb7
[ 4437.367355]  [<ffffffff8103e0fa>] ? get_parent_ip+0x9/0x1b
[ 4437.367358]  [<ffffffff8134e1d2>] ? sub_preempt_count+0x83/0x94
[ 4437.367361]  [<ffffffff8103612b>] ? need_resched+0x1a/0x23
[ 4437.367368]  [<ffffffffa0106162>] ? crypt_convert_init.isra.14+0x4f/0x4f [dm_crypt]
[ 4437.367372]  [<ffffffff8105b867>] ? process_one_work+0x16d/0x298
[ 4437.367375]  [<ffffffff8105c84a>] ? worker_thread+0xc2/0x145
[ 4437.367378]  [<ffffffff8105c788>] ? manage_workers.isra.23+0x15b/0x15b
[ 4437.367381]  [<ffffffff8105f9fe>] ? kthread+0x76/0x7e
[ 4437.367384]  [<ffffffff81351eb4>] ? kernel_thread_helper+0x4/0x10
[ 4437.367387]  [<ffffffff8105f988>] ? kthread_worker_fn+0x139/0x139
[ 4437.367390]  [<ffffffff81351eb0>] ? gs_change+0x13/0x13
[ 4437.367392] Mem-Info:
[ 4437.367393] Node 0 DMA per-cpu:
[ 4437.367396] CPU    0: hi:    0, btch:   1 usd:   0
[ 4437.367397] CPU    1: hi:    0, btch:   1 usd:   0
[ 4437.367399] Node 0 DMA32 per-cpu:
[ 4437.367401] CPU    0: hi:  186, btch:  31 usd: 164
[ 4437.367403] CPU    1: hi:  186, btch:  31 usd: 111
[ 4437.367405] Node 0 Normal per-cpu:
[ 4437.367407] CPU    0: hi:  186, btch:  31 usd: 114
[ 4437.367409] CPU    1: hi:  186, btch:  31 usd: 158
[ 4437.367413] active_anon:391300 inactive_anon:132951 isolated_anon:0
[ 4437.367414]  active_file:136666 inactive_file:140710 isolated_file:31
[ 4437.367415]  unevictable:1 dirty:3402 writeback:26688 unstable:7844
[ 4437.367416]  free:36509 slab_reclaimable:85289 slab_unreclaimable:35524
[ 4437.367417]  mapped:18088 shmem:35934 pagetables:9300 bounce:0
[ 4437.367419] Node 0 DMA free:15712kB min:260kB low:324kB high:388kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:36kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15684kB mlocked:0kB dirty:0kB writeback:36kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:160kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:40833 all_unreclaimable? yes
[ 4437.367428] lowmem_reserve[]: 0 2960 3907 3907
[ 4437.367432] Node 0 DMA32 free:110732kB min:51004kB low:63752kB high:76504kB active_anon:1380396kB inactive_anon:345140kB active_file:422008kB inactive_file:437440kB unevictable:4kB isolated(anon):0kB isolated(file):124kB present:3031688kB mlocked:4kB dirty:7148kB writeback:72004kB mapped:39424kB shmem:64836kB slab_reclaimable:212408kB slab_unreclaimable:80516kB kernel_stack:1720kB pagetables:19252kB unstable:23964kB bounce:0kB writeback_tmp:0kB pages_scanned:63 all_unreclaimable? no
[ 4437.367442] lowmem_reserve[]: 0 0 946 946
[ 4437.367445] Node 0 Normal free:19592kB min:16312kB low:20388kB high:24468kB active_anon:184804kB inactive_anon:186664kB active_file:124656kB inactive_file:125364kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:969600kB mlocked:0kB dirty:6460kB writeback:34712kB mapped:32928kB shmem:78900kB slab_reclaimable:128748kB slab_unreclaimable:61420kB kernel_stack:2792kB pagetables:17948kB unstable:7412kB bounce:0kB writeback_tmp:0kB pages_scanned:89 all_unreclaimable? no
[ 4437.367455] lowmem_reserve[]: 0 0 0 0
[ 4437.367458] Node 0 DMA: 2*4kB 1*8kB 1*16kB 0*32kB 1*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 2*2048kB 2*4096kB = 15712kB
[ 4437.367467] Node 0 DMA32: 25961*4kB 73*8kB 8*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 1*4096kB = 110732kB
[ 4437.367475] Node 0 Normal: 4134*4kB 0*8kB 1*16kB 1*32kB 0*64kB 2*128kB 1*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 19656kB
[ 4437.367484] 317456 total pagecache pages
[ 4437.367485] 4042 pages in swap cache
[ 4437.367487] Swap cache stats: add 31786, delete 27744, find 10282/11070
[ 4437.367489] Free swap  = 4012560kB
[ 4437.367490] Total swap = 4106248kB
[ 4437.370978] 1032176 pages RAM
[ 4437.370978] 42834 pages reserved
[ 4437.370978] 390787 pages shared
[ 4437.370978] 750687 pages non-shared


[ 8640.516177] INFO: task flush-0:37:7122 blocked for more than 120 seconds.
[ 8640.516182] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 8640.516186] flush-0:37      D ffff88013bc93580     0  7122      2 0x00000080
[ 8640.516192]  ffff880072c28810 0000000000000046 ffff880100000000 ffff880134f2e180
[ 8640.516199]  0000000000013580 ffff88006d491fd8 ffff88006d491fd8 ffff880072c28810
[ 8640.516205]  ffff88013bfd1c50 000000018134b58b ffff88010c3cc1b0 ffff88006d491d18
[ 8640.516211] Call Trace:
[ 8640.516221]  [<ffffffff8110e81a>] ? inode_owner_or_capable+0x36/0x36
[ 8640.516226]  [<ffffffff8110e820>] ? inode_wait+0x6/0xa
[ 8640.516232]  [<ffffffff8134a72c>] ? __wait_on_bit+0x3e/0x71
[ 8640.516241]  [<ffffffff8103e0fa>] ? get_parent_ip+0x9/0x1b
[ 8640.516245]  [<ffffffff81119674>] ? inode_wait_for_writeback+0xa2/0xc8
[ 8640.516249]  [<ffffffff810600c9>] ? autoremove_wake_function+0x2a/0x2a
[ 8640.516252]  [<ffffffff8111b4b4>] ? wb_writeback+0x226/0x255
[ 8640.516255]  [<ffffffff8134e27d>] ? add_preempt_count+0x9a/0x9c
[ 8640.516258]  [<ffffffff8111b8d4>] ? wb_do_writeback+0x150/0x1b2
[ 8640.516261]  [<ffffffff8111b9c5>] ? bdi_writeback_thread+0x8f/0x204
[ 8640.516264]  [<ffffffff8111b936>] ? wb_do_writeback+0x1b2/0x1b2
[ 8640.516266]  [<ffffffff8105f9fe>] ? kthread+0x76/0x7e
[ 8640.516270]  [<ffffffff81351eb4>] ? kernel_thread_helper+0x4/0x10
[ 8640.516273]  [<ffffffff8105f988>] ? kthread_worker_fn+0x139/0x139
[ 8640.516275]  [<ffffffff81351eb0>] ? gs_change+0x13/0x13
[ 8640.516281] INFO: task cp:7568 blocked for more than 120 seconds.
[ 8640.516283] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 8640.516284] cp              D ffff88013bc13580     0  7568   6744 0x00000080
[ 8640.516288]  ffff880123976750 0000000000000082 0000000000000000 ffffffff8160d020
[ 8640.516292]  0000000000013580 ffff88001b3a9fd8 ffff88001b3a9fd8 ffff880123976750
[ 8640.516295]  0000000000000001 0000000181066767 ffff880131463e50 ffff88013bc13e08
[ 8640.516299] Call Trace:
[ 8640.516303]  [<ffffffff810b5d03>] ? __lock_page+0x66/0x66
[ 8640.516306]  [<ffffffff8134a2ec>] ? io_schedule+0x58/0x6f
[ 8640.516308]  [<ffffffff810b5d09>] ? sleep_on_page+0x6/0xa
[ 8640.516311]  [<ffffffff8134a72c>] ? __wait_on_bit+0x3e/0x71
[ 8640.516313]  [<ffffffff810b5e51>] ? wait_on_page_bit+0x6e/0x73
[ 8640.516316]  [<ffffffff810600c9>] ? autoremove_wake_function+0x2a/0x2a
[ 8640.516319]  [<ffffffff810b5f29>] ? filemap_fdatawait_range+0x74/0x139
[ 8640.516327]  [<ffffffff8111acab>] ? writeback_single_inode+0x155/0x2f4
[ 8640.516330]  [<ffffffff8111ae94>] ? sync_inode+0x4a/0x6f
[ 8640.516343]  [<ffffffffa06b9b02>] ? nfs_wb_all+0x39/0x3e [nfs]
[ 8640.516351]  [<ffffffffa06aeed1>] ? nfs_setattr+0x8e/0xf6 [nfs]
[ 8640.516354]  [<ffffffff811104c3>] ? notify_change+0x177/0x24f
[ 8640.516357]  [<ffffffff8111e85c>] ? utimes_common+0x10c/0x135
[ 8640.516361]  [<ffffffff810fd55a>] ? fget+0x50/0x57
[ 8640.516364]  [<ffffffff8111e90f>] ? do_utimes+0x8a/0xd6
[ 8640.516367]  [<ffffffff810fc7a2>] ? vfs_read+0x9f/0xe6
[ 8640.516369]  [<ffffffff8111ea24>] ? sys_utimensat+0x64/0x6b
[ 8640.516372]  [<ffffffff8134fd52>] ? system_call_fastpath+0x16/0x1b


[ 9654.042164] ieee80211 phy0: failed to reallocate TX buffer
[ 9654.042189] ieee80211 phy0: failed to reallocate TX buffer
(120,000 lines of this)

-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
