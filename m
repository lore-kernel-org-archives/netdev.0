From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: revert use of copy_from_iter_full()
Date: Wed, 21 Dec 2016 20:01:37 -0500
Message-ID: <1482368497-7103-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        parthasarathy.bhuvaragan@ericsson.com, ying.xue@windriver.com,
        maloy@donjonn.com, tipc-discussion@lists.sourceforge.net,
        Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:31753 "EHLO
        smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932352AbcLVBBo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 20:01:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit cbbd26b8b1a6 ("[iov_iter] new primitives - copy_from_iter_full()
and friends") replaced calls to copy_from_iter() in the function
tipc_msg_build(). This causes a an immediate crash as follows:

[ 1209.597076] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[ 1209.607025] IP: copy_from_iter_full+0x43/0x290
[ 1209.611617] PGD 130f63067
[ 1209.611621] PUD 130f64067
[ 1209.614437] PMD 0
[ 1209.616966]
[ 1209.620351] Oops: 0000 [#1] SMP
[ 1209.622739] Modules linked in: tipc(E) ip6_udp_tunnel udp_tunnel rpcsec_gss_krb5 auth_rpcgss nfsv4 nfs lockd xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat grace fscache nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack xt_tcpudp iptable_filter ip_tables x_tables ppdev joydev serio_raw parport_pc parport i2c_piix4 sunrpc autofs4 floppy psmouse pata_acpi [last unloaded: tipc]
[ 1209.643115] CPU: 7 PID: 1911 Comm: tipcTC Tainted: G            E   4.9.0+ #619
[ 1209.647707] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
[ 1209.653393] task: ffff96c2f0c58000 task.stack: ffffb7cdc07a8000
[ 1209.656626] RIP: 0010:copy_from_iter_full+0x43/0x290
[ 1209.659412] RSP: 0018:ffffb7cdc07abc38 EFLAGS: 00010246
[ 1209.662459] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000018
[ 1209.666443] RDX: ffffb7cdc07abe00 RSI: 0000000000000000 RDI: ffff96c2f39e86b8
[ 1209.669918] RBP: ffffb7cdc07abc78 R08: 0000000000000000 R09: 0000000000000000
[ 1209.673379] R10: ffff96c2f50032c0 R11: ffff96c2f39e8600 R12: ffffb7cdc07abe00
[ 1209.676585] R13: 0000000000000000 R14: ffff96c2f39e86b8 R15: 0000000000000000
[ 1209.678573] FS:  00007fb5db2a3700(0000) GS:ffff96c2f9dc0000(0000) knlGS:0000000000000000
[ 1209.681433] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1209.684321] CR2: 0000000000000008 CR3: 0000000130f66000 CR4: 00000000000406e0
[ 1209.687676] Call Trace:
[ 1209.689257]  tipc_msg_build+0xe1/0x590 [tipc]
[ 1209.691479]  ? _raw_spin_unlock_bh+0x1e/0x20
[ 1209.694641]  ? tipc_node_find+0x30/0xa0 [tipc]
[ 1209.696789]  __tipc_sendmsg+0x189/0x480 [tipc]
[ 1209.699017]  ? remove_wait_queue+0x4d/0x60
[ 1209.700354]  tipc_connect+0x15f/0x1b0 [tipc]
[ 1209.701684]  SYSC_connect+0xd9/0x110
[ 1209.702847]  ? sock_alloc_file+0xa6/0x130
[ 1209.704083]  ? fd_install+0x25/0x30
[ 1209.705195]  ? sock_map_fd+0x44/0x70
[ 1209.706331]  SyS_connect+0xe/0x10
[ 1209.707385]  entry_SYSCALL_64_fastpath+0x1e/0xad
[ 1209.708714] RIP: 0033:0x7fb5dadca870
[ 1209.709700] RSP: 002b:00007fff6ea43978 EFLAGS: 00000246 ORIG_RAX: 000000000000002a
[ 1209.711948] RAX: ffffffffffffffda RBX: 0000000000000009 RCX: 00007fb5dadca870
[ 1209.713804] RDX: 0000000000000010 RSI: 00007fff6ea43990 RDI: 0000000000000003
[ 1209.715413] RBP: 00000000012e8010 R08: 0000000000008004 R09: 0000000000000009
[ 1209.716440] R10: 000000000000012a R11: 0000000000000246 R12: 0000000000000009
[ 1209.717461] R13: 0000000000000001 R14: 00007fb5db087620 R15: 0000000000404fe4
[ 1209.718486] Code: 01 00 00 48 39 72 10 49 89 f5 49 89 d4 0f 82 69 01 00 00 48 8b 72 08 45 31 c9 a8 04 49 89 fe 45 89 e8 41 89 f7 75 6f 4c 8b 7a 18 <49> 8b 5f 08 48 29 f3 4c 39 eb 49 0f 47 dd a8 02 0f 85 6e 01 00
[ 1209.721328] RIP: copy_from_iter_full+0x43/0x290 RSP: ffffb7cdc07abc38
[ 1209.723573] CR2: 0000000000000008
[ 1209.725262] ---[ end trace 752756f533c3f533 ]---
[ 1209.726603] Kernel panic - not syncing: Fatal exception
[ 1209.728293] Kernel Offset: 0x2f000000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[ 1209.731225] ---[ end Kernel panic - not syncing: Fatal exception

When we revert the change everything works fine, so we choose this solution for now.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/msg.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index a22be50..17201aa 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -268,7 +268,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 		__skb_queue_tail(list, skb);
 		skb_copy_to_linear_data(skb, mhdr, mhsz);
 		pktpos = skb->data + mhsz;
-		if (copy_from_iter_full(pktpos, dsz, &m->msg_iter))
+		if (copy_from_iter(pktpos, dsz, &m->msg_iter) == dsz)
 			return dsz;
 		rc = -EFAULT;
 		goto error;
@@ -299,7 +299,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 		if (drem < pktrem)
 			pktrem = drem;
 
-		if (!copy_from_iter_full(pktpos, pktrem, &m->msg_iter)) {
+		if (copy_from_iter(pktpos, pktrem, &m->msg_iter) != pktrem) {
 			rc = -EFAULT;
 			goto error;
 		}
-- 
2.7.4
