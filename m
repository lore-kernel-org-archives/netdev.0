From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: sctp: sctp_set_owner_w: fix panic during skb orphaning
Date: Wed,  7 Aug 2013 12:42:01 +0200
Message-ID: <1375872121-12429-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26353 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757249Ab3HGKmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Aug 2013 06:42:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following triggered bug ...

[  553.109742] kernel BUG at include/linux/skbuff.h:1813!
[  553.109766] invalid opcode: 0000 [#1] SMP
[  553.109789] Modules linked in: sctp libcrc32c rfcomm [...]
[  553.110259]  uinput i915 i2c_algo_bit drm_kms_helper e1000e drm ptp pps_core i2c_core wmi video sunrpc
[  553.110320] CPU: 0 PID: 1636 Comm: lt-test_1_to_1_ Not tainted 3.11.0-rc3+ #2
[  553.110350] Hardware name: LENOVO 74597D6/74597D6, BIOS 6DET60WW (3.10 ) 09/17/2009
[  553.110381] task: ffff88020a01dd40 ti: ffff880204ed0000 task.ti: ffff880204ed0000
[  553.110411] RIP: 0010:[<ffffffffa0698017>]  [<ffffffffa0698017>] skb_orphan.part.9+0x4/0x6 [sctp]
[  553.110459] RSP: 0018:ffff880204ed1bb8  EFLAGS: 00010286
[  553.110483] RAX: ffff8802086f5a40 RBX: ffff880204303300 RCX: 0000000000000000
[  553.110487] RDX: ffff880204303c28 RSI: ffff8802086f5a40 RDI: ffff880202158000
[  553.110487] RBP: ffff880204ed1bb8 R08: 0000000000000000 R09: 0000000000000000
[  553.110487] R10: ffff88022f2d9a04 R11: ffff880233001600 R12: 0000000000000000
[  553.110487] R13: ffff880204303c00 R14: ffff8802293d0000 R15: ffff880202158000
[  553.110487] FS:  00007f31b31fe740(0000) GS:ffff88023bc00000(0000) knlGS:0000000000000000
[  553.110487] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  553.110487] CR2: 000000379980e3e0 CR3: 000000020d225000 CR4: 00000000000407f0
[  553.110487] Stack:
[  553.110487]  ffff880204ed1ca8 ffffffffa068d7fc 0000000000000000 0000000000000000
[  553.110487]  0000000000000000 ffff8802293d0000 ffff880202158000 ffffffff81cb7900
[  553.110487]  0000000000000000 0000400000001c68 ffff8802086f5a40 000000000000000f
[  553.110487] Call Trace:
[  553.110487]  [<ffffffffa068d7fc>] sctp_sendmsg+0x6bc/0xc80 [sctp]
[  553.110487]  [<ffffffff8128f185>] ? sock_has_perm+0x75/0x90
[  553.110487]  [<ffffffff815a3593>] inet_sendmsg+0x63/0xb0
[  553.110487]  [<ffffffff8128f2b3>] ? selinux_socket_sendmsg+0x23/0x30
[  553.110487]  [<ffffffff8151c5d6>] sock_sendmsg+0xa6/0xd0
[  553.110487]  [<ffffffff81637b05>] ? _raw_spin_unlock_bh+0x15/0x20
[  553.110487]  [<ffffffff8151cd38>] SYSC_sendto+0x128/0x180
[  553.110487]  [<ffffffff8151ce6b>] ? SYSC_connect+0xdb/0x100
[  553.110487]  [<ffffffffa0690031>] ? sctp_inet_listen+0x71/0x1f0 [sctp]
[  553.110487]  [<ffffffff8151d35e>] SyS_sendto+0xe/0x10
[  553.110487]  [<ffffffff81640202>] system_call_fastpath+0x16/0x1b
[  553.110487] Code: e0 48 c7 c7 00 22 6a a0 e8 67 a3 f0 e0 48 c7 [...]
[  553.110487] RIP  [<ffffffffa0698017>] skb_orphan.part.9+0x4/0x6 [sctp]
[  553.110487]  RSP <ffff880204ed1bb8>
[  553.121578] ---[ end trace 46c20c5903ef5be2 ]---

... that is triggered after commit 376c7311b ("net: add a temporary sanity
check in skb_orphan()"). What is happening is that we call sctp_set_owner_w()
for chunks in the SCTP output path from sctp_sendmsg(). Such chunks eventually
origin from constructors like sctp_make_chunk() where skb->sk = sk is being
set for socket accounting. Doing a git grep -n "skb->sk" net/sctp/ shows that
also in other places the socket pointer is being set, before issuing a
SCTP_CMD_SEND_PKT command and the like. Since SCTP is doing it's own memory
accounting anyway and has its own skb destructor functions, we should
customize sctp_set_owner_w() and call skb_orphan() if we set a different
owner of the skb than the current one in order to properly call their
destructor function, but not run into a panic due to our non-exisiting one as
we set sctp_wfree() destructor right after that. Otherwise, we can just skip
orphaning and reassignment to the very same socket and only set the destructor
handler.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Only in net-next.

 net/sctp/socket.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d5d5882..7459b6c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -153,13 +153,18 @@ static inline void sctp_set_owner_w(struct sctp_chunk *chunk)
 {
 	struct sctp_association *asoc = chunk->asoc;
 	struct sock *sk = asoc->base.sk;
+	struct sk_buff *skb = chunk->skb;
 
 	/* The sndbuf space is tracked per association.  */
 	sctp_association_hold(asoc);
 
-	skb_set_owner_w(chunk->skb, sk);
+	if (skb->sk != sk) {
+		skb_orphan(skb);
+		skb->sk = sk;
+	}
+
+	skb->destructor = sctp_wfree;
 
-	chunk->skb->destructor = sctp_wfree;
 	/* Save the chunk pointer in skb for sctp_wfree to use later.  */
 	*((struct sctp_chunk **)(chunk->skb->cb)) = chunk;
 
@@ -167,9 +172,10 @@ static inline void sctp_set_owner_w(struct sctp_chunk *chunk)
 				sizeof(struct sk_buff) +
 				sizeof(struct sctp_chunk);
 
-	atomic_add(sizeof(struct sctp_chunk), &sk->sk_wmem_alloc);
-	sk->sk_wmem_queued += chunk->skb->truesize;
-	sk_mem_charge(sk, chunk->skb->truesize);
+	atomic_add(sizeof(struct sctp_chunk) + skb->truesize,
+		   &sk->sk_wmem_alloc);
+	sk->sk_wmem_queued += skb->truesize;
+	sk_mem_charge(sk, skb->truesize);
 }
 
 /* Verify that this is a valid address. */
-- 
1.7.11.7
