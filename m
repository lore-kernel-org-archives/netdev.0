From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: kernel crash in bpf_jit on x86_64 when running nmap
Date: Fri, 10 Oct 2014 13:44:03 -0700
Message-ID: <20141010204403.GA30018@birch.djwong.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everyone,

I was running nmap on a x86_64 qemu guest and experienced the following crash:

# nmap -sS -O -vvv 192.168.122.1
Starting Nmap 6.40 ( http://nmap.org ) at 2014-10-10 13:14 PDT
Initiating ARP Ping Scan at 13:14
Scanning 192.168.122.1 [1 port]
<kaboom>

dmesg output is as follows (I set net.core.bpf_jit_enable=2 the second time):

[   32.376291] flen=3 proglen=82 pass=0 image=ffffffffc01ac65b
[   32.377595] JIT code: 00000000: 55 48 89 e5 48 81 ec 28 02 00 00 48 89 9d d8 fd
[   32.379243] JIT code: 00000010: ff ff 4c 89 ad e0 fd ff ff 4c 89 b5 e8 fd ff ff
[   32.380984] JIT code: 00000020: 4c 89 bd f0 fd ff ff 31 c0 4d 31 ed 48 89 fb b8
[   32.382606] JIT code: 00000030: 00 00 00 00 48 8b 9d d8 fd ff ff 4c 8b ad e0 fd
[   32.384280] JIT code: 00000040: ff ff 4c 8b b5 e8 fd ff ff 4c 8b bd f0 fd ff ff
[   32.385911] JIT code: 00000050: c9 c3
[   32.386841] bpf_jit: proglen=265 != oldproglen=269
[   32.387936] flen=33 proglen=265 pass=0 image=ffffffffc01ae3a2
[   32.389288] JIT code: 00000000: 55 48 89 e5 48 81 ec 28 02 00 00 48 89 9d d8 fd
[   32.390916] JIT code: 00000010: ff ff 4c 89 ad e0 fd ff ff 4c 89 b5 e8 fd ff ff
[   32.393150] JIT code: 00000020: 4c 89 bd f0 fd ff ff 31 c0 4d 31 ed 44 8b 4f 68
[   32.394820] JIT code: 00000030: 44 2b 4f 6c 4c 8b 97 c8 00 00 00 48 89 fb be 0c
[   32.397303] JIT code: 00000040: 00 00 00 e8 07 85 ec c0 48 81 f8 06 08 00 00 0f
[   32.399712] JIT code: 00000050: 85 95 00 00 00 be 0c 00 00 00 e8 f0 84 ec c0 48
[   32.402163] JIT code: 00000060: 81 f8 06 08 00 00 75 7e b8 12 00 00 00 89 45 c0
[   32.404627] JIT code: 00000070: 44 8b 6d c0 4c 89 ee 83 c6 0e e8 ab 84 ec c0 89
[   32.407027] JIT code: 00000080: 45 c4 b8 39 00 54 52 89 45 c8 44 8b 6d c8 8b 45
[   32.409498] JIT code: 00000090: c4 44 29 e8 48 83 f8 00 75 4c be 0c 00 00 00 e8
[   32.411916] JIT code: 000000a0: a7 84 ec c0 48 81 f8 06 08 00 00 75 39 b8 16 00
[   32.414479] JIT code: 000000b0: 00 00 89 45 c8 44 8b 6d c8 4c 89 ee 83 c6 0e e8
[   32.417109] JIT code: 000000c0: 7f 84 ec c0 89 45 cc b8 36 15 00 00 89 45 d0 44
[   32.419497] JIT code: 000000d0: 8b 6d d0 8b 45 cc 44 29 e8 48 83 f8 00 75 07 b8
[   32.426032] JIT code: 000000e0: 00 01 00 00 eb 05 b8 00 00 00 00 48 8b 9d d8 fd
[   32.428445] JIT code: 000000f0: ff ff 4c 8b ad e0 fd ff ff 4c 8b b5 e8 fd ff ff
[   32.430839] JIT code: 00000100: 4c 8b bd f0 fd ff ff c9 c3
[   32.432562] BUG: unable to handle kernel NULL pointer dereference at 0000000000000012
[   32.435275] IP: [<ffffffff810768cc>] efi_call+0xfc/0x100
[   32.436464] PGD 1f6b59067 PUD 1f79b6067 PMD 0 
[   32.436464] Oops: 0002 [#1] PREEMPT SMP 
[   32.436464] Modules linked in: sch_fq_codel lpc_ich mfd_core fuse nfsd auth_rpcgss exportfs virtio_scsi af_packet
[   32.436464] CPU: 0 PID: 3577 Comm: nmap Tainted: G        W      3.17.0-mcsum #1
[   32.436464] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS Bochs 01/01/2011
[   32.436464] task: ffff8801f6c69840 ti: ffff8801f6dd4000 task.ti: ffff8801f6dd4000
[   32.436464] RIP: 0010:[<ffffffff810768cc>]  [<ffffffff810768cc>] efi_call+0xfc/0x100
[   32.436464] RSP: 0018:ffff8801f6dd7860  EFLAGS: 00010212
[   32.436464] RAX: 0000000000000012 RBX: ffff8801f76e2f00 RCX: ffffffff81a94d40
[   32.436464] RDX: ffff88007b1aa080 RSI: 0000000000000020 RDI: ffff8801f76e2f00
[   32.436464] RBP: ffff8801f6dd7a90 R08: 00000000000000cc R09: 000000000000002a
[   32.436464] R10: ffff8801f796e420 R11: 000000000000002a R12: ffff8801f796e420
[   32.436464] R13: 0000000000000012 R14: ffff8801f6981000 R15: 000000000000002a
[   32.436464] FS:  00007fd30509c780(0000) GS:ffff8801ff600000(0000) knlGS:0000000000000000
[   32.436464] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   32.436464] CR2: 0000000000000012 CR3: 00000001f6a43000 CR4: 00000000000006f0
[   32.436464] Stack:
[   32.436464]  ffffffffc01ae421 ffff8801f76e2f00 ffff8801f6f5c000 ffff8801f6981000
[   32.436464]  000000000000002a 00000000002284d0 0000000000000010 00000000ffffffff
[   32.436464]  0000000000000000 0000010000000003 ffffffff81aa64c0 ffffffff81aa7248
[   32.436464] Call Trace:
[   32.436464]  [<ffffffff8114bf1a>] ? __alloc_pages_nodemask+0x14a/0xa40
[   32.436464]  [<ffffffff8129a662>] ? put_dec+0x72/0x90
[   32.436464]  [<ffffffff8129b593>] ? number.isra.2+0x323/0x360
[   32.436464]  [<ffffffff810a8538>] ? __enqueue_entity+0x78/0x80
[   32.436464]  [<ffffffff810a9bc5>] ? set_next_entity+0x95/0xb0
[   32.436464]  [<ffffffff810af0d2>] ? pick_next_task_fair+0x722/0x880
[   32.436464]  [<ffffffff81001625>] ? __switch_to+0x165/0x5a0
[   32.436464]  [<ffffffff8103fa28>] ? lookup_address+0x28/0x30
[   32.436464]  [<ffffffff8103facb>] ? _lookup_address_cpa.isra.11+0x3b/0x40
[   32.436464]  [<ffffffffc013140f>] tpacket_rcv+0xdf/0x88d [af_packet]
[   32.436464]  [<ffffffff815a3b78>] ? __schedule+0x348/0x800
[   32.436464]  [<ffffffff81039e29>] ? kvm_clock_get_cycles+0x9/0x10
[   32.436464]  [<ffffffff8149e4a7>] dev_queue_xmit_nit+0x1b7/0x230
[   32.436464]  [<ffffffff814a07dc>] dev_hard_start_xmit+0x2fc/0x650
[   32.436464]  [<ffffffff814be62e>] sch_direct_xmit+0xee/0x1c0
[   32.436464]  [<ffffffff814a0d15>] __dev_queue_xmit+0x1e5/0x4f0
[   32.436464]  [<ffffffff814a1030>] dev_queue_xmit+0x10/0x20
[   32.436464]  [<ffffffffc0130b93>] packet_sendmsg+0xd33/0x1070 [af_packet]
[   32.436464]  [<ffffffff81485c1e>] sock_sendmsg+0x6e/0x90
[   32.436464]  [<ffffffff81485db1>] SYSC_sendto+0x121/0x1d0
[   32.436464]  [<ffffffff81039e07>] ? kvm_clock_read+0x27/0x40
[   32.436464]  [<ffffffff81039e29>] ? kvm_clock_get_cycles+0x9/0x10
[   32.436464]  [<ffffffff810df857>] ? __getnstimeofday64+0x37/0xd0
[   32.436464]  [<ffffffff810df8fe>] ? getnstimeofday64+0xe/0x30
[   32.436464]  [<ffffffff810df93a>] ? do_gettimeofday+0x1a/0x50
[   32.436464]  [<ffffffff8148684e>] SyS_sendto+0xe/0x10
[   32.436464]  [<ffffffff815a882d>] system_call_fastpath+0x1a/0x1f
[   32.436464] Code: 0f 28 4c 24 50 0f 28 54 24 40 0f 28 5c 24 30 0f 28 64 24 20 0f 28 6c 24 10 48 8b 74 24 08 0f 22 c6 48 8b 24 24 c3 66 0f 1f 84 00 <00> 00 00 00 85 f6 0f 88 cc 00 00 00 44 89 c8 29 f0 83 f8 03 7e 
[   32.436464] RIP  [<ffffffff810768cc>] efi_call+0xfc/0x100
[   32.436464]  RSP <ffff8801f6dd7860>
[   32.436464] CR2: 0000000000000012
[   32.436464] ---[ end trace c2167eb2b612f788 ]---
[   32.436464] Kernel panic - not syncing: Fatal exception in interrupt
[   32.436464] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[   32.436464] ---[ end Kernel panic - not syncing: Fatal exception in interrupt

git bisect traced it back to commit 622582786c9e041d0bd52bde201787adeab249f8
("net: filter: x86: internal BPF JIT") in 3.15-rc4.  Reverting it or setting
bpf_jit_enable=0 makes the crash go away and nmap runs to completion.

I'm not sure why %rip is efi_call, since the QEMU guest doesn't support UEFI.
I'm guessing the CPU is off in the weeds, possibly as some side effect of the
proglen mismatch.  I can help debug, but I'm not a bpf_jit expert by any means.
:)

Thanks,

--Darrick
