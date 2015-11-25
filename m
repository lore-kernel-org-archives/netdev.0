From: Mark Rutland <mark.rutland@arm.com>
Subject: KASAN failures in X-Gene ethernet driver in v4.4-rc2
Date: Wed, 25 Nov 2015 15:59:07 +0000
Message-ID: <20151125155753.GE12434@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: isubramanian@apm.com, kchudgar@apm.com,
	linux-kernel@vger.kernel.org, ryabinin.a.a@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While testing a v4.4-rc2 defconfig + KASAN_INLINE kernel on an X-Gene
platform, I spotted the KASAN warnings below. I'm using the Linaro 15.08
little-endian AArch64 GCC [1] to enable KASAN_INLINE. My rootfs is an
NFS mount.

Most of the time I can trigger the issue by grabbing the kernel source
tarball:

$ wget https://cdn.kernel.org/pub/linux/kernel/v4.x/testing/linux-4.4-rc2.tar.xz

This doesn't seem to trigger for small files (< 30K or so at least), and
I don't see similar issues triggered by my NFS root during boot.

When running the same kernel and workload on a Juno platform using
SMSC911x for networking I do not see similar issues.

Any idea what's to blame?

Thanks,
Mark.

[1] https://releases.linaro.org/components/toolchain/binaries/latest-5.1/arm-linux-gnueabihf/gcc-linaro-5.1-2015.08-x86_64_arm-linux-gnueabihf.tar.xz

==================================================================
BUG: KASAN: use-after-free in xgene_enet_start_xmit+0x1a04/0x22c0 at addr ffffffc36c220cb8
Read of size 8 by task kworker/5:2H/864
=============================================================================
BUG skbuff_head_cache (Not tainted): kasan: bad access detected
-----------------------------------------------------------------------------

Disabling lock debugging due to kernel taint
INFO: Allocated in __alloc_skb+0x8c/0x448 age=3 cpu=5 pid=864
INFO: Freed in kfree_skbmem+0xc4/0xf0 age=2 cpu=0 pid=0
INFO: Slab 0xffffffbecdb08800 objects=32 used=3 fp=0xffffffc36c220c00 flags=0x4000000000004080
INFO: Object 0xffffffc36c220c00 @offset=3072 fp=0xffffffc36c221500

Bytes b4 ffffffc36c220bf0: 05 00 00 00 60 03 00 00 8a ab ff ff 00 00 00 00  ....`...........
Object ffffffc36c220c00: 00 15 22 6c c3 ff ff ff 00 00 00 00 00 00 00 00  .."l............
Object ffffffc36c220c10: 00 00 00 00 00 00 00 00 00 f0 0d 6d c3 ff ff ff  ...........m....
Object ffffffc36c220c20: 00 21 06 6d c3 ff ff ff 5e 00 00 00 14 00 00 00  .!.m....^.......
Object ffffffc36c220c30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36c220c40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36c220c50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36c220c60: 98 ce da 00 c0 ff ff ff 00 00 00 00 00 00 00 00  ................
Object ffffffc36c220c70: 82 05 00 00 40 05 00 00 0e 00 00 00 00 00 00 00  ....@...........
Object ffffffc36c220c80: 00 16 00 00 80 00 10 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36c220c90: 95 6e 6a c8 00 00 00 00 06 00 00 00 00 00 00 00  .nj.............
Object ffffffc36c220ca0: 00 00 00 00 00 00 00 00 08 00 80 00 6c 00 5e 00  ............l.^.
Object ffffffc36c220cb0: a0 00 00 00 80 02 00 00 80 ba c7 6c c3 ff ff ff  ...........l....
Object ffffffc36c220cc0: de ba c7 6c c3 ff ff ff 40 0a 00 00 01 00 00 00  ...l....@.......
CPU: 5 PID: 864 Comm: kworker/5:2H Tainted: G    B           4.4.0-rc2 #4
Hardware name: APM X-Gene Mustang board (DT)
Workqueue: rpciod rpc_async_schedule
Call trace:
[<ffffffc00008e770>] dump_backtrace+0x0/0x280
[<ffffffc00008ea04>] show_stack+0x14/0x20
[<ffffffc000725360>] dump_stack+0x100/0x188
[<ffffffc00030c69c>] print_trailer+0xfc/0x168
[<ffffffc0003115fc>] object_err+0x3c/0x50
[<ffffffc000313464>] kasan_report_error+0x244/0x558
[<ffffffc0003138b0>] __asan_report_load8_noabort+0x48/0x50
[<ffffffc000a6fcfc>] xgene_enet_start_xmit+0x1a04/0x22c0
[<ffffffc000ce1a04>] dev_hard_start_xmit+0x5bc/0xa70
[<ffffffc000d28da0>] sch_direct_xmit+0x2d8/0x5d0
[<ffffffc000ce28d0>] __dev_queue_xmit+0x6a8/0x10d0
[<ffffffc000ce3308>] dev_queue_xmit+0x10/0x18
[<ffffffc000d573f4>] ip_finish_output2+0x5f4/0x1010
[<ffffffc000d5d364>] ip_finish_output+0x48c/0x688
[<ffffffc000d5fd28>] ip_output+0x278/0x358
[<ffffffc000d5da04>] ip_local_out+0xa4/0xc8
[<ffffffc000d5e75c>] ip_queue_xmit+0x534/0x1368
[<ffffffc000db20d4>] tcp_transmit_skb+0x10cc/0x27c8
[<ffffffc000db3d0c>] tcp_write_xmit+0x53c/0x4788
[<ffffffc000db8584>] __tcp_push_pending_frames+0x8c/0x1e0
[<ffffffc000d7695c>] tcp_push+0x37c/0x550
[<ffffffc000d81138>] tcp_sendpage+0xdc8/0x1428
[<ffffffc000e0d7a8>] inet_sendpage+0x208/0x338
[<ffffffc000ea0f88>] xs_sendpages+0x378/0x4b8
[<ffffffc000ea12bc>] xs_tcp_send_request+0x1f4/0x4b0
[<ffffffc000e9b2b8>] xprt_transmit+0xe0/0x6f8
[<ffffffc000e946bc>] call_transmit+0x6f4/0xcd8
[<ffffffc000ea868c>] __rpc_execute+0x104/0x590
[<ffffffc000ea8b28>] rpc_async_schedule+0x10/0x18
[<ffffffc00012b6f8>] process_one_work+0x3d0/0xc80
[<ffffffc00012c2f0>] worker_thread+0x348/0xd90
[<ffffffc00013ae3c>] kthread+0x1f4/0x258
[<ffffffc000086c50>] ret_from_fork+0x10/0x40
Memory state around the buggy address:
 ffffffc36c220b80: fb fb fb fb fb fb fb fb fb fb fc fc fc fc fc fc
 ffffffc36c220c00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffffffc36c220c80: fb fb fb fb fb fb fb fb fb fb fc fc fc fc fc fc
                                        ^
 ffffffc36c220d00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffffffc36c220d80: fb fb fb fb fb fb fb fb fb fb fc fc fc fc fc fc
==================================================================
==================================================================
BUG: KASAN: use-after-free in xgene_enet_start_xmit+0x19f8/0x22c0 at addr ffffffc36c220cb4
Read of size 4 by task kworker/5:2H/864
=============================================================================
BUG skbuff_head_cache (Tainted: G    B          ): kasan: bad access detected
-----------------------------------------------------------------------------

INFO: Allocated in __alloc_skb+0x8c/0x448 age=57 cpu=5 pid=864
INFO: Freed in kfree_skbmem+0xc4/0xf0 age=56 cpu=0 pid=0
INFO: Slab 0xffffffbecdb08800 objects=32 used=3 fp=0xffffffc36c220c00 flags=0x4000000000004080
INFO: Object 0xffffffc36c220c00 @offset=3072 fp=0xffffffc36c221500

Bytes b4 ffffffc36c220bf0: 05 00 00 00 60 03 00 00 8a ab ff ff 00 00 00 00  ....`...........
Object ffffffc36c220c00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36c220c10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36c220c20: 00 21 06 6d c3 ff ff ff 00 00 00 00 00 00 00 00  .!.m............
Object ffffffc36c220c30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36c220c40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36c220c50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36c220c60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36c220c70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 20 00  .............. .
Object ffffffc36c220c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36c220c90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36c220ca0: 00 00 00 00 00 00 00 00 00 00 ff ff 00 00 ff ff  ................
Object ffffffc36c220cb0: 82 00 00 00 00 07 00 00 80 f7 4f 67 c3 ff ff ff  ..........Og....
Object ffffffc36c220cc0: 02 f8 4f 67 c3 ff ff ff 80 09 00 00 01 00 00 00  ..Og............
CPU: 5 PID: 864 Comm: kworker/5:2H Tainted: G    B           4.4.0-rc2 #4
Hardware name: APM X-Gene Mustang board (DT)
Workqueue: rpciod rpc_async_schedule
Call trace:
[<ffffffc00008e770>] dump_backtrace+0x0/0x280
[<ffffffc00008ea04>] show_stack+0x14/0x20
[<ffffffc000725360>] dump_stack+0x100/0x188
[<ffffffc00030c69c>] print_trailer+0xfc/0x168
[<ffffffc0003115fc>] object_err+0x3c/0x50
[<ffffffc000313464>] kasan_report_error+0x244/0x558
[<ffffffc000313860>] __asan_report_load4_noabort+0x48/0x50
[<ffffffc000a6fcf0>] xgene_enet_start_xmit+0x19f8/0x22c0
[<ffffffc000ce1a04>] dev_hard_start_xmit+0x5bc/0xa70
[<ffffffc000d28da0>] sch_direct_xmit+0x2d8/0x5d0
[<ffffffc000ce28d0>] __dev_queue_xmit+0x6a8/0x10d0
[<ffffffc000ce3308>] dev_queue_xmit+0x10/0x18
[<ffffffc000d573f4>] ip_finish_output2+0x5f4/0x1010
[<ffffffc000d5d364>] ip_finish_output+0x48c/0x688
[<ffffffc000d5fd28>] ip_output+0x278/0x358
[<ffffffc000d5da04>] ip_local_out+0xa4/0xc8
[<ffffffc000d5e75c>] ip_queue_xmit+0x534/0x1368
[<ffffffc000db20d4>] tcp_transmit_skb+0x10cc/0x27c8
[<ffffffc000db3d0c>] tcp_write_xmit+0x53c/0x4788
[<ffffffc000db8584>] __tcp_push_pending_frames+0x8c/0x1e0
[<ffffffc000d7695c>] tcp_push+0x37c/0x550
[<ffffffc000d81138>] tcp_sendpage+0xdc8/0x1428
[<ffffffc000e0d7a8>] inet_sendpage+0x208/0x338
[<ffffffc000ea0f88>] xs_sendpages+0x378/0x4b8
[<ffffffc000ea12bc>] xs_tcp_send_request+0x1f4/0x4b0
[<ffffffc000e9b2b8>] xprt_transmit+0xe0/0x6f8
[<ffffffc000e946bc>] call_transmit+0x6f4/0xcd8
[<ffffffc000ea868c>] __rpc_execute+0x104/0x590
[<ffffffc000ea8b28>] rpc_async_schedule+0x10/0x18
[<ffffffc00012b6f8>] process_one_work+0x3d0/0xc80
[<ffffffc00012c2f0>] worker_thread+0x348/0xd90
[<ffffffc00013ae3c>] kthread+0x1f4/0x258
[<ffffffc000086c50>] ret_from_fork+0x10/0x40
Memory state around the buggy address:
 ffffffc36c220b80: 00 00 00 00 00 00 00 00 00 00 fc fc fc fc fc fc
 ffffffc36c220c00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>ffffffc36c220c80: 00 00 00 00 00 00 00 00 00 00 fc fc fc fc fc fc
                                     ^
 ffffffc36c220d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffffffc36c220d80: 00 00 00 00 00 00 00 00 00 00 fc fc fc fc fc fc
==================================================================
==================================================================
BUG: KASAN: use-after-free in xgene_enet_start_xmit+0x19ec/0x22c0 at addr ffffffc36cc7c181
Read of size 1 by task kworker/5:2H/864
=============================================================================
BUG kmalloc-1024 (Tainted: G    B          ): kasan: bad access detected
-----------------------------------------------------------------------------

INFO: Allocated in __alloc_skb+0xb4/0x448 age=125 cpu=5 pid=864
INFO: Freed in skb_release_data+0x1dc/0x2e0 age=126 cpu=0 pid=0
INFO: Slab 0xffffffbecdb31e00 objects=28 used=1 fp=0xffffffc36cc7ba80 flags=0x4000000000004080
INFO: Object 0xffffffc36cc7bf00 @offset=16128 fp=0xffffffc36cc7d100

Bytes b4 ffffffc36cc7bef0: 1f 04 00 31 42 30 00 91 00 10 83 1a 5f 00 05 eb  ...1B0......_...
Object ffffffc36cc7bf00: 00 d1 c7 6c c3 ff ff ff 46 00 00 00 78 00 00 00  ...l....F...x...
Object ffffffc36cc7bf10: 01 01 6f 00 2a 00 00 00 2f 63 6f 6d 2f 75 62 75  ..o.*.../com/ubu
Object ffffffc36cc7bf20: 6e 74 75 2f 55 70 73 74 61 72 74 2f 6a 6f 62 73  ntu/Upstart/jobs
Object ffffffc36cc7bf30: 2f 6d 6f 75 6e 74 65 64 5f 32 64 64 65 62 75 67  /mounted_2ddebug
Object ffffffc36cc7bf40: 66 73 00 00 00 00 00 00 02 01 73 00 1f 00 00 00  fs........s.....
Object ffffffc36cc7bf50: 6f 72 67 2e 66 72 65 65 64 65 73 6b 00 00 44 8a  org.freedesk..D.
Object ffffffc36cc7bf60: 5b 51 8c f4 00 01 73 02 02 50 08 00 45 00 05 dc  [Q....s..P..E...
Object ffffffc36cc7bf70: fa 55 40 00 40 06 8b 8d 0a 01 cd 9f 0a 01 cd 97  .U@.@...........
Object ffffffc36cc7bf80: 03 60 08 01 c5 1e 04 82 9a f9 1d 35 80 10 14 29  .`.........5...)
Object ffffffc36cc7bf90: b5 07 00 00 01 01 08 0a ff ff ab 85 12 1e a1 b6  ................
Object ffffffc36cc7bfa0: 80 00 10 8c 9d a8 2f fa 00 00 00 00 00 00 00 02  ....../.........
Object ffffffc36cc7bfb0: 00 01 86 a3 00 00 00 03 00 00 00 07 00 00 00 01  ................
Object ffffffc36cc7bfc0: 00 00 00 28 01 06 24 86 00 00 00 0c 31 30 2e 31  ...(..$.....10.1
Object ffffffc36cc7bfd0: 2e 32 30 35 2e 31 35 39 00 00 03 e8 00 00 03 e8  .205.159........
Object ffffffc36cc7bfe0: 00 00 00 02 00 00 00 1b 00 00 03 e8 00 00 00 00  ................
Object ffffffc36cc7bff0: 00 00 00 00 00 00 00 24 01 00 07 01 13 00 d8 00  .......$........
Object ffffffc36cc7c000: 00 00 00 00 5c c4 3a 28 b0 91 4f af a1 03 ca b8  ....\.:(..O.....
Object ffffffc36cc7c010: 0a 35 dc 7a 5e 00 d6 01 a0 fc 52 b4 00 00 00 00  .5.z^.....R.....
Object ffffffc36cc7c020: 01 10 a0 00 00 00 10 00 00 00 00 00 00 00 10 00  ................
Object ffffffc36cc7c030: 02 7c 79 d3 e0 03 19 aa aa 77 fe 97 60 8e 40 b9  .|y......w..`.@.
Object ffffffc36cc7c040: 80 02 00 b9 f4 03 15 2a 76 fd ff 35 e0 03 13 aa  .......*v..5....
Object ffffffc36cc7c050: dc f7 fc 97 bf 03 00 91 e0 03 14 2a f5 5b 42 a9  ...........*.[B.
Object ffffffc36cc7c060: f3 53 41 a9 f7 63 43 a9 f9 23 40 f9 fd 7b c7 a8  .SA..cC..#@..{..
Object ffffffc36cc7c070: c0 03 5f d6 02 03 00 f0 42 24 47 f9 c3 02 80 52  .._.....B$G....R
Object ffffffc36cc7c080: 40 d0 3b d5 03 68 22 b8 f5 03 01 2a d8 ff ff 17  @.;..h"....*....
Object ffffffc36cc7c090: 42 7c 79 d3 e8 ff ff 17 e0 03 13 aa a1 2f 00 f9  B|y........../..
Object ffffffc36cc7c0a0: a3 2b 00 f9 0e ce ff 97 f6 03 00 2a a1 2f 40 f9  .+.........*./@.
Object ffffffc36cc7c0b0: a3 2b 40 f9 40 f6 ff 35 e0 03 13 aa a1 2f 2f 00  .+@.@..5.....//.
Object ffffffc36cc7c0c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36cc7c0d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36cc7c0e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36cc7c0f0: 14 10 80 52 b4 1c b4 9b f7 63 03 a9 f5 5b 02 a9  ...R.....c...[..
Object ffffffc36cc7c100: c0 b0 c7 6c c3 ff ff ff 68 5b b8 d5 7f 00 00 00  ...l....h[......
Object ffffffc36cc7c110: 00 00 00 00 00 00 00 00 00 00 00 00 2f 73 79 73  ............/sys
Object ffffffc36cc7c120: 2f 63 6c 61 73 73 2f 64 6d 69 2f 69 64 00 65 73  /class/dmi/id.es
Object ffffffc36cc7c130: 2f 69 64 00 65 73 2f 69 64 00 00 00 65 76 65 6e  /id.es/id...even
Object ffffffc36cc7c140: 74 00 75 65 70 63 69 30 30 30 30 3a 30 30 2f 30  t.uepci0000:00/0
Object ffffffc36cc7c150: 30 30 30 3a 30 30 3a 30 30 2e 30 2f 70 63 69 5f  000:00:00.0/pci_
Object ffffffc36cc7c160: 62 75 73 2f 30 30 30 30 3a 30 31 2f 75 65 76 65  bus/0000:01/ueve
Object ffffffc36cc7c170: 6e 74 00 65 a3 27 40 f9 a0 02 40 79 e1 03 03 2a  nt.e.'@...@y...*
Object ffffffc36cc7c180: 01 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00  . ..............
Object ffffffc36cc7c190: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36cc7c1a0: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36cc7c1b0: c0 57 a9 cd be ff ff ff 00 00 00 00 a8 05 00 00  .W..............
Object ffffffc36cc7c1c0: fd 7b c7 a8 c0 03 5f d6 02 03 00 f0 42 24 47 f9  .{...._.....B$G.
Object ffffffc36cc7c1d0: 40 d0 3b d5 c3 02 80 52 03 68 22 b8 e0 03 01 2a  @.;....R.h"....*
Object ffffffc36cc7c1e0: f4 03 00 2a 56 fe ff 35 e0 03 13 aa 75 f7 fc 97  ...*V..5....u...
Object ffffffc36cc7c1f0: bf 03 00 91 e0 03 14 2a f5 5b 42 a9 f3 53 41 a9  .......*.[B..SA.
Object ffffffc36cc7c200: 80 b1 c7 6c c3 ff ff ff c0 03 5f d6 e0 03 14 aa  ...l......_.....
Object ffffffc36cc7c210: a1 37 00 f9 a3 27 00 f9 a4 33 00 f9 a5 2f 00 f9  .7...'...3.../..
Object ffffffc36cc7c220: a6 2b 00 f9 ae cd ff 97 f6 03 00 2a a1 37 40 f9  .+.........*.7@.
Object ffffffc36cc7c230: a3 27 40 f9 a4 33 40 f9 a5 2f 40 f9 a6 2b 40 f9  .'@..3@../@..+@.
Object ffffffc36cc7c240: a0 f6 ff 35 e0 03 14 aa a1 37 00 f9 a3 27 00 f9  ...5.....7...'..
Object ffffffc36cc7c250: a4 33 00 f9 a5 2f 00 f9 a6 2b 00 f9 3d f7 fc 97  .3.../...+..=...
Object ffffffc36cc7c260: f3 03 00 aa a1 37 40 f9 a3 27 40 f9 b1 c5 96 e4  .....7@..'@.....
Object ffffffc36cc7c270: 00 00 00 00 00 00 00 00 00 10 00 00 00 00 00 00  ................
Object ffffffc36cc7c280: 00 00 00 00 00 00 00 00 01 00 00 00 a4 07 00 00  ................
Object ffffffc36cc7c290: 3f 12 00 00 01 00 00 00 00 00 00 00 00 00 00 00  ?...............
Object ffffffc36cc7c2a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36cc7c2b0: 94 e7 ff ff 00 00 00 00 94 2d 59 00 c0 ff ff ff  .........-Y.....
Object ffffffc36cc7c2c0: 00 00 00 00 00 00 00 00 0a ee ff ff 00 00 00 00  ................
Object ffffffc36cc7c2d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36cc7c2e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffffffc36cc7c2f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Padding ffffffc36cc7c330: 00 1e b3 cd be ff ff ff 44 34 00 00 34 05 00 00  ........D4..4...
Padding ffffffc36cc7c340: 00 1e b3 cd be ff ff ff c4 2b 00 00 7c 00 00 00  .........+..|...
Padding ffffffc36cc7c350: 00 1e b3 cd be ff ff ff 44 23 00 00 a8 05 00 00  ........D#......
Padding ffffffc36cc7c360: 00 1e b3 cd be ff ff ff c4 1a 00 00 a8 05 00 00  ................
Padding ffffffc36cc7c370: 00 1e b3 cd be ff ff ff 44 12 00 00 34 05 00 00  ........D...4...
CPU: 5 PID: 864 Comm: kworker/5:2H Tainted: G    B           4.4.0-rc2 #4
Hardware name: APM X-Gene Mustang board (DT)
Workqueue: rpciod rpc_async_schedule
Call trace:
[<ffffffc00008e770>] dump_backtrace+0x0/0x280
[<ffffffc00008ea04>] show_stack+0x14/0x20
[<ffffffc000725360>] dump_stack+0x100/0x188
[<ffffffc00030c69c>] print_trailer+0xfc/0x168
[<ffffffc0003115fc>] object_err+0x3c/0x50
[<ffffffc000313464>] kasan_report_error+0x244/0x558
[<ffffffc0003137c0>] __asan_report_load1_noabort+0x48/0x50
[<ffffffc000a6fce4>] xgene_enet_start_xmit+0x19ec/0x22c0
[<ffffffc000ce1a04>] dev_hard_start_xmit+0x5bc/0xa70
[<ffffffc000d28da0>] sch_direct_xmit+0x2d8/0x5d0
[<ffffffc000ce28d0>] __dev_queue_xmit+0x6a8/0x10d0
[<ffffffc000ce3308>] dev_queue_xmit+0x10/0x18
[<ffffffc000d573f4>] ip_finish_output2+0x5f4/0x1010
[<ffffffc000d5d364>] ip_finish_output+0x48c/0x688
[<ffffffc000d5fd28>] ip_output+0x278/0x358
[<ffffffc000d5da04>] ip_local_out+0xa4/0xc8
[<ffffffc000d5e75c>] ip_queue_xmit+0x534/0x1368
[<ffffffc000db20d4>] tcp_transmit_skb+0x10cc/0x27c8
[<ffffffc000db3d0c>] tcp_write_xmit+0x53c/0x4788
[<ffffffc000db8584>] __tcp_push_pending_frames+0x8c/0x1e0
[<ffffffc000d7695c>] tcp_push+0x37c/0x550
[<ffffffc000d81138>] tcp_sendpage+0xdc8/0x1428
[<ffffffc000e0d7a8>] inet_sendpage+0x208/0x338
[<ffffffc000ea0f88>] xs_sendpages+0x378/0x4b8
[<ffffffc000ea12bc>] xs_tcp_send_request+0x1f4/0x4b0
[<ffffffc000e9b2b8>] xprt_transmit+0xe0/0x6f8
[<ffffffc000e946bc>] call_transmit+0x6f4/0xcd8
[<ffffffc000ea868c>] __rpc_execute+0x104/0x590
[<ffffffc000ea8b28>] rpc_async_schedule+0x10/0x18
[<ffffffc00012b6f8>] process_one_work+0x3d0/0xc80
[<ffffffc00012c2f0>] worker_thread+0x348/0xd90
[<ffffffc00013ae3c>] kthread+0x1f4/0x258
[<ffffffc000086c50>] ret_from_fork+0x10/0x40
Memory state around the buggy address:
 ffffffc36cc7c080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffffffc36cc7c100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffffffc36cc7c180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                   ^
 ffffffc36cc7c200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffffffc36cc7c280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================
