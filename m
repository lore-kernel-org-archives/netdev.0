From: Andrew Smith <iamasmith.home@gmail.com>
Subject: Kernel OOPS (NULL pointer) with incomplete sock structure?
Date: Thu, 30 Jan 2014 16:16:03 +0000
Message-ID: <CADb65V7X0OPHay7gaMuZoMzPu6HwjXUiqZ=HdcZSp9n3bFJuOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f193.google.com ([209.85.128.193]:63911 "EHLO
	mail-ve0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbaA3QQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 11:16:03 -0500
Received: by mail-ve0-f193.google.com with SMTP id pa12so562370veb.8
        for <netdev@vger.kernel.org>; Thu, 30 Jan 2014 08:16:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel OOPS (NULL pointer) with incomplete sock structure?

I'm debugging a problem that has appeared on a test rig here and I'm
wondering if anybody could shed any additional insight into what might
be happening.

I have a rig running on VMWare ESXi 5.5 with 12 4 Core CentOS 6.4
shipping approximately 100MB/second across the network and within an
hour usually one of the nodes fails with a trap as follows.

<7>out of order segment: rcv_next 3F89F4D seq AF008380 - A5BE3000
<1>BUG: unable to handle kernel NULL pointer dereference at 00000000000000b0
<1>IP: [<ffffffff8148fd63>] skb_set_owner_r+0x53/0x70
<4>PGD 13ba5a067 PUD 13cec4067 PMD 0
<4>Oops: 0000 [#1] SMP
<4>last sysfs file: /sys/module/ip_tables/initstate
<4>CPU 0
<4>Modules linked in: iptable_mangle ipv6 ipt_REJECT nf_conntrack_ipv4
nf_defrag_ipv4 xt_state nf_conntrack iptable_filter ip_tables ppdev
parport_pc parport vmxnet(U) vmware_balloon vmci(U) i2c_piix4 i2c_core
sg shpchp ext4 mbcache jbd2 sd_mod crc_t10dif sr_mod cdrom vmw_pvscsi
pata_acpi ata_generic ata_piix dm_mirror dm_region_hash dm_log dm_mod
[last unloaded: scsi_wait_scan]
<4>
<4>Pid: 1329, comm: java Not tainted 2.6.32-358.11.1.el6.x86_64 #1
VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform
<4>RIP: 0010:[<ffffffff8148fd63>]  [<ffffffff8148fd63>]
skb_set_owner_r+0x53/0x70
<4>RSP: 0000:ffff880028203a30  EFLAGS: 00010206
<4>RAX: 0000000000000000 RBX: ffff8800a405f780 RCX: 0000000000000000
<4>RDX: 0000000000000ab4 RSI: ffff8800a405f780 RDI: ffff8800a405f780
<4>RBP: ffff880028203a40 R08: 00000000000126a8 R09: 00000000fffffff7
<4>R10: 0000000000000007 R11: 000000000000000a R12: ffff8800a405f780
<4>R13: ffff8800a405f780 R14: ffff8800a405fd00 R15: 0000000000000002
<4>FS:  00007ff42d0d0700(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
<4>CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>CR2: 00000000000000b0 CR3: 000000013c441000 CR4: 00000000000006f0
<4>DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>Process java (pid: 1329, threadinfo ffff8800a5596000, task ffff880139c94080)
<4>Stack:
<4> ffff8800a405f780 ffff8800a405f780 ffff880028203a60 ffffffff814950f2
<4><d> ffff8800a405f780 0000000000000004 ffff880028203a80 ffffffff8143d38e
<4><d> 0000000000000000 ffff8800af008380 ffff880028203b50 ffffffff81496dd4
<4>Call Trace:
<4> <IRQ>
<4> [<ffffffff814950f2>] tcp_data_queue+0x432/0xc70
<4> [<ffffffff8143d38e>] __kfree_skb+0x1e/0xa0
<4> [<ffffffff81496dd4>] tcp_ack+0x3b4/0x12c0
<4> [<ffffffffa01810d5>] ? ipt_do_table+0x295/0x678 [ip_tables]

The trap seems consistent across several (although always CentOS)
Kernel revisions including 2.6.32.431.3.1 shipped with 6.5 and
manifests in the same way with the following combinations..

1. 2.6.32.385 Kernels from 6.4 and Open VM tools RPM from VMWare package feed.
2. 2.6.32.385 Kernels from 6.4 with Open VM Tools with modules built
for the Kernel.
3. 2.6.32.431.3.1 Kernel from 6.5 using vmxnet3 drivers included in the Kernel.

Tracing skb_set_owner I isolated the failing operation to an inline
function in sock.h which seems to be present in current Linux 3.x
Kernels also.

static inline int sk_has_account(struct sock *sk)
{
        /* return true if protocol supports memory accounting */
        return !!sk->sk_prot->memory_allocated;
}

The faulting instruction actually being the bottom one here..

/usr/src/debug/kernel-2.6.32-358.11.1.el6/linux-2.6.32-358.11.1.el6.x86_64/include/net/sock.h:
970
0xffffffff8148fd58 <skb_set_owner_r+72>:        mov    0x30(%r12),%rax
/usr/src/debug/kernel-2.6.32-358.11.1.el6/linux-2.6.32-358.11.1.el6.x86_64/include/net/sock.h:
1515
0xffffffff8148fd5d <skb_set_owner_r+77>:        mov    0xe0(%rbx),%edx
/usr/src/debug/kernel-2.6.32-358.11.1.el6/linux-2.6.32-358.11.1.el6.x86_64/include/net/sock.h:
1007
0xffffffff8148fd63 <skb_set_owner_r+83>:        cmpq   $0x0,0xb0(%rax)

And dumping the particular sock structure reveals the problem to be
that the sk->sk_prot pointer (actually that's a define pointing to
__sk_common.skc_prot) to be NULL.

crash> *sock 0xffff8800a405f7B0
struct sock {
  __sk_common = {
    {
      skc_node = {
        next = 0x0,
        pprev = 0x0
      },
      skc_nulls_node = {
        next = 0x0,
        pprev = 0x0
      }
    },
    skc_refcnt = {
      counter = 0
    },
    skc_hash = 0,
    skc_family = 0,
    skc_state = 0 '\000',
    skc_reuse = 0 '\000',
    skc_bound_dev_if = 0,
    skc_bind_node = {
      next = 0xcd498725cd498171,
      pprev = 0x1803f8a043
    },
    skc_prot = 0x0,
    skc_net = 0x5b4000005b4
  },

I'm somewhat baffled as to how a structure like this can occur since
the socket when constructed, either for listening or for connecting,
should have skc_prot pointed to an appropriate handler and this would
seem to obviate the need to additionally protect the check in
sk_has_account by checking the skc_prot pointer first.

I'm speculating about Hypervisor related problems that may contribute
to this and am about to look at a stock Kernel to repeat this test and
avoid any CentOS differences but I was wondering if anybody has seen
anything similar or can suggest how a sock can end up in a state
without skc_prot populated.

Regards,


Andy
