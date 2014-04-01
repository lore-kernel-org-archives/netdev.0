From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH] vxlan: using AF_PACKET socket to send multicast packet cause WARNING
Date: Tue,  1 Apr 2014 17:08:50 +0800
Message-ID: <1396343330-23648-1-git-send-email-lucien.xin@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:57407 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbaDAJJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 05:09:05 -0400
Received: by mail-pa0-f53.google.com with SMTP id ld10so9518369pab.40
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 02:09:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we use AF_PACKET socket in normal network interface, it bypass the
protocol stack and send packets directly with dev_queue_xmit(), so it will
never trigger this problem. when we use it in vxlan interface. the path will
like this:
dev_queue_xmit()->dev_hard_start_xmit()->vxlan_xmit()->ip_tunnel_xmit()->ip_mc_output(),
after reaching ip_mc_output(), it will check the mc_loop by sk_mc_loop(), but
it have no case for AF_PACKET, then cause WARN_ON(1).

Perhaps others type interfaces like vxlan also has the same issue. so fix it
by adding the case for AF_PACKET in sk_mc_loop().

you can use 'dhclient' on a vxlan interface to reproduce it easily.

[ 2133.224368] ------------[ cut here ]------------
[ 2133.228971] WARNING: CPU: 0 PID: 10226 at include/net/ip.h:433
ip_mc_output+0x189/0x250()
[ 2133.235054] Modules linked in: vxlan(F) ip_tunnel nf_conntrack_netbios_ns
nf_conntrack_broadcast ipt_MASQUERADE ip6t_REJECT xt_conntrack ebtable_nat
ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat
nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security
ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security
iptable_raw kvm_amd kvm ppdev parport_pc pcspkr serio_raw i2c_piix4 parport
pvpanic xfs libcrc32c cirrus drm_kms_helper ttm drm virtio_net virtio_blk
ata_generic virtio_pci pata_acpi virtio_ring virtio i2c_core floppy
[ 2133.278480] CPU: 0 PID: 10226 Comm: dhclient Tainted: GF       W
3.14.0-rc3+ #20
[ 2133.284651] Hardware name: Red Hat KVM, BIOS Bochs 01/01/2011
[ 2133.289983]  0000000000000009 ffff8800bb3ed970 ffffffff816a2b65
0000000000000000
[ 2133.296498]  ffff8800bb3ed9a8 ffffffff8108196d ffff880138694200
ffff8800b8295840
[ 2133.302891]  ffff8800b8295840 0000000000000000 000000000a0000ef
ffff8800bb3ed9b8
[ 2133.309170] Call Trace:
[ 2133.313236]  [<ffffffff816a2b65>] dump_stack+0x45/0x56
[ 2133.318500]  [<ffffffff8108196d>] warn_slowpath_common+0x7d/0xa0
[ 2133.324052]  [<ffffffff81081a4a>] warn_slowpath_null+0x1a/0x20
[ 2133.329153]  [<ffffffff815e1fa9>] ip_mc_output+0x189/0x250
[ 2133.333910]  [<ffffffff815e1825>] ip_local_out+0x25/0x30
[ 2133.338845]  [<ffffffff81624225>] iptunnel_xmit+0xf5/0x110
[ 2133.343609]  [<ffffffffa033b36d>] vxlan_xmit_skb+0x1bd/0x340 [vxlan]
[ 2133.349063]  [<ffffffffa033c235>] vxlan_xmit_one+0x5e5/0xa60 [vxlan]
[ 2133.354062]  [<ffffffffa033dcdc>] vxlan_xmit+0x13c/0x8f0 [vxlan]
[ 2133.359125]  [<ffffffff8159261e>] ? __alloc_skb+0x7e/0x2b0
[ 2133.363963]  [<ffffffff81591c91>] ? __kmalloc_reserve.isra.25+0x31/0x90
[ 2133.369216]  [<ffffffff815925ee>] ? __alloc_skb+0x4e/0x2b0
[ 2133.374104]  [<ffffffff815a4146>] dev_hard_start_xmit+0x326/0x5d0
[ 2133.379153]  [<ffffffff815a4706>] __dev_queue_xmit+0x316/0x480
[ 2133.384179]  [<ffffffff815a4880>] dev_queue_xmit+0x10/0x20
[ 2133.389063]  [<ffffffff8168ca4b>] packet_sendmsg+0xfab/0x1050
[ 2133.393805]  [<ffffffff815886de>] sock_aio_write+0xfe/0x130
[ 2133.398450]  [<ffffffff811cfb2a>] do_sync_write+0x5a/0x90
[ 2133.403282]  [<ffffffff811d0395>] vfs_write+0x1c5/0x1e0
[ 2133.407887]  [<ffffffff811d0c69>] SyS_write+0x49/0xa0
[ 2133.412713]  [<ffffffff81110d46>] ? __audit_syscall_exit+0x1f6/0x2a0
[ 2133.417899]  [<ffffffff816b2369>] system_call_fastpath

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/ip.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/ip.h b/include/net/ip.h
index 25064c2..d9f1fbd 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -428,6 +428,8 @@ static inline int sk_mc_loop(struct sock *sk)
 	case AF_INET6:
 		return inet6_sk(sk)->mc_loop;
 #endif
+	case AF_PACKET:
+		return 1;
 	}
 	WARN_ON(1);
 	return 1;
-- 
1.8.3.1
