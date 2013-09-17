From: Dmitry Vyukov <dvyukov@google.com>
Subject: Potential out-of-bounds access in ip6_finish_output2
Date: Mon, 16 Sep 2013 22:13:10 -0700
Message-ID: <CACT4Y+ZXqoixvCyN5703+sVhCV4ND-vNwash2Z1vSDoLgKNyVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: yoshfuji@linux-ipv6.org, hannes@stressinduktion.org,
	netdev@vger.kernel.org, Paul Turner <pjt@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:41093 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab3IQFNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 01:13:32 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so5068694lbi.1
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 22:13:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am working on AddressSanitizer -- a tool that detects use-after-free
and out-of-bounds bugs
(https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel).

I've got a dozen of reports in ip6_finish_output2. Below are 2 of
them. They are always followed by kernel crash. Unfortunately I don't
have a reproducer because I am using trinity fuzzer. I would
appreciate if somebody familiar with the code look at sources and
maybe spot the bug.

The reports are obtained on revision 6a7492a4b2e05051a44458d7187023e22d580666.

[  977.765485] ERROR: AddressSanitizer: heap-buffer-overflow on
address ffff8800521e8730
[  977.767205] ffff8800521e8730 is located 16 bytes to the left of
512-byte region [ffff8800521e8740, ffff8800521e8940)
[  977.769399] Accessed by thread T11464:
[  977.770274]   #0 ffffffff810dd2a6 (asan_report_error+0x306/0x410)
[  977.771570]   #1 ffffffff810dc6a0 (asan_check_region+0x30/0x40)
[  977.772883]   #2 ffffffff810dc9ff (asan_memcpy+0x1f/0x60)
[  977.774033]   #3 ffffffffa0003b1c (ip6_finish_output2+0x54c/0x840 [ipv6])
[  977.775451]   #4 ffffffffa00088dc (ip6_fragment+0xe2c/0x1520 [ipv6])
[  977.776710]   #5 ffffffffa00090f7 (ip6_finish_output+0x127/0x190 [ipv6])
[  977.777649]   #6 ffffffffa00091e1 (ip6_output+0x81/0x140 [ipv6])
[  977.778503]   #7 ffffffffa000630c (ip6_local_out+0x4c/0x60 [ipv6])
[  977.779379]   #8 ffffffffa0006afd
(ip6_push_pending_frames+0x7dd/0xac0 [ipv6])
[  977.780391]   #9 ffffffffa00319de (rawv6_sendmsg+0x12ae/0x15c0 [ipv6])
[  977.781295]   #10 ffffffff818bb498 (inet_sendmsg+0x108/0x160)
[  977.782094]   #11 ffffffff817d0016 (sock_aio_write+0x296/0x2e0)
[  977.782885]   #12 ffffffff8129dcb1 (do_sync_write+0x111/0x170)
[  977.783699]   #13 ffffffff8129e9fd (vfs_write+0x2dd/0x300)
[  977.784468]   #14 ffffffff8129f9a0 (SyS_write+0x80/0xe0)
[  977.785214]   #15 ffffffff81928582 (system_call_fastpath+0x16/0x1b)
[  977.786066]
[  977.786284] Allocated by thread T11464:
[  977.786858]   #0 ffffffff810dc768 (asan_slab_alloc+0x48/0xc0)
[  977.787661]   #1 ffffffff81283d89 (kmem_cache_alloc_node_trace+0x99/0x4f0)
[  977.788860]   #2 ffffffff81284211 (__kmalloc_node_track_caller+0x31/0x40)
[  977.790359]   #3 ffffffff817ded6a (__kmalloc_reserve.isra.27+0x4a/0xb0)
[  977.791800]   #4 ffffffff817e0201 (__alloc_skb+0x91/0x280)
[  977.792985]   #5 ffffffff817d807a (sock_wmalloc+0x6a/0xe0)
[  977.794183]   #6 ffffffffa0005ea6 (ip6_append_data+0x1906/0x1c20 [ipv6])
[  977.795597]   #7 ffffffffa0030dd7 (rawv6_sendmsg+0x6a7/0x15c0 [ipv6])
[  977.796831]   #8 ffffffff818bb498 (inet_sendmsg+0x108/0x160)
[  977.798035]   #9 ffffffff817d0016 (sock_aio_write+0x296/0x2e0)
[  977.799260]   #10 ffffffff8129dcb1 (do_sync_write+0x111/0x170)
[  977.800495]   #11 ffffffff8129e9fd (vfs_write+0x2dd/0x300)
[  977.801709]   #12 ffffffff8129f9a0 (SyS_write+0x80/0xe0)
[  977.802882]   #13 ffffffff81928582 (system_call_fastpath+0x16/0x1b)
[  977.804209]
[  977.804529] Shadow bytes around the buggy address:
[  977.805588]   ffff8800521e8480: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00
[  977.807192]   ffff8800521e8500: 00 00 00 00 00 00 00 fb fb fb fb fb
fb fb fb fb
[  977.808655]   ffff8800521e8580: fb fb fb fb fb fb fb fb fb fb fb fb
fb fb fb fb
[  977.810122]   ffff8800521e8600: fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa fa
[  977.811776]   ffff8800521e8680: fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa fa
[  977.813128] =>ffff8800521e8700: fa fa fa fa fa fa[fa]fa 00 00 00 00
00 00 00 00
[  977.814463]   ffff8800521e8780: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00
[  977.815625]   ffff8800521e8800: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00
[  977.816685]   ffff8800521e8880: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00
[  977.817814]   ffff8800521e8900: 00 00 00 00 00 00 00 00 fa fa fa fa
fa fa fa fa
[  977.818907]   ffff8800521e8980: fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa fa
[  977.819917] Shadow byte legend (one shadow byte represents 8
application bytes):
[  977.820929]   Addressable:           00
[  977.821479]   Partially addressable: 01 02 03 04 05 06 07
[  977.822251]   Heap redzone:          fa
[  977.822841]   Heap kmalloc redzone:  fb
[  977.823414]   Freed heap region:     fd
[  977.823955]   Shadow gap:            fe
[  977.824512] =========================================================================
[  977.825607] skbuff: skb_under_panic: text:ffffffffa0003b35 len:125
put:14 head:ffff8800521e8740 data:ffff8800521e8732 tail:0x6f end:0xc0
dev:lo
[  977.827336] ------------[ cut here ]------------
[  977.828000] kernel BUG at net/core/skbuff.c:126!
[  977.828270] invalid opcode: 0000 [#1] SMP
[  977.828270] Modules linked in: snd_seq_dummy snd_seq_oss
snd_seq_midi_event snd_seq snd_seq_device tun 8021q snd_pcm_oss
snd_pcm snd_page_alloc snd_timer snd_mixer_oss snd sr_mod cdrom loop
bridge stp llc st ipt_ULOG nfnetlink iptable_mangle tg3 ptp pps_core
i2c_piix4 i2c_core msr cpuid e1000 ipv6
[  977.828270] CPU: 1 PID: 11464 Comm: trinity-child28 Not tainted
3.11.0-smp-DEV #8
[  977.828270] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  977.828270] task: ffff880053321280 ti: ffff880049194000 task.ti:
ffff880049194000
[  977.828270] RIP: 0010:[<ffffffff81913878>]  [<ffffffff81913878>]
skb_panic+0xd5/0xd7
[  977.828270] RSP: 0018:ffff8800491957a0  EFLAGS: 00010286
[  977.828270] RAX: 0000000000000083 RBX: ffff8800485be6c0 RCX: 0000000000000000
[  977.828270] RDX: ffff880000000000 RSI: 0000000000000008 RDI: ffffffff81c44cd8
[  977.828270] RBP: ffff880049195808 R08: 000000000000006f R09: 0000000000000000
[  977.828270] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88005bf8b400
[  977.828270] R13: ffff8800521e8732 R14: 000000000000006f R15: 00000000000000c0
[  977.828270] FS:  0000000001642880(0063) GS:ffff88005fd00000(0000)
knlGS:0000000000000000
[  977.828270] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  977.828270] CR2: 0000000000000009 CR3: 0000000049eef000 CR4: 00000000000006e0
[  977.828270] Stack:
[  977.828270]  ffff8800521e8732 000000000000006f 00000000000000c0
ffff88005bf8b400
[  977.828270]  0000000e485be6c0 ffffffffa0003b35 ffffffff81aa3940
ffff8800521e8740
[  977.828270]  ffff8800485be6c0 ffff8800521e8732 000000000000000e
ffff8800485be720
[  977.828270] Call Trace:
[  977.828270]  [<ffffffffa0003b35>] ? ip6_finish_output2+0x565/0x840 [ipv6]
[  977.828270]  [<ffffffff817ddb59>] skb_push+0xa9/0xb0
[  977.828270]  [<ffffffffa0003b35>] ip6_finish_output2+0x565/0x840 [ipv6]
[  977.828270]  [<ffffffffa00088dc>] ip6_fragment+0xe2c/0x1520 [ipv6]
[  977.828270]  [<ffffffffa00035d0>] ?
ip6_flush_pending_frames+0x1d0/0x1d0 [ipv6]
[  977.828270]  [<ffffffffa00090f7>] ip6_finish_output+0x127/0x190 [ipv6]
[  977.828270]  [<ffffffffa00091e1>] ip6_output+0x81/0x140 [ipv6]
[  977.828270]  [<ffffffffa000630c>] ip6_local_out+0x4c/0x60 [ipv6]
[  977.828270]  [<ffffffff810dc689>] ? asan_check_region+0x19/0x40
[  977.828270]  [<ffffffffa0006afd>] ip6_push_pending_frames+0x7dd/0xac0 [ipv6]
[  977.828270]  [<ffffffffa00319de>] rawv6_sendmsg+0x12ae/0x15c0 [ipv6]
[  977.828270]  [<ffffffff810dc689>] ? asan_check_region+0x19/0x40
[  977.828270]  [<ffffffff818bb498>] inet_sendmsg+0x108/0x160
[  977.828270]  [<ffffffff817d0016>] sock_aio_write+0x296/0x2e0
[  977.828270]  [<ffffffff8129dcb1>] do_sync_write+0x111/0x170
[  977.828270]  [<ffffffff8129e9fd>] vfs_write+0x2dd/0x300
[  977.828270]  [<ffffffff8129f9a0>] SyS_write+0x80/0xe0
[  977.828270]  [<ffffffff81928582>] system_call_fastpath+0x16/0x1b
[  977.828270] Code: c7 f0 a2 ba 81 44 8b 45 bc 48 8b 55 c0 31 c0 48
8b 75 c8 4c 89 64 24 18 4c 89 7c 24 10 4c 89 74 24 08 4c 89 2c 24 e8
7d 73 ff ff <0f> 0b 55 48 89 e5 48 8b 7d 08 e8 39 9b 7c ff 0f 0b 55 48
89 e5
[  977.828270] RIP  [<ffffffff81913878>] skb_panic+0xd5/0xd7
[  977.828270]  RSP <ffff8800491957a0>
[  977.871681] ---[ end trace 20970757dd5daf11 ]---





[  521.772929] ERROR: AddressSanitizer: heap-buffer-overflow on
address ffff88004965fbe8
[  521.774073] ffff88004965fbe8 is located 24 bytes to the left of
512-byte region [ffff88004965fc00, ffff88004965fe00)
[  521.775741] Accessed by thread T2167:
[  521.776475]   #0 ffffffff810dd2a6 (asan_report_error+0x306/0x410)
[  521.777728]   #1 ffffffff810dc6a0 (asan_check_region+0x30/0x40)
[  521.778966]   #2 ffffffff810dc9ff (asan_memcpy+0x1f/0x60)
[  521.780145]   #3 ffffffffa0003b1c (ip6_finish_output2+0x54c/0x840 [ipv6])
[  521.781570]   #4 ffffffffa00088dc (ip6_fragment+0xe2c/0x1520 [ipv6])
[  521.782912]   #5 ffffffffa00090f7 (ip6_finish_output+0x127/0x190 [ipv6])
[  521.784032]   #6 ffffffffa00091e1 (ip6_output+0x81/0x140 [ipv6])
[  521.785157]   #7 ffffffffa000630c (ip6_local_out+0x4c/0x60 [ipv6])
[  521.786460]   #8 ffffffffa0006afd
(ip6_push_pending_frames+0x7dd/0xac0 [ipv6])
[  521.787977]   #9 ffffffffa00319de (rawv6_sendmsg+0x12ae/0x15c0 [ipv6])
[  521.789366]   #10 ffffffff818bb498 (inet_sendmsg+0x108/0x160)
[  521.790597]   #11 ffffffff817d0016 (sock_aio_write+0x296/0x2e0)
[  521.791826]   #12 ffffffff8129dcb1 (do_sync_write+0x111/0x170)
[  521.792975]   #13 ffffffff8129e9fd (vfs_write+0x2dd/0x300)
[  521.793821]   #14 ffffffff8129f9a0 (SyS_write+0x80/0xe0)
[  521.794684]   #15 ffffffff81928582 (system_call_fastpath+0x16/0x1b)
[  521.795640]
[  521.795878] Allocated by thread T6026:
[  521.796474]   #0 ffffffff810dc768 (asan_slab_alloc+0x48/0xc0)
[  521.797360]   #1 ffffffff81283d89 (kmem_cache_alloc_node_trace+0x99/0x4f0)
[  521.798365]   #2 ffffffff81284211 (__kmalloc_node_track_caller+0x31/0x40)
[  521.799406]   #3 ffffffff817ded6a (__kmalloc_reserve.isra.27+0x4a/0xb0)
[  521.800436]   #4 ffffffff817e0201 (__alloc_skb+0x91/0x280)
[  521.801328]   #5 ffffffff817d807a (sock_wmalloc+0x6a/0xe0)
[  521.802170]   #6 ffffffffa0005ea6 (ip6_append_data+0x1906/0x1c20 [ipv6])
[  521.803073]   #7 ffffffffa0030dd7 (rawv6_sendmsg+0x6a7/0x15c0 [ipv6])
[  521.804068]   #8 ffffffff818bb498 (inet_sendmsg+0x108/0x160)
[  521.804919]   #9 ffffffff817d18e3 (sock_sendmsg+0x133/0x170)
[  521.805760]   #10 ffffffff817d2009 (SYSC_sendto+0x1e9/0x2d0)
[  521.806618]   #11 ffffffff817d2cc9 (SyS_sendto+0x49/0x70)
[  521.807598]   #12 ffffffff81928582 (system_call_fastpath+0x16/0x1b)
[  521.808826]
[  521.809188] Shadow bytes around the buggy address:
[  521.810231]   ffff88004965f900: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00
[  521.811752]   ffff88004965f980: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00
[  521.813253]   ffff88004965fa00: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00
[  521.814743]   ffff88004965fa80: 00 00 00 00 00 00 00 00 fa fa fa fa
fa fa fa fa
[  521.816052]   ffff88004965fb00: fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa fa
[  521.817113] =>ffff88004965fb80: fa fa fa fa fa fa fa fa fa fa fa fa
fa[fa]fa fa
[  521.818149]   ffff88004965fc00: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00
[  521.819224]   ffff88004965fc80: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00
[  521.820280]   ffff88004965fd00: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00
[  521.821357]   ffff88004965fd80: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00
[  521.822398]   ffff88004965fe00: fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa fa
[  521.823392] Shadow byte legend (one shadow byte represents 8
application bytes):
[  521.824388]   Addressable:           00
[  521.824901]   Partially addressable: 01 02 03 04 05 06 07
[  521.825667]   Heap redzone:          fa
[  521.826260]   Heap kmalloc redzone:  fb
[  521.826802]   Freed heap region:     fd
[  521.827347]   Shadow gap:            fe
[  521.827884] =========================================================================
[  521.828976] skbuff: skb_under_panic: text:ffffffffa0003b35 len:133
put:14 head:ffff88004965fc00 data:ffff88004965fbea tail:0x6f end:0xc0
dev:lo
[  521.830736] ------------[ cut here ]------------
[  521.831372] kernel BUG at net/core/skbuff.c:126!
Dec 31 18[:5 4: 035 21.831680] invalid opcode: 0000 [#1] SMP
[  521.831680] Modules linked in: snd_mixer_oss snd sr_mod cdrom loop
tun 8021qasa n3b krerinedl:g [e   5s21t.8p28976]  slkblc st ipt_ULOG
nfnetlink iptable_mangle tg3 ptp pps_core i2c_piix4 i2c_core msr cpuid
e1000 ipv6
[  521.831680] CPU: 1 PID: 2167 Comm: trinity-child52 Not tainted
3.11.0-smp-DEV #8
[  521.831680] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
uff:[ s kb _u5nd2er1_p.831680] task: ffff88004b720be0 ti:
ffff88004fc54000 task.ti: ffff88004fc54000
[  521.831680] RIP: 0010:[<ffffffff81913878>] anic :
[te<xtf:ffffffffffff81913878>] skb_panic+0xd5/0xd7
[  521.831680] RSP: 0018:ffff88004fc557a0  EFLAGS: 00010286
fffa[00 03 b355 2le1n:.831680] RAX: 0000000000000083 RBX:
ffff88004a919d80 RCX: 0000000000000000
[  521.831680] RDX: ffff880000000000 RSI: 0000000000000008 RDI: ffffffff81c44cd8
133 [pu t: 145 h2ea1d:.831680] RBP: ffff88004fc55808 R08:
000000000000006f R09: 0000000000000000
[fff f8 8050429615f.c08031680] R10: 0000000000000000 R11:
0000000007f70a60 R12: ffff88005bf89400
[  521.831680] R13: ffff88004965fbea R14: 000000000000006f R15: 00000000000000c0
 d[at a: ff5ff8280104.9831680] FS:  0000000001a48880(0063)
GS:ffff88005fd00000(0000) knlGS:0000000000000000
[  521.831680] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  521.831680] CR2: 0000000000000000 CR3: 0000000013404000 CR4: 00000000000006e0
65fbe[a  ta il52:01x.6f831680] Stack:
[  521.831680]  ffff88004965fbea 000000000000006f en d:00x0c00
d0ev0:l0o00000000c0 ffff88005bf89400
[  521.831680]  0000000e4a919d80 ffffffffa0003b35 ffffffff81aa3940
ffff88004965fc00
[  521.831680]  ffff88004a919d80 ffff88004965fbea 000000000000000e
ffff88004a919de0
[  521.831680] Call Trace:
[  521.831680]  [<ffffffffa0003b35>] ? ip6_finish_output2+0x565/0x840 [ipv6]
[  521.831680]  [<ffffffff817ddb59>] skb_push+0xa9/0xb0
[  521.831680]  [<ffffffffa0003b35>] ip6_finish_output2+0x565/0x840 [ipv6]
[  521.831680]  [<ffffffffa00088dc>] ip6_fragment+0xe2c/0x1520 [ipv6]
[  521.831680]  [<ffffffffa00035d0>] ?
ip6_flush_pending_frames+0x1d0/0x1d0 [ipv6]
[  521.831680]  [<ffffffff810dcd19>] ? asan_region_is_poisoned+0x89/0x1a0
[  521.831680]  [<ffffffffa00090f7>] ip6_finish_output+0x127/0x190 [ipv6]
[  521.831680]  [<ffffffffa00091e1>] ip6_output+0x81/0x140 [ipv6]
[  521.831680]  [<ffffffffa000630c>] ip6_local_out+0x4c/0x60 [ipv6]
[  521.831680]  [<ffffffff810dc689>] ? asan_check_region+0x19/0x40
[  521.831680]  [<ffffffffa0006afd>] ip6_push_pending_frames+0x7dd/0xac0 [ipv6]
[  521.831680]  [<ffffffffa00319de>] rawv6_sendmsg+0x12ae/0x15c0 [ipv6]
[  521.831680]  [<ffffffff810dc689>] ? asan_check_region+0x19/0x40
[  521.831680]  [<ffffffff818bb498>] inet_sendmsg+0x108/0x160
[  521.831680]  [<ffffffff817d0016>] sock_aio_write+0x296/0x2e0
[  521.831680]  [<ffffffff8129dcb1>] do_sync_write+0x111/0x170
[  521.831680]  [<ffffffff8129e9fd>] vfs_write+0x2dd/0x300
[  521.831680]  [<ffffffff8129f9a0>] SyS_write+0x80/0xe0
[  521.831680]  [<ffffffff81928582>] system_call_fastpath+0x16/0x1b
[  521.831680] Code: c7 f0 a2 ba 81 44 8b 45 bc 48 8b 55 c0 31 c0 48
8b 75 c8 4c 89 64 24 18 4c 89 7c 24 10 4c 89 74 24 08 4c 89 2c 24 e8
7d 73 ff ff <0f> 0b 55 48 89 e5 48 8b 7d 08 e8 39 9b 7c ff 0f 0b 55 48
89 e5
[  521.831680] RIP  [<ffffffff81913878>] skb_panic+0xd5/0xd7
[  521.831680]  RSP <ffff88004fc557a0>
[  521.876810] ---[ end trace 4037fd48810bceeb ]---
