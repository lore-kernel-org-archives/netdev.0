From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Possible regression with skb_clone() in 2.6.36
Date: Wed,  8 Sep 2010 20:32:06 -0300
Message-ID: <1283988727-1456-1-git-send-email-padovan@profusion.mobi>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I've been experiencing some problems when running the L2CAP Streaming mode in
2.6.36. The system quickly runs in an Out Of Memory condition and crash. That
wasn't happening before, so I think we may have a regression here (I didn't
find where yet). The crash log is below.

The following patch does not fix the regression, but shows that removing the
skb_clone() call from l2cap_streaming_send() we workaround the problem. The
patch is good anyway because it saves memory and time.

By now I have no idea on how to fix this.


[ 5066.137533] Bluetooth: L2CAP ver 2.15
[ 5066.137873] Bluetooth: L2CAP socket layer initialized
[ 5066.545179] Bluetooth: RFCOMM TTY layer initialized
[ 5066.545879] Bluetooth: RFCOMM socket layer initialized
[ 5066.546582] Bluetooth: RFCOMM ver 1.11
[ 5092.268021] l2test invoked oom-killer: gfp_mask=0x4d0, order=0, oom_adj=0, oom_sc
ore_adj=0
[ 5092.268872] Pid: 3897, comm: l2test Not tainted 2.6.36-rc3 #5
[ 5092.269863] Call Trace:
[ 5092.270265]  [<ffffffff8138b6a6>] ? _raw_spin_unlock+0x26/0x30
[ 5092.270878]  [<ffffffff810c0827>] T.427+0x77/0x1e0
[ 5092.271874]  [<ffffffff811b85e7>] ? security_real_capable_noaudit+0x37/0x60
[ 5092.272956]  [<ffffffff810c0e3a>] out_of_memory+0x2ca/0x2f0
[ 5092.273894]  [<ffffffff810c3d43>] __alloc_pages_nodemask+0x693/0x6b0
[ 5092.274871]  [<ffffffff810ea3e6>] cache_alloc_refill+0x2d6/0x5c0
[ 5092.275864]  [<ffffffff810ea805>] __kmalloc+0x135/0x150
[ 5092.276876]  [<ffffffff8130f2ae>] __alloc_skb+0x6e/0x150
[ 5092.277865]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
[ 5092.278652]  [<ffffffff8130ace2>] sock_alloc_send_pskb+0x1c2/0x320
[ 5092.278927]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
[ 5092.279864]  [<ffffffff81312add>] ? memcpy_fromiovec+0x6d/0x90
[ 5092.280864]  [<ffffffff8130ae50>] sock_alloc_send_skb+0x10/0x20
[ 5092.281867]  [<ffffffffa00e600f>] l2cap_create_iframe_pdu+0x9f/0x2c0 [l2cap]
[ 5092.282865]  [<ffffffffa00e84b9>] l2cap_sock_sendmsg+0x5d9/0x910 [l2cap]
[ 5092.283932]  [<ffffffff8138ba3c>] ? restore_args+0x0/0x30
[ 5092.284865]  [<ffffffff8130725b>] sock_sendmsg+0xdb/0x100
[ 5092.285652]  [<ffffffff8138ba3c>] ? restore_args+0x0/0x30
[ 5092.285864]  [<ffffffff8138ba3c>] ? restore_args+0x0/0x30
[ 5092.286864]  [<ffffffff813073c0>] sys_sendto+0xf0/0x130
[ 5092.287864]  [<ffffffff8138b60b>] ? _raw_spin_unlock_irq+0x2b/0x40
[ 5092.288872]  [<ffffffff81093cfd>] ? trace_hardirqs_on_caller+0x13d/0x180
[ 5092.289927]  [<ffffffff81093d4d>] ? trace_hardirqs_on+0xd/0x10
[ 5092.290864]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
[ 5092.291649]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
[ 5092.291864]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
[ 5092.292864]  [<ffffffff8130740f>] sys_send+0xf/0x20
[ 5092.293870]  [<ffffffff8132ccd6>] compat_sys_socketcall+0x146/0x1f0
[ 5092.294875]  [<ffffffff81053ee4>] sysenter_dispatch+0x7/0x30
[ 5092.295673] Mem-Info:
[ 5092.295863] DMA per-cpu:
[ 5092.296214] CPU    0: hi:    0, btch:   1 usd:   0
[ 5092.296925] DMA32 per-cpu:
[ 5092.297298] CPU    0: hi:   90, btch:  15 usd:  85
[ 5092.297864] active_anon:504 inactive_anon:543 isolated_anon:0
[ 5092.297865]  active_file:14 inactive_file:3 isolated_file:0
[ 5092.297866]  unevictable:0 dirty:0 writeback:3 unstable:0
[ 5092.297866]  free:728 slab_reclaimable:559 slab_unreclaimable:39895
[ 5092.297867]  mapped:12 shmem:35 pagetables:84 bounce:0
[ 5092.299944] DMA free:1064kB min:124kB low:152kB high:184kB active_anon:0kB inacti
ve_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB iso
lated(file):0kB present:15768kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem
:0kB slab_reclaimable:0kB slab_unreclaimable:14916kB kernel_stack:0kB pagetables:0kB
 unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[ 5092.301862] lowmem_reserve[]: 0 236 236 236
[ 5092.303134] DMA32 free:1848kB min:1904kB low:2380kB high:2856kB active_anon:2016k
B inactive_anon:2172kB active_file:56kB inactive_file:12kB unevictable:0kB isolated(
anon):0kB isolated(file):0kB present:242380kB mlocked:0kB dirty:0kB writeback:12kB m
apped:48kB shmem:140kB slab_reclaimable:2236kB slab_unreclaimable:144664kB kernel_st
ack:456kB pagetables:336kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1
03 all_unreclaimable? yes
[ 5092.304962] lowmem_reserve[]: 0 0 0 0
[ 5092.306066] DMA: 0*4kB 1*8kB 0*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024k
B 0*2048kB 0*4096kB = 1064kB
[ 5092.307862] DMA32: 10*4kB 2*8kB 0*16kB 0*32kB 0*64kB 0*128kB 1*256kB 1*512kB 1*10
24kB 0*2048kB 0*4096kB = 1848kB
[ 5092.309467] 52 total pagecache pages
[ 5092.309862] 0 pages in swap cache
[ 5092.310317] Swap cache stats: add 0, delete 0, find 0/0
[ 5092.310862] Free swap  = 0kB
[ 5092.311260] Total swap = 0kB
[ 5092.313796] 65530 pages RAM
[ 5092.313868] 22603 pages reserved
[ 5092.314324] 206 pages shared
[ 5092.314862] 39353 pages non-shared
[ 5092.315348] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[ 5092.315867] [    1]     0     1      438       19   0       0             0 init
[ 5092.316871] [ 1018]     0  1018      537       75   0     -17         -1000 udevd
[ 5092.318867] [ 2217]   101  2217      606       39   0       0             0 dbus-
daemon
[ 5092.319865] [ 2825]     0  2825      481       29   0       0             0 dhcpc
d
[ 5092.320865] [ 3497]     0  3497     1091       83   0       0             0 sshd
[ 5092.321969] [ 3535]     0  3535      477       31   0       0             0 agett
y
[ 5092.322864] [ 3536]     0  3536      477       30   0       0             0 agett
y
[ 5092.323864] [ 3537]     0  3537      477       29   0       0             0 agett
y
[ 5092.325937] [ 3538]     0  3538      477       31   0       0             0 agett
y
[ 5092.326865] [ 3539]     0  3539      477       31   0       0             0 agett
y
[ 5092.327864] [ 3540]     0  3540      477       31   0       0             0 agett
y
[ 5092.328864] [ 3541]     0  3541     1738      105   0       0             0 sshd
[ 5092.329865] [ 3545]     0  3545      745       72   0       0             0 bash
[ 5092.330864] [ 3550]     0  3550      706       43   0       0             0 scree
n
[ 5092.331866] [ 3551]     0  3551      772      124   0       0             0 scree
n
[ 5092.332965] [ 3552]     0  3552      745       77   0       0             0 bash
[ 5092.333865] [ 3557]     0  3557      745       77   0       0             0 bash
[ 5092.334867] [ 3562]     0  3562      536       75   0     -17         -1000 udevd
[ 5092.336865] [ 3567]     0  3567      536       75   0     -17         -1000 udevd
[ 5092.337865] [ 3887]     0  3887      935       54   0       0             0 bluet
oothd
[ 5092.338864] [ 3896]     0  3896      458       24   0       0             0 l2tes
t
[ 5092.339864] [ 3897]     0  3897      458       24   0       0             0 l2tes
t
[ 5092.340933] [ 3942]     0  3942      458       29   0       0             0 l2tes
t
[ 5092.341863] Kernel panic - not syncing: Out of memory and no killable processes..
.
[ 5092.341864]
[ 5092.342864] Pid: 3897, comm: l2test Not tainted 2.6.36-rc3 #5
[ 5092.343862] Call Trace:
[ 5092.344934]  [<ffffffff813884d9>] panic+0x8c/0x199
[ 5092.345621]  [<ffffffff810c0e54>] out_of_memory+0x2e4/0x2f0
[ 5092.345864]  [<ffffffff810c3d43>] __alloc_pages_nodemask+0x693/0x6b0
[ 5092.346894]  [<ffffffff810ea3e6>] cache_alloc_refill+0x2d6/0x5c0
[ 5092.347864]  [<ffffffff810ea805>] __kmalloc+0x135/0x150
[ 5092.348871]  [<ffffffff8130f2ae>] __alloc_skb+0x6e/0x150
[ 5092.349865]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
[ 5092.350628]  [<ffffffff8130ace2>] sock_alloc_send_pskb+0x1c2/0x320
[ 5092.350935]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
[ 5092.351864]  [<ffffffff81312add>] ? memcpy_fromiovec+0x6d/0x90
[ 5092.352864]  [<ffffffff8130ae50>] sock_alloc_send_skb+0x10/0x20
[ 5092.353867]  [<ffffffffa00e600f>] l2cap_create_iframe_pdu+0x9f/0x2c0 [l2cap]
[ 5092.354865]  [<ffffffffa00e84b9>] l2cap_sock_sendmsg+0x5d9/0x910 [l2cap]
[ 5092.355864]  [<ffffffff8138ba3c>] ? restore_args+0x0/0x30
[ 5092.356864]  [<ffffffff8130725b>] sock_sendmsg+0xdb/0x100
[ 5092.357612]  [<ffffffff8138ba3c>] ? restore_args+0x0/0x30
[ 5092.357931]  [<ffffffff8138ba3c>] ? restore_args+0x0/0x30
[ 5092.358864]  [<ffffffff813073c0>] sys_sendto+0xf0/0x130
[ 5092.359864]  [<ffffffff8138b60b>] ? _raw_spin_unlock_irq+0x2b/0x40
[ 5092.360929]  [<ffffffff81093cfd>] ? trace_hardirqs_on_caller+0x13d/0x180
[ 5092.361866]  [<ffffffff81093d4d>] ? trace_hardirqs_on+0xd/0x10
[ 5092.362864]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
[ 5092.363653]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
[ 5092.364868]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
[ 5092.365865]  [<ffffffff8130740f>] sys_send+0xf/0x20
[ 5092.366945]  [<ffffffff8132ccd6>] compat_sys_socketcall+0x146/0x1f0
[ 5092.367865]  [<ffffffff81053ee4>] sysenter_dispatch+0x7/0x30

Gustavo F. Padovan (1):
      Bluetooth: Simplify L2CAP Streaming mode sending
