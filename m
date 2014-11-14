From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: net-next panic in ovs call to arch_fast_hash2 since e5a2c899
Date: Thu, 13 Nov 2014 18:15:32 -0800
Message-ID: <12086.1415931332@famine>
Cc: discuss@openvswitch.org, Pravin Shelar <pshelar@nicira.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:46025 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933518AbaKNCPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 21:15:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	I'm having an issue with recent net-next, wherein a call is now
using alternative_call, and this is apparently being mis-compiled for
the "don't have feature" case.

	I'm using gcc (Ubuntu 4.8.2-19ubuntu1) 4.8.2 on an Ubuntu 14.04
system.

	The call is in net/openvswitch/flow_table.c:flow_hash(), which
as of commit

commit e5a2c899957659cd1a9f789bc462f9c0b35f5150
Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date:   Wed Nov 5 00:23:04 2014 +0100

    fast_hash: avoid indirect function calls

	uses arch_fast_hash2, which is an alternative_call function,
selecting between __jhash2 and __intel_crc4_2_hash based on the
X86_FEATURE_XMM4_2:

static inline u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
{
        u32 hash;

        alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
#ifdef CONFIG_X86_64
                         "=a" (hash), "D" (data), "S" (len), "d" (seed));
#else
                         "=a" (hash), "a" (data), "d" (len), "c" (seed));
#endif
        return hash;
}

	This is panicing on a system without X86_FEATURE_XMM4_2.

	Reverting just the above commit does make the problem go away.

	It appears that the alternative_call itself is not calling
__jhash2 correctly:

0xffffffffa01a55dd <ovs_flow_tbl_insert+0xcd>:	sub    %ecx,%esi
0xffffffffa01a55df <ovs_flow_tbl_insert+0xcf>:	lea    0x38(%r8,%rax,1),%rdi
0xffffffffa01a55e4 <ovs_flow_tbl_insert+0xd4>:	sar    $0x2,%esi
0xffffffffa01a55e7 <ovs_flow_tbl_insert+0xd7>:	callq  0xffffffff813a75c0 <__jhash2>
0xffffffffa01a55ec <ovs_flow_tbl_insert+0xdc>:	mov    %eax,0x30(%r8)
0xffffffffa01a55f0 <ovs_flow_tbl_insert+0xe0>:	mov    (%rbx),%r13
0xffffffffa01a55f3 <ovs_flow_tbl_insert+0xe3>:	mov    %r8,%rsi
0xffffffffa01a55f6 <ovs_flow_tbl_insert+0xe6>:	mov    %r13,%rdi
0xffffffffa01a55f9 <ovs_flow_tbl_insert+0xe9>:	callq  0xffffffffa01a4ba0 <table_instance_insert>

	but __jhash2 clobbers %r8 (which is not saved), resulting in a
panic on the next instruction at ovs_flow_tbl_insert+0xdc:

[   17.762419] BUG: unable to handle kernel paging request at 00000000f6cc13e5
[   17.765456] IP: [<ffffffffa01a6bec>] ovs_flow_tbl_insert+0xdc/0x1f0 [openvswi
tch]
[   17.765456] PGD b18da067 PUD 0 
[   17.765456] Oops: 0002 [#1] SMP 
[   17.765456] Modules linked in: openvswitch libcrc32c i915 video drm_kms_helpe
r coretemp kvm_intel drm kvm gpio_ich ppdev parport_pc lpc_ich i2c_algo_bit lp s
erio_raw parport mac_hid hid_generic usbhid hid psmouse r8169 mii sky2
[   17.765456] CPU: 0 PID: 901 Comm: ovs-vswitchd Not tainted 3.18.0-rc2-nn-4d3c
9d37+ #19
[   17.765456] Hardware name: LENOVO 0829F3U/To be filled by O.E.M., BIOS 90KT15
AUS 07/21/2010
[   17.765456] task: ffff8800b07c9900 ti: ffff8800b1a04000 task.ti: ffff8800b1a0
4000
[   17.765456] RIP: 0010:[<ffffffffa01a6bec>]  [<ffffffffa01a6bec>] ovs_flow_tbl
_insert+0xdc/0x1f0 [openvswitch]
[   17.765456] RSP: 0018:ffff8800b1a07798  EFLAGS: 00010293
[   17.765456] RAX: 00000000e81d0094 RBX: ffff8800b27a0b20 RCX: 000000007aa02ddf
[   17.765456] RDX: 000000005e013969 RSI: 00000000290f109c RDI: ffff880138d501a4
[   17.765456] RBP: ffff8800b1a077e8 R08: 00000000f6cc13b5 R09: 00000000748df07f
[   17.765456] R10: ffffffffa01a6c96 R11: 0000000000000004 R12: ffff8800b27a0b28
[   17.765456] R13: ffff8800b1a07850 R14: ffff8800b27a0b28 R15: ffff8800a5a99c00
[   17.765456] FS:  00007fcd60b8d980(0000) GS:ffff88013fc00000(0000) knlGS:0000000000000000
[   17.765456] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   17.765456] CR2: 00000000f6cc13e5 CR3: 0000000031846000 CR4: 00000000000407f0
[   17.765456] Stack:
[   17.765456]  ffff880138d50000 ffff8800b1a07a70 ffff880138d50000 0000000000000000
[   17.765456]  ffff880138d501c0 ffff8800b1a07a70 ffff880138d50000 0000000000000000
[   17.765456]  0000000000000000 ffff8800b27a0b20 ffff8800b1a07a38 ffffffffa019e1fe
[   17.765456] Call Trace:
[   17.765456]  [<ffffffffa019e1fe>] ovs_flow_cmd_new+0x23e/0x3c0 [openvswitch]
[   17.765456]  [<ffffffff8165f3e5>] genl_family_rcv_msg+0x1a5/0x3c0

	The "have feature" function, __intel_crc4_2_hash2, does not
clobber %r8, and so the call does not panic on a system with
X86_FEATURE_XMM4_2, although I'm not sure if that's a deliberate
compiler action or just happenstance because __intel_crc4_2_hash2 uses
fewer registers than __jhash2.

	As I said above, reverting the commit in question does resolve
the problem, but it does appear that there is a problem in the compiler
or alternative_call system that is the real root cause.

	I've discussed this with Jesse Gross <jesse@nicira.com> and
Pravin Shelar <pshelar@nicira.com>, who don't see the problem, but I
suspect that's because they have newer cpus with X86_FEATURE_XMM4_2.
Jesse, Pravin, can you confirm whether or not your test systems have
this cpu feature (it's "sse4_2" in /proc/cpuinfo's flags)?

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
